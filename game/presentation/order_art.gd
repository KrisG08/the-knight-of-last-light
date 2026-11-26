extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const Horizon = preload("res://game/presentation/forest_horizon.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "OrderArchitecture"
	region.add_child(root)
	var stone := Art.stone()
	var batches: Dictionary = {}
	region.interact_colliders.order_depth.get_child(0).hide()
	region.expedition.get_child(0).hide()
	Horizon.build(region,Vector2(35,38),"OrderHorizon",Vector2(32,35))
	region.get_node("OrderHorizon").position.z = -21
	region.get_node("OrderHorizon").scale.y = 0.7
	# Dress existing walls/cots; their physical footprints remain the authority.
	for child in region.get_children():
		if not child is Node3D or child.get_child_count()==0: continue
		var visual = child.get_child(0)
		if not visual is MeshInstance3D or not visual.mesh is BoxMesh: continue
		if child.position.x==-24 and is_equal_approx(child.position.y,0.4):
			visual.hide()
			cot(root,batches,Vector3(-24,0,child.position.z))
		elif child.position==Vector3(-19,5,-48):
			visual.hide()
		elif child.position.x in [8,17,26] and child.position.z in [-19,-32] and child.position.y==2:
			visual.hide()
		elif child.position==Vector3(0,1,-25):
			visual.hide()
		elif child is StaticBody3D and (absf(child.position.x)==32 or child.position.z in [-56,14]):
			# Outer walls retain collision but receive an irregular crenellated profile.
			visual.material_override = stone
	for side in [-1,1]:
		for z in [8,-5,-18,-31,-44,-53]:
			Kit.piece(batches,stone,Vector3(side*31.3,3,z),Vector3(1.1,6,1.5))
			Kit.piece(batches,stone,Vector3(side*31.3,6.1,z),Vector3(1.4,0.3,1.8))
		for index in range(16):
			var z: float = 11-index*4
			Kit.piece(batches,stone,Vector3(side*32,5.4,z),Vector3(1.2,0.8,1.3))
	# Barracks entrances frame the actual wide passages.
	for z in [-12,-38]:
		Art.pointed_arch(root,Vector3(-19,0,z),7.2,6.6)
	for z in [-16,-25,-34]:
		Kit.beam(batches,Vector3(-26,4,z),Vector3(-19,6.4,z),0.22)
		Kit.beam(batches,Vector3(-19,6.4,z),Vector3(-12,4,z),0.22)
		Kit.torch(root,Vector3(-26.3,2,z),Vector3.RIGHT)
	# Surviving western roof strips; eastern half collapsed into the courtyard.
	for index in range(12):
		if index in [3,8,9]: continue
		Kit.piece(batches,Kit.wood(),Vector3(-23,5.1,-36+index*2),Vector3(7.8,0.14,1.8),Basis(Vector3.BACK,0.32))
	# Courtyard columns now have plinths, carved collars and broken arcades.
	for x in [8,17,26]:
		for z in [-19,-32]:
			Art.cylinder(root,Vector3(x,0.2,z),0.9,0.9,0.4,stone,12)
			Art.cylinder(root,Vector3(x,2,z),0.5,0.42,4,stone,12)
			Art.cylinder(root,Vector3(x,4.1,z),0.7,0.7,0.25,stone,12)
		if x<26:
			Art.pointed_arch(root,Vector3(x+4.5,0,-32),9,6.6)
	Dressing.rubble(root,Vector3(27,0,-27),45,2.2)
	# Existing central obstacle becomes a fallen masonry column and rubble bed.
	var fallen := Art.cylinder(root,Vector3(0,0.9,-25),0.72,0.66,6.3,stone,14)
	fallen.quaternion = Quaternion(Vector3.UP,Vector3(1,0.08,0).normalized())
	for x in [-2.7,2.7]:
		var collar := Art.cylinder(root,Vector3(x,0.9+x*0.08,-25),0.86,0.86,0.3,stone,14)
		collar.rotation.z = PI/2
	Dressing.rubble(root,Vector3(0,0,-25),55,2)
	# Weapon racks and abandoned shields belong to the barracks, not the route.
	for z in [-20,-30]:
		for x in [-26.2,-25.2]:
			Kit.beam(batches,Vector3(x,0,z),Vector3(x,2.1,z),0.08)
		Kit.beam(batches,Vector3(-26.2,1.7,z),Vector3(-25.2,1.7,z),0.08)
		for index in range(3):
			var x: float = -26+index*0.3
			Kit.beam(batches,Vector3(x,0.2,z),Vector3(x,1.8,z),0.025)
			Kit.piece(batches,Art.material("order_rack_iron",Color("56616a"),0.7),Vector3(x,1.9,z),Vector3(0.06,0.35,0.05))
	# Memorial hall: recessed memorial tablets, arch and a chain-hung banner.
	Art.pointed_arch(root,Vector3(-19,0,-48),11,8.7)
	for side in [-1,1]:
		var x: float = -19+side*5.6
		Kit.piece(batches,stone,Vector3(x,2,-44),Vector3(0.35,3.5,3.1))
		for row in range(7):
			Kit.piece(batches,Art.material("memorial_carving",Color("28333b")),Vector3(x-side*0.19,3.2-row*0.35,-44),Vector3(0.025,0.045,2.3-row%3*0.25))
		Kit.torch(root,Vector3(x-side*0.3,2,-40),Vector3.RIGHT if side<0 else Vector3.LEFT)
	var cloth := ShaderMaterial.new()
	cloth.shader = preload("res://assets/materials/weathered_canvas.gdshader")
	cloth.set_shader_parameter("cloth_color",Color("38495b"))
	var banner := PlaneMesh.new()
	banner.size = Vector2(1.4,2.6)
	Art.mesh(root,banner,Vector3(-19,5.8,-48.3),cloth).rotation.x = PI/2
	for side in [-1,1]:
		Art.beam(root,Vector3(-19+side*0.6,8.4,-48.3),Vector3(-19+side*0.6,7.1,-48.3),0.018,Art.material("banner_chain",Color("303b43"),0.6))
	# Sanctum facade gives the next confrontation a strong local landmark.
	Art.pointed_arch(root,Vector3(0,0,-49.3),8,7.8)
	for side in [-1,1]:
		Kit.piece(batches,Kit.wood(),Vector3(side*1.72,2,-49.42),Vector3(3.4,4,0.12))
		for y in [0.7,2,3.3]:
			Kit.piece(batches,Art.material("sanctum_iron",Color("333c43"),0.65),Vector3(side*1.72,y,-49.33),Vector3(3.35,0.09,0.06))
	# Open record on a timber lectern replaces the floating yellow rectangle.
	var lectern: Node3D = region.expedition
	Art.box(root,region.points.expedition+Vector3(0,0.1,0),Vector3(0.7,0.16,0.7),Kit.wood())
	Art.cylinder(root,region.points.expedition+Vector3(0,0.5,0),0.13,0.17,0.7,Kit.wood(),10)
	var book := Art.material("record_parchment",Color("b4aa8d"))
	for side in [-1,1]:
		Art.box(lectern,Vector3(side*0.19,0.15,0),Vector3(0.37,0.06,0.6),book).rotation.z = -side*0.1
		for row in range(6):
			Art.box(lectern,Vector3(side*0.19,0.187,-0.2+row*0.075),Vector3(0.25,0.008,0.012),Art.material("record_ink",Color("484338")))
	for side in [-1,1]:
		Art.cylinder(root,Vector3(side*5,4,-51),1,0.8,8,stone,12)
		Art.cylinder(root,Vector3(side*5,9,-51),1.4,0,2,stone,10)
		Kit.torch(root,Vector3(side*4,2,-49),Vector3.BACK)
	Kit.flush(root,batches)
	Dressing.pavers(root,Vector3(0,0.06,-21),5,62)
	Dressing.pavers(root,Vector3(-19,0.06,-22),4,50)

static func cot(root: Node3D, batches: Dictionary, at: Vector3) -> void:
	for side in [-1,1]:
		Kit.piece(batches,Kit.wood(),at+Vector3(side*0.8,0.4,0),Vector3(0.1,0.7,2.9))
		for z in [-1.3,1.3]:
			Kit.piece(batches,Kit.wood(),at+Vector3(side*0.8,0.35,z),Vector3(0.15,0.7,0.15))
	var mattress := BoxMesh.new()
	mattress.size = Vector3(1.5,0.22,2.6)
	var cloth := ShaderMaterial.new()
	cloth.shader = preload("res://assets/materials/weathered_canvas.gdshader")
	cloth.set_shader_parameter("cloth_color",Color("6b6755"))
	Art.mesh(root,mattress,at+Vector3.UP*0.63,cloth)
