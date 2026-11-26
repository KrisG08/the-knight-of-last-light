extends SceneTree
## Native visual fixture plus actual automatic completion; never loads owner saves.
var assertions:=0
var failures:=0
func check(ok: bool, description: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(description)
func _initialize() -> void:
	create_timer(70,true).timeout.connect(func(): push_error("Victory preview timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	var output: String=args[1] if args.size()>1 else ProjectSettings.globalize_path("res://.tools/review/wizard-defeat")
	root.size=Vector2i(1280,720)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.session.begin(1,false)
	if args.size()>1:
		game.session.state=JSON.parse_string(FileAccess.get_file_as_string(args[0]))
	else:
		game.session.state=load("res://tests/finale_checks.gd").citadel_state()
		var fixture:=FileAccess.open("res://.tools/wizard-defeat-fixture.json",FileAccess.WRITE)
		fixture.store_string(JSON.stringify(game.session.state)); fixture.close()
	var expected_version: String=args[2] if args.size()>2 else "0.5.35"
	check(ProjectSettings.get_setting("application/config/version")==expected_version,"Expected cinematic release version is loaded")
	var localizer=load("res://game/localization/localizer.gd")
	var language_before: String=localizer.language
	for language in ["bg","ru","fr","ar"]:
		localizer.set_locale(language)
		for text in ["Maldrek has fallen. The curse still clings to the artifact.","Shatter the central artifact to end the curse"]:
			check(localizer.text(text)!=text,"Victory caption translated: "+language)
	localizer.set_locale(language_before)
	game.started=true; game.benchmarking=true
	await game.transition("region.ritual"); game.pause(false)
	var boss=game.citadel_chapter.actor
	game.player.global_position=boss.global_position+Vector3(0,0,1.8)
	var strike_origin: Vector3=game.player.global_position
	boss.start()
	game.player.input_grace_ticks=0; game.player.weapon_damage=10000
	game.player.combat.state="attack"; game.player.combat.heavy=false
	game.player.combat.elapsed=0.19; game.player.combat.attack_yaw=0
	game.player.combat.ledger=load("res://game/combat/domain/attack_sweep.gd").new()
	game.player._physics_process(0.12)
	var film=game.opening
	check(film!=null,"Actual knight attack sweep delivers the cinematic's lethal hit")
	if film==null: game.queue_free(); quit(1); return
	var speech_text=preload("res://game/audio/speech_text.gd")
	var film_script=preload("res://game/presentation/film_script.gd")
	check(game.voice.current_key.ends_with(speech_text.key(film_script.VICTORY[0],"narrator")+".ogg"),"Victory begins with the selected-language first spoken caption")
	check(game.player.global_position==strike_origin,"Lethal-hit cinematic cancels remaining movement in the same physics tick")
	film.set_process(false)
	check(paused and film!=null,"Actual lethal hit starts victory choreography")
	var before_hp: float=game.player.health
	var before_artifact: Vector3=game.region.seal.global_position
	var before_hero: Vector3=game.player.global_position
	var camera_start: Vector3=film.camera.global_position
	DirAccess.make_dir_recursive_absolute(output)
	for pose in [1.0,4.0,7.0,10.0]:
		film.advance(pose)
		for frame in range(4): await process_frame
		if not DisplayServer.get_name()=="headless":
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(output+"/scene-%02d.png"%int(pose))
	check(film.camera.global_position.distance_to(camera_start)>1,"Directed camera changes shot distance and angle")
	check(game.voice.current_key.ends_with(speech_text.key(film_script.VICTORY[1],"narrator")+".ogg"),"Artifact camera cue starts the second spoken caption")
	check(game.player.health==before_hp and game.player.global_position==before_hero,"Choreography does not move physics capsule or change health")
	check(game.region.seal.visible and game.region.seal.global_position==before_artifact and not game.session.state.campaign.completed,"Wizard scene preserves artifact and explicit ending choice")
	check(film.sparks.size()==54 and film.stage.find_children("*","CollisionObject3D",true,false).is_empty(),"Bounded decorative magic has no damage or collision")
	var completions: Array[int]=[0]
	film.finished.connect(func(): completions[0]+=1)
	film.advance(film.DURATION-.1); film.set_process(true)
	await create_timer(0.35,true).timeout
	check(completions[0]==1 and game.opening==null and not paused and game.player.enabled,"Timeline automatically completes once and restores controls")
	check(not game.voice.player.playing and game.voice.pending.is_empty(),"Finishing victory cancels its narration")
	check(root.get_camera_3d()!=film.camera if is_instance_valid(film) else root.get_camera_3d()!=null,"Gameplay camera restored after automatic completion")
	check(not game.session.state.campaign.completed and "boss.maldrek" in game.session.state.campaign.boss_defeated_ids,"Automatic finish preserves saved victory without granting campaign completion")
	game.player.sounds.stop(); game.ui_sound.stop(); game.queue_free()
	await process_frame
	print("Wizard defeat choreography: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL"))
	quit(0 if failures==0 else 1)
