extends SceneTree
var game: Node
var assertions := 0
var failures := 0
var output := ""
func _initialize() -> void:
	create_timer(150, true).timeout.connect(func(): push_error("NPC presentation timeout"); quit(1))
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func settle() -> void:
	await create_timer(0.1, true).timeout
	for frame in range(8): await process_frame
func photo(name_value: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await settle()
	RenderingServer.force_draw(false)
	check(root.get_texture().get_image().save_png(output + "/" + name_value + ".png") == OK, "Native evidence saved")
func run() -> void:
	var args := OS.get_cmdline_user_args()
	output = args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review/npc-refresh")
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1600, 900)
	game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking = true
	game.session.begin(1, false)
	game.started = true
	for extent in [Vector2i(1600, 900), Vector2i(1280, 600)]:
		root.size = extent
		await settle()
		for language in ["en", "bg", "ru", "fr", "ar"]:
			game.set_language(language)
			for entry in [["OREN", "oren"], ["LYRA", "lyra"], ["SIR CAEL", "cael"]]:
				game.open_dialogue(entry[0] + "\n" + "We travel together, or I wait at the refuge. Only one companion can follow. Rest at a lantern to recover a downed companion.")
				game.button(game.choices, "Follow me", game.leave_dialogue)
				game.button(game.choices, "Leave", game.leave_dialogue)
				await settle()
				var panel: Rect2 = game.dialogue.get_global_rect()
				var picture: Rect2 = game.npc_conversation.portrait.get_global_rect()
				var screen := Rect2(Vector2.ZERO, root.get_visible_rect().size)
				check(game.npc_conversation.speaker == entry[1] and game.npc_conversation.portrait.visible, "Correct NPC portrait selected")
				check(screen.encloses(panel) and panel.end.y > screen.size.y * 0.85, "Dialogue fits bottom screen")
				check(screen.encloses(picture) and picture.end.y <= panel.position.y, "Portrait fits above panel")
				check(picture.position.x < panel.position.x + panel.size.x * 0.25, "Portrait stays on physical left in every language")
				check(paused, "Conversation pauses gameplay")
				if language == "bg" and entry[1] == "oren" or language == "ar" and entry[1] == "lyra":
					await photo(entry[1] + "-" + language + "-" + str(extent.x))
				game.choices.get_child(1).pressed.emit()
				check(not game.dialogue.visible and not game.npc_conversation.portrait.visible, "Leave hides both dialogue and portrait")
	root.size = Vector2i(1600, 900)
	game.set_language("bg")
	game.talk_to_oren()
	await photo("oren-dialogue-final")
	root.size = Vector2i(1280, 600)
	game.settings.values.ui_scale = 1.5
	game.apply_settings()
	game.set_language("fr")
	game.talk_to_oren()
	await settle()
	check(Rect2(Vector2.ZERO, root.get_visible_rect().size).encloses(game.dialogue.get_global_rect()), "Large French dialogue stays on screen")
	check(game.choices is HFlowContainer and game.choices.get_child_count() == 3, "NPC responses wrap while preserving every action")
	await photo("oren-large-french")
	game.settings.values.ui_scale = 1.0
	game.apply_settings()
	game.open_dialogue("JOURNAL\nCurrent lead")
	await settle()
	check(game.npc_conversation.speaker.is_empty() and not game.npc_conversation.portrait.visible, "Non-NPC screens keep their own layout")
	game.leave_dialogue()
	game.session.state = JSON.parse_string(FileAccess.get_file_as_string("res://.tools/wizard-defeat-fixture.json"))
	check(await game.transition("region.village"), "Village loads")
	var state: Dictionary = game.session.state.duplicate(true)
	state.campaign.recruited_ally_ids.erase("ally.oren")
	game.region.apply_state(state)
	check(game.region.captured_gate.visible and game.region.captured_gate.collision_layer == 1, "Closed cell remains solid")
	check(game.region.has_node("OrenHoldingCell") and game.region.captured_gate.has_node("DoorHinge"), "Authored village cell and hinged gate exist")
	await cell_photo("village-cell", game.region.points.oren)
	state.campaign.recruited_ally_ids.append("ally.oren")
	game.region.apply_state(state)
	await create_timer(0.8, true).timeout
	check(game.region.captured_gate.visible and game.region.captured_gate.collision_layer == 0, "Rescued cell keeps its door and permits passage")
	check(game.region.captured_gate.get_node("DoorHinge").rotation.y < -1.0, "Rescue opens door on its hinge")
	await cell_photo("village-cell-open", game.region.points.oren)
	check(await game.transition("region.citadel"), "Citadel loads")
	state = game.session.state.duplicate(true)
	state.campaign.facts.erase("citadel.prisoners_freed")
	game.region.apply_state(state)
	check(game.region.has_node("CitadelCaptiveQuarters") and game.region.prison_bars.collision_layer == 1, "Citadel captive quarters remain guarded")
	await cell_photo("citadel-cell", Vector3(-19, 0, -20))
	state.campaign.facts.append("citadel.prisoners_freed")
	game.region.apply_state(state)
	check(game.region.prison_bars.collision_layer == 0 and not game.region.prison_survivors.visible, "Freed survivors and passable prison state persist")
	game.queue_free()
	await process_frame
	print("NPC presentation: %d assertions, " % assertions + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
func cell_photo(label_value: String, at: Vector3) -> void:
	var camera := Camera3D.new()
	game.region.add_child(camera)
	camera.position = game.region.surface_point(at) + Vector3(0, 2.5, 7)
	camera.look_at(game.region.surface_point(at) + Vector3.UP * 1.3)
	camera.make_current()
	await photo(label_value)
	camera.queue_free()
	await process_frame
