extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")

# Exterior-only portal building; the existing crypt encounter loads separately.
static func build(region: Node3D) -> StaticBody3D:
	var body: StaticBody3D = region.box(Vector3(0,3.5,-39),Vector3(16,7,10),Color.BLACK)
	body.name = "MausoleumCollision"
	body.get_child(0).hide()
	var root := Node3D.new()
	root.name = "VillageMausoleum"
	root.position = Vector3(0,0,-39)
	region.add_child(root)
	var stone := Art.stone()
	var batches: Dictionary = {}
	var slate := Kit.material("roof_slates_02",Color("4c535d"),0.5) if ResourceLoader.exists("res://assets/vendor/polyhaven/roof_slates_02/Diffuse.jpg") else Art.material("mausoleum_slate",Color("29333d"))
	Kit.piece(batches,stone,Vector3(0,3.5,0),Vector3(16,7,10))
	for y in [0.25,1,6.7,7.15]:
		Kit.piece(batches,stone,Vector3(0,y,0),Vector3(16.6,0.25,10.5))
	for side in [-1,1]:
		# Steep slate roof and tiered tower silhouettes.
		Kit.piece(batches,slate,Vector3(side*4.1,9.4,0),Vector3(9.6,0.25,11),Basis(Vector3.BACK,-side*0.55))
		var roof_collision: Node3D = region.box(root.position+Vector3(side*4.1,9.4,0),Vector3(9.6,0.3,11),Color.BLACK)
		roof_collision.name = "MausoleumRoofCollision"
		roof_collision.rotation.z = -side*0.55
		roof_collision.get_child(0).hide()
		var tower := Vector3(side*6.5,0,3.6)
		Art.cylinder(root,tower+Vector3.UP*5.8,1.25,1.1,11.6,stone,12)
		for y in [0.3,3.5,7.2,10.8,11.5]:
			Art.cylinder(root,tower+Vector3.UP*y,1.4,1.4,0.22,stone,12)
		Art.cylinder(root,tower+Vector3.UP*13.1,1.65,0,3.2,slate,12)
		for z in [-3.8,0,3.8]:
			Kit.piece(batches,stone,Vector3(side*8,2.8,z),Vector3(0.9,5.6,1.2))
			Kit.piece(batches,stone,Vector3(side*8,5.6,z),Vector3(1.05,0.25,1.35))
			# Simple collision matching the projecting buttresses.
			var proxy: Node3D = region.box(root.position+Vector3(side*8,2.8,z),Vector3(0.9,5.6,1.2),Color.BLACK)
			proxy.get_child(0).hide()
		Art.pointed_arch(root,Vector3(side*4.3,1,5.14),1.4,3.7)
		Kit.piece(batches,Art.material("mausoleum_recess",Color("111b24")),Vector3(side*4.3,2.2,5.05),Vector3(0.95,2.5,0.06))
		Kit.torch(root,Vector3(side*2.9,2,5.4),Vector3.BACK)
	var gables := SurfaceTool.new()
	gables.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in [-5.0,5.0]:
		for vertex in [Vector3(-8,7,z),Vector3(0,11.9,z),Vector3(8,7,z)]:
			gables.add_vertex(vertex)
	gables.generate_normals()
	var gable_mat := stone.duplicate() as StandardMaterial3D
	gable_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	Art.mesh(root,gables.commit(),Vector3.ZERO,gable_mat)
	# Layered portal surrounds a physical transition door, not a fake interior.
	Kit.piece(batches,Kit.wood(),Vector3(0,2.1,5.07),Vector3(3.5,4.2,0.1))
	for x in [-1.4,-0.7,0,0.7,1.4]:
		Kit.piece(batches,Art.material("mausoleum_door_iron",Color("273237"),0.65),Vector3(x,2,5.15),Vector3(0.07,3.8,0.06))
	Art.pointed_arch(root,Vector3(0,0,5.35),4.2,5.5)
	Art.pointed_arch(root,Vector3(0,0,5.16),5.2,6.3)
	var rose := TorusMesh.new()
	rose.inner_radius = 0.72
	rose.outer_radius = 0.98
	rose.rings = 24
	rose.ring_segments = 8
	Art.mesh(root,rose,Vector3(0,8.1,5.15),stone).rotation.x = PI/2
	for index in range(8):
		var angle: float = index*TAU/8
		Kit.beam(batches,Vector3(0,8.1,5.2),Vector3(sin(angle)*0.77,8.1+cos(angle)*0.77,5.2),0.06)
	Kit.piece(batches,stone,Vector3(0,12.1,0),Vector3(0.22,1.5,0.25))
	Kit.piece(batches,stone,Vector3(0,12.4,0),Vector3(0.9,0.2,0.25))
	Kit.flush(root,batches)
	return body

static func grave(region: Node3D, at: Vector3) -> void:
	var body: Node3D = region.box(at+Vector3.UP*0.7,Vector3(0.8,1.4,0.35),Color.BLACK)
	body.get_child(0).hide()
	var root := Node3D.new()
	root.position = at
	region.add_child(root)
	var stone := Art.stone()
	Art.box(root,Vector3(0,0.52,0),Vector3(0.76,1.04,0.28),stone)
	var crown := SphereMesh.new()
	crown.radius = 0.38
	crown.height = 0.76
	crown.radial_segments = 12
	crown.rings = 6
	Art.mesh(root,crown,Vector3(0,1.05,0),stone).scale = Vector3(1,0.65,0.4)
	Art.box(root,Vector3(0,0.1,0),Vector3(1.15,0.2,0.7),stone)
	Art.box(root,Vector3(0,0.06,-1),Vector3(0.95,0.12,1.7),stone)
	var recess := Art.material("headstone_carving",Color("283134"))
	Art.box(root,Vector3(0,0.8,0.147),Vector3(0.07,0.5,0.015),recess)
	Art.box(root,Vector3(0,0.91,0.148),Vector3(0.31,0.06,0.015),recess)
	for row in range(3):
		Art.box(root,Vector3(0,0.45-row*0.1,0.147),Vector3(0.35-row*0.06,0.018,0.015),recess)
