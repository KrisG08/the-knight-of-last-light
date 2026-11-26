extends RefCounted

static func build(region: Node3D) -> void:
	region.points = {"spawn": Vector3(0,0.1,54), "checkpoint": Vector3(-7,0,38), "citadel_exit": Vector3(0,0,57), "citadel_depth": Vector3(0,0,-55), "prisoners": Vector3(-19,0,-16), "ritual_lore": Vector3(18,0,-35)}
	region.box(Vector3(0,-0.5,-1),Vector3(96,1,126),Color("514c5c"))
	for x in [-48,48]:
		region.box(Vector3(x,7,-1),Vector3(1,14,126),Color("625e70"))
	for z in [-64,62]:
		region.box(Vector3(0,6,z),Vector3(96,12,1),Color("625e70"))
	region.lantern(region.points.checkpoint,"CITADEL LANTERN\nE · Activate / rest")
	region.box(Vector3(0,0.02,-24),Vector3(5,0.04,65),Color("85808f"),false)
	for x in [-7,7]:
		for z in [-18,-33,-48]:
			region.box(Vector3(x,3,z),Vector3(1.5,6,1.5),Color("7c7486"))
	region.label(Vector3(0,5,-4),"ECLIPSE GATEHOUSE",0.004)
	region.label(Vector3(0,3,57),"ASHEN PEAKS\nE · Return",0.003)
	region.prison_bars = region.box(Vector3(-19,1.5,-18),Vector3(7,3,0.2),Color("727b87"))
	region.prison_survivors = Node3D.new()
	region.add_child(region.prison_survivors)
	for x in [-21,-17]:
		var survivor: Node3D = region.person(Vector3(x,0,-22),"SURVIVOR")
		survivor.reparent(region.prison_survivors,false)
	region.prison_label = region.label(Vector3(-19,4,-18),"PRISON\nE · Release after defeating jailer",0.003)
	region.label(Vector3(18,3,-35),"RITUAL INSCRIPTION\nE · Read",0.003)
	region.interact_colliders.citadel_depth = region.box(Vector3(0,3,-58),Vector3(12,6,3),Color("74607c"))
	region.label(Vector3(0,7,-56),"RITUAL ASCENT\nE · Face Maldrek",0.004)
	region.build_navigation(Rect2(-48,-64,96,126),1.0)

static func build_ritual(region: Node3D) -> void:
	region.points = {"spawn": Vector3(0,0.1,9), "checkpoint": Vector3(0,0,9), "ritual_exit": Vector3(0,0,10), "artifact": Vector3(0,0,-9)}
	region.box(Vector3(0,-0.5,0),Vector3(26,1,26),Color("4d4359"))
	for x in [-13,13]:
		region.box(Vector3(x,4,0),Vector3(1,8,26),Color("71647d"))
	region.box(Vector3(0,4,-13),Vector3(26,8,1),Color("71647d"))
	for x in [-7.5,7.5]:
		region.box(Vector3(x,4,13),Vector3(11,8,1),Color("71647d"))
	region.entrance_barrier = region.box(Vector3(0,2,12.5),Vector3(4,4,0.6),Color("b18abf"))
	region.entrance_barrier.hide()
	region.entrance_barrier.collision_layer = 0
	region.seal = region.box(Vector3(0,1.5,-9),Vector3(1.3,3,1.3),Color("b78bc9"),false)
	region.seal_label = region.label(Vector3(0,4,-9),"CENTRAL ARTIFACT\nDefeat Maldrek first",0.004)
	region.label(Vector3(0,3,12),"CITADEL\nE · Return outside battle",0.003)
	region.build_navigation(Rect2(-13,-13,26,26),1.0)
