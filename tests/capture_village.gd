extends SceneTree

# Native rendered review images, never presented as an interactive playthrough.
func _initialize() -> void:
	call_deferred("capture")

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
	game.pause(true)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/village_menu.png")
	for id in ["region.refuge", "region.village"]:
		await game.transition(id)
		game.pause(false)
		game.player.enabled = false
		for actor in game.enemies:
			actor.set_physics_process(false)
		game.player.position = Vector3(20, 0.1, 28) if id == "region.village" else Vector3(0, 0.1, 10)
		game.player.pivot.rotation = Vector3(-0.25, 0, 0)
		for frame in range(4):
			await physics_frame
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png("res://.tools/review/" + id.trim_prefix("region.") + ".png")
		if result != OK:
			quit(1)
			return
	game.show_journal()
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/village_journal.png")
	game.queue_free()
	await process_frame
	quit(0)
