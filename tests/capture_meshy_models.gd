extends SceneTree
const Models = preload("res://game/presentation/meshy_models.gd")
func _initialize() -> void:
	create_timer(120).timeout.connect(func(): quit(1))
	call_deferred("capture")
func capture() -> void:
	var world := Node3D.new(); root.add_child(world)
	var env := WorldEnvironment.new(); env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("17232e")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color("b8cad1")
	env.environment.ambient_light_energy = 0.65
	world.add_child(env)
	for angle in [Vector3(-40,-25,0),Vector3(-20,145,0)]:
		var light := DirectionalLight3D.new(); light.rotation_degrees = angle
		light.light_energy = 1.4 if angle.y<0 else 0.7; world.add_child(light)
	var camera := Camera3D.new(); camera.current = true; camera.fov = 42; world.add_child(camera)
	root.size = Vector2i(1100,850)
	for id in Models.HEIGHTS:
		var actor := Node3D.new(); world.add_child(actor)
		var weapon := Node3D.new(); actor.add_child(weapon)
		var rig: Dictionary = Models.knight(actor,weapon) if id=="knight" else Models.build(actor,id)
		var h: float = Models.HEIGHTS[id]
		camera.position = Vector3(h,h*0.68,-h*1.6)*(1.5 if id=="thorn-beast" else 1.0)
		camera.look_at(Vector3(0,h*0.49,0))
		for frame in range(5): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/meshy-"+id+".png")
		for leg in rig.legs: leg.rotation.x = 0.35
		for frame in range(3): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/meshy-"+id+"-motion.png")
		for leg in rig.legs: leg.rotation.x = 0
		camera.position = Vector3(-h,h*0.68,h*1.6)*(1.5 if id=="thorn-beast" else 1.0)
		camera.look_at(Vector3(0,h*0.49,0))
		for frame in range(3): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/meshy-"+id+"-back.png")
		actor.free()
	print("Captured all 10 Meshy model rest/motion views")
	quit()
