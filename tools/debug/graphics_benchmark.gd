extends SceneTree
## Opt-in fixture workload: never loads owner saves, signs in or changes system power.
var game: Node
var collecting:=false
var phase:=""
var samples: Dictionary={}
var transitions: Dictionary={}
var settings_seen: Dictionary={}
var last_usec:=0
var peaks:={"draw_calls":0.0,"video_bytes":0.0,"physics_ms":0.0,"navigation_ms":0.0}
var center:=Vector3.ZERO
var started_usec:=0
var output: String
var quality: String
var frame_cap:=0
var sample_seconds:=12.0
var attack_elapsed:=0.0
func _initialize() -> void:
	print("PROFILE initialize pid=",OS.get_process_id())
	create_timer(240,true).timeout.connect(func(): push_error("Graphics workload timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	output=args[1]; quality=args[2]
	if args.size()>3 and args[3].is_valid_int(): frame_cap=int(args[3])
	if args.size()>4 and args[4].is_valid_float(): sample_seconds=clampf(float(args[4]),5,12)
	root.size=Vector2i(1920,1080)
	var boot:=Time.get_ticks_usec()
	print("PROFILE load scene")
	var scene=load("res://game/world/runtime/village_game.tscn")
	print("PROFILE scene loaded ms=",float(Time.get_ticks_usec()-boot)/1000)
	game=scene.instantiate()
	print("PROFILE add scene")
	game.testing=true; root.add_child(game)
	print("PROFILE scene added ms=",float(Time.get_ticks_usec()-boot)/1000)
	while game.transitioning: await process_frame
	var boot_ms:=float(Time.get_ticks_usec()-boot)/1000
	game.benchmarking=true; game.session.begin(1,false)
	game.session.state=JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	game.started=true
	if game.settings.values.has("graphics_quality"): game.settings.set_value("graphics_quality",quality)
	game.apply_settings()
	print("GRAPHICS WORKLOAD PID: ",OS.get_process_id()," quality: ",quality)
	started_usec=Time.get_ticks_usec()
	for entry in [["region.refuge",Vector3(0,0,58)],["region.village",Vector3(20,0,23)],["region.blackwood",Vector3(0,0,-36)],["region.order",Vector3(0,0,-12)],["region.peaks",Vector3(0,0,-38)],["region.citadel",Vector3(0,0,43)],["region.ritual",Vector3(0,0,1)]]:
		if args.size()>5 and entry[0] not in args[5].split(","): continue
		collecting=false
		for action in ["move_left","move_right","move_forward","move_back"]: Input.action_release(action)
		var start:=Time.get_ticks_usec()
		if not await game.transition(entry[0]): push_error("Benchmark transition rejected"); quit(1); return
		transitions[entry[0]]=float(Time.get_ticks_usec()-start)/1000
		print("PROFILE stage ",entry[0]," transition_ms=",transitions[entry[0]])
		center=game.region.surface_point(entry[1])+Vector3.UP*0.1
		game.player.position=center; game.player.reset_physics_interpolation()
		game.player.velocity=Vector3.ZERO; game.player.visual.rotation.y=0
		game.player.yaw=0; game.player.pitch=-0.18
		game.pause(false)
		# Measure available headroom, not the normal user's configured frame cap.
		Engine.max_fps=frame_cap
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED if frame_cap==0 else DisplayServer.VSYNC_ENABLED)
		if entry[0]=="region.ritual":
			game.citadel_chapter.actor.start()
			game.citadel_chapter.actor.receive_hit(game.player.global_position,430,1,0)
		await create_timer(2.0,true).timeout
		phase=entry[0]; samples[phase]=[]
		settings_seen[phase]={"scale":root.scaling_3d_scale,"msaa":root.msaa_3d,"anisotropy":root.anisotropic_filtering_level,"lod":root.mesh_lod_threshold,"sun_shadows":game.sun.shadow_enabled,"shadow_distance":game.sun.directional_shadow_max_distance,"viewport":str(root.get_visible_rect().size),"window":str(DisplayServer.window_get_size()),"texture":str(root.get_texture().get_size()),"3d_pixels_estimate":str(Vector2(root.get_texture().get_size())*root.scaling_3d_scale)}
		settings_seen[phase].camera_distance_m=root.get_camera_3d().global_position.distance_to(game.player.global_position+Vector3.UP*1.45)
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png(output.get_basename()+"-"+phase.trim_prefix("region.")+".png")
		# Keep synchronous screenshot readback out of gameplay frame samples.
		await create_timer(0.5,true).timeout
		last_usec=Time.get_ticks_usec(); collecting=true
		await create_timer(sample_seconds,true).timeout
		collecting=false
		print("PROFILE sampled ",entry[0]," ",JSON.stringify(summary(samples[phase])))
	for action in ["move_left","move_right","move_forward","move_back"]: Input.action_release(action)
	var summaries: Dictionary={}
	for key in samples: summaries[key]=summary(samples[key])
	var report:={"engine":Engine.get_version_info().string,"version":ProjectSettings.get_setting("application/config/version"),"exported":not OS.has_feature("editor"),"gpu":RenderingServer.get_video_adapter_name(),"cpu":OS.get_processor_name(),"quality":quality,"frame_cap":frame_cap,"vsync":frame_cap>0,"sample_seconds_per_stage":sample_seconds,"process_id":OS.get_process_id(),"boot_ms":boot_ms,"elapsed_s":float(Time.get_ticks_usec()-started_usec)/1000000,"transitions_ms":transitions,"stages":summaries,"rendering":settings_seen,"peaks":peaks,"conditions":"One native benchmark instance; 2 s warmup, screenshot then 0.5 s recovery before timed samples. Authored fixture, restored HP, light attacks, forced wizard phase; other desktop load not controlled. Power scheme and process memory recorded separately. Not a human playthrough or phone benchmark."}
	var file:=FileAccess.open(output,FileAccess.WRITE); file.store_string(JSON.stringify(report,"\t")); file.close()
	print("GRAPHICS WORKLOAD COMPLETE: ",JSON.stringify(summaries))
	game.player.sounds.stop(); game.ui_sound.stop(); game.queue_free()
	await process_frame; quit()
func _process(_delta: float) -> bool:
	if not collecting: return false
	var now:=Time.get_ticks_usec(); samples[phase].append(float(now-last_usec)/1000); last_usec=now
	peaks.draw_calls=maxf(peaks.draw_calls,Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	peaks.video_bytes=maxf(peaks.video_bytes,Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	peaks.physics_ms=maxf(peaks.physics_ms,Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)*1000)
	peaks.navigation_ms=maxf(peaks.navigation_ms,Performance.get_monitor(Performance.TIME_NAVIGATION_PROCESS)*1000)
	return false
func _physics_process(_delta: float) -> bool:
	if not collecting or game.transitioning: return false
	game.player.health=game.player.max_health
	attack_elapsed+=_delta
	if phase in ["region.village","region.ritual"] and attack_elapsed>1.3:
		game.player.combat.request_action("light_attack"); attack_elapsed=0
	if phase=="region.ritual" and game.citadel_chapter.actor.health<100:
		game.citadel_chapter.actor.health=340
	var clock:=float(Time.get_ticks_usec()-started_usec)/1000000
	var target:=center+Vector3(sin(clock*0.7)*1.8,0,cos(clock*0.7)*1.8)
	var offset: Vector3=(target-game.player.position).limit_length(1)
	for entry in [["move_right",maxf(offset.x,0)],["move_left",maxf(-offset.x,0)],["move_back",maxf(offset.z,0)],["move_forward",maxf(-offset.z,0)]]:
		if entry[1]>0.1: Input.action_press(entry[0],entry[1])
		else: Input.action_release(entry[0])
	return false
func summary(values: Array) -> Dictionary:
	var ordered:=values.duplicate(); ordered.sort()
	var total:=0.0; var slow:=0
	for value in values:
		total+=value
		if value>33.34: slow+=1
	return {"frames":values.size(),"mean_fps":1000*values.size()/maxf(1,total),"p50_ms":ordered[int((ordered.size()-1)*0.5)],"p95_ms":ordered[int((ordered.size()-1)*0.95)],"p99_ms":ordered[int((ordered.size()-1)*0.99)],"worst_ms":ordered.back(),"frames_over_33ms":slow}
