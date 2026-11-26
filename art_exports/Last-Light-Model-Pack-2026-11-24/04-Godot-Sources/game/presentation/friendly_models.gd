extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Knight = preload("res://game/presentation/scanned_knight.gd")

static func sphere(root: Node3D, at: Vector3, radius: float, scale: Vector3, material: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius*2
	mesh.radial_segments = 20
	mesh.rings = 10
	var result := Art.mesh(root,mesh,at,material)
	result.scale = scale
	return result

static func build(root: Node3D, kind: String, weapon: Node3D) -> Dictionary:
	if kind in ["oren","lyra","cael","survivor"]:
		var imported := preload("res://game/presentation/meshy_models.gd")
		if kind=="cael":
			weapon.position = Vector3(0.28,1.42,0)
		elif kind=="lyra":
			weapon.position.y = 1.15
		var result: Dictionary = imported.build(root,"oren" if kind=="survivor" else kind,weapon)
		if kind=="survivor":
			for instance in root.find_children("*","MeshInstance3D",true,false):
				var variant: ShaderMaterial=instance.material_override.duplicate()
				variant.set_shader_parameter("variant_tint",Color(0.72,0.83,0.91))
				instance.material_override=variant
		if kind in ["cael","lyra"]:
			var equipment:=Node3D.new(); equipment.name="ForgedWeapon"; weapon.add_child(equipment)
			var bounds: AABB=result.right_arm.get_child(0).mesh.get_aabb()
			var palm:=bounds.position+Vector3(bounds.size.x*0.5,bounds.size.y*0.15,bounds.size.z*0.5)
			# Both nodes share the weapon parent, including during off-tree region authoring.
			equipment.position=result.right_arm.transform*palm
			equipment.rotation.x=-0.5
			equipment.scale=Vector3(0.65,0.65,0.75) if kind=="lyra" else Vector3.ONE*0.85
			preload("res://game/presentation/hostile_models.gd").blade(equipment,0.9 if kind=="lyra" else 1.35,Art.material("friendly_forged_steel",Color("7c858b"),0.45))
		return result
	if kind=="cael":
		var rig := Knight.build(root,weapon)
		var cloak := SurfaceTool.new()
		cloak.begin(Mesh.PRIMITIVE_TRIANGLES)
		for vertex in [Vector3(-0.28,1.42,0.22),Vector3(0.28,1.42,0.22),Vector3(-0.37,0.45,0.33),Vector3(0.28,1.42,0.22),Vector3(0.37,0.45,0.33),Vector3(-0.37,0.45,0.33)]:
			cloak.set_uv(Vector2(vertex.x+0.5,1.42-vertex.y))
			cloak.add_vertex(vertex)
		cloak.generate_normals()
		var fabric := ShaderMaterial.new()
		fabric.shader = preload("res://assets/materials/weathered_canvas.gdshader")
		fabric.set_shader_parameter("cloth_color",Color("38475e"))
		Art.mesh(root,cloak.commit(),Vector3.ZERO,fabric)
		return rig
	var scout := kind=="lyra"
	var smith := kind=="oren"
	var cloth := Art.material("friendly_"+kind,Color("425f53") if scout else (Color("625244") if smith else Color("665f59")))
	var leather := Art.material("friendly_leather",Color("382e27"))
	var skin := Art.material("friendly_skin",Color("bca187"))
	Art.cylinder(root,Vector3(0,1.13,0),0.23,0.29,0.58,cloth,16)
	Art.cylinder(root,Vector3(0,0.88,0),0.27,0.22,0.25,cloth,16)
	Art.cylinder(root,Vector3(0,0.92,0),0.25,0.25,0.09,leather,16)
	Art.cylinder(root,Vector3(0,1.46,0),0.085,0.09,0.15,skin,12)
	if scout:
		sphere(root,Vector3(0,1.69,0.04),0.235,Vector3(1,1.15,1),cloth)
	sphere(root,Vector3(0,1.67,-0.065 if scout else 0),0.19,Vector3(0.9,1.17,0.92),skin)
	var dark := Art.material("friendly_features",Color("252725"))
	for side in [-1,1]:
		var face_z := -0.244 if scout else -0.175
		sphere(root,Vector3(side*0.065,1.71,face_z),0.018,Vector3(1.1,0.4,0.5),dark)
		Art.beam(root,Vector3(side*0.04,1.75,face_z+0.015),Vector3(side*0.09,1.745,face_z+0.02),0.01,dark)
		if not scout:
			sphere(root,Vector3(side*0.17,1.67,0),0.04,Vector3(0.65,1.4,0.8),skin)
		sphere(root,Vector3(side*0.29,1.34,0),0.15,Vector3(1,0.9,1),cloth)
		Art.beam(root,Vector3(side*0.3,1.31,0),Vector3(side*0.36,1.04,-0.04),0.085,cloth)
		Art.beam(root,Vector3(side*0.36,1.04,-0.04),Vector3(side*0.34,0.87,-0.12),0.065,skin)
		sphere(root,Vector3(side*0.34,0.86,-0.12),0.075,Vector3(0.8,1.1,0.7),skin)
	var legs: Array[Node3D] = []
	for side in [-1,1]:
		var leg := Node3D.new()
		leg.position = Vector3(side*0.14,0.86,0)
		root.add_child(leg)
		Art.cylinder(leg,Vector3(0,-0.2,0),0.09,0.115,0.4,cloth,12)
		Art.cylinder(leg,Vector3(0,-0.58,0),0.08,0.095,0.36,leather,12)
		sphere(leg,Vector3(0,-0.77,-0.06),0.12,Vector3(0.85,0.6,1.55),leather)
		legs.append(leg)
	sphere(root,Vector3(0,1.65,-0.265 if scout else -0.2),0.035,Vector3(0.7,1.2,0.9),skin)
	Art.beam(root,Vector3(-0.035,1.575,-0.225 if scout else -0.16),Vector3(0.035,1.575,-0.225 if scout else -0.16),0.007,Art.material("friendly_lips",Color("74584d")))
	Art.box(root,Vector3(0,0.92,-0.25),Vector3(0.08,0.075,0.04),Art.material("friendly_buckle",Color("8a7961"),0.6))
	Art.cylinder(root,Vector3(-0.24,0.83,0.05),0.08,0.08,0.19,leather,10)
	if not scout:
		sphere(root,Vector3(0,1.8,0.02),0.18,Vector3(0.95,0.57,0.85),Art.material("friendly_hair",Color("453b33")))
	if smith:
		# Leather apron, beard and hammer distinguish the blacksmith at a glance.
		var apron := SurfaceTool.new()
		apron.begin(Mesh.PRIMITIVE_TRIANGLES)
		for vertex in [Vector3(-0.17,1.35,-0.25),Vector3(0.17,1.35,-0.25),Vector3(-0.24,0.62,-0.27),Vector3(0.17,1.35,-0.25),Vector3(0.24,0.62,-0.27),Vector3(-0.24,0.62,-0.27)]:
			apron.add_vertex(vertex)
		apron.generate_normals()
		var apron_mat := leather.duplicate() as StandardMaterial3D
		apron_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		Art.mesh(root,apron.commit(),Vector3.ZERO,apron_mat)
		sphere(root,Vector3(0,1.54,-0.08),0.16,Vector3(0.9,0.85,0.8),Art.material("oren_beard",Color("5b5047")))
		Art.beam(root,Vector3(0.32,0.86,-0.12),Vector3(0.32,0.58,-0.24),0.035,leather)
		Art.box(root,Vector3(0.32,0.58,-0.24),Vector3(0.28,0.13,0.12),Art.material("iron",Color("343c40"),0.7))
	elif scout:
		Art.cylinder(root,Vector3(0.12,1.16,0.28),0.11,0.12,0.65,leather,12).rotation.z = -0.25
		for index in range(5):
			Art.beam(root,Vector3(0.04+index*0.035,1.4,0.28),Vector3(0.1+index*0.035,1.9,0.28),0.012,leather)
		var last := Vector3(-0.34,0.72,0.28)
		for index in range(1,9):
			var t: float = float(index)/8
			var point := Vector3(-0.34-sin(t*PI)*0.2,0.72+t*1.1,0.28)
			Art.beam(root,last,point,0.025,leather)
			last = point
		Art.beam(root,Vector3(-0.34,0.72,0.28),Vector3(-0.34,1.82,0.28),0.007,leather)
		weapon.position.y = 1.15
		Art.box(weapon,Vector3(0.35,-0.1,-0.35),Vector3(0.055,0.04,0.6),Art.material("iron",Color("71818a"),0.7))
	return {"legs":legs,"source":"Original friendly kit"}
