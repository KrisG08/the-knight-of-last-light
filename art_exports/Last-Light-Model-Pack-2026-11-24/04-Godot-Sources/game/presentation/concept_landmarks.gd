extends RefCounted
## Fixed authored Gothic scenery following world-concepts-v061. Shared geometry
## batches bound draw calls; peripheral details never become invisible blockers.
const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const Detail = preload("res://game/presentation/chapter_detail_kit.gd")
var region: Node3D
var root: Node3D
var blocks: Dictionary = {}
var ribs: Array[Transform3D] = []
var stone: Material
var iron: Material

static func build(owner_region: Node3D) -> void:
	var builder = load("res://game/presentation/concept_landmarks.gd").new()
	builder.region = owner_region
	builder.root = Node3D.new(); builder.root.name = "ConceptLandmarks"
	owner_region.add_child(builder.root)
	builder.root.set_meta("concept_region",owner_region.region_id)
	builder.stone = Art.stone()
	builder.iron = Art.material("concept_iron",Color("292331"),.65)
	builder.compose()
	Kit.flush(builder.root,builder.blocks)
	if not builder.ribs.is_empty():
		var shaft := CylinderMesh.new(); shaft.top_radius = 1; shaft.bottom_radius = 1; shaft.height = 1; shaft.radial_segments = 10; shaft.rings = 1
		Dressing.instances(builder.root,shaft,builder.stone,builder.ribs)
		builder.root.set_meta("rib_instances",builder.ribs.size())

func ground(at: Vector3) -> Vector3:
	return at+Vector3.UP*region.height_at(at.x,at.z)

func block(at: Vector3, size: Vector3, material: Material = null) -> void:
	Kit.piece(blocks,stone if material == null else material,at,size)

func beam(a: Vector3, b: Vector3, radius: float) -> void:
	var vector := b-a
	if vector.length() < .001: return
	var basis := Basis(Quaternion(Vector3.UP,vector.normalized()))*Basis.from_scale(Vector3(radius,vector.length(),radius))
	ribs.append(Transform3D(basis,(a+b)*.5))

func arch(at: Vector3, width: float, height: float) -> void:
	for side in [-1,1]:
		for trim in [0.0,.22]:
			var previous := at+Vector3(side*(width*.5+trim),height*.58,0)
			beam(at+Vector3(side*(width*.5+trim),.4,0),previous,.12)
			for step in range(1,17):
				var t := step/16.0
				var point := at+Vector3(side*(width*.5+trim)*(1-t),height*(.58+.42*sqrt(t))+trim,0)
				beam(previous,point,.12); previous = point
		block(at+Vector3(side*width*.5,.25,0),Vector3(.85,.5,1.1))

func circle(at: Vector3, radius: float, thickness: float) -> void:
	for step in range(40):
		var a := step*TAU/40; var b := (step+1)*TAU/40
		beam(at+Vector3(cos(a),sin(a),0)*radius,at+Vector3(cos(b),sin(b),0)*radius,thickness)

func rose(at: Vector3, radius: float) -> void:
	block(at+Vector3(0,0,-.6),Vector3(radius*2+maxf(.35,radius*.3),radius*2+maxf(.5,radius*.5),.8))
	arch(at-Vector3(0,radius+1,0),radius*2.4,radius*2.8)
	var glass := Art.material("concept_lavender_glass",Color("281d38"),.1)
	glass.emission_enabled = true; glass.emission = Color("4b2a69"); glass.emission_energy_multiplier = .16
	var pane := CylinderMesh.new(); pane.top_radius = radius*.95; pane.bottom_radius = radius*.95; pane.height = .07; pane.radial_segments = 48
	Art.mesh(root,pane,at+Vector3(0,0,-.13),glass).rotation.x = PI/2
	circle(at,radius,.10); circle(at,radius*1.09,.08); circle(at,radius*.22,.065)
	for petal in range(8):
		var angle := petal*TAU/8
		var direction := Vector3(cos(angle),sin(angle),0)
		circle(at+direction*radius*.64,radius*.30,.055)
		beam(at+direction*radius*.22,at+direction*radius*.96,.055)

func buttress(at: Vector3, side: float, height: float) -> void:
	block(at+Vector3(0,height*.35,0),Vector3(1,height*.7,1.5))
	block(at+Vector3(side*.5,height*.12,0),Vector3(1.5,height*.24,2))
	beam(at+Vector3(0,height*.6,0),at+Vector3(-side*3,height*.92,0),.22)
	beam(at+Vector3(0,height*.7,0),at+Vector3(0,height*1.2,0),.16)

func belfry(at: Vector3, height: float, width: float) -> void:
	for side in [-1,1]:
		block(at+Vector3(side*width*.45,height*.35,0),Vector3(.9,height*.7,2.4))
	arch(at+Vector3(0,height*.52,.2),width*.72,height*.3)
	var roof := PrismMesh.new(); roof.size = Vector3(width*1.35,height*.26,3.4)
	Art.mesh(root,roof,at+Vector3(0,height*.91,0),Kit.material("grey_roof_tiles",Color("3d334b"),.4))
	for side in [-1,1]: beam(at+Vector3(side*width*.6,height*.8,0),at+Vector3(side*width*.6,height*1.08,0),.09)

func spire(at: Vector3, height: float, radius: float) -> void:
	Art.cylinder(root,at+Vector3.UP*height*.5,radius,radius*.82,height,stone,16)
	for fraction in [.12,.5,.82,1.0]:
		Art.cylinder(root,at+Vector3.UP*height*fraction,radius*1.12,radius*1.12,.55,stone,16)
	var slate := Kit.material("grey_roof_tiles",Color("3d334b"),.4)
	Art.cylinder(root,at+Vector3.UP*(height+radius*2),radius*1.3,.03,radius*4,slate,12)
	var glass := Art.material("concept_spire_windows",Color("8d663d"))
	glass.emission_enabled = true; glass.emission = Color("b78448"); glass.emission_energy_multiplier = .3
	for fraction in [.42,.7,.9]:
		for x in [-.28,0,.28]:
			block(at+Vector3(x*radius,height*fraction,radius*.94),Vector3(.25,2.2,.12),glass)

func lamp(at: Vector3) -> void:
	Art.lantern(root,at)
	var light := OmniLight3D.new(); light.position = at+Vector3.UP*.7
	light.light_color = Color("e7ad63"); light.light_energy = 1.7
	light.omni_range = 8; light.shadow_enabled = false
	root.add_child(light)

func camp_collision(at: Vector3, size: Vector3) -> void:
	var collider: Node3D = region.box(at,size,Color.BLACK)
	collider.get_child(0).hide()
	# Refuge terrain is already elevated; the legacy box helper's flat-floor
	# height test cannot identify every raised footprint.
	var footprint := Rect2(Vector2(at.x-size.x*.5,at.z-size.z*.5),Vector2(size.x,size.z)).grow(.55)
	if not region.obstacles.has(footprint): region.obstacles.append(footprint)

func compose() -> void:
	match region.region_id:
		"region.refuge": camp()
		"region.village": village()
		"region.blackwood": woodland()
		"region.order": order()
		"region.peaks": peaks()
		"region.citadel": citadel()
		_: chamber()

func camp() -> void:
	var at := ground(Vector3(-17,0,47))
	arch(at,7.6,9); rose(at+Vector3(0,10.8,0),2.2)
	belfry(at+Vector3(-6,0,-2),17,3.5)
	for side in [-1,1]:
		buttress(at+Vector3(side*5,0,-2),side,9)
		camp_collision(at+Vector3(side*3.8,3.2,0),Vector3(.7,6.4,.7))
	lamp(at+Vector3(4,.2,1.5))
	var scans = preload("res://game/presentation/real_assets.gd")
	for side in [-1,1]:
		var trunk_at := ground(Vector3(side*14,0,97))
		scans.place_mesh(root,"dead_tree_trunk","dead_tree_trunk",trunk_at,Vector3.ONE*3.6,side*.6)
		camp_collision(trunk_at+Vector3.UP*2,Vector3(1.8,4,1.8))
	for pos in [Vector3(-8,0,83),Vector3(-12,0,93),Vector3(9,0,88)]:
		var p := ground(pos)
		tent(p)
		camp_collision(p+Vector3.UP*.8,Vector3(3.5,1.6,3.8))
		Detail.crate(root,p+Vector3(2.2,0,1.7),Vector3(.8,.7,.8))
	# Only new refuge footprints require a rebuilt authored navigation grid.
	region.remove_child(region.navigation); region.navigation.queue_free()
	region.build_navigation(preload("res://game/world/regions/forest_approach.gd").BOUNDS,4.0)

func tent(at: Vector3) -> void:
	var surface := SurfaceTool.new(); surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for side in [-1,1]:
		for row in range(12):
			for column in range(8):
				for corner in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
					var u: float = (column+corner.x)/8.0; var v: float = (row+corner.y)/12.0
					var sag := sin(v*PI)*(.13+.08*sin(u*PI))
					var wrinkle := sin(v*PI*8)*sin(u*PI)*.045
					surface.set_uv(Vector2(u,v))
					surface.add_vertex(Vector3(side*u*1.9,2.6*(1-u)-sag+wrinkle+.08,(v-.5)*4.6))
		# Parted front flaps retain a narrow, dark opening and visible cloth edges.
		for point in [Vector3(0,2.55,2.3),Vector3(side*.35,.1,2.3),Vector3(side*1.9,.1,2.3)]:
			surface.set_uv(Vector2(point.x*.25+.5,point.y/2.6)); surface.add_vertex(point)
	surface.generate_normals()
	var canvas := ShaderMaterial.new(); canvas.shader = preload("res://assets/materials/weathered_canvas.gdshader")
	canvas.set_shader_parameter("cloth_color",Color("77624f")); canvas.set_shader_parameter("flutter",.012)
	Art.mesh(root,surface.commit(),at,canvas)
	var rope := Art.material("concept_guy_rope",Color("78654e"))
	Art.beam(root,at+Vector3(0,2.56,-2.3),at+Vector3(0,2.56,2.3),.045,Kit.wood())
	for z in [-2.3,2.3]:
		Art.beam(root,at+Vector3(0,.1,z),at+Vector3(0,2.56,z),.055,Kit.wood())
		for side in [-1,1]:
			var peg := at+Vector3(side*2.7,.04,z*1.28)
			Art.beam(root,at+Vector3(side*1.75,.3,z),peg,.012,rope)
			Art.beam(root,peg-Vector3.UP*.02,peg+Vector3.UP*.22,.035,Kit.wood())

func village() -> void:
	var at := ground(Vector3(-45,0,-29))
	belfry(at,27,6); rose(at+Vector3(0,12,1.3),2.1)
	for side in [-1,1]:
		var p := ground(Vector3(side*43,0,-18))
		arch(p,6,11); buttress(p+Vector3(side*5,0,0),side,13)
	lamp(ground(Vector3(-8,.1,5)))

func woodland() -> void:
	var at := ground(Vector3(-38,0,-39))
	arch(at,9,12); rose(at+Vector3(0,14,0),2.9)
	for side in [-1,1]: buttress(at+Vector3(side*6,0,-1),side,12)
	lamp(ground(Vector3(16,.1,-42)))

func order() -> void:
	var at := ground(Vector3(0,0,-43))
	rose(at+Vector3(0,17,0),4.2)
	for side in [-1,1]:
		for z in [-14,-30,-48]:
			buttress(ground(Vector3(side*38,0,z)),side,19)
			arch(ground(Vector3(side*30,6,z)),7,11)
		Detail.banner(root,at+Vector3(side*7,12,.2),0,Color("48263e"),5)

func peaks() -> void:
	for side in [-1,1]:
		var at := ground(Vector3(side*43,0,-31))
		# End towers carry the high windows; no freestanding tracery in the sky.
		block(at+Vector3(0,10,0),Vector3(8.5,20,3.4))
		belfry(at,25,9)
		rose(at+Vector3(0,19,2),3)
		belfry(ground(Vector3(side*29,0,-87)),27,5)
	var at := ground(Vector3(0,0,-81))
	arch(at,14,19); rose(at+Vector3(0,23,0),4)

func citadel() -> void:
	var at := ground(Vector3(0,0,28))
	for side in [-1,1]:
		rose(at+Vector3(side*14,12,1),.65)
		for z in [45,17,-12,-44]: buttress(ground(Vector3(side*46,0,z)),side,24)
		Detail.banner(root,at+Vector3(side*10,14,.3),0,Color("4d264b"),6)
	# Cathedral crowns the already-authored ascending terraces, beyond the north wall.
	at = ground(Vector3(0,0,-74))
	arch(at,19,30); rose(at+Vector3(0,35,0),6.2)
	spire(ground(Vector3(0,0,-94)),74,4)
	for side in [-1,1]:
		spire(ground(Vector3(side*11,0,-88)),59,3)
		belfry(at+Vector3(side*17,0,-3),53,7)
		belfry(at+Vector3(side*29,0,-9),39,5)
		rose(at+Vector3(side*17,27,1),3.2)

func chamber() -> void:
	var base := ground(Vector3.ZERO)
	var ritual: bool = region.region_id == "region.ritual"
	# Fit tracery to the inside of each existing vault, not behind its end wall.
	var width := 23.0
	var height := 13.0
	var rear := -12.6
	var radius := 3.2
	match region.region_id:
		"region.crypt": width = 18.4; height = 9.4; rear = -9.1; radius = 1.5
		"region.sanctum": width = 22.0; height = 11.5; rear = -11.0; radius = 2.2
		"region.forge": width = 22.0; height = 9.4; rear = -11.0; radius = 1.8
		"region.ritual": height = 23.0; radius = 4.5
	for z in [-8,0,8]: arch(base+Vector3(0,0,z),width,height)
	rose(base+Vector3(0,height*.74,rear),radius)
	for side in [-1,1]:
		for z in [-8,0,8]:
			Detail.banner(root,base+Vector3(side*(width*.5-.3),height*.54,z),side*PI/2,Color("472840"),2.4)
		lamp(base+Vector3(side*(width*.5-1),.2,-8.5))
	if region.region_id == "region.grove":
		# Root arches replace a bare arena silhouette without shrinking its floor.
		for side in [-1,1]: belfry(base+Vector3(side*17,0,-12),13,4)
