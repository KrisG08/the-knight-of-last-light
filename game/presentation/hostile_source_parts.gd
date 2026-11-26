extends RefCounted

# Static CC BY 4.0 samples; no original animation/rig is assumed. Preserve source
# UVs/materials and partition at limb seams for the existing procedural controllers.
const TURN = Basis(Vector3.UP,PI)
static var cache: Dictionary = {}

static func pivot(id: String, part: String) -> Vector3:
	if id=="strong-knight":
		if part.ends_with("leg"):
			return Vector3(-0.15 if part.begins_with("left") else 0.15,0.85,0)
		if part.ends_with("arm"):
			return Vector3(-0.34 if part.begins_with("left") else 0.34,1.45,0)
	else:
		if part=="head":
			return Vector3(0,0.72,-0.52)
		if part=="tail":
			return Vector3(0,0.54,0.5)
		if part.begins_with("front") or part.begins_with("back"):
			return Vector3(-0.1 if part.ends_with("left") else 0.1,0.52,-0.36 if part.begins_with("front") else 0.3)
	return Vector3.ZERO

static func classify(id: String, p: Vector3) -> String:
	if id=="strong-knight":
		if p.y>1.55 and absf(p.x)<0.33:
			return "head"
		if absf(p.x)>0.34 and p.y>0.85 and p.y<1.6:
			return "left_arm" if p.x<0 else "right_arm"
		if p.y<0.85:
			return "left_leg" if p.x<0 else "right_leg"
	else:
		if p.z< -0.48 and p.y>0.56:
			return "head"
		if p.z>0.5:
			return "tail"
		if p.y<0.46 and absf(p.x)>0.035:
			return ("front_" if p.z<0 else "back_")+("left" if p.x<0 else "right")
	return "body"

static func compact(arrays: Array, indices: PackedInt32Array, origin: Vector3) -> Array:
	var used: Array[int] = []
	var remap: Dictionary = {}
	var result_indices := PackedInt32Array()
	for old in indices:
		if not remap.has(old):
			remap[old] = used.size()
			used.append(old)
		result_indices.append(remap[old])
	var result := arrays.duplicate()
	for slot in range(Mesh.ARRAY_MAX):
		if slot==Mesh.ARRAY_INDEX:
			continue
		# Extra glTF UV sets arrive as packed custom channels. StandardMaterial3D
		# uses UV/UV2, retained below; these static samples have no skinning.
		if slot in [Mesh.ARRAY_CUSTOM0,Mesh.ARRAY_CUSTOM1,Mesh.ARRAY_CUSTOM2,Mesh.ARRAY_CUSTOM3,Mesh.ARRAY_BONES,Mesh.ARRAY_WEIGHTS]:
			result[slot] = null
			continue
		var data: Variant = arrays[slot]
		if data==null or data.size()==0:
			continue
		var output: Variant = data.slice(0,0)
		for old in used:
			if slot==Mesh.ARRAY_TANGENT:
				var tangent: Vector3 = TURN*Vector3(data[old*4],data[old*4+1],data[old*4+2])
				output.append_array(PackedFloat32Array([tangent.x,tangent.y,tangent.z,data[old*4+3]]))
			elif slot==Mesh.ARRAY_VERTEX:
				output.append(TURN*data[old]-origin)
			elif slot==Mesh.ARRAY_NORMAL:
				output.append(TURN*data[old])
			else:
				output.append(data[old])
		result[slot] = output
	result[Mesh.ARRAY_INDEX] = result_indices
	return result

static func prepare(id: String) -> Dictionary:
	if cache.has(id):
		return cache[id]
	var catalog: Resource = load("res://assets/models/native-parts/"+id+".res")
	cache[id] = catalog.get_meta("parts")
	return cache[id]

static func prepare_source(id: String) -> Dictionary:
	# Offline preparation and equivalence tests only; gameplay loads the catalog.
	var scene: PackedScene = load("res://assets/vendor/hostile_sources/"+id+".glb")
	var source := scene.instantiate()
	var parts: Dictionary = {}
	for node in source.find_children("*","MeshInstance3D",true,false):
		if id=="strong-knight" and (String(node.name).to_lower().contains("dagger") or String(node.name).to_lower().contains("maul")):
			continue
		for surface in range(node.mesh.get_surface_count()):
			var arrays: Array = node.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			if indices.is_empty():
				for index in range(vertices.size()):
					indices.append(index)
			var groups: Dictionary = {}
			for triangle in range(0,indices.size(),3):
				var center: Vector3 = TURN*(vertices[indices[triangle]]+vertices[indices[triangle+1]]+vertices[indices[triangle+2]])/3
				var part := classify(id,center)
				if id=="strong-knight" and String(node.mesh.surface_get_material(surface).resource_name).to_lower().contains("cloth"):
					part = "body"
				if not groups.has(part):
					groups[part] = PackedInt32Array()
				var selected: PackedInt32Array = groups[part]
				selected.append_array(PackedInt32Array([indices[triangle],indices[triangle+1],indices[triangle+2]]))
				groups[part] = selected
			for part in groups:
				if not parts.has(part):
					parts[part] = ArrayMesh.new()
				var mesh: ArrayMesh = parts[part]
				mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,compact(arrays,groups[part],pivot(id,part)))
				var material := node.mesh.surface_get_material(surface).duplicate() as StandardMaterial3D
				material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
				var final_material: Material = material
				if id=="red-fox":
					var fur := ShaderMaterial.new()
					fur.shader = preload("res://assets/materials/cursed_fur.gdshader")
					fur.set_shader_parameter("fur_texture",material.albedo_texture)
					if material.normal_texture!=null:
						fur.set_shader_parameter("fur_normal",material.normal_texture)
						fur.set_shader_parameter("has_normal",true)
					final_material = fur
				else:
					material.albedo_color = Color(0.75,0.75,0.75)
					material.roughness = maxf(material.roughness,0.55)
				mesh.surface_set_material(mesh.get_surface_count()-1,final_material)
	source.free()
	return parts
