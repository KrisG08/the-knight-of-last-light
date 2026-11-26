extends SceneTree
var output := ""
var failures := 0
var assertions := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	var args := OS.get_cmdline_user_args()
	output = args[0] if not args.is_empty() and args[0] != "--touch" else ProjectSettings.globalize_path("res://.tools/review/journal-fix")
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking = true
	game.session.begin(1, false)
	game.started = true
	for extent in [Vector2i(1600,900), Vector2i(1280,600)]:
		root.size = extent
		for scale_value in [1.0,1.5]:
			game.settings.values.ui_scale = scale_value
			game.apply_settings()
			for language in ["bg","en","ru","fr","ar"]:
				game.set_language(language)
				game.open_dialogue("OREN\nTest")
				game.leave_dialogue()
				var key := InputEventAction.new()
				key.action = "journal"; key.pressed = true
				game._input(key)
				await create_timer(0.15,true).timeout
				for frame in range(8): await process_frame
				check(game.dialogue.visible and paused,"J opens journal and pauses gameplay")
				check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(game.dialogue.get_global_rect()),"Journal stays inside screen: "+language+str(extent)+str(scale_value))
				var scroll := game.dialogue.get_child(0) as ScrollContainer
				check(game.dialogue_text.size.x <= scroll.size.x + 1,"Journal text wraps to available width")
				check(not game.npc_conversation.portrait.visible,"Journal hides NPC portrait")
				if language == "bg" and scale_value == 1.0:
					RenderingServer.force_draw(false)
					DirAccess.make_dir_recursive_absolute(output)
					root.get_texture().get_image().save_png(output+"/"+str(extent.x)+".png")
				game.leave_dialogue()
	game.queue_free(); await process_frame
	print("Journal layout: %d assertions, " % assertions + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
