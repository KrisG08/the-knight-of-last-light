extends SceneTree
func _initialize() -> void:
	create_timer(45,true).timeout.connect(func(): push_error("Journey capture timed out"); quit(1))
	call_deferred("capture")
func photo(name: String) -> void:
	for frame in range(6): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://.tools/review/"+name+".png")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	await process_frame
	game.benchmarking = true
	# Seeded QA campaigns, not a claimed manual campaign playthrough.
	game.session.begin(1,false)
	game.session.visit("region.village")
	game.session.act("ClearMill")
	game.session.act("RescueOren")
	game.session.act("DefeatBoss","boss.gravedigger")
	game.session.act("BreakSeal","seal.burial")
	game.session.act("VisitBlackwood")
	for index in range(4): game.session.record_enemy("region.village/soldier/"+str(index),"Fallen Soldier","region.village")
	game.session.save_progress()
	for id in range(2,7): game.session.begin(id,false)
	game.session.load_slot(1)
	game.refresh_journey_picker(1)
	game.started = true
	game.show_saved_journeys()
	await photo("saved-journeys-library")
	game.show_journey_progress()
	await photo("saved-journey-progress")
	var scroll: ScrollContainer = game.dialogue.get_child(0)
	scroll.scroll_vertical = 10000
	await photo("saved-journey-enemies")
	print("Six seeded independent journeys and world/victory progress rendered: PASS")
	game.queue_free()
	await process_frame
	quit()
