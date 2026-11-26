extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "RitualHallArchitecture"
	region.add_child(root)
	var stone := Art.stone()
	preload("res://game/presentation/stone_vault.gd").build(root,12.7,12.7,16,10).name = "RitualVault"
	for side in [-1,1]:
		Art.box(root,Vector3(side*13,12,0),Vector3(0.5,8,26),stone)
		Art.box(root,Vector3(0,12,side*13),Vector3(26,8,0.5),stone)
	for z in [-9,0,9]:
		Art.pointed_arch(root,Vector3(0,0,z),24,14)
	for side in [-1,1]:
		for z in [-9,-3,3,9]:
			Art.cylinder(root,Vector3(side*12.3,4,z),0.35,0.3,8,stone,12)
			Art.cylinder(root,Vector3(side*12.3,0.15,z),0.5,0.5,0.3,stone,12)
			Kit.torch(root,Vector3(side*12.1,2.7,z),Vector3.LEFT if side>0 else Vector3.RIGHT,z in [-9,9])
	# Thin inlaid concentric rings mark the ritual without raising the arena floor.
	var metal := Art.material("ritual_inlay",Color("797483"),0.45)
	for radius in [3.0,6.0,9.0]:
		var ring := TorusMesh.new()
		ring.inner_radius = radius-0.035
		ring.outer_radius = radius+0.035
		ring.rings = 64
		ring.ring_segments = 8
		Art.mesh(root,ring,Vector3(0,0.012,0),metal).scale.y = 0.12
	preload("res://game/presentation/seal_crystal.gd").attach(region.seal,Color("be9bd8"))
	# Keep plinth below the actor's step threshold; interaction stays on seal node.
	Art.cylinder(root,Vector3(0,0.08,-9),1.25,1.1,0.16,stone,16)
	var fill := OmniLight3D.new()
	fill.position = Vector3(0,5,-4)
	fill.light_color = Color("b4a9dc")
	fill.light_energy = 2.2
	fill.omni_range = 20
	root.add_child(fill)
