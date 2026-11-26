extends RefCounted
## Visual fittings only, attached beneath existing body/head/weapon pivots.
const Art = preload("res://game/presentation/art_kit.gd")
static var baked: Dictionary = {}
static var steel: StandardMaterial3D

static func restore(root: Node3D, key: String) -> bool:
	if not baked.has(key): return false
	for part in baked[key]: Art.mesh(root,part.mesh,Vector3.ZERO,part.material)
	return true

static func finish(root: Node3D, key: String) -> void:
	var groups: Dictionary = {}
	for node in root.find_children("*","MeshInstance3D",true,false):
		var transform: Transform3D = root.global_transform.affine_inverse()*node.global_transform
		var normal_basis := transform.basis.inverse().transposed()
		for surface in range(node.mesh.get_surface_count()):
			var material: Material = node.material_override if node.material_override!=null else node.mesh.surface_get_material(surface)
			var id: int = material.get_instance_id()
			if not groups.has(id):
				var tool := SurfaceTool.new()
				tool.begin(Mesh.PRIMITIVE_TRIANGLES)
				groups[id] = {"tool":tool,"material":material}
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var positions: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array()
			for index in range(indices.size() if not indices.is_empty() else positions.size()):
				var vertex: int = indices[index] if not indices.is_empty() else index
				groups[id].tool.set_normal((normal_basis*normals[vertex]).normalized())
				groups[id].tool.set_uv(uvs[vertex] if not uvs.is_empty() else Vector2.ZERO)
				groups[id].tool.add_vertex(transform*positions[vertex])
		root.remove_child(node)
		node.queue_free()
	var parts: Array = []
	for group in groups.values():
		var mesh: ArrayMesh = group.tool.commit()
		Art.mesh(root,mesh,Vector3.ZERO,group.material)
		parts.append({"mesh":mesh,"material":group.material})
	baked[key] = parts

static func fabric(tint: Color) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = preload("res://assets/materials/hostile_fabric.gdshader")
	result.set_shader_parameter("cloth_color",tint)
	return result

static func metal() -> Material:
	if steel==null:
		steel = Art.material("iron",Color("243239"),0.75).duplicate() as StandardMaterial3D
		steel.albedo_color = Color("898a82")
		steel.metallic = 0.55
		steel.roughness = 0.8
		steel.normal_scale = 0.4
	return steel

static func gold() -> Material:
	return Art.material("villain_tarnished_gold",Color("a38b5b"),0.55)

static func bone() -> Material:
	return Art.material("villain_carved_bone",Color("b7b09a"))

static func gem(tint: Color) -> StandardMaterial3D:
	tint=tint.lerp(preload("res://game/presentation/curse_palette.gd").LIGHT,0.85)
	var result := Art.material("villain_gem_"+tint.to_html(),tint,0.25)
	result.emission_enabled = true
	result.emission = tint*0.45
	return result

static func plate(root: Node3D, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	# Convex chamfered octagonal plate, rather than a box stuck onto a body.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var outline := [Vector2(-0.3,-0.5),Vector2(0.3,-0.5),Vector2(0.5,-0.3),Vector2(0.5,0.3),Vector2(0.3,0.5),Vector2(-0.3,0.5),Vector2(-0.5,0.3),Vector2(-0.5,-0.3)]
	for index in range(outline.size()):
		var a: Vector2 = outline[index]
		var b: Vector2 = outline[(index+1)%outline.size()]
		for vertex in [Vector3(0,0,-0.5),Vector3(a.x,a.y,-0.15),Vector3(b.x,b.y,-0.15),Vector3(0,0,0.5),Vector3(b.x,b.y,0.15),Vector3(a.x,a.y,0.15),Vector3(a.x,a.y,-0.15),Vector3(a.x,a.y,0.15),Vector3(b.x,b.y,0.15),Vector3(a.x,a.y,-0.15),Vector3(b.x,b.y,0.15),Vector3(b.x,b.y,-0.15)]:
			surface.set_uv(Vector2(vertex.x+0.5,vertex.y+0.5))
			surface.add_vertex(vertex*size)
	surface.generate_normals()
	return Art.mesh(root,surface.commit(),at,material)

static func band(root: Node3D, at: Vector3, radius: float, material: Material, width := 0.025) -> MeshInstance3D:
	var ring := TorusMesh.new()
	ring.inner_radius = radius-width
	ring.outer_radius = radius+width
	ring.rings = 20
	ring.ring_segments = 6
	return Art.mesh(root,ring,at,material)

static func strap(root: Node3D, start: Vector3, finish: Vector3, width: float, material: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var side := (finish-start).cross(Vector3.FORWARD).normalized()*width*0.5
	for vertex in [start-side,start+side,finish+side,start-side,finish+side,finish-side]:
		surface.set_uv(Vector2(vertex.x,vertex.y))
		surface.add_vertex(vertex)
	surface.generate_normals()
	Art.mesh(root,surface.commit(),Vector3.ZERO,material)

static func hanging_panel(root: Node3D, top: Vector3, length: float, width: float, tint: Color) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(8):
		for column in range(8):
			for corner in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
				var u: float = (column+corner.x)/8
				var v: float = (row+corner.y)/8
				var vertex := top+Vector3((u-0.5)*width,-v*length+sin(u*31)*0.035*v*v,-v*0.2-sin(u*19)*0.028)
				surface.set_uv(Vector2(u,v))
				surface.add_vertex(vertex)
	surface.generate_normals()
	Art.mesh(root,surface.commit(),Vector3.ZERO,fabric(tint))
	for side in [-1,1]:
		strap(root,top+Vector3(side*width*0.44,0,-0.025),top+Vector3(side*width*0.44,-length*0.9,-0.025),0.018,gold())

static func hood(root: Node3D, at: Vector3, material: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	var rows := [Vector3(0.23,-0.23,0.19),Vector3(0.26,0,0.23),Vector3(0.2,0.23,0.18),Vector3(0.05,0.34,0.08)]
	for row in range(rows.size()-1):
		for side in range(24):
			for corner in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
				var data: Vector3 = rows[row+int(corner.y)]
				var u: float = (side+corner.x)/24
				var angle: float = lerpf(-PI*0.2,PI*1.2,u)
				surface.set_uv(Vector2(u,(row+corner.y)/3))
				surface.add_vertex(at+Vector3(cos(angle)*data.x,data.y,sin(angle)*data.z))
	surface.generate_normals()
	Art.mesh(root,surface.commit(),Vector3.ZERO,material).name = "OpenCowl"

static func armor(body: Node3D, id: String) -> void:
	var root := Node3D.new()
	root.name = "CharacterRegalia"
	body.add_child(root)
	if restore(root,id): return
	var brass := gold()
	var leather := Art.material("villain_leather_straps",Color("3c3029"))
	var tint := Color("3b5145") if id=="soldier" else (Color("344960") if id=="commander" else Color("69513a"))
	hanging_panel(root,Vector3(0,1.44,-0.27),0.88,0.36 if id=="soldier" else 0.52,tint)
	strap(root,Vector3(-0.32,1.45,-0.29),Vector3(0.3,0.95,-0.43),0.065,leather)
	plate(root,Vector3(0.02,0.96,-0.44),Vector3(0.12,0.1,0.025),brass)
	for side in [-1,1]:
		for index in range(4):
			plate(root,Vector3(side*(0.18+index*0.03),1.39-index*0.035,-0.25),Vector3(0.06,0.08,0.025),metal())
		if id=="warden":
			for layer in range(4):
				plate(root,Vector3(side*0.22,0.97-layer*0.1,-0.43-layer*0.025),Vector3(0.3,0.14,0.055),metal())
		else:
			band(root,Vector3(side*0.2,1.48,-0.22),0.055,brass,0.012).rotation.x = PI/2
	if id=="commander":
		plate(root,Vector3(0,1.26,-0.32),Vector3(0.13,0.2,0.035),brass)
		strap(root,Vector3(-0.16,1.27,-0.35),Vector3(0.16,1.27,-0.35),0.025,brass)
		for side in [-1,1]:
			strap(root,Vector3(side*0.04,1.36,-0.36),Vector3(side*0.04,1.06,-0.41),0.02,brass)
	elif id=="warden":
		# A sealed furnace backpack and flanged vents give the Warden a forge identity.
		Art.cylinder(root,Vector3(0,1.2,0.37),0.21,0.21,0.65,metal(),16)
		for y in [0.91,1.17,1.45]: band(root,Vector3(0,y,0.37),0.23,brass,0.018)
		for side in [-1,1]:
			Art.cylinder(root,Vector3(side*0.12,1.67,0.36),0.05,0.065,0.35,metal(),10)
			plate(root,Vector3(side*0.105,1.2,0.58),Vector3(0.08,0.32,0.02),gem(Color("8d542c")))
	finish(root,id)

static func robes(body: Node3D, id: String, height: float) -> void:
	var root := Node3D.new()
	root.name = "CharacterRegalia"
	body.add_child(root)
	if restore(root,id): return
	var brass := gold()
	var bone_mat := bone()
	var waist: float = height*0.48
	band(root,Vector3(0,waist,0),0.33,Art.material("villain_rope",Color("776e54")),0.025).scale.z = 0.8
	if id=="villager":
		hanging_panel(root,Vector3(0,height*0.68,-0.31),height*0.56,0.47,Color("6e6650"))
		for side in [-1,1]:
			strap(root,Vector3(side*0.19,height*0.76,-0.24),Vector3(side*0.16,height*0.48,-0.34),0.055,Art.material("villain_rope",Color("776e54")))
		for index in range(7):
			Art.beam(root,Vector3(-0.18+index*0.055,height*0.38,-0.35),Vector3(-0.15+index*0.055,height*0.42,-0.35),0.006,brass)
	elif id=="shade":
		hanging_panel(root,Vector3(0,height*0.77,-0.36),height*0.68,0.24,Color("344752"))
	elif id=="gravedigger":
		hanging_panel(root,Vector3(0,height*0.65,-0.34),height*0.58,0.65,Color("615a48"))
		for side in [-1,1]:
			for index in range(5):
				plate(root,Vector3(side*(0.16+index*0.055),height*0.79-index*0.035,-0.42+index*0.03),Vector3(0.06,0.15,0.055),bone_mat).rotation.z = side*0.6
			plate(root,Vector3(side*0.36,waist,-0.08),Vector3(0.17,0.23,0.12),Art.material("grave_pouch",Color("514233")))
		lantern(root,Vector3(-0.43,height*0.18,-0.32))
	elif id=="maldrek":
		hanging_panel(root,Vector3(0,height*0.77,-0.38),height*0.71,0.42,Color("4b355d"))
		for side in [-1,1]:
			for index in range(5):
				plate(root,Vector3(side*(0.18+index*0.055),height*0.81-index*0.045,-0.39+index*0.025),Vector3(0.14,0.2,0.07),brass).rotation.z = side*0.45
			plate(root,Vector3(side*0.34,height*0.66,-0.21),Vector3(0.1,0.18,0.05),gem(Color("8d6ab1")))
		for index in range(5):
			var x: float = (index-2)*0.085
			Art.beam(root,Vector3(x,height+0.14,-0.05),Vector3(x*1.7,height+0.45-absf(x),0.02),0.022,brass)
		band(root,Vector3(0,height+0.03,0.2),0.45,brass,0.018).rotation.x = PI/2
		band(root,Vector3(0,height+0.03,0.2),0.52,Art.material("ritual_halo",Color("4d405b"),0.4),0.009).rotation.x = PI/2
		for index in range(7):
			var y: float = height*0.65-index*0.15
			var front: float = -0.44-(height*0.77-y)/(height*0.71)*0.2
			plate(root,Vector3(0,y,front),Vector3(0.06,0.09,0.015),brass).rotation.z = index*0.6
	finish(root,id)

static func lantern(root: Node3D, at: Vector3) -> void:
	var iron := metal()
	for side in [-1,1]:
		for z in [-0.08,0.08]:
			Art.beam(root,at+Vector3(side*0.08,0,z),at+Vector3(side*0.08,0.25,z),0.012,iron)
	plate(root,at,Vector3(0.22,0.045,0.2),iron).rotation.x = PI/2
	plate(root,at+Vector3.UP*0.26,Vector3(0.22,0.045,0.2),iron).rotation.x = PI/2
	Art.cylinder(root,at+Vector3.UP*0.12,0.055,0.045,0.18,gem(Color("a47940")),8)
	Art.beam(root,at+Vector3.UP*0.3,at+Vector3.UP*0.45,0.012,iron)

static func armored_arm(root: Node3D, shoulder: Vector3, elbow: Vector3, grip: Vector3, scale: float) -> void:
	for segment in [[shoulder,elbow],[elbow,grip]]:
		var direction: Vector3 = segment[1]-segment[0]
		var node := Art.cylinder(root,(segment[0]+segment[1])*0.5,0.12*scale,0.15*scale,direction.length()*0.9,metal(),12)
		node.quaternion = Quaternion(Vector3.UP,direction.normalized())
		for t in [0.2,0.75]:
			var cuff := band(root,segment[0].lerp(segment[1],t),0.145*scale,metal(),0.015)
			cuff.quaternion = Quaternion(Vector3.UP,direction.normalized())
	plate(root,elbow,Vector3(0.25,0.25,0.2)*scale,metal())
	plate(root,grip+Vector3(0,0,-0.06),Vector3(0.2,0.13,0.17)*scale,metal())

static func beast(body: Node3D, head: Node3D, thorn: bool) -> void:
	var root := Node3D.new()
	root.name = "CharacterRegalia"
	body.add_child(root)
	var ivory := bone()
	# Brow armor and paired fangs follow the authoritative attacking head pivot.
	for side in [-1,1]:
		plate(head,Vector3(side*0.065,0.065,-0.24),Vector3(0.07,0.045,0.14),ivory).rotation.z = -side*0.4
		if thorn:
			for index in range(4):
				plate(root,Vector3(side*0.08,0.69,-0.14+index*0.15),Vector3(0.14,0.07,0.16),Art.material("thorn_carapace",Color("4e5143"))).rotation.z = side*0.25
		else:
			for index in range(3):
				plate(root,Vector3(side*0.1,0.67,-0.4+index*0.035),Vector3(0.045,0.08,0.04),metal())
	band(root,Vector3(0,0.63,-0.36),0.14,Art.material("hound_collar",Color("483a30")),0.025).rotation.x = PI/3
	finish(root,"thorn" if thorn else "hound")
