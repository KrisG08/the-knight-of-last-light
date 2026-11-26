extends RefCounted
## Authored regional height profiles. Applied once while staging a region.
## The same surface drives collision, navigation, arrivals and actor placement.
const Art = preload("res://game/presentation/art_kit.gd")
const Creature = preload("res://game/presentation/ambient_creature.gd")
const PROFILES = {
	"region.village": [[45.0,0.0],[18.0,0.0],[-5.0,1.5],[-45.0,1.5]],
	"region.blackwood": [[22.0,1.5],[-8.0,1.5],[-25.0,4.5],[-42.0,4.5],[-60.0,7.0],[-78.0,7.0]],
	"region.order": [[14.0,7.0],[-6.0,7.0],[-25.0,11.0],[-45.0,11.0],[-62.0,13.0],[-80.0,13.0]],
	"region.peaks": [[14.0,13.0],[-5.0,13.0],[-23.0,19.0],[-36.0,19.0],[-55.0,26.0],[-80.0,26.0]],
	"region.citadel": [[62.0,26.0],[-5.0,26.0],[-17.0,32.0],[-23.0,32.0],[-35.0,38.0],[-41.0,38.0],[-53.0,44.0],[-96.0,44.0]],
	"region.grove": [[20.0,4.5],[-20.0,4.5]],
	"region.sanctum": [[20.0,11.0],[-20.0,11.0]],
	"region.forge": [[20.0,26.0],[-20.0,26.0]],
	"region.ritual": [[20.0,44.0],[-20.0,44.0]],
}

static func height(id: String, _x: float, z: float) -> float:
	if not PROFILES.has(id): return 0.0
	var profile: Array = PROFILES[id]
	for index in range(1,profile.size()):
		var a: Array = profile[index-1]
		var b: Array = profile[index]
		if z >= b[0]:
			return lerpf(a[1],b[1],clampf((a[0]-z)/(a[0]-b[0]),0.0,1.0))
	return profile.back()[1]

static func apply(region: Node3D) -> void:
	if not PROFILES.has(region.region_id): return
	for child in region.get_children():
		if child is Node3D: lift(region,child,Transform3D.IDENTITY,0.0)
	for key in region.points:
		var at: Vector3 = region.points[key]
		at.y += height(region.region_id,at.x,at.z)
		region.points[key] = at
	if region.region_id == "region.citadel": stairs(region)
	region.set_meta("authored_elevation",true)

static func lift(region: Node3D, node: Node3D, parent_frame: Transform3D, inherited: float) -> void:
	var frame := parent_frame*node.transform
	if node.has_meta("landscape_horizon"): return
	var rise := height(region.region_id,frame.origin.x,frame.origin.z)
	if node.get_script() == Creature:
		node.position += parent_frame.basis.inverse()*Vector3.UP*(rise-inherited)
		node.stroll_origin = node.position
		node.terrain_height = region.height_at
		return
	if node is NavigationRegion3D:
		var nav: NavigationMesh = node.navigation_mesh.duplicate()
		var vertices := nav.vertices
		for index in range(vertices.size()): vertices[index].y += height(region.region_id,vertices[index].x,vertices[index].z)
		nav.vertices = vertices
		node.navigation_mesh = nav
		return
	# Floors are subdivided before bending so collision follows every terrace.
	if node is StaticBody3D and node.get_child_count()>0:
		var visual = node.get_child(0)
		if visual is MeshInstance3D and visual.mesh is BoxMesh:
			var size: Vector3 = visual.mesh.size
			if (size.y <= 1.1 and size.x >= 4 and size.z >= 8) or (size.z >= 12 and size.x <= 1.6):
				var box: BoxMesh = visual.mesh.duplicate()
				box.subdivide_depth = maxi(1,ceili(size.z)-1)
				box.subdivide_width = maxi(1,ceili(size.x/2)-1)
				var bent := bend(region,box,frame*visual.transform,0.0)
				visual.mesh = bent
				for shape in node.get_children():
					if shape is CollisionShape3D: shape.shape = bent.create_trimesh_shape()
				if region.region_id == "region.citadel" and visual.material_override is ShaderMaterial:
					visual.material_override = visual.material_override.duplicate()
					visual.material_override.set_shader_parameter("ascent_stairs",true)
				return
	# Positioned props/structures stay rigid, retaining their authored silhouette.
	if node.position.length_squared()>0.001 and not node is MeshInstance3D and not node is MultiMeshInstance3D:
		node.position += parent_frame.basis.inverse()*Vector3.UP*(rise-inherited)
		return
	if node is MultiMeshInstance3D:
		var source: MultiMesh = node.multimesh
		var batch := MultiMesh.new()
		batch.transform_format = source.transform_format
		batch.use_colors = source.use_colors
		batch.use_custom_data = source.use_custom_data
		batch.mesh = source.mesh
		batch.instance_count = source.instance_count
		for index in range(batch.instance_count):
			var instance := source.get_instance_transform(index)
			var at := frame*instance.origin
			instance.origin += frame.basis.inverse()*Vector3.UP*(height(region.region_id,at.x,at.z)-inherited)
			if node.has_meta("terrain_paving"):
				var slope: float=(height(region.region_id,at.x,at.z+0.05)-height(region.region_id,at.x,at.z-0.05))/0.1
				# Thin pavers must meet the sloping ground, not hover horizontally.
				var world_basis: Basis=frame.basis*instance.basis
				for axis in range(3): world_basis[axis].y+=slope*world_basis[axis].z
				instance.basis=frame.basis.inverse()*world_basis
				# The final ascent has authored stone treads over a collision ramp.
				# Keep loose paving beneath them instead of floating over the steps.
				if region.region_id=="region.citadel" and absf(slope)>0.1: instance.origin.y-=0.35
			batch.set_instance_transform(index,instance)
			if source.use_colors: batch.set_instance_color(index,source.get_instance_color(index))
			if source.use_custom_data: batch.set_instance_custom_data(index,source.get_instance_custom_data(index))
		node.multimesh = batch
		return
	if node is MeshInstance3D and node.mesh != null:
		node.mesh = bend(region,node.mesh,frame,inherited)
		return
	for child in node.get_children():
		if child is Node3D: lift(region,child,frame,inherited)

static func bend(region: Node3D, mesh: Mesh, frame: Transform3D, inherited: float) -> ArrayMesh:
	var result := ArrayMesh.new()
	for surface in range(mesh.get_surface_count()):
		var arrays := mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		for index in range(vertices.size()):
			var at := frame*vertices[index]
			vertices[index] += frame.basis.inverse()*Vector3.UP*(height(region.region_id,at.x,at.z)-inherited)
			# Inverse-transpose of the authored vertical shear.
			var slope := (height(region.region_id,at.x,at.z+0.05)-height(region.region_id,at.x,at.z-0.05))/0.1
			var normal := frame.basis.inverse().transposed()*normals[index]
			normal.z -= slope*normal.y
			normals[index] = (frame.basis.transposed()*normal).normalized()
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		result.surface_set_material(surface,mesh.surface_get_material(surface))
	return result

static func stairs(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "SummitStairways"
	region.add_child(root)
	var stone := Art.stone()
	for start in [-5.0,-23.0,-41.0]:
		# Visible treads over a continuous collision ramp: no jump or step snag.
		for step in range(40):
			var z: float = start-(step+0.5)*0.3
			var top := height(region.region_id,0,z)-0.075
			Art.box(root,Vector3(0,top-0.15,z),Vector3(12,0.3,0.305),stone)
		for side in [-1,1]:
			for step in range(9):
				var z: float = start-step*1.5
				var y := height(region.region_id,0,z)
				Art.cylinder(root,Vector3(side*6.3,y+0.65,z),0.18,0.14,1.3,stone,8)
				if step%4==0: Art.lantern(root,Vector3(side*6.3,y+1.4,z))
