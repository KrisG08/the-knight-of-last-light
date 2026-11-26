extends SceneTree

func _initialize() -> void:
	create_timer(120,true).timeout.connect(func(): push_error("Chapter capture timeout"); quit(1))
	call_deferred("capture")

func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.benchmarking = true
	game.session.begin(1,false)
	game.session.state = load("res://tests/finale_checks.gd").citadel_state()
	game.started = true
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 72
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	var views := {
		"region.blackwood":[["blackwood-trail",Vector3(0,2,10),Vector3(8,3,-17)],["blackwood-tower",Vector3(13,2,-12),Vector3(21,5,-26)],["blackwood-shrine",Vector3(-12,2,-48),Vector3(-12,3,-59)]],
		"region.grove":[["grove",Vector3(0,2,8),Vector3(0,3,-9)]],
		"region.order":[["order-barracks",Vector3(-19,2,1),Vector3(-19,3,-25)],["order-court",Vector3(10,2,-7),Vector3(17,4,-32)]],
		"region.sanctum":[["sanctum",Vector3(0,2,8),Vector3(0,4,-10)]],
		"region.peaks":[["peaks-mine",Vector3(-16,2,-6),Vector3(-21,2,-17)],["peaks-forge",Vector3(0,2,-52),Vector3(0,5,-68)],["peaks-bridge",Vector3(0,2,-22),Vector3(0,1,-39)]],
		"region.forge":[["forge",Vector3(0,2,8),Vector3(0,4,-10)]],
		"region.citadel":[["citadel",Vector3(0,2,5),Vector3(0,7,-56)],["citadel-prison",Vector3(-15,2,-11),Vector3(-19,2,-23)]],
		"region.ritual":[["ritual",Vector3(0,2,8),Vector3(0,5,-9)],["ritual-ceiling",Vector3(0,2,5),Vector3(0,11,0)]]
	}
	for id in views:
		if not await game.transition(id):
			push_error("Chapter transition rejected: "+id)
			quit(1)
			return
		game.pause(false)
		game.player.enabled = false
		game.player.hide()
		game.ui_layer.hide()
		for actor in game.enemies: actor.set_physics_process(false)
		var boss = game.current_encounter()
		if is_instance_valid(boss) and is_instance_valid(boss.actor): boss.actor.set_physics_process(false)
		for view in views[id]:
			camera.position = view[1]
			camera.look_at(view[2])
			for frame in range(8): await process_frame
			await RenderingServer.frame_post_draw
			var path: String = "res://.tools/review/chapter-"+view[0]+".png"
			if root.get_texture().get_image().save_png(path)!=OK:
				push_error("Capture write failed: "+path)
				quit(1)
				return
			print("Rendered %s: %d draw calls, %d primitives" % [view[0],Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.queue_free()
	await process_frame
	quit(0)
