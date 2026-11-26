extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	await game.start_selected()
	await game.transition("region.crypt")
	game.pause(false)
	game.player.enabled = false
	game.player.hide()
	game.burial.actor.set_physics_process(false)
	game.ui_layer.hide()
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 74
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	for view in [["burial-vault",Vector3(0,2,7),Vector3(0,4,-7)],["burial-tombs",Vector3(4,2,3),Vector3(8.6,1.8,-3)],["burial-exit",Vector3(-2,2,-5),Vector3(0,3,9)]]:
		camera.position = view[1]
		camera.look_at(view[2])
		for frame in range(10):
			await process_frame
		await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png("res://.tools/review/"+view[0]+".png")!=OK:
			quit(1)
			return
	game.player.show()
	camera.current = false
	game.player.arm.get_child(0).current = true
	game.player.position = Vector3(0,0.1,5)
	game.player.pitch = -0.1
	game.ui_layer.show()
	for frame in range(10):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/burial-gameplay.png")
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await process_frame
	quit(0)
