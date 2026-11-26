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
	game.started = true
	game.session.act("DefeatBoss", "boss.gravedigger")
	game.session.act("BreakSeal", "seal.burial")
	await game.transition("region.blackwood")
	game.pause(false)
	game.player.enabled = false
	for actor in game.enemies:
		actor.set_physics_process(false)
	game.player.position = Vector3(20, 0.1, -18)
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	await photograph("blackwood_chapter")
	await game.transition("region.grove")
	game.player.enabled = false
	game.player.position = Vector3(0, 0.1, 3)
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	var boss = game.forest_chapter.actor
	boss.set_physics_process(false)
	boss.start()
	boss.begin_attack("lunge")
	boss._physics_process(0.7)
	await photograph("thorn_beast")
	boss.receive_hit(game.player.position, 1000, 1, 0)
	game.forest_chapter.break_seal()
	await game.transition("region.order")
	game.player.enabled = false
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	await photograph("order_entrance")
	game.player.sounds.stop()
	game.ui_sound.stop()
	await create_timer(0.2, true).timeout
	game.queue_free()
	await process_frame
	quit()
