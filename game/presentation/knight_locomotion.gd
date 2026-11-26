extends Node3D

# Original in-place leg clips over a six-bone skin adapter for the credited mesh.
# Physics/camera/attacks remain owned by the knight; no root motion is applied.
var actor: CharacterBody3D
var original: Dictionary
var skeleton: Skeleton3D
var animation: AnimationPlayer
var visual_root: Node3D
var current := ""
var upper_body: RefCounted
static var skinned_meshes: Dictionary = {}
const NAMES = ["hip_L","knee_L","ankle_L","hip_R","knee_R","ankle_R"]
const TIMES = [0.0,0.2,0.5,0.65,0.8,1.0]
const POSES = [Vector3(0.72,-0.12,-0.60),Vector3(0.24,-0.08,-0.16),Vector3(-0.72,-0.10,0.82),Vector3(-0.46,-1.15,1.0),Vector3(0.35,-1.1,0.75),Vector3(0.72,-0.12,-0.60)]

func setup(knight: CharacterBody3D, model: Dictionary) -> void:
	actor = knight
	original = model
	name = "KnightLocomotion"

func _ready() -> void:
	visual_root = get_parent()
	skeleton = Skeleton3D.new()
	skeleton.name = "LegSkeleton"
	add_child(skeleton)
	var skin := Skin.new()
	var origins: Array[Vector3] = []
	for side in [-1,1]:
		origins.append_array([Vector3(side*0.17,0.9,0),Vector3(side*0.17,0.48,0),Vector3(side*0.17,0.14,-0.025)])
	for index in range(6):
		skeleton.add_bone(NAMES[index])
		var parent: int = index-1 if index%3!=0 else -1
		skeleton.set_bone_parent(index,parent)
		var local: Vector3 = origins[index]-(origins[parent] if parent>=0 else Vector3.ZERO)
		skeleton.set_bone_rest(index,Transform3D(Basis.IDENTITY,local))
		# Godot 4 pose translations are parent-relative, not rest-relative offsets.
		skeleton.set_bone_pose_position(index,local)
		skin.add_bind(index,Transform3D(Basis.IDENTITY,origins[index]).affine_inverse())
	var source = preload("res://game/presentation/scanned_knight.gd")
	if not original.has("leg_meshes"): source.prepare()
	for side in range(2):
		var leg_source: Mesh = original.leg_meshes[side].mesh if original.has("leg_meshes") else (source.parts.left_leg if side==0 else source.parts.right_leg)
		var mesh := skinned(leg_source,origins[side*3],side*3)
		var instance := MeshInstance3D.new()
		instance.name = "SkinnedLegLeft" if side==0 else "SkinnedLegRight"
		instance.mesh = mesh
		instance.skin = skin
		instance.skeleton = NodePath("../LegSkeleton")
		add_child(instance)
		original.legs[side].hide()
	animation = AnimationPlayer.new()
	animation.root_node = NodePath("..")
	add_child(animation)
	var library := AnimationLibrary.new()
	library.add_animation("jog",clip(0.72,0.9))
	library.add_animation("run",clip(0.62,1.12))
	library.add_animation("stand",standing())
	animation.add_animation_library("",library)
	animation.play("stand")
	current = "stand"
	if original.has("left_arm") and original.has("sword"):
		upper_body = preload("res://game/presentation/knight_upper_body.gd").new()
		upper_body.setup(actor,original,skeleton)

func skinned(source: Mesh, origin: Vector3, first_bone: int) -> ArrayMesh:
	var cache_key := str(source.get_instance_id())+"/"+str(first_bone)
	if skinned_meshes.has(cache_key): return skinned_meshes[cache_key]
	var result := ArrayMesh.new()
	for surface in range(source.get_surface_count()):
		var arrays := source.surface_get_arrays(surface)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var bones := PackedInt32Array()
		var weights := PackedFloat32Array()
		for index in range(vertices.size()):
			vertices[index] += origin
			var y: float = vertices[index].y
			var hip := smoothstep(0.41,0.57,y)
			var ankle := 1.0-smoothstep(0.07,0.20,y)
			var knee := maxf(0,1.0-hip-ankle)
			bones.append_array(PackedInt32Array([first_bone,first_bone+1,first_bone+2,0]))
			weights.append_array(PackedFloat32Array([hip,knee,ankle,0]))
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_BONES] = bones
		arrays[Mesh.ARRAY_WEIGHTS] = weights
		if arrays[Mesh.ARRAY_TEX_UV]==null:
			var uv := PackedVector2Array()
			for vertex in vertices: uv.append(Vector2(vertex.x,vertex.y))
			arrays[Mesh.ARRAY_TEX_UV] = uv
		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		var material: Material = source.surface_get_material(surface)
		if material is ShaderMaterial:
			material = material.duplicate()
		result.surface_set_material(surface,material)
	skinned_meshes[cache_key] = result
	return result

func clip(duration: float, scale: float) -> Animation:
	var result := Animation.new()
	result.length = duration
	result.loop_mode = Animation.LOOP_LINEAR
	for side in range(2):
		for joint in range(3):
			var track := result.add_track(Animation.TYPE_ROTATION_3D)
			result.track_set_path(track,NodePath("LegSkeleton:"+NAMES[side*3+joint]))
			for index in range(33):
				var time := float(index)/32
				var phase: float = fmod(time+side*0.5,1.0)
				var angles := pose(phase)*scale
				result.track_insert_key(track,time*duration,Quaternion(Vector3.RIGHT,angles[joint]))
	var sound := result.add_track(Animation.TYPE_METHOD)
	result.track_set_path(sound,NodePath("."))
	for time in [0.0,duration*0.5]:
		result.track_insert_key(sound,time,{"method":"footfall","args":[]})
	return result

func pose(phase: float) -> Vector3:
	for index in range(1,TIMES.size()):
		if phase<=TIMES[index]:
			var t := inverse_lerp(TIMES[index-1],TIMES[index],phase)
			var a: Vector3 = POSES[posmod(index-2,5)]
			var b: Vector3 = POSES[index-1]
			var c: Vector3 = POSES[index]
			var d: Vector3 = POSES[(index+1)%5]
			return (b*2+(c-a)*t+(a*2-b*5+c*4-d)*t*t+(-a+b*3-c*3+d)*t*t*t)*0.5
	return POSES[0]

func standing() -> Animation:
	var result := Animation.new()
	result.length = 0.2
	for index in range(6):
		var track := result.add_track(Animation.TYPE_ROTATION_3D)
		result.track_set_path(track,NodePath("LegSkeleton:"+NAMES[index]))
		result.track_insert_key(track,0,Quaternion.IDENTITY)
	return result

func footfall() -> void:
	if actor.enabled and actor.health>0 and actor.is_on_floor() and actor.combat.state=="locomotion" and Vector2(actor.velocity.x,actor.velocity.z).length()>1:
		actor.sounds.cue("step")

func _process(delta: float) -> void:
	var speed := Vector2(actor.velocity.x,actor.velocity.z).length()
	var dashing: bool = actor.dodge_left>0
	var moving: bool = actor.enabled and actor.health>0 and actor.is_on_floor() and actor.combat.state in ["locomotion","block"] and speed>0.5
	# Space uses the walking cycle at dash speed, preserving the phase when the
	# player was already walking rather than switching to the standing pose.
	var desired := ("jog" if dashing else ("run" if speed>5.2 else "jog")) if moving else "stand"
	if desired!=current:
		animation.play(desired,0.12)
		current = desired
	animation.speed_scale = clampf(speed/(4.8 if desired=="run" else 3.7),0.4,2.4 if dashing else 1.45) if moving else 1.0
	var drop := 0.025
	if moving:
		var left: float = skeleton.get_bone_global_pose(2).origin.y-0.14
		var right: float = skeleton.get_bone_global_pose(5).origin.y-0.14
		drop += clampf(-minf(left,right),-0.14,0.02)
	visual_root.position.y = lerpf(visual_root.position.y,drop,minf(1,delta*18))
	if upper_body!=null: upper_body.advance(delta,moving,desired=="run")
