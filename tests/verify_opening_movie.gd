extends SceneTree
var failed: bool = false
func photograph(path: String) -> void:
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png(path)!=OK:
		failed=true; push_error("Could not save movie review frame: "+path)
func _initialize() -> void:
	create_timer(preload("res://game/presentation/film_script.gd").LENGTH+40,true).timeout.connect(func(): push_error("Opening movie playback timed out"); quit(1))
	call_deferred("verify")
func verify() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	game.testing = false # Store/settings were already constructed as memory-only.
	game.start_selected()
	while not is_instance_valid(game.opening):
		await physics_frame
	var opening = game.opening
	var args:=OS.get_cmdline_user_args()
	var capture_dir: String=args[0] if not args.is_empty() and not args[0].begins_with("--") else ProjectSettings.globalize_path("user://movie-review")
	if DirAccess.make_dir_recursive_absolute(capture_dir)!=OK:
		push_error("Could not create movie review directory"); quit(1); return
	await create_timer(1,true).timeout
	await photograph(capture_dir+"/movie_playback_castle.png")
	await create_timer(2,true).timeout
	var first: Image = opening.video.get_video_texture().get_image()
	var first_hash: int = hash(first.get_data())
	var first_time: float = opening.video.stream_position
	await photograph(capture_dir+"/movie_playback_casting.png")
	await create_timer(1,true).timeout
	if first_hash==hash(opening.video.get_video_texture().get_image().get_data()):
		push_error("Opening lacks visible motion within the first shot")
		failed = true
	await create_timer(8,true).timeout
	var second: Image = opening.video.get_video_texture().get_image()
	if first_time<1 or opening.video.stream_position<10 or first_hash==hash(second.get_data()):
		push_error("Opening movie did not advance decoded frames and playback time")
		failed = true
	await photograph(capture_dir+"/movie_playback_march.png")
	await opening.finished
	await process_frame
	if is_instance_valid(game.opening) or game.player.position.distance_to(game.region.points.checkpoint)>3 or not game.session.store.memory_only:
		push_error("Film completion did not safely return to camp")
		failed = true
	print("MOVIE_PLAYBACK: ","FAIL" if failed else "PASS","; decoded moving frames, elapsed playback, automatic completion and memory-only camp handoff")
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await create_timer(0.2,true).timeout
	quit(1 if failed else 0)
