extends Control
## Bottom conversation framing with an isolated portrait of the actual NPC model.
var game: Node
var speaker := ""
var portrait: PanelContainer
var viewport: SubViewport
var model: Node3D
var camera: Camera3D
var spoken_source := ""
var spoken_language := ""

func setup(owner_game: Node) -> void:
	game = owner_game
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	portrait = PanelContainer.new()
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_theme_stylebox_override("panel", preload("res://game/presentation/ui_style.gd").frame(Color("15131fe8"), Color("b46bdf"), 4))
	add_child(portrait)
	var container := TextureRect.new()
	container.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	container.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.add_child(container)
	viewport = SubViewport.new()
	viewport.size = Vector2i(512, 640)
	viewport.msaa_3d = Viewport.MSAA_4X
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	container.texture = viewport.get_texture()
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("171321")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("bdc5df")
	environment.environment.ambient_light_energy = 0.7
	viewport.add_child(environment)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-25, -35, 0)
	key.light_color = Color("ffe1b4")
	key.light_energy = 1.6
	viewport.add_child(key)
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees = Vector3(-15, 150, 0)
	rim.light_color = Color("bc8aef")
	rim.light_energy = 0.4
	viewport.add_child(rim)
	camera = Camera3D.new()
	viewport.add_child(camera)
	camera.position = Vector3(0.12, 1.65, -2.7)
	camera.look_at_from_position(camera.position, Vector3(0, 1.57, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 1.05
	portrait.hide()
	resized.connect(arrange)
	game.dialogue.visibility_changed.connect(func():
		if not game.dialogue.visible:
			game.voice.stop_for(self); spoken_source = ""
		portrait.visible = game.dialogue.visible and not speaker.is_empty()
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if portrait.visible else SubViewport.UPDATE_DISABLED)

func present(text: String) -> void:
	var heading := text.get_slice("\n", 0).to_upper()
	var next := ""
	if heading.begins_with("OREN"): next = "oren"
	elif heading.begins_with("LYRA"): next = "lyra"
	elif heading.begins_with("SIR CAEL"): next = "cael"
	if next != speaker:
		if is_instance_valid(model):
			viewport.remove_child(model)
			model.queue_free()
			model = null
		if not next.is_empty():
			model = Node3D.new()
			viewport.add_child(model)
			var weapon := Node3D.new()
			model.add_child(weapon)
			preload("res://game/presentation/friendly_models.gd").build(model, next, weapon)
			model.rotation.y = -0.12
	speaker = next
	var compact_choices := not speaker.is_empty()
	if compact_choices != (game.choices is HFlowContainer):
		var parent: Node = game.choices.get_parent()
		var previous: Container = game.choices
		parent.remove_child(previous)
		previous.queue_free()
		game.choices = HFlowContainer.new() if compact_choices else VBoxContainer.new()
		game.choices.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		game.choices.add_theme_constant_override("h_separation", 12)
		game.choices.add_theme_constant_override("v_separation", 8)
		parent.add_child(game.choices)
	portrait.visible = not speaker.is_empty() and game.dialogue.visible
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if portrait.visible else SubViewport.UPDATE_DISABLED
	if speaker.is_empty():
		game.refresh_mobile_layout()
	arrange()

func arrange() -> void:
	if not is_instance_valid(game.dialogue): return
	var extent := get_viewport_rect().size
	var safe: Vector4 = preload("res://game/presentation/mobile_display.gd").safe_margins(extent)
	if speaker.is_empty():
		var panel := game.dialogue as PanelContainer
		var available := extent - Vector2(safe.x + safe.z + 32, safe.y + safe.w + 32)
		var dimensions := Vector2(minf(800, available.x), minf(620, available.y))
		panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		panel.custom_minimum_size = Vector2.ZERO
		game.dialogue_text.custom_minimum_size.x = maxf(160, dimensions.x - 72)
		panel.size = dimensions
		panel.position = Vector2(safe.x + 16, safe.y + 16) + (available - dimensions) / 2
		return
	var width := minf(1100, extent.x - safe.x - safe.z - 32)
	var height := minf(350, extent.y * 0.43)
	var panel := game.dialogue as PanelContainer
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	panel.custom_minimum_size = Vector2.ZERO
	game.dialogue_text.custom_minimum_size.x = maxf(180, width - 72)
	panel.size = Vector2(width, height)
	panel.position = Vector2((extent.x - width) / 2, extent.y - safe.w - height - 16)
	var portrait_height := minf(220, panel.position.y - safe.y - 20)
	portrait.size = Vector2(portrait_height * 0.82, portrait_height)
	portrait.position = Vector2(panel.position.x + 12, panel.position.y - portrait_height - 8)

func _process(_delta: float) -> void:
	if not game.dialogue.visible: return
	arrange()
	var source: String = preload("res://game/localization/localizer.gd").source(game.dialogue_text)
	var language: String = preload("res://game/localization/localizer.gd").language
	if source != spoken_source or language != spoken_language:
		spoken_source = source; spoken_language = language
		game.voice.dialogue(source,self)

func _exit_tree() -> void:
	if is_instance_valid(game) and is_instance_valid(game.voice): game.voice.stop_for(self)
