extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "EclipseCitadelArchitecture"
	region.add_child(root)
	var stone := Art.stone()
	var iron := Art.material("iron",Color("243239"),0.75)
	var batches: Dictionary = {}
	# Dress the original six pillar colliders; no route or navmesh is changed.
	for child in region.get_children():
		if child is StaticBody3D and absf(child.position.x)==7 and child.position.y==3:
			child.get_child(0).hide()
	for x in [-7,7]:
		for z in [-18,-33,-48]:
			Art.cylinder(root,Vector3(x,3,z),0.72,0.62,6,stone,16)
			for y in [0.15,5.8]:
				Art.cylinder(root,Vector3(x,y,z),0.75,0.75,0.3,stone,16)
			Art.cylinder(root,Vector3(x,6.7,z),0.64,0,1.5,stone,8)
			Kit.torch(root,Vector3(x,3,z+0.76),Vector3.FORWARD,z==-33)
	for side in [-1,1]:
		for z in range(-60,60,6):
			Kit.piece(batches,stone,Vector3(side*47.45,7,z),Vector3(0.55,14,1.5))
			Kit.piece(batches,stone,Vector3(side*47.4,14.5,z),Vector3(0.65,0.5,1.9))
			Kit.piece(batches,stone,Vector3(side*48,15.5,z),Vector3(1.4,1.4,2.5))
		for z in [-62,60]:
			Art.cylinder(root,Vector3(side*49,10,z),4,3.6,20,stone,16)
			Art.cylinder(root,Vector3(side*49,24,z),4.1,0,8,stone,12)
	# Visible processional route runs between the pillars to the existing ascent.
	Dressing.pavers(root,Vector3(0,0.06,-24),4,60)
	Art.pointed_arch(root,Vector3(0,0,-55.9),10,10)
	var portal: Node3D = region.interact_colliders.citadel_depth
	portal.get_child(0).hide()
	Art.box(portal,Vector3.ZERO,Vector3(12,6,3),stone)
	Art.box(root,Vector3(0,2.9,-56.45),Vector3(5,5.8,0.12),Kit.wood())
	for x in [-2.4,0,2.4]:
		Kit.piece(batches,iron,Vector3(x,2.9,-56.3),Vector3(0.1,5.8,0.08))
	for y in [0.7,3.8,5.2]:
		Kit.piece(batches,iron,Vector3(0,y,-56.3),Vector3(4.9,0.12,0.08))
	# All replacement bars remain children of the authoritative prison gate, so
	# freeing prisoners opens the complete gate through the existing chapter code.
	preload("res://game/presentation/prison_cells.gd").citadel(region)
	Art.pointed_arch(root,Vector3(-19,0,-18),7.4,4.5)
	# Low relief tablets retain the existing lore interaction position.
	Art.box(root,Vector3(18,0.05,-35),Vector3(1.8,0.1,1.2),stone)
	for x in range(-3,4):
		Kit.piece(batches,iron,Vector3(18+x*0.2,0.11,-35),Vector3(0.05,0.02,0.65-absf(x)*0.08))
	Kit.flush(root,batches)
	var horizon := Node3D.new()
	horizon.position.z = -1
	root.add_child(horizon)
	preload("res://game/presentation/forest_horizon.gd").build(horizon,Vector2(53,68),"CitadelHorizon",Vector2(48,63))
