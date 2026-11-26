extends SceneTree
const L=preload("res://game/localization/localizer.gd")
var game: Node
var failures:=0
func _initialize() -> void:
	create_timer(90,true).timeout.connect(func(): push_error("Journey capture timeout"); quit(1))
	call_deferred("capture")
func photo(name_value: String) -> void:
	for frame in range(8): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://.tools/review/journeys-"+name_value+".png")
func capture() -> void:
	root.size=Vector2i(1600,900)
	game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true
	var fresh=preload("res://game/campaign/domain/campaign_rules.gd").new_game(12)
	var progressed=preload("res://tests/finale_checks.gd").citadel_state()
	preload("res://game/persistence/domain/journey_history.gd").ensure(progressed)
	if not game.session.store.save(fresh).ok or not game.session.store.save(progressed).ok:
		push_error("Journey capture fixtures did not save"); quit(1); return
	game.refresh_journey_picker(12)
	for code in L.LANGUAGES:
		game.set_language(code)
		await photo(code+"-menu")
		game.show_saved_journeys()
		await photo(code+"-library")
		for item in game.choices.get_children():
			if item is Button and code!="en" and item.text.contains("Rank"):
				failures+=1; push_error("English rank in "+code+" saved journey button")
		game.pause(true)
		game.refresh_journey_picker(1)
		game.show_journey_progress()
		await photo(code+"-progress")
		game.pause(true); game.refresh_journey_picker(12)
	game.queue_free(); await process_frame; L.set_locale("en")
	print("Five-language saved journey menu, library and progress: "+("PASS" if failures==0 else "FAIL"))
	quit(0 if failures==0 else 1)
