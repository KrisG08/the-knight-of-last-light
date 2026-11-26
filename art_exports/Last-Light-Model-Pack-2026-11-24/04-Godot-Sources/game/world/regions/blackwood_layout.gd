extends RefCounted

static func extend_forest(region: Node3D) -> void:
	region.points.checkpoint = Vector3(-9, 0, 5)
	region.points.grove = Vector3(-12, 0, -58)
	region.points.forest_shortcut = Vector3(-19, 0, -33)
	region.points.order_gate = Vector3(22, 0, -66)
	region.lantern(region.points.checkpoint, "BLACKWOOD LANTERN\nE · Activate / rest")
	region.box(Vector3(-26.5, 1.8, -30), Vector3(9, 3.6, 1), Color("394837"))
	region.box(Vector3(-2, 1.8, -30), Vector3(28, 3.6, 1), Color("394837"))
	region.forest_shortcut = region.box(Vector3(-19, 1.8, -30), Vector3(6, 3.6, 1), Color("657750"))
	region.label(Vector3(-19, 4, -30), "ROOT BAR\nOpen from northern side", 0.0035)
	region.box(Vector3(20, 0.02, -38), Vector3(4, 0.04, 39), Color("77715a"), false)
	region.box(Vector3(0, 0.02, -54), Vector3(44, 0.04, 4), Color("77715a"), false)
	region.box(Vector3(-19, 0.02, -44), Vector3(4, 0.04, 30), Color("77715a"), false)
	region.box(Vector3(22, 0.02, -61), Vector3(4, 0.04, 19), Color("77715a"), false)
	for x in [17, 25]:
		for z in [-22, -30]:
			region.box(Vector3(x, 3, z), Vector3(0.6, 6, 0.6), Color("777362"))
	region.box(Vector3(21, 6, -26), Vector3(9, 0.7, 9), Color("4a5148"), false)
	region.label(Vector3(21, 7.5, -26), "SCOUT WATCHTOWER\nNorth to root shrine", 0.005)
	region.box(Vector3(-5, 0.025, -43), Vector3(14, 0.05, 8), Color("344b3a"), false)
	region.label(Vector3(-5, 1.8, -43), "BLIGHTED HOLLOW", 0.003)
	for x in [-28, -24, -8, 0, 8, 28]:
		for z in [-38, -48, -65, -72]:
			region.box(Vector3(x, 2, z), Vector3(0.8, 4, 0.8), Color("4b4037"))
			region.box(Vector3(x, 5.5, z), Vector3(4, 3.5, 4), Color("344b3c"), false)
	for x in [-15, -9]:
		region.box(Vector3(x, 2.5, -59), Vector3(1, 5, 1), Color("67745c"))
	region.box(Vector3(-12, 5, -59), Vector3(7, 0.8, 1), Color("67745c"))
	region.label(Vector3(-12, 6.4, -59), "ROOT SHRINE\nE · Enter guardian grove", 0.005)
	region.order_ward = region.box(Vector3(22, 1.6, -66), Vector3(6, 3.2, 0.6), Color("714c97"))
	region.interact_colliders.order_gate = region.order_ward
	region.order_label = region.label(Vector3(22, 3.7, -66), "ORDER'S RUINS\nRoot Seal intact", 0.004)

static func build_grove(region: Node3D) -> void:
	region.points = {"spawn": Vector3(0, 0.1, 9), "checkpoint": Vector3(0, 0, 9), "grove_exit": Vector3(0, 0, 10), "root_seal": Vector3(0, 0, -9)}
	region.box(Vector3(0, -0.5, 0), Vector3(24, 1, 24), Color("414f3b"))
	for x in [-12, 12]:
		region.box(Vector3(x, 2.5, 0), Vector3(1, 5, 24), Color("42583c"))
	region.box(Vector3(0, 2.5, -12), Vector3(24, 5, 1), Color("42583c"))
	for x in [-7, 7]:
		region.box(Vector3(x, 2.5, 12), Vector3(10, 5, 1), Color("42583c"))
	region.entrance_barrier = region.box(Vector3(0, 2, 11.5), Vector3(4, 4, 0.6), Color("7b8a60"))
	region.entrance_barrier.hide()
	region.entrance_barrier.collision_layer = 0
	for x in [-10, 10]:
		for z in [-8, 0, 8]:
			region.box(Vector3(x, 2.5, z), Vector3(1, 5, 1), Color("594c39"), false)
	region.seal = region.box(Vector3(0, 1, -9), Vector3(1, 2, 1), Color("b9bd7f"), false)
	region.seal_label = region.label(Vector3(0, 3, -9), "ROOT SEAL", 0.004)
	region.label(Vector3(0, 3.5, 11), "BLACKWOOD\nE · Leave before battle / after victory", 0.003)

