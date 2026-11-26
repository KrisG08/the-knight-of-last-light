extends PanelContainer
const L = preload("res://game/localization/localizer.gd")
const Style = preload("res://game/presentation/ui_style.gd")
signal closed
var auth: Node
var sync: Node
var game: Node
var mode := "login"
var heading: Label
var note: Label
var session_note: Label
var fields: VBoxContainer
var profile: VBoxContainer
var name_row: VBoxContainer
var password_row: VBoxContainer
var confirm_row: VBoxContainer
var code_row: VBoxContainer
var email: LineEdit
var password: LineEdit
var confirm: LineEdit
var display_name: LineEdit
var code: LineEdit
var submit: Button
var tabs: HBoxContainer
var controls: Array[Button] = []
var arranging := false
var resend: Button

func setup(owner_game: Node) -> void:
	game=owner_game; auth=game.cloud_account; sync=game.cloud_sync
	process_mode=Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	offset_left=-340; offset_right=340; offset_top=-320; offset_bottom=320
	add_theme_stylebox_override("panel",Style.frame(Color(0.025,0.032,0.038,0.98),Color("80629d"),24))
	var scroll := ScrollContainer.new(); scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; add_child(scroll)
	var body := VBoxContainer.new(); body.size_flags_horizontal=Control.SIZE_EXPAND_FILL; body.add_theme_constant_override("separation",12); scroll.add_child(body)
	heading=Label.new(); heading.add_theme_font_size_override("font_size",28); body.add_child(heading)
	session_note=Label.new(); session_note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; body.add_child(session_note)
	L.set_text(session_note,"Local progress is safe while offline.")
	tabs=HBoxContainer.new(); tabs.add_theme_constant_override("separation",10); body.add_child(tabs)
	for item in [["Sign in","login"],["Create account","signup"],["Forgot password?","recover"]]:
		var target: String=item[1]
		button(tabs,item[0],func(): mode=target; password.clear(); confirm.clear(); refresh())
	fields=VBoxContainer.new(); fields.add_theme_constant_override("separation",8); body.add_child(fields)
	display_name=input(fields,"Display name",false); display_name.max_length=32; name_row=display_name.get_parent()
	email=input(fields,"Email",false); email.placeholder_text="you@example.com"; email.max_length=254
	password=input(fields,"Password",true); password_row=password.get_parent()
	confirm=input(fields,"Confirm password",true); confirm_row=confirm.get_parent()
	code=input(fields,"Verification code",false); code.max_length=12; code_row=code.get_parent()
	submit=button(fields,"Sign in",submit_form,true)
	resend=button(fields,"Resend confirmation email",func():
		if game.session.active: return
		password.clear(); confirm.clear()
		await auth.resend_confirmation(email.text))
	profile=VBoxContainer.new(); profile.add_theme_constant_override("separation",10); body.add_child(profile)
	button(profile,"Sync now",func(): sync.synchronize())
	button(profile,"Import local journeys",func():
		var count: int=sync.import_guest()
		L.set_text(note,L.text("Imported journeys: %d")%count))
	button(profile,"Sign out",func(): if not sync.busy: auth.sign_out())
	note=Label.new(); note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; note.custom_minimum_size.x=580; body.add_child(note)
	var back := button(body,"Close",func(): close())
	controls.erase(back)
	auth.changed.connect(refresh); auth.status_changed.connect(refresh); sync.changed.connect(refresh)
	resized.connect(arrange)
	arrange(); refresh(); hide()

func input(parent: Node, caption: String, secret: bool) -> LineEdit:
	var row := VBoxContainer.new(); parent.add_child(row)
	var label := Label.new(); L.set_text(label,caption); row.add_child(label)
	var field := LineEdit.new(); field.secret=secret; field.max_length=256; field.custom_minimum_size.y=44
	row.add_child(field)
	return field

func button(parent: Node, caption: String, callback: Callable, primary: bool=false) -> Button:
	var item := Button.new(); L.set_text(item,caption); item.custom_minimum_size.y=46
	item.size_flags_horizontal=Control.SIZE_EXPAND_FILL; item.clip_text=true
	Style.apply_button(item,primary); item.pressed.connect(callback); parent.add_child(item); controls.append(item)
	return item

func arrange() -> void:
	if not is_inside_tree() or arranging: return
	arranging=true
	var size_value := get_viewport_rect().size
	if Style.mobile() or size_value.y<680 or size_value.x<1000:
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		offset_left=24; offset_top=24; offset_right=-24; offset_bottom=-24
	else:
		set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		offset_left=-340; offset_right=340; offset_top=-320; offset_bottom=320
	if is_instance_valid(note): note.custom_minimum_size.x=minf(580,maxf(240,size_value.x-100))
	arranging=false

func refresh() -> void:
	if not is_instance_valid(fields): return
	var signed: bool=auth.authenticated()
	L.set_text(session_note,"Local progress is safe while offline." if signed or auth.email_codes_ready else "Account registration is currently in testing. You can keep playing offline.")
	L.set_text(heading,"Cloud saves" if signed else "Account")
	tabs.visible=not signed; fields.visible=not signed; profile.visible=signed
	name_row.visible=mode=="signup"
	password_row.visible=mode in ["login","signup","reset"]
	confirm_row.visible=mode in ["signup","reset"]
	code_row.visible=mode in ["verify","reset"]
	resend.visible=mode in ["login","verify"]
	L.set_text(submit,{"login":"Sign in","signup":"Create account","verify":"Verify email","recover":"Reset password","reset":"Reset password"}.get(mode,"Sign in"))
	var message: String=auth.notice
	if signed: message=str(auth.user.get("email",""))+"\n"+sync.notice+"\n"+L.text("You stay signed in for this play session.")
	L.set_text(note,message)
	for item in controls: item.disabled=auth.busy or sync.busy or not auth.configured()
	for field in [email,password,confirm,display_name,code]: field.editable=not auth.busy

func submit_form() -> void:
	if game.session.active or auth.busy: return
	if not email.text.contains("@"):
		L.set_text(note,"Enter a valid email address."); return
	if mode in ["signup","reset"] and password.text!=confirm.text:
		L.set_text(note,"Passwords do not match."); return
	match mode:
		"login": await auth.sign_in(email.text,password.text)
		"signup":
			if await auth.sign_up(email.text,password.text,display_name.text) and not auth.authenticated():
				mode="verify" if auth.email_codes_ready else "login"
		"verify": await auth.verify(email.text,code.text)
		"recover":
			if not auth.email_codes_ready:
				auth.notice="Password recovery is temporarily unavailable. Your local journeys are safe."
			elif await auth.recover(email.text): mode="reset"
		"reset":
			var next_password := password.text
			if await auth.verify(email.text,code.text,true): await auth.set_password(next_password)
	password.clear(); confirm.clear(); refresh()

func close() -> void:
	password.clear(); confirm.clear(); code.clear(); hide(); closed.emit()
