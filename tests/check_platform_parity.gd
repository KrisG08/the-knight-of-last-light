extends SceneTree
func _initialize() -> void:
	create_timer(30,true).timeout.connect(func(): push_error("Platform parity timed out"); quit(1))
	call_deferred("run")
func run() -> void:
	var touch := preload("res://game/presentation/mobile_controls.gd").requested()
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	await process_frame
	game.benchmarking = true
	if not game.menu.has_method("show_actions") or is_instance_valid(game.mobile_controls) != touch:
		push_error("Shared frontend or platform-specific control selection failed")
		quit(1)
		return
	await game.start_selected()
	game.pause(true)
	game.player.health = 50
	game.player.healing_charges = 3
	await game.mobile_menu_action("heal")
	for tick in range(90): await physics_frame
	if game.player.health != 95 or game.player.healing_charges != 2 or not game.menu_input.pending.is_empty():
		push_error("Menu action parity failed: %s/%s" % [game.player.health,game.player.healing_charges])
		quit(1)
		return
	print(("Touch" if touch else "Laptop")+": shared v0.5 frontend, platform controls and one-flask menu action PASS")
	game.queue_free()
	await process_frame
	quit()
