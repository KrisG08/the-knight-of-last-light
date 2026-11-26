extends RefCounted

static func build(region: Node3D) -> void:
	region.points = {"spawn": Vector3(0, 0.1, 7), "checkpoint": Vector3(-7, 0, 5), "peaks_exit": Vector3(0, 0, 9), "mine": Vector3(-19, 0, -16), "bridge": Vector3(0, 0, -24), "fortress": Vector3(0, 0, -65), "citadel_gate": Vector3(23, 0, -69), "peaks_shortcut": Vector3(19, 0, -39)}
	region.box(Vector3(0, -0.5, -6), Vector3(64, 1, 40), Color("777d83"))
	region.box(Vector3(0, -0.5, -57), Vector3(64, 1, 46), Color("777d83"))
	# A real gap separates the two plateaus. Navigation excludes the void.
	region.box(Vector3(0, -0.25, -30), Vector3(5, 0.5, 10), Color("9c9790"))
	region.obstacles.append(Rect2(-32, -34, 30, 8))
	region.obstacles.append(Rect2(2, -34, 30, 8))
	for x in [-2.35, 2.35]:
		region.box(Vector3(x, 0.65, -30), Vector3(0.3, 1.3, 10), Color("555d65"))
	# Distant gorge floor is visual only; falling uses the existing safe recovery.
	region.box(Vector3(0, -10, -30), Vector3(64, 0.2, 8), Color("303b47"), false)
	for x in [-32, 32]:
		region.box(Vector3(x, 4, -33), Vector3(1, 8, 94), Color("565e69"))
	for z in [-80, 14]:
		region.box(Vector3(0, 3, z), Vector3(64, 6, 1), Color("565e69"))
	region.lantern(region.points.checkpoint, "PEAKS LANTERN\nE · Activate / rest")
	region.label(Vector3(0, 3, 9), "ORDER'S RUINS\nE · Return", 0.003)
	region.box(Vector3(0, 0.02, -6), Vector3(5, 0.04, 37), Color("9a9e9e"), false)
	region.box(Vector3(0, 0.02, -50), Vector3(5, 0.04, 31), Color("9a9e9e"), false)
	for x in [-27, -11]:
		region.box(Vector3(x, 2, -15), Vector3(1, 4, 17), Color("515760"))
	for z in [-7, -22]:
		region.box(Vector3(-19, 3.5, z), Vector3(17, 0.6, 1), Color("6d6253"), false)
	region.box(Vector3(-22, 0.7, -16), Vector3(3, 1.4, 3), Color("494c52"))
	region.label(Vector3(-19, 4.5, -8), "ABANDONED MINE", 0.004)
	region.label(Vector3(0, 3, -24), "RIDGE BRIDGE\nKeep inside the rails", 0.003)
	# The east service path returns directly to the bridge after opening north bar.
	region.box(Vector3(19, 0.02, -51), Vector3(4, 0.04, 29), Color("9a9e9e"), false)
	region.box(Vector3(10, 0.025, -63), Vector3(22, 0.05, 4), Color("9a9e9e"), false)
	region.box(Vector3(9, 2, -44), Vector3(1, 4, 16), Color("565e69"))
	region.box(Vector3(12, 2, -36), Vector3(6, 4, 1), Color("565e69"))
	region.box(Vector3(26, 2, -36), Vector3(8, 4, 1), Color("565e69"))
	region.peaks_shortcut = region.box(Vector3(19, 1.6, -36), Vector3(5, 3.2, 0.6), Color("686351"))
	region.label(Vector3(19, 3.6, -36), "SERVICE BAR\nOpen from fortress side", 0.003)
	region.interact_colliders.fortress = region.box(Vector3(0, 3, -69), Vector3(14, 6, 5), Color("656a72"))
	region.label(Vector3(0, 7, -67), "FORGE FORTRESS\nE · Enter Iron Warden arena", 0.004)
	region.citadel_ward = region.box(Vector3(23, 2, -70), Vector3(6, 4, 0.6), Color("714c97"))
	region.interact_colliders.citadel_gate = region.citadel_ward
	region.citadel_label = region.label(Vector3(23, 4.4, -70), "ECLIPSE CITADEL\nFour broken seals required", 0.0035)
	region.build_navigation(Rect2(-32, -80, 64, 94), 1.0)

static func build_forge(region: Node3D) -> void:
	region.points = {"spawn": Vector3(0, 0.1, 9), "checkpoint": Vector3(0, 0, 9), "forge_exit": Vector3(0, 0, 10), "forge_seal": Vector3(0, 0, -9)}
	region.box(Vector3(0, -0.5, 0), Vector3(24, 1, 24), Color("59575b"))
	for x in [-12, 12]:
		region.box(Vector3(x, 3, 0), Vector3(1, 6, 24), Color("6b6564"))
		for z in [-7, 0, 7]:
			region.lantern(Vector3(x * 0.85, 0, z), "FORGE EMBERS")
	region.box(Vector3(0, 3, -12), Vector3(24, 6, 1), Color("6b6564"))
	for x in [-7, 7]:
		region.box(Vector3(x, 3, 12), Vector3(10, 6, 1), Color("6b6564"))
	region.entrance_barrier = region.box(Vector3(0, 2, 11.5), Vector3(4, 4, 0.6), Color("a68468"))
	region.entrance_barrier.hide()
	region.entrance_barrier.collision_layer = 0
	region.seal = region.box(Vector3(0, 1, -9), Vector3(1, 2, 1), Color("ddaa70"), false)
	region.seal_label = region.label(Vector3(0, 3, -9), "FORGE SEAL", 0.004)
	region.label(Vector3(0, 3, 11), "ASHEN PEAKS\nE · Return outside battle", 0.003)

