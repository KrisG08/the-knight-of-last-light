extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Vault = preload("res://game/presentation/stone_vault.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "ForgeArchitecture"
	region.add_child(root)
	var iron := Art.material("iron",Color("43484c"),0.7)
	var stone := Art.stone()
	var batches: Dictionary = {}
	Vault.build(root,11.7,11.7,6,4).name = "ForgeVault"
	# Reuse the six original side lights; no extra furnace light fan-out.
	for lamp in region.find_children("*","OmniLight3D",true,false):
		lamp.light_color = Color("ed9f55")
		lamp.light_energy = 2.4
	for mesh in region.find_children("*","MeshInstance3D",true,false):
		if mesh.material_override!=null and mesh.material_override==Art.materials.get("lantern_gold_glass"):
			var material := mesh.material_override.duplicate() as StandardMaterial3D
			material.albedo_color = Color("eab879")
			material.emission = Color("ed9646")
			mesh.material_override = material
	for z in [-8,0,8]:
		Kit.piece(batches,iron,Vector3(0,6.2,z),Vector3(23,0.3,0.35))
		for side in [-1,1]:
			Kit.piece(batches,iron,Vector3(side*11.3,3,z),Vector3(0.28,6,0.45))
			Kit.beam(batches,Vector3(side*11.3,4.7,z),Vector3(side*9.2,6.2,z),0.18)
	for side in [-1,1]:
		for z in [-5,5]:
			var furnace := Node3D.new()
			furnace.position = Vector3(side*11.42,0,z)
			furnace.rotation.y = -side*PI/2
			root.add_child(furnace)
			Art.box(furnace,Vector3(0,1.65,0),Vector3(2.7,3.3,0.04),Art.material("furnace_dark",Color("181b20")))
			Art.pointed_arch(furnace,Vector3(0,0,0.02),3.3,4.6)
			for x in [-0.9,-0.45,0,0.45,0.9]:
				Art.cylinder(furnace,Vector3(x,1.5,0.12),0.04,0.04,2.8,iron,8)
			var glow := Art.material("forge_coals",Color("b75e2e"))
			glow.emission_enabled = true
			glow.emission = Color("e17e35")
			glow.emission_energy_multiplier = 1.6
			for index in range(7):
				var coal := SphereMesh.new()
				coal.radius = 0.17
				coal.height = 0.24
				coal.radial_segments = 8
				coal.rings = 4
				Art.mesh(furnace,coal,Vector3(-0.9+index*0.3,0.25+(index%2)*0.08,0.1),glow)
			# Suspended chain stays well above the knight/camera corridor.
			for index in range(6):
				var link := TorusMesh.new()
				link.inner_radius = 0.09
				link.outer_radius = 0.13
				link.rings = 10
				link.ring_segments = 6
				var node := Art.mesh(root,link,Vector3(side*7.5,6-index*0.22,z),iron)
				node.rotation.x = PI/2
				node.rotation.y = (index%2)*PI/2
	Kit.flush(root,batches)
	preload("res://game/presentation/seal_crystal.gd").attach(region.seal,Color("d39b62"))
	Art.cylinder(root,Vector3(0,0.2,-9),0.9,0.75,0.4,stone,14)
	var fill := OmniLight3D.new()
	fill.position = Vector3(0,5,0)
	fill.light_color = Color("92a5b6")
	fill.light_energy = 0.9
	fill.omni_range = 18
	root.add_child(fill)
