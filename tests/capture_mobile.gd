extends SceneTree
func _initialize() -> void:
	create_timer(60, true).timeout.connect(func(): push_error("Mobile capture timed out"); quit(1))
	call_deferred("capture")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	await process_frame # Let _ready finish before suppressing focus pauses; do not start its benchmark.
	game.benchmarking = true
	await game.start_selected()
	game.pause(false)
	for frame in range(12):
		await process_frame
	var movement := InputEventScreenTouch.new()
	movement.index = 7
	movement.position = game.mobile_controls.pad + Vector2(0,-65)
	movement.pressed = true
	root.push_input(movement, true)
	for frame in range(3):
		await physics_frame
	if not Input.is_action_pressed("move_forward") or Input.is_action_pressed("light_attack"):
		push_error("Touch movement missing or emulated mouse triggered an attack")
		quit(1)
		return
	movement.pressed = false
	root.push_input(movement, true)
	for frame in range(2):
		await process_frame
	print("Real touch movement routes without a phantom mouse attack: PASS")
	for frame in range(8): await physics_frame
	var height_before: float = game.player.position.y
	var jump_touch := InputEventScreenTouch.new()
	jump_touch.index = 19
	jump_touch.position = game.mobile_controls.buttons.dodge
	jump_touch.pressed = true
	root.push_input(jump_touch,true)
	var jump_drag := InputEventScreenDrag.new()
	jump_drag.index = 19
	jump_drag.position = jump_touch.position+Vector2(0,-60)
	jump_drag.relative = Vector2(0,-60)
	root.push_input(jump_drag,true)
	jump_touch.pressed = false
	root.push_input(jump_touch,true)
	for frame in range(8): await physics_frame
	if game.player.position.y<height_before+0.2 or game.player.dodge_left>0:
		push_error("Touch jump gesture did not lift the real actor independently of dodge")
		quit(1)
		return
	print("Real touch upward swipe lifts player without dodge: PASS")
	for frame in range(50): await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/mobile-controls.png")
	var cancelled := InputEventScreenTouch.new()
	cancelled.index = 2
	cancelled.position = game.mobile_controls.pause_rect().get_center()
	cancelled.pressed = true
	root.push_input(cancelled,true)
	cancelled.pressed = false
	cancelled.canceled = true
	root.push_input(cancelled,true)
	for frame in range(2): await process_frame
	if paused:
		push_error("Cancelled pause touch opened menu")
		quit(1)
		return
	print("Cancelled HUD pause touch stays in gameplay: PASS")
	var tap := InputEventScreenTouch.new()
	tap.index = 3
	tap.position = game.mobile_controls.pause_rect().get_center()
	tap.pressed = true
	root.push_input(tap, true)
	tap.pressed = false
	root.push_input(tap, true)
	for frame in range(3):
		await process_frame
	if not paused or not game.menu.visible or not game.mobile_controls.held.is_empty():
		push_error("Touch Menu state: paused=%s visible=%s active=%s held=%s fingers=%s" % [paused, game.menu.visible, game.mobile_controls.active, game.mobile_controls.held, game.mobile_controls.fingers])
		quit(1)
		return
	print("Dedicated HUD pause tap opens pause and releases held inputs: PASS")
	for frame in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/mobile-menu.png")
	game.player.health = 50
	game.player.healing_charges = 3
	await game.mobile_menu_action("heal")
	for tick in range(90):
		await physics_frame
	if game.player.health < 94 or game.player.healing_charges != 2 or Input.is_action_pressed("heal"):
		push_error("Secondary menu heal: health=%s charges=%s state=%s elapsed=%s grace=%s enabled=%s paused=%s held=%s pulses=%s" % [game.player.health, game.player.healing_charges, game.player.combat.state, game.player.combat.elapsed, game.player.input_grace_ticks, game.player.enabled, paused, Input.is_action_pressed("heal"), game.mobile_controls.pulses])
		quit(1)
		return
	print("Secondary menu action resumes, heals once and releases its input: PASS")
	game.queue_free()
	await process_frame
	quit()
