extends RefCounted
## Offline QA: evaluate the same skin binds used by the rendered mesh.
static func vertices(root: Node3D, stride: int=1) -> PackedVector3Array:
	var result:=PackedVector3Array()
	for mesh: MeshInstance3D in root.find_children("*","MeshInstance3D",true,false):
		if not mesh.is_visible_in_tree() or mesh.mesh==null: continue
		var skeleton: Skeleton3D=mesh.get_node_or_null(mesh.skeleton) as Skeleton3D if mesh.skin!=null else null
		var matrices: Array[Transform3D]=[]
		if skeleton!=null:
			skeleton.force_update_all_bone_transforms()
			for index in range(mesh.skin.get_bind_count()):
				matrices.append(skeleton.get_bone_global_pose(mesh.skin.get_bind_bone(index))*mesh.skin.get_bind_pose(index))
		for surface in range(mesh.mesh.get_surface_count()):
			var arrays:=mesh.mesh.surface_get_arrays(surface)
			var points: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
			var bones=arrays[Mesh.ARRAY_BONES]
			var weights=arrays[Mesh.ARRAY_WEIGHTS]
			for i in range(0,points.size(),stride):
				var point:=points[i]
				if skeleton!=null and bones!=null and weights!=null:
					point=Vector3.ZERO
					for influence in range(4):
						if weights[i*4+influence]>0:
							point+=(matrices[bones[i*4+influence]]*points[i])*weights[i*4+influence]
				result.append(mesh.global_transform*point)
	return result

static func bounds(points: PackedVector3Array) -> AABB:
	assert(not points.is_empty())
	var box:=AABB(points[0],Vector3.ZERO)
	for point in points: box=box.expand(point)
	return box
