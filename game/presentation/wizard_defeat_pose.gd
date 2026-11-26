extends RefCounted
## Temporary leg skin for kneeling; original imported geometry is restored afterward.
var limbs: Array[Dictionary]=[]
func setup(visual: Node3D) -> void:
	for name_value in ["left_leg","right_leg"]:
		var anchor:=visual.get_node_or_null(name_value) as Node3D
		if anchor==null: continue
		var source:=anchor.get_child(0) as MeshInstance3D
		if source==null: continue
		var skeleton:=Skeleton3D.new(); skeleton.name="DefeatLegSkin"; anchor.add_child(skeleton)
		var origins: Array[Vector3]=[Vector3.ZERO,Vector3(0,-0.66,0),Vector3(0,-1.16,0)]
		var skin:=Skin.new()
		for index in range(3):
			skeleton.add_bone(["hip","knee","ankle"][index]); skeleton.set_bone_parent(index,index-1)
			var local:=origins[index]-(origins[index-1] if index>0 else Vector3.ZERO)
			skeleton.set_bone_rest(index,Transform3D(Basis.IDENTITY,local))
			skeleton.set_bone_pose_position(index,local)
			skin.add_bind(index,Transform3D(Basis.IDENTITY,origins[index]).affine_inverse())
		var mesh:=ArrayMesh.new()
		for surface in range(source.mesh.get_surface_count()):
			var arrays:=source.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
			var bones:=PackedInt32Array(); var weights:=PackedFloat32Array()
			for vertex in vertices:
				var hip:=smoothstep(-0.76,-0.52,vertex.y)
				var foot:=1-smoothstep(-1.18,-0.98,vertex.y)
				bones.append_array(PackedInt32Array([0,1,2,0]))
				weights.append_array(PackedFloat32Array([hip,maxf(0,1-hip-foot),foot,0]))
			arrays[Mesh.ARRAY_BONES]=bones; arrays[Mesh.ARRAY_WEIGHTS]=weights
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
			mesh.surface_set_material(surface,source.mesh.surface_get_material(surface))
		var replacement:=MeshInstance3D.new(); replacement.mesh=mesh; replacement.skin=skin
		replacement.material_override=source.material_override; replacement.skeleton=NodePath("../DefeatLegSkin")
		anchor.add_child(replacement)
		limbs.append({"source":source,"visible":source.visible,"skeleton":skeleton,"replacement":replacement,"rotation":anchor.rotation,"anchor":anchor})
		source.hide(); anchor.rotation=Vector3.ZERO
func advance(kneel: float, collapse: float) -> void:
	var weight:=kneel*(1-collapse*0.75)
	for limb in limbs:
		limb.skeleton.set_bone_pose_rotation(0,Quaternion(Vector3.RIGHT,-0.7*weight))
		limb.skeleton.set_bone_pose_rotation(1,Quaternion(Vector3.RIGHT,1.8*weight))
		limb.skeleton.set_bone_pose_rotation(2,Quaternion(Vector3.RIGHT,-0.3*weight))
func restore() -> void:
	for limb in limbs:
		if not is_instance_valid(limb.source): continue
		limb.source.visible=limb.visible; limb.anchor.rotation=limb.rotation
		limb.replacement.queue_free(); limb.skeleton.queue_free()
	limbs.clear()
