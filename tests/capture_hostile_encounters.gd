extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func photo(name: String) -> void:
	for frame in range(10):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/"+name+".png")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	game.benchmarking = true
	await game.start_selected()
	await game.transition("region.village")
	game.pause(false)
	game.player.enabled = false
	game.player.visual.hide()
	for actor in game.enemies:
		actor.set_physics_process(false)
	game.player.position = Vector3(26,0.1,-1)
	game.mill_guard._physics_process(0.016)
	game.mill_guard._physics_process(0.3)
	var camera := Camera3D.new()
	camera.fov = 52
	game.add_child(camera)
	camera.current = true
	camera.position = Vector3(23,2.1,1.5)
	camera.look_at(game.mill_guard.position+Vector3.UP)
	game.ui_layer.hide()
	await photo("hostile_village_guard")
	await game.transition("region.crypt")
	game.pause(false)
	game.player.enabled = false
	game.player.visual.hide()
	game.player.position = Vector3(0,0.1,4)
	game.burial.actor.set_physics_process(false)
	game.burial.actor.begin_attack("slam")
	game.burial.actor._physics_process(0.5)
	camera.current = true
	camera.position = Vector3(3,2.7,3.8)
	camera.look_at(game.burial.actor.position+Vector3(0,1.5,0))
	game.ui_layer.hide()
	await photo("hostile_crypt_gravedigger")
	game.burial.actor.sounds.stop()
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await create_timer(0.2,true).timeout
	quit()
