extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Vault = preload("res://game/presentation/stone_vault.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "CommanderHall"
	region.add_child(root)
	var stone := Art.stone()
	var batches: Dictionary = {}
	Vault.build(root,11.7,11.7,6,6).name = "SanctumVault"
	for z in [-8.5,0,8.5]:
		Art.pointed_arch(root,Vector3(0,0,z),22.5,11.5)
	for side in [-1,1]:
		for z in [-8,-3,3,8]:
			Art.cylinder(root,Vector3(side*11.3,3,z),0.45,0.38,6,stone,12)
			for y in [0.2,5.9]:
				Art.cylinder(root,Vector3(side*11.3,y,z),0.65,0.65,0.3,stone,12)
			Kit.torch(root,Vector3(side*11,2.5,z),Vector3.LEFT if side>0 else Vector3.RIGHT,z in [-8,8])
		for z in [-5.5,5.5]:
			var banner := PlaneMesh.new()
			banner.size = Vector2(3.2,1.6)
			var cloth := ShaderMaterial.new()
			cloth.shader = preload("res://assets/materials/weathered_canvas.gdshader")
			cloth.set_shader_parameter("cloth_color",Color("34475d"))
			Art.mesh(root,banner,Vector3(side*11.4,4,z),cloth).rotation.z = PI/2
			Kit.piece(batches,Art.material("order_banner_trim",Color("918268"),0.3),Vector3(side*11.35,4,z),Vector3(0.03,1.7,0.07))
			Kit.piece(batches,Art.material("order_banner_trim",Color("918268"),0.3),Vector3(side*11.35,4.35,z),Vector3(0.03,0.07,0.85))
	# Empty throne behind the seal alludes to the commander's lost station.
	Kit.piece(batches,stone,Vector3(0,0.35,-11),Vector3(3.4,0.7,1.1))
	Kit.piece(batches,stone,Vector3(0,2.3,-11.2),Vector3(2.4,4,0.4))
	for side in [-1,1]:
		Art.cylinder(root,Vector3(side*1.4,2,-10.8),0.25,0.2,4,stone,10)
		Art.cylinder(root,Vector3(side*1.4,4.4,-10.8),0.45,0,0.8,stone,8)
	Kit.flush(root,batches)
	# Keep seal visibility/interaction tied to its original authoritative node.
	preload("res://game/presentation/seal_crystal.gd").attach(region.seal,Color("95bddb"))
	Art.cylinder(root,Vector3(0,0.2,-9),1.05,0.85,0.4,stone,16)
	var fill := OmniLight3D.new()
	fill.position = Vector3(0,5,-1)
	fill.light_color = Color("8eacc8")
	fill.light_energy = 1.8
	fill.omni_range = 18
	root.add_child(fill)
