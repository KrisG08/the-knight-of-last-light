extends RefCounted

static var scenes: Dictionary = {}
static var meshes: Dictionary = {}
static var ground_material: StandardMaterial3D

static func forest_pine_mesh(source: Mesh, canopy_budget: int = 0) -> ArrayMesh:
	# Use the first imported simplification as the forest base. Keep useful later
	# LODs, excluding needle-collapse levels that turn a canopy into a few triangles.
	var result := ArrayMesh.new()
	for surface in range(source.get_surface_count()):
		var arrays := source.surface_get_arrays(surface)
		var data := RenderingServer.mesh_get_surface(source.get_rid(),surface)
		var levels: Array = data.get("lods",[])
		var lods: Dictionary = {}
		if surface > 0 and not levels.is_empty():
			var chosen := 0
			if canopy_budget>0:
				var stride := 4 if arrays[Mesh.ARRAY_VERTEX].size()>65536 else 2
				for index in range(levels.size()):
					var triangles := int(levels[index].index_data.size()/stride/3)
					if triangles>=2000 and triangles<=canopy_budget:
						chosen = index
						break
			var bytes: PackedByteArray = levels[chosen].index_data
			var indices := PackedInt32Array()
			if arrays[Mesh.ARRAY_VERTEX].size()>65536:
				indices = bytes.to_int32_array()
			else:
				for index in range(bytes.size()/2):
					indices.append(bytes.decode_u16(index*2))
			arrays[Mesh.ARRAY_INDEX] = indices
			for level in levels.slice(chosen+1):
				var smaller: PackedByteArray = level.index_data
				if smaller.size()>=bytes.size()*0.1:
					lods[level.edge_length] = smaller.to_int32_array()
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays,[],lods)
		var material := source.surface_get_material(surface).duplicate() as StandardMaterial3D
		if surface > 0:
			# Keep needle cards opaque where covered, rather than noisy alpha blending.
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			material.alpha_scissor_threshold = 0.35
			material.alpha_antialiasing_mode = BaseMaterial3D.ALPHA_ANTIALIASING_ALPHA_TO_COVERAGE
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
		result.surface_set_material(surface,material)
	return result

static func scene(id: String) -> PackedScene:
	if not scenes.has(id):
		scenes[id] = load("res://assets/vendor/polyhaven/"+id+"/"+id+".gltf")
	return scenes[id]

static func place_mesh(root: Node3D, id: String, name: String, at: Vector3, size: Vector3, yaw: float = 0, canopy_budget: int = 0) -> void:
	# Separate catalog prevents later-region simplification changing approved trees
	# already used by the village/starting road.
	var catalog_id := id+("@"+str(canopy_budget) if canopy_budget>0 else "")
	if not meshes.has(catalog_id):
		var source := scene(id).instantiate()
		var catalog: Dictionary = {}
		for mesh in source.find_children("*","MeshInstance3D",true,false):
			catalog[String(mesh.name)] = forest_pine_mesh(mesh.mesh,canopy_budget) if id == "pine_sapling_small" else mesh.mesh
		meshes[catalog_id] = catalog
		source.free()
	if not meshes[catalog_id].has(name):
		push_error("Missing verified model part: "+name)
		return
	var wrapper := Node3D.new()
	wrapper.position = at
	wrapper.rotation.y = yaw
	wrapper.scale = size
	root.add_child(wrapper)
	var node := MeshInstance3D.new()
	node.mesh = meshes[catalog_id][name]
	var bounds := node.mesh.get_aabb()
	node.position = -Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)
	node.visibility_range_end = 95
	if id == "pine_sapling_small":
		node.lod_bias = 0.5
	wrapper.add_child(node)

static func ground() -> StandardMaterial3D:
	if ground_material == null:
		ground_material = StandardMaterial3D.new()
		ground_material.albedo_color = Color(0.32,0.34,0.32)
		ground_material.albedo_texture = load("res://assets/vendor/polyhaven/forest_ground_04/Diffuse.jpg")
		ground_material.normal_enabled = true
		ground_material.normal_texture = load("res://assets/vendor/polyhaven/forest_ground_04/nor_gl.jpg")
		ground_material.roughness_texture = load("res://assets/vendor/polyhaven/forest_ground_04/Rough.jpg")
		ground_material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		ground_material.uv1_triplanar = true
		ground_material.uv1_scale = Vector3.ONE*0.3
		ground_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return ground_material

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "PhotogrammetryDressing"
	region.add_child(root)
	if region.region_id in ["region.refuge","region.village","region.blackwood","region.peaks"]:
		for child in region.get_children():
			if child is StaticBody3D and child.position.y < 0 and child.get_child_count() > 0 and child.get_child(0) is MeshInstance3D:
				child.get_child(0).material_override = ground().duplicate()
	if region.region_id == "region.refuge":
		for side in [-1,1]:
			for z in [-9,9]:
				place_mesh(root,"modular_fort_01","modular_fort_01_wall_thin_straight_01",Vector3(side*19.2,0,z),Vector3(0.7,0.8,1.2))
			place_mesh(root,"modular_fort_01","modular_fort_01_tower_round",Vector3(side*26,0,-23),Vector3.ONE*0.9)
			for z in [-8,5,13]:
				place_mesh(root,"rock_moss_set_01","rock_moss_set_01_rock03",Vector3(side*12.5,-0.05,z),Vector3.ONE*1.4,z*0.2)
			place_mesh(root,"dead_tree_trunk","dead_tree_trunk",Vector3(side*14,0,10),Vector3.ONE*1.6,side*0.6)
		place_mesh(root,"modular_fort_01","modular_fort_01_wall_thin_gate_01",Vector3(0,-0.05,-18),Vector3.ONE,PI/2)
		var door := scene("large_castle_door").instantiate()
		door.position = Vector3(0,0,17.65)
		door.scale = Vector3.ONE*1.3
		root.add_child(door)
	elif region.region_id in ["region.blackwood","region.peaks","region.village"]:
		var centers := [Vector3(-25,0,-20),Vector3(26,0,-30),Vector3(-24,0,-45)]
		if region.region_id == "region.village":
			centers = [Vector3(-34,0,25),Vector3(35,0,20),Vector3(-34,0,-30)]
		for index in range(centers.size()):
			place_mesh(root,"rock_moss_set_01","rock_moss_set_01_rock0"+str(index+1),centers[index],Vector3.ONE*2,index*1.7)
			place_mesh(root,"dead_tree_trunk","dead_tree_trunk",centers[index]+Vector3(3,0,2),Vector3.ONE*2,index)
	elif region.region_id in ["region.order","region.citadel"]:
		for side in [-1,1]:
			place_mesh(root,"modular_fort_01","modular_fort_01_tower_round",Vector3(side*28,0,-58),Vector3.ONE)
