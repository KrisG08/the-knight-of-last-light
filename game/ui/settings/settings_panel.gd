extends PanelContainer

signal applied
signal closed
var settings: RefCounted
var capturing: String = ""
var action_picker: OptionButton
var feedback: Label
var body: VBoxContainer

func setup(model: RefCounted) -> void:
	settings = model
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	offset_left = -350
	offset_right = 350
	offset_top = -320
	offset_bottom = 320
	custom_minimum_size = Vector2(700, 640)
	var style := preload("res://game/presentation/ui_style.gd").frame(Color(0.025,0.032,0.038,0.98),Color("80629d"),22)
	add_theme_stylebox_override("panel", style)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10)
	scroll.add_child(body)
	rebuild()
	hide()

func rebuild() -> void:
	for child in body.get_children():
		body.remove_child(child)
		child.queue_free()
	var title := Label.new()
	var mobile := preload("res://game/presentation/mobile_controls.gd").requested()
	preload("res://game/localization/localizer.gd").set_text(title, "SETTINGS · TOUCH & AUDIO" if mobile else "SETTINGS · keyboard / mouse")
	body.add_child(title)
	var language_row := HBoxContainer.new(); body.add_child(language_row)
	var language_label := Label.new(); preload("res://game/localization/localizer.gd").set_text(language_label,"Language")
	language_label.custom_minimum_size.x=330; language_row.add_child(language_label)
	var picker := OptionButton.new(); language_row.add_child(picker)
	var languages: Dictionary=preload("res://game/localization/localizer.gd").LANGUAGES
	for code in languages:
		picker.add_item(languages[code]); picker.set_item_metadata(picker.item_count-1,code)
		if code==settings.values.language: picker.select(picker.item_count-1)
	picker.item_selected.connect(func(index): settings.set_value("language",picker.get_item_metadata(index)); applied.emit())
	var quality_row:=HBoxContainer.new(); body.add_child(quality_row)
	var quality_label:=Label.new(); preload("res://game/localization/localizer.gd").set_text(quality_label,"Graphics quality")
	quality_label.custom_minimum_size.x=330; quality_row.add_child(quality_label)
	var quality_picker:=OptionButton.new(); quality_picker.name="GraphicsQuality"
	quality_picker.custom_minimum_size=Vector2(250,56) if mobile else Vector2(180,42)
	quality_row.add_child(quality_picker)
	var qualities:=["high","balanced","performance"]
	for index in range(qualities.size()):
		preload("res://game/localization/localizer.gd").add_item(quality_picker,["High quality","Balanced","Performance"][index])
		if qualities[index]==settings.values.graphics_quality: quality_picker.select(index)
	quality_picker.item_selected.connect(func(index): settings.set_value("graphics_quality",qualities[index]); applied.emit())
	var limit_row:=HBoxContainer.new(); body.add_child(limit_row)
	var limit_label:=Label.new(); preload("res://game/localization/localizer.gd").set_text(limit_label,"Frame limit")
	limit_label.custom_minimum_size.x=330; limit_row.add_child(limit_label)
	var limit_picker:=OptionButton.new(); limit_picker.name="FrameLimit"; limit_row.add_child(limit_picker)
	limit_picker.custom_minimum_size=Vector2(250,56) if mobile else Vector2(180,42)
	var limits: Array=preload("res://game/settings/game_settings.gd").FRAME_LIMITS
	for index in range(limits.size()):
		limit_picker.add_item("%d FPS"%limits[index])
		if limits[index]==settings.values.frame_limit: limit_picker.select(index)
	limit_picker.item_selected.connect(func(index): settings.set_value("frame_limit",limits[index]); applied.emit())
	var resolution_row:=HBoxContainer.new(); body.add_child(resolution_row)
	var resolution_label:=Label.new(); preload("res://game/localization/localizer.gd").set_text(resolution_label,"3D resolution")
	resolution_label.custom_minimum_size.x=330; resolution_row.add_child(resolution_label)
	var resolution_picker:=OptionButton.new(); resolution_picker.name="RenderResolution"
	resolution_picker.custom_minimum_size=Vector2(250,56) if mobile else Vector2(180,42)
	resolution_row.add_child(resolution_picker)
	for entry in ["Profile default","Native screen"]:
		preload("res://game/localization/localizer.gd").add_item(resolution_picker,entry)
	resolution_picker.select(1 if settings.values.render_resolution=="native" else 0)
	resolution_picker.item_selected.connect(func(index): settings.set_value("render_resolution","native" if index==1 else "profile"); applied.emit(); refresh_render_info())
	var render_info:=Label.new(); render_info.name="RenderInfo"
	render_info.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; render_info.custom_minimum_size.x=620
	body.add_child(render_info)
	refresh_render_info()
	limit_picker.item_selected.connect(func(_index): refresh_render_info())
	quality_picker.item_selected.connect(func(_index): refresh_render_info())
	var pacing_note:=Label.new()
	preload("res://game/localization/localizer.gd").set_text(pacing_note,"90/120 FPS are targets. Enable high refresh in phone display settings. Profile default lowers resolution for smoothness; Native screen prioritizes detail.")
	pacing_note.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; pacing_note.custom_minimum_size.x=620
	body.add_child(pacing_note)
	for entry in [["sensitivity", "Camera sensitivity", 0.25, 3.0, 0.05], ["ui_scale", "Text size (100 / 125 / 150%)", 1.0, 1.5, 0.25], ["master", "Master volume", 0.0, 1.0, 0.05], ["effects", "Effects volume", 0.0, 1.0, 0.05], ["music", "Music volume", 0.0, 1.0, 0.05], ["ui_volume", "Menu volume", 0.0, 1.0, 0.05], ["voice_volume", "Voice volume", 0.0, 1.0, 0.05], ["incoming_damage", "Incoming damage (assist)", 0.25, 1.0, 0.25], ["enemy_tempo", "Enemy attack tempo (assist)", 0.6, 1.0, 0.1]]:
		var row := HBoxContainer.new()
		if mobile: row.custom_minimum_size.y = 56
		body.add_child(row)
		var label := Label.new()
		preload("res://game/localization/localizer.gd").set_text(label, entry[1])
		label.custom_minimum_size.x = 330
		if mobile:
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(label)
		var slider := HSlider.new()
		slider.min_value = entry[2]
		slider.max_value = entry[3]
		slider.step = entry[4]
		slider.value = settings.values[entry[0]]
		slider.custom_minimum_size.x = 180
		if mobile:
			slider.custom_minimum_size = Vector2(240,52)
			slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(slider)
		var number := Label.new()
		preload("res://game/localization/localizer.gd").set_text(number, "%.2f" % slider.value)
		row.add_child(number)
		slider.value_changed.connect(func(value): settings.set_value(entry[0], value); preload("res://game/localization/localizer.gd").set_text(number, "%.2f" % value); applied.emit())
	for entry in [["voice_enabled", "Spoken dialogue and narration"], ["menu_motion", "Animated menus"], ["invert_y", "Invert camera Y"], ["show_fps", "Show FPS"], ["fullscreen", "Fullscreen"]]:
		if mobile and entry[0] == "fullscreen": continue
		var toggle := CheckButton.new()
		preload("res://game/localization/localizer.gd").set_text(toggle, entry[1])
		toggle.button_pressed = settings.values[entry[0]]
		body.add_child(toggle)
		toggle.toggled.connect(func(value): settings.set_value(entry[0], value); applied.emit())
	if not mobile:
		action_picker = OptionButton.new()
		for action in settings.actions():
			preload("res://game/localization/localizer.gd").add_item(action_picker,action.replace("_", " ") + " · " + settings.hint(action))
		body.add_child(action_picker)
		var bind := Button.new()
		preload("res://game/localization/localizer.gd").set_text(bind, "Rebind selected action…")
		body.add_child(bind)
		bind.pressed.connect(func(): capturing = settings.actions()[action_picker.selected]; preload("res://game/localization/localizer.gd").set_text(feedback, "Press a key or mouse button. Escape cancels."))
	feedback = Label.new()
	preload("res://game/localization/localizer.gd").set_text(feedback, settings.notice)
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(feedback)
	var defaults := Button.new()
	preload("res://game/localization/localizer.gd").set_text(defaults, "Restore default settings and controls")
	body.add_child(defaults)
	defaults.pressed.connect(func(): settings.restore_defaults(); applied.emit(); rebuild())
	var close := Button.new()
	preload("res://game/localization/localizer.gd").set_text(close, "Save settings and back")
	body.add_child(close)
	close.pressed.connect(func(): settings.save_settings(); capturing = ""; hide(); closed.emit())
	var note := Label.new()
	preload("res://game/localization/localizer.gd").set_text(note, "Subtitles/text cues always on. Shake, flashes and motion blur are absent.\nGamepad is not supported in this build. Assist keeps progression/rewards identical.")
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.custom_minimum_size.x = 620
	body.add_child(note)

func refresh_render_info() -> void:
	var info:=body.get_node_or_null("RenderInfo") as Label
	if info==null: return
	var pixels:=Vector2i(get_viewport().get_texture().get_size())
	var profile: Dictionary=preload("res://game/presentation/graphics_profile.gd").resolve(settings.values.graphics_quality,preload("res://game/presentation/mobile_controls.gd").requested(),pixels,settings.values.render_resolution,settings.values.frame_limit)
	var dimensions:=Vector2i(Vector2(pixels)*profile.scale)
	preload("res://game/localization/localizer.gd").set_text(info,"3D: %d × %d · Target: %d FPS"%[dimensions.x,dimensions.y,settings.values.frame_limit])

func capture_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event is InputEventKey and event.physical_keycode == KEY_ESCAPE:
		capturing = ""
		preload("res://game/localization/localizer.gd").set_text(feedback, "Rebind cancelled")
		return
	var code: int = event.physical_keycode if event is InputEventKey else (-event.button_index if event is InputEventMouseButton else 0)
	if code == 0:
		return
	if settings.rebind(capturing, code):
		capturing = ""
		applied.emit()
		var selected := action_picker.selected
		rebuild()
		action_picker.select(selected)
	else:
		preload("res://game/localization/localizer.gd").set_text(feedback, settings.notice)
