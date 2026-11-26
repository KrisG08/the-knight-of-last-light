extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func photograph(id: String) -> void:
	for frame in range(12):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/"+id+".png")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	await game.start_selected()
	game.player.enabled = false
	game.player.pitch = -0.07
	await photograph("forest_camp")
	game.player.position = Vector3(-7,0.1,43)
	game.player.yaw = -0.25
	await photograph("forest_road")
	game.player.position = Vector3(0,0.1,-46)
	game.player.yaw = 0
	await photograph("forest_chapel")
	game.pause(true)
	game.menu.hide()
	var intro := preload("res://game/ui/opening_cinematic.gd").new()
	game.add_child(intro)
	await photograph("opening_cinematic")
	intro.complete()
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.queue_free()
	await process_frame
	quit()
