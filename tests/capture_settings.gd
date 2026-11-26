extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func photograph(name: String) -> void:
	for frame in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/" + name + ".png")

func capture() -> void:
	var scene := load("res://game/world/runtime/village_game.tscn") as PackedScene
	var game = scene.instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	for scale in [1.0, 1.5]:
		game.settings.set_value("ui_scale", scale)
		game.apply_settings()
		game.show_settings()
		await photograph("settings_%d" % int(scale * 100))
	game.pause(true)
	await photograph("menu_150")
	game.session.begin(1, false)
	game.started = true
	await game.transition("region.crypt")
	game.pause(false)
	game.player.enabled = false
	game.player.position = Vector3(0, 0.1, 4)
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	game.burial.actor.set_physics_process(false)
	game.burial.actor.start()
	game.burial.actor.begin_attack("slam")
	game.burial.actor._physics_process(0.8)
	await photograph("hud_150")
	game.ui_sound.stop()
	game.player.sounds.stop()
	game.burial.actor.sounds.stop()
	await create_timer(0.2, true).timeout
	game.queue_free()
	await process_frame
	quit()
