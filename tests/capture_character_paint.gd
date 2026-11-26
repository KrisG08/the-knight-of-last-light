extends SceneTree
## Native rendered material comparisons, using the real runtime character builder.
const Models = preload("res://game/presentation/meshy_models.gd")
var models: Array[Node3D] = []

func _initialize() -> void: call_deferred("capture")

func capture() -> void:
	root.size=Vector2i(1920,1080)
	var stage := Node3D.new(); root.add_child(stage)
	var environment := WorldEnvironment.new(); environment.environment=Environment.new()
	environment.environment.background_mode=Environment.BG_COLOR
	environment.environment.background_color=Color("171c28")
	environment.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color=Color("c1c9df")
	environment.environment.ambient_light_energy=.65
	stage.add_child(environment)
	var key := DirectionalLight3D.new(); stage.add_child(key)
	key.position=Vector3(-3,6,-6); key.look_at(Vector3(4,2,0)); key.light_energy=1.7
	key.light_color=Color("ffe4c4")
	var fill := DirectionalLight3D.new(); stage.add_child(fill)
	fill.position=Vector3(10,3,-4); fill.look_at(Vector3(4,2,0)); fill.light_energy=.7
	fill.light_color=Color("a6b5e3")
	var rim := DirectionalLight3D.new(); stage.add_child(rim)
	rim.position=Vector3(4,5,4); rim.look_at(Vector3(4,2,0)); rim.light_energy=1.2
	rim.light_color=Color("b6a3e7")
	var camera := Camera3D.new(); stage.add_child(camera)
	camera.projection=Camera3D.PROJECTION_ORTHOGONAL; camera.size=6.2
	camera.position=Vector3(4.4,2.6,-14); camera.look_at(Vector3(4.4,2.6,0)); camera.current=true
	var index := 0
	for id: String in Models.HEIGHTS:
		var model := Node3D.new(); stage.add_child(model)
		model.position=Vector3((index%5)*2.2,2.8 if index<5 else .1,0)
		Models.build(model,id,null,(1.7 if id=="thorn-beast" else 1.9)/Models.HEIGHTS[id]); models.append(model)
		var label := Label3D.new(); stage.add_child(label)
		label.text=id; label.position=model.position+Vector3(0,-.22,-.1)
		label.rotation.y=PI; label.font_size=42; label.pixel_size=.005
		index+=1
	var args := OS.get_cmdline_user_args()
	var tag: String = args[0] if not args.is_empty() else "review"
	for angle: String in ["front","oblique","rear"]:
		for model in models: model.rotation.y={"front":0.0,"oblique":PI/4.0,"rear":PI}[angle]
		for frame in range(8): await process_frame
		await RenderingServer.frame_post_draw
		var output := "res://.tools/review/character-paint-"+tag+"-"+angle+".png"
		assert(root.get_texture().get_image().save_png(output)==OK)
		print("CAPTURE ",output)
	stage.free()
	quit()
