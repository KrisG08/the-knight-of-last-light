extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const Assets = preload("res://game/presentation/real_assets.gd")
static var materials: Dictionary = {}

static func material(id: String, tint: Color, scale: float = 0.5) -> StandardMaterial3D:
	if materials.has(id):
		return materials[id]
	var result := StandardMaterial3D.new()
	result.albedo_color = tint
	result.albedo_texture = load("res://assets/vendor/polyhaven/"+id+"/Diffuse.jpg")
	result.normal_enabled = true
	result.normal_texture = load("res://assets/vendor/polyhaven/"+id+"/nor_gl.jpg")
	result.normal_scale = 0.35 if id == "grey_plaster_02" else 0.8
	result.roughness_texture = load("res://assets/vendor/polyhaven/"+id+"/Rough.jpg")
	result.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
	result.uv1_triplanar = true
	result.uv1_scale = Vector3.ONE*scale
	result.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	materials[id] = result
	return result

static func wood() -> StandardMaterial3D:
	return material("dark_wooden_planks",Color("7c7165"),0.45)

static func piece(batches: Dictionary, mat: Material, at: Vector3, size: Vector3, basis: Basis = Basis.IDENTITY) -> void:
	var key := mat.get_instance_id()
	if not batches.has(key):
		batches[key] = {"material":mat,"transforms":[]}
	batches[key].transforms.append(Transform3D(basis*Basis.from_scale(size),at))

static func beam(batches: Dictionary, from: Vector3, to: Vector3, thickness: float = 0.18, face: Transform3D = Transform3D.IDENTITY) -> void:
	var direction := to-from
	var transform := face*Transform3D(Basis(Quaternion(Vector3.UP,direction.normalized())),(from+to)*0.5)
	piece(batches,wood(),transform.origin,Vector3(thickness,direction.length(),thickness),transform.basis)

static func flush(root: Node3D, batches: Dictionary) -> void:
	var shape := BoxMesh.new()
	shape.size = Vector3.ONE
	for batch in batches.values():
		var transforms: Array[Transform3D] = []
		transforms.assign(batch.transforms)
		Dressing.instances(root,shape,batch.material,transforms)

static func facade(batches: Dictionary, root: Node3D, width: float, height: float, face: Transform3D, has_door: bool) -> void:
	for y in [0.35,3.1,height-0.1]:
		beam(batches,Vector3(-width/2,y,0.06),Vector3(width/2,y,0.06),0.22,face)
	var bays: int = maxi(2,int(width/2.4))
	for index in range(bays+1):
		var x: float = -width/2+width*index/bays
		beam(batches,Vector3(x,0.4,0.07),Vector3(x,height,0.07),0.2,face)
		if index<bays:
			var next: float = x+width/bays
			beam(batches,Vector3(x,3.3,0.08),Vector3(next,height-0.3,0.08),0.14,face)
	for index in range(bays):
		var x: float = -width/2+width*(index+0.5)/bays
		var window := face*Transform3D(Basis.IDENTITY,Vector3(x,4.55,0.15))
		var dark := Art.material("village_window",Color("10171b"))
		piece(batches,dark,window.origin,Vector3(0.88,1.35,0.09),face.basis)
		for dx in [-0.51,0.51]:
			var at := face*Vector3(x+dx,4.55,0.24)
			piece(batches,wood(),at,Vector3(0.13,1.65,0.18),face.basis)
		for y in [3.78,4.55,5.32]:
			piece(batches,wood(),face*Vector3(x,y,0.22),Vector3(1.12,0.12,0.16),face.basis)
		piece(batches,wood(),face*Vector3(x,4.55,0.24),Vector3(0.08,1.5,0.18),face.basis)
		# Individual planks and angled shutter geometry.
		for side in [-1,1]:
			var angle: float = side*0.35
			piece(batches,wood(),face*Vector3(x+side*0.83,4.55,0.36),Vector3(0.55,1.5,0.12),face.basis*Basis(Vector3.UP,angle))
	if has_door:
		piece(batches,wood(),face*Vector3(0,1.28,0.16),Vector3(1.35,2.45,0.14),face.basis)
		for x in [-0.78,0.78]:
			piece(batches,wood(),face*Vector3(x,1.3,0.26),Vector3(0.18,2.6,0.25),face.basis)
		for y in [0.65,1.9,2.55]:
			piece(batches,Art.material("village_door_iron",Color("272b29"),0.7),face*Vector3(0,y,0.26),Vector3(1.4,0.12,0.08),face.basis)
		for side in [-1,1]:
			beam(batches,Vector3(side*1.1,2.5,0.25),Vector3(side*1.1,3.1,1.25),0.13,face)
		piece(batches,wood(),face*Vector3(0,3.15,0.8),Vector3(2.8,0.18,1.65),face.basis*Basis(Vector3.RIGHT,0.12))
		if root.get_parent() is StaticBody3D:
			var proxy := CollisionShape3D.new()
			proxy.name = "AwningCameraCollision"
			var shape := BoxShape3D.new()
			shape.size = Vector3(2.8,0.22,1.65)
			proxy.shape = shape
			proxy.transform = root.transform*face*Transform3D(Basis(Vector3.RIGHT,0.12),Vector3(0,3.15,0.8))
			root.get_parent().add_child(proxy)

static func roof(root: Node3D, width: float, depth: float, height: float) -> void:
	var rise := width*0.56
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1,1]:
		for row in range(8):
			for column in range(8):
				for offset in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
					var u: float = (column+offset.x)/8.0
					var v: float = (row+offset.y)/8.0
					var x: float = side*u*(width/2+0.65)
					var y: float = height+(1-u)*rise-sin(u*PI)*0.14-sin(v*PI)*0.12
					var z: float = (v-0.5)*(depth+1.2)
					surface.set_uv(Vector2(u*(width*0.65),v*depth))
					surface.add_vertex(Vector3(x,y,z))
	surface.generate_normals()
	var tiles := material("grey_roof_tiles",Color("727986"),0.4).duplicate() as StandardMaterial3D
	tiles.uv1_triplanar = false
	tiles.uv1_scale = Vector3(0.5,0.5,1)
	tiles.cull_mode = BaseMaterial3D.CULL_DISABLED
	Art.mesh(root,surface.commit(),Vector3.ZERO,tiles).name = "CurvedSlateRoof"

static func house(root: Node3D, size: Vector3, street_side: int) -> void:
	root.name = "TimberHouse"
	var batches: Dictionary = {}
	var h: float = size.y
	var plaster := material("grey_plaster_02",Color("bbb3a0"),0.4)
	piece(batches,plaster,Vector3(0,h*0.5,0),Vector3(size.x,h,size.z))
	piece(batches,plaster,Vector3(0,3.2+(h-3.2)*0.5,0),Vector3(size.x+0.2,h-3.2,size.z+0.2))
	piece(batches,Art.stone(),Vector3(0,0.22,0),Vector3(size.x+0.2,0.44,size.z+0.2))
	for side in [-1,1]:
		var face := Transform3D(Basis(Vector3.UP,0 if side==1 else PI),Vector3(0,0,side*size.z/2))
		facade(batches,root,size.x,h,face,side==1)
		var side_face := Transform3D(Basis(Vector3.UP,side*PI/2),Vector3(side*size.x/2,0,0))
		facade(batches,root,size.z,h,side_face,side==street_side)
		var gable := SurfaceTool.new()
		gable.begin(Mesh.PRIMITIVE_TRIANGLES)
		for v in [Vector3(-size.x/2,h,side*size.z/2),Vector3(0,h+size.x*0.56,side*size.z/2),Vector3(size.x/2,h,side*size.z/2)]:
			gable.add_vertex(v)
		gable.generate_normals()
		var two_sided := plaster.duplicate() as StandardMaterial3D
		two_sided.cull_mode = BaseMaterial3D.CULL_DISABLED
		Art.mesh(root,gable.commit(),Vector3.ZERO,two_sided)
		for direction in [-1,1]:
			beam(batches,Vector3(direction*size.x/2,h,side*(size.z/2+0.1)),Vector3(0,h+size.x*0.56,side*(size.z/2+0.1)),0.23)
		beam(batches,Vector3(0,h,side*(size.z/2+0.1)),Vector3(0,h+size.x*0.56,side*(size.z/2+0.1)),0.18)
		beam(batches,Vector3(side*(size.x/2+0.5),h, -size.z/2-0.65),Vector3(side*(size.x/2+0.5),h,size.z/2+0.65),0.2)
	beam(batches,Vector3(0,h+size.x*0.56,-size.z/2-0.7),Vector3(0,h+size.x*0.56,size.z/2+0.7),0.26)
	# Chimney, projecting floor band and corbels break up the silhouette.
	piece(batches,Art.stone(),Vector3(size.x*0.3,h+size.x*0.35, -size.z*0.25),Vector3(0.9,3.5,0.95))
	piece(batches,Art.stone(),Vector3(size.x*0.3,h+size.x*0.35+1.8,-size.z*0.25),Vector3(1.2,0.22,1.2))
	for side in [-1,1]:
		piece(batches,wood(),Vector3(side*(size.x/2+0.12),3.2,0),Vector3(0.35,0.3,size.z+0.6))
		for z in [-size.z*0.35,0,size.z*0.35]:
			beam(batches,Vector3(side*(size.x/2-0.1),2.5,z),Vector3(side*(size.x/2+0.45),3.1,z),0.18)
	roof(root,size.x,size.z,h)
	flush(root,batches)

static func torch(root: Node3D, at: Vector3, facing: Vector3, illuminate: bool = true) -> void:
	var iron := Art.material("torch_iron",Color("252c2d"),0.65)
	Art.beam(root,at-facing*0.2-Vector3.UP*0.4,at+facing*0.25+Vector3.UP*0.1,0.07,iron)
	for side in [-1,1]:
		Art.beam(root,at+Vector3(side*0.12,0,0),at+Vector3(side*0.18,0.3,0),0.025,iron)
	var flame := SphereMesh.new()
	flame.radius = 0.11
	flame.height = 0.5
	var shader := ShaderMaterial.new()
	shader.shader = preload("res://assets/materials/torch_flame.gdshader")
	Art.mesh(root,flame,at+Vector3(0,0.22,0),shader)
	if illuminate:
		var light := OmniLight3D.new()
		light.position = at+facing*0.4+Vector3.UP*0.3
		light.light_color = Color("ffba6d")
		light.light_energy = 2.4
		light.omni_range = 8
		root.add_child(light)

static func well(region: Node3D, root: Node3D) -> void:
	var at := Vector3(0,0,-7)
	var collider: Node3D = region.box(at+Vector3(0,2,0),Vector3(3,4,3),Color.BLACK)
	collider.name = "VillageWellCollision"
	collider.get_child(0).hide()
	var batches: Dictionary = {}
	for row in range(3):
		for index in range(18):
			var angle: float = (index+row*0.5)*TAU/18
			piece(batches,Art.stone(),at+Vector3(sin(angle)*1.08,0.22+row*0.3,cos(angle)*1.08),Vector3(0.37,0.29,0.4),Basis(Vector3.UP,angle))
	for side in [-1,1]:
		beam(batches,at+Vector3(side*1.25,0.1,0),at+Vector3(side*1.25,3.3,0),0.2)
	beam(batches,at+Vector3(-1.5,3.2,0),at+Vector3(1.5,3.2,0),0.18)
	Art.beam(root,at+Vector3(0,3.2,0),at+Vector3(0,0.65,0),0.025,wood())
	var cover := Node3D.new()
	cover.position = at+Vector3(0,3.25,0)
	root.add_child(cover)
	roof(cover,3.4,2.4,0)
	flush(root,batches)

static func mill_wheel(root: Node3D, at: Vector3) -> void:
	var batches: Dictionary = {}
	var ring := TorusMesh.new()
	ring.inner_radius = 2.55
	ring.outer_radius = 2.9
	ring.rings = 48
	ring.ring_segments = 8
	for side in [-1,1]:
		var rim := Art.mesh(root,ring,at+Vector3(side*0.4,0,0),wood())
		rim.rotation.z = PI/2
	for index in range(16):
		var angle: float = index*TAU/16
		beam(batches,at,at+Vector3(0,cos(angle)*2.7,sin(angle)*2.7),0.18)
		piece(batches,wood(),at+Vector3(0,cos(angle)*2.8,sin(angle)*2.8),Vector3(1.1,0.25,0.7),Basis(Vector3.RIGHT,angle))
	flush(root,batches)

static func shortcut_gate(body: StaticBody3D) -> void:
	body.get_child(0).hide()
	var root := Node3D.new()
	body.add_child(root)
	var batches: Dictionary = {}
	for x in [-4.7,4.7]:
		piece(batches,wood(),Vector3(x,0,0),Vector3(0.28,3.2,0.3))
	for y in [-0.9,0.9]:
		piece(batches,wood(),Vector3(0,y,0),Vector3(9.5,0.23,0.22))
	for x in [-4,-3,-2,-1,0,1,2,3,4]:
		piece(batches,wood(),Vector3(x,0,0),Vector3(0.13,2.5,0.18))
	beam(batches,Vector3(-4.5,-1.3,0.12),Vector3(4.5,1.3,0.12),0.18)
	beam(batches,Vector3(-4.5,1.3,0.15),Vector3(4.5,-1.3,0.15),0.18)
	flush(root,batches)

static func finish(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "VillageStreetDetail"
	region.add_child(root)
	var cobbles := material("cobblestone_floor_02",Color("797b80"),0.32)
	region.village_ground.get_child(0).material_override = cobbles.duplicate()
	for child in region.get_children():
		if child is Node3D and child.position.y>=0 and child.position.y<0.05 and child.get_child_count()>0:
			var visual := child.get_child(0) as MeshInstance3D
			if visual!=null and visual.mesh is BoxMesh and visual.mesh.size.y<0.1:
				visual.hide()
		if child is StaticBody3D and (absf(child.position.x)==40 or absf(child.position.z)==45):
			child.get_child(0).hide()
	var dressing := region.get_node("AuthoredRuinDressing")
	for child in dressing.get_children():
		if child is MultiMeshInstance3D and child.multimesh.mesh is BoxMesh:
			child.hide()
	for mesh in region.find_children("*","MeshInstance3D",true,false):
		if mesh.material_override!=null and mesh.material_override == Art.materials.get("lantern_gold_glass"):
			var warm := mesh.material_override.duplicate() as StandardMaterial3D
			warm.albedo_color = Color("ffd69c")
			warm.emission = Color("ffb95f")
			mesh.material_override = warm
	well(region,root)
	# Torch pools at the street-facing doors; no real-time local shadow maps.
	for at in [Vector3(-4.6,2,21),Vector3(4.6,2,16),Vector3(-5.6,2,-6),Vector3(7.6,2,-10),Vector3(25,2,-0.4)]:
		torch(root,at,Vector3.RIGHT if at.x<0 else Vector3.LEFT)
	for side in [-1,1]:
		for z in [-34,-12,12,34]:
			Assets.place_mesh(root,"pine_sapling_small","pine_sapling_small_b",Vector3(side*45,0,z),Vector3.ONE*18,z*0.1)
		for z in [-36,-20,0,20,38]:
			var fence := Node3D.new()
			fence.position = Vector3(side*39,0,z)
			root.add_child(fence)
			var batches: Dictionary = {}
			for index in range(10):
				piece(batches,wood(),Vector3(0,1.4,index*1.8-8),Vector3(0.22,2.8,0.2))
			for y in [0.7,1.8]:
				piece(batches,wood(),Vector3(0,y,0),Vector3(0.16,0.16,18))
			flush(fence,batches)
	# Rebuild once with the new well footprint included.
	region.remove_child(region.navigation)
	region.navigation.queue_free()
	region.build_navigation()
