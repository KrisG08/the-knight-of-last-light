extends Node3D



const UiStyle = preload("res://game/presentation/ui_style.gd")
const Opening = preload("res://game/ui/opening_cinematic.gd")
const MobileControls = preload("res://game/presentation/mobile_controls.gd")
var mobile_controls: Control
var menu_input: Node
var opening: CanvasLayer
var graphics_profile: Dictionary={}
var fps_label: Label
var applied_fullscreen: Variant = null
var cloud_account: Node
var cloud_sync: Node
var account_panel: PanelContainer

const Region = preload("res://game/world/regions/graybox_region.gd")

const Knight = preload("res://game/actors/player/knight.gd")

const Enemy = preload("res://game/actors/enemies/training_soldier.gd")

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")

const Session = preload("res://game/campaign/application/campaign_session.gd")

const Store = preload("res://game/persistence/infrastructure/save_store.gd")

const Strike = preload("res://game/combat/runtime/strike_query.gd")

const Bindings = preload("res://game/core/input_bindings.gd")

const BurialEncounter = preload("res://game/world/runtime/burial_encounter.gd")

const Settings = preload("res://game/settings/game_settings.gd")

const SettingsPanel = preload("res://game/ui/settings/settings_panel.gd")

const Benchmark = preload("res://game/core/slice_benchmark.gd")

const CompanionJourney = preload("res://game/allies/runtime/companion_journey.gd")

const BlackwoodChapter = preload("res://game/world/runtime/blackwood_chapter.gd")

const OrderChapter = preload("res://game/world/runtime/order_chapter.gd")

const CommanderEncounter = preload("res://game/world/runtime/commander_encounter.gd")

const PeaksChapter = preload("res://game/world/runtime/peaks_chapter.gd")

const CitadelChapter = preload("res://game/world/runtime/citadel_chapter.gd")

var testing: bool = false

var session: RefCounted

var player: CharacterBody3D

var region: Node3D

var enemies: Array[CharacterBody3D] = []

var mill_guard: CharacterBody3D

var transitioning: bool = false

var started: bool = false

var hud: Label

var coach: Control
var target_indicator: Control
var hud_overlay: Control

var objective_label: Label

var region_caption: Label

var prompt_label: Label

var prompt_panel: PanelContainer

var notice_label: Label

var last_notice: String = ""

var notice_remaining: float = 0

var menu: PanelContainer

var menu_note: Label

var slots: OptionButton

var npc_conversation: Control
var dialogue: PanelContainer

var dialogue_text: Label

var choices: Container

var confirmation: ConfirmationDialog

var journal: bool = false

var burial: Node



var settings: RefCounted

var settings_panel: PanelContainer

var sun: DirectionalLight3D
var atmosphere: Environment

var ui_layer: CanvasLayer

var hud_panel: PanelContainer

var hp_bar: ProgressBar

var stamina_bar: ProgressBar

var transition_label: Label

var ui_sound: AudioStreamPlayer
var music: Node
var voice: Node

var load_button: Button

var retry_save_button: Button
var quit_button: Button
var resume_button: Button

var journal_button: Button

var benchmarking: bool = false

var journey: Node

var forest_chapter: Node

var order_chapter: Node

var commander: Node

var peaks_chapter: Node

var citadel_chapter: Node



func _ready() -> void:

	process_mode = Node.PROCESS_MODE_ALWAYS

	benchmarking = "--benchmark" in OS.get_cmdline_user_args()

	testing = testing or "--review" in OS.get_cmdline_user_args() or benchmarking

	get_window().title = "The Knight of Last Light - v" + str(ProjectSettings.get_setting("application/config/version")) + (" REVIEW" if testing else "")

	get_tree().auto_accept_quit = false
	get_tree().quit_on_go_back = false

	Bindings.setup()
	menu_input = preload("res://game/core/menu_input_pulses.gd").new()
	add_child(menu_input)

	settings = Settings.new("user://settings.cfg", testing)

	settings.load_settings()
	preload("res://game/localization/localizer.gd").set_locale(settings.values.language)

	settings.apply_audio()
	voice = preload("res://game/audio/narrative_voice.gd").new()
	add_child(voice)
	voice.setup(self)
	music = preload("res://game/audio/journey_music.gd").new()
	add_child(music)
	music.setup(self)

	session = Session.new(Store.new("user://campaign_saves", testing))

	session.state = Rules.new_game()
	cloud_account=preload("res://game/cloud/cloud_account.gd").new()
	cloud_account.enabled=not testing
	add_child(cloud_account)
	cloud_sync=preload("res://game/cloud/cloud_sync.gd").new()
	add_child(cloud_sync); cloud_sync.setup(self,cloud_account)

	build_lighting()

	player = Knight.new()

	player.debug_reset = false

	add_child(player)

	player.died.connect(func(): pause(true))

	player.reset_requested.connect(respawn)

	journey = CompanionJourney.new()

	add_child(journey)

	journey.setup(self)

	build_ui()
	if MobileControls.requested():
		preload("res://game/presentation/mobile_display.gd").apply()
		get_viewport().size_changed.connect(refresh_mobile_layout)
	if MobileControls.requested():
		var touch_layer := CanvasLayer.new()
		touch_layer.layer = 20
		add_child(touch_layer)
		mobile_controls = MobileControls.new()
		mobile_controls.game = self
		touch_layer.add_child(mobile_controls)
		notice_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
		notice_label.position = Vector2(get_viewport().get_visible_rect().size.x / 2 - 230, 80)
		notice_label.size = Vector2(460, 80)
		notice_label.custom_minimum_size.x = 460
		notice_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	get_viewport().size_changed.connect(apply_graphics)

	refresh_journey_picker()
	apply_settings()

	await transition("region.refuge")

	pause(true)

	if benchmarking and DisplayServer.get_name() != "headless":

		var benchmark := Benchmark.new()

		add_child(benchmark)

		benchmark.start(self)



func build_lighting() -> void:

	var world := WorldEnvironment.new()

	var environment := Environment.new()
	atmosphere = environment

	environment.background_mode = Environment.BG_SKY

	var sky_material := ShaderMaterial.new()
	sky_material.shader = preload("res://assets/materials/storm_sky.gdshader")
	sky_material.set_shader_parameter("moon_texture",load("res://assets/sky/curse-moon-v1.png"))
	sky_material.set_shader_parameter("cloud_panorama",load("res://assets/sky/storm-panorama-v1.png"))
	var sky := Sky.new()

	sky.sky_material = sky_material

	environment.sky = sky

	environment.fog_enabled = true

	environment.fog_light_color = Color("294e63")

	environment.fog_density = 0.012

	environment.fog_sky_affect = 0.8

	environment.background_color = Color("2b3741")

	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR

	environment.ambient_light_color = Color("89b1c6")

	environment.ambient_light_energy = 0.75

	world.environment = environment

	add_child(world)

	sun = DirectionalLight3D.new()

	sun.rotation_degrees = Vector3(-48, -30, 0)

	sun.light_color = Color("93adc7")

	sun.light_energy = 0.95

	sun.shadow_enabled = true

	add_child(sun)



func transition(id: String, arrival: String = "spawn") -> bool:
	if is_instance_valid(opening): return false

	if transitioning or id not in ["region.refuge", "region.village", "region.crypt", "region.blackwood", "region.grove", "region.order", "region.sanctum", "region.peaks", "region.forge", "region.citadel", "region.ritual"]:

		session.notice = "That region is unavailable; current area preserved"

		return false

	if id == "region.blackwood" and not Rules.gate_access("gate.village_to_blackwood", session.state).allowed:

		session.notice = "Blackwood remains warded. Break the Burial Seal first."

		return false

	if id == "region.order" and not Rules.gate_access("gate.blackwood_to_order", session.state).allowed:

		session.notice = "The Order passage is warded. Break the Root Seal first."

		return false

	if id == "region.sanctum" and "region.order.visited" not in session.state.campaign.facts:

		session.notice = "Discover the Order's Ruins before entering the sanctum"

		return false

	if id == "region.peaks" and not Rules.gate_access("gate.order_to_peaks", session.state).allowed:

		session.notice = "Break the Oath Seal before entering Ashen Peaks"

		return false

	if id == "region.forge" and "region.peaks.visited" not in session.state.campaign.facts:

		session.notice = "Discover Ashen Peaks before entering the forge fortress"

		return false

	if id == "region.citadel" and not Rules.gate_access("gate.peaks_to_citadel", session.state).allowed:

		session.notice = "All four regional seals must be broken before entering the citadel"

		return false

	if id == "region.ritual" and "region.citadel.visited" not in session.state.campaign.facts:

		session.notice = "Discover the citadel before entering the ritual chamber"

		return false

	if id == "region.grove" and "region.blackwood.visited" not in session.state.campaign.facts:

		session.notice = "Discover Blackwood before entering the root shrine"

		return false

	transitioning = true

	if is_instance_valid(transition_label):

		transition_label.show()

	player.enabled = false

	player.target = null

	if is_instance_valid(region):

		region.process_mode = Node.PROCESS_MODE_DISABLED

	var was_paused: bool = get_tree().paused

	get_tree().paused = false

	# Present honest passage feedback before synchronous geometry/navigation work.
	# Native draws are explicit so a hidden/minimized window cannot block the await.
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless": RenderingServer.force_draw(false)

	var staged := Region.new()

	staged.build(id)

	if not staged.points.has(arrival) or not staged.points.has("checkpoint"):

		staged.free()

		transitioning = false

		if is_instance_valid(region):

			region.process_mode = Node.PROCESS_MODE_PAUSABLE

		pause(was_paused)

		session.notice = "Missing arrival point; current area preserved"

		return false

	var parked_map: RID

	if is_instance_valid(region) and is_instance_valid(region.navigation):

		parked_map = NavigationServer3D.map_create()

		region.navigation.set_navigation_map(parked_map)

	add_child(staged)

	await get_tree().physics_frame

	await get_tree().physics_frame

	if is_instance_valid(staged.navigation):

		var map: RID = staged.navigation.get_navigation_map()

		# Flush region replacement before querying; transitions may start from paused menus.

		NavigationServer3D.map_force_update(map)

		var ready_nav := false

		for tick in range(120):

			if NavigationServer3D.region_get_iteration_id(staged.navigation.get_rid()) > 0 and NavigationServer3D.map_get_iteration_id(map) > 0:

				var nearest := NavigationServer3D.map_get_closest_point(map, staged.points.spawn)

				if nearest.distance_to(staged.points.spawn) < 2 and NavigationServer3D.map_get_closest_point_owner(map, staged.points.spawn) == staged.navigation.get_rid():

					ready_nav = true

					break

			await get_tree().physics_frame

		if not ready_nav:

			remove_child(staged)

			staged.queue_free()

			if is_instance_valid(region):

				region.process_mode = Node.PROCESS_MODE_PAUSABLE

				if is_instance_valid(region.navigation):

					region.navigation.set_navigation_map(get_world_3d().navigation_map)

			transitioning = false

			if parked_map.is_valid():

				NavigationServer3D.free_rid(parked_map)

			session.notice = "Navigation not ready; previous area preserved. Retry travel."

			pause(was_paused)

			return false

	if is_instance_valid(region):

		remove_child(region)

		region.queue_free()

	if parked_map.is_valid():

		NavigationServer3D.free_rid(parked_map)

	region = staged

	region.process_mode = Node.PROCESS_MODE_PAUSABLE

	enemies.clear()

	mill_guard = null

	burial = null

	forest_chapter = null

	order_chapter = null

	commander = null

	peaks_chapter = null

	citadel_chapter = null

	region.apply_state(session.state)

	sync_stats()

	player.reset_position()

	player.position = region.points[arrival]

	if arrival in ["crypt", "forest", "grove", "order_gate", "order_depth", "peaks_gate", "fortress", "citadel_gate", "citadel_depth"]:

		player.position += Vector3(0, 0.1, 3)

	player.combat.message = "The last camp is safe. Follow the old forest road north, past the chapel, to Ashen Village." if id == "region.refuge" else "East loop: mill and Oren. West loop: graveyard and lost token."

	if id == "region.village":

		spawn_enemies()

	elif id == "region.crypt":

		burial = BurialEncounter.new()

		region.add_child(burial)

		burial.setup(self)

		player.combat.message = "Step into the burial chamber. Watch the Gravedigger's shovel."

	elif id == "region.blackwood":

		session.act("VisitBlackwood")

		player.combat.message = "Scout trail south; follow the eastern watchtower road to the root shrine."

	elif id == "region.order":

		session.act("VisitOrder")

		player.combat.message = "Find Sir Cael west of the courtyard; the memorial hall lies beyond the barracks."

		order_chapter = OrderChapter.new()

		region.add_child(order_chapter)

		order_chapter.setup(self)

	elif id == "region.sanctum":

		commander = CommanderEncounter.new()

		region.add_child(commander)

		commander.setup(self)

		player.combat.message = "Your mentor's crosscut has two swings. Wait for the lowered sword before countering."

	elif id == "region.peaks":

		session.act("VisitPeaks")

		player.combat.message = "West: mine. North: guarded bridge and forge fortress. Activate the Peaks lantern."

	elif id == "region.citadel":

		session.act("VisitCitadel")

		player.combat.message = "West: prison. East: ritual inscription. North: Maldrek. Activate the citadel lantern."

	if session.state.campaign.completed:

		var peaceful := {"region.village":["mill.guards_cleared","ClearMill"], "region.blackwood":["forest.trail_safe","ClearForestTrail"], "region.order":["order.courtyard_safe","ClearOrderCourtyard"], "region.citadel":["citadel.prison_safe","ClearPrison"]}

		if peaceful.has(id) and peaceful[id][0] not in session.state.campaign.facts:

			session.act(peaceful[id][1])

	journey.region_ready()

	if id in ["region.citadel", "region.ritual"]:

		citadel_chapter = CitadelChapter.new()

		region.add_child(citadel_chapter)

		citadel_chapter.setup(self)

	if id in ["region.peaks", "region.forge"]:

		peaks_chapter = PeaksChapter.new()

		region.add_child(peaks_chapter)

		peaks_chapter.setup(self)

		if id == "region.forge":

			player.combat.message = "The raised hammer warns of a local slam. Move clear, then punish the recovery."

	if id in ["region.blackwood", "region.grove"]:

		forest_chapter = BlackwoodChapter.new()

		region.add_child(forest_chapter)

		forest_chapter.setup(self)

		if id == "region.grove":

			player.combat.message = "Watch the Thorn Beast's head: sidestep the lunge and punish its recovery."

	if session.active:

		session.visit(id)
		session.save_progress()

	transitioning = false

	transition_label.hide()

	apply_settings()

	pause(was_paused or not started)

	sun.light_color = Color("fff2d4") if session.state.campaign.completed else Color("93adc7")
	var woodland: bool = id == "region.refuge" and not session.state.campaign.completed
	atmosphere.fog_light_color = Color("344653") if woodland else Color("294e63")
	atmosphere.fog_density = 0.0035 if woodland else 0.012
	atmosphere.fog_sky_affect = 0.18 if woodland else 0.8
	atmosphere.ambient_light_color = Color("9bafc4") if woodland else Color("89b1c6")
	atmosphere.ambient_light_energy = 0.56 if woodland else 0.75
	sun.rotation_degrees = Vector3(-42,-38,0) if woodland else Vector3(-48,-30,0)
	atmosphere.sky.sky_material.set_shader_parameter("eclipse_amount",0.0 if id == "region.village" or session.state.campaign.completed else 1.0)
	atmosphere.sky.sky_material.set_shader_parameter("night_strength",1.0 if id == "region.village" and not session.state.campaign.completed else 0.0)
	if id == "region.village" and not session.state.campaign.completed:
		atmosphere.fog_light_color = Color("202c3c")
		atmosphere.fog_density = 0.004
		atmosphere.fog_sky_affect = 0.12
		atmosphere.ambient_light_color = Color("8d9bb4")
		atmosphere.ambient_light_energy = 0.38
		sun.light_color = Color("b6c9e3")
		sun.light_energy = 0.8
	else:
		sun.light_energy = 0.95
	if id == "region.crypt":
		atmosphere.ambient_light_energy = 0.32
		atmosphere.fog_light_color = Color("263443")
		atmosphere.fog_density = 0.006
		atmosphere.fog_sky_affect = 0.0
		sun.light_energy = 0.12
	if id in ["region.blackwood","region.grove"]:
		atmosphere.fog_light_color = Color("2c3940")
		atmosphere.fog_density = 0.0045 if id=="region.blackwood" else 0.006
		atmosphere.fog_sky_affect = 0.18
		atmosphere.ambient_light_color = Color("a6b6b5")
		atmosphere.ambient_light_energy = 0.7
		sun.light_energy = 0.85
	if id == "region.order":
		atmosphere.fog_light_color = Color("334353")
		atmosphere.fog_density = 0.004
		atmosphere.fog_sky_affect = 0.2
		atmosphere.ambient_light_energy = 0.5
		sun.light_energy = 0.9
	if id == "region.sanctum":
		atmosphere.ambient_light_energy = 0.38
		atmosphere.fog_light_color = Color("293b4b")
		atmosphere.fog_density = 0.004
		atmosphere.fog_sky_affect = 0
		sun.light_energy = 0.1
	if id == "region.peaks":
		atmosphere.fog_light_color = Color("3f4a5b")
		atmosphere.fog_density = 0.005
		atmosphere.fog_sky_affect = 0.25
		atmosphere.ambient_light_energy = 0.6
		sun.rotation_degrees = Vector3(-35,-30,0)
	if id == "region.forge":
		atmosphere.ambient_light_energy = 0.42
		atmosphere.fog_light_color = Color("3d3637")
		atmosphere.fog_density = 0.004
		atmosphere.fog_sky_affect = 0
		sun.light_energy = 0.08

	if id == "region.citadel":
		atmosphere.ambient_light_energy = 0.48
		atmosphere.fog_light_color = Color("3a364c")
		atmosphere.fog_density = 0.004
		atmosphere.fog_sky_affect = 0.25
		sun.light_energy = 0.65
	if id == "region.ritual":
		atmosphere.ambient_light_energy = 0.4
		atmosphere.fog_light_color = Color("302d42")
		atmosphere.fog_density = 0.004
		atmosphere.fog_sky_affect = 0
		sun.light_energy = 0.08
	# A shared horizon tint closes the distant terrain/sky seam. Closed rooms keep
	# their local fog; sky seen through openings uses that same atmospheric color.
	if not session.state.campaign.completed:
		atmosphere.fog_light_color=atmosphere.fog_light_color.lerp(Color("452b60"),0.32)
		atmosphere.ambient_light_color=atmosphere.ambient_light_color.lerp(Color("b59ad6"),0.16)
		atmosphere.fog_light_color = Color(atmosphere.fog_light_color.r*0.55,atmosphere.fog_light_color.g*0.55,atmosphere.fog_light_color.b*0.55)
	preload("res://game/presentation/region_look.gd").apply(atmosphere,sun,id,session.state.campaign.completed)
	atmosphere.sky.sky_material.set_shader_parameter("horizon_color",atmosphere.fog_light_color)
	preload("res://game/presentation/forest_horizon.gd").atmosphere(region,atmosphere.fog_light_color)
	atmosphere.fog_sky_affect = 0.0
	return true



func spawn_enemies() -> void:

	if session.state.campaign.completed:

		return

	var placements := [

		["hollow_villager", Vector3(20, 0.1, 24)],

		["grave_hound", Vector3(-23, 0.1, 0)],

		["fallen_soldier", Vector3(26, 0.1, -3)],

		["hollow_villager", Vector3(-25, 0.1, -24)],

		["fallen_soldier", Vector3(5, 0.1, -23)],

	]

	for placement in placements:

		var actor := Enemy.new()

		actor.player = player

		actor.profile = load("res://content/enemies/" + placement[0] + ".tres")

		actor.home = placement[1]

		actor.use_navigation = true

		region.add_child(actor)

		enemies.append(actor)

		if placement[1].x == 26:

			mill_guard = actor

		actor.defeated.connect(func(): enemy_defeated(actor))



func enemy_defeated(actor: CharacterBody3D) -> void:

	if not session.active:

		return

	if actor.get_meta("rewarded_life",-1) == actor.life_number: return
	actor.set_meta("rewarded_life",actor.life_number)
	session.record_enemy(preload("res://game/persistence/domain/journey_history.gd").enemy_id(region.region_id,actor),actor.display_name,region.region_id)
	if actor == mill_guard:

		session.act("ClearMill")

	# A defeated runtime actor emits once; repeat rewards require real respawn.

	session.state = session.state.duplicate(true)

	Rules.grant_xp(session.state.character, 15)

	session.state.character.shards += 8

	session.dirty = true

	session.revision += 1

	session.save_progress()

	sync_stats()



func summoned_enemy_defeated(actor: CharacterBody3D) -> void:
	if not session.active or actor.get_meta("rewarded_life",-1) == actor.life_number: return
	actor.set_meta("rewarded_life",actor.life_number)
	session.record_enemy(preload("res://game/persistence/domain/journey_history.gd").enemy_id(region.region_id,actor),actor.display_name,region.region_id)
	session.save_progress() # Summons retain their existing zero-XP/reward policy.

func sync_stats() -> void:

	var maximum := Rules.max_health(session.state)

	var gained: float = maxf(0, maximum - player.max_health)

	player.max_health = maximum

	player.health = minf(maximum, player.health + gained)

	player.weapon_damage = Rules.sword_damage(session.state)
	player.defense = 10 + preload("res://game/campaign/domain/relics.gd").bonus(session.state.character,"defense")
	player.flask_healing = 45 + preload("res://game/campaign/domain/relics.gd").bonus(session.state.character,"healing")

	if is_instance_valid(region):

		region.apply_state(session.state)

		refresh_world_hints()



func in_combat() -> bool:

	var encounter := current_encounter()

	if is_instance_valid(encounter) and encounter.active():

		return true

	for actor in enemies:

		if is_instance_valid(actor) and actor.health > 0 and actor.state != "idle":

			return true

	return false



func current_encounter() -> Node:

	if is_instance_valid(citadel_chapter) and is_instance_valid(citadel_chapter.actor):

		return citadel_chapter

	if is_instance_valid(peaks_chapter) and is_instance_valid(peaks_chapter.actor):

		return peaks_chapter

	if is_instance_valid(commander) and is_instance_valid(commander.actor):

		return commander

	if is_instance_valid(burial) and is_instance_valid(burial.actor):

		return burial

	if is_instance_valid(forest_chapter) and is_instance_valid(forest_chapter.actor):

		return forest_chapter

	return null



func focus() -> String:

	if not is_instance_valid(region) or transitioning or player.health <= 0:

		return ""

	var candidates: Array = []

	for key in region.points:

		if key == "spawn":

			continue

		if key == "checkpoint" and region.region_id in ["region.crypt", "region.grove", "region.sanctum", "region.forge", "region.ritual"]:

			continue

		if key == "artifact" and session.state.campaign.completed:

			continue

		if key == "forge_seal" and "seal.forge" in session.state.campaign.broken_seal_ids:

			continue

		if key == "peaks_shortcut" and "gate.peaks.shortcut.open" in session.state.campaign.facts:

			continue

		if key == "oath_seal" and "seal.oath" in session.state.campaign.broken_seal_ids:

			continue

		if key == "cael" and (not is_instance_valid(region.cael) or not region.cael.visible):

			continue

		if key == "seal" and "seal.burial" in session.state.campaign.broken_seal_ids:

			continue

		if key == "root_seal" and "seal.root" in session.state.campaign.broken_seal_ids:

			continue

		if key == "forest_shortcut" and "gate.blackwood.shortcut.open" in session.state.campaign.facts:

			continue

		if key == "oren" and not region.oren.visible:

			continue

		if key == "lyra" and (not is_instance_valid(region.lyra) or not region.lyra.visible):

			continue

		if key == "satchel" and not region.satchel.visible:

			continue

		if key == "token" and not region.token.visible:

			continue

		if key == "shortcut" and "gate.village.shortcut.open" in session.state.campaign.facts:

			continue

		var at: Vector3 = region.points[key]

		var distance := player.position.distance_to(at)

		if distance <= 3:

			var ray := PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP, at + Vector3.UP * 1.9, 1)

			if region.interact_colliders.has(key):

				ray.exclude = [region.interact_colliders[key].get_rid()]

			if get_world_3d().direct_space_state.intersect_ray(ray).is_empty():

				candidates.append([distance, key])

	if is_instance_valid(journey.follower) and journey.follower.visible:

		var ally_distance: float = player.global_position.distance_to(journey.follower.global_position)

		if ally_distance <= 3 and Strike.visible(player, journey.follower):

			candidates.append([ally_distance, "companion"])

	candidates.sort_custom(func(a, b): return a[0] < b[0])

	return candidates[0][1] if not candidates.is_empty() else ""



func interact() -> void:

	if transitioning or get_tree().paused or not session.active or not player.combat.can_act() or player.dodge_left > 0:

		return

	match focus():

		"checkpoint": rest()

		"travel":

			if in_combat():

				session.notice = "Lose your pursuers before travelling"

			else:

				if region.region_id == "region.refuge":
					transition("region.village")
				else:
					transition("region.refuge","travel")

		"oren": talk_to_oren()

		"lyra": journey.talk()

		"companion": journey.talk_recruited(journey.follower.ally_id)

		"cael":

			if "ally.cael" in session.state.campaign.recruited_ally_ids:

				journey.talk_recruited("ally.cael")

			else:

				order_chapter.talk()

		"expedition": order_chapter.read_record()

		"satchel":

			session.act("ClaimPickup", "pickup.lyra_satchel")

			sync_stats()

		"token":

			session.act("ClaimPickup", "pickup.family_token")

			sync_stats()

		"memorial":

			session.act("CompleteQuest", "quest.family_token")

			sync_stats()

		"shortcut":

			if player.position.z > 16:

				session.notice = "The bar can only be lifted from the village side"

			else:

				session.act("OpenShortcut")

				sync_stats()

		"crypt":

			if in_combat():

				session.notice = "Lose your pursuers before entering the crypt"

			else:

				transition("region.crypt")

		"crypt_exit":

			if in_combat():

				session.notice = "The arena ward holds until the Gravedigger falls"

			else:

				transition("region.village", "crypt")

		"seal": burial.break_seal()

		"forest":

			if in_combat():

				session.notice = "Lose your pursuers before entering Blackwood"

			else:

				transition("region.blackwood")

		"forest_exit": transition("region.village", "forest")

		"forest_end": session.notice = "Go east around the root ridge, past the watchtower, then west to the root shrine."

		"forest_shortcut":

			if player.position.z > -30.5:

				session.notice = "Lift the root bar from the northern side"

			else:

				session.act("OpenForestShortcut")

				sync_stats()

		"grove":

			if in_combat():

				session.notice = "Escape your pursuers before entering the grove"

			else:

				transition("region.grove")

		"grove_exit":

			if in_combat():

				session.notice = "The grove ward holds until the Thorn Beast falls"

			else:

				transition("region.blackwood", "grove")

		"root_seal": forest_chapter.break_seal()

		"order_gate":

			if in_combat():

				session.notice = "Lose your pursuers before entering the Order's Ruins"

			else:

				transition("region.order")

		"order_exit":

			if in_combat():

				session.notice = "Lose your pursuers before returning to Blackwood"

			else:

				transition("region.blackwood", "order_gate")

		"order_depth":

			if in_combat():

				session.notice = "Escape your pursuers before entering the sanctum"

			else:

				transition("region.sanctum")

		"sanctum_exit":

			if in_combat():

				session.notice = "The sanctum ward holds until the Commander falls"

			else:

				transition("region.order", "order_depth")

		"oath_seal": commander.break_seal()

		"peaks_gate":

			if in_combat():

				session.notice = "Escape your pursuers before travelling to the peaks"

			else:

				transition("region.peaks")

		"peaks_exit":

			if in_combat():

				session.notice = "Lose your pursuers before returning to Order ruins"

			else:

				transition("region.order", "peaks_gate")

		"mine":

			if in_combat():

				session.notice = "Finish the encounter before reading"

			else:

				open_dialogue("ABANDONED MINE\nThe ore carts stand empty. The Warden sealed the forge when the kingdom fell. A service path east of the fortress leads back to the bridge; lift its bar from the north.")

				button(choices, "Leave inscription", leave_dialogue)

		"bridge": session.notice = "Cross inside the rails. The gorge is real; a fall returns you to your last lantern."

		"peaks_shortcut":

			if player.position.z > -36.5:

				session.notice = "Lift the service bar from the fortress side"

			else:

				session.act("OpenPeaksShortcut")

				sync_stats()

		"fortress":

			if in_combat():

				session.notice = "Escape your pursuers before entering the forge"

			else:

				transition("region.forge")

		"forge_exit":

			if in_combat():

				session.notice = "The forge ward holds until Iron Warden falls"

			else:

				transition("region.peaks", "fortress")

		"forge_seal": peaks_chapter.break_seal()

		"citadel_gate":

			if in_combat():

				session.notice = "Lose your pursuers before entering the citadel"

			else:

				transition("region.citadel")

		"citadel_exit":

			if in_combat():

				session.notice = "Escape your pursuers before returning to Peaks"

			else:

				transition("region.peaks", "citadel_gate")

		"citadel_depth":

			if in_combat():

				session.notice = "Escape your pursuers before entering the ritual chamber"

			else:

				transition("region.ritual")

		"ritual_exit":

			if in_combat():

				session.notice = "Maldrek's ward holds until he falls"

			else:

				transition("region.citadel", "citadel_depth")

		"artifact": citadel_chapter.artifact()

		"ritual_lore": citadel_chapter.read_lore()

		"prisoners":

			if in_combat():

				session.notice = "Finish the encounter before freeing prisoners"

			else:

				session.act("FreePrisoners")

				sync_stats()



func rest() -> bool:

	if region.region_id not in ["region.refuge", "region.village", "region.blackwood", "region.order", "region.peaks", "region.citadel"] or in_combat() or player.health <= 0:

		session.notice = "Cannot rest during combat"

		return false

	session.act("ActivateCheckpoint", "checkpoint." + region.region_id.trim_prefix("region."))

	for actor in enemies:

		actor.reset_encounter()

	player.reset_position()

	player.position = region.points.checkpoint + Vector3(-2, 0.1, 0)

	journey.recover_at_checkpoint()

	player.sounds.cue("rest")
	if is_instance_valid(coach): coach.mark("rest")

	return true



func respawn() -> void:

	if not session.active:

		return

	if not await transition(session.state.recovery.region_id):

		pause(true)

		return

	player.position = region.points.checkpoint + Vector3(-2, 0.1, 0)

	pause(false)



func pause(open: bool) -> void:
	if is_instance_valid(opening):
		return

	if is_instance_valid(settings_panel):

		settings_panel.hide()

	if not transitioning and is_instance_valid(transition_label):

		transition_label.hide()

	menu.visible = open

	dialogue.hide()

	hud.visible = not open

	hud_panel.visible = not open

	hud_overlay.visible = not open

	get_tree().paused = open

	player.enabled = not open and not transitioning

	player.combat.clear_buffer()

	player.input_grace_ticks = 2

	player.discard_mouse_events = 2

	if is_instance_valid(mobile_controls):
		mobile_controls.release_all()
	if is_instance_valid(menu_input): menu_input.cancel()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if open or MobileControls.requested() else Input.MOUSE_MODE_CAPTURED

	if open and is_instance_valid(load_button):

		refresh_slot_buttons()



func start_selected(load_existing: bool = false) -> void:

	if transitioning or is_instance_valid(opening):

		return

	var slot := slots.get_selected_id()

	if session.dirty and not session.save_progress():

		return

	if load_existing:

		var candidate: Dictionary = session.store.load_slot(slot)

		if not candidate.ok:

			session.notice = candidate.message

			return

		if candidate.state.recovery.region_id not in ["region.refuge", "region.village", "region.blackwood", "region.order", "region.peaks", "region.citadel"]:

			session.notice = "This save belongs to another prototype; preserved"

			return

		if not session.load_slot(slot):

			return

	else:

		if not session.store.memory_only:

			var previous: Dictionary = session.store.read_file(session.store.path_for(slot), slot)

			if previous.message.begins_with("Unsupported"):

				session.notice = previous.message

				return

		session.begin(slot, false)

	refresh_journey_picker(session.state.slot_id)
	started = true

	var load_notice: String = session.notice

	if not await transition(session.state.recovery.region_id):

		pause(true)

		return

	if load_notice.begins_with("Recovered"):

		session.notice = load_notice

	player.position = region.points.checkpoint + Vector3(-2, 0.1, 0)

	if not load_existing and not testing:
		pause(true)
		menu.hide()
		# Decode the film without drawing the paused 3D world behind its opaque UI.
		region.hide()
		player.hide()
		opening = Opening.new()
		opening.voice = voice
		add_child(opening)
		await opening.finished
		opening = null
		region.show()
		player.show()
	pause(DisplayServer.get_name() != "headless" and not testing and not DisplayServer.window_is_focused())



func button(parent: Node, text: String, callback: Callable) -> Button:

	var item := Button.new()

	preload("res://game/localization/localizer.gd").set_text(item, text)

	item.pressed.connect(callback)

	item.pressed.connect(func():

		if is_instance_valid(ui_sound):

			ui_sound.play())

	parent.add_child(item)
	UiStyle.apply_button(item)

	return item



func panel(layer: CanvasLayer, size: Vector2) -> PanelContainer:

	var result := PanelContainer.new()

	result.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	result.position = -size / 2

	result.custom_minimum_size = size

	var style := UiStyle.frame(Color(0.025,0.055,0.08,0.95),Color("b46bdf"),24)

	result.add_theme_stylebox_override("panel", style)

	layer.add_child(result)

	return result



func side_to_margin(side: String) -> int:

	return {"left": SIDE_LEFT, "right": SIDE_RIGHT, "top": SIDE_TOP, "bottom": SIDE_BOTTOM}[side]



func build_ui() -> void:

	var layer := CanvasLayer.new()

	ui_layer = layer

	add_child(layer)

	ui_sound = AudioStreamPlayer.new()

	ui_sound.bus = "UI"

	ui_sound.volume_db = -20

	ui_sound.stream = player.sounds.cues["heal"]

	add_child(ui_sound)

	hud_panel = PanelContainer.new()

	hud_panel.position = Vector2(20, 18)

	hud_panel.custom_minimum_size = Vector2(340, 135)

	var backing := UiStyle.frame(Color(0.02,0.045,0.065,0.92),Color("ad69d4"),14)

	hud_panel.add_theme_stylebox_override("panel", backing)

	layer.add_child(hud_panel)

	var hud_body := VBoxContainer.new()

	hud_body.add_theme_constant_override("separation", 5)

	hud_panel.add_child(hud_body)

	hud = Label.new()

	hud.custom_minimum_size.x = 310

	hud.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	hud.add_theme_color_override("font_color", Color("fff1d5"))

	hud_body.add_child(hud)

	hp_bar = preload("res://game/ui/resource_bar.gd").new()

	hp_bar.custom_minimum_size = Vector2(300, 38)

	hp_bar.show_percentage = false

	var health_fill := StyleBoxFlat.new()

	health_fill.bg_color = Color("a43b48")

	hp_bar.add_theme_stylebox_override("fill", health_fill)

	hud_body.add_child(hp_bar)

	stamina_bar = preload("res://game/ui/resource_bar.gd").new()
	stamina_bar.set("caption","STAMINA")
	stamina_bar.set("tint",Color("66bfaa"))

	stamina_bar.custom_minimum_size = Vector2(300, 38)

	stamina_bar.show_percentage = false

	var stamina_fill := StyleBoxFlat.new()

	stamina_fill.bg_color = Color("65b8b3")

	stamina_bar.add_theme_stylebox_override("fill", stamina_fill)

	hud_body.add_child(stamina_bar)

	hud_body.move_child(hud,2)

	hud_overlay = Control.new()

	hud_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	coach = preload("res://game/ui/journey_coach.gd").new()
	hud_overlay.add_child(coach)
	coach.setup(self)
	target_indicator = preload("res://game/ui/target_indicator.gd").new()
	hud_overlay.add_child(target_indicator)
	target_indicator.setup(self)

	hud_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	layer.add_child(hud_overlay)

	region_caption = Label.new()

	region_caption.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)

	region_caption.offset_left = -230

	region_caption.offset_right = 230

	region_caption.offset_top = 26

	region_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	region_caption.add_theme_font_size_override("font_size",20)

	region_caption.add_theme_color_override("font_color",Color("bccfce"))
	region_caption.add_theme_stylebox_override("normal",UiStyle.frame(Color("151e29"),Color("ad69d4"),8))

	hud_overlay.add_child(region_caption)
	fps_label=Label.new()
	fps_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	fps_label.offset_left=-130; fps_label.offset_right=130; fps_label.offset_top=-36; fps_label.offset_bottom=-12
	fps_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	fps_label.add_theme_font_size_override("font_size",16)
	fps_label.add_theme_color_override("font_color",Color("c4a0ff"))
	fps_label.hide(); hud_overlay.add_child(fps_label)

	objective_label = Label.new()

	objective_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)

	objective_label.position = Vector2(-325,92)

	objective_label.custom_minimum_size.x = 295

	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	objective_label.add_theme_color_override("font_color",Color("d5d1bd"))
	objective_label.add_theme_stylebox_override("normal",UiStyle.frame(Color(0.02,0.04,0.06,0.88),Color("ad69d4"),14))

	hud_overlay.add_child(objective_label)

	prompt_panel = PanelContainer.new()

	prompt_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)

	prompt_panel.offset_left = -280

	prompt_panel.offset_right = 280

	prompt_panel.offset_top = -80

	prompt_panel.offset_bottom = -30

	prompt_panel.add_theme_stylebox_override("panel",UiStyle.frame(Color(0.02,0.04,0.06,0.9),Color("6b8d91"),12))

	hud_overlay.add_child(prompt_panel)

	prompt_label = Label.new()

	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	prompt_panel.add_child(prompt_label)

	notice_label = Label.new()

	notice_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)

	notice_label.offset_left = 24
	notice_label.offset_top = -150
	notice_label.offset_right = 444
	notice_label.offset_bottom = -20
	notice_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

	notice_label.custom_minimum_size.x = 400

	notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	hud_overlay.add_child(notice_label)

	transition_label = Label.new()

	transition_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

	transition_label.position = Vector2(-180, -30)

	preload("res://game/localization/localizer.gd").set_text(transition_label, "Preparing passage…")
	transition_label.add_theme_stylebox_override("normal",UiStyle.frame(Color("151e29"),Color("d782ff"),18))

	layer.add_child(transition_label)

	transition_label.hide()

	menu = preload("res://game/ui/mobile_frontend.gd").new()
	layer.add_child(menu)
	menu.setup(self)

	confirmation = ConfirmationDialog.new()
	confirmation.theme = UiStyle.theme(1.0)

	confirmation.title = "Replace selected campaign slot?"

	confirmation.dialog_text = "Only the selected campaign slot will be replaced. Training saves are separate."

	confirmation.confirmed.connect(func(): start_selected())
	if MobileControls.requested():
		confirmation.min_size = Vector2i(640,250)
		confirmation.theme = UiStyle.theme(1.0)
		confirmation.get_ok_button().custom_minimum_size.y = 60
		confirmation.get_cancel_button().custom_minimum_size.y = 60

	layer.add_child(confirmation)

	dialogue = panel(layer, Vector2(760, 560))

	var dialogue_scroll := ScrollContainer.new()

	dialogue_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED

	dialogue.add_child(dialogue_scroll)

	var body := VBoxContainer.new()

	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	body.add_theme_constant_override("separation", 14)

	dialogue_scroll.add_child(body)

	dialogue_text = Label.new()

	dialogue_text.custom_minimum_size.x = 652

	dialogue_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	body.add_child(dialogue_text)

	npc_conversation = preload("res://game/ui/npc_conversation.gd").new()
	layer.add_child(npc_conversation)
	npc_conversation.setup(self)
	choices = VBoxContainer.new()

	body.add_child(choices)

	dialogue.hide()

	settings_panel = SettingsPanel.new()

	layer.add_child(settings_panel)

	settings_panel.setup(settings)

	settings_panel.applied.connect(apply_settings)
	account_panel=preload("res://game/ui/account_panel.gd").new()
	layer.add_child(account_panel); account_panel.setup(self)
	account_panel.closed.connect(func(): menu.show(); menu.show_actions(false))

	settings_panel.closed.connect(func():

		if settings.notice.contains("could not"):

			session.notice = settings.notice

		pause(true))



func show_account() -> void:
	if session.active:
		open_dialogue("Save and return to the menu before switching accounts.")
		return
	pause(true); menu.show(); account_panel.refresh(); account_panel.show()

func show_settings() -> void:

	pause(true)

	menu.show()

	settings_panel.rebuild()

	settings_panel.show()



func set_language(code: String) -> void:
	if not settings.set_value("language",code): return
	settings.save_settings()
	preload("res://game/localization/localizer.gd").set_locale(code)
	apply_settings()
	if is_instance_valid(settings_panel): settings_panel.rebuild()

func apply_settings() -> void:
	if preload("res://game/localization/localizer.gd").language!=settings.values.language:
		preload("res://game/localization/localizer.gd").set_locale(settings.values.language)
		settings.save_settings()
		if is_instance_valid(settings_panel): settings_panel.rebuild.call_deferred()
	# Region changes refresh gameplay settings, but must preserve a player's
	# native maximized/fullscreen window unless the display preference changed.
	var display_changed: bool = applied_fullscreen != settings.values.fullscreen
	applied_fullscreen = settings.values.fullscreen

	settings.apply_audio()

	player.sensitivity = settings.values.sensitivity

	player.invert_y = settings.values.invert_y

	player.incoming_damage = settings.values.incoming_damage

	apply_graphics()
	Engine.max_fps=settings.values.frame_limit
	if DisplayServer.get_name()!="headless": DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)

	for actor in enemies:

		if is_instance_valid(actor):

			actor.attack_tempo = settings.values.enemy_tempo

	var encounter := current_encounter()

	if is_instance_valid(encounter):

		encounter.actor.attack_tempo = settings.values.enemy_tempo

	var font := UiStyle.theme(settings.values.ui_scale)

	for control in [hud_panel, hud_overlay, menu, dialogue, settings_panel,account_panel]:

		if is_instance_valid(control):

			control.theme = font

	if is_instance_valid(settings_panel):

		var width: float = 880 if settings.values.ui_scale > 1.25 else 700

		settings_panel.custom_minimum_size.x = width

		settings_panel.offset_left = -width / 2

		settings_panel.offset_right = width / 2

	if is_instance_valid(journal_button):

		preload("res://game/localization/localizer.gd").set_text(journal_button, "Journal / routes" if MobileControls.requested() else "Journal  [%s]" % settings.hint("journal"))

	refresh_world_hints()

	if MobileControls.requested():
		preload("res://game/presentation/mobile_display.gd").apply()
		refresh_mobile_layout()
	elif display_changed and not testing and DisplayServer.get_name() != "headless":

		var desired: int = DisplayServer.WINDOW_MODE_FULLSCREEN if settings.values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED

		if DisplayServer.window_get_mode() != desired:

			DisplayServer.window_set_mode(desired)



func apply_graphics() -> void:
	if settings==null or not is_instance_valid(sun): return
	var policy=preload("res://game/presentation/graphics_profile.gd")
	var pixels:=Vector2i(get_viewport().get_texture().get_size())
	var next: Dictionary=policy.resolve(settings.values.graphics_quality,MobileControls.requested(),pixels,settings.values.render_resolution,settings.values.frame_limit)
	if graphics_profile==next: return
	policy.apply(get_viewport(),sun,next,graphics_profile)
	graphics_profile=next

func refresh_mobile_layout() -> void:
	if not MobileControls.requested() or not is_instance_valid(dialogue): return
	var extent := get_viewport().get_visible_rect().size
	var safe: Vector4 = preload("res://game/presentation/mobile_display.gd").safe_margins(extent)
	fps_label.offset_top=-safe.w-30; fps_label.offset_bottom=-safe.w-8
	for item in [dialogue,settings_panel]:
		item.custom_minimum_size = Vector2.ZERO
		item.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		item.offset_left = safe.x + 12
		item.offset_top = safe.y + 12
		item.offset_right = -safe.z - 12
		item.offset_bottom = -safe.w - 12
	hud_panel.position = Vector2(safe.x,safe.y)
	objective_label.position = Vector2(extent.x-safe.z-295,safe.y+58)
	notice_label.position = Vector2(extent.x/2-230,safe.y+48)

func refresh_world_hints() -> void:

	if not is_instance_valid(region) or settings == null:

		return

	var hint: String = settings.hint("interact")

	for label in region.find_children("*", "Label3D", true, false):

		var previous: String = label.get_meta("interact_hint", "E")

		preload("res://game/localization/localizer.gd").set_text(label, preload("res://game/localization/localizer.gd").source(label).replace(previous + " ·", hint + " ·").replace("E ·", hint + " ·"))

		label.set_meta("interact_hint", hint)



func refresh_slot_buttons() -> void:

	load_button.disabled = not session.store.load_slot(slots.get_selected_id()).ok

	resume_button.disabled = not session.active



func control_help() -> String:
	if MobileControls.requested():
		return "Left stick: move; push fully to sprint. Drag empty space on the right to look.\nSword: tap for light; hold for heavy. Shield: hold to guard.\nCurved arrow: tap to dodge; swipe up to jump.\nDiamond: interact nearby or drink a flask away from objects.\nTap an enemy to focus; tap again or drag to release. Attacks can focus automatically.\nPause opens the journal, map, equipment and companion orders."

	return "%s / %s Move · mouse Look · %s / %s Attack\n%s Block · %s Dodge · %s Jump · %s Heal\n%s Lock · %s Interact · %s Journal · %s Pause\n%s Companion follow / hold" % [settings.hint("move_forward"), settings.hint("move_left"), settings.hint("light_attack"), settings.hint("heavy_attack"), settings.hint("block"), settings.hint("dodge"), settings.hint("jump"), settings.hint("heal"), settings.hint("target_lock"), settings.hint("interact"), settings.hint("journal"), settings.hint("pause"), settings.hint("companion_order")]



func show_credits() -> void:

	open_dialogue("THE KNIGHT OF LAST LIGHT\nCampaign development build · Godot 4.7.2\n\nOriginal gameplay/ruin kit and weapon effects. Footfalls: Kenney (CC0). Environment scans: Poly Haven (CC0). Character geometry: generated with Meshy (https://www.meshy.ai/), Meshy 6 Lite, CC BY 4.0; original reference images, simplified geometry, procedural materials and limb adapters. Knight equipment: Andy Woodhead, via afk.ai (CC BY 4.0).\nAmbient dragon: chengzijieczj; crystal deer: Coffeek; shadow hound base: Alexei Ostapenko (CC BY 4.0 via afk.ai), adapted as passive scenery.\nHostile armor: DJMaesen. Cursed canine base: Alexei Ostapenko. Static samples via afk.ai, CC BY 4.0; adapted geometry/materials and procedural motion.\nFonts: El Messiri, Cinzel, Source Sans 3, Barlow Semi Condensed, Noto Serif and Noto Naskh Arabic, SIL OFL 1.1.\nGodot Engine: MIT license. Engine third-party and font notices accompany the build.\n\nIncludes refuge, village, Oren, optional token quest, Gravedigger, Blackwood, Lyra, Thorn Beast, Order barracks, Sir Cael, Fallen Commander, Ashen Peaks, Iron Warden, citadel exploration, Maldrek, explicit ending and peaceful postgame. Art and full human campaign acceptance remain in development.\nPowered by Poly Haven. Asset source links, licenses and modifications are in the bundled asset credits. Gamepad and final animation polish remain in development.")

	button(choices, "Font licenses", show_font_licenses)
	button(choices, "Back", func(): pause(true))

func show_font_licenses() -> void:
	var l=preload("res://game/localization/localizer.gd")
	var parts: PackedStringArray=[l.text("Original font license texts"),l.text("These legal texts are displayed in their original language.")]
	for font_name in ["ElMessiri","Cinzel","SourceSans3","Barlow","NotoSerif","NotoNaskhArabic"]:
		parts.append(font_name+"\n"+FileAccess.get_file_as_string("res://assets/fonts/"+font_name+"-OFL.txt"))
	open_dialogue("\n\n".join(parts),false)
	button(choices,"Back to credits",show_credits)

func refresh_journey_picker(preferred: int = -1) -> void:
	var previous: int = preferred if preferred > 0 else slots.get_selected_id()
	slots.clear()
	for entry in session.store.catalog():
		var caption := "Journey %d" % entry.id
		if entry.ok: caption += " · Rank %d · %d/5 bosses" % [entry.state.character.rank,entry.state.campaign.boss_defeated_ids.size()]
		else: caption += " · recovery needed"
		preload("res://game/localization/localizer.gd").add_item(slots,caption,entry.id)
	if slots.item_count == 0: preload("res://game/localization/localizer.gd").add_item(slots,"No saved journeys yet",1)
	var index := slots.get_item_index(previous)
	slots.select(index if index >= 0 else slots.item_count-1)
	refresh_slot_buttons()

func request_new() -> void:
	if transitioning or is_instance_valid(opening): return
	if session.dirty and not session.save_progress(): return
	var id: int = session.store.next_journey_id()
	if id < 1:
		session.notice = "Journey storage limit reached; existing saves preserved"
		return
	preload("res://game/localization/localizer.gd").add_item(slots,"New journey %d" % id,id)
	slots.select(slots.item_count-1)
	start_selected()

func show_journey_progress() -> void:
	var snapshot: Dictionary
	if session.active: snapshot = session.state.duplicate(true)
	else:
		var loaded: Dictionary = session.store.load_slot(slots.get_selected_id())
		if not loaded.ok:
			session.notice = loaded.message
			return
		snapshot = loaded.state.duplicate(true)
	preload("res://game/persistence/domain/journey_history.gd").ensure(snapshot)
	open_dialogue(preload("res://game/persistence/domain/journey_history.gd").describe(snapshot))
	button(choices,"Back to menu",func(): pause(true))

func show_saved_journeys() -> void:
	open_dialogue("SAVED JOURNEYS\nEach new journey has its own save. Switching first saves your current progress.")
	for entry in session.store.catalog():
		var id: int = entry.id
		var caption := "Journey %d · %s" % [id,preload("res://game/persistence/domain/journey_history.gd").summary(entry.state) if entry.ok else entry.message]
		var item := button(choices,caption,func():
			refresh_journey_picker(id)
			start_selected(true))
		item.disabled = not entry.ok
	button(choices,"Begin another journey",request_new)
	button(choices,"Back to menu",func(): pause(true))

func clear_choices() -> void:

	for item in choices.get_children():

		choices.remove_child(item)

		item.queue_free()



func open_dialogue(text: String, translate_value: bool=true) -> void:

	pause(true)

	menu.visible=not session.active

	dialogue.show()

	preload("res://game/localization/localizer.gd").set_text(dialogue_text, text,translate_value)

	clear_choices()

	npc_conversation.present(text)
	if not npc_conversation.speaker.is_empty() and is_instance_valid(coach): coach.mark("interact")
	var scroll := dialogue.get_child(0) as ScrollContainer

	scroll.set_deferred("scroll_vertical",0)



func leave_dialogue() -> void:

	dialogue.hide()

	pause(false if session.active and player.health > 0 else true)



func talk_to_oren() -> void:

	if in_combat():

		session.notice = "Defeat or escape nearby enemies before talking"

		return

	if region.region_id == "region.village":

		open_dialogue("OREN\nThe things in the churchyard were our neighbors. Something below the graves keeps calling them back.\n\nPlease free me. I can work again if the chapel still stands.")

		button(choices, "Free Oren", func(): session.act("RescueOren"); sync_stats(); leave_dialogue())

		button(choices, "Ask about the crypt", func(): preload("res://game/localization/localizer.gd").set_text(dialogue_text, "OREN\nA gravedigger guards the seal beneath the burial yard. Defeating him will not be enough: the seal itself must be broken."))

	else:

		open_dialogue("OREN · Refuge forge\nYou came back. My tools are rough, but this sword can still hold an edge.\n\nSword tier %d · shards %d\nUpgrade costs 60 / 120 shards." % [session.state.character.weapon_tier, session.state.character.shards])

		button(choices, "Improve equipped sword", func(): session.act("UpgradeWeapon"); sync_stats(); preload("res://game/localization/localizer.gd").set_text(dialogue_text, "OREN\n" + session.notice + "\nSword damage %d · shards %d" % [player.weapon_damage, session.state.character.shards]))

		button(choices, "Ask about the village", func(): preload("res://game/localization/localizer.gd").set_text(dialogue_text, "OREN\nThe forge is warm again. Find the burial yard north of the square. The forest ward will hold until the Burial Seal is broken."))

	button(choices, "Leave", leave_dialogue)



func show_equipment() -> void:
	preload("res://game/ui/equipment_panel.gd").open(self)

func show_world_map() -> void:
	open_dialogue("World map\n" + objective())
	var detail := Label.new()
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preload("res://game/localization/localizer.gd").set_text(detail, "White: you · Gold: lantern · Violet: next landmark. Select a marker for its name.")
	var map := preload("res://game/ui/world_map.gd").new()
	map.name = "WorldMap"
	choices.add_child(map)
	choices.add_child(detail)
	map.setup(self, detail)
	button(choices, "Lantern travel / activated routes", show_lantern_map)
	button(choices, "Back to journal", show_journal)
	button(choices, "Close", leave_dialogue)

func show_journal() -> void:


	open_dialogue(preload("res://game/ui/journal_content.gd").render(session.state,region.region_id,objective()))

	button(choices, "Back", leave_dialogue)
	button(choices, "World map", show_world_map)
	button(choices, "Equipment", show_equipment)

	button(choices, "Lantern travel / activated routes", show_lantern_map)
	button(choices,"Controls",func():
		open_dialogue(control_help())
		button(choices,"Replay tutorial hints",func(): coach.replay(); leave_dialogue())
		button(choices,"Skip tutorial hints",func(): coach.skip(); leave_dialogue())
		button(choices,"Back to journal",show_journal))

	if "ally.lyra" in session.state.campaign.recruited_ally_ids:

		button(choices, "Lyra: follow / wait at refuge", func(): journey.select(session.state.campaign.active_companion_id != "ally.lyra"); leave_dialogue())

	if "ally.cael" in session.state.campaign.recruited_ally_ids:

		button(choices, "Sir Cael: follow / wait at refuge", func(): journey.choose("ally.cael" if session.state.campaign.active_companion_id != "ally.cael" else ""); leave_dialogue())

	if "document.order.expedition" in session.state.campaign.pickup_claim_ids:

		button(choices, "Read recovered expedition record", func():

			preload("res://game/localization/localizer.gd").set_text(dialogue_text, "EXPEDITION RECORD\nCael left to seek aid while the wounded sheltered in the memorial hall. The Commander held the ward. The dead were people he tried to save."))





func lantern_travel_ready() -> bool:

	if not session.active or transitioning or player.health <= 0 or in_combat() or not is_instance_valid(region) or not player.combat.can_act() or player.dodge_left > 0:

		return false

	var checkpoint: String = "checkpoint." + region.region_id.trim_prefix("region.")

	return Rules.lantern_destination(session.state,checkpoint).allowed and player.position.distance_to(region.points.checkpoint) <= 3



func show_lantern_map() -> void:

	if not lantern_travel_ready():

		open_dialogue("LANTERN ROUTES\nStand beside an activated lantern outside combat to travel. Only lanterns you have already activated can be destinations. Your discovered roads remain open for walking.")

		button(choices,"Back to journal",show_journal)

		button(choices,"Close",leave_dialogue)

		return

	open_dialogue("LANTERN ROUTES\nChoose an activated lantern. Travel restores you and your selected companion; ordinary encounters reset. Your recovery moves to the destination.\n\nCompleted journeys always reload at the restored refuge.")

	for checkpoint in session.state.campaign.checkpoint_ids:

		var destination := Rules.lantern_destination(session.state,checkpoint)

		if destination.allowed and destination.region != region.region_id:

			button(choices,"Travel to " + destination.name,func(): travel_to_lantern(checkpoint))

	button(choices,"Close",leave_dialogue)



func travel_to_lantern(checkpoint: String) -> bool:

	var destination := Rules.lantern_destination(session.state,checkpoint)

	if not lantern_travel_ready() or not destination.allowed:

		session.notice = "Stand beside an activated lantern outside combat and choose a known destination"

		return false

	if not await transition(destination.region):

		return false

	player.position = region.points.checkpoint + Vector3(-2,0.1,0)

	session.act("ActivateCheckpoint",checkpoint)

	journey.recover_at_checkpoint()

	pause(false)

	return true



func save_and_return_to_menu() -> bool:
	if transitioning or is_instance_valid(opening): return false
	if not session.active: return true
	# Keep the live journey available if saving fails; never discard dirty state.
	if not session.save_progress():
		pause(true)
		return false
	session.active = false
	session.revision += 1
	session.notice = "Journey saved. Choose Continue journey to return."
	started = false
	player.target = null
	player.sounds.stop()
	pause(true)
	menu.show_actions(false)
	return true

func quit_game() -> void:

	if session.active and not session.save_progress():

		pause(true)

		return

	get_tree().quit()



func mobile_menu_action(action: String) -> void:
	if not session.active or player.health <= 0 or transitioning:
		return
	pause(false)
	# Resume clears buffered input and grants two grace ticks. Dispatch afterwards.
	for tick in range(3):
		await get_tree().physics_frame
	if player.enabled and not get_tree().paused and not transitioning:
		# Input pressed inside physics_frame can be missed by a player that already
		# processed this tick. Deliver outside physics, as a normal touch event is.
		menu_input.call_deferred("pulse", action)

func _input(event: InputEvent) -> void:
	if is_instance_valid(account_panel) and account_panel.visible:
		if event.is_action_pressed("pause"): account_panel.close(); get_viewport().set_input_as_handled()
		return
	if is_instance_valid(opening):
		if event.is_action_pressed("pause"):
			opening.complete()
		if event is InputEventKey:
			get_viewport().set_input_as_handled()
		return

	if is_instance_valid(settings_panel) and settings_panel.visible:

		if settings_panel.capturing != "":

			settings_panel.capture_input(event)

			get_viewport().set_input_as_handled()

		elif event.is_action_pressed("pause"):

			if not settings.save_settings():

				session.notice = settings.notice

			settings_panel.hide()

			pause(true)

			get_viewport().set_input_as_handled()

		return

	if not is_instance_valid(menu) or transitioning:

		return

	if event.is_action_pressed("pause"):

		if dialogue.visible:

			leave_dialogue()

		elif started and player.health > 0:

			pause(not menu.visible)

		get_viewport().set_input_as_handled()

	elif session.active and event.is_action_pressed("equipment"):
		show_equipment()
		get_viewport().set_input_as_handled()
		return
	elif session.active and event.is_action_pressed("journal"):

		show_journal()

		get_viewport().set_input_as_handled()

	elif not get_tree().paused and event.is_action_pressed("companion_order"):

		journey.toggle_order()

		get_viewport().set_input_as_handled()

	elif not get_tree().paused and event.is_action_pressed("interact"):

		interact()



func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED] and MobileControls.requested():
		preload("res://game/presentation/mobile_display.gd").apply()

	if what == NOTIFICATION_WM_CLOSE_REQUEST and session != null:

		quit_game()

	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_GO_BACK_REQUEST] and is_instance_valid(menu) and not benchmarking:
		if session != null and session.active and session.dirty:
			session.save_progress()

		if is_instance_valid(settings_panel):

			settings_panel.capturing = ""

		pause(true)



func _process(_delta: float) -> void:
	if is_instance_valid(fps_label):
		fps_label.visible=settings.values.show_fps and started
		fps_label.text="%d FPS"%Engine.get_frames_per_second()

	if not is_instance_valid(hud) or not is_instance_valid(region):

		return

	retry_save_button.visible = session.dirty
	preload("res://game/localization/localizer.gd").set_text(quit_button, "Save and main menu" if session.active else "Quit")
	preload("res://game/localization/localizer.gd").set_text(menu_note, ("YOU FELL · Return to the last lantern.\n" if player.health <= 0 else "") + session.notice + ("\nUNSAVED · retry before quitting" if session.dirty else ""))

	var character: Dictionary = session.state.character

	preload("res://game/localization/localizer.gd").set_text(hud, "RANK %d  ·  Sword +%d\n%d flasks  ·  %d shards" % [character.rank,character.weapon_tier,player.healing_charges,character.shards])

	preload("res://game/localization/localizer.gd").set_text(region_caption, region.region_id.trim_prefix("region.").replace("_"," ").to_upper())

	preload("res://game/localization/localizer.gd").set_text(objective_label, "THE JOURNEY\n" + objective())

	if session.notice != last_notice:

		last_notice = session.notice

		notice_remaining = 5

	notice_remaining = maxf(0,notice_remaining-_delta)

	preload("res://game/localization/localizer.gd").set_text(notice_label, (session.notice+"\n" if notice_remaining > 0 or session.dirty else "") + "%s  Journal    %s  Pause" % [settings.hint("journal"),settings.hint("pause")])
	if MobileControls.requested():
		preload("res://game/localization/localizer.gd").set_text(notice_label, session.notice if notice_remaining > 0 or session.dirty else "")

	preload("res://game/localization/localizer.gd").set_text(prompt_label, "")

	hp_bar.max_value = player.max_health

	hp_bar.value = player.health

	stamina_bar.value = player.stamina

	var current := focus()

	if current != "":

		var new_prompts := {"grove": "Enter Thorn Beast grove", "grove_exit": "Return to Blackwood", "root_seal": "Break Root Seal", "forest_shortcut": "Open forest shortcut", "order_gate": "Enter Order's Ruins", "order_exit": "Return to Blackwood", "order_depth": "Enter Commander sanctum", "sanctum_exit": "Return to Order ruins", "oath_seal": "Break Oath Seal", "peaks_gate": "Enter Ashen Peaks", "peaks_exit": "Return to Order ruins", "mine": "Read mine inscription", "bridge": "Inspect bridge", "fortress": "Enter forge fortress", "peaks_shortcut": "Open service path", "forge_exit": "Return to Ashen Peaks", "forge_seal": "Break Forge Seal", "citadel_gate": "Enter Eclipse Citadel", "citadel_exit": "Return to Ashen Peaks", "citadel_depth": "Face Maldrek", "ritual_exit": "Return to citadel", "artifact": "Break the curse", "prisoners": "Free prisoners", "ritual_lore": "Read ritual inscription", "cael": "Talk to Sir Cael", "expedition": "Read expedition record"}

		if new_prompts.has(current):

			preload("res://game/localization/localizer.gd").set_text(prompt_label, "[%s] %s" % [settings.hint("interact"), new_prompts[current]])

		else:

			preload("res://game/localization/localizer.gd").set_text(prompt_label, "[%s] " % settings.hint("interact") + {"checkpoint": "Rest / activate lantern", "travel": "Travel to village" if region.region_id == "region.refuge" else "Return to refuge", "oren": "Talk to Oren", "lyra": "Talk to Lyra", "companion": "Companion orders", "satchel": "Recover scout satchel", "memorial": "Return family token", "token": "Collect family token", "shortcut": "Lift shortcut bar (village side)", "crypt": "Enter burial chamber", "crypt_exit": "Return to village", "seal": "Break Burial Seal", "forest": "Enter Blackwood", "forest_exit": "Return to village", "forest_end": "Inspect deeper forest path"}.get(current, current))

	prompt_panel.visible = prompt_label.text != ""

	prompt_panel.offset_top = -350 if MobileControls.requested() else -80

	prompt_panel.offset_bottom = -300 if MobileControls.requested() else -30

	if is_instance_valid(player.target):

		preload("res://game/localization/localizer.gd").append_text(objective_label, "\nLOCKED · %s" % player.target.display_name)

	var ally_status: String = journey.hud_status()

	if ally_status != "":

		preload("res://game/localization/localizer.gd").append_text(objective_label, "\n\n" + ally_status)



func objective() -> String:

	if session.state.campaign.completed:

		return "The curse is broken · explore the peaceful kingdom"

	if "boss.maldrek" in session.state.campaign.boss_defeated_ids:

		return "Shatter the central artifact to end the curse"

	if is_instance_valid(region) and region.region_id == "region.ritual":

		return "Defeat Maldrek · dodge the orb, leave marked ground"

	if is_instance_valid(region) and region.region_id == "region.citadel":

		return "Activate the lantern · free captives or face Maldrek to the north"

	if "region.citadel.visited" in session.state.campaign.facts:

		return "Chapter IV complete · Eclipse Citadel discovered"

	if "seal.forge" in session.state.campaign.broken_seal_ids:

		return "Enter Eclipse Citadel through the northeast mountain ward"

	if "boss.iron_warden" in session.state.campaign.boss_defeated_ids:

		return "Break the Forge Seal inside the fortress"

	if is_instance_valid(region) and region.region_id == "region.forge":

		return "Defeat Iron Warden · move clear of the slam, punish recovery"

	if is_instance_valid(region) and region.region_id == "region.peaks":

		return "Activate the lantern · cross the bridge to the forge fortress"

	if "region.peaks.visited" in session.state.campaign.facts:

		return "Chapter III complete · Ashen Peaks discovered"

	if "seal.oath" in session.state.campaign.broken_seal_ids:

		return "Enter Ashen Peaks through the northeast Order passage"

	if "boss.fallen_commander" in session.state.campaign.boss_defeated_ids:

		return "Break the Oath Seal inside the Commander's sanctum"

	if is_instance_valid(region) and region.region_id == "region.sanctum":

		return "Face the Commander · two crosscuts, then counter"

	if is_instance_valid(region) and region.region_id == "region.order":

		if "ally.cael" in session.state.campaign.recruited_ally_ids:

			return "Face the Fallen Commander in the northern sanctum"

		if "ally.cael.met" not in session.state.campaign.facts:

			return "Find Sir Cael west of the Order courtyard"

		if "order.courtyard_safe" not in session.state.campaign.facts:

			return "Defeat the three sentries in the courtyard and barracks"

		if "document.order.expedition" not in session.state.campaign.pickup_claim_ids:

			return "Recover the expedition record in the northwest memorial hall"

		return "Return the expedition record to Sir Cael"

	if "region.order.visited" in session.state.campaign.facts:

		return "Chapter II complete · Order's Ruins discovered"

	if "seal.root" in session.state.campaign.broken_seal_ids:

		return "Enter Order's Ruins through the northeast forest ward"

	if "boss.thorn_beast" in session.state.campaign.boss_defeated_ids:

		return "Break the Root Seal inside the guardian grove"

	if is_instance_valid(region) and region.region_id == "region.grove":

		return "Defeat Thorn Beast · sidestep lunges, punish recovery"

	if is_instance_valid(region) and region.region_id == "region.blackwood" and "ally.lyra" not in session.state.campaign.recruited_ally_ids:

		if "ally.lyra.met" not in session.state.campaign.facts:

			return "Find the scout beside the western forest path"

		if "forest.trail_safe" not in session.state.campaign.facts:

			return "Defeat the two hounds near the fallen walls"

		if "pickup.lyra_satchel" not in session.state.campaign.pickup_claim_ids:

			return "Recover Lyra's satchel by the watchtower post"

		return "Return the satchel to Lyra and ask her to join"

	if "region.blackwood.visited" in session.state.campaign.facts:

		return "Follow the watchtower road to the root shrine"

	if "seal.burial" in session.state.campaign.broken_seal_ids:

		return "Enter Blackwood through the northeast passage"

	if "boss.gravedigger" in session.state.campaign.boss_defeated_ids:

		return "Break the Burial Seal inside the crypt"

	if "ally.oren" in session.state.campaign.recruited_ally_ids:

		return "Confront the Gravedigger north of the square"

	return "Find survivors · Oren is at the eastern mill"



func play_wizard_defeat(actor: CharacterBody3D) -> void:
	if is_instance_valid(opening): return
	var film:=preload("res://game/presentation/wizard_defeat_cinematic.gd").new()
	opening=film
	add_child(film)
	film.finished.connect(func():
		opening=null
		pause(false)
		if is_instance_valid(mobile_controls): mobile_controls.show()
	)
	film.setup(self,actor)

func finish_ending() -> void:

	if not await transition("region.refuge"):

		pause(true)

		return

	open_dialogue("DAWN OVER VEYR\n\nThe central artifact shatters. For the first time in years, the roads fall silent. The knight returns to Lantern Refuge. Those who survived can begin again.\n\nTHE END\n\nCredits\nThe Knight of Last Light · local development campaign\nOriginal gameplay/ruin kit and weapon effects. Footfalls: Kenney (CC0). Poly Haven models/maps (CC0). Character geometry generated with Meshy (https://www.meshy.ai/), Meshy 6 Lite / CC BY 4.0, modified geometry/materials/motion. Knight equipment by Andy Woodhead via afk.ai (CC BY 4.0). Ambient dragon by chengzijieczj; crystal deer by Coffeek; shadow hound base by Alexei Ostapenko (CC BY 4.0 via afk.ai), modified for passive scenery. Hostile armor by DJMaesen; canine base by Alexei Ostapenko, via afk.ai (CC BY 4.0), modified for this game.\nBuilt with Godot 4.7.2 · MIT engine license; bundled font/library notices accompany the build.\n\nYour completed journey is saved. Continue exploring the peaceful kingdom; reopening this save returns to the restored refuge.")

	button(choices,"Continue exploring",leave_dialogue)















