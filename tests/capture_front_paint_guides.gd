extends SceneTree
## Actual orthographic geometry guides for reference-aligned front paint.
const Models=preload("res://game/presentation/meshy_models.gd")
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1024,1024)
	var stage := Node3D.new(); root.add_child(stage)
	var environment := WorldEnvironment.new(); environment.environment=Environment.new()
	environment.environment.background_mode=Environment.BG_COLOR
	environment.environment.background_color=Color("242933")
	environment.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color=Color.WHITE
	environment.environment.ambient_light_energy=.9
	stage.add_child(environment)
	var key := DirectionalLight3D.new(); stage.add_child(key)
	key.position=Vector3(-3,6,-6); key.look_at(Vector3(0,1,0)); key.light_energy=.8
	var camera := Camera3D.new(); stage.add_child(camera)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL
	camera.position=Vector3(0,.95,-10); camera.look_at(Vector3(0,.95,0)); camera.current=true
	DirAccess.make_dir_recursive_absolute("res://.tools/review/front-guides")
	for id: String in Models.HEIGHTS:
		var model := Node3D.new(); stage.add_child(model)
		Models.build(model,id,null,1.9/Models.HEIGHTS[id])
		camera.size=2.25 if id!="thorn-beast" else 3.5
		for frame in range(5): await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png("res://.tools/review/front-guides/"+id+".png")==OK)
		model.free()
		print("FRONT GUIDE ",id)
	stage.free(); quit()
