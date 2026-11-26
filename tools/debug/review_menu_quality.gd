extends SceneTree
## Native fullscreen-sized comparison with the same menu and grading.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size=Vector2i(1920,1080)
	var output:=ProjectSettings.globalize_path("res://.tools/review/menu-hq-comparison")
	DirAccess.make_dir_recursive_absolute(output)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.set_language("bg")
	var scene=game.menu.living_scene
	var films:={"before-720p":scene.LEGACY_MOVIE_PATH,"desktop-qhd":scene.MOVIE_PATH,"phone-fullhd":scene.MOBILE_MOVIE_PATH}
	for label in films:
		game.settings.values.menu_motion=true
		scene.movie.stop(); scene.movie_ready=false
		scene.movie.stream=load(films[label]); scene.movie.play()
		for frame in range(180):
			await process_frame
			if scene.movie.stream_position>0.2 and scene.movie_ready: break
		if not scene.movie_ready: push_error("No decoded comparison frame: "+label); quit(1); return
		game.settings.values.menu_motion=false
		scene.clock=0.75
		for frame in range(8): await process_frame
		RenderingServer.force_draw(false)
		if root.get_texture().get_image().save_png(output+"/"+label+".png")!=OK:
			push_error("Comparison capture failed"); quit(1); return
		print(label," decoded texture ",scene.movie.get_video_texture().get_size())
	game.queue_free(); await process_frame
	quit()
