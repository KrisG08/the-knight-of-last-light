extends RefCounted
const Stone=preload("res://game/presentation/cursed_stone_style.gd")
const TITLE_FONT = preload("res://assets/fonts/ui_fantasy_title.tres")
const BODY_FONT = preload("res://assets/fonts/ui_fantasy_body.tres")
const BUTTON_FONT = BODY_FONT

static func font() -> Font:
	return BODY_FONT

static func title_font() -> Font:
	return TITLE_FONT

static func mobile() -> bool:
	return OS.has_feature("android") or OS.has_feature("ios") or "--touch" in OS.get_cmdline_user_args()

static func button_panel(primary: bool = false, state: String = "normal") -> Stone:
	var fill := Color("233040") if primary else Color("151e29")
	var edge := Color("e15aff") if primary else Color("ab60df")
	if state == "hover": fill = fill.lightened(0.10); edge = Color("ed9aff")
	if state == "pressed": fill = Color("101924"); edge = Color("ffd4ff")
	if state == "disabled": fill = Color("10151d"); edge = Color("50435e")
	var style := Stone.new()
	style.bg_color=fill; style.border_color=edge
	style.glow=0.95 if primary else 0.70
	if state=="hover": style.glow=1.2
	if state=="pressed": style.glow=1.4
	if state=="disabled": style.glow=0.12
	style.set_content_margin_all(14)
	style.shadow_color = Color(0,0,0,0.3)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0,1 if state=="pressed" else 3)
	return style

static func apply_button(item: Button, primary: bool = false) -> void:
	for state in ["normal","hover","pressed","disabled"]:
		item.add_theme_stylebox_override(state,button_panel(primary,state))
	item.add_theme_font_override("font",font())
	if not item.has_meta("button_feedback"):
		item.set_meta("button_feedback",true)
		item.add_child(preload("res://game/presentation/button_feedback.gd").new())

static func navigation_button(item: Button, primary: bool) -> void:
	apply_button(item,primary)
	item.alignment=HORIZONTAL_ALIGNMENT_LEFT
	for state in ["normal","hover","pressed","disabled"]:
		var box := button_panel(primary,state)
		box.bg_color.a=0.98 if primary else 0.93
		box.content_margin_left=38; box.content_margin_right=38
		box.shadow_size=2
		item.add_theme_stylebox_override(state,box)
	if not item.has_node("NavigationOrnament"):
		var decoration := preload("res://game/presentation/navigation_ornament.gd").new()
		decoration.name="NavigationOrnament"; item.add_child(decoration)

static func frame(fill: Color, edge: Color, margin: int = 14) -> StyleBox:
	if margin>=8 and fill.a>0.05:
		var stone:=Stone.new()
		stone.bg_color=fill; stone.border_color=edge
		stone.glow=0.45; stone.rim=minf(9,margin*0.4)
		stone.set_content_margin_all(margin)
		return stone
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(1)
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]:
		style.set_content_margin(side,margin)
	return style

static func theme(scale: float) -> Theme:
	var result := Theme.new()
	result.default_font = font()
	result.default_font_size = roundi((20 if mobile() else 16)*scale)
	for type in ["Button","OptionButton","CheckButton"]:
		result.set_font("font",type,font())
		for state in ["normal","hover","pressed","disabled"]:
			result.set_stylebox(state,type,button_panel(false,state))
			if type=="OptionButton":
				result.set_stylebox(state+"_mirrored",type,button_panel(false,state))
		result.set_stylebox("focus",type,frame(Color(0,0,0,0),Color("c4a0ff"),0))
		result.set_color("font_color",type,Color("d8dfda"))
		result.set_color("font_hover_color",type,Color("ffffff"))
	result.set_stylebox("panel","PanelContainer",frame(Color(0.025,0.055,0.08,0.94),Color("80629d"),22))
	result.set_stylebox("panel","AcceptDialog",frame(Color("131c28"),Color("b46bdf"),20))
	result.set_color("font_color","Label",Color("d8e4e2"))
	result.set_stylebox("normal","LineEdit",frame(Color("17131e"),Color("68517e"),10))
	result.set_stylebox("read_only","LineEdit",frame(Color("17131e"),Color("352b42"),10))
	result.set_stylebox("focus","LineEdit",frame(Color(0,0,0,0),Color("c4a0ff"),0))
	result.set_color("selection_color","LineEdit",Color("623f85"))
	result.set_color("caret_color","LineEdit",Color("e5ccff"))
	result.set_stylebox("panel","PopupMenu",frame(Color("191323"),Color("68517e"),10))
	result.set_stylebox("hover","PopupMenu",frame(Color("50306f"),Color("b68be8"),5))
	for type in ["HSlider","VSlider"]:
		result.set_stylebox("slider",type,frame(Color("25202f"),Color("68517e"),3))
		result.set_stylebox("grabber_area",type,frame(Color("714c97"),Color("b68be8"),3))
		result.set_stylebox("grabber_area_highlight",type,frame(Color("9d55ec"),Color("ddbbff"),3))
		result.set_icon("grabber",type,preload("res://assets/ui/violet-slider.svg"))
		result.set_icon("grabber_highlight",type,preload("res://assets/ui/violet-slider.svg"))
	for state in ["grabber","grabber_highlight","grabber_pressed"]:
		result.set_stylebox(state,"VScrollBar",frame(Color("68517e"),Color("80629d"),2))
	result.set_icon("checked","CheckButton",preload("res://assets/ui/violet-toggle-on.svg"))
	result.set_icon("unchecked","CheckButton",preload("res://assets/ui/violet-toggle-off.svg"))
	result.set_icon("checked_mirrored","CheckButton",preload("res://assets/ui/violet-toggle-on-rtl.svg"))
	result.set_icon("unchecked_mirrored","CheckButton",preload("res://assets/ui/violet-toggle-off-rtl.svg"))
	return result
