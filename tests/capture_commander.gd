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
	await game.transition("region.sanctum")
	game.pause(false)
	game.player.enabled = false
	game.player.position = Vector3(0, 0.1, 2)
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	var boss = game.commander.actor
	boss.set_physics_process(false)
	boss.start()
	boss.begin_attack("overhead")
	boss._physics_process(1.0)
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	await photograph("commander_overhead")
	boss.begin_attack("crosscut", true)
	boss._physics_process(0.5)
	await photograph("commander_second_cut")
	boss.receive_hit(game.player.position, 10000, 1, 0)
	game.commander.break_seal()
	game.player.position = Vector3(0, 0.1, -5)
	await photograph("oath_seal_broken")
	await game.transition("region.peaks")
	game.player.enabled = false
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	await photograph("ashen_peaks_entrance")
	game.player.sounds.stop()
	game.ui_sound.stop()
	await create_timer(0.2, true).timeout
	game.queue_free()
	await process_frame
	quit()
