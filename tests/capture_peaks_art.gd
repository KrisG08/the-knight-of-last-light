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
	game.session.state = load("res://tests/peaks_checks.gd").peaks_state()
	game.started = true
	await game.transition("region.peaks")
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
	for view in [["peaks-art-bridge",Vector3(0,2,-22),Vector3(0,1,-39)],["peaks-art-gorge",Vector3(9,3,-23),Vector3(0,-3,-30)],["peaks-art-mine",Vector3(-17,2,0),Vector3(-19,3,-14)],["peaks-art-fortress",Vector3(0,2,-54),Vector3(0,5,-68)]]:
		camera.position = view[1]
		camera.look_at(view[2])
		for frame in range(10): await process_frame
		await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png("res://.tools/review/"+view[0]+".png")!=OK:
			quit(1)
			return
	await game.transition("region.forge")
	game.pause(false)
	game.player.enabled = false
	game.player.hide()
	game.peaks_chapter.actor.set_physics_process(false)
	for view in [["peaks-art-forge",Vector3(0,2,8),Vector3(0,4,-8)],["peaks-art-furnace",Vector3(5,2,1),Vector3(11,2,-5)]]:
		camera.position = view[1]
		camera.look_at(view[2])
		for frame in range(10): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/"+view[0]+".png")
	for actor in game.enemies: actor.sounds.stop()
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await process_frame
	quit(0)
