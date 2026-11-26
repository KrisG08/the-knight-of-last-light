extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func photo(name: String) -> void:
	for frame in range(8): await process_frame
	RenderingServer.force_draw(false)
	if root.get_texture().get_image().save_png("res://.tools/review/"+name+".png")!=OK:
		quit(1)

func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	await game.start_selected()
	game.show_journal()
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	await photo("journal-fresh")
	game.session.state.campaign.facts.append("region.blackwood.visited")
	game.session.state.campaign.quest_states["quest.lyra"] = "active"
	game.show_journal()
	await photo("journal-discovered-forest")
	game.queue_free()
	await process_frame
	quit(0)
