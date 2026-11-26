extends RefCounted

# Hand-authored roadside composition. No campaign facts or random encounters.
const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")

static func build(region: Node3D, road: Array, height: Callable) -> void:
	var root := Node3D.new()
	root.name = "KingsRoadSettlement"
	region.add_child(root)
	var batches: Dictionary = {}
	var rng := RandomNumberGenerator.new()
	rng.seed = 4217
	# The old paved center remains readable inside the wider dirt shoulder.
	var stones: Array[Transform3D] = []
	for segment in range(road.size()-1):
		var start: Vector3 = road[segment]
		var finish: Vector3 = road[segment+1]
		var forward := (finish-start).normalized()
		var side := forward.cross(Vector3.UP)
		var steps := int(start.distance_to(finish)/0.85)
		for row in range(steps):
			var center := start.lerp(finish,(row+0.5)/steps)
			for column in range(5):
				if rng.randf()<0.19:
					continue
				var at := center+side*((column-2)*0.65+rng.randf_range(-0.06,0.06))
				at.y = 0.014+rng.randf_range(-0.003,0.003)
				stones.append(Transform3D(Basis(Vector3.UP,atan2(forward.x,forward.z)+rng.randf_range(-0.08,0.08)).scaled(Vector3(0.6,0.022,0.77)),at))
		# Paired worn boundary stones make bends legible without floating arrows.
		for offset in [-1,1]:
			var at: Vector3 = start.lerp(finish,0.55)+side*offset*3.4
			Kit.piece(batches,Art.stone(),at+Vector3.UP*0.35,Vector3(0.35,0.7,0.35))
	var stone_mesh := BoxMesh.new()
	stone_mesh.size = Vector3.ONE
	Dressing.instances(root,stone_mesh,Art.stone(),stones)
	# Old estate boundary: interrupted runs, never across the walking corridor.
	for run in [[Vector3(-17,0,68),Vector3(-20,0,42)],[Vector3(19,0,33),Vector3(23,0,7)],[Vector3(-14,0,-7),Vector3(-20,0,-34)]]:
		fence(batches,run[0],run[1],height)
	watchtower(region,root,batches,Vector3(24,0,12),height)
	cart(region,root,batches,Vector3(-17,0,47),height)
	graveyard(root,batches,Vector3(-27,0,-27),height)
	# Small covered roadside shelter, visibly open toward the road.
	var shelter := Vector3(18,0,56)
	shelter.y = height.call(shelter.x,shelter.z)
	for x in [-2.5,2.5]:
		for z in [-1.6,1.6]:
			Kit.beam(batches,shelter+Vector3(x,0,z),shelter+Vector3(x,3,z),0.22)
	for x in [-2.5,0,2.5]:
		Kit.beam(batches,shelter+Vector3(x,3,-2.1),shelter+Vector3(x,4.2,0),0.18)
		Kit.beam(batches,shelter+Vector3(x,4.2,0),shelter+Vector3(x,3,2.1),0.18)
	for side in [-1,1]:
		Kit.piece(batches,Kit.wood(),shelter+Vector3(0,3.6,side*1.05),Vector3(5.8,0.13,2.45),Basis(Vector3.RIGHT,side*0.52))
	Kit.piece(batches,Kit.wood(),shelter+Vector3(0,0.65,-1.2),Vector3(4.5,0.18,0.6))
	Kit.torch(root,shelter+Vector3(-2.5,1.8,1.6),Vector3.FORWARD)
	# Road signs and lanterns mark a rhythm, rather than an illuminated fence.
	for at in [Vector3(5,0,67),Vector3(1,0,26),Vector3(17,0,-12),Vector3(-6,0,-39),Vector3(5,0,-90)]:
		Kit.beam(batches,at,at+Vector3.UP*2.5,0.16)
		Kit.piece(batches,Kit.wood(),at+Vector3(0,2.15,0),Vector3(1.8,0.35,0.12),Basis(Vector3.FORWARD,0.08))
		Art.lantern(root,at+Vector3(0.6,0,0))
	Kit.flush(root,batches)

static func fence(batches: Dictionary, start: Vector3, finish: Vector3, height: Callable) -> void:
	var count := int(start.distance_to(finish)/2.5)
	for index in range(count+1):
		var at := start.lerp(finish,float(index)/count)
		at.y = height.call(at.x,at.z)
		Kit.beam(batches,at,at+Vector3(0.04,1.45,0),0.16)
		if index==count or index%4==2:
			continue
		var next := start.lerp(finish,float(index+1)/count)
		next.y = height.call(next.x,next.z)
		for y in [0.5,1.15]:
			Kit.beam(batches,at+Vector3.UP*y,next+Vector3.UP*(y-0.08),0.1)

static func watchtower(region: Node3D, root: Node3D, batches: Dictionary, at: Vector3, height: Callable) -> void:
	at.y = height.call(at.x,at.z)
	# Solid foundations match the visible walls; central road remains untouched.
	for side in [-1,1]:
		var wall := at+Vector3(side*3,2.6,0)
		region.box(wall,Vector3(0.9,5.2,6.8),Color("59605c")).name = "RoadTowerWall"
		for z in [-3,3]:
			Kit.piece(batches,Art.stone(),at+Vector3(side*3.4,2,z),Vector3(1.1,4,1.2))
	region.box(at+Vector3(0,2.2,-3),Vector3(6,4.4,0.9),Color("59605c"))
	Art.pointed_arch(root,at+Vector3(0,0,3),5.2,5.8)
	for side in [-1,1]:
		Kit.beam(batches,at+Vector3(side*3.3,4.5,-3.2),at+Vector3(side*3.3,7,0),0.2)
		Kit.beam(batches,at+Vector3(side*3.3,7,0),at+Vector3(side*3.3,4.5,3.2),0.2)
		for z in [-2,-1,0,1,2]:
			Kit.piece(batches,Art.stone(),at+Vector3(side*3,5.5,z*1.3),Vector3(1,0.65,0.75))
	# Surviving upper watch platform and broken cross braces.
	Kit.piece(batches,Kit.wood(),at+Vector3(0,4.4,0),Vector3(6.4,0.25,6.4))
	Kit.beam(batches,at+Vector3(-3,0,3.3),at+Vector3(-3,4.3,0),0.25)
	Dressing.rubble(root,at+Vector3(1,0,5),38,2.2)
	Art.lantern(root,at+Vector3(-2,0,4.4))
	Kit.torch(root,at+Vector3(-2.9,2,3.5),Vector3.BACK)
	Kit.torch(root,at+Vector3(2.9,2,3.5),Vector3.BACK)

static func cart(region: Node3D, root: Node3D, batches: Dictionary, at: Vector3, height: Callable) -> void:
	at.y = height.call(at.x,at.z)
	var body: Node3D = region.box(at+Vector3.UP,Vector3(2.4,1.8,3.8),Color.BLACK)
	body.name = "AbandonedCartCollision"
	body.get_child(0).hide()
	Kit.piece(batches,Kit.wood(),at+Vector3.UP*0.9,Vector3(2.4,0.2,3.8))
	for side in [-1,1]:
		for y in [1.2,1.55,1.9]:
			Kit.piece(batches,Kit.wood(),at+Vector3(side*1.15,y,0),Vector3(0.12,0.22,3.8))
		for z in [-1.35,1.35]:
			var center := at+Vector3(side*1.35,0.7,z)
			var wheel := TorusMesh.new()
			wheel.inner_radius = 0.52
			wheel.outer_radius = 0.67
			wheel.rings = 16
			wheel.ring_segments = 8
			Art.mesh(root,wheel,center,Kit.wood()).rotation.z = PI/2
			for spoke in range(6):
				var angle := spoke*PI/3
				Kit.beam(batches,center,center+Vector3(0,sin(angle),cos(angle))*0.57,0.07)
		Kit.beam(batches,at+Vector3(side*0.8,0.8,-1.5),at+Vector3(side*0.8,0.25,-4.5),0.14)
	for offset in [Vector3(-0.5,1.3,0.4),Vector3(0.5,1.2,-0.7)]:
		Kit.piece(batches,Kit.wood(),at+offset,Vector3(0.9,0.7,0.9))

static func graveyard(root: Node3D, batches: Dictionary, at: Vector3, height: Callable) -> void:
	for row in range(3):
		for column in range(3):
			var grave := at+Vector3(column*2.4,0,row*3)
			grave.y = height.call(grave.x,grave.z)
			var lean := Basis(Vector3.FORWARD,(column-1)*0.12)
			Kit.piece(batches,Art.stone(),grave+Vector3.UP*0.65,Vector3(0.5,1.3,0.22),lean)
			Kit.piece(batches,Art.stone(),grave+Vector3.UP*0.95,Vector3(0.95,0.25,0.24),lean)
			Kit.piece(batches,Art.stone(),grave+Vector3(0,0.08,1),Vector3(1.2,0.16,2))
	fence(batches,at+Vector3(-2,0,-2),at+Vector3(-2,0,9),height)
	Dressing.tree(root,at+Vector3(5,0,8),1.4)
