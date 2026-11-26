extends RefCounted

# Andy Woodhead, CC BY 4.0; simplified static copy distributed by afk.ai.
# See assets/vendor/andy_woodhead/README.md. Runtime limbs are procedural adapters.
static var parts: Dictionary = {}
const CENTER = Vector3(-0.074,0,-0.472)
const TURN = Basis(Vector3.UP,PI)
const SCALE = 0.95

static func bake(mesh: Mesh, side: int = 0, pivot: Vector3 = Vector3.ZERO, bend: float = 0) -> ArrayMesh:
	var result := ArrayMesh.new()
	var rest := Basis(Vector3.BACK,bend)
	for surface in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		for index in range(vertices.size()):
			vertices[index] = TURN*(vertices[index]-CENTER)*SCALE
			if not normals.is_empty():
				normals[index] = TURN*normals[index]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
		if indices.is_empty():
			for index in range(vertices.size()):
				indices.append(index)
		var selected := PackedInt32Array()
		for triangle in range(0,indices.size(),3):
			var center_x: float = (vertices[indices[triangle]].x+vertices[indices[triangle+1]].x+vertices[indices[triangle+2]].x)/3
			if side == 0 or (side > 0 and center_x >= 0) or (side < 0 and center_x < 0):
				selected.append_array(PackedInt32Array([indices[triangle],indices[triangle+1],indices[triangle+2]]))
		for index in range(vertices.size()):
			vertices[index] = rest*(vertices[index]-pivot)
			if not normals.is_empty():
				normals[index] = rest*normals[index]
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_INDEX] = selected
		# Tangents must follow the canonical orientation as well.
		var tangents: PackedFloat32Array = arrays[Mesh.ARRAY_TANGENT]
		for index in range(0,tangents.size(),4):
			var tangent := rest*TURN*Vector3(tangents[index],tangents[index+1],tangents[index+2])
			tangents[index] = tangent.x
			tangents[index+1] = tangent.y
			tangents[index+2] = tangent.z
		arrays[Mesh.ARRAY_TANGENT] = tangents
		if selected.is_empty():
			continue
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		var material := mesh.surface_get_material(surface).duplicate() as StandardMaterial3D
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		if material.resource_name.to_lower() in ["head","arms","legs","sword"]:
			material.metallic = 0.9
			material.roughness = 0.48
		material.albedo_color = Color(0.7,0.74,0.78)
		result.surface_set_material(result.get_surface_count()-1,material)
	return result

static func prepare() -> void:
	if not parts.is_empty():
		return
	var catalog: Resource = load("res://assets/models/native-parts/crusader-knight.res")
	parts = catalog.get_meta("parts")

static func prepare_source() -> Dictionary:
	# Keep the original converter for offline regeneration and lossless QA.
	var source: Node = load("res://assets/vendor/andy_woodhead/crusader_knight.glb").instantiate()
	var prepared := {}
	var meshes := source.find_children("*","MeshInstance3D",true,false)
	# The verified source has six named material/mesh groups, in this stable order.
	prepared.head = bake(meshes[0].mesh)
	prepared.left_arm = bake(meshes[1].mesh,-1,Vector3(-0.28,1.42,0),0.45)
	prepared.right_arm = bake(meshes[1].mesh,1,Vector3(0.28,1.42,0),-0.45)
	prepared.body = bake(meshes[2].mesh)
	prepared.left_leg = bake(meshes[3].mesh,-1,Vector3(-0.17,0.9,0))
	prepared.right_leg = bake(meshes[3].mesh,1,Vector3(0.17,0.9,0))
	prepared.sword = bake(meshes[4].mesh,0,Vector3(0.28,1.42,0),-0.45)
	prepared.shield = bake(meshes[5].mesh,0,Vector3(-0.28,1.42,0),0.45)
	source.free()
	return prepared

static func add(parent: Node3D, shape: Mesh) -> void:
	var node := MeshInstance3D.new()
	node.mesh = shape
	parent.add_child(node)

static func build(root: Node3D, weapon_pivot: Node3D) -> Dictionary:
	prepare()
	weapon_pivot.position = Vector3(0.28,1.42,0)
	for id in ["head","body"]:
		add(root,parts[id])
	var left_arm := Node3D.new()
	left_arm.position = Vector3(-0.28,1.42,0)
	root.add_child(left_arm)
	add(left_arm,parts.left_arm)
	add(left_arm,parts.shield)
	add(weapon_pivot,parts.right_arm)
	add(weapon_pivot,parts.sword)
	var legs: Array[Node3D] = []
	for side in [-1,1]:
		var leg := Node3D.new()
		leg.position = Vector3(side*0.17,0.9,0)
		root.add_child(leg)
		add(leg,parts.left_leg if side < 0 else parts.right_leg)
		legs.append(leg)
	return {"legs":legs,"source":"Andy Woodhead / CC BY 4.0"}
