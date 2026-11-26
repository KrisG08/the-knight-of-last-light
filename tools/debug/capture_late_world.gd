extends SceneTree
## Authored review cameras, not a human campaign or an exported-phone benchmark.
func _initialize() -> void:
	create_timer(180,true).timeout.connect(func(): push_error("Late world capture timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	root.size=Vector2i(1600,900)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.session.begin(1,false)
	game.session.state=load("res://tests/finale_checks.gd").citadel_state()
	game.started=true
	var camera:=Camera3D.new(); camera.fov=72; game.add_child(camera)
	var shots:={
		"region.blackwood":[Vector3(20,2,1),Vector3(-22,12,-41)],
		"region.grove":[Vector3(0,3,10),Vector3(0,8,-12)],
		"region.order":[Vector3(0,2,8),Vector3(-7,16,-48)],
		"region.sanctum":[Vector3(0,2,8),Vector3(0,8,-11)],
		"region.peaks":[Vector3(0,2,-35),Vector3(0,21,-85)],
		"region.forge":[Vector3(0,2,8),Vector3(0,5,-9)],
		"region.citadel":[Vector3(0,2,52),Vector3(0,36,-77)],
		"region.ritual":[Vector3(0,2,9),Vector3(0,14,-10)]}
	for id in shots:
		if not await game.transition(id): quit(1); return
		game.pause(false); game.player.enabled=false; game.player.hide(); game.ui_layer.hide()
		for actor in game.enemies: actor.set_physics_process(false)
		var boss=game.current_encounter()
		if is_instance_valid(boss) and is_instance_valid(boss.actor): boss.actor.set_physics_process(false)
		camera.current=true
		camera.position=game.region.surface_point(shots[id][0])
		camera.look_at(game.region.surface_point(shots[id][1]))
		for frame in range(12): await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://.tools/review/late-world-"+id.trim_prefix("region.")+".png")
		print("Native late world view: ",id)
		if id=="region.citadel":
			camera.position=game.region.surface_point(Vector3(20,4,-36))
			camera.look_at(game.region.surface_point(Vector3(0,24,-77)))
			for frame in range(12): await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png("res://.tools/review/late-world-citadel-upper.png")
	game.queue_free(); await process_frame; quit()
