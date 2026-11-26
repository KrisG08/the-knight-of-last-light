extends SceneTree
const Enemy = preload("res://game/actors/enemies/training_soldier.gd")
var actors: Array[CharacterBody3D] = []
var labels: Array[Label3D] = []
var world: Node3D
var camera: Camera3D
func _initialize() -> void:
	call_deferred("capture")
func photo(name: String) -> void:
	for frame in range(8):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/"+name+".png")
func capture() -> void:
	world = Node3D.new()
	root.add_child(world)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("111b24")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("a2b8c7")
	environment.ambient_light_energy = 0.7
	var reflection := Sky.new()
	var reflection_material := ProceduralSkyMaterial.new()
	reflection_material.sky_top_color = Color("273d50")
	reflection_material.sky_horizon_color = Color("879da6")
	reflection.sky_material = reflection_material
	environment.sky = reflection
	environment.background_mode = Environment.BG_SKY
	var sky := WorldEnvironment.new()
	sky.environment = environment
	world.add_child(sky)
	for entry in [[Vector3(-45,-25,0),Color("b5d3e2"),1.6],[Vector3(-25,145,0),Color("c9a47c"),1.0]]:
		var light := DirectionalLight3D.new()
		light.rotation_degrees = entry[0]
		light.light_color = entry[1]
		light.light_energy = entry[2]
		light.shadow_enabled = true
		world.add_child(light)
	var floor_body := StaticBody3D.new()
	world.add_child(floor_body)
	var floor_mesh := BoxMesh.new()
	floor_mesh.size = Vector3(40,0.2,25)
	var floor_visual := MeshInstance3D.new()
	floor_visual.mesh = floor_mesh
	floor_visual.position.y = -0.1
	var matte := StandardMaterial3D.new()
	matte.albedo_color = Color("26313a")
	floor_visual.material_override = matte
	floor_body.add_child(floor_visual)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = floor_mesh.size
	collision.shape = shape
	collision.position.y = -0.1
	floor_body.add_child(collision)
	var player := preload("res://game/actors/player/knight.gd").new()
	world.add_child(player)
	player.hide()
	player.position.z = 30
	player.set_physics_process(false)
	for profile in ["hollow_villager","fallen_soldier","grave_hound","bound_shade"]:
		var actor := Enemy.new()
		actor.profile = load("res://content/enemies/"+profile+".tres")
		actor.player = player
		world.add_child(actor)
		actor.set_physics_process(false)
		actor.label.hide()
		actors.append(actor)
	for id in ["gravedigger","thorn_beast","fallen_commander","iron_warden","maldrek"]:
		var actor = load("res://game/actors/bosses/"+id+".gd").new()
		actor.player = player
		world.add_child(actor)
		actor.set_physics_process(false)
		actor.label.hide()
		actors.append(actor)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 58
	world.add_child(camera)
	for index in range(actors.size()):
		actors[index].hide()
	for index in range(4):
		actors[index].show()
		actors[index].position = Vector3((index-1.5)*2.6,0.05,0)
		actors[index].visual.rotation.y = PI
	camera.position = Vector3(0,3.1,10)
	camera.look_at(Vector3(0,1.0,0))
	await photo("hostiles_ordinary")
	for actor in actors:
		actor.hide()
	for index in range(5):
		actors[index+4].show()
		actors[index+4].position = Vector3((index-2)*4,0.05,0)
		actors[index+4].visual.rotation.y = PI
	camera.position = Vector3(0,4.8,17)
	camera.look_at(Vector3(0,1.3,0))
	await photo("hostiles_bosses")
	for actor in actors:
		actor.hide()
	for index in range(9):
		actors[index].show()
		actors[index].position = Vector3(0,0.05,0)
		actors[index].visual.rotation.y = PI-0.3
		camera.position = Vector3(3,2.4,5.5)
		camera.look_at(Vector3(0,1.45,0))
		await photo("hostile_"+["villager","soldier","hound","shade","gravedigger","thorn","commander","warden","maldrek"][index])
		actors[index].hide()
	for actor in actors:
		actor.sounds.stop()
	player.sounds.stop()
	world.queue_free()
	await create_timer(0.2,true).timeout
	quit()
