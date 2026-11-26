extends RefCounted

# Authored traces of the village's former trades; no pickups or campaign state.
const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")

static func build(region: Node3D, parent: Node3D) -> void:
	var root := Node3D.new()
	root.name = "VillageTrades"
	parent.add_child(root)
	var batches: Dictionary = {}
	market(region,root,batches,Vector3(-29,0,17),false)
	market(region,root,batches,Vector3(29,0,16),true)
	# Storage belongs beside the workshops, outside the north/south streets.
	for at in [Vector3(-34,0,-7),Vector3(34,0,-8),Vector3(-25,0,34),Vector3(25,0,34)]:
		proxy(region,at+Vector3(0.4,0.75,-0.55),Vector3(1.8,1.5,2.7),"VillageStorageCollision")
		barrel(root,at)
		barrel(root,at+Vector3(0.9,0,0.25))
		crate(batches,at+Vector3(0.4,0,-1.3),Vector3(1.1,0.9,1.0))
		crate(batches,at+Vector3(0.5,0.9,-1.3),Vector3(0.75,0.65,0.75))
	for side in [-1,1]:
		woodpile(root,Vector3(side*16.8,0,27))
		proxy(region,Vector3(side*16.8+0.6,0.6,27),Vector3(1.8,1.2,2.1),"VillageWoodpileCollision")
		trough(region,batches,Vector3(side*25,0,22))
		# Broken picket enclosure frames a pocket yard, with a wide open entrance.
		for z in [11.0,22.0]:
			var start := Vector3(side*34,0,z)
			for index in range(6):
				var at := start+Vector3(side*index*0.65,0,0)
				Kit.piece(batches,Kit.wood(),at+Vector3.UP*0.65,Vector3(0.1,1.3+(index%2)*0.13,0.14))
			for y in [0.4,0.95]:
				Kit.piece(batches,Kit.wood(),start+Vector3(side*1.6,y,0),Vector3(3.4,0.1,0.12))
		# Visible gutters and downpipes attach to the existing first street houses.
		Kit.piece(batches,Art.material("village_weathered_iron",Color("3c4441"),0.55),Vector3(side*15.06,2.1,24.8),Vector3(0.14,4.2,0.14))
		Dressing.rubble(root,Vector3(side*35,0,20),25,1.1)
	# A line above the route tells a domestic story without obstructing movement.
	for at in [Vector3(-16,0,29),Vector3(-25,0,24)]:
		Kit.beam(batches,at,at+Vector3.UP*4,0.12)
	var line_start := Vector3(-16,3.8,29)
	var line_end := Vector3(-25,3.8,24)
	Art.beam(root,line_start,line_end,0.018,Kit.wood())
	var cloth := canvas(Color("847a65"))
	for index in range(4):
		var at := line_start.lerp(line_end,0.2+index*0.18)
		var sheet := PlaneMesh.new()
		sheet.size = Vector2(0.9,1.1+(index%2)*0.25)
		var visual := Art.mesh(root,sheet,at-Vector3.UP*0.6,cloth)
		visual.rotation = Vector3(PI/2,-0.5,0)
	Kit.flush(root,batches)

static func market(region: Node3D, root: Node3D, batches: Dictionary, at: Vector3, torn: bool) -> void:
	proxy(region,at+Vector3(0,3.2,0),Vector3(5.4,0.45,3),"MarketCanopyCollision")
	# The physical counter also reserves its footprint in the navigation mesh.
	var counter: Node3D = region.box(at+Vector3(0,0.65,0),Vector3(4.6,1.3,1.5),Color.BLACK)
	counter.name = "MarketCounterCollision"
	counter.get_child(0).hide()
	Kit.piece(batches,Kit.wood(),at+Vector3(0,0.65,0),Vector3(4.6,1.3,1.5))
	for x in [-2.5,2.5]:
		for z in [-1.2,1.2]:
			Kit.beam(batches,at+Vector3(x,0,z),at+Vector3(x,3.4,z),0.13)
		Kit.beam(batches,at+Vector3(x,3.4,-1.4),at+Vector3(x,3,1.5),0.12)
	Kit.beam(batches,at+Vector3(-2.6,3.4,-1.4),at+Vector3(2.6,3.4,-1.4),0.12)
	# Separate sagging strips leave actual gaps in the abandoned canopy.
	var cloth := canvas(Color("59413b") if torn else Color("81745b"))
	for strip in range(8):
		if torn and strip in [2,5]:
			continue
		var surface := SurfaceTool.new()
		surface.begin(Mesh.PRIMITIVE_TRIANGLES)
		var x: float = -2.6+strip*0.65
		var a := Vector3(x,3.4,-1.5)
		var b := Vector3(x+0.63,3.4,-1.5)
		var c := Vector3(x,2.95,1.5)
		var d := Vector3(x+0.63,2.95,1.5)
		var middle := Vector3(x+0.31,2.96,0)
		for vertex in [a,b,middle,b,d,middle,d,c,middle,c,a,middle]:
			surface.set_uv(Vector2((vertex.x-x)/0.63,(vertex.z+1.5)/3.0))
			surface.add_vertex(vertex)
		surface.generate_normals()
		Art.mesh(root,surface.commit(),at,cloth)
	for x in [-1.5,0,1.5]:
		crate(batches,at+Vector3(x,1.3,0),Vector3(1.05,0.28,0.85))
	Kit.torch(root,at+Vector3(-2.45,1.9,1.2),Vector3.BACK)

static func crate(batches: Dictionary, at: Vector3, size: Vector3) -> void:
	Kit.piece(batches,Kit.wood(),at+Vector3.UP*size.y*0.5,size)
	var iron := Art.material("village_crate_bands",Color("303a3a"),0.6)
	for side in [-1,1]:
		Kit.piece(batches,iron,at+Vector3(side*size.x*0.36,size.y*0.5,0),Vector3(0.055,size.y+0.035,size.z+0.035))

static func barrel(root: Node3D, at: Vector3) -> void:
	Art.cylinder(root,at+Vector3.UP*0.22,0.34,0.43,0.44,Kit.wood(),14)
	Art.cylinder(root,at+Vector3.UP*0.66,0.43,0.34,0.44,Kit.wood(),14)
	for y in [0.12,0.44,0.78]:
		var ring := TorusMesh.new()
		ring.inner_radius = 0.35 if y!=0.44 else 0.415
		ring.outer_radius = ring.inner_radius+0.035
		ring.rings = 14
		ring.ring_segments = 6
		Art.mesh(root,ring,at+Vector3.UP*y,Art.material("village_barrel_iron",Color("343e3b"),0.65))

static func woodpile(root: Node3D, at: Vector3) -> void:
	for row in range(3):
		for column in range(4-row):
			var center := at+Vector3((column+row*0.5)*0.4,0.23+row*0.35,0)
			var log := Art.cylinder(root,center,0.2,0.18,2.1,Kit.wood(),9)
			log.rotation.x = PI/2

static func trough(region: Node3D, batches: Dictionary, at: Vector3) -> void:
	var collider: Node3D = region.box(at+Vector3.UP*0.45,Vector3(1.2,0.9,2.8),Color.BLACK)
	collider.name = "VillageTroughCollision"
	collider.get_child(0).hide()
	for side in [-1,1]:
		Kit.piece(batches,Art.stone(),at+Vector3(side*0.5,0.45,0),Vector3(0.2,0.9,2.8))
		Kit.piece(batches,Art.stone(),at+Vector3(0,0.45,side*1.3),Vector3(0.9,0.9,0.2))
	Kit.piece(batches,Art.material("trough_still_water",Color("263d3e"),0.3),at+Vector3.UP*0.6,Vector3(0.8,0.035,2.4))

static func proxy(region: Node3D, at: Vector3, size: Vector3, id: String) -> void:
	var body: Node3D = region.box(at,size,Color.BLACK)
	body.name = id
	body.get_child(0).hide()

static func canvas(tint: Color) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = preload("res://assets/materials/weathered_canvas.gdshader")
	result.set_shader_parameter("cloth_color",tint)
	return result
