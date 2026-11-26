extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size = Vector2i(640,640)
	var knight = preload("res://game/actors/player/knight.gd").new()
	root.add_child(knight)
	knight.set_physics_process(false)
	var motion = knight.model.skeletal_locomotion
	motion.set_process(false)
	motion.animation.play("stand")
	motion.animation.advance(0)
	for child in knight.visual.get_children():
		if child!=motion: child.hide()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.RED
	for mesh in motion.find_children("*","MeshInstance3D",true,false):
		mesh.material_override = material
	var camera := Camera3D.new()
	root.add_child(camera)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 1.2
	camera.position = Vector3(0,0.5,3)
	camera.look_at(Vector3(0,0.5,0))
	camera.current = true
	for frame in range(5): await process_frame
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	var red := 0
	for y in range(70,400):
		for x in range(160,480):
			var pixel := picture.get_pixel(x,y)
			if pixel.r>0.7 and pixel.g<0.15 and pixel.b<0.15: red+=1
	picture.save_png("res://.tools/review/leg-render-probe.png")
	print("Leg upper/shin coverage: %d pixels" % red)
	if red<500:
		push_error("Skinned legs missing above the boots")
	knight.queue_free()
	await process_frame
	quit(1 if red<500 else 0)
