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
	game.benchmarking = true
	await game.start_selected()
	game.session.act("DefeatBoss","boss.gravedigger")
	game.session.act("BreakSeal","seal.burial")
	await game.transition("region.blackwood")
	game.pause(false)
	game.player.enabled = false
	game.player.hide()
	for actor in game.enemies:
		actor.set_physics_process(false)
	game.ui_layer.hide()
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 72
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	for view in [["blackwood-art-trail",Vector3(0,2,10),Vector3(8,3,-17)],["blackwood-art-tower",Vector3(13,2,-12),Vector3(21,6,-26)],["blackwood-art-shrine",Vector3(-12,2,-48),Vector3(-12,3.4,-59)]]:
		camera.position = view[1]
		camera.look_at(view[2])
		for frame in range(10):
			await process_frame
		await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png("res://.tools/review/"+view[0]+".png")!=OK:
			quit(1)
			return
	for actor in game.enemies:
		actor.sounds.stop()
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await process_frame
	quit(0)
