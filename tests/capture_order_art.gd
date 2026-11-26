extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.session.begin(1,false)
	game.session.state = load("res://tests/order_checks.gd").order_state()
	game.started = true
	await game.transition("region.order")
	game.pause(false)
	game.player.enabled = false
	game.player.hide()
	game.ui_layer.hide()
	for actor in game.enemies: actor.set_physics_process(false)
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 74
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	for view in [["order-art-barracks",Vector3(-19,2,2),Vector3(-19,3,-24)],["order-art-courtyard",Vector3(11,2,-8),Vector3(17,4,-30)],["order-art-memorial",Vector3(-19,2,-38),Vector3(-19,4,-47)],["order-art-sanctum",Vector3(0,2,-36),Vector3(0,5,-49)]]:
		camera.position = view[1]
		camera.look_at(view[2])
		for frame in range(10): await process_frame
		await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png("res://.tools/review/"+view[0]+".png")!=OK:
			quit(1)
			return
	await game.transition("region.sanctum")
	game.pause(false)
	game.player.enabled = false
	game.player.hide()
	game.commander.actor.set_physics_process(false)
	for view in [["order-art-hall",Vector3(0,2,9),Vector3(0,5,-8)],["order-art-oath",Vector3(3,2,-5),Vector3(0,2,-10)]]:
		camera.position = view[1]
		camera.look_at(view[2])
		for frame in range(10): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/"+view[0]+".png")
	await game.transition("region.crypt")
	game.pause(false)
	game.player.enabled = false
	game.player.hide()
	game.burial.actor.set_physics_process(false)
	camera.position = Vector3(0,2,7)
	camera.look_at(Vector3(0,4,-7))
	for frame in range(10): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/order-art-burial-regression.png")
	for actor in game.enemies: actor.sounds.stop()
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await process_frame
	quit(0)
