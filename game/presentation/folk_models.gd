extends RefCounted
## Passive inhabitants: original geometry, no gameplay state.
const Art = preload("res://game/presentation/art_kit.gd")
const Shapes = preload("res://game/presentation/ambient_entities.gd")
const Detail = preload("res://game/presentation/hostile_regalia.gd")
static var rigs: Dictionary = {}

static func orb(root: Node3D, at: Vector3, radii: Vector3, mat: Material) -> void:
	Shapes.orb(root,at,radii*2,mat)

static func skin(id: String, tint: Color) -> Material:
	var material := Art.material("folk_skin_"+id,tint)
	material.roughness = 0.96
	if material.normal_texture==null:
		var noise := FastNoiseLite.new()
		noise.seed = 4927
		noise.frequency = 0.13
		var texture := NoiseTexture2D.new()
		texture.width = 256
		texture.height = 256
		texture.noise = noise
		texture.seamless = true
		texture.as_normal_map = true
		texture.bump_strength = 1.5
		material.normal_enabled = true
		material.normal_texture = texture
		material.normal_scale = 0.45
	return material

static func cone(root: Node3D, start: Vector3, end: Vector3, radius: float, mat: Material) -> void:
	var direction := end-start
	var mesh := Art.cylinder(root,(start+end)*0.5,radius,0,direction.length(),mat,12)
	mesh.quaternion = Quaternion(Vector3.UP,direction.normalized())

static func face(root: Node3D, y: float, width: float, mat: Material, nose: float) -> void:
	orb(root,Vector3(0,y,0),Vector3(width,0.3,width*0.8),mat)
	orb(root,Vector3(0,y-0.07,-width*0.7),Vector3(width*0.6,0.13,0.15),mat)
	orb(root,Vector3(0,y+0.015,-width*0.95),Vector3(0.075,0.12,nose),mat)
	var dark := Art.material("folk_eye_socket",Color("161a13"))
	var iris := Art.material("folk_amber_iris",Color("ae9560"))
	for side in [-1,1]:
		orb(root,Vector3(side*width*0.44,y+0.065,-width*0.72),Vector3(0.045,0.025,0.035),dark)
		orb(root,Vector3(side*width*0.44,y+0.065,-width*0.85),Vector3(0.014,0.016,0.012),iris)
		Art.beam(root,Vector3(side*0.04,y+0.14,-width*0.76),Vector3(side*width*0.72,y+0.11,-width*0.62),0.045,mat)
		orb(root,Vector3(side*width*0.6,y-0.025,-width*0.58),Vector3(0.08,0.065,0.06),mat)
		orb(root,Vector3(side*0.045,y-0.045,-width*0.95-nose*0.72),Vector3(0.02,0.012,0.012),dark)

static func limbs(root: Node3D, hip: float, shoulder: float, width: float, mat: Material, boots: Material) -> void:
	for side in [-1,1]:
		var leg := Node3D.new()
		leg.name = "Leg"+str(side)
		root.add_child(leg)
		var first := root.get_child_count()
		Art.beam(root,Vector3(side*width*0.45,hip,0),Vector3(side*width*0.65,0.18,-0.04),width*0.21,mat)
		orb(root,Vector3(side*width*0.65,0.12,-0.12),Vector3(width*0.28,0.12,0.25),boots)
		collect_limb(root,leg,first,Vector3(side*width*0.45,hip,0))
		var arm := Node3D.new()
		arm.name = "Arm"+str(side)
		root.add_child(arm)
		first = root.get_child_count()
		var elbow := Vector3(side*width*1.18,shoulder*0.65,-0.1)
		var wrist := Vector3(side*width*1.05,shoulder*0.38,-0.2)
		Art.beam(root,Vector3(side*width*0.7,shoulder,0),elbow,width*0.21,mat)
		Art.beam(root,elbow,wrist,width*0.17,mat)
		orb(root,wrist,Vector3(width*0.23,0.14,0.1),mat)
		for finger in range(4):
			Art.beam(root,wrist+Vector3((finger-1.5)*0.035,-0.04,-0.05),wrist+Vector3((finger-1.5)*0.045,-0.22,-0.07),0.02,mat)
		collect_limb(root,arm,first,Vector3(side*width*0.7,shoulder,0))

static func collect_limb(root: Node3D, pivot: Node3D, first: int, at: Vector3) -> void:
	pivot.position = at
	for node in root.get_children().slice(first):
		root.remove_child(node)
		pivot.add_child(node)
		node.position -= at

static func build(root: Node3D, kind: String) -> void:
	if kind in ["goblin","troll","dwarf"]:
		var source: String="oren" if kind=="dwarf" else "goblin"
		var height: float=0.76 if kind=="dwarf" else (1.70 if kind=="troll" else 1.0)
		var width: float=1.22 if kind=="dwarf" else (1.36 if kind=="troll" else 1.0)
		var model: Dictionary = preload("res://game/presentation/meshy_models.gd").build(root,source,null,height)
		root.set_meta("folk_source",source)
		for instance in root.find_children("*","MeshInstance3D",true,false):
			var limb: Node3D=instance.get_parent()
			limb.scale.x*=width; limb.scale.z*=1.12 if kind!="goblin" else 1.0
			limb.position.x*=width; limb.position.z*=1.12 if kind!="goblin" else 1.0
			if kind!="goblin":
				var variant: ShaderMaterial=instance.material_override.duplicate()
				variant.set_shader_parameter("variant_tint",Color(0.70,0.76,0.62) if kind=="troll" else Color(0.94,0.85,0.72))
				instance.material_override=variant
		for side in [-1,1]:
			model["left_leg" if side<0 else "right_leg"].name = "Leg"+str(side)
			model["left_arm" if side<0 else "right_arm"].name = "Arm"+str(side)
		if kind=="dwarf":
			# Retain the textured artisan face; avoid rigid strips over its beard.
			# Work tool follows the existing authored repair arm motion.
			var arm: Node3D=root.get_node("Arm1")
			var bounds: AABB=arm.get_child(0).mesh.get_aabb()
			var grip:=bounds.position+Vector3(bounds.size.x*0.5,bounds.size.y*0.15,bounds.size.z*0.5)
			Art.beam(arm,grip+Vector3(0,0.05,0),grip+Vector3(0,-0.30,0),0.025,Art.material("dwarf_tool_wood",Color("49372a")))
			Detail.plate(arm,grip+Vector3(0,-0.31,0),Vector3(0.24,0.10,0.09),Detail.metal())
		return
	var key := "ambient_folk_"+kind
	if Detail.restore(root,key):
		for part in rigs[kind]:
			var pivot := Node3D.new()
			pivot.name = part.name
			pivot.position = part.position
			root.add_child(pivot)
			Detail.restore(pivot,key+"/"+part.name)
		return
	match kind:
		"goblin": goblin(root)
		"troll": troll(root)
		"dwarf": dwarf(root)
	var limbs_to_restore: Array[Node3D] = []
	rigs[kind] = []
	for child in root.get_children():
		if child is MeshInstance3D: continue
		Detail.finish(child,key+"/"+str(child.name))
		rigs[kind].append({"name":str(child.name),"position":child.position})
		limbs_to_restore.append(child)
		root.remove_child(child)
	Detail.finish(root,key)
	for limb in limbs_to_restore: root.add_child(limb)

static func goblin(root: Node3D) -> void:
	var flesh := skin("goblin",Color("667051"))
	var hide := Art.material("folk_worn_hide",Color("42382a"))
	orb(root,Vector3(0,0.8,0.04),Vector3(0.27,0.38,0.19),hide)
	limbs(root,0.62,1.02,0.31,flesh,hide)
	face(root,1.25,0.26,flesh,0.18)
	for side in [-1,1]:
		cone(root,Vector3(side*0.19,1.29,0),Vector3(side*0.6,1.47,0.04),0.105,flesh)
		cone(root,Vector3(side*0.1,1.15,-0.23),Vector3(side*0.12,1.24,-0.25),0.027,Detail.bone())
		Art.beam(root,Vector3(side*0.14,0.97,-0.15),Vector3(-side*0.17,0.65,-0.16),0.025,hide)
	Detail.band(root,Vector3(0,0.66,0),0.23,Detail.metal(),0.025)
	for index in range(3):
		orb(root,Vector3(0.2,0.65-index*0.07,-0.05),Vector3(0.09,0.09,0.08),hide)
	for side in [-1,1]:
		for index in range(4):
			orb(root,Vector3(side*0.15,0.75+index*0.055,-0.16),Vector3.ONE*0.014,Detail.metal())

static func troll(root: Node3D) -> void:
	var flesh := skin("troll",Color("62675a"))
	var hide := Art.material("troll_hide",Color("37332a"))
	orb(root,Vector3(0,1.35,0.12),Vector3(0.72,0.88,0.5),flesh)
	orb(root,Vector3(0,1.95,0.15),Vector3(0.8,0.42,0.48),flesh)
	limbs(root,0.95,1.95,0.78,flesh,flesh)
	face(root,2.14,0.4,flesh,0.2)
	for side in [-1,1]:
		cone(root,Vector3(side*0.19,2.0,-0.36),Vector3(side*0.24,2.28,-0.44),0.065,Detail.bone())
		orb(root,Vector3(side*0.55,1.05,0),Vector3(0.3,0.4,0.36),hide)
		for index in range(5):
			orb(root,Vector3(side*(0.32+index*0.07),1.95-index*0.035,0.28),Vector3(0.12,0.09,0.13),Art.stone())
	for index in range(7):
		var a := index*TAU/7
		cone(root,Vector3(sin(a)*0.52,0.96,cos(a)*0.4),Vector3(sin(a)*0.57,0.5,cos(a)*0.43),0.17,hide)

static func dwarf(root: Node3D) -> void:
	var flesh := skin("dwarf",Color("a08a73"))
	var leather := Art.material("dwarf_apron",Color("493b30"))
	orb(root,Vector3(0,0.75,0),Vector3(0.4,0.42,0.28),leather)
	limbs(root,0.53,1.0,0.43,flesh,Detail.metal())
	face(root,1.23,0.25,flesh,0.1)
	var beard := Art.material("dwarf_beard",Color("615b50"))
	for index in range(19):
		var x := (index-9)*0.023
		var length := 0.32+0.2*(1-absf(x)/0.23)
		Art.beam(root,Vector3(x,1.16,-0.35),Vector3(x*0.7,1.16-length,-0.4),0.025,beard)
	for side in [-1,1]:
		Art.beam(root,Vector3(side*0.02,1.18,-0.36),Vector3(side*0.19,1.12,-0.36),0.04,beard)
		Detail.band(root,Vector3(side*0.11,0.9,-0.4),0.035,Detail.gold(),0.012)
		orb(root,Vector3(side*0.32,1.0,0),Vector3(0.17,0.12,0.22),Detail.metal())
	orb(root,Vector3(0,1.43,0.03),Vector3(0.29,0.17,0.24),Detail.metal())
	Detail.band(root,Vector3(0,1.39,0.03),0.27,Detail.gold(),0.025)
	Detail.plate(root,Vector3(0,0.76,-0.28),Vector3(0.52,0.45,0.04),leather)
	Art.beam(root,Vector3(0.5,0.15,-0.2),Vector3(0.5,0.64,-0.2),0.035,leather)
	Detail.plate(root,Vector3(0.5,0.61,-0.2),Vector3(0.36,0.16,0.16),Detail.metal())
	var hand := root.get_node("Arm1") as Node3D
	for tool in root.get_children().slice(root.get_child_count()-2):
		root.remove_child(tool)
		hand.add_child(tool)
		tool.position -= hand.position
