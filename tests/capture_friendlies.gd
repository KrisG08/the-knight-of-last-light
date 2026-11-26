extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	await game.start_selected()
	game.player.enabled = false
	game.player.hide()
	game.ui_layer.hide()
	var lineup := Node3D.new()
	lineup.position = Vector3(0,0,78)
	game.region.add_child(lineup)
	var kit = preload("res://game/presentation/friendly_models.gd")
	for index in range(3):
		var person := Node3D.new()
		person.position.x = (index-1)*1.8
		lineup.add_child(person)
		var weapon := Node3D.new()
		person.add_child(weapon)
		kit.build(person,["oren","lyra","cael"][index],weapon)
	var light := OmniLight3D.new()
	light.position = Vector3(0,3,74)
	light.light_energy = 2.5
	light.omni_range = 10
	game.add_child(light)
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.position = Vector3(0,1.5,73)
	camera.look_at(Vector3(0,1.1,78))
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	for frame in range(10): await process_frame
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png("res://.tools/review/friendly-lineup.png")!=OK:
		quit(1)
		return
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.queue_free()
	await process_frame
	quit(0)
