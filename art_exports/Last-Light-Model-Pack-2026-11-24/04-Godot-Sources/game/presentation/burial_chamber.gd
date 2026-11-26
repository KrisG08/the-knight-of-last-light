extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")

# Presentation of the existing boss room; central combat floor remains unchanged.
static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "BurialArchitecture"
	region.add_child(root)
	preload("res://game/presentation/seal_crystal.gd").attach(region.seal,Color("aa8ec7"))
	var stone := Art.stone()
	var batches: Dictionary = {}
	var fill := OmniLight3D.new()
	fill.position = Vector3(0,5,-2)
	fill.light_color = Color("8baac9")
	fill.light_energy = 1.6
	fill.omni_range = 14
	root.add_child(fill)
	for side in [-1,1]:
		for z in [-6.7,0,6.7]:
			var at := Vector3(side*8.75,0,z)
			Kit.piece(batches,stone,at+Vector3.UP*0.22,Vector3(1.2,0.44,2.9))
			Kit.piece(batches,stone,at+Vector3.UP*0.7,Vector3(1.05,0.6,2.65))
			Kit.piece(batches,stone,at+Vector3.UP*1.07,Vector3(1.3,0.18,2.85))
			# Raised recumbent effigy rather than a featureless box lid.
			Art.cylinder(root,at+Vector3(0,1.25,-0.8),0.19,0.19,0.25,stone,10)
			Kit.piece(batches,stone,at+Vector3(0,1.23,0.1),Vector3(0.45,0.2,1.3))
			for offset in [-0.32,0.32]:
				Kit.piece(batches,stone,at+Vector3(offset,1.24,-0.1),Vector3(0.12,0.15,0.8),Basis(Vector3.UP,offset))
			# Wall bay pilasters and stepped capitals stay outside the fight corridor.
			for dz in [-1.8,1.8]:
				Kit.piece(batches,stone,Vector3(side*9.25,2.5,z+dz),Vector3(0.45,5,0.55))
				Kit.piece(batches,stone,Vector3(side*9.2,4.9,z+dz),Vector3(0.6,0.25,0.85))
			Kit.torch(root,Vector3(side*9,2.8,z),Vector3.LEFT if side==1 else Vector3.RIGHT)
	# Elliptical barrel vault, including upper end walls, closes the outdoor sky.
	preload("res://game/presentation/stone_vault.gd").build(root,9.7,9.7,5,5).name = "BurialVault"
	# Narrow stone ribs follow the curvature, leaving the arena completely clear.
	for z in [-8.6,-3.1,3.1,8.6]:
		for index in range(20):
			var a: float = float(index)/20*PI
			var b: float = float(index+1)/20*PI
			var start := Vector3(cos(a)*9.55,5+sin(a)*4.88,z)
			var finish := Vector3(cos(b)*9.55,5+sin(b)*4.88,z)
			var direction := finish-start
			Kit.piece(batches,stone,(start+finish)*0.5,Vector3(0.18,direction.length()+0.02,0.3),Basis(Quaternion(Vector3.UP,direction.normalized())))
	# Rear apse surrounds the existing seal without obscuring its interaction.
	for side in [-1,1]:
		Art.pointed_arch(root,Vector3(side*4.8,0,-9.1),3,4.6)
		Kit.piece(batches,Art.material("burial_recess",Color("101b25")),Vector3(side*4.8,1.9,-9.35),Vector3(2.4,3.8,0.05))
	Kit.flush(root,batches)
