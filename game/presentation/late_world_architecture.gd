extends RefCounted
## Hand-authored landmarks and castle expansion. Shared meshes keep repeated
## masonry inexpensive; only the citadel's new solid footprints affect routes.
const Art=preload("res://game/presentation/art_kit.gd")
const Kit=preload("res://game/presentation/village_kit.gd")
const Detail=preload("res://game/presentation/chapter_detail_kit.gd")
const Dressing=preload("res://game/presentation/ruin_dressing.gd")
var root: Node3D
var region: Node3D
var boxes: Dictionary={}
var shafts: Array[Transform3D]=[]
var drums: Array[Transform3D]=[]
var roofs: Array[Transform3D]=[]
var stone: Material
var slate: Material
var window: Material

static func build(owner_region: Node3D) -> void:
	var builder=load("res://game/presentation/late_world_architecture.gd").new()
	builder.region=owner_region
	builder.root=Node3D.new(); builder.root.name="LateWorldLandmarks"
	owner_region.add_child(builder.root)
	builder.stone=Art.stone()
	builder.slate=Kit.material("grey_roof_tiles",Color("4c5766"),0.35)
	builder.window=Art.material("citadel_amber_windows",Color("746044"))
	builder.window.emission_enabled=true
	builder.window.emission=Color("b88443"); builder.window.emission_energy_multiplier=0.35
	match owner_region.region_id:
		"region.blackwood": builder.forest()
		"region.grove": builder.shrine()
		"region.order": builder.order()
		"region.sanctum": builder.memorial()
		"region.peaks": builder.peaks()
		"region.forge": builder.forge()
		"region.citadel": builder.castle()
		"region.ritual": builder.cathedral()
	builder.flush()
	if owner_region.region_id in ["region.blackwood","region.order"]:
		owner_region.remove_child(owner_region.navigation); owner_region.navigation.queue_free()
		owner_region.build_navigation(Rect2(-32,-78,64,100) if owner_region.region_id=="region.blackwood" else Rect2(-32,-56,64,70),1.0)

func block(at: Vector3, size: Vector3, material: Material=null) -> void:
	Kit.piece(boxes,stone if material==null else material,at,size)

func column(at: Vector3, radius: float, height: float, rings:=false) -> void:
	var transform:=Transform3D(Basis.from_scale(Vector3(radius,height,radius)),at+Vector3.UP*height*0.5)
	if rings: drums.append(transform)
	else: shafts.append(transform)

func tower(at: Vector3, radius: float, height: float) -> void:
	column(at,radius,height)
	for y in [0.4,height*0.38,height*0.72,height-0.5]:
		column(at+Vector3.UP*y,radius*1.12,0.45,true)
	roofs.append(Transform3D(Basis.from_scale(Vector3(radius*1.25,height*0.30,radius*1.25)),at+Vector3.UP*height*1.15))
	for side in [-1,1]:
		var center:=at+Vector3(side*radius*0.42,height*0.65,radius*0.94)
		lancet(center,radius*0.25,height*0.13)
	for angle_index in range(8):
		var angle: float=angle_index*TAU/8
		column(at+Vector3(sin(angle)*radius*0.91,height-0.1,cos(angle)*radius*0.91),radius*0.16,1.5)

func lancet(center: Vector3, width: float, height: float) -> void:
	block(center,Vector3(width+0.35,height+0.4,0.25),slate)
	block(center+Vector3(0,0,0.15),Vector3(width,height,0.08),window)
	block(center+Vector3(0,0,0.22),Vector3(0.08,height,0.08))
	for y in [-0.26,0.26]:
		block(center+Vector3(0,y*height,0.22),Vector3(width,0.08,0.08))

func gate(at: Vector3, width: float, height: float) -> void:
	Art.pointed_arch(root,at,width,height)
	Art.pointed_arch(root,at+Vector3(0,0,-1.0),width+1,height+0.7)
	for side in [-1,1]:
		block(at+Vector3(side*(width*0.5+1),height*0.43,-0.5),Vector3(1.3,height*0.86,2.7))
		column(at+Vector3(side*(width*0.5+1),height*0.86,-0.5),0.6,3.4)
		if region.region_id in ["region.blackwood","region.order"]:
			var body=region.box(at+Vector3(side*(width*0.5+1),height*0.43,-0.5),Vector3(1.3,height*0.86,2.7),Color("566370"))
			body.get_child(0).hide()
			var pillar=region.box(at+Vector3(side*width*0.5,height*0.3,0),Vector3(0.55,height*0.6,0.7),Color("566370"))
			pillar.get_child(0).hide()

func gallery(at: Vector3, bays: int, spacing: float, height: float) -> void:
	for bay in range(bays):
		var point:=at+Vector3(bay*spacing,0,0)
		Art.pointed_arch(root,point,spacing-0.5,height)
		block(point+Vector3(0,height+0.7,-0.3),Vector3(spacing,1.1,1.5))

func forest() -> void:
	# The ruined wayside abbey stands beyond the west forest collision boundary.
	gate(Vector3(20,0,-37),9,8)
	gate(Vector3(-12,0,-53),7,9.5)
	tower(Vector3(-39,0,-40),4,21)
	block(Vector3(-39,4,-49),Vector3(15,8,15))
	gallery(Vector3(-44,8,-40.7),3,5,5)
	for z in [-44,-50,-56]:
		block(Vector3(-29,5,z),Vector3(1,10,2))
		Art.beam(root,Vector3(-29,8,z),Vector3(-34,12,z),0.25,stone)
	for at in [Vector3(-4,0,-4),Vector3(24,0,-44),Vector3(-7,0,-53)]:
		column(at,0.45,2.1)
		Art.lantern(root,at+Vector3.UP*2.1)

func shrine() -> void:
	for side in [-1,1]:
		tower(Vector3(side*17,0,-11),2.7,16)
	gate(Vector3(0,0,-14),10,13)
	gallery(Vector3(-7,11,-16),3,7,4)

func order() -> void:
	tower(Vector3(-41,0,-41),5,31)
	tower(Vector3(40,0,-50),3.5,23)
	gallery(Vector3(-28,7,-57),8,8,7)
	for side in [-1,1]:
		block(Vector3(side*38,6,-23),Vector3(10,12,37))
		for z in [-10,-22,-34]:
			Art.beam(root,Vector3(side*33,8,z),Vector3(side*39,16,z),0.4,stone)
	gate(Vector3(0,0,-43),10,11)

func memorial() -> void:
	for side in [-1,1]:
		for z in [-8,0,8]:
			column(Vector3(side*11.4,0,z),0.4,9)
			Detail.banner(root,Vector3(side*11.1,8,z),-side*PI/2,Color("4b4568"),3)
	gate(Vector3(0,0,-11.5),10,11)

func peaks() -> void:
	# Abandoned aqueduct and summit monastery frame the playable ridge bridge.
	for side in [-1,1]:
		var group:=Node3D.new(); group.position=Vector3(side*43,-5,-31)
		group.rotation.y=PI/2; root.add_child(group)
		for bay in range(5):
			Art.pointed_arch(group,Vector3(-20+bay*10,0,0),9,15)
		block(Vector3(side*43,11,-31),Vector3(3,2,60))
		for index in range(4):
			tower(Vector3(side*(37+index*8),0,-86-index*4),2.7,18+index*4)
	block(Vector3(0,9,-89),Vector3(40,18,15))
	gallery(Vector3(-15,12,-81),4,10,8)
	tower(Vector3(0,0,-98),7,42)

func forge() -> void:
	for side in [-1,1]:
		for z in [-8,0,8]:
			block(Vector3(side*11.4,4.5,z),Vector3(0.6,9,1))
			Art.beam(root,Vector3(side*11.4,6,z),Vector3(side*7,10,z),0.28,stone)

func castle() -> void:
	# New playable forecourt: 96 x 126 m; the original upper quest locations stay.
	gate(Vector3(0,0,28),18,16)
	for side in [-1,1]:
		for x in [10.0,14.0]:
			var body=region.box(Vector3(side*x,5,28),Vector3(2,10,3),Color("566370"))
			body.get_child(0).hide()
			tower(Vector3(side*x,0,28),1.0,18 if x==10 else 22)
		for z in [47,14,-14,-42]:
			tower(Vector3(side*46,0,z),3.3,24)
		for z in [47,37,17,4]:
			column(Vector3(side*7.2,0,z),0.4,1.5)
			Art.lantern(root,Vector3(side*7.2,1.5,z))
		for z in [41,11]:
			var base=region.box(Vector3(side*29,2,z),Vector3(7,4,10),Color("566370"))
			base.get_child(0).hide()
			block(Vector3(side*29,2,z),Vector3(7,4,10))
			gallery(Vector3(side*29-2,4,z+5),2,4,5)
			Detail.banner(root,Vector3(side*29,7,z+5.5),0,Color("4c315c"),2.5)
		# Outer fortress wings and flying buttresses remain beyond physical walls.
		block(Vector3(side*54,11,-33),Vector3(13,22,60))
		for z in [-12,-28,-44,-60]:
			Art.beam(root,Vector3(side*47,12,z),Vector3(side*58,25,z),0.65,stone)
			tower(Vector3(side*61,0,z),3.5,29)
		for x in [18,35]:
			tower(Vector3(side*x,0,-77),5.0 if x==18 else 6.5,42 if x==18 else 34)
	# A real layered keep silhouette: nave, clerestory, gabled buttresses and crown.
	block(Vector3(0,12,-77),Vector3(62,24,23))
	block(Vector3(0,28,-81),Vector3(32,17,22))
	for side in [-1,1]:
		var wing:=Node3D.new(); wing.position=Vector3(side*23,0,-77); root.add_child(wing)
		Kit.roof(wing,15,25,24)
	var nave:=Node3D.new(); nave.position=Vector3(0,0,-81); root.add_child(nave)
	Kit.roof(nave,32,24,36.5)
	tower(Vector3(0,16,-87),9,43)
	gallery(Vector3(-24,15,-64.7),7,8,9)
	for x in [-12,-6,0,6,12]:
		lancet(Vector3(x,28,-69.8),2.2,9)
		Art.pointed_arch(root,Vector3(x,23,-69.5),3,12)
	for side in [-1,1]:
		for x in [24,31,39]:
			Art.beam(root,Vector3(side*x,13,-66),Vector3(side*(x-8),30,-77),0.6,stone)
		Detail.banner(root,Vector3(side*12,15,-64.5),0,Color("4e295f"),6)
	Dressing.pavers(root,Vector3(0,0.055,27),8,62)
	region.remove_child(region.navigation); region.navigation.queue_free()
	region.build_navigation(Rect2(-48,-64,96,126),1.0)

func cathedral() -> void:
	# Preserve the validated battle floor and cinematic coordinates; enlarge its
	# vertical architecture rather than silently changing boss spacing/balance.
	for side in [-1,1]:
		for z in [-9,0,9]:
			column(Vector3(side*12.5,8,z),0.45,13)
			Art.beam(root,Vector3(side*12.4,15,z),Vector3(side*8,23,z),0.25,stone)
			block(Vector3(side*12.65,17,z),Vector3(0.1,6,2.4),window)
			for dz in [-1.3,0,1.3]:
				block(Vector3(side*12.5,17,z+dz),Vector3(0.22,6.3,0.12))
			for y in [14,16,18,20]:
				block(Vector3(side*12.5,y,z),Vector3(0.22,0.12,2.7))
	gate(Vector3(0,0,-12.6),19,23)
	for side in [-1,1]:
		tower(Vector3(side*10.8,0,-12.5),0.8,22)
		Detail.banner(root,Vector3(side*8,16,-12.3),0,Color("51315f"),5)

func flush() -> void:
	Kit.flush(root,boxes)
	for kind in [0,1,2]:
		var transforms: Array[Transform3D]=shafts if kind==0 else (drums if kind==1 else roofs)
		if transforms.is_empty(): continue
		var mesh:=CylinderMesh.new(); mesh.height=1; mesh.bottom_radius=1
		mesh.top_radius=0.86 if kind==0 else (1.0 if kind==1 else 0.0)
		mesh.radial_segments=16
		Dressing.instances(root,mesh,slate if kind==2 else stone,transforms)
