extends RefCounted

static var materials: Dictionary = {}

static func material(id: String, color: Color, metal: float = 0.0) -> StandardMaterial3D:
	if materials.has(id):
		return materials[id]
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metal
	result.roughness = 0.72 if metal > 0 else 0.94
	if id in ["iron","knight_steel"] and ResourceLoader.exists("res://assets/vendor/polyhaven/metal_plate/Diffuse.jpg"):
		result.albedo_texture = load("res://assets/vendor/polyhaven/metal_plate/Diffuse.jpg")
		result.normal_enabled = true
		result.normal_texture = load("res://assets/vendor/polyhaven/metal_plate/nor_gl.jpg")
		result.roughness_texture = load("res://assets/vendor/polyhaven/metal_plate/Rough.jpg")
		result.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		result.metallic_texture = load("res://assets/vendor/polyhaven/metal_plate/Metal.jpg")
		result.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		result.uv1_triplanar = true
		result.uv1_scale = Vector3.ONE*2
		result.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	materials[id] = result
	return result

static func stone() -> StandardMaterial3D:
	var result := material("stone",Color("63717b"))
	result.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	if result.albedo_texture != null and result.normal_enabled:
		return result
	if ResourceLoader.exists("res://assets/vendor/polyhaven/modular_fort_01/textures/modular_fort_01_wall_diff_2k.jpg"):
		result.albedo_texture = load("res://assets/vendor/polyhaven/modular_fort_01/textures/modular_fort_01_wall_diff_2k.jpg")
		result.normal_enabled = true
		result.normal_texture = load("res://assets/vendor/polyhaven/modular_fort_01/textures/modular_fort_01_wall_nor_gl_2k.jpg")
		var arm: Texture2D = load("res://assets/vendor/polyhaven/modular_fort_01/textures/modular_fort_01_wall_arm_2k.jpg")
		result.roughness_texture = arm
		result.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
		result.ao_enabled = true
		result.ao_texture = arm
		result.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		result.uv1_triplanar = true
		result.uv1_scale = Vector3.ONE*0.5
		return result
	if result.albedo_texture == null and ResourceLoader.exists("res://assets/materials/ruined_limestone.png"):
		result.albedo_texture = load("res://assets/materials/ruined_limestone.png")
		result.uv1_triplanar = true
		result.uv1_scale = Vector3.ONE * 0.5
	return result

static func mesh(parent: Node3D, shape: Mesh, at: Vector3, mat: Material) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = shape
	node.position = at
	node.material_override = mat
	parent.add_child(node)
	return node

static func box(parent: Node3D, at: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return mesh(parent,shape,at,mat)

static func cylinder(parent: Node3D, at: Vector3, bottom: float, top: float, height: float, mat: Material, sides: int = 12) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.bottom_radius = bottom
	shape.top_radius = top
	shape.height = height
	shape.radial_segments = sides
	return mesh(parent,shape,at,mat)

static func beam(parent: Node3D, start: Vector3, end: Vector3, radius: float, mat: Material) -> void:
	var direction := end-start
	var node := cylinder(parent,(start+end)*0.5,radius,radius*0.7,direction.length(),mat,7)
	node.quaternion = Quaternion(Vector3.UP,direction.normalized())

static func lantern(parent: Node3D, at: Vector3) -> void:
	var iron := material("iron",Color("243239"),0.75)
	var glow := material("lantern_gold_glass",Color("b99a67"))
	glow.emission_enabled = true
	glow.emission = Color("d59c50")
	glow.emission_energy_multiplier = 1.1
	box(parent,at+Vector3(0,0.07,0),Vector3(0.65,0.14,0.65),stone())
	cylinder(parent,at+Vector3(0,0.25,0),0.24,0.19,0.3,iron,8)
	box(parent,at+Vector3(0,0.65,0),Vector3(0.3,0.5,0.3),glow)
	for x in [-0.22,0.22]:
		for z in [-0.22,0.22]:
			box(parent,at+Vector3(x,0.65,z),Vector3(0.055,0.7,0.055),iron)
	cylinder(parent,at+Vector3(0,1.04,0),0.36,0.04,0.24,iron,4)
	cylinder(parent,at+Vector3(0,1.25,0),0.04,0.015,0.3,iron,8)

static func pointed_arch(parent: Node3D, at: Vector3, width: float, height: float) -> void:
	var mat := stone()
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1,1]:
		box(parent,at+Vector3(side*width*0.5,height*0.3,0),Vector3(0.55,height*0.6,0.7),mat)
		box(parent,at+Vector3(side*width*0.5,0.15,0),Vector3(0.85,0.3,1),mat)
		var previous := Vector3(side*width*0.5,height*0.6,0)
		for step in range(1,17):
			var t := float(step)/16
			var point := Vector3(side*width*0.5*(1-t),height*(0.6+0.4*sqrt(t)),0)
			var direction := (point-previous).normalized()
			var outward: Vector3 = Vector3(-direction.y,direction.x,0)*(-side)
			var a := previous+direction*0.012
			var b := point-direction*0.012
			var corners: Array[Vector3] = []
			for depth in [-0.36,0.36]:
				for vertex in [a-outward*0.22,b-outward*0.22,b+outward*0.22,a+outward*0.22]:
					corners.append(vertex+Vector3(0,0,depth))
			for face in [[0,3,2,1],[4,5,6,7],[0,1,5,4],[3,7,6,2],[0,4,7,3],[1,2,6,5]]:
				for index in [face[0],face[1],face[2],face[0],face[2],face[3]]:
					surface.add_vertex(corners[index])
			previous = point
	surface.generate_normals()
	mesh(parent,surface.commit(),at,mat)
	cylinder(parent,at+Vector3(0,height+0.4,0),0.2,0,0.8,mat,6)
