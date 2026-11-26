extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	game.session.begin(1,false)
	game.session.state = load("res://tests/finale_checks.gd").citadel_state()
	for id in ["village","blackwood","order","peaks","citadel"]:
		game.session.act("ActivateCheckpoint","checkpoint."+id)
	game.started = true
	await game.transition("region.refuge")
	game.player.position = game.region.points.checkpoint+Vector3(-2,0.1,0)
	game.settings.values.ui_scale = 1.5
	game.apply_settings()
	game.show_lantern_map()
	for frame in range(5):
		await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	root.get_texture().get_image().save_png("res://.tools/review/lantern_map_150.png")
	game.player.sounds.stop()
	game.ui_sound.stop()
	await create_timer(0.2,true).timeout
	game.queue_free()
	await process_frame
	quit()
