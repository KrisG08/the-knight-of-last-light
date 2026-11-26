extends RefCounted
const Art = preload("res://game/presentation/art_kit.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "AuthoredRuinDressing"
	region.add_child(root)
	if region.region_id == "region.refuge":
		refuge(root)
	elif region.region_id == "region.village":
		for at in [Vector3(-35,0,27),Vector3(34,0,27),Vector3(-34,0,-32),Vector3(34,0,-33)]:
			tree(root,at,1.5)
		for at in [Vector3(-17,0,28),Vector3(17,0,28),Vector3(-5,0,-28),Vector3(5,0,-28)]:
			Art.lantern(root,at)
		Art.pointed_arch(root,Vector3(0,0,-34),4.5,7)
		pavers(root,Vector3(0,0.055,0),4,80)
		rubble(root,Vector3(-32,0,-31),35,8)
	elif region.region_id == "region.blackwood":
		for at in [Vector3(-14,0,7),Vector3(14,0,5),Vector3(-23,0,-22),Vector3(26,0,-42),Vector3(-22,0,-59)]:
			tree(root,at,1.7)
		for at in [Vector3(18,0,-33),Vector3(22,0,-51),Vector3(-15,0,-55)]:
			Art.lantern(root,at)
		rubble(root,Vector3(26,0,-59),60,4)
	else:
		if region.points.has("spawn"):
			for side in [-1,1]:
				Art.lantern(root,region.points.spawn+Vector3(side*3,0,-3))
		if region.region_id in ["region.crypt","region.grove","region.sanctum","region.forge","region.ritual"]:
			Art.pointed_arch(root,Vector3(0,0,-11),5,6)
			for side in [-1,1]:
				rubble(root,Vector3(side*10,0,-7),25,1.4)
		elif region.region_id == "region.order":
			Art.pointed_arch(root,Vector3(0,0,-47),6,9)
			rubble(root,Vector3(25,0,-44),60,4)
		elif region.region_id == "region.peaks":
			for at in [Vector3(-29,0,-12),Vector3(27,0,-51),Vector3(-23,0,-66)]:
				rubble(root,at,50,4)
		elif region.region_id == "region.citadel":
			Art.pointed_arch(root,Vector3(0,0,-52),7,11)
			for at in [Vector3(-7,0,-19),Vector3(7,0,-19),Vector3(-7,0,-36),Vector3(7,0,-36)]:
				Art.lantern(root,at)

static func refuge(root: Node3D) -> void:
	var stone := Art.stone()
	Art.pointed_arch(root,Vector3(0,0,-17.5),6.4,9)
	for side in [-1,1]:
		var x: float = side*7
		for z in [-10,-3,4]:
			Art.cylinder(root,Vector3(x,2.5,z),0.65,0.45,5,stone,10)
			for y in [0.2,4.7]:
				Art.cylinder(root,Vector3(x,y,z),0.75,0.75,0.3,stone,10)
			if side == 1:
				Art.pointed_arch(root,Vector3(0,0,z),14,8.6)
		for z in [-14,-7,0,7,14]:
			Art.box(root,Vector3(side*18.4,2,z),Vector3(1.4,4,1),stone)
			Art.cylinder(root,Vector3(side*18.4,4.7,z),0.55,0,1.4,stone,6)
		for z in [-14,-3,8]:
			Art.lantern(root,Vector3(side*4,0,z))
		var light := OmniLight3D.new()
		light.position = Vector3(side*4,1.8,-3)
		light.light_color = Color("e4a346")
		light.light_energy = 5
		light.omni_range = 9
		root.add_child(light)
		for z in [-14,13]:
			tree(root,Vector3(side*15.5,0,z),1.15)
		# Exterior spires establish a cathedral silhouette above existing walls.
		var tower := Vector3(side*15,0,-21)
		Art.box(root,tower+Vector3(0,7,0),Vector3(4,14,4),stone)
		for y in [4,9,13.8]:
			Art.box(root,tower+Vector3(0,y,0),Vector3(4.6,0.4,4.6),stone)
		Art.cylinder(root,tower+Vector3(0,17,0),3,0,6,Art.material("roof",Color("182a37")),8)
		Art.box(root,tower+Vector3(0,11,2.04),Vector3(1,3.4,0.05),Art.material("curse_glass",Color("bc86ff")))
		for offset in [-1.5,1.5]:
			Art.cylinder(root,tower+Vector3(offset,14.6,1.5),0.3,0,2,stone,6)
		rubble(root,Vector3(side*15,0,1),70,2.3)
	pavers(root,Vector3(0,0.07,-0.5),5,32)
	grass(root)

static func pavers(root: Node3D, center: Vector3, width: int, length: int) -> void:
	var transforms: Array[Transform3D] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 1042
	for row in range(length):
		for col in range(width):
			if rng.randf() < 0.06:
				continue
			var at := center+Vector3((col-width*0.5)*0.8+rng.randf_range(-0.04,0.04),rng.randf_range(-0.015,0.015),(row-length*0.5)*0.9)
			at.y = center.y-0.05+rng.randf_range(-0.003,0.003)
			transforms.append(Transform3D(Basis(Vector3.UP,rng.randf_range(-0.06,0.06)),at))
	var shape := BoxMesh.new()
	shape.size = Vector3(0.74,0.02,0.84)
	instances(root,shape,Art.stone(),transforms)
	root.get_child(-1).set_meta("terrain_paving",true)

static func rubble(root: Node3D, center: Vector3, count: int, radius: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 824+int(absf(center.x)*23+absf(center.z)*11)
	var transforms: Array[Transform3D] = []
	for item in range(count):
		var size := Vector3(rng.randf_range(0.15,0.75),rng.randf_range(0.12,0.5),rng.randf_range(0.2,0.7))
		var at := center+Vector3(rng.randf_range(-radius,radius),size.y*0.5,rng.randf_range(-radius,radius))
		transforms.append(Transform3D(Basis.from_euler(Vector3(rng.randf()*0.5,rng.randf()*TAU,rng.randf()*0.5)).scaled(size),at))
	var shape := PrismMesh.new()
	instances(root,shape,Art.stone(),transforms)

static func instances(root: Node3D, shape: Mesh, mat: Material, transforms: Array[Transform3D]) -> void:
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.mesh = shape
	batch.instance_count = transforms.size()
	for index in range(transforms.size()):
		batch.set_instance_transform(index,transforms[index])
	var node := MultiMeshInstance3D.new()
	node.multimesh = batch
	node.material_override = mat
	root.add_child(node)

static func tree(root: Node3D, at: Vector3, scale: float) -> void:
	var bark := Art.material("dead_bark",Color("25313a"))
	Art.beam(root,at,at+Vector3(0.3,4.5,0)*scale,0.2*scale,bark)
	for index in range(7):
		var side := -1 if index%2 == 0 else 1
		var start := at+Vector3(0.12,1.6+index*0.38,0)*scale
		var end := start+Vector3(side*(1.1+index*0.09),0.8,(index%3-1)*0.8)*scale
		Art.beam(root,start,end,0.08*scale,bark)
		Art.beam(root,end,end+Vector3(side*0.5,0.8,0.2)*scale,0.035*scale,bark)

static func grass(root: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 703
	var transforms: Array[Transform3D] = []
	for item in range(320):
		var side := -1 if item%2 == 0 else 1
		var at := Vector3(side*rng.randf_range(4.5,17.5),0.12,rng.randf_range(-15,15))
		transforms.append(Transform3D(Basis(Vector3.UP,rng.randf()*TAU).scaled(Vector3(0.1,rng.randf_range(0.16,0.45),0.1)),at))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for blade in range(3):
		var angle := blade*PI/3
		var left := Vector3(-0.25,0,0).rotated(Vector3.UP,angle)
		var right := -left
		for vertex in [left,Vector3(0.1,1.4,0.12),right]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var mat := Art.material("withered_grass",Color("344539"))
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	instances(root,surface.commit(),mat,transforms)
