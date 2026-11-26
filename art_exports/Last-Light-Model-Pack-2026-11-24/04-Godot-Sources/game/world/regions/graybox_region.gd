extends Node3D
const Art = preload("res://game/presentation/art_kit.gd")
const RealAssets = preload("res://game/presentation/real_assets.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const ForestLayout = preload("res://game/world/regions/blackwood_layout.gd")
const OrderLayout = preload("res://game/world/regions/order_layout.gd")
const PeaksLayout = preload("res://game/world/regions/peaks_layout.gd")
const CitadelLayout = preload("res://game/world/regions/citadel_layout.gd")
const ForestApproach = preload("res://game/world/regions/forest_approach.gd")
const VillageKit = preload("res://game/presentation/village_kit.gd")

var region_id: String = "region.refuge"
var obstacles: Array[Rect2] = []
var points: Dictionary = {}
var navigation: NavigationRegion3D
var shortcut: StaticBody3D
var oren: Node3D
var token: Node3D
var captured_gate: StaticBody3D
var interact_colliders: Dictionary = {}
var entrance_barrier: StaticBody3D
var seal: Node3D
var seal_label: Label3D
var forest_label: Label3D
var village_ground: Node3D
var lyra: Node3D
var satchel: Node3D
var forest_shortcut: StaticBody3D
var order_ward: StaticBody3D
var order_label: Label3D
var forest_ground: Node3D
var refuge_echo: Label3D
var cael: Node3D
var expedition: Node3D
var peaks_ward: StaticBody3D
var peaks_label: Label3D
var order_ground: Node3D
var peaks_shortcut: StaticBody3D
var citadel_ward: StaticBody3D
var citadel_label: Label3D
var prison_bars: StaticBody3D
var prison_label: Label3D
var prison_survivors: Node3D
var rescued_survivors: Node3D
var curse_presence: Node3D

func height_at(x: float, z: float) -> float:
	if region_id == "region.refuge": return ForestApproach.height_at(x,z)
	return preload("res://game/world/regions/elevation.gd").height(region_id,x,z)

func surface_point(at: Vector3) -> Vector3:
	return at + Vector3.UP*height_at(at.x,at.z)

func box(at: Vector3, size: Vector3, color: Color, solid: bool = true) -> Node3D:
	var parent: Node3D = StaticBody3D.new() if solid else Node3D.new()
	parent.position = at
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	if (size.length() > 2 and color.s < 0.35) or (size.y < 1 and size.x > 2 and size.z > 2):
		material.albedo_texture = Art.stone().albedo_texture
		material.normal_enabled = Art.stone().normal_enabled
		material.normal_texture = Art.stone().normal_texture
		material.roughness_texture = Art.stone().roughness_texture
		material.roughness_texture_channel = Art.stone().roughness_texture_channel
		material.uv1_triplanar = true
		material.uv1_scale = Vector3.ONE*0.5
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	visual.material_override = material
	parent.add_child(visual)
	if solid:
		var shape := CollisionShape3D.new()
		var collider := BoxShape3D.new()
		collider.size = size
		shape.shape = collider
		parent.add_child(shape)
		if at.y + size.y / 2 > 0.3 and at.y - size.y / 2 < 1.8:
			obstacles.append(Rect2(Vector2(at.x - size.x / 2, at.z - size.z / 2), Vector2(size.x, size.z)).grow(0.55))
	add_child(parent)
	return parent

func label(at: Vector3, text: String, size: float = 0.005) -> Label3D:
	var item := Label3D.new()
	item.font = preload("res://game/presentation/ui_style.gd").font()
	item.position = at
	preload("res://game/localization/localizer.gd").set_text(item, text)
	item.font_size = 24
	item.pixel_size = minf(size,0.0025)
	item.visibility_range_end = 18
	item.modulate = Color("c2dce0")
	item.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(item)
	return item

func lantern(at: Vector3, text: String) -> void:
	if region_id == "region.village":
		Art.cylinder(self,at+Vector3.UP*0.65,0.08,0.06,1.3,VillageKit.wood(),8)
		VillageKit.torch(self,at+Vector3.UP*1.5,Vector3.FORWARD,false)
	else:
		Art.lantern(self,at)
	var lamp := OmniLight3D.new()
	lamp.position = at + Vector3(0, 1.4, 0)
	lamp.light_color = Color("ffba6d")
	lamp.light_energy = 3
	lamp.omni_range = 7
	add_child(lamp)
	label(at + Vector3(0, 2.2, 0), text, 0.0035)

func house(at: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	if region_id == "region.village" and size.x<=12:
		var dimensions := Vector3(size.x,6.4+maxf(0,size.y-4)*0.4,size.z)
		var body := box(at+Vector3.UP*dimensions.y*0.5,dimensions,color) as StaticBody3D
		body.get_child(0).hide()
		var visual := Node3D.new()
		visual.position.y = -dimensions.y*0.5
		body.add_child(visual)
		VillageKit.house(visual,dimensions,1 if at.x<0 else -1)
		return body
	var shell := box(at + Vector3(0, size.y / 2, 0), size, color) as StaticBody3D
	var roof := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(size.x + 1, 2.5, size.z + 1)
	roof.mesh = prism
	roof.position = at + Vector3(0, size.y + 1.1, 0)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("34333c")
	roof.material_override = material
	add_child(roof)
	box(at + Vector3(0, 1, size.z / 2 + 0.05), Vector3(1.3, 2, 0.15), Color("332c2b"), false)
	for x in [-size.x * 0.3, size.x * 0.3]:
		box(at + Vector3(x, 2.5, size.z / 2 + 0.1), Vector3(0.8, 0.9, 0.15), Color("b19666"), false)
	return shell

func person(at: Vector3, text: String) -> Node3D:
	var parent := Node3D.new()
	add_child(parent)
	var model := Node3D.new()
	model.position = at
	parent.add_child(model)
	var weapon := Node3D.new()
	model.add_child(weapon)
	var kind := "oren" if text.contains("OREN") else ("lyra" if text.contains("LYRA") else ("cael" if text.contains("CAEL") else "survivor"))
	preload("res://game/presentation/friendly_models.gd").build(model,kind,weapon)
	var nameplate := label(at + Vector3(0, 2.5, 0), text, 0.0035)
	nameplate.reparent(parent, false)
	return parent

func build(id: String) -> void:
	region_id = id
	if id == "region.refuge":
		ForestApproach.build(self)
		preload("res://game/presentation/quest_props.gd").build(self)
		preload("res://game/presentation/region_portals.gd").build(self)
		preload("res://game/presentation/concept_landmarks.gd").build(self)
		return
	elif id == "region.village":
		build_village()
	elif id == "region.crypt":
		build_crypt()
	elif id == "region.blackwood":
		build_blackwood()
	elif id == "region.grove":
		ForestLayout.build_grove(self)
	elif id == "region.order":
		OrderLayout.build(self)
	elif id == "region.sanctum":
		OrderLayout.build_sanctum(self)
	elif id == "region.peaks":
		PeaksLayout.build(self)
	elif id == "region.forge":
		PeaksLayout.build_forge(self)
	elif id == "region.citadel":
		CitadelLayout.build(self)
	elif id == "region.ritual":
		CitadelLayout.build_ritual(self)

	Dressing.build(self)
	RealAssets.build(self)
	if id == "region.blackwood":
		preload("res://game/presentation/blackwood_art.gd").build(self)
	if id == "region.order":
		preload("res://game/presentation/order_art.gd").build(self)
	if id == "region.sanctum":
		preload("res://game/presentation/commander_hall.gd").build(self)
	if id == "region.peaks":
		preload("res://game/presentation/peaks_art.gd").build(self)
	if id == "region.forge":
		preload("res://game/presentation/forge_hall.gd").build(self)
	if region_id == "region.citadel":
		preload("res://game/presentation/citadel_art.gd").build(self)
	if region_id == "region.ritual":
		preload("res://game/presentation/ritual_hall.gd").build(self)
	if id == "region.crypt":
		preload("res://game/presentation/burial_chamber.gd").build(self)
		var ambience := preload("res://game/audio/burial_ambience.gd").new()
		ambience.name = "BurialAmbience"
		add_child(ambience)
	if id == "region.village":
		preload("res://game/presentation/village_life.gd").build(self,self)
		VillageKit.finish(self)
		preload("res://game/presentation/village_landscape.gd").build(self)
	if id in ["region.blackwood","region.order","region.peaks","region.citadel"]:
		preload("res://game/presentation/chapter_landscape.gd").build(self)
	if id in ["region.grove","region.sanctum","region.forge","region.ritual"]:
		preload("res://game/presentation/chapter_arenas.gd").build(self)
	if id in ["region.blackwood","region.grove","region.order","region.sanctum","region.peaks","region.forge","region.citadel","region.ritual"]:
		preload("res://game/presentation/late_world_architecture.gd").build(self)
	preload("res://game/presentation/mythic_fauna.gd").build(self)
	preload("res://game/presentation/quest_props.gd").build(self)
	preload("res://game/world/regions/elevation.gd").apply(self)
	if id in ["region.crypt","region.sanctum","region.forge","region.ritual"]:
		var inner := Vector2(13,13) if id=="region.ritual" else Vector2(12,12)
		preload("res://game/presentation/forest_horizon.gd").build(self,inner+Vector2.ONE*4,"ArenaHorizon",inner)
	preload("res://game/presentation/forest_horizon.gd").fit(self)
	preload("res://game/presentation/region_portals.gd").build(self)
	preload("res://game/presentation/concept_landmarks.gd").build(self)

func build_refuge() -> void:
	points = {"spawn": Vector3(0, 0.1, 10), "checkpoint": Vector3(3, 0, 8), "travel": Vector3(0, 0, -14), "oren": Vector3(11, 0, 2), "memorial": Vector3(-11, 0, 2)}
	box(Vector3(0, -0.5, 0), Vector3(38, 1, 36), Color("51564d"))
	for x in [-19, 19]:
		box(Vector3(x, 2, 0), Vector3(1, 4, 36), Color("676a65"))
	box(Vector3(0, 2, 18), Vector3(38, 4, 1), Color("676a65"))
	for x in [-11, 11]:
		box(Vector3(x, 2, -18), Vector3(16, 4, 1), Color("676a65"))
	for x in [-7, 7]:
		for z in [-10, -3, 4]:
			box(Vector3(x, 2.5, z), Vector3(0.9, 5, 0.9), Color("8d8d7c"))
	box(Vector3(0, 5, -10), Vector3(15, 0.8, 1), Color("8d8d7c"))
	box(Vector3(0, 0.015, -1), Vector3(4, 0.03, 28), Color("7e7966"), false)
	lantern(points.checkpoint, "LANTERN REFUGE\nE · Rest")
	label(Vector3(0, 3, -14), "ASHEN VILLAGE\nE · Travel", 0.005)
	box(points.oren + Vector3(0, 0.5, 1.5), Vector3(2, 1, 1), Color("555967"))
	oren = person(points.oren, "OREN · Blacksmith")
	lantern(points.oren + Vector3(2, 0, 0), "THE FORGE")
	interact_colliders.memorial = box(points.memorial + Vector3(0, 1, 0), Vector3(1.5, 2, 1), Color("8f9284"))
	label(points.memorial + Vector3(0, 2.8, 0), "MEMORIAL\nE · Remember the lost", 0.0035)
	points.lyra = Vector3(-11, 0, 9)
	lyra = person(points.lyra, "LYRA · Scout")
	points.cael = Vector3(11, 0, 10)
	cael = person(points.cael, "SIR CAEL\nE · Talk")
	rescued_survivors = Node3D.new()
	add_child(rescued_survivors)
	for x in [13,16]:
		var survivor := person(Vector3(x,0,-7),"RESCUED SURVIVOR")
		survivor.reparent(rescued_survivors,false)
	refuge_echo = label(Vector3(0, 3.5, -6), "", 0.004)
	build_navigation(Rect2(-19, -18, 38, 36))

func build_village() -> void:
	points = {"spawn": Vector3(0, 0.1, 37), "checkpoint": Vector3(3, 0, 31), "travel": Vector3(0, 0, 40), "oren": Vector3(27, 0, -12), "token": Vector3(-27, 0, -17), "shortcut": Vector3(0, 0, 15), "crypt": Vector3(0, 0, -34), "forest": Vector3(26, 0, -33)}
	village_ground = box(Vector3(0, -0.5, 0), Vector3(80, 1, 90), Color("444d48"))
	for x in [-40, 40]:
		box(Vector3(x, 2, 0), Vector3(1, 4, 90), Color("414a45"))
	for z in [-45, 45]:
		box(Vector3(0, 2, z), Vector3(80, 4, 1), Color("414a45"))
	box(Vector3(0, 0.015, 0), Vector3(5, 0.03, 82), Color("746e5f"), false)
	box(Vector3(0, 0.02, -7), Vector3(66, 0.03, 5), Color("746e5f"), false)
	for x in [-20, 20]:
		box(Vector3(x, 0.02, 11), Vector3(4, 0.03, 42), Color("6b6558"), false)
	house(Vector3(-10, 0, 19), Vector3(10, 4, 12), Color("706b62"))
	house(Vector3(10, 0, 19), Vector3(10, 5, 12), Color("69675e"))
	house(Vector3(-11, 0, -8), Vector3(10, 4, 12), Color("62665f"))
	house(Vector3(12, 0, -9), Vector3(8, 4, 10), Color("69665b"))
	house(Vector3(29, 0, 4), Vector3(12, 6, 8), Color("786351"))
	for entry in [[Vector3(-31,0,28),Vector3(8,4,8)],[Vector3(31,0,28),Vector3(8,4,8)],[Vector3(-31,0,7),Vector3(8,4,8)],[Vector3(32,0,-23),Vector3(10,5,8)],[Vector3(-13,0,-27),Vector3(8,4,7)],[Vector3(14,0,-27),Vector3(9,5,7)]]:
		house(entry[0],entry[1],Color("797467"))
	var wheel := box(Vector3(36,3,4),Vector3(1,6,6),Color("453b33"))
	wheel.get_child(0).hide()
	VillageKit.mill_wheel(self,Vector3(36,3,4))
	lantern(Vector3(23, 0, 7), "BURNING MILL")
	lantern(points.checkpoint, "VILLAGE LANTERN\nE · Activate / rest")
	label(points.travel + Vector3(0, 2, 0), "LANTERN REFUGE\nE · Return", 0.004)
	shortcut = box(Vector3(0, 1.6, 18), Vector3(10, 3.2, 0.7), Color("594c3d")) as StaticBody3D
	VillageKit.shortcut_gate(shortcut)
	label(Vector3(0, 3.5, 18), "BARRED SHORTCUT\nOpen from village side", 0.0035)
	oren = person(points.oren, "OREN · Captive\nE · Talk")
	captured_gate = box(points.oren + Vector3(0, 1.25, 1.45), Vector3(3.2, 2.5, 0.15), Color("776453")) as StaticBody3D
	preload("res://game/presentation/prison_cells.gd").village(self)
	interact_colliders.oren = captured_gate
	for x in [-30, -25, -20]:
		for z in [-27, -22]:
			preload("res://game/presentation/village_mausoleum.gd").grave(self,Vector3(x,0,z))
	token = box(points.token + Vector3(0, 0.4, 0), Vector3(0.5, 0.8, 0.5), Color("d7b770"), false)
	label(points.token + Vector3(0, 1.7, 0), "FAMILY TOKEN\nE · Collect", 0.003)
	interact_colliders.crypt = preload("res://game/presentation/village_mausoleum.gd").build(self)
	label(points.crypt + Vector3(0, 3, 0), "GRAVEDIGGER'S CRYPT\nE · Enter burial chamber", 0.004)
	interact_colliders.forest = box(points.forest + Vector3(0, 1.5, 0), Vector3(6, 3, 0.6), Color("714c97"))
	forest_label = label(points.forest + Vector3(0, 3, 0), "BLACKWOOD WARD\nBurial Seal intact", 0.0035)
	label(Vector3(0, 4, -6), "ASHEN VILLAGE · SQUARE", 0.005)
	build_navigation()

func apply_state(state: Dictionary) -> void:
	var portals:=get_node_or_null("RegionPortals")
	if portals!=null: portals.apply_state(state)
	if not is_instance_valid(curse_presence):
		curse_presence=preload("res://game/presentation/curse_presence.gd").new()
		add_child(curse_presence); curse_presence.setup(self)
	curse_presence.apply_state(state)
	var opening_story := get_node_or_null("OpeningWorldStory")
	if opening_story!=null: opening_story.apply_state(state)
	if is_instance_valid(rescued_survivors):
		rescued_survivors.visible = "citadel.prisoners_freed" in state.campaign.facts
	if is_instance_valid(prison_bars):
		var freed: bool = "citadel.prisoners_freed" in state.campaign.facts
		preload("res://game/presentation/prison_cells.gd").set_open(prison_bars, freed)
		
		preload("res://game/localization/localizer.gd").set_text(prison_label, "PRISON\nE · Release after defeating jailer" if not freed else "PRISONERS FREED\nThe refuge is their home now")
		prison_survivors.visible = not freed
	if region_id == "region.ritual":
		seal.visible = not state.campaign.completed
		preload("res://game/localization/localizer.gd").set_text(seal_label, "THE CURSE IS BROKEN" if state.campaign.completed else ("CENTRAL ARTIFACT\nE · Break the curse" if "boss.maldrek" in state.campaign.boss_defeated_ids else "CENTRAL ARTIFACT\nDefeat Maldrek first"))
	if region_id == "region.peaks":
		var open: bool = "gate.peaks.shortcut.open" in state.campaign.facts
		peaks_shortcut.visible = not open
		peaks_shortcut.collision_layer = 0 if open else 1
		var unlocked: bool = Rules.gate_access("gate.peaks_to_citadel", state).allowed
		citadel_ward.visible = not unlocked
		citadel_ward.collision_layer = 0 if unlocked else 1
		preload("res://game/localization/localizer.gd").set_text(citadel_label, "ECLIPSE CITADEL\nE · Travel" if unlocked else "ECLIPSE CITADEL\nFour broken seals required")
	if region_id == "region.forge":
		var broken: bool = "seal.forge" in state.campaign.broken_seal_ids
		seal.visible = not broken
		preload("res://game/localization/localizer.gd").set_text(seal_label, "FORGE SEAL BROKEN" if broken else ("FORGE SEAL\nE · Break seal" if "boss.iron_warden" in state.campaign.boss_defeated_ids else "FORGE SEAL\nGuardian still lives"))
	if region_id == "region.order":
		var broken: bool = "seal.oath" in state.campaign.broken_seal_ids
		peaks_ward.visible = not broken
		peaks_ward.collision_layer = 0 if broken else 1
		preload("res://game/localization/localizer.gd").set_text(peaks_label, "ASHEN PEAKS\nE · Travel" if broken else "ASHEN PEAKS\nBreak Oath Seal first")
		var ground_material: Material = order_ground.get_child(0).material_override
		if ground_material is ShaderMaterial:
			ground_material.set_shader_parameter("curse_tint",Color("d0cbbb") if broken else Color("bfb0d5"))
		else:
			ground_material.albedo_color = Color("7c806e") if broken else Color("64665b")
	if region_id == "region.sanctum":
		var broken: bool = "seal.oath" in state.campaign.broken_seal_ids
		seal.visible = not broken
		preload("res://game/localization/localizer.gd").set_text(seal_label, "OATH SEAL BROKEN" if broken else ("OATH SEAL\nE · Break seal" if "boss.fallen_commander" in state.campaign.boss_defeated_ids else "OATH SEAL\nGuardian still lives"))
	if is_instance_valid(cael):
		var recruited: bool = "ally.cael" in state.campaign.recruited_ally_ids
		cael.visible = (recruited and state.campaign.active_companion_id != "ally.cael") if region_id == "region.refuge" else not recruited
	if is_instance_valid(expedition):
		expedition.visible = "document.order.expedition" not in state.campaign.pickup_claim_ids
	if is_instance_valid(refuge_echo):
		preload("res://game/localization/localizer.gd").set_text(refuge_echo, "THE ROOT WARD HAS FALLEN\nHope returns to Lantern Refuge" if "seal.root" in state.campaign.broken_seal_ids else "")
		if "seal.oath" in state.campaign.broken_seal_ids:
			preload("res://game/localization/localizer.gd").set_text(refuge_echo, "THE OATH WARD HAS FALLEN\nThe road to Ashen Peaks is open")
		if "seal.forge" in state.campaign.broken_seal_ids:
			preload("res://game/localization/localizer.gd").set_text(refuge_echo, "FOUR SEALS HAVE FALLEN\nThe Eclipse Citadel ward is broken")
		if state.campaign.completed:
			preload("res://game/localization/localizer.gd").set_text(refuge_echo, "DAWN OVER VEYR\nThe curse is broken · the roads are peaceful")
	var rescued: bool = "ally.oren" in state.campaign.recruited_ally_ids
	if is_instance_valid(oren):
		oren.visible = rescued if region_id == "region.refuge" else not rescued
	if is_instance_valid(lyra):
		var recruited: bool = "ally.lyra" in state.campaign.recruited_ally_ids
		lyra.visible = (recruited and state.campaign.active_companion_id != "ally.lyra") if region_id == "region.refuge" else not recruited
	if is_instance_valid(satchel):
		satchel.visible = "pickup.lyra_satchel" not in state.campaign.pickup_claim_ids
	if region_id == "region.village":
		preload("res://game/presentation/prison_cells.gd").set_open(captured_gate, rescued)
		
		token.visible = "pickup.family_token" not in state.campaign.pickup_claim_ids
		var open: bool = "gate.village.shortcut.open" in state.campaign.facts
		shortcut.visible = not open
		shortcut.collision_layer = 0 if open else 1
		var forest_open: bool = "seal.burial" in state.campaign.broken_seal_ids
		interact_colliders.forest.visible = not forest_open
		interact_colliders.forest.collision_layer = 0 if forest_open else 1
		preload("res://game/localization/localizer.gd").set_text(forest_label, "BLACKWOOD\nE · Enter forest" if forest_open else "BLACKWOOD WARD\nBreak Burial Seal first")
		var ground_material: Material = village_ground.get_child(0).material_override
		if ground_material is ShaderMaterial:
			ground_material.set_shader_parameter("curse_tint",Color("e1d3b8") if forest_open else Color("bfb0d5"))
		else:
			ground_material.albedo_color = Color("86817a") if forest_open else Color("666d76")
	if region_id == "region.crypt":
		var broken: bool = "seal.burial" in state.campaign.broken_seal_ids
		seal.visible = not broken
		preload("res://game/localization/localizer.gd").set_text(seal_label, "BURIAL SEAL BROKEN" if broken else ("BURIAL SEAL\nE · Break seal" if "boss.gravedigger" in state.campaign.boss_defeated_ids else "BURIAL SEAL\nGuardian still lives"))
	if region_id == "region.blackwood":
		var open: bool = "gate.blackwood.shortcut.open" in state.campaign.facts
		forest_shortcut.visible = not open
		forest_shortcut.collision_layer = 0 if open else 1
		var weakened: bool = "seal.root" in state.campaign.broken_seal_ids
		order_ward.visible = not weakened
		order_ward.collision_layer = 0 if weakened else 1
		preload("res://game/localization/localizer.gd").set_text(order_label, "ORDER'S RUINS\nE · Travel" if weakened else "ORDER'S RUINS\nBreak Root Seal first")
		var ground_material: Material = forest_ground.get_child(0).material_override
		if ground_material is ShaderMaterial:
			ground_material.set_shader_parameter("curse_tint",Color("c6c9a5") if weakened else Color("bfb0d5"))
		else:
			ground_material.albedo_color = Color("596047") if weakened else Color("3c5142")
	if region_id == "region.grove":
		var broken: bool = "seal.root" in state.campaign.broken_seal_ids
		seal.visible = not broken
		preload("res://game/localization/localizer.gd").set_text(seal_label, "ROOT SEAL BROKEN" if broken else ("ROOT SEAL\nE · Break seal" if "boss.thorn_beast" in state.campaign.boss_defeated_ids else "ROOT SEAL\nGuardian still lives"))

func build_crypt() -> void:
	points = {"spawn": Vector3(0, 0.1, 7), "checkpoint": Vector3(0, 0, 7), "crypt_exit": Vector3(0, 0, 8), "seal": Vector3(0, 0, -7)}
	box(Vector3(0, -0.5, 0), Vector3(20, 1, 20), Color("4a454c"))
	for x in [-10, 10]:
		box(Vector3(x, 2.5, 0), Vector3(1, 5, 20), Color("666271"))
	box(Vector3(0, 2.5, -10), Vector3(20, 5, 1), Color("666271"))
	for x in [-6, 6]:
		box(Vector3(x, 2.5, 10), Vector3(8, 5, 1), Color("666271"))
	entrance_barrier = box(Vector3(0, 1.75, 9.5), Vector3(4, 3.5, 0.5), Color("606d8a")) as StaticBody3D
	entrance_barrier.hide()
	entrance_barrier.collision_layer = 0
	lantern(Vector3(-7, 0, 6), "BURIAL CHAMBER")
	lantern(Vector3(7, 0, 6), "")
	label(Vector3(0, 3.5, 9), "VILLAGE\nE · Leave before battle / after victory", 0.003)
	seal = box(points.seal + Vector3(0, 0.9, 0), Vector3(0.8, 1.8, 0.8), Color("9882bd"), false)
	seal_label = label(points.seal + Vector3(0, 2.8, 0), "BURIAL SEAL", 0.004)

func build_blackwood() -> void:
	points = {"spawn": Vector3(0, 0.1, 10), "checkpoint": Vector3(0, 0, 10), "forest_exit": Vector3(0, 0, 13), "forest_end": Vector3(0, 0, -20), "lyra": Vector3(-5, 0, -5), "satchel": Vector3(7, 0, -18)}
	forest_ground = box(Vector3(0, -0.5, -28), Vector3(64, 1, 100), Color("3c5142"))
	for x in [-32, 32]:
		box(Vector3(x, 1.8, -28), Vector3(1, 3.6, 100), Color("394a40"))
	for z in [-78, 22]:
		box(Vector3(0, 1.8, z), Vector3(64, 3.6, 1), Color("394a40"))
	box(Vector3(0, 0.02, -3), Vector3(4, 0.04, 36), Color("77715a"), false)
	for x in [-8, -4, 5, 9]:
		for z in [-20, -11, -2, 7]:
			box(Vector3(x, 2, z), Vector3(0.7, 4, 0.7), Color("4b4037"))
			box(Vector3(x, 5, z), Vector3(3.5, 3, 3.5), Color("344b3c"), false)
	label(Vector3(0, 3, 13), "ASHEN VILLAGE\nE · Return", 0.004)
	label(Vector3(0, 3, -20), "EAST TO WATCHTOWER\nNorthwest to root shrine", 0.004)
	lyra = person(points.lyra, "LYRA · Scout\nE · Talk")
	box(Vector3(5, 0.7, -15), Vector3(5, 1.4, 1), Color("666b60"))
	box(Vector3(-6, 0.7, -12), Vector3(5, 1.4, 1), Color("666b60"))
	box(Vector3(10, 3, -20), Vector3(1, 6, 1), Color("777664"))
	satchel = box(points.satchel + Vector3(0, 0.3, 0), Vector3(0.7, 0.6, 0.5), Color("b4996a"), false)
	label(points.satchel + Vector3(0, 1.6, 0), "SCOUT SATCHEL\nE · Recover", 0.003)
	ForestLayout.extend_forest(self)
	build_navigation(Rect2(-32, -78, 64, 100), 1.0)

func build_navigation(bounds: Rect2 = Rect2(-40, -45, 80, 90), spacing: float = 2.0) -> void:
	# Fixed authored floor grid, not procedural world generation. Cells exclude
	# inflated building/wall footprints; geometry is never rebaked each frame.
	navigation = NavigationRegion3D.new()
	var mesh := NavigationMesh.new()
	var vertices := PackedVector3Array()
	var columns: int = int(bounds.size.x / spacing)
	var rows: int = int(bounds.size.y / spacing)
	for z in range(rows + 1):
		for x in range(columns + 1):
			var px: float = bounds.position.x + x * spacing
			var pz: float = bounds.position.y + z * spacing
			var height: float = ForestApproach.height_at(px,pz) if region_id == "region.refuge" else 0.0
			vertices.append(Vector3(px,height,pz))
	mesh.set_vertices(vertices)
	for z in range(rows):
		for x in range(columns):
			var cell := Rect2(bounds.position + Vector2(x, z) * spacing, Vector2.ONE * spacing)
			var blocked := false
			for obstacle in obstacles:
				if cell.intersects(obstacle):
					blocked = true
					break
			if not blocked:
				var index := z * (columns + 1) + x
				mesh.add_polygon(PackedInt32Array([index, index + columns + 1, index + columns + 2, index + 1]))
	navigation.navigation_mesh = mesh
	add_child(navigation)
