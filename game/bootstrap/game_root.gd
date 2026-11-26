extends Node

const Knight = preload("res://game/actors/player/knight.gd")
const Soldier = preload("res://game/actors/enemies/training_soldier.gd")
const Progression = preload("res://game/campaign/application/training_progression.gd")
const CHECKPOINT_POSITION = Vector3(2.5, 0, 7)
var player: CharacterBody3D
var enemy: CharacterBody3D
var menu: PanelContainer
var menu_title: Label
var start_button: Button
var hud: Label
var stamina_bar: ProgressBar
var health_bar: ProgressBar
var combat_hud: Label
var started: bool = false
var testing: bool = false
var progression: Node

func _ready() -> void:
	testing = testing or "--review" in OS.get_cmdline_user_args()
	get_window().title = "The Knight of Last Light - M3 Review" if testing else "The Knight of Last Light - Progression M3"
	get_tree().auto_accept_quit = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	configure_input()
	build_world()
	build_ui()
	set_menu(true)

func configure_input() -> void:
	var keys := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "sprint": KEY_SHIFT, "jump": KEY_F, "dodge": KEY_SPACE, "pause": KEY_ESCAPE, "reset": KEY_BACKSPACE, "heavy_attack": KEY_Q, "heal": KEY_R, "interact": KEY_E, "equipment": KEY_TAB}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(action, event)
	var mouse := {"light_attack": MOUSE_BUTTON_LEFT, "block": MOUSE_BUTTON_RIGHT, "target_lock": MOUSE_BUTTON_MIDDLE, "cycle_target": MOUSE_BUTTON_WHEEL_UP}
	for action in mouse:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		var event := InputEventMouseButton.new()
		event.button_index = mouse[action]
		InputMap.action_add_event(action, event)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_WHEEL_DOWN
	InputMap.action_add_event("cycle_target", down)

func block(at: Vector3, size: Vector3, color: Color, tilt: float = 0) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = at
	body.rotation.x = tilt
	body.collision_layer = 1
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	mesh.material_override = material
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body

func signpost(at: Vector3, words: String, text_scale: float = 1.0) -> Label3D:
	var label := Label3D.new()
	label.font = preload("res://game/presentation/ui_style.gd").font()
	preload("res://game/localization/localizer.gd").set_text(label, words)
	label.position = at
	label.font_size = 42
	label.pixel_size = 0.009
	label.scale = Vector3.ONE * text_scale
	label.modulate = Color("f0d7a0")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	return label

func build_world() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("172530")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("91abc0")
	settings.ambient_light_energy = 0.65
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = settings
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -35, 0)
	sun.light_color = Color("ffe1ad")
	sun.light_energy = 1.6
	sun.shadow_enabled = true
	add_child(sun)
	block(Vector3(0, -0.5, 0), Vector3(38, 1, 38), Color("39434a"))
	for x in [-19, 19]:
		block(Vector3(x, 1.3, 0), Vector3(1, 2.6, 38), Color("515962"))
	block(Vector3(0, 1.3, 19), Vector3(38, 2.6, 1), Color("515962"))
	# The northern ledge is intentionally open for the fall/reset route.
	for x in [-14, -7, 7, 14]:
		block(Vector3(x, 2, -9), Vector3(1.2, 4, 1.2), Color("626974"))
		block(Vector3(x, 4.1, -9), Vector3(1.8, 0.3, 1.8), Color("8c8676"))
	block(Vector3(-10, 0.8, 1), Vector3(5, 0.5, 7), Color("686b63"), -0.22)
	block(Vector3(-10, 1.55, -4.4), Vector3(5, 0.5, 4), Color("686b63"))
	for i in range(4):
		block(Vector3(8, 0.2 + i * 0.18, 4 - i * 1.8), Vector3(3, 0.4 + i * 0.36, 1.3), Color("706a60"))
	block(Vector3(1.5, 1.5, -5), Vector3(1, 3, 6), Color("515962"))
	block(Vector3(5, 1.5, -7.5), Vector3(6, 3, 1), Color("515962"))
	for x in [-3, 3]:
		block(Vector3(x, 2, -14), Vector3(1, 4, 1), Color("817e70"))
	block(Vector3(0, 4, -14), Vector3(7, 0.8, 1), Color("817e70"))
	signpost(Vector3(0, 5, -14), "OLD TRAINING COURTYARD\nCombat prototype")
	signpost(Vector3(-10, 3.5, -3), "SLOPE ROUTE")
	signpost(Vector3(8, 2.8, 1), "JUMP ROUTE · F")
	signpost(Vector3(0, 1.5, -18), "OPEN LEDGE · safe fall reset")
	player = Knight.new()
	add_child(player)
	player.reset_position()
	player.died.connect(on_player_died)
	player.reset_requested.connect(func(): enemy.reset_encounter())
	enemy = Soldier.new()
	enemy.player = player
	add_child(enemy)
	block(CHECKPOINT_POSITION + Vector3(0, 0.5, 0), Vector3(0.7, 1, 0.7), Color("ba9458"))
	var light := OmniLight3D.new()
	light.position = CHECKPOINT_POSITION + Vector3(0, 1.5, 0)
	light.light_color = Color("ffca77")
	light.light_energy = 3
	light.omni_range = 6
	add_child(light)
	signpost(CHECKPOINT_POSITION + Vector3(0, 2.3, 0), "LANTERN\nE · Rest", 0.35)

func build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Label.new()
	hud.position = Vector2(28, 22)
	preload("res://game/localization/localizer.gd").set_text(hud, "THE KNIGHT OF LAST LIGHT  /  M3\nGraybox progression · temporary geometry\n\nWASD Move   Mouse Look   Shift Sprint   F Jump\nLMB Attack   Q Heavy   RMB Block   Space Dodge\nR Heal   MMB Lock   E Interact   Tab Equipment   Esc Pause")
	hud.add_theme_color_override("font_color", Color("f0e5cf"))
	layer.add_child(hud)
	stamina_bar = ProgressBar.new()
	stamina_bar.position = Vector2(28, 225)
	stamina_bar.size = Vector2(240, 18)
	stamina_bar.show_percentage = false
	layer.add_child(stamina_bar)
	health_bar = ProgressBar.new()
	health_bar.position = Vector2(28, 200)
	health_bar.size = Vector2(240, 18)
	health_bar.show_percentage = false
	var hp_style := StyleBoxFlat.new()
	hp_style.bg_color = Color("a74949")
	health_bar.add_theme_stylebox_override("fill", hp_style)
	var stamina_style := StyleBoxFlat.new()
	stamina_style.bg_color = Color("74a17a")
	stamina_bar.add_theme_stylebox_override("fill", stamina_style)
	layer.add_child(health_bar)
	combat_hud = Label.new()
	combat_hud.position = Vector2(28, 255)
	combat_hud.add_theme_color_override("font_color", Color("f0e5cf"))
	layer.add_child(combat_hud)
	menu = PanelContainer.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	menu.position = Vector2(-250, -315)
	menu.custom_minimum_size = Vector2(500, 630)
	var panel_style := preload("res://game/presentation/ui_style.gd").button_panel()
	panel_style.set_content_margin_all(0)
	menu.add_theme_stylebox_override("panel", panel_style)
	layer.add_child(menu)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 28)
	menu.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	menu_title = Label.new()
	preload("res://game/localization/localizer.gd").set_text(menu_title, "THE KNIGHT\nOF LAST LIGHT")
	menu_title.add_theme_font_size_override("font_size", 24)
	column.add_child(menu_title)
	var description := Label.new()
	preload("res://game/localization/localizer.gd").set_text(description, "Training journey · three save slots\nReload resumes healthy at the lantern.")
	column.add_child(description)
	start_button = Button.new()
	preload("res://game/localization/localizer.gd").set_text(start_button, "Enter the courtyard")
	start_button.pressed.connect(start_or_retry)
	column.add_child(start_button)
	var reset := Button.new()
	preload("res://game/localization/localizer.gd").set_text(reset, "Restart training encounter")
	reset.pressed.connect(func(): reset_training(); set_menu(false))
	column.add_child(reset)
	var quit := Button.new()
	preload("res://game/localization/localizer.gd").set_text(quit, "Save and quit")
	quit.pressed.connect(func(): progression.save_and_quit())
	column.add_child(quit)
	var village := Button.new()
	preload("res://game/localization/localizer.gd").set_text(village, "Ashen Village campaign")
	village.pressed.connect(func():
		if progression.session.active and not progression.session.save_progress():
			return
		get_tree().paused = false
		get_tree().change_scene_to_file("res://game/world/runtime/village_game.tscn"))
	column.add_child(village)
	progression = Progression.new()
	add_child(progression)
	progression.setup(self, column, layer, testing)

func set_menu(open: bool) -> void:
	if is_instance_valid(progression) and is_instance_valid(progression.equipment):
		progression.equipment.hide()
	menu.visible = open
	hud.visible = not open
	health_bar.visible = not open
	stamina_bar.visible = not open
	combat_hud.visible = not open
	player.enabled = not open
	player.discard_mouse_events = 2
	player.input_grace_ticks = 2
	player.combat.clear_buffer()
	get_tree().paused = open
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if open else Input.MOUSE_MODE_CAPTURED
	if open:
		preload("res://game/localization/localizer.gd").set_text(menu_title, "YOU FELL\nReturn to the lantern" if player.health <= 0 else "THE KNIGHT\nOF LAST LIGHT")
		preload("res://game/localization/localizer.gd").set_text(start_button, "Return to checkpoint" if player.health <= 0 else ("Resume" if started else "Enter the courtyard"))
		start_button.disabled = false
		if not started and is_instance_valid(progression):
			var slot: int = progression.selected_slot()
			var has_save: bool = progression.session.store.exists(slot)
			preload("res://game/localization/localizer.gd").set_text(start_button, "Continue selected slot" if has_save else "Start selected slot")
			start_button.disabled = has_save and not progression.session.store.load_slot(slot).ok
		start_button.grab_focus()

func start_or_retry() -> void:
	if not progression.start_or_continue():
		return
	started = true
	if player.health <= 0:
		reset_training()
	set_menu(false)

func reset_training() -> void:
	player.reset_position()
	enemy.reset_encounter()
	player.combat.message = "Rested at the lantern. Encounter reset."
	player.sounds.cue("rest")
	if is_instance_valid(progression):
		progression.sync()

func on_player_died() -> void:
	set_menu(true)

func rest_at_checkpoint() -> bool:
	if player.health <= 0 or not player.combat.can_act() or player.dodge_left > 0:
		return false
	if player.position.distance_to(CHECKPOINT_POSITION) > 3:
		player.combat.message = "Return to the lantern to rest"
		return false
	if enemy.health > 0 and enemy.state != "idle":
		player.combat.message = "Cannot rest during combat"
		return false
	reset_training()
	if progression.session.active:
		progression.session.save_progress()
	return true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and started:
		if progression.equipment.visible:
			progression.close_equipment()
		elif player.health > 0:
			set_menu(not menu.visible)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("equipment") and started:
		if progression.equipment.visible:
			progression.close_equipment()
		else:
			progression.show_equipment()
		get_viewport().set_input_as_handled()
	elif not get_tree().paused and event.is_action_pressed("interact"):
		progression.interact()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(progression):
		progression.save_and_quit()
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(menu):
		set_menu(true)

func _process(_delta: float) -> void:
	if is_instance_valid(player) and is_instance_valid(stamina_bar):
		stamina_bar.value = player.stamina
		health_bar.value = player.health
		preload("res://game/localization/localizer.gd").set_text(combat_hud, "HP %d / %d   Stamina %d / 100\nHealing charges %d / 3   |   %s\n%s" % [player.health, player.max_health, player.stamina, player.healing_charges, player.combat.state.to_upper(), player.combat.message])
		if is_instance_valid(progression):
			var character: Dictionary = progression.session.state.character
			preload("res://game/localization/localizer.gd").append_text(combat_hud, "\nRank %d · XP %d · Shards %d · Sword +%d\n%s" % [character.rank, character.xp_into_rank, character.shards, character.weapon_tier, progression.session.notice])
		if is_instance_valid(player.target):
			preload("res://game/localization/localizer.gd").append_text(combat_hud, "\nLOCKED · Fallen Soldier · HP %d" % player.target.health)
		if is_instance_valid(progression):
			preload("res://game/localization/localizer.gd").append_text(combat_hud, "\n" + progression.interaction_prompt())
