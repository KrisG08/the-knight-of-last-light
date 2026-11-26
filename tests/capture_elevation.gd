extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var world := Node3D.new(); root.add_child(world)
	var env := WorldEnvironment.new(); env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("263545")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("a3b5c4")
	env.environment.ambient_light_energy = 0.65
	world.add_child(env)
	var sun := DirectionalLight3D.new(); world.add_child(sun)
	sun.rotation_degrees = Vector3(-48,-35,0); sun.light_energy = 1.5
	var camera := Camera3D.new(); world.add_child(camera); camera.current = true; camera.fov = 65
	root.size = Vector2i(1280,720)
	for id in ["peaks","citadel"]:
		var region := preload("res://game/world/regions/graybox_region.gd").new()
		region.build("region."+id); world.add_child(region)
		if id=="citadel":
			camera.position = Vector3(0,29,8)
			camera.look_at(Vector3(0,40,-44))
		else:
			camera.position = Vector3(20,33,11)
			camera.look_at(Vector3(0,21,-39))
		for frame in range(12): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/elevation-"+id+".png")
		region.queue_free(); await process_frame
	quit()
