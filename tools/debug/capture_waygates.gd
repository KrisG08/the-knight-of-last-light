extends SceneTree
var output_directory: String
func _initialize() -> void:
	create_timer(220,true).timeout.connect(func(): push_error("Portal capture timeout"); quit(1))
	call_deferred("run")
func photo(tag: String) -> void:
	for frame in range(8): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(output_directory+"/portal-"+tag+".png")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	output_directory=args[1] if args.size()>1 else ProjectSettings.globalize_path("res://.tools/review")
	DirAccess.make_dir_recursive_absolute(output_directory)
	root.size=Vector2i(1600,900)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.session.begin(1,false)
	game.session.state=JSON.parse_string(FileAccess.get_file_as_string(args[0])) if args.size()>1 else load("res://tests/finale_checks.gd").citadel_state()
	game.started=true
	var camera:=Camera3D.new(); game.add_child(camera); camera.fov=62
	var routes=load("res://game/presentation/region_portals.gd").ROUTES
	for id in routes:
		if args.size()>2 and id not in args[2].split(","): continue
		if not await game.transition(id): quit(1); return
		game.pause(false); game.player.enabled=false; game.player.hide(); game.ui_layer.hide()
		for actor in game.enemies: actor.set_physics_process(false)
		var boss=game.current_encounter()
		if is_instance_valid(boss) and is_instance_valid(boss.actor): boss.actor.set_physics_process(false)
		var manager=game.region.get_node("RegionPortals")
		for key in manager.portals:
			var gate: Node3D=manager.portals[key]
			camera.current=true
			camera.position=gate.global_position+gate.basis*Vector3(0,gate.height*0.44,gate.height*1.55)
			camera.look_at(gate.global_position+Vector3.UP*gate.height*0.48)
			await photo(id.trim_prefix("region.")+"-"+key)
			if key=="forest":
				await create_timer(1.0,true).timeout
				await photo("village-forest-motion")
				gate.set_accessible(false); await photo("village-forest-locked")
				gate.set_accessible(true)
			print("Native portal view: ",id," / ",key)
	game.queue_free(); await process_frame; quit()
