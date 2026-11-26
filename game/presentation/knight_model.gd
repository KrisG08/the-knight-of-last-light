extends RefCounted
const Art = preload("res://game/presentation/art_kit.gd")

static func build(root: Node3D, sword_pivot: Node3D) -> Dictionary:
	var steel := Art.material("knight_steel",Color("7d9099"),0.8)
	var dark := Art.material("knight_joint",Color("222e34"),0.35)
	var trim := Art.material("knight_trim",Color("a59165"),0.65)
	var cloth := Art.material("knight_cloth",Color("3a2434"))
	# Layered cuirass, gorget and articulated waist plates.
	Art.cylinder(root,Vector3(0,1.12,0),0.24,0.33,0.65,steel,8)
	Art.cylinder(root,Vector3(0,1.48,0),0.24,0.17,0.14,trim,12)
	Art.box(root,Vector3(0,0.91,0),Vector3(0.54,0.09,0.4),dark)
	for y in [0.73,0.81]:
		Art.box(root,Vector3(0,y,0),Vector3(0.53,0.075,0.4),steel)
	Art.box(root,Vector3(0,1.14,-0.28),Vector3(0.025,0.48,0.025),trim)
	Art.box(root,Vector3(0,1.25,-0.28),Vector3(0.23,0.025,0.025),trim)
	# Closed great helm with a readable eye slit and breathing rivets.
	Art.cylinder(root,Vector3(0,1.7,0),0.23,0.19,0.4,steel,10)
	Art.box(root,Vector3(0,1.76,-0.205),Vector3(0.31,0.035,0.035),dark)
	Art.box(root,Vector3(0,1.64,-0.225),Vector3(0.025,0.19,0.03),trim)
	for x in [-0.1,0.1]:
		for y in [1.60,1.65]:
			Art.box(root,Vector3(x,y,-0.219),Vector3(0.025,0.025,0.02),dark)
	var legs: Array[Node3D] = []
	for side in [-1,1]:
		var leg := Node3D.new()
		leg.position = Vector3(side*0.17,0.78,0)
		root.add_child(leg)
		Art.cylinder(leg,Vector3(0,-0.19,0),0.105,0.13,0.35,steel,8)
		Art.cylinder(leg,Vector3(0,-0.42,0),0.12,0.12,0.12,dark,8)
		Art.cylinder(leg,Vector3(0,-0.57,0),0.09,0.115,0.3,steel,8)
		Art.box(leg,Vector3(0,-0.72,-0.08),Vector3(0.22,0.14,0.4),dark)
		legs.append(leg)
		var shoulder := Art.cylinder(root,Vector3(side*0.36,1.36,0),0.2,0.11,0.23,steel,10)
		shoulder.rotation.z = side*0.3
		Art.cylinder(root,Vector3(side*0.37,1.49,0),0.13,0.14,0.045,trim,10)
	# Shield face and boss, carried clear of the body.
	Art.cylinder(root,Vector3(-0.48,1.07,-0.05),0.1,0.12,0.4,dark,8)
	var shield := Art.cylinder(root,Vector3(-0.5,1.02,-0.25),0.35,0.35,0.09,dark,8)
	shield.rotation.x = PI/2
	var rim := Art.cylinder(root,Vector3(-0.5,1.02,-0.3),0.35,0.33,0.025,trim,8)
	rim.rotation.x = PI/2
	Art.box(root,Vector3(-0.5,1.02,-0.33),Vector3(0.035,0.49,0.025),steel)
	Art.box(root,Vector3(-0.5,1.09,-0.33),Vector3(0.36,0.035,0.025),steel)
	Art.cylinder(sword_pivot,Vector3(0.41,0.07,-0.14),0.1,0.115,0.36,steel,8)
	Art.box(sword_pivot,Vector3(0.42,0,-0.34),Vector3(0.17,0.12,0.17),dark)
	Art.box(sword_pivot,Vector3(0.42,0,-0.48),Vector3(0.38,0.07,0.06),trim)
	Art.box(sword_pivot,Vector3(0.42,0,-1.15),Vector3(0.09,0.045,1.3),steel)
	var tip := PrismMesh.new()
	tip.size = Vector3(0.09,0.22,0.045)
	var tip_node := Art.mesh(sword_pivot,tip,Vector3(0.42,0,-1.91),steel)
	tip_node.rotation.x = -PI/2
	# Authored cape surface with irregular hem, double sided.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(5):
		for col in range(4):
			var a := cape_vertex(row,col)
			var b := cape_vertex(row+1,col)
			var c := cape_vertex(row+1,col+1)
			var d := cape_vertex(row,col+1)
			for vertex in [a,b,c,a,c,d]:
				surface.add_vertex(vertex)
	surface.generate_normals()
	var cape_material := cloth.duplicate() as StandardMaterial3D
	cape_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	Art.mesh(root,surface.commit(),Vector3.ZERO,cape_material)
	return {"legs":legs}

static func cape_vertex(row: int, col: int) -> Vector3:
	var t := float(row)/5
	var x := (float(col)/4-0.5)*(0.58+t*0.3)
	return Vector3(x,1.42-t*1.15+sin(col*2.0)*0.035*t,0.25+t*0.18+sin(row*1.2+col)*0.045)
