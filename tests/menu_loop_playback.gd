extends SceneTree
## Native decoder check, including a real loop boundary and reduced motion.
var failures:=0
var assertions:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void:
	create_timer(45,true).timeout.connect(func(): push_error("Menu movie timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	var evidence_root: String=args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review")
	DirAccess.make_dir_recursive_absolute(evidence_root)
	root.size=Vector2i(1280,720)
	var scene=load("res://game/presentation/menu_living_scene.gd").new()
	root.add_child(scene); scene.setup()
	check(scene.movie!=null,"Actual menu video player created")
	if scene.movie==null: quit(1); return
	check(scene.movie.loop and scene.movie.expand,"Movie loops and resizes")
	var expected:=Vector2i(1920,1080) if scene.selected_movie==scene.MOBILE_MOVIE_PATH else Vector2i(2560,1440)
	var wrapped:=false
	var previous:=0.0
	var samples:=0
	var start:=Time.get_ticks_msec()
	while Time.get_ticks_msec()-start<14500:
		scene.advance(0.02,true)
		await process_frame
		var current: float=scene.movie.stream_position
		if current<previous-2.0: wrapped=true
		previous=current
		if current>0.5 and samples==0 or current>4.0 and samples==1:
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(evidence_root+"/loop-playback-%d.png"%samples)
			samples+=1
	check(wrapped,"Native decoder passed a real twelve-second loop boundary")
	check(samples==2,"Two moving native frames captured")
	check(scene.movie.get_video_texture().get_size()==Vector2(expected),"Native decoder exposes the expected high-resolution movie")
	check(not scene.landscape.visible and not scene.knight.visible,"Decoded movie replaces static fallback layers")
	scene.advance(0,false)
	await create_timer(0.12,true).timeout
	var frozen: float=scene.movie.stream_position
	await create_timer(0.25,true).timeout
	check(is_equal_approx(scene.movie.stream_position,frozen),"Reduced motion pauses decoded video")
	scene.advance(0.1,true)
	await create_timer(0.2,true).timeout
	check(scene.movie.stream_position>frozen,"Motion resumes from frozen video pose")
	scene.hide(); await process_frame
	check(scene.movie.paused,"Hidden menu suspends decoding")
	scene.show(); scene.advance(0.1,true)
	check(not scene.movie.paused,"Returning to menu resumes decoding")
	var cover_ratio: float=scene.movie.size.x/scene.movie.size.y
	root.size=Vector2i(1600,720)
	for frame in range(4): await process_frame
	check(is_equal_approx(scene.movie.size.x/scene.movie.size.y,cover_ratio),"Wide display preserves movie aspect")
	check(scene.movie.size.x>=scene.size.x and scene.movie.size.y>=scene.size.y,"Movie covers the complete menu")
	var cold=load("res://game/presentation/menu_living_scene.gd").new()
	root.add_child(cold); cold.setup()
	for frame in range(120):
		cold.advance(0,false); await process_frame
		if cold.movie_ready and cold.movie.paused: break
	check(cold.movie_ready and cold.movie.paused,"Cold reduced-motion start decodes and holds a real initial frame")
	check(cold.clock==0.0,"Initial frame bootstrap preserves the frozen artwork clock")
	cold.queue_free(); await process_frame
	scene.queue_free(); await process_frame
	print("Native looping menu movie: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
