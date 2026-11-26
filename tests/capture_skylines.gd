extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.benchmarking = true
	await game.start_selected()
	game.session.state = preload("res://tests/finale_checks.gd").citadel_state()
	preload("res://game/persistence/domain/journey_history.gd").ensure(game.session.state)
	game.ui_layer.hide()
	var camera := Camera3D.new(); camera.far=6500; camera.fov=70; game.add_child(camera)
	var regions: Array = ["peaks","citadel"] if "--quick" in OS.get_cmdline_user_args() else ["refuge","village","crypt","blackwood","grove","order","sanctum","peaks","forge","citadel","ritual"]
	for id in regions:
		var changed: bool = await game.transition("region."+id)
		if not changed or game.region.region_id!="region."+id:
			push_error("Skyline capture failed to enter "+id); quit(1); return
		game.pause(false); game.player.enabled=false; game.player.hide()
		for hostile in get_nodes_in_group("hostiles"): hostile.set_physics_process(false)
		camera.make_current()
		var at: Vector3 = game.region.points.spawn
		if id=="peaks": at = game.region.surface_point(Vector3(0,0,-20))
		if id=="citadel": at = game.region.surface_point(Vector3(0,0,-50))
		camera.position = at+Vector3(0,3,0)
		camera.look_at(camera.position+Vector3(-0.23,0.24,-0.9))
		for frame in range(8): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/sky-"+id+"-north.png")
		camera.look_at(camera.position+Vector3(0.8,-0.12,0.5))
		for frame in range(4): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/sky-"+id+"-edge.png")
	print("Native skyline/edge captures verified for %d regions" % regions.size())
	quit()
