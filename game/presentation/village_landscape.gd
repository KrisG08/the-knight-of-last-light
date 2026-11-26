extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Assets = preload("res://game/presentation/real_assets.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const Horizon = preload("res://game/presentation/forest_horizon.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "VillageLandscape"
	region.add_child(root)
	var ground := ShaderMaterial.new()
	ground.shader = preload("res://assets/materials/village_ground.gdshader")
	var textures := {"cobble_color":"cobblestone_floor_02/Diffuse.jpg","cobble_normal":"cobblestone_floor_02/nor_gl.jpg","cobble_rough":"cobblestone_floor_02/Rough.jpg","soil_color":"forest_ground_04/Diffuse.jpg"}
	for entry in textures:
		ground.set_shader_parameter(entry,load("res://assets/vendor/polyhaven/"+textures[entry]))
	region.village_ground.get_child(0).material_override = ground
	Horizon.build(region,Vector2(43,48),"VillageHorizon",Vector2(40,45))
	# Outer tree belt sits beyond the existing fence and collision boundary.
	for side in [-1,1]:
		for index in range(9):
			var at := Vector3(side*(49+index%3*4),0,-43+index*11)
			Assets.place_mesh(root,"pine_sapling_small","pine_sapling_small_"+["a","b","c"][index%3],at,Vector3(25,19+index%3*2,25),index*1.3)
	var tufts: Array[Transform3D] = []
	var random := RandomNumberGenerator.new()
	random.seed = 95042
	# Authored pockets: house foundations, back yards, grave edges. No main streets.
	for center in [Vector3(-16,0,19),Vector3(15.5,0,19),Vector3(-35,0,17),Vector3(35,0,17),Vector3(-35,0,-31),Vector3(36,0,-34),Vector3(-24,0,-29),Vector3(18,0,-26),Vector3(-24,0,4),Vector3(24,0,4)]:
		for index in range(95):
			var at: Vector3 = center+Vector3(random.randf_range(-1.1,1.1),0.04,random.randf_range(-2.2,2.2))
			tufts.append(Transform3D(Basis(Vector3.UP,random.randf()*TAU).scaled(Vector3.ONE*random.randf_range(0.55,1.15)),at))
	var blades := SurfaceTool.new()
	blades.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(5):
		var angle: float = index*TAU/5
		var height: float = 0.22+index%3*0.09
		for vertex in [Vector3(-0.035,0,0),Vector3(0.025,height*0.55,0.04),Vector3(0.035,0,0),Vector3(-0.035,0,0),Vector3(0.055,height,0.1),Vector3(0.025,height*0.55,0.04)]:
			blades.add_vertex(vertex.rotated(Vector3.UP,angle))
	blades.generate_normals()
	var grass := Art.material("village_yard_grass",Color("4d5940"))
	grass.cull_mode = BaseMaterial3D.CULL_DISABLED
	Dressing.instances(root,blades.commit(),grass,tufts)
