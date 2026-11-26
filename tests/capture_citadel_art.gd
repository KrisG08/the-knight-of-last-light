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
	game.session.state = load("res://tests/finale_checks.gd").citadel_state()
	game.started = true
	await game.transition("region.citadel")
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
	for view in [["citadel-procession",Vector3(0,2,5),Vector3(0,4,-45)],["citadel-prison",Vector3(-16,2,-11),Vector3(-19,2,-21)],["citadel-ascent",Vector3(0,2,-43),Vector3(0,5,-57)]]:
		await shot(camera,view)
	await game.transition("region.ritual")
	game.pause(false)
	game.player.enabled = false
	game.player.hide()
	game.citadel_chapter.actor.set_physics_process(false)
	for view in [["ritual-hall",Vector3(0,2,8),Vector3(0,4,-9)],["ritual-artifact",Vector3(5,2,-5),Vector3(0,2,-9)]]:
		await shot(camera,view)
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await process_frame
	quit(0)

func shot(camera: Camera3D, view: Array) -> void:
	camera.position = view[1]
	camera.look_at(view[2])
	for frame in range(10): await process_frame
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png("res://.tools/review/"+view[0]+".png")!=OK:
		push_error("Could not save citadel capture")
		quit(1)
