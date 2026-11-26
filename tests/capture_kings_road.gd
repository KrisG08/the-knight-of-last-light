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
	game.player.enabled = false
	game.ui_layer.hide()
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 70
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	var views := [
		["road-camp",Vector3(1,2.3,77),Vector3(-5,2,44)],
		["road-watchtower",Vector3(3,2.3,26),Vector3(22,3,11)],
		["road-graves",Vector3(-8,2.4,-14),Vector3(-23,2,-22)],
		["road-chapel",Vector3(0,2.3,-45),Vector3(0,7,-89)]
	]
	for view in views:
		camera.position = view[1]
		camera.look_at(view[2])
		for frame in range(10):
			await process_frame
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png("res://.tools/review/"+view[0]+".png")
		if error!=OK:
			quit(1)
			return
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await process_frame
	quit(0)
