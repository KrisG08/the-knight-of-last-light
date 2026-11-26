extends SceneTree
const Progress = preload("res://game/campaign/domain/tutorial_progress.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
var failures := 0
var assertions := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	root.size = Vector2i(1280,600)
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking = true; game.session.begin(1,false); game.started = true; game.pause(false)
	game.player.set_physics_process(false)
	var coach = game.coach
	coach._process(0.01)
	check(coach.visible and coach.active_lesson == "move","Fresh journey starts contextual movement lesson")
	game.player.position += Vector3(0,0,4); game.player.velocity = Vector3(0,0,2)
	coach._process(0.01)
	check("move" in game.session.state.journey.tutorial_completed_ids,"Actual movement completes lesson")
	game.player.apply_look(Vector2(12,0))
	check("look" in game.session.state.journey.tutorial_completed_ids,"Actual camera input completes look lesson")
	game.player.combat.state = "attack"; game.player.combat.heavy = true
	coach._process(0.01)
	check("heavy" in game.session.state.journey.tutorial_completed_ids,"Real combat state completes heavy lesson")
	check(game.session.save_progress(),"Tutorial progress saves")
	check(game.session.store.load_slot(1).state.journey.tutorial_completed_ids.has("heavy"),"Tutorial progress persists")
	check(Schema.validate(game.session.state).is_empty(),"Tutorial snapshot validates")
	var disk = preload("res://game/persistence/infrastructure/save_store.gd").new("user://tutorial-roundtrip-"+str(Time.get_ticks_usec()))
	check(disk.save(game.session.state).ok and disk.load_slot(1).state.journey.tutorial_completed_ids.has("heavy"),"Tutorial progress survives JSON disk round-trip")
	check(not Progress.valid(["move","move"]) and not Progress.valid(["unknown"]),"Invalid tutorial IDs rejected")
	var invalid: Dictionary = game.session.state.duplicate(true)
	invalid.journey.tutorial_completed_ids = ["unknown"]
	check(not Schema.validate(invalid).is_empty(),"Invalid persisted tutorial state rejected")
	game.pause(true); check(not coach.is_visible_in_tree(),"Paused menus hide coach")
	game.pause(false); coach.skip(); coach._process(0.01)
	check(not coach.visible and game.session.state.journey.tutorial_completed_ids.size() == Progress.IDS.size(),"Skip persists and stops hints")
	game.session.state.journey.erase("tutorial_completed_ids")
	coach.replaying = false; coach._process(0.01)
	check(not coach.visible,"Pre-feature journey is not interrupted by new hints")
	game.session.state.journey.legacy_history = true
	coach.replay(); coach._process(0.01)
	check(coach.replaying and coach.visible,"Legacy journey can explicitly replay lessons")
	coach.replaying = false
	game.player.apply_look(Vector2(12,0))
	check("look" in game.session.state.journey.tutorial_completed_ids,"Opted-in legacy journey continues tracking after transient replay mode resets")
	game.show_journal()
	for item in game.choices.get_children():
		if item is Button and item.text == "Controls": item.pressed.emit(); break
	var skip_button: Button
	for item in game.choices.get_children():
		if item is Button and item.text == "Skip tutorial hints": skip_button = item
	check(skip_button != null,"Skip action is reachable through real journal Controls")
	skip_button.pressed.emit()
	check(game.session.state.journey.tutorial_completed_ids.size() == Progress.IDS.size(),"Real skip button stores completed lessons")
	coach.replay()
	game.player.combat.state = "locomotion"
	game.settings.rebind("jump",KEY_G)
	coach.active_lesson = "jump"; coach.showing_for = 0
	coach._process(0.01)
	check(coach.label.text.contains("G") or preload("res://game/presentation/mobile_controls.gd").requested(),"Desktop instruction follows rebound input")
	var args := OS.get_cmdline_user_args()
	var output: String = args[0] if not args.is_empty() and args[0] != "--touch" else ProjectSettings.globalize_path("res://.tools/review/tutorial")
	DirAccess.make_dir_recursive_absolute(output)
	game.settings.values.ui_scale = 1.5; game.apply_settings()
	for language in ["bg","en","ru","fr","ar"]:
		game.set_language(language)
		coach.active_lesson = "sprint"; coach.showing_for = 0
		coach._process(0.01)
		await create_timer(0.15,true).timeout
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png(output+"/"+language+".png")
		check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(coach.get_global_rect()),"Translated lesson stays inside screen")
	game.queue_free(); await process_frame
	print("Tutorial: %d assertions, " % assertions + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
