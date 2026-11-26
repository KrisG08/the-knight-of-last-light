extends RefCounted
## Offline-only skin: shared rest-space vertices receive identical weights at cuts.
## The credited geometry, UVs and paint remain unchanged; gameplay rigs are untouched.
const Models=preload("res://game/presentation/meshy_models.gd")
static var prepared: Dictionary={}
static var support_clouds: Dictionary={}
static var caster_hand_image: Image
var skeleton: Skeleton3D
var visual: MeshInstance3D
var root: Node3D
var origins: Array[Vector3]=[]
var caster:=false
var model_id: String
var attachments: Array[Dictionary]=[]

func setup(parent: Node3D,id: String,rig: Dictionary) -> void:
	root=parent; caster=id=="maldrek"; model_id=id
	skeleton=Skeleton3D.new(); skeleton.name="FilmSkeleton"; parent.add_child(skeleton)
	var height: float=Models.HEIGHTS[id]
	origins=[Vector3.ZERO,Vector3(0,height*.5895,0)]
	for side in [-1,1]:
		origins.append_array([Vector3(side*.17,.9,0),Vector3(side*.17,.48,0),Vector3(side*.17,.14,-.025)])
	for side in [-1,1]:
		var shoulder:=Vector3(side*height*.18,height*.77,0)
		origins.append_array([shoulder,shoulder+Vector3(side*.04,-height*.18,0),shoulder+Vector3(side*.06,-height*.33,-.025)])
	if caster: origins.append_array([origins[10],origins[13]])
	var skin:=Skin.new()
	for bone in range(origins.size()):
		skeleton.add_bone("joint_"+str(bone))
		var owner:=0 if bone in [1,2,5] else (1 if bone in [8,11] else bone-1)
		if bone>=14: owner=0
		if bone==0: owner=-1
		skeleton.set_bone_parent(bone,owner)
		var local:=origins[bone]-(origins[owner] if owner>=0 else Vector3.ZERO)
		skeleton.set_bone_rest(bone,Transform3D(Basis.IDENTITY,local))
		skeleton.set_bone_pose_position(bone,local)
		skin.add_bind(bone,Transform3D(Basis.IDENTITY,origins[bone]).affine_inverse())
	for part in Models.definition(id).parts:
		var node: Node3D=rig[part]
		var original:=node.get_child(0)
		if original is MeshInstance3D: original.hide()
		else:
			var meshes:=original.find_children("*","MeshInstance3D",true,false)
			if not meshes.is_empty(): meshes[0].hide()
	if rig.has("skeletal_locomotion"):
		var gait: Node3D=rig.skeletal_locomotion
		for node in gait.get_children():
			if node is MeshInstance3D: node.hide()
		for arm in gait.upper_body.arms: arm.skin_mesh.hide()
	visual=MeshInstance3D.new(); visual.name="ContinuousFilmSkin"
	visual.mesh=mesh_for(id); visual.skin=skin; visual.skeleton=NodePath("../FilmSkeleton")
	visual.custom_aabb=AABB(Vector3(-4,-4,-4),Vector3(8,8,8))
	parent.add_child(visual)

func attach(node: Node3D,bone: int) -> void:
	attachments.append({"node":node,"bone":bone,"rest":root.global_transform.affine_inverse()*node.global_transform})

func apply(gait: Node3D=null,left: Vector3=Vector3.ZERO,right: Vector3=Vector3.ZERO,body: Vector3=Vector3.ZERO) -> void:
	for bone in range(origins.size()): skeleton.set_bone_pose_rotation(bone,Quaternion.IDENTITY)
	if caster:
		skeleton.set_bone_pose_rotation(1,Quaternion.from_euler(body))
		for side in range(2):
			skeleton.set_bone_pose_rotation(8+side*3,Quaternion.from_euler(left if side==0 else right))
			skeleton.set_bone_pose_rotation(9+side*3,Quaternion(Vector3.RIGHT,.22+absf(left.x if side==0 else right.x)*.30))
		skeleton.force_update_all_bone_transforms()
		# Bell sleeves follow the cuff translation while their lower fabric hangs
		# down; rotating all cloth with the arm produces the reported bat wings.
		for side in range(2):
			skeleton.set_bone_pose_position(14+side,skeleton.get_bone_global_pose(10+side*3).origin)
	else:
		skeleton.set_bone_pose_rotation(1,Quaternion.from_euler(gait.upper_body.chest.rotation))
		for bone in range(6): skeleton.set_bone_pose_rotation(2+bone,gait.skeleton.get_bone_pose_rotation(bone))
		for side in range(2):
			for bone in range(3): skeleton.set_bone_pose_rotation(8+side*3+bone,gait.upper_body.arms[side].skeleton.get_bone_pose_rotation(bone))
	skeleton.force_update_all_bone_transforms()
	for attachment in attachments:
		var deform:=skeleton.get_bone_global_pose(attachment.bone)*Transform3D(Basis.IDENTITY,origins[attachment.bone]).affine_inverse()
		attachment.node.global_transform=root.global_transform*deform*attachment.rest

func ground(actor: Node3D,terrain: Node3D) -> void:
	var transforms: Array[Transform3D]=[]
	for bone in range(origins.size()):
		transforms.append(skeleton.get_bone_global_pose(bone)*Transform3D(Basis.IDENTITY,origins[bone]).affine_inverse())
	var shift: float=-INF
	for item in support_clouds[model_id]:
		var p:=Vector3.ZERO
		for i in range(4):
			if item.weights[i]>0: p+=(transforms[item.bones[i]]*item.point)*item.weights[i]
		p=root.global_transform*p
		shift=maxf(shift,terrain.height_at(p.x,p.z)+.028-p.y)
	actor.position.y+=shift

func contacts(terrain: Node3D) -> Dictionary:
	var matrices: Array[Transform3D]=[]
	for bone in range(origins.size()): matrices.append(skeleton.get_bone_global_pose(bone)*Transform3D(Basis.IDENTITY,origins[bone]).affine_inverse())
	var result:={"foot":INF,"torso":INF}
	for item in support_clouds[model_id]:
		var category: String="foot" if item.point.y<.25 else ("torso" if item.point.y>1.0 and item.point.y<1.6 and absf(item.point.x)<.29 else "")
		if category.is_empty(): continue
		var p:=Vector3.ZERO
		for i in range(4):
			if item.weights[i]>0: p+=(matrices[item.bones[i]]*item.point)*item.weights[i]
		p=root.global_transform*p
		result[category]=minf(result[category],p.y-terrain.height_at(p.x,p.z))
	return result

static func weights_at(p: Vector3,id: String) -> Dictionary:
	var height: float=Models.HEIGHTS[id]
	var arm:=smoothstep(height*.085,height*.22,absf(p.x))*(1-smoothstep(height*.81,height*.88,p.y))*smoothstep(height*.33,height*.49,p.y)
	var first:=8 if p.x<0 else 11
	if arm>.001:
		var shoulder:=smoothstep(height*.56,height*.67,p.y)
		var wrist:=1-smoothstep(height*.41,height*.49,p.y)
		if id=="maldrek":
			var cloth: float=(1-smoothstep(1.55,1.85,p.y))*(1-caster_hand_mask(p))
			if cloth>.001:
				var hang:=14 if p.x<0 else 15
				return {"bones":PackedInt32Array([hang,first+1,first+2,1]),"weights":PackedFloat32Array([arm*cloth,arm*maxf(0,1-shoulder-wrist)*(1-cloth),arm*(wrist+shoulder)*(1-cloth),1-arm])}
		return {"bones":PackedInt32Array([first,first+1,first+2,1]),"weights":PackedFloat32Array([arm*shoulder,arm*maxf(0,1-shoulder-wrist),arm*wrist,1-arm])}
	if id=="knight":
		var leg: float=(1-smoothstep(.79,.99,p.y))*smoothstep(.015,.115,absf(p.x))
		if leg>.001:
			var hip:=smoothstep(.41,.57,p.y)
			var ankle:=1-smoothstep(.07,.20,p.y)
			first=2 if p.x<0 else 5
			return {"bones":PackedInt32Array([first,first+1,first+2,0]),"weights":PackedFloat32Array([leg*hip,leg*maxf(0,1-hip-ankle),leg*ankle,1-leg])}
	return {"bones":PackedInt32Array([1,0,0,0]),"weights":PackedFloat32Array([1,0,0,0])}

static func caster_hand_mask(p: Vector3) -> float:
	if caster_hand_image==null: caster_hand_image=Image.load_from_file(ProjectSettings.globalize_path("res://assets/models/meshy/front-reference-colors/maldrek.png"))
	var front: Dictionary=Models.definition("maldrek").front_projection
	var q:=p/2.8
	var u: float=1-(q.x-front.x_bounds[0])/(front.x_bounds[1]-front.x_bounds[0])
	var coordinate:=Vector2(front.rect[0]+u*front.rect[2],front.rect[1]+(1-q.y)*front.rect[3])
	var pixel:=caster_hand_image.get_pixel(clampi(int(coordinate.x*caster_hand_image.get_width()),0,caster_hand_image.get_width()-1),clampi(int(coordinate.y*caster_hand_image.get_height()),0,caster_hand_image.get_height()-1))
	return smoothstep(.025,.11,pixel.r-pixel.b)*smoothstep(.22,.46,pixel.r)

static func mesh_for(id: String) -> ArrayMesh:
	if prepared.has(id): return prepared[id]
	var result:=ArrayMesh.new()
	var support: Array=[]
	var data:=Models.definition(id)
	for part in data.parts:
		var spec: Dictionary=data.parts[part]
		var origin:=Vector3(spec.origin[0],spec.origin[1],spec.origin[2])
		var source: ArrayMesh=load(spec.mesh)
		for surface in range(source.get_surface_count()):
			var arrays:=source.surface_get_arrays(surface)
			var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
			var bones:=PackedInt32Array(); var weights:=PackedFloat32Array()
			for i in range(vertices.size()):
				vertices[i]+=origin
				var binding:=weights_at(vertices[i],id)
				bones.append_array(binding.bones); weights.append_array(binding.weights)
				if i%17==0: support.append({"point":vertices[i],"bones":binding.bones,"weights":binding.weights})
			arrays[Mesh.ARRAY_VERTEX]=vertices; arrays[Mesh.ARRAY_BONES]=bones; arrays[Mesh.ARRAY_WEIGHTS]=weights
			result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
			var paint: ShaderMaterial=Models.material(id,part,origin).duplicate()
			paint.set_shader_parameter("part_origin",Vector3.ZERO)
			result.surface_set_material(result.get_surface_count()-1,paint)
	prepared[id]=result
	support_clouds[id]=support
	return result
