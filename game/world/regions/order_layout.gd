extends RefCounted

static func build(region: Node3D) -> void:
	region.points = {"spawn": Vector3(0, 0.1, 7), "checkpoint": Vector3(-7, 0, 7), "order_exit": Vector3(0, 0, 9), "order_depth": Vector3(0, 0, -48), "cael": Vector3(-11, 0, -3), "expedition": Vector3(-19, 0, -43), "peaks_gate": Vector3(22, 0, -48)}
	region.order_ground = region.box(Vector3(0, -0.5, -21), Vector3(64, 1, 70), Color("64665b"))
	for x in [-32, 32]:
		region.box(Vector3(x, 2.5, -21), Vector3(1, 5, 70), Color("73786d"))
	for z in [-56, 14]:
		region.box(Vector3(0, 2.5, z), Vector3(64, 5, 1), Color("73786d"))
	region.box(Vector3(0, 0.02, -21), Vector3(5, 0.04, 64), Color("888773"), false)
	region.box(Vector3(-19, 0.025, -22), Vector3(4, 0.05, 52), Color("888773"), false)
	region.box(Vector3(-10, 0.03, -43), Vector3(25, 0.06, 4), Color("888773"), false)
	region.lantern(region.points.checkpoint, "ORDER LANTERN\nE · Activate / rest")
	region.label(Vector3(0, 3, 9), "BLACKWOOD\nE · Return", 0.003)
	region.cael = region.person(region.points.cael, "SIR CAEL\nE · Talk")
	# Open-air barracks: two entrances remain wide enough for both actors.
	for x in [-27, -11]:
		region.box(Vector3(x, 2, -25), Vector3(1, 4, 26), Color("73786d"))
	for z in [-12, -38]:
		for x in [-25, -13]:
			region.box(Vector3(x, 2, z), Vector3(4, 4, 1), Color("73786d"))
	for z in [-18, -25, -32]:
		region.box(Vector3(-24, 0.4, z), Vector3(2, 0.8, 3), Color("544f49"))
	region.label(Vector3(-19, 4.5, -13), "ORDER BARRACKS", 0.004)
	region.box(Vector3(0, 1, -25), Vector3(8, 2, 4), Color("5b6056"))
	for x in [8, 17, 26]:
		for z in [-19, -32]:
			region.box(Vector3(x, 2, z), Vector3(1, 4, 1), Color("929482"))
	region.label(Vector3(14, 4, -26), "COLLAPSED COURTYARD", 0.004)
	for x in [-25, -13]:
		region.box(Vector3(x, 2.5, -45), Vector3(1, 5, 12), Color("929482"))
	region.box(Vector3(-19, 5, -48), Vector3(13, 0.7, 1), Color("929482"), false)
	region.label(Vector3(-19, 5.8, -44), "MEMORIAL HALL", 0.004)
	region.expedition = region.box(region.points.expedition + Vector3(0, 0.8, 0), Vector3(1.2, 0.15, 0.8), Color("d2c69a"), false)
	region.label(region.points.expedition + Vector3(0, 2, 0), "EXPEDITION RECORD\nE · Read", 0.003)
	region.interact_colliders.order_depth = region.box(Vector3(0, 2, -50), Vector3(10, 4, 1), Color("535a63"))
	region.label(Vector3(0, 4, -49), "COMMANDER'S SANCTUM\nE · Enter", 0.0035)
	region.peaks_ward = region.box(Vector3(22, 1.6, -49), Vector3(6, 3.2, 0.6), Color("714c97"))
	region.interact_colliders.peaks_gate = region.peaks_ward
	region.peaks_label = region.label(Vector3(22, 3.8, -49), "ASHEN PEAKS\nBreak Oath Seal first", 0.0035)
	region.build_navigation(Rect2(-32, -56, 64, 70), 1.0)

static func build_sanctum(region: Node3D) -> void:
	region.points = {"spawn": Vector3(0, 0.1, 9), "checkpoint": Vector3(0, 0, 9), "sanctum_exit": Vector3(0, 0, 10), "oath_seal": Vector3(0, 0, -9)}
	region.box(Vector3(0, -0.5, 0), Vector3(24, 1, 24), Color("555b61"))
	for x in [-12, 12]:
		region.box(Vector3(x, 3, 0), Vector3(1, 6, 24), Color("737986"))
	region.box(Vector3(0, 3, -12), Vector3(24, 6, 1), Color("737986"))
	for x in [-7, 7]:
		region.box(Vector3(x, 3, 12), Vector3(10, 6, 1), Color("737986"))
	region.entrance_barrier = region.box(Vector3(0, 2, 11.5), Vector3(4, 4, 0.6), Color("9aa3bc"))
	region.entrance_barrier.hide()
	region.entrance_barrier.collision_layer = 0
	region.seal = region.box(Vector3(0, 1, -9), Vector3(1, 2, 1), Color("a6bde0"), false)
	region.seal_label = region.label(Vector3(0, 3, -9), "OATH SEAL", 0.004)
	region.label(Vector3(0, 3, 11), "ORDER'S RUINS\nE · Return outside battle", 0.003)

