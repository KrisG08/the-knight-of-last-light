extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func photograph(name: String) -> void:
	for frame in range(8):
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
	await game.start_selected()
	await game.transition("region.village")
	game.pause(false)
	game.player.enabled = false
	for enemy in game.enemies:
		enemy.set_physics_process(false)
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 72
	game.ui_layer.hide()
	camera.position = Vector3(21,2.1,25)
	camera.look_at(Vector3(29,1.8,16))
	await photograph("village-life-east-market")
	camera.position = Vector3(-22,2.1,27)
	camera.look_at(Vector3(-29,1.8,17))
	await photograph("village-life-west-yard")
	camera.position = Vector3(22,2,0)
	camera.look_at(Vector3(33,1.2,-7))
	await photograph("village-life-mill-storage")
	camera.position = Vector3(0,1.8,28)
	camera.look_at(Vector3(0,4,4))
	await photograph("village_detail_street")
	camera.position = Vector3(0,1.9,5)
	camera.look_at(Vector3(0,2,-10))
	await photograph("village_detail_square")
	camera.position = Vector3(21,2,12)
	camera.look_at(Vector3(30,4,4))
	await photograph("village_detail_mill")
	camera.queue_free()
	game.player.arm.get_child(0).current = true
	game.player.position = Vector3(0,0.1,28)
	game.player.pitch = -0.12
	game.ui_layer.show()
	await photograph("village_detail_hud")
	for enemy in game.enemies:
		enemy.sounds.stop()
	game.player.sounds.stop()
	game.ui_sound.stop()
	paused = false
	game.queue_free()
	await create_timer(0.2,true).timeout
	quit()
