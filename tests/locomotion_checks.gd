extends RefCounted

static func run(knight: CharacterBody3D, check: Callable) -> void:
	if not knight.model.has("skeletal_locomotion"):
		return # Explicit legacy fallback is verified by the existing actor checks.
	var motion = knight.model.skeletal_locomotion
	var skeleton: Skeleton3D = motion.skeleton
	var valid_bind := skeleton.get_bone_count()==6
	for index in range(skeleton.get_bone_count()):
		valid_bind = valid_bind and skeleton.get_bone_global_rest(index).origin.distance_to(skeleton.get_bone_global_pose(index).origin)<0.001
	check.call(valid_bind,"Standing skin preserves all six global bind origins")
	var valid_weights := true
	var retained_uvs := true
	var retained_paint := true
	for instance in motion.find_children("*","MeshInstance3D",true,false):
		for surface in range(instance.mesh.get_surface_count()):
			var arrays: Array = instance.mesh.surface_get_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			retained_uvs = retained_uvs and arrays[Mesh.ARRAY_TEX_UV].size()==vertices.size()
			retained_paint = retained_paint and arrays[Mesh.ARRAY_COLOR]!=null and arrays[Mesh.ARRAY_TEX_UV2]!=null and arrays[Mesh.ARRAY_COLOR].size()==vertices.size() and arrays[Mesh.ARRAY_TEX_UV2].size()==vertices.size()
			valid_weights = valid_weights and weights.size()==vertices.size()*4
			for vertex in range(vertices.size()):
				var total := 0.0
				for slot in range(4): total+=weights[vertex*4+slot]
				valid_weights = valid_weights and absf(total-1.0)<0.001
	check.call(valid_weights and retained_uvs,"Every skinned vertex has normalized weights and its original texture UV")
	check.call(retained_paint,"Animated knight legs retain baked pigment and rest-space detail coordinates")
	var position_before: Vector3 = knight.position
	var stamina_before: float = knight.stamina
	motion.animation.play("jog")
	motion.animation.seek(motion.animation.get_animation("jog").length*0.8,true)
	var bend := absf(skeleton.get_bone_pose_rotation(1).get_euler().x)
	check.call(bend>0.8,"Jog clip bends the knee rather than rotating a rigid leg")
	check.call(knight.position==position_before and knight.stamina==stamina_before,"Sampling visual locomotion cannot move the collision body or spend stamina")
	motion.animation.play("stand")
	motion.animation.advance(0)
	if motion.upper_body==null: return
	var upper = motion.upper_body
	var enabled_before: bool = knight.enabled
	var combat_before: String = knight.combat.state
	var pivot_before: Vector3 = knight.sword_pivot.rotation
	knight.enabled = true
	knight.combat.state = "locomotion"
	motion.animation.play("jog")
	motion.animation.seek(motion.animation.get_animation("jog").length*0.1,true)
	for frame in range(40): upper.advance(1.0/60,true,false)
	var opposed := true
	var normalized := true
	for side in range(2):
		var arm: Dictionary = upper.arms[side]
		var shoulder: float = arm.skeleton.get_bone_pose_rotation(0).get_euler().x
		var hip: float = skeleton.get_bone_pose_rotation(side*3).get_euler().x
		opposed = opposed and shoulder*hip<0 and absf(shoulder)>0.05
		for surface in range(arm.skin_mesh.mesh.get_surface_count()):
			var arrays: Array = arm.skin_mesh.mesh.surface_get_arrays(surface)
			var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
			for index in range(0,weights.size(),4):
				normalized = normalized and absf(weights[index]+weights[index+1]+weights[index+2]+weights[index+3]-1)<0.001
	check.call(opposed,"Both shoulders swing opposite their corresponding leg")
	check.call(normalized,"Arm shoulder/elbow/wrist skin weights are normalized")
	var painted_arms := true
	for arm: Dictionary in upper.arms:
		for surface in range(arm.skin_mesh.mesh.get_surface_count()):
			var arrays: Array = arm.skin_mesh.mesh.surface_get_arrays(surface)
			painted_arms = painted_arms and arrays[Mesh.ARRAY_COLOR].size()==arrays[Mesh.ARRAY_VERTEX].size() and arrays[Mesh.ARRAY_TEX_UV2].size()==arrays[Mesh.ARRAY_VERTEX].size()
	check.call(painted_arms,"Animated arms retain their painted materials rather than reverting to white")
	var walk_bend: float = upper.arms[1].skeleton.get_bone_pose_rotation(1).get_euler().x
	for frame in range(40): upper.advance(1.0/60,true,true)
	check.call(upper.arms[1].skeleton.get_bone_pose_rotation(1).get_euler().x>walk_bend+0.25,"Running bends the elbows more than walking")
	check.call(not upper.arms[1].equipment.transform.is_equal_approx(upper.arms[1].equipment_rest),"Sword follows animated wrist instead of floating beside the hand")
	knight.combat.state = "block"
	for frame in range(40): upper.advance(1.0/60,true,false)
	check.call(upper.arms[0].skeleton.get_bone_pose_rotation(1).get_euler().x>0.5,"Guard raises the shield arm rather than retaining a walk swing")
	knight.combat.state = "attack"
	knight.sword_pivot.rotation.y = 0.8
	for frame in range(60): upper.advance(1.0/60,false,false)
	check.call(absf(upper.arms[1].skeleton.get_bone_pose_rotation(0).get_euler().x)<0.005 and upper.arms[1].skeleton.get_bone_pose_rotation(2).get_euler().length()<0.005 and is_equal_approx(knight.sword_pivot.rotation.y,0.8),"Attack takes shoulder/wrist priority without locomotion rewriting the combat pivot")
	check.call(knight.position==position_before and knight.stamina==stamina_before,"Upper body animation cannot move physics or change sprint stamina")
	check.call(motion.pose(0).distance_to(motion.pose(1))<0.001,"Leg motion closes continuously at the gait loop boundary")
	var dodge_before: float = knight.dodge_left
	knight.combat.state = "locomotion"
	knight.dodge_left = 0.4
	motion.animation.advance(0.10)
	for frame in range(30): upper.advance(1.0/60,true,false)
	check.call(upper.weight>0.95 and knight.position==position_before and knight.stamina==stamina_before,"Dash keeps arm swing without modifying physics or stamina")
	knight.dodge_left = dodge_before
	knight.enabled = enabled_before
	knight.combat.state = combat_before
	knight.sword_pivot.rotation = pivot_before
	for frame in range(40): upper.advance(1.0/60,false,false)
	motion.animation.play("stand")
	motion.animation.advance(0)
