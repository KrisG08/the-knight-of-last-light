extends RefCounted
## Presentation-only arms and torso. The combat pivot keeps sole attack authority.
static var skins: Dictionary = {}
var actor: CharacterBody3D
var model: Dictionary
var legs: Skeleton3D
var chest: Node3D
var arms: Array[Dictionary] = []
var clock := 0.0
var weight := 0.0
var run_weight := 0.0
var torso_rest := Vector3(0,1.12,0)

func setup(knight: CharacterBody3D, rig: Dictionary, leg_skeleton: Skeleton3D) -> void:
	actor = knight
	model = rig
	legs = leg_skeleton
	chest = Node3D.new()
	chest.name = "GaitChest"
	var body: Node3D = model.body
	var children := body.get_children()
	body.add_child(chest)
	chest.position = torso_rest
	for child: Node3D in children: child.reparent(chest,true)
	for side in [-1,1]:
		var anchor: Node3D = model.left_arm if side<0 else model.right_arm
		var source: MeshInstance3D = anchor.get_child(0)
		var skeleton := Skeleton3D.new()
		skeleton.name = "ArmSkeleton"
		anchor.add_child(skeleton)
		var origins: Array[Vector3] = [Vector3.ZERO,Vector3(side*0.055,-0.33,0),Vector3(side*0.08,-0.61,-0.025)]
		var skin := Skin.new()
		for index in range(3):
			skeleton.add_bone(["shoulder","elbow","wrist"][index])
			skeleton.set_bone_parent(index,index-1)
			var local := origins[index]-(origins[index-1] if index>0 else Vector3.ZERO)
			skeleton.set_bone_rest(index,Transform3D(Basis.IDENTITY,local))
			skeleton.set_bone_pose_position(index,local)
			skin.add_bind(index,Transform3D(Basis.IDENTITY,origins[index]).affine_inverse())
		var visual := MeshInstance3D.new()
		visual.name = "SkinnedArm"
		visual.mesh = skinned(source.mesh)
		visual.skin = skin
		visual.skeleton = NodePath("../ArmSkeleton")
		anchor.add_child(visual)
		source.hide()
		var equipment: Node3D = model.shield if side<0 else model.sword
		equipment.reparent(anchor,true)
		arms.append({"anchor":anchor,"skeleton":skeleton,"skin_mesh":visual,"equipment":equipment,"equipment_rest":equipment.transform,"wrist_inverse":Transform3D(Basis.IDENTITY,origins[2]).affine_inverse(),"anchor_rest":anchor.position,"side":side})

func skinned(source: Mesh) -> ArrayMesh:
	var key := source.get_instance_id()
	if skins.has(key): return skins[key]
	var result := ArrayMesh.new()
	for surface in range(source.get_surface_count()):
		var arrays := source.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bones := PackedInt32Array()
		var weights := PackedFloat32Array()
		var uvs := PackedVector2Array()
		for vertex in vertices:
			var shoulder := smoothstep(-0.40,-0.21,vertex.y)
			var wrist := 1.0-smoothstep(-0.65,-0.52,vertex.y)
			var elbow := maxf(0,1-shoulder-wrist)
			bones.append_array(PackedInt32Array([0,1,2,0]))
			weights.append_array(PackedFloat32Array([shoulder,elbow,wrist,0]))
			uvs.append(Vector2(vertex.x,vertex.y))
		arrays[Mesh.ARRAY_BONES] = bones
		arrays[Mesh.ARRAY_WEIGHTS] = weights
		if arrays[Mesh.ARRAY_TEX_UV]==null: arrays[Mesh.ARRAY_TEX_UV] = uvs
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		result.surface_set_material(surface,source.surface_get_material(surface))
	skins[key] = result
	return result

func advance(delta: float, moving: bool, running: bool) -> void:
	if actor.enabled and actor.health>0: clock += delta
	var locomotion: bool = actor.combat.state=="locomotion" and actor.health>0
	var blend := 1.0-exp(-delta*12.0)
	weight = lerpf(weight,1.0 if moving and locomotion else 0.0,blend)
	run_weight = lerpf(run_weight,1.0 if running and locomotion else 0.0,blend)
	var left_hip := legs.get_bone_pose_rotation(0).get_euler().x
	var right_hip := legs.get_bone_pose_rotation(3).get_euler().x
	var twist := (left_hip-right_hip)*0.045*weight
	var lean := -0.045*weight-0.065*run_weight
	var attack_weight := 0.0
	if actor.combat.state == "attack":
		var attack: Dictionary = actor.combat.Attacks.resolve(actor.combat.heavy,actor.combat.combo_step)
		attack_weight = sin(clampf(actor.combat.elapsed / (attack.windup+attack.active),0,1)*PI)
		twist = actor.sword_pivot.rotation.y * 0.14
		lean = -attack_weight * (0.14 if actor.combat.heavy else 0.07)
	chest.rotation = chest.rotation.lerp(Vector3(lean,twist,-twist*0.24),blend)
	chest.position.y = torso_rest.y+sin(clock*1.8)*0.003+absf(left_hip-right_hip)*0.008*weight
	for index in range(arms.size()):
		var arm: Dictionary = arms[index]
		var skeleton: Skeleton3D = arm.skeleton
		var side: int = arm.side
		var hip := left_hip if index==0 else right_hip
		var amplitude := 0.42 if side<0 else 0.65 # Restrained shield, freer sword arm.
		var shoulder := Vector3(-hip*(amplitude+run_weight*0.12)*weight,twist*0.4,-side*0.055*weight)
		var elbow := Vector3((0.16+run_weight*0.42+maxf(0,hip)*0.12)*weight,0,0)
		var wrist := Vector3((-0.28-run_weight*0.08)*weight if side>0 else 0,0,0)
		if actor.combat.state=="block":
			shoulder = Vector3(0.40 if side<0 else 0.08,side*0.08,0)
			elbow = Vector3(0.62 if side<0 else 0.18,0,0)
		if actor.combat.state == "attack":
			shoulder.x = -attack_weight * (0.32 if side>0 else -0.25)
			elbow.x = attack_weight * (0.35 if side>0 else 0.55)
		# Reset secondary motion during attack/heal/stagger; never write the
		# combat pivot, hit sweep, velocity, stamina, camera, or actor transform.
		for bone in range(3):
			var target := Quaternion.from_euler([shoulder,elbow,wrist][bone])
			skeleton.set_bone_pose_rotation(bone,skeleton.get_bone_pose_rotation(bone).slerp(target,blend))
		var rest: Vector3 = arm.anchor_rest
		var shoulder_world := Vector3(side*0.342,1.463,0)
		var displacement := chest.basis*(shoulder_world-torso_rest)+chest.position-shoulder_world
		if side>0: displacement = actor.sword_pivot.basis.inverse()*displacement
		arm.anchor.position = rest+displacement
		arm.equipment.transform = skeleton.get_bone_global_pose(2)*arm.wrist_inverse*arm.equipment_rest
