extends SceneTree
## Native GPU review of the face and real menu, with isolated QA storage.
var output_directory: String
var game: Node
func _initialize() -> void:
	var args:=OS.get_cmdline_user_args()
	output_directory=args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review/living-moon")
	create_timer(70,true).timeout.connect(func(): push_error("Moon review timeout"); quit(1))
	call_deferred("run")
func settle() -> void:
	for frame in range(8): await process_frame
func photo(label: String) -> void:
	await settle(); RenderingServer.force_draw(false)
	var result:=root.get_texture().get_image().save_png(output_directory+"/"+label+".png")
	if result!=OK: push_error("Moon screenshot failed: "+str(result)); quit(1)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(output_directory)
	root.size=Vector2i(640,640)
	var face=load("res://game/presentation/menu_moonlight.gd").new()
	root.add_child(face); face.setup(); await settle()
	face.moon.position=Vector2(40,40); face.moon.size=Vector2(560,560)
	for pose in [0.0,2.0,5.0,8.0]:
		face.advance(pose); await photo("face-"+str(int(pose)))
	face.queue_free(); await process_frame
	root.size=Vector2i(1600,900)
	game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true
	game.settings.values.menu_motion=false
	await create_timer(0.7,true).timeout
	for dimensions in [Vector2i(1600,900),Vector2i(1600,720)]:
		root.size=dimensions; await settle()
		for pose in [0.0,5.0,10.0]:
			game.menu.living_scene.clock=pose
			await photo("menu-%dx%d-%d"%[dimensions.x,dimensions.y,int(pose)])
	game.queue_free(); await process_frame
	print("Living moon native closeups and desktop/wide menu captures complete")
	quit()
