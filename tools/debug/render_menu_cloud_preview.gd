extends SceneTree
## Native moving menu evidence, not an edited still or player journey.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	var output: String=args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review/foreground-clouds-film")
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(1280,720)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.set_language("bg")
	game.settings.values.menu_motion=true
	for frame in range(20): await process_frame
	game.menu.living_scene.clock=0.0
	for frame in range(192):
		await process_frame; RenderingServer.force_draw(false)
		var result:=root.get_texture().get_image().save_jpg(output+"/%04d.jpg"%frame,0.90)
		if result!=OK: push_error("Cloud preview write failed"); quit(1); return
		if frame%64==0: print("Foreground cloud preview frame ",frame)
	game.queue_free(); await process_frame
	print("Actual menu movie and foreground clouds: 192 native frames")
	quit()
