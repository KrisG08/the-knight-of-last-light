extends SceneTree
func _initialize() -> void:
	create_timer(35,true).timeout.connect(func(): push_error("Hold regression timed out"); quit(1))
	call_deferred("probe")
func probe() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	await process_frame
	game.benchmarking = true
	await game.start_selected()
	game.pause(false)
	for frame in range(4): await process_frame
	for command in ["attack","dodge","block","context"]:
		var touch := InputEventScreenTouch.new()
		touch.index = 40
		touch.position = game.mobile_controls.buttons[command]
		touch.pressed = true
		root.push_input(touch,true)
		await create_timer(0.85,true).timeout
		var interrupted: bool = paused or game.menu.visible
		touch.pressed = false
		root.push_input(touch,true)
		for frame in range(2): await process_frame
		interrupted = interrupted or paused or game.menu.visible
		if interrupted:
			print("FAIL: holding %s returns from gameplay to the full-screen menu" % command)
			game.queue_free()
			await process_frame
			quit(1)
			return
		print("Holding %s stays in gameplay: PASS" % command)
	game.queue_free()
	await process_frame
	quit()
