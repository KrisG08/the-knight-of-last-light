extends RefCounted
## Authored physical beats. Root rotation, leg joints, chest and hands move together.
static func key(t: float, root: Vector3, legs: Vector3, other: Vector3, chest: Vector3, arms: Vector3) -> Dictionary:
	return {"t":t,"root":root,"left":legs,"right":other,"chest":chest,"arms":arms}
static func sample(track: Array, t: float, name: String) -> Vector3:
	for index in range(1,track.size()):
		if t<=track[index].t:
			var u: float = clampf(inverse_lerp(track[index-1].t,track[index].t,t),0,1)
			return track[index-1][name].cubic_interpolate(track[index][name],track[maxi(0,index-2)][name],track[mini(track.size()-1,index+1)][name],u)
	return track[-1][name]

static func pose(actor: Node3D, gait: Node3D, t: float, rising: bool, side: float) -> void:
	var zero := Vector3.ZERO
	var folded := Vector3(0.3,-0.65,0.35)
	var track: Array
	if rising:
		track=[key(0,Vector3(0.16,-1.43,0.1),folded,folded,Vector3(0.1,0,0),Vector3(-0.2,0.3,0.2)),
			key(1.3,Vector3(0.08,-1.1,0.15),folded,Vector3(0.5,-1.0,0.6),Vector3(0.3,0,0),Vector3(-0.9,0.8,0.45)),
			key(2.7,Vector3(-0.46,-0.32,0.1),Vector3(0.9,-1.7,0.8),Vector3(-0.3,-1.2,0.8),Vector3(0.6,0,0.08),Vector3(-0.85,0.5,0.85)),
			key(4.2,Vector3(-0.52,0,0),Vector3(0.8,-1.6,0.8),Vector3(-0.3,-1.4,1.0),Vector3(0.52,0,0),Vector3(-0.65,0.45,0.65)),
			key(5.5,Vector3(-0.16,0,0),Vector3(0.28,-0.5,0.3),Vector3(-0.05,-0.4,0.3),Vector3(0.2,0,0),Vector3(-0.2,0.2,0.3)),
			key(6.8,zero,zero,zero,zero,Vector3(0,0,0.15)),key(8,zero,zero,zero,Vector3(0.01,0.06,0),Vector3(0,0,0.15))]
	else:
		track=[key(0,zero,zero,zero,zero,zero),
			key(0.35,Vector3(0,0,-0.08),Vector3(0.25,-0.35,0.12),Vector3(-0.15,-0.2,0.15),Vector3(-0.16,0,0),Vector3(-0.8,-0.65,0.5)),
			key(0.95,Vector3(-0.4,0,0.18),Vector3(0.7,-1.4,0.7),Vector3(-0.25,-0.9,0.6),Vector3(0.35,0,0.1),Vector3(-0.6,-0.7,0.8)),
			key(1.55,Vector3(-0.3,side*0.7,0.2),Vector3(0.7,-1.2,0.6),folded,Vector3(0.2,0,0),Vector3(-0.7,-0.4,0.6)),
			key(2.25,Vector3(0.2,side*1.48,0.1),folded,folded,Vector3(0.1,0,0),Vector3(-0.2,0.3,0.2)),
			key(3.1,Vector3(0.16,side*1.43,0.1),folded,folded,Vector3(0.1,0,0),Vector3(-0.2,0.3,0.2))]
	var root_pose := sample(track,t,"root")
	actor.position.y+=root_pose.x
	actor.rotation.z=root_pose.y; actor.rotation.x=root_pose.z
	var upper = gait.upper_body
	upper.chest.rotation=sample(track,t,"chest")
	for leg in range(2):
		var angles := sample(track,t,"left" if leg==0 else "right")
		for joint in range(3): gait.skeleton.set_bone_pose_rotation(leg*3+joint,Quaternion(Vector3.RIGHT,angles[joint]))
	var arms := sample(track,t,"arms")
	for index in range(upper.arms.size()):
		var arm: Dictionary = upper.arms[index]
		var shoulder := Vector3(arms.x if index==0 else arms.y,0,-arm.side*0.1)
		arm.skeleton.set_bone_pose_rotation(0,Quaternion.from_euler(shoulder))
		arm.skeleton.set_bone_pose_rotation(1,Quaternion(Vector3.RIGHT,arms.z))
		arm.equipment.transform=arm.skeleton.get_bone_global_pose(2)*arm.wrist_inverse*arm.equipment_rest
