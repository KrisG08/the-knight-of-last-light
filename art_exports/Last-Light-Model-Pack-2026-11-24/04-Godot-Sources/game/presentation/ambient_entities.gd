extends RefCounted
## Original scenery silhouettes; the sentinel reuses the credited knight mesh.
const Art = preload("res://game/presentation/art_kit.gd")
const Sources = preload("res://game/presentation/hostile_source_parts.gd")

static func orb(root: Node3D, at: Vector3, size: Vector3, mat: Material) -> void:
	var shape := SphereMesh.new()
	shape.radial_segments = 24
	shape.rings = 12
	var mesh := Art.mesh(root,shape,at,mat)
	mesh.scale = size

static func eyes(root: Node3D, y: float, z: float, spacing: float) -> void:
	var glow := Art.material("ambient_soul_eyes",Color("81b7af"))
	glow.emission_enabled = true
	glow.emission = Color("548c89")
	glow.emission_energy_multiplier = 1.4
	for side in [-1,1]: orb(root,Vector3(side*spacing,y,z),Vector3(0.035,0.018,0.025),glow)

static func wraith(root: Node3D) -> void:
	var cloth := Art.material("ambient_wraith_cloth",Color("293a3c"))
	cloth.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Corrugated, torn robe: actual curved geometry, not a billboard.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(18):
		for segment in range(64):
			for corner in [Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,0),Vector2(1,1),Vector2(0,1)]:
				var t: float = (row+corner.y)/18.0
				var a: float = (segment+corner.x)*TAU/64.0
				var radius := lerpf(0.6,0.22,t)+sin(a*12)*0.04
				var hem: float = (1-t)*pow(0.5+0.5*sin(a*7),3)*0.25
				surface.set_uv(Vector2(a/TAU,t))
				surface.add_vertex(Vector3(cos(a)*radius,0.3+t*1.65+hem,sin(a)*radius*0.7))
	surface.generate_normals()
	Art.mesh(root,surface.commit(),Vector3.ZERO,cloth)
	orb(root,Vector3(0,2.02,0),Vector3(0.34,0.43,0.3),cloth)
	orb(root,Vector3(0,2.03,-0.24),Vector3(0.23,0.28,0.06),Art.material("ambient_void",Color("050b0c")))
	eyes(root,2.05,-0.302,0.065)
	for side in [-1,1]:
		Art.beam(root,Vector3(side*0.2,1.8,0),Vector3(side*0.55,1.05,-0.12),0.14,cloth)
		for finger in range(4):
			Art.beam(root,Vector3(side*(0.5+finger*0.025),1.05,-0.13),Vector3(side*(0.49+finger*0.04),0.8,-0.19),0.012,Art.stone())

static func sentinel(root: Node3D) -> void:
	for part in Sources.prepare("strong-knight"):
		Art.mesh(root,Sources.prepare("strong-knight")[part],Sources.pivot("strong-knight",part),Art.stone())
	# Broken radial crown and ceremonial staff distinguish the effigy from enemies.
	for index in range(7):
		var angle := (index-3)*0.35
		Art.beam(root,Vector3(sin(angle)*0.2,1.9+cos(angle)*0.1,0),Vector3(sin(angle)*0.48,2.0+cos(angle)*0.45,0),0.035,Art.stone())
	Art.beam(root,Vector3(0.6,0,-0.15),Vector3(0.6,2.4,-0.15),0.045,Art.stone())
	eyes(root,1.77,-0.18,0.07)

static func gargoyle(root: Node3D) -> void:
	var stone := Art.stone()
	orb(root,Vector3(0,0.65,0),Vector3(0.48,0.72,0.4),stone)
	orb(root,Vector3(0,1.15,-0.15),Vector3(0.3,0.33,0.32),stone)
	orb(root,Vector3(0,1.05,-0.4),Vector3(0.22,0.15,0.23),stone)
	for side in [-1,1]:
		Art.beam(root,Vector3(side*0.16,1.25,0),Vector3(side*0.28,1.65,0.08),0.09,stone)
		Art.beam(root,Vector3(side*0.25,0.7,0),Vector3(side*0.45,0.25,-0.38),0.13,stone)
		orb(root,Vector3(side*0.37,0.16,-0.22),Vector3(0.22,0.15,0.4),stone)
		var points := [Vector3(side*0.2,0.8,0.15),Vector3(side*0.65,1.5,0.3),Vector3(side*1.35,1.7,0.4),Vector3(side*1.1,0.7,0.38),Vector3(side*0.8,0.85,0.32),Vector3(side*0.65,0.4,0.25)]
		var skin := SurfaceTool.new()
		skin.begin(Mesh.PRIMITIVE_TRIANGLES)
		for index in range(1,points.size()-1):
			for vertex in [points[0],points[index],points[index+1]]: skin.add_vertex(vertex)
		skin.generate_normals()
		var membrane := stone.duplicate() as StandardMaterial3D
		membrane.cull_mode = BaseMaterial3D.CULL_DISABLED
		Art.mesh(root,skin.commit(),Vector3.ZERO,membrane)
		for point in points.slice(1): Art.beam(root,points[0],point,0.035,stone)
	eyes(root,1.18,-0.43,0.09)
