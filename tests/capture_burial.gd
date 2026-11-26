extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func photograph(name: String) -> void:
	for frame in range(4):
		await physics_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("res://.tools/review/" + name + ".png")
	if result != OK:
		quit(1)

func capture() -> void:
	var scene := load("res://game/world/runtime/village_game.tscn") as PackedScene
	var game = scene.instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	game.session.begin(1, false)
	game.started = true
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	await game.transition("region.crypt")
	game.pause(false)
	game.player.enabled = false
	game.player.position = Vector3(0, 0.1, 4)
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	var boss = game.burial.actor
	boss.set_physics_process(false)
	boss.start()
	boss.begin_attack("slam")
	boss._physics_process(0.8)
	await photograph("crypt_slam")
	boss.receive_hit(game.player.position, 230, 1, 0)
	boss.begin_attack("burst")
	boss._physics_process(0.7)
	game.player.position = Vector3(3, 0.1, 4)
	await photograph("crypt_burst")
	boss.receive_hit(game.player.position, 1000, 1, 0)
	game.burial.break_seal()
	await game.transition("region.blackwood")
	game.pause(false)
	game.player.enabled = false
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	await photograph("blackwood_entrance")
	game.player.sounds.stop()
	await create_timer(0.2, true).timeout
	game.queue_free()
	await process_frame
	quit(0)
