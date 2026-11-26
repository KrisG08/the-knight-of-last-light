extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Detail = preload("res://game/presentation/chapter_detail_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "ChapterArenaDetail"
	region.add_child(root)
	var routes := [[Vector3(0,0,10),Vector3(0,0,-9)]]
	Detail.ground(region,routes,0 if region.region_id=="region.grove" else 2)
	if region.region_id=="region.grove":
		grove(region,root,routes)
		return
	var batches: Dictionary = {}
	var half_width := 12.7 if region.region_id=="region.ritual" else 11.7
	var ritual: bool = region.region_id=="region.ritual"
	var forge: bool = region.region_id=="region.forge"
	var tint := Color("80668d") if ritual else Color("5c7e92")
	# Arcaded wall bays break broad flat surfaces without occupying the arena.
	for side in [-1,1]:
		for z in ([-1.6,1.6] if region.region_id=="region.sanctum" else [-5.5,5.5]):
			if not forge:
				Detail.niche(root,Vector3(side*(half_width-0.17),1,z),-side*PI/2,tint,5.7 if ritual else 4.2)
			else:
				for y in [1.1,2.5,4]:
					Kit.piece(batches,Art.material("iron",Color("41474c"),0.7),Vector3(side*11.5,y,z),Vector3(0.1,0.16,3.7))
		for z in [-9,0,9]:
			Kit.piece(batches,Art.stone(),Vector3(side*(half_width-0.04),0.2,z),Vector3(0.25,0.4,5.8))
			Kit.piece(batches,Art.stone(),Vector3(side*(half_width-0.04),5.8,z),Vector3(0.25,0.25,5.8))
	# Distinct focal architecture at the seal end of each hall.
	if forge:
		for side in [-1,1]:
			Art.cylinder(root,Vector3(side*9,4.8,-11.4),0.32,0.32,8.5,Art.material("iron",Color("41474c"),0.7),12)
			for y in [1,3,5,7]:
				Art.cylinder(root,Vector3(side*9,y,-11.4),0.44,0.44,0.18,Art.material("iron",Color("41474c"),0.7),12)
			Detail.banner(root,Vector3(side*6,5.6,-11.35),0,Color("6b4c34"),3.2)
			# Forging tools hang on the wall, not floating inside the fight corridor.
			for index in range(4):
				var x: float = side*(3.0+index*0.45)
				Kit.beam(batches,Vector3(x,1.2,-11.4),Vector3(x,2.2,-11.4),0.05)
				Kit.piece(batches,Art.material("iron",Color("41474c"),0.7),Vector3(x,2.3,-11.4),Vector3(0.35,0.22,0.12))
	else:
		for side in [-1,1]:
			Detail.niche(root,Vector3(side*6.2,0.6,-half_width+0.06),0,tint,6.5 if ritual else 4.9)
			Detail.banner(root,Vector3(side*3.8,6.7,-half_width+0.12),0,Color("51364e") if ritual else Color("34495f"),3.3)
			statue(root,Vector3(side*(half_width-0.15),1,-0.2),-side*PI/2)
	if ritual:
		oculus(root)
		var inlay := Art.material("ritual_silver",Color("8e8299"),0.5)
		for ray in range(12):
			var angle: float = ray*TAU/12
			for index in range(3):
				var start := Vector3(sin(angle),0,cos(angle))*(3.3+index*1.8)+Vector3.UP*0.013
				var finish := start+Vector3(sin(angle+0.05),0,cos(angle+0.05))*1.2
				var direction := finish-start
				Kit.piece(batches,inlay,(start+finish)*0.5,Vector3(0.045,0.012,direction.length()),Basis(Vector3.UP,atan2(direction.x,direction.z)))
	else:
		# Broken tile edging and a recessed central medallion, all below step height.
		var medallion := TorusMesh.new()
		medallion.inner_radius = 3.8
		medallion.outer_radius = 3.86
		medallion.rings = 64
		medallion.ring_segments = 6
		Art.mesh(root,medallion,Vector3(0,0.014,0),Art.material("hall_inlay",Color("827b68"),0.4)).scale.y = 0.1
	Kit.flush(root,batches)

static func grove(region: Node3D, root: Node3D, routes: Array) -> void:
	var transforms: Array[Transform3D] = []
	for child in region.get_children():
		if child is Node3D and child.get_child_count()>0 and child.get_child(0) is MeshInstance3D:
			if child is StaticBody3D and (absf(child.position.x)==12 or absf(child.position.z)==12): child.get_child(0).hide()
			elif child.position.y==2.5 and absf(child.position.x)==10: child.get_child(0).hide()
	for side in [-1,1]:
		root_bank(root,Vector3(side*11.6,0,0),-side*PI/2,24)
		root_bank(root,Vector3(side*7,0,11.6),PI,10)
		for z in range(-10,11,4):
			var start := Vector3(side*11.8,0,z)
			for step in range(1,16):
				var t: float = step/15.0
				var finish := Vector3(side*(11.8-6.8*pow(t,3)),sin(t*PI/2)*9.3,z+sin(t*PI)*0.35)
				transforms.append(preload("res://game/presentation/blackwood_art.gd").root_segment(start,finish,lerpf(0.42,0.10,t)))
				start = finish
			for twig_side in [-1,1]:
				transforms.append(preload("res://game/presentation/blackwood_art.gd").root_segment(start,start+Vector3(-side*1.8,0.6,twig_side*1.7),0.08))
		for x in range(-10,11,4):
			for step in range(6):
				var start := Vector3(x,step*1.2,side*11.8)
				transforms.append(preload("res://game/presentation/blackwood_art.gd").root_segment(start,start+Vector3(0.1,1.3,0.1),0.35-step*0.03))
	var cylinder := CylinderMesh.new()
	cylinder.bottom_radius = 1
	cylinder.top_radius = 0.7
	cylinder.height = 1
	cylinder.radial_segments = 9
	Dressing.instances(root,cylinder,Kit.wood(),transforms)
	root_bank(root,Vector3(0,0,-11.6),0,24)
	# Rocky banks sit behind the original solid wall ring.
	for side in [-1,1]:
		for z in [-8,0,8]:
			preload("res://game/presentation/real_assets.gd").place_mesh(root,"rock_moss_set_01","rock_moss_set_01_rock02",Vector3(side*13.2,-0.3,z),Vector3(2.0,3.8,3.3),z)
			preload("res://game/presentation/real_assets.gd").place_mesh(root,"pine_sapling_small","pine_sapling_small_c",Vector3(side*15,0,z),Vector3(20,24,20),z*0.31,4000)
	Detail.vegetation(region,root,routes,Rect2(-11,-11,22,22),6671)
	preload("res://game/presentation/forest_horizon.gd").build(root,Vector2(17,17),"GroveHorizon",Vector2(12,12))
	root.get_node("GroveHorizon").scale.y = 0.35
	region.entrance_barrier.get_child(0).hide()
	preload("res://game/presentation/blackwood_art.gd").root_bar(region.entrance_barrier,4)
	preload("res://game/presentation/seal_crystal.gd").attach(region.seal,Color("9eb97c"))
	Art.pointed_arch(root,Vector3(0,0,-11.4),5,6.5)
	for side in [-1,1]:
		Kit.torch(root,Vector3(side*3,2,-10.6),Vector3.BACK)

static func root_bank(root: Node3D, at: Vector3, yaw: float, length: float) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var steps := int(length)
	for index in range(steps):
		var x: float = -length*0.5+index
		var a := Vector3(x,0,0)
		var b := Vector3(x+1,0,0)
		var c := Vector3(x,1.5+sin(index*1.7)*0.25,-0.35)
		var d := Vector3(x+1,1.5+sin((index+1)*1.7)*0.25,-0.35)
		for vertex in [a,b,c,b,d,c]:
			surface.set_uv(Vector2(vertex.x,vertex.y)*0.3)
			surface.add_vertex(vertex)
	surface.generate_normals()
	var stone := Art.stone().duplicate() as StandardMaterial3D
	stone.albedo_color = Color("58624a")
	stone.cull_mode = BaseMaterial3D.CULL_DISABLED
	Art.mesh(root,surface.commit(),at,stone).rotation.y = yaw

static func statue(root: Node3D, at: Vector3, yaw: float) -> void:
	var face := Node3D.new()
	face.position = at
	face.rotation.y = yaw
	root.add_child(face)
	var stone := Art.stone()
	Art.box(face,Vector3(0,0.05,0),Vector3(1,0.1,0.28),stone)
	Art.cylinder(face,Vector3(0,1.2,0),0.32,0.22,2.2,stone,10)
	Art.cylinder(face,Vector3(0,2.6,0),0.26,0.22,0.6,stone,10)
	Art.box(face,Vector3(0,2.65,0.23),Vector3(0.35,0.06,0.08),Art.material("statue_visor",Color("242e36")))
	for side in [-1,1]:
		Art.beam(face,Vector3(side*0.32,2.15,0),Vector3(side*0.24,1.1,0.12),0.14,stone)
	Art.box(face,Vector3(0,1.1,0.25),Vector3(0.09,1.8,0.08),stone)
	Art.box(face,Vector3(0,1.8,0.25),Vector3(0.55,0.09,0.08),stone)

static func oculus(root: Node3D) -> void:
	var metal := Art.material("oculus_iron",Color("47404f"),0.6)
	for radius in [2.4,3.5]:
		var ring := TorusMesh.new()
		ring.inner_radius = radius-0.08
		ring.outer_radius = radius+0.08
		ring.rings = 48
		ring.ring_segments = 8
		Art.mesh(root,ring,Vector3(0,11.5,0),metal)
	for ray in range(12):
		var angle: float = ray*TAU/12
		var at := Vector3(sin(angle)*3.5,11.5,cos(angle)*3.5)
		Art.beam(root,at,Vector3(0,13.7,0),0.045,metal)
		Art.beam(root,at,at-Vector3.UP*1.3,0.022,metal)
		var shard := PrismMesh.new()
		shard.size = Vector3(0.16,0.75,0.16)
		Art.mesh(root,shard,at-Vector3.UP*1.6,Art.material("oculus_crystal",Color("9b84ab"),0.3)).rotation.z = PI
