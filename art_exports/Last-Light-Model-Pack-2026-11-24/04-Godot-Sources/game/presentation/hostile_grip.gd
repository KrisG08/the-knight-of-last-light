extends RefCounted
## Render-only two-bone arm deformation. Combat weapon pivots are never moved.
static func configure(rig: Dictionary, pivot: Node3D, id: String) -> void:
	if not rig.has("right_arm"): return
	var arm: Node3D=rig.right_arm
	var instance:=arm.get_child(0) as MeshInstance3D
	if instance==null or not instance.material_override is ShaderMaterial: return
	var bounds:=instance.mesh.get_aabb()
	var wrist:=Vector3.ZERO; var count:=0
	for surface in range(instance.mesh.get_surface_count()):
		var vertices: PackedVector3Array=instance.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
		for point in vertices:
			var t: float=(point.y-bounds.position.y)/maxf(0.01,bounds.size.y)
			if t>=0.08 and t<=0.22: wrist+=point; count+=1
	if count==0: return
	wrist/=count
	var palm_world:=arm.to_global(wrist)
	var shoulder: Vector3=arm.position+pivot.position
	# The authored body part can itself be scaled (the smaller shade variant).
	# Attach beside it under MeshyBody to avoid applying that scale a second time.
	arm.reparent(rig.body.get_parent(),false); arm.position=shoulder
	var material:=instance.material_override.duplicate() as ShaderMaterial
	instance.material_override=material
	var elbow:=wrist*0.52+Vector3(0,0,0.025)
	rig.grip_arm=arm; rig.grip_material=material
	rig.rest_wrist=wrist; rig.rest_elbow=elbow
	rig.grip_lengths=Vector2(elbow.length(),(wrist-elbow).length())
	var visual: Node3D=rig.weapon_visual
	visual.rotation.x=rig.rest_weapon_angle
	rig.rest_weapon_offset=pivot.to_local(palm_world)-visual.basis*rig.grip_local
	visual.position=rig.rest_weapon_offset
	material.set_shader_parameter("grip_rest_elbow",elbow)

static func update(rig: Dictionary, alive: bool, active: bool, delta: float) -> void:
	if not rig.has("weapon_visual"): return
	var visual: Node3D=rig.weapon_visual
	var weight:=minf(1,delta*16)
	visual.rotation.x=lerpf(visual.rotation.x,0.0 if active else rig.rest_weapon_angle,weight)
	visual.position=visual.position.lerp(Vector3.ZERO if active else rig.get("rest_weapon_offset",Vector3.ZERO),weight)
	if not rig.has("grip_material"): return
	var material: ShaderMaterial=rig.grip_material
	material.set_shader_parameter("grip_enabled",alive)
	if not alive: return
	var arm: Node3D=rig.grip_arm
	var target: Vector3=arm.to_local(visual.to_global(rig.grip_local))
	var lengths: Vector2=rig.grip_lengths
	var distance:=clampf(target.length(),absf(lengths.x-lengths.y)+0.005,lengths.x+lengths.y-0.005)
	var axis:=target.normalized()
	var along: float=(lengths.x*lengths.x-lengths.y*lengths.y+distance*distance)/(2*distance)
	var side:=Vector3.BACK-axis*Vector3.BACK.dot(axis)
	if side.length_squared()<0.001: side=Vector3.RIGHT
	var elbow: Vector3=axis*along+side.normalized()*sqrt(maxf(0,lengths.x*lengths.x-along*along))
	var wrist: Vector3=axis*distance
	material.set_shader_parameter("grip_upper",Basis(Quaternion(rig.rest_elbow.normalized(),elbow.normalized())))
	material.set_shader_parameter("grip_fore",Basis(Quaternion((rig.rest_wrist-rig.rest_elbow).normalized(),(wrist-elbow).normalized())))
	material.set_shader_parameter("grip_elbow",elbow)
