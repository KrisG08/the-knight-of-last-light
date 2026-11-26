extends RefCounted
## Prepared source meshes only; never imports geometry or runs conversion in game.
const Art = preload("res://game/presentation/art_kit.gd")
const ROOT = "res://assets/models/meshy/"
const HEIGHTS = {"knight":1.9,"oren":1.85,"lyra":1.8,"cael":1.9,"goblin":1.45,"gravedigger":2.6,"maldrek":2.8,"fallen-commander":2.65,"iron-warden":3.1,"thorn-beast":2.3}
static var definitions: Dictionary = {}
static var meshes: Dictionary = {}
static var materials: Dictionary = {}

static func definition(id: String) -> Dictionary:
	if not definitions.has(id): definitions[id] = JSON.parse_string(FileAccess.get_file_as_string(ROOT+id+".json"))
	return definitions[id]

static func material(id: String, part: String, origin: Vector3) -> Material:
	var key := id+"/"+part
	if materials.has(key): return materials[key]
	var result := ShaderMaterial.new()
	result.shader = preload("res://assets/materials/meshy_surface.gdshader")
	result.set_shader_parameter("reference_color",load(ROOT+"reference-colors/"+id+".png"))
	result.set_shader_parameter("metal_detail",preload("res://assets/vendor/polyhaven/metal_plate/Diffuse.jpg"))
	result.set_shader_parameter("creature",id=="thorn-beast")
	result.set_shader_parameter("enemy_surface",id in ["thorn-beast","fallen-commander","iron-warden","maldrek","gravedigger"])
	result.set_shader_parameter("part_origin",origin)
	result.set_shader_parameter("bark_detail",preload("res://assets/vendor/polyhaven/dead_tree_trunk/textures/dead_tree_trunk_diff_1k.jpg"))
	materials[key] = result
	return result

static func build(root: Node3D, id: String, weapon: Node3D = null, height_scale: float = 1.0) -> Dictionary:
	var data := definition(id)
	var rig := {"legs":[],"leg_meshes":[],"source":"Meshy 6 Lite / CC BY 4.0","meshy_id":id}
	root.set_meta("source_credit",rig.source)
	root.set_meta("meshy_model",id)
	var body := Node3D.new(); body.name = "MeshyBody"; root.add_child(body); rig.body = body
	for part in ["body","left_leg","right_leg","left_arm","right_arm","front_left_leg","front_right_leg","back_left_leg","back_right_leg"]:
		if not data.parts.has(part): continue
		var spec: Dictionary = data.parts[part]
		var origin := Vector3(spec.origin[0],spec.origin[1],spec.origin[2])
		var limb := Node3D.new()
		limb.name = part
		var parent := body if part=="body" else root
		if weapon!=null and part=="right_arm": parent = weapon
		parent.add_child(limb)
		limb.position = origin*height_scale-(weapon.position if parent==weapon else Vector3.ZERO)
		limb.scale=Vector3.ONE*height_scale
		var path: String = spec.mesh
		if not meshes.has(path):
			var prepared: ArrayMesh = load(path).duplicate()
			for surface in range(prepared.get_surface_count()): prepared.surface_set_material(surface,material(id,part,origin))
			meshes[path] = prepared
		var instance := MeshInstance3D.new()
		instance.mesh = meshes[path]
		instance.material_override = material(id,part,origin)
		instance.visibility_range_end = 110 if id=="goblin" else 180
		limb.add_child(instance)
		rig[part] = limb
		if part.ends_with("leg"):
			rig.legs.append(limb)
			rig.leg_meshes.append(instance)
	return rig

static func knight(root: Node3D, weapon: Node3D) -> Dictionary:
	weapon.position = Vector3(0.28,1.42,0)
	var rig := build(root,"knight",weapon)
	var equipment := preload("res://game/presentation/scanned_knight.gd")
	equipment.prepare()
	equipment.add(weapon,equipment.parts.sword)
	rig.sword = weapon.get_child(weapon.get_child_count()-1)
	var shield := MeshInstance3D.new()
	shield.mesh = equipment.parts.shield
	rig.left_arm.add_child(shield)
	shield.position = Vector3(-0.28,1.42,0)-rig.left_arm.position
	rig.shield = shield
	return rig
