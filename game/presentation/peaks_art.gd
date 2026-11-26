extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Assets = preload("res://game/presentation/real_assets.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const Horizon = preload("res://game/presentation/forest_horizon.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "PeaksArchitecture"
	region.add_child(root)
	var stone := Art.stone()
	var batches: Dictionary = {}
	Horizon.build(region,Vector2(36,51),"PeaksHorizon",Vector2(32,47))
	region.get_node("PeaksHorizon").position.z = -33
	region.get_node("PeaksHorizon").scale.y = 1.5
	for child in region.get_children():
		if not child is Node3D or child.get_child_count()==0: continue
		var visual = child.get_child(0)
		if not visual is MeshInstance3D or not visual.mesh is BoxMesh: continue
		if child is StaticBody3D and (absf(child.position.x)==32 or child.position.z in [-80,14]):
			visual.hide()
		elif is_equal_approx(absf(child.position.x),2.35) and child.position.z==-30:
			visual.hide()
		elif child.position.x==-19 and is_equal_approx(child.position.y,3.5):
			visual.hide()
	# Thin plateau boxes receive real-looking cliff faces down to the visual gorge.
	cliff(root,-26,1)
	cliff(root,-34,-1)
	for side in [-1,1]:
		Art.box(root,Vector3(side*32,-5,-30),Vector3(0.4,10,8),stone)
	for side in [-1,1]:
		var arch := Node3D.new()
		arch.position = Vector3(side*2.2,-7.9,-30)
		arch.rotation.y = PI/2
		root.add_child(arch)
		Art.pointed_arch(arch,Vector3.ZERO,10,7.5)
		for index in range(10):
			var z: float = -25.4-index
			Art.cylinder(root,Vector3(side*2.35,0.6,z),0.17,0.12,1.2,stone,10)
			Kit.piece(batches,stone,Vector3(side*2.35,0.12,z),Vector3(0.4,0.24,0.45))
		Kit.piece(batches,stone,Vector3(side*2.35,1.15,-30),Vector3(0.35,0.2,10.3))
		for index in range(5):
			var at := Vector3(side*37,0,3-index*19)
			Assets.place_mesh(root,"rock_moss_set_01","rock_moss_set_01_rock0"+str(index%6+1),at,Vector3(6,7,6),index*1.2)
	# Mine portal and repeated support frames preserve the existing open entrance.
	Art.pointed_arch(root,Vector3(-19,0,-7),13,6.4)
	for z in [-7,-14,-22]:
		for side in [-1,1]:
			Kit.beam(batches,Vector3(-19+side*6.5,0,z),Vector3(-19+side*6.5,4.8,z),0.24)
			Kit.beam(batches,Vector3(-19+side*6.5,4.8,z),Vector3(-19,6,z),0.23)
			Kit.beam(batches,Vector3(-19+side*6.5,2.8,z),Vector3(-19+side*4.2,5.1,z),0.18)
		Kit.torch(root,Vector3(-25.3,2,z),Vector3.RIGHT,z!=-14)
	for index in range(8):
		if index in [3,6]: continue
		Kit.piece(batches,Kit.wood(),Vector3(-22.2,5.35,-21+index*2),Vector3(6.8,0.13,1.8),Basis(Vector3.BACK,0.18))
	# Fortress entrance: four buttresses and a deep stone portal over the same gate.
	region.interact_colliders.fortress.get_child(0).hide()
	Kit.piece(batches,stone,Vector3(0,3,-69),Vector3(14,6,5))
	for side in [-1,1]:
		Art.cylinder(root,Vector3(side*6,4.5,-67.2),1.2,1,9,stone,12)
		Art.cylinder(root,Vector3(side*6,9.5,-67.2),1.5,1.5,0.35,stone,12)
		for index in range(5):
			var angle: float = index*TAU/5
			Kit.piece(batches,stone,Vector3(side*6+sin(angle)*1.1,10,-67.2+cos(angle)*1.1),Vector3(0.6,0.9,0.6))
		Kit.torch(root,Vector3(side*3.6,2,-66.3),Vector3.BACK)
	Kit.piece(batches,Kit.wood(),Vector3(0,2.3,-66.43),Vector3(5.8,4.6,0.1))
	Art.pointed_arch(root,Vector3(0,0,-66.15),6.6,7.2)
	Kit.flush(root,batches)
	Dressing.pavers(root,Vector3(0,0.06,-6),5,37)
	Dressing.pavers(root,Vector3(0,0.06,-50),5,30)

static func cliff(root: Node3D, z: float, side: int) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(16):
		var x: float = -32+index*4
		var a := Vector3(x,-0.04,z)
		var b := Vector3(x+4,-0.04,z)
		var c := Vector3(x+sin(index)*0.8,-10,z+side*(0.7+sin(index)*0.4))
		var d := Vector3(x+4+sin(index+1)*0.8,-10,z+side*(0.7+sin(index+1)*0.4))
		for vertex in [a,b,c,b,d,c]:
			surface.set_uv(Vector2(vertex.x,vertex.y)*0.2)
			surface.add_vertex(vertex)
	surface.generate_normals()
	var material := Art.stone().duplicate() as StandardMaterial3D
	material.albedo_color = Color("626e79")
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	Art.mesh(root,surface.commit(),Vector3.ZERO,material)
