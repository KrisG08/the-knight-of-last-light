extends PanelContainer
## Full-screen presentation of the existing campaign menu actions.
const Style = preload("res://game/presentation/ui_style.gd")
var game: Node
var shell: Control
var title: Label
var subtitle: Label
var card: PanelContainer
var main_page: VBoxContainer
var actions_page: VBoxContainer
var journal: Button
var utilities: Button
var summary: Label
var new_journey: Button
var previous_scale := -1.0
var previous_saved := false
var art: TextureRect
var atmosphere: Control
var heading: Label
var animation_clock := 0.0
var page_tween: Tween
var progress_button: Button
var journeys_button: Button
var cached_id := -1
var cached_revision := -1
var cached_summary := ""
var language_picker: OptionButton
var account_button: Button
var utility_bar: VBoxContainer
var previous_language := ""
var previous_playing:=false
var modal_shade: ColorRect
var living_scene: Control
var title_protected_rect:=Rect2()

func setup(owner_game: Node) -> void:
	game = owner_game
	name = "MobileFrontEnd"
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	shell = Control.new()
	add_child(shell)
	living_scene=preload("res://game/presentation/menu_living_scene.gd").new()
	shell.add_child(living_scene); living_scene.setup()
	art=living_scene.landscape
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.008,0.014,0.022,0.30))
	gradient.set_color(1, Color(0.015,0.025,0.03,0.48))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.RIGHT
	var shade := TextureRect.new()
	shade.name="MenuReadabilityShade"
	shade.texture = texture
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shell.add_child(shade)
	atmosphere = preload("res://game/presentation/frontend_atmosphere.gd").new()
	shell.add_child(atmosphere)
	modal_shade=ColorRect.new()
	modal_shade.color=Color(0.01,0.015,0.02,0.72)
	modal_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal_shade.hide(); shell.add_child(modal_shade)
	utility_bar=VBoxContainer.new(); utility_bar.add_theme_constant_override("separation",12)
	utility_bar.name="BottomLeftUtilities"
	shell.add_child(utility_bar)
	account_button=Button.new()
	preload("res://game/localization/localizer.gd").set_text(account_button,"Account")
	account_button.custom_minimum_size=Vector2(0,48)
	account_button.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
	account_button.set_meta("base_font_size",18)
	Style.apply_button(account_button)
	account_button.pressed.connect(func(): game.show_account())
	utility_bar.add_child(account_button)
	language_picker=OptionButton.new(); language_picker.custom_minimum_size=Vector2(0,48)
	language_picker.fit_to_longest_item=false
	language_picker.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
	language_picker.set_meta("base_font_size",18)
	language_picker.auto_translate_mode=Node.AUTO_TRANSLATE_MODE_DISABLED
	var languages: Dictionary=preload("res://game/localization/localizer.gd").LANGUAGES
	for code in languages:
		language_picker.add_item(languages[code]); language_picker.set_item_metadata(language_picker.item_count-1,code)
		if code==game.settings.values.language: language_picker.select(language_picker.item_count-1)
	language_picker.item_selected.connect(func(index): game.set_language(language_picker.get_item_metadata(index)))
	utility_bar.add_child(language_picker)
	title = Label.new()
	preload("res://game/localization/localizer.gd").set_text(title, "THE KNIGHT\nOF LAST LIGHT")
	title.add_theme_font_override("font", Style.title_font())
	title.set_meta("font_role","title")
	title.add_theme_font_size_override("font_size", 50)
	title.add_theme_color_override("font_color", Color("e8ddfa"))
	title.add_theme_color_override("font_outline_color",Color(0.035,0.018,0.065,0.85))
	title.add_theme_constant_override("outline_size",2)
	title.add_theme_color_override("font_shadow_color",Color(0.015,0.008,0.025,0.8))
	title.add_theme_constant_override("shadow_offset_y",3)
	var enchantment:=ShaderMaterial.new()
	enchantment.shader=preload("res://assets/materials/title_enchantment.gdshader")
	title.material=enchantment
	shell.add_child(title)
	subtitle = Label.new()
	preload("res://game/localization/localizer.gd").set_text(subtitle, "A KINGDOM WITHOUT DAWN.\nA FLAME THAT WILL NOT DIE.")
	subtitle.add_theme_color_override("font_color", Color("b4c3c1"))
	subtitle.add_theme_font_size_override("font_size", 19)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shell.add_child(subtitle)
	card = PanelContainer.new()
	var navigation_frame := Style.frame(Color(0.025,0.018,0.038,0.66),Color(0.63,0.40,0.84,0.35),24)
	card.add_theme_stylebox_override("panel",navigation_frame)
	shell.add_child(card)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	card.add_child(scroll)
	var pages := VBoxContainer.new()
	pages.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(pages)
	main_page = VBoxContainer.new()
	main_page.add_theme_constant_override("separation", 8)
	pages.add_child(main_page)
	heading = Label.new()
	preload("res://game/localization/localizer.gd").set_text(heading, "YOUR JOURNEY")
	heading.add_theme_color_override("font_color", Color("c4a0ff"))
	main_page.add_child(heading)
	game.slots = OptionButton.new()
	game.slots.custom_minimum_size.y = 48
	game.slots.add_theme_font_size_override("font_size",20)
	preload("res://game/localization/localizer.gd").add_item(game.slots,"No saved journeys yet",1)
	main_page.add_child(game.slots)
	game.slots.item_selected.connect(func(_index): game.refresh_slot_buttons())
	summary = Label.new()
	summary.add_theme_font_size_override("font_size",15)
	summary.add_theme_color_override("font_color",Color("9baeb0"))
	main_page.add_child(summary)
	game.load_button = action(main_page,"Continue journey",func(): game.start_selected(true),true)
	game.resume_button = action(main_page,"Return to the journey",resume,true)
	new_journey = action(main_page,"Begin a new journey",game.request_new)
	action(main_page,"Settings",game.show_settings)
	progress_button = action(main_page,"World progress",game.show_journey_progress)
	journeys_button = action(main_page,"Saved journeys",game.show_saved_journeys)
	utilities = action(main_page,"More actions",func(): show_actions(true))
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation",12)
	main_page.add_child(footer)
	var credits := action(footer,"Credits",game.show_credits)
	credits.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game.quit_button = action(footer,"Quit",func():
		if game.session.active: game.save_and_return_to_menu()
		else: game.quit_game())
	game.quit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	actions_page = VBoxContainer.new()
	actions_page.add_theme_constant_override("separation",12)
	pages.add_child(actions_page)
	action(actions_page,"Back to menu",func(): show_actions(false))
	journal = action(actions_page,"Journal / routes",game.show_journal)
	game.journal_button = journal
	for entry in [["Drink flask","heal"],["Jump","jump"],["Lock / unlock target","target_lock"],["Next target","cycle_target"],["Companion follow / hold","companion_order"]]:
		var command: String = entry[1]
		action(actions_page,entry[0],func(): game.mobile_menu_action(command))
	game.retry_save_button = action(main_page,"Retry saving",func(): game.session.save_progress())
	game.menu_note = Label.new()
	game.menu_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game.menu_note.add_theme_font_size_override("font_size",17)
	main_page.add_child(game.menu_note)
	var version := Label.new()
	preload("res://game/localization/localizer.gd").set_text(version, "Version "+str(ProjectSettings.get_setting("application/config/version")))
	version.add_theme_font_size_override("font_size",14)
	version.add_theme_color_override("font_color",Color("9baeb0"))
	main_page.add_child(version)
	show_actions(false)
	visibility_changed.connect(func():
		if visible: show_actions(false))
	resized.connect(arrange)
	arrange()

func action(parent: Node, text: String, callback: Callable, primary: bool = false) -> Button:
	var item: Button = game.button(parent,text,callback)
	item.custom_minimum_size.y = 60 if primary else 48
	item.clip_text=true
	item.add_theme_font_size_override("font_size",22 if primary else 20)
	item.set_meta("base_font_size",22 if primary else 20)
	Style.navigation_button(item,primary)
	return item

func resume() -> void:
	if game.player.health <= 0: game.respawn()
	else: game.pause(false)

func show_actions(open: bool) -> void:
	main_page.visible = not open
	actions_page.visible = open
	var page: Control = actions_page if open else main_page
	if is_instance_valid(page_tween): page_tween.kill()
	page.modulate.a = 1.0
	if game.settings.values.get("menu_motion",true) and is_visible_in_tree():
		page.modulate.a = 0.0
		page_tween = create_tween()
		page_tween.tween_property(page,"modulate:a",1.0,0.2)

func _process(delta: float) -> void:
	if not is_instance_valid(game) or not is_instance_valid(game.player): return
	var overlay: bool=(is_instance_valid(game.account_panel) and game.account_panel.visible) or (is_instance_valid(game.settings_panel) and game.settings_panel.visible) or (is_instance_valid(game.dialogue) and game.dialogue.visible)
	modal_shade.visible=overlay
	for item in [card,utility_bar,title,subtitle]: item.visible=not overlay
	var playing: bool = game.session.active
	account_button.disabled=playing
	atmosphere.enabled = game.settings.values.get("menu_motion",true)
	living_scene.visible=not playing
	living_scene.advance(delta,atmosphere.enabled)
	animation_clock=living_scene.clock
	title.material.set_shader_parameter("animation_clock",animation_clock)
	preload("res://game/localization/localizer.gd").set_text(title, "JOURNEY\nPAUSED" if playing else "THE KNIGHT\nOF LAST LIGHT")
	preload("res://game/localization/localizer.gd").set_text(heading, "RETURN TO THE LIGHT" if playing else "YOUR JOURNEY")
	new_journey.visible = not playing
	game.slots.visible = not playing
	preload("res://game/localization/localizer.gd").set_text(subtitle, (game.region.region_id.trim_prefix("region.").replace("_"," ").to_upper()+"\n"+game.objective()) if playing and is_instance_valid(game.region) else "A KINGDOM WITHOUT DAWN.\nA FLAME THAT WILL NOT DIE.")
	game.load_button.visible = not playing
	game.resume_button.visible = playing
	preload("res://game/localization/localizer.gd").set_text(game.resume_button, "Return to the lantern" if game.player.health <= 0 else "Resume journey")
	journal.visible = playing
	utilities.visible = playing and game.player.health > 0
	progress_button.disabled = not playing and game.load_button.disabled
	journeys_button.visible = playing
	if cached_id != game.slots.get_selected_id() or cached_revision != game.session.revision:
		cached_id = game.slots.get_selected_id()
		cached_revision = game.session.revision
		var snapshot: Dictionary = game.session.state if playing else game.session.store.load_slot(cached_id).get("state",{})
		cached_summary = preload("res://game/persistence/domain/journey_history.gd").summary(snapshot) if not snapshot.is_empty() else "An unwritten journey"
	preload("res://game/localization/localizer.gd").set_text(summary, cached_summary)
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var saved: bool = not game.load_button.disabled
	if previous_scale < 0 or previous_saved != saved:
		Style.navigation_button(new_journey,not saved)
		previous_saved = saved
	var scale_value: float = game.settings.values.ui_scale
	var locale: String=preload("res://game/localization/localizer.gd").language
	if previous_scale != scale_value or previous_language!=locale or previous_playing!=playing:
		previous_scale = scale_value
		previous_language=locale
		previous_playing=playing
		for index in range(language_picker.item_count):
			if language_picker.get_item_metadata(index)==locale: language_picker.select(index)
		for item in find_children("*","Button",true,false):
			item.add_theme_font_size_override("font_size",roundi(item.get_meta("base_font_size",20)*scale_value))
			item.alignment=HORIZONTAL_ALIGNMENT_RIGHT if locale=="ar" else HORIZONTAL_ALIGNMENT_LEFT
		game.slots.add_theme_font_size_override("font_size",roundi(20*scale_value))
		arrange()

func arrange() -> void:
	if not is_instance_valid(shell): return
	var extent := size
	var safe: Vector4 = preload("res://game/presentation/mobile_display.gd").safe_margins(extent)
	var margin := maxf(32,maxf(safe.y,safe.w))
	var width := 440.0 * minf(1.25,maxf(1.0,previous_scale))
	card.position = Vector2(extent.x-width-maxf(margin,safe.z),margin)
	card.size = Vector2(width,extent.y-margin*2)
	account_button.custom_minimum_size.y=48.0*maxf(1.0,previous_scale)
	language_picker.custom_minimum_size.y=48.0*maxf(1.0,previous_scale)
	var utility_alignment:=Control.SIZE_SHRINK_END if previous_language=="ar" else Control.SIZE_SHRINK_BEGIN
	account_button.size_flags_horizontal=utility_alignment
	language_picker.size_flags_horizontal=utility_alignment
	var account_min:=account_button.get_combined_minimum_size()
	var language_min:=language_picker.get_combined_minimum_size()
	var utility_height:=account_min.y+language_min.y+12.0
	var utility_width:=maxf(account_min.x,language_min.x)
	utility_bar.position=Vector2(maxf(margin,safe.x)+12,extent.y-maxf(margin,safe.w)-utility_height)
	utility_bar.size=Vector2(utility_width,utility_height)
	title.position = Vector2(maxf(margin,safe.x)+12, extent.y * 0.09)
	var text_width:=maxf(200,minf(extent.x*0.52-title.position.x,card.position.x-title.position.x-48))
	title.autowrap_mode=TextServer.AUTOWRAP_OFF
	var face := Style.title_font()
	var measured := 1.0
	for line in title.text.split("\n"):
		measured=maxf(measured,face.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,50).x)
	var title_size:=clampi(roundi(50*minf(1,text_width/maxf(1,measured))),24,50)
	title.add_theme_font_size_override("font_size",title_size)
	title.size=Vector2(text_width,face.get_height(title_size)*title.text.split("\n").size()+8)
	title.material.set_shader_parameter("title_extent",title.size)
	subtitle.position=title.position+Vector2(4,title.size.y+12)
	subtitle.size=Vector2(text_width,100)
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT if previous_language=="ar" else HORIZONTAL_ALIGNMENT_LEFT
	subtitle.horizontal_alignment=title.horizontal_alignment
	var subtitle_height:=Style.font().get_multiline_string_size(subtitle.text,HORIZONTAL_ALIGNMENT_LEFT,text_width,19).y
	title_protected_rect=Rect2(title.position,Vector2(text_width,subtitle.position.y+subtitle_height-title.position.y))
	atmosphere.exclusion_rect=title_protected_rect
	var last_line: String=subtitle.text.split("\n")[-1]
	var tagline_end:=subtitle.position.x+Style.font().get_string_size(last_line,HORIZONTAL_ALIGNMENT_LEFT,-1,19).x
	living_scene.reframe_for_menu(tagline_end,card.get_rect())
	living_scene.place_moon(title_protected_rect,card.get_rect())
