extends RefCounted
## Authored cells reuse registered stone, timber and iron materials.
const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")

static func gate(body: StaticBody3D, width: float, height: float) -> void:
	body.get_child(0).hide()
	var iron := Art.material("iron", Color("243239"), 0.75)
	var count := ceili(width / 0.23)
	for index in range(count + 1):
		var x := -width / 2 + width * index / count
		Art.cylinder(body, Vector3(x, 0, 0), 0.025, 0.025, height, iron, 8)
	for y in [-height * 0.43, 0, height * 0.43]:
		Art.box(body, Vector3(0, y, 0), Vector3(width, 0.07, 0.11), iron)
	for x in [-width * 0.46, width * 0.46]:
		for y in [-height * 0.32, height * 0.32]:
			Art.cylinder(body, Vector3(x, y, 0.09), 0.065, 0.065, 0.14, iron, 10).rotation.x = PI / 2
	var lock := Art.material("cell_lock", Color("978568"), 0.6)
	Art.box(body, Vector3(0.28, -0.08, 0.10), Vector3(0.19, 0.25, 0.13), lock)
	Art.box(body, Vector3(0.28, -0.07, 0.174), Vector3(0.025, 0.075, 0.014), iron)
	var hinge := Node3D.new()
	hinge.name = "DoorHinge"
	hinge.position.x = -width / 2
	body.add_child(hinge)
	for child in body.get_children():
		if child is MeshInstance3D and child.visible:
			child.reparent(hinge, false)
			child.position.x += width / 2

static func set_open(body: StaticBody3D, opened: bool) -> void:
	body.visible = true
	body.collision_layer = 0 if opened else 1
	var hinge := body.get_node_or_null("DoorHinge") as Node3D
	if hinge == null or body.get_meta("door_open", false) == opened: return
	body.set_meta("door_open", opened)
	var angle := -1.4 if opened else 0.0
	if body.is_inside_tree() and body.is_node_ready():
		body.create_tween().tween_property(hinge, "rotation:y", angle, 0.7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	else:
		hinge.rotation.y = angle

static func furnishings(root: Node3D, at: Vector3, width: float) -> void:
	var wood := Kit.wood()
	var iron := Art.material("iron", Color("243239"), 0.75)
	for index in range(4):
		Art.box(root, at + Vector3(-width * 0.30, 0.25, -0.8 + index * 0.28), Vector3(0.8, 0.09, 0.25), wood)
	for x in [-0.28, 0.28]:
		Art.box(root, at + Vector3(-width * 0.30 + x, 0.12, -0.35), Vector3(0.09, 0.25, 0.95), wood)
	Art.cylinder(root, at + Vector3(width * 0.29, 0.13, -0.6), 0.15, 0.19, 0.26, iron, 12)
	for side in [-1, 1]:
		for link in range(7):
			var torus := TorusMesh.new()
			torus.inner_radius = 0.035
			torus.outer_radius = 0.055
			torus.rings = 8
			torus.ring_segments = 6
			var chain := Art.mesh(root, torus, at + Vector3(side * width * 0.32, 1.7 - link * 0.09, -1.6), iron)
			chain.rotation.x = PI / 2
			chain.rotation.y = PI / 2 if link % 2 else 0

static func village(region: Node3D) -> void:
	var at: Vector3 = region.points.oren
	gate(region.captured_gate, 3.2, 2.5)
	var root := Node3D.new()
	root.name = "OrenHoldingCell"
	region.add_child(root)
	for side in [-1, 1]:
		region.box(at + Vector3(side * 1.85, 1.45, -0.3), Vector3(0.45, 2.9, 3.8), Color("59616a"))
	region.box(at + Vector3(0, 1.45, -2.0), Vector3(4.1, 2.9, 0.4), Color("59616a"))
	region.box(at + Vector3(0, 2.9, -0.3), Vector3(4.1, 0.25, 3.8), Color("45454e"))
	Art.pointed_arch(root, at + Vector3(0, 0, 1.46), 3.7, 3.4)
	furnishings(root, at, 3.2)
	Kit.torch(root, at + Vector3(2.15, 1.8, 1.55), Vector3.FORWARD, false)

static func citadel(region: Node3D) -> void:
	gate(region.prison_bars, 7.0, 3.0)
	var root := Node3D.new()
	root.name = "CitadelCaptiveQuarters"
	region.add_child(root)
	var at := Vector3(-19, 0, -20)
	for side in [-1, 1]:
		region.box(at + Vector3(side * 3.8, 1.8, -0.2), Vector3(0.5, 3.6, 4.5), Color("535563"))
	region.box(at + Vector3(0, 1.8, -2.4), Vector3(8.1, 3.6, 0.5), Color("535563"))
	furnishings(root, at, 7.0)
	Kit.torch(root, Vector3(-23, 2.1, -17.7), Vector3.FORWARD, false)
