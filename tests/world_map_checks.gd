extends SceneTree
var failures := 0
var assertions := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	root.size = Vector2i(1600,900)
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking = true; game.session.begin(1,false); game.started = true
	game.show_journal()
	var entry: Button
	for item in game.choices.get_children():
		if item is Button and item.text == "World map": entry = item
	check(entry != null,"Map reachable from journal")
	entry.pressed.emit()
	var map = game.choices.get_node("WorldMap")
	check(map != null and paused,"Map opens and pauses gameplay")
	check(map.target == "travel" and not map.polygons.is_empty(),"Refuge map uses navigation and next route")
	check("token" not in map.markers,"Map does not reveal hidden pickups")
	check(not game.travel_to_lantern("checkpoint.citadel"),"Map opening does not bypass travel proximity")
	var snapshot := JSON.stringify(game.session.state)
	for language in ["bg","en","ru","fr","ar"]:
		game.set_language(language); game.show_world_map()
		await create_timer(0.12,true).timeout
		RenderingServer.force_draw(false)
		var output := ProjectSettings.globalize_path("res://.tools/review/world-map")
		DirAccess.make_dir_recursive_absolute(output)
		root.get_texture().get_image().save_png(output+"/"+language+".png")
		check(game.dialogue.visible and not game.npc_conversation.portrait.visible,"Map uses its own presentation")
	check(snapshot == JSON.stringify(game.session.state),"Map browsing never changes campaign progress")
	game.leave_dialogue()
	check(not paused,"Closing map resumes gameplay")
	game.session.state = JSON.parse_string(FileAccess.get_file_as_string("res://.tools/wizard-defeat-fixture.json"))
	for id in ["village","crypt","blackwood","grove","order","sanctum","peaks","forge","citadel","ritual"]:
		check(await game.transition("region."+id),"Map region loads: "+id)
		game.show_world_map()
		map = game.choices.get_node("WorldMap")
		check(map.target in map.markers and not map.polygons.is_empty(),"Current campaign map has a valid next landmark: "+id)
		await create_timer(0.12,true).timeout
		game.leave_dialogue()
	game.queue_free(); await process_frame
	print("World map: %d assertions, " % assertions + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
