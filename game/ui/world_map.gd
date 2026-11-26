extends Control
## A north-up local plan from authored navigation, with a discovered-region route.
const L = preload("res://game/localization/localizer.gd")
const Journal = preload("res://game/ui/journal_content.gd")
const REGIONS = ["refuge", "village", "blackwood", "order", "peaks", "citadel"]
const NAMES = ["Lantern Refuge", "Ashen Village", "Blackwood", "Order's Ruins", "Ashen Peaks", "Eclipse Citadel"]
const POIS = {"checkpoint":"Lantern", "order_depth":"Forward route", "peaks_gate":"Forward route", "fortress":"Forward route", "citadel_gate":"Forward route", "oren":"Oren", "lyra":"Lyra", "cael":"Sir Cael", "crypt":"Crypt", "forest":"Blackwood", "travel":"Return route", "forest_exit":"Return route", "forest_end":"Forward route", "order_exit":"Return route", "peaks_exit":"Return route", "citadel_exit":"Return route", "prisoners":"Prison", "ritual_lore":"Ritual inscription", "shortcut":"Shortcut", "forest_shortcut":"Shortcut", "peaks_shortcut":"Shortcut", "citadel_depth":"Maldrek", "seal":"Seal", "root_seal":"Seal", "oath_seal":"Seal", "forge_seal":"Seal", "artifact":"Artifact"}
var game: Node
var bounds := Rect2()
var vertices := PackedVector3Array()
var polygons: Array[PackedInt32Array] = []
var markers: Dictionary = {}
var target := ""
var detail: Label
var route := PackedVector2Array()
func setup(owner_game: Node, selection: Label) -> void:
	game = owner_game
	detail = selection
	custom_minimum_size = Vector2(0, 410)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_contents = true
	if is_instance_valid(game.region.navigation):
		var mesh: NavigationMesh = game.region.navigation.navigation_mesh
		vertices = mesh.get_vertices()
		for index in range(mesh.get_polygon_count()): polygons.append(mesh.get_polygon(index))
	# Guardian rooms use a physical floor without a navigation region.
	if vertices.is_empty():
		for child in game.region.get_children():
			if not child is Node3D or child.get_child_count() == 0: continue
			var visual := child.get_child(0) as MeshInstance3D
			if visual == null or visual.mesh == null or child.position.y > 0: continue
			var floor_bounds: AABB = visual.mesh.get_aabb()
			var dimensions: Vector3 = floor_bounds.size
			if dimensions.x < 5 or dimensions.z < 5: continue
			for corner in [Vector3(-1,0,-1),Vector3(1,0,-1),Vector3(1,0,1),Vector3(-1,0,1)]:
				vertices.append(child.position + floor_bounds.get_center() + dimensions * corner * 0.5)
			polygons.append(PackedInt32Array([0,1,2,3]))
			break
	bounds = Rect2(Vector2(game.player.position.x, game.player.position.z), Vector2.ONE)
	for vertex in vertices: bounds = bounds.expand(Vector2(vertex.x, vertex.z))
	for key in game.region.points:
		if key not in POIS: continue
		if key == "checkpoint" and game.region.region_id in ["region.crypt","region.grove","region.sanctum","region.forge","region.ritual"]: continue
		if key == "oren" and not game.region.oren.visible: continue
		if key == "lyra" and is_instance_valid(game.region.lyra) and not game.region.lyra.visible: continue
		if key == "cael" and is_instance_valid(game.region.cael) and not game.region.cael.visible: continue
		var at: Vector3 = game.region.points[key]
		markers[key] = Vector2(at.x, at.z)
		bounds = bounds.expand(markers[key])
	bounds = bounds.grow(3)
	target = next_landmark()
	if target in markers and is_instance_valid(game.region.navigation):
		var start := Vector3(game.player.position.x,0,game.player.position.z)
		var end := Vector3(markers[target].x,0,markers[target].y)
		for point in NavigationServer3D.map_get_path(game.region.navigation.get_navigation_map(),start,end,true):
			route.append(Vector2(point.x,point.z))
	resized.connect(queue_redraw)
	queue_redraw()
func next_landmark() -> String:
	var state: Dictionary = game.session.state.campaign
	match game.region.region_id:
		"region.refuge": return "travel"
		"region.village":
			if "ally.oren" not in state.recruited_ally_ids: return "oren"
			return "crypt" if "seal.burial" not in state.broken_seal_ids else "forest"
		"region.blackwood": return "forest_end"
		"region.order": return "order_depth" if "seal.oath" not in state.broken_seal_ids else "peaks_gate"
		"region.peaks": return "fortress" if "seal.forge" not in state.broken_seal_ids else "citadel_gate"
		"region.citadel": return "citadel_depth"
	for key in ["artifact","seal","root_seal","oath_seal","forge_seal","checkpoint"]:
		if key in markers: return key
	return ""
func project(at: Vector2) -> Vector2:
	var available := Vector2(size.x - 64, size.y - 155)
	var factor := minf(available.x / maxf(1,bounds.size.x), available.y / maxf(1,bounds.size.y))
	return Vector2(size.x / 2, 100 + available.y / 2) + (at - bounds.get_center()) * factor
func _draw() -> void:
	if game == null: return
	draw_style_box(preload("res://game/presentation/ui_style.gd").frame(Color("10151f"),Color("634a80"),8), Rect2(Vector2.ZERO,size))
	var font := preload("res://game/presentation/ui_style.gd").font()
	for index in range(REGIONS.size()):
		var id: String = "region." + REGIONS[index]
		var known := Journal.discovered(game.session.state,id,game.region.region_id)
		var at := Vector2(60 + (size.x - 120) * index / 5, 30)
		if index > 0: draw_line(at-Vector2((size.x-120)/5,0),at,Color("6e5487") if known else Color("34313e"),2)
		var active: bool = "checkpoint."+REGIONS[index] in game.session.state.campaign.checkpoint_ids
		draw_circle(at,7,Color("edc479") if active else Color("70647c"))
		if id == game.region.region_id: draw_arc(at,12,0,TAU,24,Color("d8a3ff"),2)
		var caption: String = L.text(NAMES[index] if known else "Undiscovered")
		draw_multiline_string(font,at+Vector2(-52,22),caption.replace(" ","\n"),HORIZONTAL_ALIGNMENT_CENTER,104,11)
	for polygon in polygons:
		var points := PackedVector2Array()
		for index in polygon: points.append(project(Vector2(vertices[index].x,vertices[index].z)))
		if points.size() >= 3: draw_colored_polygon(points,Color("293d42"))
	for obstacle in game.region.obstacles:
		var corner := project(obstacle.position)
		var end := project(obstacle.end)
		draw_rect(Rect2(corner,end-corner),Color("55515d"))
	if route.size() > 1:
		var points := PackedVector2Array()
		for point in route: points.append(project(point))
		draw_polyline(points,Color("bc89df"),2,true)
	for key in markers:
		var at := project(markers[key])
		var activated: bool = "checkpoint." + game.region.region_id.trim_prefix("region.") in game.session.state.campaign.checkpoint_ids
		var color := Color("e6bd78") if key == "checkpoint" and activated else Color("aaa3b3")
		if key == target: color = Color("d29aff")
		draw_circle(at,5,color)
		if key == target: draw_arc(at,9,0,TAU,20,color,2)
	var player := project(Vector2(game.player.position.x,game.player.position.z))
	draw_colored_polygon(PackedVector2Array([player+Vector2(0,-8),player+Vector2(-6,5),player+Vector2(6,5)]),Color("f5f2e8"))
	draw_string(font,Vector2(size.x-30,95),"N",HORIZONTAL_ALIGNMENT_LEFT,-1,16)
	if target in markers:
		draw_string(font,Vector2(20,size.y-16),L.text("Next landmark")+" · "+label_for(target),HORIZONTAL_ALIGNMENT_LEFT,size.x-40,16)
func label_for(key: String) -> String:
	return L.text("Forward route" if key == "travel" and game.region.region_id == "region.refuge" else POIS[key])
func _gui_input(event: InputEvent) -> void:
	var at := Vector2.ZERO
	if event is InputEventMouseButton and event.pressed: at = event.position
	elif event is InputEventScreenTouch and event.pressed: at = event.position
	else: return
	var nearest := ""
	var distance := 24.0
	for key in markers:
		var candidate := project(markers[key]).distance_to(at)
		if candidate < distance: nearest = key; distance = candidate
	if not nearest.is_empty():
		L.set_text(detail, "Forward route" if nearest == "travel" and game.region.region_id == "region.refuge" else POIS[nearest])
		accept_event()
