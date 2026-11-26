extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Assets = preload("res://game/presentation/real_assets.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const Horizon = preload("res://game/presentation/forest_horizon.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "BlackwoodArchitecture"
	region.add_child(root)
	# Keep authored trunk colliders and their navigation footprints, replace foliage.
	for child in region.get_children():
		if not child is Node3D or child.get_child_count()==0:
			continue
		var visual = child.get_child(0)
		if not visual is MeshInstance3D or not visual.mesh is BoxMesh:
			continue
		var size: Vector3 = visual.mesh.size
		if size.y>=3 and size.x>=3 and child.position.y>=5 and child.position.y<6:
			visual.hide()
			var variant: String = ["b","c"][int(absf(child.position.x+child.position.z))%2]
			Assets.place_mesh(root,"pine_sapling_small","pine_sapling_small_"+variant,Vector3(child.position.x,0,child.position.z),Vector3(17,16,17),child.position.z*0.3,8000 if variant=="b" else 4000)
		elif size.x<1 and size.y==4 and child.position.y==2:
			visual.hide()
		elif is_equal_approx(child.position.y,3.0) and is_equal_approx(size.y,6.0) and size.x<1:
			visual.hide()
		elif is_equal_approx(child.position.y,6.0) and is_equal_approx(size.y,0.7):
			visual.material_override = Kit.wood()
		elif child.position==Vector3(-12,5,-59):
			visual.hide()
		elif is_equal_approx(child.position.z,-30) and is_equal_approx(child.position.y,1.8):
			visual.hide()
			root_bar(child,size.x)
		elif size.y<0.1 and child.position.y>=0 and child.position.y<0.04:
			visual.hide()
		elif child is StaticBody3D and (absf(child.position.x)==32 or child.position.z in [-78,22]):
			visual.hide()
	Horizon.build(region,Vector2(35,53),"BlackwoodHorizon",Vector2(32,50))
	region.get_node("BlackwoodHorizon").position.z = -28
	region.get_node("BlackwoodHorizon").scale.y = 0.6
	var batches: Dictionary = {}
	var tower := Vector3(21,0,-26)
	for side in [-1,1]:
		for z in [-4,4]:
			Kit.beam(batches,tower+Vector3(side*4,0,z),tower+Vector3(side*4,9,z),0.22)
			Kit.beam(batches,tower+Vector3(side*4,0,z),tower+Vector3(-side*4,5.7,z),0.15)
		for y in [6.5,7.2]:
			Kit.beam(batches,tower+Vector3(side*4,y,-4),tower+Vector3(side*4,y,4),0.12)
		Kit.beam(batches,tower+Vector3(side*4,9,-4.5),tower+Vector3(side*4,10.5,0),0.15)
		Kit.beam(batches,tower+Vector3(side*4,10.5,0),tower+Vector3(side*4,9,4.5),0.15)
	for strip in range(8):
		if strip in [2,5]: continue
		Kit.piece(batches,Kit.wood(),tower+Vector3(-3.5+strip,9.7,1.9),Vector3(0.86,0.12,4.6),Basis(Vector3.RIGHT,0.32))
	# Shrine columns retain collision; nested arches and roots give a distinct portal.
	for depth in [0.0,-0.6]:
		Art.pointed_arch(root,Vector3(-12,0,-59+depth),5.2,6.7)
	for side in [-1,1]:
		var start := Vector3(-12+side*3.7,0,-58)
		for index in range(4):
			var end := start+Vector3(-side*0.5,1.5,-0.3)
			Art.beam(root,start,end,0.22-index*0.035,Kit.wood())
			start = end
		Kit.torch(root,Vector3(-12+side*3.1,2,-57.9),Vector3.BACK)
	Kit.flush(root,batches)
	road(root)

static func road(root: Node3D) -> void:
	var routes := [[Vector3(0,0,12),Vector3(0,0,-14),Vector3(20,0,-20),Vector3(20,0,-54),Vector3(-12,0,-54),Vector3(-12,0,-58)],[Vector3(20,0,-54),Vector3(22,0,-65)],[Vector3(-19,0,-29),Vector3(-19,0,-54)]]
	var transforms: Array[Transform3D] = []
	var random := RandomNumberGenerator.new()
	random.seed = 7742
	for route in routes:
		for segment in range(1,route.size()):
			var start: Vector3 = route[segment-1]
			var finish: Vector3 = route[segment]
			var forward := (finish-start).normalized()
			var side := forward.cross(Vector3.UP)
			var steps := maxi(1,int(start.distance_to(finish)/0.9))
			for step in range(steps):
				for column in [-1,0,1]:
					if random.randf()<0.28: continue
					var at: Vector3 = start.lerp(finish,(step+0.5)/steps)+side*column*0.7+Vector3.UP*0.012
					transforms.append(Transform3D(Basis(Vector3.UP,atan2(forward.x,forward.z)+random.randf_range(-0.08,0.08)).scaled(Vector3(0.62,0.02,0.8)),at))
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	Dressing.instances(root,mesh,Art.stone(),transforms)
	root.get_child(-1).set_meta("terrain_paving",true)

static func root_bar(body: Node3D, width: float) -> void:
	# Parent visibility/collision remains controlled by the existing shortcut rule.
	var wood := Kit.wood()
	var transforms: Array[Transform3D] = []
	for row in range(4):
		var previous := Vector3(-width*0.5,-1.5+row*0.75,-0.25)
		var steps := maxi(6,int(width*1.5))
		for index in range(1,steps+1):
			var x: float = -width*0.5+width*index/steps
			var point := Vector3(x,-1.5+row*0.75+sin(index*1.7+row)*0.25,sin(index+row)*0.3)
			transforms.append(root_segment(previous,point,0.18))
			if index%2==0:
				transforms.append(root_segment(point,point+Vector3(0.3,0.55,0.4),0.08))
			previous = point
	var shape := CylinderMesh.new()
	shape.bottom_radius = 1
	shape.top_radius = 0.7
	shape.height = 1
	shape.radial_segments = 7
	Dressing.instances(body,shape,wood,transforms)

static func root_segment(start: Vector3, finish: Vector3, radius: float) -> Transform3D:
	var direction := finish-start
	return Transform3D(Basis(Quaternion(Vector3.UP,direction.normalized()))*Basis.from_scale(Vector3(radius,direction.length(),radius)),(start+finish)*0.5)
