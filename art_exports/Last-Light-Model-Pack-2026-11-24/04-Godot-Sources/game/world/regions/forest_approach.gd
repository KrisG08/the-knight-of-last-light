extends RefCounted

# Authored road and landmarks. The fixed seed only varies decorative vegetation.
const Art = preload("res://game/presentation/art_kit.gd")
const Assets = preload("res://game/presentation/real_assets.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const KingsRoad = preload("res://game/presentation/kings_road.gd")
const Horizon = preload("res://game/presentation/forest_horizon.gd")
const ROAD = [Vector3(0,0,94), Vector3(0,0,76), Vector3(-9,0,53), Vector3(-7,0,30), Vector3(7,0,8), Vector3(11,0,-15), Vector3(0,0,-39), Vector3(0,0,-65), Vector3(0,0,-102)]
const BOUNDS = Rect2(-68,-112,136,224)

static func landmark_clearance(at: Vector3) -> bool:
	# Reserve breathing room around authored props and their approaches.
	for site in [Vector3(24,0,12),Vector3(-17,0,47),Vector3(-24,0,-23),Vector3(18,0,56)]:
		if Vector2(at.x-site.x,at.z-site.z).length()<8:
			return true
	return false

static func road_distance(at: Vector3) -> float:
	var distance := INF
	for index in range(1,ROAD.size()):
		distance = minf(distance,at.distance_to(Geometry3D.get_closest_point_to_segment(at,ROAD[index-1],ROAD[index])))
	return distance

static func height_at(x: float, z: float) -> float:
	var edge := smoothstep(5.5,16.0,road_distance(Vector3(x,0,z)))
	if (absf(x) < 22 and z < -45 and z > -85) or (absf(x) < 10 and z > 70 and z < 98):
		edge = 0
	return edge*(1.2+sin(x*0.11+z*0.037)*0.7+cos(z*0.09)*0.45)

static func build(region: Node3D) -> void:
	region.points = {"spawn":Vector3(1,0.1,82),"checkpoint":Vector3(3,0,82),"travel":Vector3(0,0,-102),"oren":Vector3(12,0,-62),"memorial":Vector3(-12,0,-62),"lyra":Vector3(-10,0,-53),"cael":Vector3(10,0,-53)}
	terrain(region)
	# Invisible perimeter behind trees, not visible rectangular courtyard walls.
	for x in [-68,68]:
		var wall: Node3D = region.box(Vector3(x,3,0),Vector3(1,8,224),Color.BLACK)
		wall.get_child(0).hide()
	for z in [-112,112]:
		var wall: Node3D = region.box(Vector3(0,3,z),Vector3(136,8,1),Color.BLACK)
		wall.get_child(0).hide()
	road(region)
	region.lantern(region.points.checkpoint,"THE LAST CAMP\nRest / activate lantern")
	region.label(Vector3(-4,2.5,76),"OLD KING'S ROAD\nAshen Village · north",0.003)
	region.label(region.points.travel+Vector3(0,2.4,0),"ASHEN VILLAGE\nContinue along the road",0.003)
	region.oren = region.person(region.points.oren,"OREN · Blacksmith")
	region.lyra = region.person(region.points.lyra,"LYRA · Scout")
	region.cael = region.person(region.points.cael,"SIR CAEL")
	region.interact_colliders.memorial = region.box(region.points.memorial+Vector3(0,1,0),Vector3(1.3,2,0.8),Color("737d72"))
	region.label(region.points.memorial+Vector3(0,2.8,0),"EXPEDITION MEMORIAL",0.003)
	region.refuge_echo = region.label(Vector3(0,3.2,-62),"",0.003)
	region.rescued_survivors = Node3D.new()
	region.add_child(region.rescued_survivors)
	for at in [Vector3(13,0,-71),Vector3(16,0,-71)]:
		var survivor: Node3D = region.person(at,"RESCUED SURVIVOR")
		survivor.reparent(region.rescued_survivors,false)
	landmarks(region)
	vegetation(region)
	distant_citadel(region)
	Horizon.build(region,Vector2(72,118),"ForestHorizon",Vector2(68,112))
	KingsRoad.build(region,ROAD,height_at)
	region.build_navigation(BOUNDS,4.0)
	preload("res://game/presentation/mythic_fauna.gd").build(region,height_at)
	Horizon.fit(region)

static func terrain(region: Node3D) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(56):
		for column in range(34):
			var x: float = -68+column*4
			var z: float = -112+row*4
			for offset in [Vector2(0,0),Vector2(4,4),Vector2(0,4),Vector2(0,0),Vector2(4,0),Vector2(4,4)]:
				surface.set_uv(Vector2(x+offset.x,z+offset.y)*0.25)
				surface.add_vertex(Vector3(x+offset.x,height_at(x+offset.x,z+offset.y),z+offset.y))
	surface.generate_normals()
	var mesh := surface.commit()
	mesh.surface_set_material(0,Assets.ground())
	var body := StaticBody3D.new()
	body.name = "ForestTerrain"
	region.add_child(body)
	Art.mesh(body,mesh,Vector3.ZERO,Assets.ground())
	var collider := CollisionShape3D.new()
	collider.shape = mesh.create_trimesh_shape()
	body.add_child(collider)

static func road(region: Node3D) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(1,ROAD.size()):
		var start: Vector3 = ROAD[index-1]
		var end: Vector3 = ROAD[index]
		var side := (end-start).normalized().cross(Vector3.UP)*3.0
		for vertex in [start-side,end+side,start+side,start-side,end-side,end+side]:
			surface.set_uv(Vector2(vertex.x,vertex.z)*0.35)
			surface.add_vertex(vertex+Vector3.UP*0.003)
	surface.generate_normals()
	var dirt := Assets.ground().duplicate() as StandardMaterial3D
	dirt.albedo_color = Color("69604b")
	Art.mesh(region,surface.commit(),Vector3.ZERO,dirt).name = "KingsRoad"

static func landmarks(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "AuthoredRuinDressing"
	region.add_child(root)
	var stone := Art.stone()
	# An expedition bivouac explains the starting point.
	var canvas := Art.material("camp_canvas",Color("4c4038"))
	# Detailed cloth tents are authored by ConceptLandmarks after the terrain.
	for at in [Vector3(-4,0,80),Vector3(-6,0,79),Vector3(6,0,87)]:
		var wood := Art.material("camp_wood",Color("4d3828"))
		Art.cylinder(root,at+Vector3(0,0.45,0),0.35,0.35,0.9,wood,16)
		for y in [0.12,0.45,0.78]:
			Art.cylinder(root,at+Vector3(0,y,0),0.37,0.37,0.055,Art.material("barrel_hoops",Color("242b2b"),0.7),16)
	Art.beam(root,Vector3(-7,0,82),Vector3(-7,4.5,82),0.06,canvas)
	Art.box(root,Vector3(-6.4,3.7,82),Vector3(1.3,1.2,0.04),Art.material("expedition_banner",Color("5e272b")))
	# Broken roadside shrine, followed by the surviving chapel refuge.
	Art.pointed_arch(root,Vector3(-14,0,27),4.5,6.5)
	Dressing.rubble(root,Vector3(-16,0,25),28,3)
	for z in [-77,-63]:
		Art.pointed_arch(root,Vector3(0,0,z),12,10)
		for side in [-1,1]:
			Art.cylinder(root,Vector3(side*7,2.5,z),0.65,0.45,5,stone)
	for side in [-1,1]:
		for z in [-78,-69,-60]:
			# Individual buttresses, not a solid box enclosing the forest.
			Art.box(root,Vector3(side*19,1.8,z),Vector3(1.2,3.6,2.2),stone)
		Dressing.rubble(root,Vector3(side*17,0,-67),35,3)
	Dressing.pavers(root,Vector3(0,0.06,-66),5,28)
	region.lantern(Vector3(4,0,-63),"CHAPEL OF THE LOST")
	region.lantern(Vector3(-4,0,-63),"")
	var warm := OmniLight3D.new()
	warm.position = Vector3(-4,2,83)
	warm.light_color = Color("edac60")
	warm.light_energy = 3
	warm.omni_range = 12
	root.add_child(warm)
	# Three instanced ground layers keep the detail budget bounded.
	Dressing.rubble(root,Vector3(11,0,20),45,8)

static func vegetation(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "PhotogrammetryDressing"
	region.add_child(root)
	var random := RandomNumberGenerator.new()
	random.seed = 72083
	for row in range(19):
		for column in range(11):
			var at := Vector3(-61+column*12+random.randf_range(-3,3),0,-103+row*11+random.randf_range(-3,3))
			if landmark_clearance(at) or road_distance(at) < 7 or (absf(at.x)<23 and at.z < -45 and at.z > -86) or (absf(at.x)<10 and at.z>70 and at.z<98):
				continue
			at.y = height_at(at.x,at.z)-0.1
			var size := random.randf_range(14,23)
			Assets.place_mesh(root,"pine_sapling_small","pine_sapling_small_"+["a","b","c"][(row+column)%3],at,Vector3(size*1.35,size,size*1.35),random.randf_range(-PI,PI))
			# Physical trunk proxy is separate from cosmetic imported geometry.
			if road_distance(Vector3(at.x,0,at.z)) < 22:
				var trunk: Node3D = region.box(at+Vector3(0,2.5,0),Vector3(0.9,5,0.9),Color.BLACK)
				trunk.get_child(0).hide()
			if (row+column)%2 == 0:
				Assets.place_mesh(root,"fern_02","fern_02_a",at+Vector3(1,0,1),Vector3.ONE*1.6,random.randf_range(-PI,PI))
	for index in range(ROAD.size()-1):
		for side in [-1,1]:
			var at: Vector3 = ROAD[index]+Vector3(side*7,0,-4)
			at.y = height_at(at.x,at.z)-0.15
			var scale := random.randf_range(1.4,2.8)
			if index < 2: scale *= .42
			Assets.place_mesh(root,"rock_moss_set_01","rock_moss_set_01_rock0"+str(index%6+1),at,Vector3.ONE*scale,index*0.9)
			Assets.place_mesh(root,"fern_02","fern_02_b",at+Vector3(side*1.5,0,2),Vector3.ONE*1.8,index)
	for at in [Vector3(-13,0,56),Vector3(18,0,-9),Vector3(-16,0,-28)]:
		Assets.place_mesh(root,"dead_tree_trunk","dead_tree_trunk",at,Vector3.ONE*2.6,0.6)
	# Dense lower layers frame the route, leaving the actual walking corridor clear.
	var grass_transforms: Array[Transform3D] = []
	for index in range(900):
		var segment: int = index%(ROAD.size()-1)
		var center: Vector3 = ROAD[segment].lerp(ROAD[segment+1],random.randf())
		var forward: Vector3 = (ROAD[segment+1]-ROAD[segment]).normalized()
		var side: Vector3 = forward.cross(Vector3.UP)*(1 if index%2==0 else -1)
		var at: Vector3 = center+side*random.randf_range(3.4,14)
		if landmark_clearance(at):
			continue
		at.y = height_at(at.x,at.z)
		grass_transforms.append(Transform3D(Basis(Vector3.UP,random.randf()*TAU).scaled(Vector3(0.45,random.randf_range(0.3,0.8),0.45)),at))
		if index%8==0:
			Assets.place_mesh(root,"fern_02","fern_02_"+["a","b","c","d"][index%4],at,Vector3.ONE*random.randf_range(1.1,2.4),random.randf()*TAU)
	var blades := SurfaceTool.new()
	blades.begin(Mesh.PRIMITIVE_TRIANGLES)
	for angle in [0,PI/3,PI*2/3]:
		for vertex in [Vector3(-0.18,0,0),Vector3(0.13,1.2,0.12),Vector3(0.18,0,0)]:
			blades.add_vertex(vertex.rotated(Vector3.UP,angle))
	blades.generate_normals()
	var grass := Art.material("roadside_grass",Color("384637"))
	grass.cull_mode = BaseMaterial3D.CULL_DISABLED
	Dressing.instances(root,blades.commit(),grass,grass_transforms)
	for side in [-1,1]:
		Assets.place_mesh(root,"modular_fort_01","modular_fort_01_tower_round",Vector3(side*24,0,-91),Vector3.ONE*1.5)

static func distant_citadel(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "DistantCitadelLandmark"
	root.position = Vector3(6,8,-168)
	region.add_child(root)
	var stone := Art.stone()
	var roof := Art.material("distant_slate",Color("17252b"))
	var hill := SphereMesh.new()
	hill.radius = 1
	hill.height = 2
	hill.radial_segments = 40
	hill.rings = 16
	var ridge := Art.mesh(root,hill,Vector3(0,-11,0),Art.material("citadel_cliff",Color("303c38")))
	ridge.scale = Vector3(82,14,64)
	for index in range(7):
		var x: float = (index-3)*8
		var high: float = 21+12*(1-absf(index-3)/3.0)
		var z: float = -absf(index-3)*3
		Art.cylinder(root,Vector3(x,high*0.5,z),3,2.5,high,stone,12)
		for ring in [high*0.4,high*0.75,high]:
			Art.cylinder(root,Vector3(x,ring,z),3.35,3.35,0.45,stone,12)
		Art.cylinder(root,Vector3(x,high+5,z),4,0,10,roof,10)
		for side in [-1,1]:
			Art.cylinder(root,Vector3(x+side*2.4,high+1,z+2),0.6,0,5,roof,8)
		if index<6:
			Art.pointed_arch(root,Vector3(x+4,0,z),8,high*0.7)
