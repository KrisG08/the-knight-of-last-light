extends RefCounted
## Bounded authored poses: stumble, knee contact, accelerated fall, impact, settle.
static func blend(a: Vector3,b: Vector3,t: float) -> Vector3:
	return a.lerp(b,smoothstep(0,1,clampf(t,0,1)))
static func fall(actor: Node3D,gait: Node3D,age: float,side: float,rest_roll: float=1.58) -> void:
	var stumble:=smoothstep(0,.42,age)
	var knee:=smoothstep(.35,.95,age)
	# Squared angular progress accelerates into the ground instead of constant speed.
	var gravity:=pow(clampf((age-.85)/.86,0,1),2)
	var settle:=smoothstep(1.72,2.25,age)
	actor.rotation.z=side*(gravity*1.62-settle*(1.62-rest_roll))
	actor.rotation.x=.10*stumble-.06*settle
	gait.upper_body.chest.rotation=Vector3(.25*knee*(1-gravity),-.06*stumble,side*.04*stumble)
	for leg in range(2):
		var braced:=Vector3(.48,-1.13,.61) if leg==0 else Vector3(-.21,-.75,.48)
		var rest:=Vector3(.08,-.15,.07) if leg==0 else Vector3(.24,-.38,.14)
		var angles:=blend(Vector3.ZERO,braced,knee).lerp(rest,smoothstep(.5,1,gravity))
		for joint in range(3): gait.skeleton.set_bone_pose_rotation(leg*3+joint,Quaternion(Vector3.RIGHT,angles[joint]))
	for index in range(2):
		var arm: Dictionary=gait.upper_body.arms[index]
		var reach: float=sin(clampf(age/1.75,0,1)*PI)
		var shoulder:=Vector3(-.42*reach,0,-arm.side*.16*reach).lerp(Vector3(.7,0,-arm.side*.36),settle)
		arm.skeleton.set_bone_pose_rotation(0,Quaternion.from_euler(shoulder))
		arm.skeleton.set_bone_pose_rotation(1,Quaternion(Vector3.RIGHT,.15+.48*reach+.16*settle))

static func recover(actor: Node3D,gait: Node3D,t: float) -> void:
	# Reverse the same contact pose, then pause on a knee before extending the legs.
	fall(actor,gait,2.25*(1-smoothstep(.7,7.5,t)),1)
	gait.upper_body.chest.rotation.y+=sin(t*.9)*.045*smoothstep(7.0,9.0,t)
