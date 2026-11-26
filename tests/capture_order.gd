extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func photograph(name: String) -> void:
	for frame in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/" + name + ".png")

func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	game.session.begin(1, false)
	game.session.state = load("res://tests/order_checks.gd").order_state()
	game.started = true
	await game.transition("region.order")
	game.pause(false)
	game.player.enabled = false
	for guard in game.enemies:
		guard.set_physics_process(false)
	game.player.position = game.region.points.cael + Vector3(0, 0.1, 2)
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	game.order_chapter.talk()
	await photograph("cael_quest")
	game.leave_dialogue()
	for guard in game.order_chapter.guards:
		guard.receive_hit(game.player.position, 1000, 1, 0)
	game.player.position = game.region.points.expedition + Vector3(0, 0.1, 2)
	game.order_chapter.read_record()
	await photograph("order_record")
	game.leave_dialogue()
	game.player.position = game.region.points.cael + Vector3(0, 0.1, 2)
	game.order_chapter.talk()
	game.choices.get_child(0).pressed.emit()
	game.player.enabled = false
	game.player.position = Vector3(3, 0.1, -3)
	game.journey.follower.set_physics_process(false)
	game.journey.follower.position = Vector3(1, 0.1, -5)
	game.journey.follower.set_order("hold")
	await photograph("cael_companion")
	game.ui_sound.stop()
	game.player.sounds.stop()
	for guard in game.enemies:
		guard.sounds.stop()
	await create_timer(0.2, true).timeout
	game.queue_free()
	await process_frame
	quit()
