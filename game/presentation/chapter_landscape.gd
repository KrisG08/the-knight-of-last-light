extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Detail = preload("res://game/presentation/chapter_detail_kit.gd")
const Assets = preload("res://game/presentation/real_assets.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")

static func build(region: Node3D) -> void:
	var root := Node3D.new()
	root.name = "ChapterLandscape"
	region.add_child(root)
	match region.region_id:
		"region.blackwood": blackwood(region,root)
		"region.order": order(region,root)
		"region.peaks": peaks(region,root)
		"region.citadel": citadel(region,root)

static func blackwood(region: Node3D, root: Node3D) -> void:
	var routes := [[Vector3(0,0,14),Vector3(0,0,-14),Vector3(20,0,-20),Vector3(20,0,-54),Vector3(-12,0,-54),Vector3(-12,0,-58)],[Vector3(20,0,-54),Vector3(22,0,-66)],[Vector3(-19,0,-29),Vector3(-19,0,-54)]]
	Detail.ground(region,routes,0)
	Detail.vegetation(region,root,routes,Rect2(-30,-75,60,94),1729)
	# Tree clusters frame the playable paths, not an evenly spaced grid.
	for at in [Vector3(-29,0,14),Vector3(-27,0,-6),Vector3(29,0,9),Vector3(27,0,-15),Vector3(-30,0,-44),Vector3(-26,0,-66),Vector3(30,0,-48),Vector3(29,0,-72),Vector3(8,0,-74),Vector3(-7,0,-73)]:
		Assets.place_mesh(root,"pine_sapling_small","pine_sapling_small_b",at,Vector3(22,24,22),at.z*0.47,8000)
	# Large scans stand behind the existing boundary colliders, avoiding phantom
	# obstacles or changes to combat/navigation inside the forest.
	for side in [-1,1]:
		for index in range(5):
			Assets.place_mesh(root,"rock_moss_set_01","rock_moss_set_01_rock03",Vector3(side*34,-0.5,11-index*19),Vector3(3.5,3.0,5),index*0.67)
	# Low roots replace the two physical rectangular fallen-log obstacles.
	for child in region.get_children():
		if child is StaticBody3D and child.position in [Vector3(5,0.7,-15),Vector3(-6,0.7,-12)]:
			child.get_child(0).hide()
			var log := Art.cylinder(root,child.position,0.48,0.35,5,Kit.wood(),12)
			log.rotation.z = PI/2
			for offset in [-1.7,0.4,1.6]:
				Art.beam(root,child.position+Vector3(offset,0,0),child.position+Vector3(offset+0.4,0.6,-0.4),0.09,Kit.wood())
	# Supplies at the existing watchtower posts and a hanging rope ladder.
	for at in [Vector3(17.3,0,-22.3),Vector3(24.6,0,-29.6)]:
		Detail.crate(root,at,Vector3(0.8,0.7,0.8))
		Detail.barrel(root,at+Vector3(0.5,0,0),0.7)
	var batches: Dictionary = {}
	for side in [-1,1]:
		Kit.beam(batches,Vector3(21+side*0.45,0.2,-30),Vector3(21+side*0.45,6.4,-30),0.045)
	for rung in range(17):
		Kit.beam(batches,Vector3(20.55,0.4+rung*0.35,-30),Vector3(21.45,0.4+rung*0.35,-30),0.065)
	Kit.flush(root,batches)
	Detail.banner(root,Vector3(20.7,6,-21.45),0,Color("4b5d49"),2.1)
	Kit.torch(root,Vector3(17,2,-21.6),Vector3.BACK)
	# Route markers accompany the already authoritative interaction labels.
	signpost(root,Vector3(3.2,0,-16),"WATCHTOWER  →","ROOT SHRINE  ↑")
	signpost(root,Vector3(23,0,-53),"ROOT SHRINE  ←","ORDER RUINS  ↑")
	Art.pointed_arch(root,Vector3(22,0,-65.5),6.8,7.8)
	Detail.banner(root,Vector3(27,6.3,-65.3),0,Color("34475a"))
	# Small luminous mushrooms: emissive materials, not dozens of point lights.
	var glow := Art.material("forest_mushroom",Color("589c8e"))
	glow.emission_enabled = true
	glow.emission = Color("30675d")
	for cluster in [Vector3(-8,0,-11),Vector3(8,0,-20),Vector3(-15,0,-57),Vector3(26,0,-43)]:
		for index in range(5):
			var at: Vector3 = cluster+Vector3(sin(index*2.3)*0.6,0.08,cos(index*2.3)*0.6)
			Art.cylinder(root,at,0.018,0.015,0.16,Kit.wood(),6)
			var cap := SphereMesh.new()
			cap.radius = 0.11
			cap.height = 0.11
			cap.radial_segments = 8
			cap.rings = 4
			Art.mesh(root,cap,at+Vector3.UP*0.1,glow)

static func order(region: Node3D, root: Node3D) -> void:
	var routes := [[Vector3(0,0,10),Vector3(0,0,-17),Vector3(6,0,-25),Vector3(0,0,-36),Vector3(0,0,-48)],[Vector3(-11,0,-3),Vector3(-19,0,-9),Vector3(-19,0,-43)],[Vector3(0,0,-43),Vector3(22,0,-48)]]
	Detail.ground(region,routes,2)
	Detail.vegetation(region,root,routes,Rect2(-30,-53,60,64),3723,true)
	for side in [-1,1]:
		for z in [4,-11,-27,-43]:
			Detail.niche(root,Vector3(side*31.42,0.8,z),-side*PI/2,Color("536b72"),3.5)
			Detail.banner(root,Vector3(side*31.35,4.7,z-4),-side*PI/2,Color("35485b"),2.4)
	# Dress barracks wall tops with tile courses and timber lintels.
	var batches: Dictionary = {}
	for side in [-1,1]:
		var x: float = -19+side*7.45
		for z in [-16,-23,-30,-36]:
			Kit.piece(batches,Kit.wood(),Vector3(x,2,z),Vector3(0.18,4,0.2))
		for y in [0.3,3.8]:
			Kit.piece(batches,Art.stone(),Vector3(x,y,-25),Vector3(0.3,0.25,25))
	for z in [-17,-30]:
		Detail.crate(root,Vector3(-26.1,0,z),Vector3(0.8,0.8,1.0))
		Detail.barrel(root,Vector3(-26.1,0,z+1.1),0.8)
	for x in [8,17,26]:
		Detail.banner(root,Vector3(x,4.1,-18.4),0,Color("455468"),2.2)
		# Flying braces stay above actor and camera clearance.
		Kit.beam(batches,Vector3(x,4,-19),Vector3(x,6.7,-25),0.19)
		Kit.beam(batches,Vector3(x,6.7,-25),Vector3(x,4,-32),0.19)
	Kit.flush(root,batches)
	signpost(root,Vector3(3,0,-39),"MEMORIAL  ←","SANCTUM  ↑")
	Art.pointed_arch(root,Vector3(22,0,-48.5),6.7,7.2)

static func peaks(region: Node3D, root: Node3D) -> void:
	var routes := [[Vector3(0,0,10),Vector3(0,0,-25),Vector3(0,0,-35),Vector3(0,0,-65)],[Vector3(0,0,-3),Vector3(-19,0,-7),Vector3(-19,0,-20)],[Vector3(0,0,-61),Vector3(19,0,-61),Vector3(19,0,-38)],[Vector3(19,0,-61),Vector3(23,0,-69)]]
	Detail.ground(region,routes,1)
	# Layered crags behind the physical boundary instead of an empty skyline.
	for side in [-1,1]:
		for index in range(7):
			Assets.place_mesh(root,"rock_moss_set_01","rock_moss_set_01_rock0"+str(index%3+1),Vector3(side*(33+index%2),-0.4,10-index*14),Vector3(3.5,4+index%3,4.8),index*0.8)
	var batches: Dictionary = {}
	# Rails run inside the actual mine. Metal ties are near-flush with its floor.
	var iron := Art.material("mine_rail",Color("41494d"),0.7)
	for x in [-19.55,-18.45]:
		Kit.piece(batches,iron,Vector3(x,0.045,-15),Vector3(0.06,0.06,14))
	for z in range(-21,-7):
		Kit.piece(batches,Kit.wood(),Vector3(-19,0.035,z),Vector3(1.7,0.05,0.16))
	# Replace the existing solid crate by a braced ore cart at the same footprint.
	for child in region.get_children():
		if child is StaticBody3D and child.position==Vector3(-22,0.7,-16): child.get_child(0).hide()
	var cart := Vector3(-22,0,-16)
	Kit.piece(batches,iron,cart+Vector3.UP*0.5,Vector3(2.6,0.15,2.5))
	for side in [-1,1]:
		Kit.piece(batches,Kit.wood(),cart+Vector3(side*1.25,0.9,0),Vector3(0.1,0.8,2.5))
		Kit.piece(batches,Kit.wood(),cart+Vector3(0,0.9,side*1.2),Vector3(2.5,0.8,0.1))
		for z in [-0.85,0.85]:
			var wheel := Art.cylinder(root,cart+Vector3(side*1.3,0.3,z),0.3,0.3,0.16,iron,12)
			wheel.rotation.z = PI/2
	Dressing.rubble(root,cart+Vector3.UP*0.55,20,0.9)
	# Riveted reinforcement on the existing forge doorway and mine wall panels.
	for side in [-1,1]:
		for y in [0.8,2.0,3.4]:
			Kit.piece(batches,iron,Vector3(side*1.5,y,-66.3),Vector3(2.8,0.12,0.06))
		for z in [-9,-15,-21]:
			Kit.piece(batches,Kit.wood(),Vector3(-19+side*7.4,2,z),Vector3(0.14,4,0.2))
		Detail.banner(root,Vector3(side*5.8,8.7,-65.9),0,Color("685344"),3.3)
	Kit.flush(root,batches)
	signpost(root,Vector3(3.4,0,-21),"RIDGE BRIDGE  ↑","MINE  ←")
	Art.pointed_arch(root,Vector3(23,0,-69.5),6.8,8.5)
	for side in [-1,1]:
		Art.cylinder(root,Vector3(23+side*4.5,4.5,-71),0.7,0.5,9,Art.stone(),12)
		Art.cylinder(root,Vector3(23+side*4.5,10,-71),1,0,2,Art.stone(),8)

static func citadel(region: Node3D, root: Node3D) -> void:
	var routes := [[Vector3(0,0,58),Vector3(0,0,-55)],[Vector3(0,0,-9),Vector3(-19,0,-16)],[Vector3(0,0,-33),Vector3(18,0,-35)],[Vector3(0,0,38),Vector3(-7,0,38)]]
	Detail.ground(region,routes,2)
	# The upper story gives the final destination a readable cathedral silhouette.
	for side in [-1,1]:
		for z in [5,-10,-25,-40,-55]:
			Detail.niche(root,Vector3(side*31.45,2.5,z),-side*PI/2,Color("6b618d"),5.4)
			Detail.banner(root,Vector3(side*31.35,8,z-4),-side*PI/2,Color("50354d"),3.8)
		for x in [10,21]:
			var at := Vector3(side*x,0,-66)
			Art.cylinder(root,at+Vector3.UP*9,2.3,1.8,18,Art.stone(),16)
			Art.cylinder(root,at+Vector3.UP*21,2.8,0,6,Art.material("citadel_slate",Color("25313f")),12)
			for y in [6,12,17.7]:
				Art.cylinder(root,at+Vector3.UP*y,2.6,2.6,0.3,Art.stone(),16)
			Detail.niche(root,at+Vector3(0,11,2.4),0,Color("666088"),4.4)
	# Prisoners have a roofed cell behind the existing prison gate, not a floating
	# grid in an empty courtyard. Side/back walls stay behind their authored points.
	region.box(Vector3(-19,4.0,-22),Vector3(8,0.25,9),Color("59616b"))
	for x in [-23,-15]:
		region.box(Vector3(x,2,-24),Vector3(0.2,4,4),Color("59616b"))
	region.box(Vector3(-19,2,-26),Vector3(8,4,0.2),Color("59616b"))
	for x in [-21,-17]:
		Detail.barrel(root,Vector3(x,0,-25.7),0.5)
	# Sealed service houses anchor the courtyard edges in the same architectural
	# language as the village. Their real footprints are included in navigation.
	for side in [-1,1]:
		var house: Node3D = region.box(Vector3(side*25,3.2,-43),Vector3(8,6.4,12),Color("555661"))
		house.get_child(0).hide()
		var facade := Node3D.new()
		facade.position = Vector3(side*25,0,-43)
		root.add_child(facade)
		Kit.house(facade,Vector3(8,6.4,12),-side)
	Detail.banner(root,Vector3(-19,4.2,-17.4),0,Color("563847"),1.6)
	for side in [-1,1]:
		Detail.niche(root,Vector3(side*9,1.5,-63.45),0,Color("71658f"),5)
		Detail.banner(root,Vector3(side*8,9,-55.6),0,Color("50354d"),4.5)
	signpost(root,Vector3(-3.3,0,-9),"PRISON  ←","RITUAL ASCENT  ↑")
	# Include the new rear cell enclosure in the actual navigation footprint.
	region.remove_child(region.navigation)
	region.navigation.queue_free()
	region.build_navigation(Rect2(-48,-64,96,126),1.0)

static func signpost(root: Node3D, at: Vector3, first: String, second: String) -> void:
	Art.cylinder(root,at+Vector3.UP*1.1,0.08,0.06,2.2,Kit.wood(),8)
	for index in range(2):
		var y: float = 1.9-index*0.45
		Art.box(root,at+Vector3(0,y,0),Vector3(2.2,0.38,0.12),Kit.wood())
		var text := Label3D.new()
		preload("res://game/localization/localizer.gd").set_text(text, first if index==0 else second)
		text.position = at+Vector3(0,y,0.075)
		text.font = preload("res://game/presentation/ui_style.gd").font()
		text.font_size = 32
		text.pixel_size = 0.0025
		text.modulate = Color("dfd0ab")
		text.visibility_range_end = 16
		root.add_child(text)
