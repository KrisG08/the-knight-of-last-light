extends SceneTree
## Actual decode, localized speech and scene-to-camp handoff; isolated journey state.
const Film=preload("res://game/presentation/film_script.gd")
const L=preload("res://game/localization/localizer.gd")
var failures:=0
var assertions:=0
func check(value: bool, message: String) -> void:
	assertions+=1
	if not value: failures+=1; push_error(message)
func _initialize() -> void:
	create_timer(Film.LENGTH+55,true).timeout.connect(func(): push_error("Prologue acceptance timed out"); quit(1))
	run.call_deferred()
func run() -> void:
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.settings.set_value("language","bg"); game.apply_settings()
	game.testing=false # Persistence/settings were already constructed memory-only.
	var original_step_budget:=Engine.max_physics_steps_per_frame
	game.start_selected()
	while not is_instance_valid(game.opening): await process_frame
	var opening=game.opening
	var seen: Array[int]=[]
	var moving: Array[int]=[]
	var frame_hashes: Dictionary={}
	var captures: Dictionary={}
	var last_position:=0.0
	var playback_start:=Time.get_ticks_usec()
	var frames: Array[float]=[]
	var last:=Time.get_ticks_usec()
	var revision:=str(ProjectSettings.get_setting("application/config/version")).replace(".","")
	var directory:="res://.tools/review/prologue-v"+revision+"-playback"
	if preload("res://game/presentation/mobile_controls.gd").requested(): directory+="-touch"
	DirAccess.make_dir_recursive_absolute(directory)
	while is_instance_valid(opening) and not opening.done:
		await process_frame
		var now:=Time.get_ticks_usec(); frames.append((now-last)/1000.0); last=now
		if not is_instance_valid(opening): break
		last_position=opening.video.stream_position
		var shot: int=opening.spoken_shot
		if shot>=0 and shot in seen and shot not in moving and opening.video.stream_position-Film.STARTS[shot]>2.4:
			var decoded_hash: int=hash(opening.video.get_video_texture().get_image().get_data())
			check(decoded_hash!=frame_hashes[shot],"Decoded frames actually move within beat "+str(shot))
			moving.append(shot)
			print("PROLOGUE_MOTION ",shot," at ",last_position)
		if shot<0 or shot in seen or opening.video.stream_position-Film.STARTS[shot]<1.2: continue
		seen.append(shot)
		print("PROLOGUE_BEAT ",shot," at ",last_position)
		frame_hashes[shot]=hash(opening.video.get_video_texture().get_image().get_data())
		check(opening.caption_label.text==L.text(Film.CAPTIONS[shot]),"Localized native caption for beat "+str(shot))
		check(game.voice.current_key.contains("/bg/") and game.voice.player.playing,"Actual Bulgarian voice playback for beat "+str(shot))
		check(opening.score.playing,"Independent musical score plays in beat "+str(shot))
		check(opening.caption_label.get_minimum_size().y<=opening.caption_mask.size.y,"Caption fits its film strip for beat "+str(shot))
		await RenderingServer.frame_post_draw
		captures[shot]=root.get_texture().get_image()
	await process_frame
	var elapsed: float=(Time.get_ticks_usec()-playback_start)/1000000.0
	check(seen.size()==Film.CAPTIONS.size(),"Every authored film beat played, without skipping")
	check(moving.size()==Film.CAPTIONS.size(),"Every beat contains decoded moving frames")
	check(last_position>=Film.LENGTH-.7,"Native movie reaches its final second")
	check(elapsed>=Film.LENGTH-1 and elapsed<Film.LENGTH+3,"Native movie preserves its real-time pace")
	check(game.session.store.memory_only and not is_instance_valid(game.opening),"Natural completion restores the isolated journey")
	check(game.player.visible and game.region.visible and game.player.position.distance_to(game.region.points.checkpoint)<3,"Film finishes at the safe camp")
	check(Engine.max_physics_steps_per_frame==original_step_budget,"Natural completion restores gameplay clock settings")
	# Disk encoding/writes must not block the playback observation loop.
	for shot in captures: captures[shot].save_jpg(directory+"/beat-"+str(shot)+".jpg",.92)
	# The same opening can be dismissed immediately in every supported locale.
	for language in L.LANGUAGES:
		L.set_locale(language)
		var film=preload("res://game/ui/opening_cinematic.gd").new()
		film.voice=game.voice; game.add_child(film)
		await create_timer(.18,true).timeout
		check(film.caption_label.text==L.text(Film.CAPTIONS[0]),"First caption locale "+language)
		check(game.voice.current_key.contains("/"+language+"/"),"Speech locale "+language)
		film.complete(); film.complete()
		check(not game.voice.player.playing,"Skip cancels speech immediately "+language)
		check(not film.score.playing,"Skip cancels musical score immediately "+language)
		await process_frame
		check(Engine.max_physics_steps_per_frame==original_step_budget,"Skip restores gameplay clock settings "+language)
	frames.sort()
	print("Prologue native playback: ",assertions," assertions; ","PASS" if failures==0 else "FAIL", "; beats=",seen,"; moving=",moving,"; last_position=",last_position,"; elapsed=",elapsed,"; median/p95 ms=",frames[frames.size()/2],"/",frames[int(frames.size()*.95)],"; physical phone untested")
	game.queue_free(); await process_frame; quit(0 if failures==0 else 1)
