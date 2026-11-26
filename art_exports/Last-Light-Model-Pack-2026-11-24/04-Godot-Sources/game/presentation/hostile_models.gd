extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Sources = preload("res://game/presentation/hostile_source_parts.gd")
const Pose = preload("res://game/presentation/hostile_pose.gd")
const Regalia = preload("res://game/presentation/hostile_regalia.gd")
static var spheres: SphereMesh
static var armor_meshes: Dictionary = {}
static var cloth_meshes: Dictionary = {}

static func mat(id: String, color: Color, metal: float = 0) -> StandardMaterial3D:
	var result := Art.material("hostile_"+id,color,metal)
	if metal>0 and result.albedo_texture==null:
		var source := Art.material("iron",Color("243239"),0.75)
		result.albedo_texture = source.albedo_texture
		result.normal_enabled = true
		result.normal_texture = source.normal_texture
		result.roughness_texture = source.roughness_texture
		result.roughness_texture_channel = source.roughness_texture_channel
		result.normal_scale = 0.55
		result.uv1_triplanar = true
		result.uv1_scale = Vector3.ONE*2
	if metal==0 and result.albedo_texture==null and id not in ["eye_socket","nose","telegraph","wicked_eyes"]:
		var source_path := "res://assets/vendor/polyhaven/grey_plaster_02/"
		if id=="beast_hide":
			result.albedo_texture = load("res://assets/vendor/polyhaven/dead_tree_trunk/textures/dead_tree_trunk_diff_1k.jpg")
			result.normal_texture = load("res://assets/vendor/polyhaven/dead_tree_trunk/textures/dead_tree_trunk_nor_gl_1k.jpg")
		elif id=="old_wood":
			result.albedo_texture=preload("res://assets/vendor/polyhaven/dark_wooden_planks/Diffuse.jpg")
			result.normal_texture=preload("res://assets/vendor/polyhaven/dark_wooden_planks/nor_gl.jpg")
		else:
			result.albedo_texture = load(source_path+"Diffuse.jpg")
			result.normal_texture = load(source_path+"nor_gl.jpg")
		result.normal_enabled = true
		result.normal_scale = 0.45 if id=="beast_hide" else 0.12
		result.roughness = 0.95
		result.uv1_triplanar = true
		result.uv1_scale = Vector3.ONE*2.5
	return result

static func orb(root: Node3D, at: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	if spheres==null:
		spheres = SphereMesh.new()
		spheres.radius = 1
		spheres.height = 2
		spheres.radial_segments = 20
		spheres.rings = 12
	var node := Art.mesh(root,spheres,at,material)
	node.scale = size
	return node

static func joint(root: Node3D, from: Vector3, to: Vector3, width: float, material: Material) -> void:
	var direction := to-from
	var node := orb(root,(from+to)*0.5,Vector3(width,direction.length()*0.6,width),material)
	node.quaternion = Quaternion(Vector3.UP,direction.normalized())

static func spike(root: Node3D, start: Vector3, end: Vector3, radius: float, material: Material) -> void:
	var vector := end-start
	var node := Art.cylinder(root,(start+end)*0.5,radius,0.004,vector.length(),material,10)
	node.quaternion = Quaternion(Vector3.UP,vector.normalized())

static func cloth(root: Node3D, rows: Array, width: float, depth: float, material: Material, ragged: float = 0.06) -> MeshInstance3D:
	var key := str(rows)+str(width)+str(depth)+str(ragged)
	if cloth_meshes.has(key): return Art.mesh(root,cloth_meshes[key],Vector3.ZERO,material)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.set_smooth_group(0)
	for row in range((rows.size()-1)*4):
		for side in range(48):
			for offset in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
				var level: float = (row+offset.y)/4.0
				var low := mini(int(level),rows.size()-2)
				var data: Vector2 = rows[low].lerp(rows[low+1],level-low)
				var angle: float = (side+offset.x)/48.0*TAU
				var radius: float = data.y*(1+sin(angle*12+level*0.2)*0.07+sin(angle*19-level*0.4)*0.022)
				var hem := maxf(0,1-level*2)
				var y: float = data.x+sin(angle*9)*ragged*hem
				surface.set_uv(Vector2((side+offset.x)/48.0,level/(rows.size()-1)))
				surface.add_vertex(Vector3(cos(angle)*radius*width,y,sin(angle)*radius*depth))
	surface.generate_normals()
	cloth_meshes[key] = surface.commit()
	return Art.mesh(root,cloth_meshes[key],Vector3.ZERO,material)

static func cape(root: Node3D, height: float, width: float, material: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(8):
		for column in range(8):
			for corner in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
				var u: float = (column+corner.x)/8
				var v: float = (row+corner.y)/8
				surface.set_uv(Vector2(u,v))
				surface.add_vertex(Vector3((u-0.5)*width*(0.65+v*0.35),height-v*(height-0.2)+sin(u*19)*0.08*v,0.25+v*0.25+sin(u*22)*0.035))
	surface.generate_normals()
	Art.mesh(root,surface.commit(),Vector3.ZERO,material)

static func skull(root: Node3D, at: Vector3, size: float, accent: Material) -> void:
	var bone := mat("old_bone",Color("a09a85"))
	var dark := mat("eye_socket",Color("090d0c"))
	orb(root,at,Vector3(0.15,0.2,0.14)*size,bone)
	orb(root,at+Vector3(0,-0.13,-0.03)*size,Vector3(0.11,0.1,0.1)*size,bone)
	for side in [-1,1]:
		orb(root,at+Vector3(side*0.065,0.025,-0.125)*size,Vector3(0.048,0.028,0.027)*size,dark)
		var eyes := mat("wicked_eyes",Color("c4a0ff"))
		eyes.emission_enabled = true
		eyes.emission = Color("9d55ec")
		orb(root,at+Vector3(side*0.065,0.025,-0.151)*size,Vector3(0.014,0.009,0.01)*size,eyes)
		orb(root,at+Vector3(side*0.09,-0.06,-0.04)*size,Vector3(0.055,0.05,0.09)*size,bone)
		Regalia.plate(root,at+Vector3(side*0.075,0.067,-0.124)*size,Vector3(0.1,0.035,0.055)*size,bone).rotation.z = side*0.18
	Regalia.plate(root,at+Vector3(0,-0.025,-0.152)*size,Vector3(0.028,0.065,0.02)*size,dark)
	for index in range(7):
		spike(root,at+Vector3((index-3)*0.025,-0.075,-0.124)*size,at+Vector3((index-3)*0.025,-0.12,-0.13)*size,0.009*size,bone)

static func armor_part(id: String, name: String) -> Mesh:
	var key := id+"/"+name
	if not armor_meshes.has(key):
		var parts := Sources.prepare("strong-knight")
		var mesh := parts[name].duplicate() as ArrayMesh
		for surface in range(mesh.get_surface_count()):
			var material := mesh.surface_get_material(surface).duplicate() as StandardMaterial3D
			material.albedo_color = Color("b5b8bc") if id!="warden" else Color("aaa08d")
			material.roughness = maxf(material.roughness,0.72)
			# Worn, dirty steel keeps a diffuse component in dim interior lighting.
			material.metallic = minf(material.metallic,0.35)
			mesh.surface_set_material(surface,material)
		armor_meshes[key] = mesh
	return armor_meshes[key]

static func armor(root: Node3D, id: String, accent: Material) -> Dictionary:
	var container := Node3D.new()
	var scale: float = 1.3 if id=="commander" else (1.55 if id=="warden" else 0.95)
	container.scale = Vector3.ONE*scale
	root.add_child(container)
	root.set_meta("source_credit","DJMaesen / CC BY 4.0")
	var body := Node3D.new()
	container.add_child(body)
	for name in ["body","head"]:
		Art.mesh(body,armor_part(id,name),Vector3.ZERO,null)
	# The scanned closed visor already has eye slits; extra spheres floated outside it.
	var legs: Array[Node3D] = []
	for side in [-1,1]:
		var leg := Node3D.new()
		leg.position = Sources.pivot("strong-knight","left_leg" if side<0 else "right_leg")
		container.add_child(leg)
		Art.mesh(leg,armor_part(id,"left_leg" if side<0 else "right_leg"),Vector3.ZERO,null)
		legs.append(leg)
		if side<0:
			var arm := Node3D.new()
			arm.position = Sources.pivot("strong-knight","left_arm")
			arm.rotation.z = 0.15
			body.add_child(arm)
			Art.mesh(arm,armor_part(id,"left_arm"),Vector3.ZERO,null)
		if id=="warden":
			for layer in range(3):
				orb(body,Vector3(side*(0.37+layer*0.035),1.55-layer*0.075,0),Vector3(0.2,0.055,0.23),mat("rust_armor",Color("53443a"),0.85))
	var cloth_mat := Regalia.fabric(Color("363349") if id=="commander" else Color("493b30"))
	if id!="soldier":
		cape(body,1.48,1.0,cloth_mat)
		for side in [-1,1]:
			spike(body,Vector3(side*0.42,1.48,0),Vector3(side*0.58,1.88,0.05),0.08,mat("rust_armor",Color("53443a"),0.85))
	if id=="commander":
		for index in range(5):
			var x: float = (index-2)*0.09
			spike(body,Vector3(x,1.87,0),Vector3(x*1.2,2.12-absf(x)*0.6,0.03),0.035,mat("old_gold",Color("8b7950"),0.7))
	Regalia.armor(body,id)
	return {"body":body,"legs":legs}

static func robes(root: Node3D, id: String, accent: Material) -> Dictionary:
	var body := Node3D.new()
	root.add_child(body)
	var h: float = 2.35 if id=="maldrek" else (2.6 if id=="gravedigger" else 1.65)
	var tint := Color("655071") if id=="maldrek" else (Color("58604e") if id=="villager" else (Color("3d4b58") if id=="shade" else Color("747060")))
	var worn := Regalia.fabric(tint)
	cloth(body,[Vector2(0.12,0.6),Vector2(h*0.2,0.5),Vector2(h*0.5,0.32),Vector2(h*0.75,0.44),Vector2(h*0.84,0.24)],1,0.8,worn,0.1)
	var neck := Vector3(0,h-0.17,-0.1)
	if id=="gravedigger":
		neck += Vector3(0,-0.04,-0.27)
	# Hood shell around an actual recessed skull, not a closed cube.
	Regalia.hood(body,neck+Vector3(0,0.03,-0.03),worn)
	if id!="shade":
		skull(body,neck+Vector3(0,0,-0.1),0.85 if id in ["gravedigger","maldrek"] else 0.68,accent)
	else:
		Regalia.plate(body,neck+Vector3(0,-0.015,-0.14),Vector3(0.23,0.30,0.06),mat("shade_mask",Color("36434b"),0.3))
		for side in [-1,1]: orb(body,neck+Vector3(side*0.05,0.035,-0.175),Vector3(0.019,0.0045,0.004),Regalia.gem(Color("a77cd1")))
	cloth(body,[Vector2(h*0.69,0.5),Vector2(h*0.78,0.46),Vector2(h*0.88,0.23)],1.05,0.85,worn,0.03)
	var chain_metal := mat("chain_iron",Color("493d32"),0.65)
	if id=="gravedigger":
		var link := TorusMesh.new()
		link.inner_radius = 0.035
		link.outer_radius = 0.055
		link.rings = 12
		link.ring_segments = 6
		for side in [-1,1]:
			for index in range(8):
				var node := Art.mesh(body,link,Vector3(side*0.23,h*0.77-index*0.07,-0.31),chain_metal)
				node.rotation.x = PI/2
	var leather := mat("leather",Color("302c27"))
	for side in [-1,1]:
		if side<0:
			joint(body,Vector3(side*0.35,h*0.74,0),Vector3(side*0.53,h*0.51,-0.1),0.14,worn)
			joint(body,Vector3(side*0.53,h*0.51,-0.1),Vector3(side*0.43,h*0.34,-0.28),0.075,leather)
			orb(body,Vector3(side*0.43,h*0.33,-0.3),Vector3(0.075,0.11,0.06),mat("dead_skin",Color("707365")))
			for finger in range(4):
				spike(body,Vector3(side*0.43+(finger-1.5)*0.027,h*0.3,-0.31),Vector3(side*0.44+(finger-1.5)*0.027,h*0.24,-0.36),0.012,mat("dead_skin",Color("707365")))
		orb(body,Vector3(side*0.31,h*0.76,-0.2),Vector3(0.13,0.09,0.06),accent)
	var legs: Array[Node3D] = []
	for side in [-1,1]:
		var leg := Node3D.new()
		leg.position = Vector3(side*0.16,0.55,0)
		root.add_child(leg)
		joint(leg,Vector3.ZERO,Vector3(0,-0.42,-0.06),0.09,leather)
		orb(leg,Vector3(0,-0.47,-0.12),Vector3(0.12,0.1,0.24),leather)
		legs.append(leg)
	if id=="maldrek":
		cape(body,1.96,1.15,worn)
		for side in [-1,1]:
			spike(body,Vector3(side*0.23,h+0.1,0),Vector3(side*0.45,h+0.56,0.1),0.085,mat("obsidian",Color("333c44"),0.75))
	Regalia.robes(body,id,h)
	return {"body":body,"legs":legs}

static func beast(root: Node3D, head_pivot: Node3D, thorn: bool, accent: Material) -> Dictionary:
	var parts := Sources.prepare("red-fox")
	var container := Node3D.new()
	var size: float = 1.85 if thorn else 1.2
	var dimensions := Vector3(1.25 if thorn else 1.0,1,1)*size
	container.scale = dimensions
	root.add_child(container)
	root.set_meta("source_credit","Alexei Ostapenko / CC BY 4.0")
	var body := Node3D.new()
	container.add_child(body)
	Art.mesh(body,parts.body,Vector3.ZERO,null)
	var legs: Array[Node3D] = []
	for name in ["front_left","front_right","back_left","back_right"]:
		var leg := Node3D.new()
		leg.position = Sources.pivot("red-fox",name)
		container.add_child(leg)
		Art.mesh(leg,parts[name],Vector3.ZERO,null)
		legs.append(leg)
	var head := Node3D.new()
	head.scale = dimensions
	head.position = Sources.pivot("red-fox","head")*dimensions-head_pivot.position
	head_pivot.add_child(head)
	Art.mesh(head,parts.head,Vector3.ZERO,null)
	var bone := mat("beast_bone",Color("77715e"))
	if thorn:
		for side in [-1,1]:
			var base := Vector3(side*0.09,0.2,-0.25)
			for index in range(4):
				var next := base+Vector3(side*(0.09+index*0.025),0.16,0.09)
				Art.beam(head,base,next,0.04-index*0.007,bone)
				spike(head,next,next+Vector3(-side*0.09,0.2,0.04),0.02,bone)
				base = next
		for index in range(6):
			var at := Vector3(0,0.76,-0.24+index*0.12)
			orb(body,at,Vector3(0.13,0.07,0.16),mat("beast_hide",Color("6a6255")))
			spike(body,at,at+Vector3(0,0.2+(index%2)*0.1,0.1),0.055,bone)
	else:
		var collar := TorusMesh.new()
		collar.inner_radius = 0.11
		collar.outer_radius = 0.145
		collar.rings = 20
		collar.ring_segments = 8
		var band := Art.mesh(body,collar,Vector3(0,0.66,-0.36),accent)
		band.rotation.x = PI/3
	var tail := Node3D.new()
	tail.position = Sources.pivot("red-fox","tail")
	container.add_child(tail)
	Art.mesh(tail,parts.tail,Vector3.ZERO,null)
	Regalia.beast(body,head,thorn)
	return {"body":body,"legs":legs,"tail":tail}
static func blade(root: Node3D, length: float, material: Material) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Lenticular bevels retain a broad blade until the short tapered point.
	var rings: Array=[]
	for section in [Vector3(0.11,0.035,-0.25),Vector3(0.105,0.03,-length*0.70),Vector3(0.07,0.02,-length*0.89),Vector3(0.001,0.001,-length)]:
		rings.append([Vector3(-section.x,0,section.z),Vector3(0,section.y,section.z),Vector3(section.x,0,section.z),Vector3(0,-section.y,section.z)])
	for row in range(rings.size()-1):
		for edge in range(4):
			var next: int=(edge+1)%4
			for vertex in [rings[row][edge],rings[row+1][edge],rings[row][next],rings[row][next],rings[row+1][edge],rings[row+1][next]]: surface.add_vertex(vertex)
	surface.generate_normals()
	var mesh := Art.mesh(root,surface.commit(),Vector3.ZERO,material)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	Art.beam(root,Vector3(-0.32,0,-0.2),Vector3(0.32,0,-0.2),0.055,material)
	Art.beam(root,Vector3(0,0,0.1),Vector3(0,0,-0.2),0.06,mat("grip",Color("2b221d")))

static func spade(root: Node3D, metal: Material) -> void:
	var outline := [Vector2(-0.34,0),Vector2(-0.43,-0.35),Vector2(-0.3,-0.73),Vector2(0,-0.98),Vector2(0.3,-0.73),Vector2(0.43,-0.35),Vector2(0.34,0)]
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1,1]:
		for index in range(outline.size()):
			var a: Vector2 = outline[index]
			var b: Vector2 = outline[(index+1)%outline.size()]
			for v in [Vector3(0,side*0.025,-0.4),Vector3(a.x,side*0.025+absf(a.x)*0.12,a.y),Vector3(b.x,side*0.025+absf(b.x)*0.12,b.y)]:
				surface.add_vertex(v)
	surface.generate_normals()
	var iron := metal.duplicate() as StandardMaterial3D
	iron.cull_mode = BaseMaterial3D.CULL_DISABLED
	Art.mesh(root,surface.commit(),Vector3(0.4,0,-2.1),iron)

static func weapon(root: Node3D, id: String, accent: Material) -> void:
	var metal := mat("weapon_iron",Color("778080"),0.45)
	# Broad weapons must read as forged iron, not industrial diamond plate.
	metal.albedo_texture=null; metal.normal_scale=0.08; metal.roughness=0.65
	var wood := mat("old_wood",Color("3b2e25"))
	if id=="villager":
		cleaver(root,metal)
	elif id in ["soldier","commander","shade"]:
		blade(root,2.2 if id=="commander" else 1.8,metal)
		if id=="commander":
			for index in range(6):
				Regalia.plate(root,Vector3(0,0.05,-0.45-index*0.21),Vector3(0.025,0.012,0.07),Regalia.gold()).rotation.x = PI/2
	elif id=="gravedigger":
		Art.beam(root,Vector3(0.4,0,0),Vector3(0.4,0,-2.35),0.075,wood)
		spade(root,metal)
		Art.beam(root,Vector3(0.4,0,0),Vector3(0.4,0,-0.5),0.09,metal)
	elif id=="warden":
		Art.beam(root,Vector3(0,0,0.2),Vector3(0,0,-2.5),0.09,wood)
		var hammer := Art.cylinder(root,Vector3(0,0,-2.55),0.38,0.38,1.2,metal,24)
		hammer.rotation.z = PI/2
		for side in [-1,1]:
			var band := Art.cylinder(root,Vector3(side*0.48,0,-2.55),0.41,0.41,0.10,metal,24)
			band.rotation.z = PI/2
			Regalia.plate(root,Vector3(side*0.61,0,-2.55),Vector3(0.64,0.64,0.12),Regalia.metal()).rotation.y = PI/2
	elif id=="maldrek":
		Art.beam(root,Vector3(0,-0.95,0),Vector3(0,1.4,0),0.065,wood)
		# Cut crystal rather than a featureless luminous sphere.
		var gem:=SurfaceTool.new(); gem.begin(Mesh.PRIMITIVE_TRIANGLES)
		for side in range(8):
			var a:=Vector3(cos(side*TAU/8)*0.19,1.52,sin(side*TAU/8)*0.19)
			var b:=Vector3(cos((side+1)*TAU/8)*0.19,1.52,sin((side+1)*TAU/8)*0.19)
			for vertex in [a,b,Vector3(0,1.92,0),b,a,Vector3(0,1.30,0)]: gem.add_vertex(vertex)
		gem.generate_normals(); Art.mesh(root,gem.commit(),Vector3.ZERO,accent)
		for y in [-0.9,-0.4,0.1,0.6]: Regalia.band(root,Vector3(0,y,0),0.075,Regalia.gold(),0.014)
		for side in [-1,1]:
			Art.beam(root,Vector3(0,1,0),Vector3(side*0.25,1.45,0),0.05,metal)
			spike(root,Vector3(side*0.25,1.45,0),Vector3(side*0.18,1.85,0),0.06,metal)

static func cleaver(root: Node3D, material: Material) -> void:
	Art.beam(root,Vector3.ZERO,Vector3(0,0,-0.5),0.055,mat("old_wood",Color("3b2e25")))
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var outline := [Vector2(-0.07,-0.45),Vector2(-0.16,-1.5),Vector2(-0.08,-1.8),Vector2(0.27,-1.66),Vector2(0.32,-0.78),Vector2(0.15,-0.52)]
	for side in [-1,1]:
		for index in range(outline.size()):
			var a: Vector2 = outline[index]
			var b: Vector2 = outline[(index+1)%outline.size()]
			for vertex in [Vector3(0.06,side*0.025,-1.05),Vector3(a.x,side*0.025,a.y),Vector3(b.x,side*0.025,b.y)]: surface.add_vertex(vertex)
	surface.generate_normals()
	var steel := material.duplicate() as StandardMaterial3D
	steel.cull_mode = BaseMaterial3D.CULL_DISABLED
	Art.mesh(root,surface.commit(),Vector3.ZERO,steel)

static func build(id: String, actor: CharacterBody3D, root: Node3D, pivot: Node3D, accent: StandardMaterial3D) -> void:
	root.set_meta("hostile_model",id)
	accent.roughness = 0.55
	var rig: Dictionary
	var imported_ids := {"shade":"maldrek","villager":"oren","commander":"fallen-commander","warden":"iron-warden","thorn":"thorn-beast","maldrek":"maldrek","gravedigger":"gravedigger"}
	var imported: bool = imported_ids.has(id)
	if imported:
		rig = preload("res://game/presentation/meshy_models.gd").build(root,imported_ids[id],pivot if id!="thorn" else null,0.70 if id=="shade" else 1.0)
		if id in ["villager","shade"]:
			# Reuse the detailed artisan as a corrupted butcher; isolate materials from Oren.
			for instance in root.find_children("*","MeshInstance3D",true,false):
				var variant: ShaderMaterial=instance.material_override.duplicate()
				variant.set_shader_parameter("variant_tint",Color(0.56,0.66,0.57) if id=="villager" else Color(0.60,0.52,0.82))
				variant.set_shader_parameter("enemy_surface",true)
				instance.material_override=variant
	elif id in ["soldier","commander","warden"]:
		rig = armor(root,id,accent)
	elif id in ["hound","thorn"]:
		rig = beast(root,pivot,id=="thorn",accent)
	else:
		rig = robes(root,id,accent)
	if id not in ["hound","thorn"]:
		var appearance:=Node3D.new(); appearance.name="WeaponAppearance"; pivot.add_child(appearance)
		weapon(appearance,id,accent)
		if id=="villager": appearance.scale=Vector3.ONE*0.62
		if id=="warden": appearance.scale=Vector3.ONE*0.82
		if id=="gravedigger": appearance.scale.z=0.75
		rig.weapon_visual=appearance
		rig.rest_weapon_angle=0.0 if id=="maldrek" else (-0.38 if id in ["warden","gravedigger"] else -0.42)
		rig.grip_local=Vector3(0.4,0,-0.05) if id=="gravedigger" else Vector3.ZERO
		if imported: preload("res://game/presentation/hostile_grip.gd").configure(rig,pivot,id)
	if id not in ["hound","thorn"] and not imported:
		var arm := mat("arm_leather",Color("333531"),0.25)
		var scale: float = 1.3 if id=="commander" else (1.55 if id=="warden" else 0.95)
		var shoulder := Vector3(0.4,1.42,0)*scale-pivot.position
		if id in ["villager","shade","maldrek","gravedigger"]:
			var height: float = 2.35 if id=="maldrek" else (2.6 if id=="gravedigger" else 1.65)
			shoulder = Vector3(0.35,height*0.74,0)-pivot.position
		var grip := Vector3(0.4,0,-0.5) if id=="gravedigger" else Vector3(0,0,-0.05)
		var elbow := Vector3(0.4,-0.05,0.1) if id=="soldier" else (shoulder+grip)*0.5+Vector3(0,-0.2,0.12)
		if id in ["soldier","commander","warden"]:
			Regalia.armored_arm(pivot,shoulder,elbow,grip,scale)
		else:
			joint(pivot,shoulder,elbow,0.115*maxf(1,scale),arm)
			joint(pivot,elbow,grip,0.09*maxf(1,scale),arm)
			orb(pivot,grip,Vector3(0.105,0.09,0.13),arm)
	var warning := MeshInstance3D.new()
	warning.name = "AttackTelegraph"
	var ring := TorusMesh.new()
	ring.inner_radius = 0.65
	ring.outer_radius = 0.69
	ring.rings = 40
	ring.ring_segments = 6
	warning.mesh = ring
	var signal_mat := mat("telegraph",Color("d9b46a"))
	signal_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	signal_mat.emission_enabled = true
	signal_mat.emission = Color("bc8132")
	warning.material_override = signal_mat
	warning.position.y = 0.08
	warning.hide()
	root.add_child(warning)
	rig.warning = warning
	var animation := Pose.new()
	animation.setup(actor,rig)
	root.add_child(animation)
