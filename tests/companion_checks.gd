extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const Settings = preload("res://game/settings/game_settings.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")
const Store = preload("res://game/persistence/infrastructure/save_store.gd")

static func rules(check: Callable) -> void:
	var state := Rules.new_game()
	check.call(not Rules.apply_action(state, "MeetLyra").accepted and not Rules.apply_action(state, "RecruitAlly", "ally.lyra").accepted, "Lyra requires discovery and authored quest, never proximity")
	for action in [["DefeatBoss", "boss.gravedigger"], ["BreakSeal", "seal.burial"], ["VisitBlackwood", ""], ["MeetLyra", ""]]:
		state = Rules.apply_action(state, action[0], action[1]).next_state
	check.call(not Rules.apply_action(state, "ClaimPickup", "pickup.lyra_satchel").accepted, "Scout satchel requires a secured trail")
	state = Rules.apply_action(state, "ClearForestTrail").next_state
	state = Rules.apply_action(state, "ClaimPickup", "pickup.lyra_satchel").next_state
	var prior: int = state.character.shards
	state = Rules.apply_action(state, "RecruitAlly", "ally.lyra").next_state
	check.call(state.campaign.active_companion_id == "ally.lyra" and state.character.shards == prior + 20, "Explicit recruitment atomically selects Lyra and grants reward")
	check.call(Schema.validate(state) == "" and not Rules.apply_action(state, "RecruitAlly", "ally.lyra").accepted, "Recruitment snapshot validates and reward cannot duplicate")
	check.call(state.schema_version == 2 and Rules.new_game().schema_version == 1, "First companion mutation upgrades a copied legacy state to schema two")
	var mislabeled := state.duplicate(true)
	mislabeled.schema_version = 1
	check.call(Schema.validate(mislabeled) != "", "New companion facts cannot masquerade as an old save schema")
	check.call(not Rules.apply_action(state, "SetActiveCompanion", "ally.oren").accepted, "Refuge blacksmith cannot become active companion")
	var dismissed: Dictionary = Rules.apply_action(state, "SetActiveCompanion").next_state
	check.call(dismissed.campaign.active_companion_id == null and "ally.lyra" in dismissed.campaign.recruited_ally_ids, "Waiting clears active selection without losing recruitment")
	var bad := state.duplicate(true)
	bad.campaign.pickup_claim_ids.erase("pickup.lyra_satchel")
	check.call(Schema.validate(bad) != "", "Save cannot recruit Lyra without satchel prerequisites")
	var directory := "res://.tools/test-settings/" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(directory)
	var config := ConfigFile.new()
	var model := Settings.new(directory.path_join("legacy.cfg"))
	model.restore_defaults()
	var store := Store.new(directory.path_join("saves"))
	check.call(store.save(Rules.new_game()).ok and store.save(state).ok, "Companion schema two promotes over a legacy save with backup")
	var loaded: Dictionary = store.load_slot(1)
	check.call(loaded.ok and loaded.state.campaign.active_companion_id == "ally.lyra" and Schema.validate(loaded.state) == "", "Real JSON round-trip retains version-two recruitment and selection")
	check.call(store.read_file(store.path_for(1) + ".bak", 1).state.schema_version == 1, "Companion schema upgrade retains previous version-one backup")
	for action in model.bindings:
		if action != "companion_order":
			config.set_value("bindings", action, KEY_C if action == "interact" else model.bindings[action])
	config.save(model.path)
	model.load_settings()
	check.call(model.bindings.interact == KEY_C and model.bindings.companion_order == KEY_V, "Legacy C rebind survives new companion control with unused fallback")
	model.restore_defaults()

static func run(tree: SceneTree, check: Callable) -> void:
	var scene := load("res://game/world/runtime/village_game.tscn") as PackedScene
	var game = scene.instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	await game.start_selected()
	game.session.act("DefeatBoss", "boss.gravedigger")
	game.session.act("BreakSeal", "seal.burial")
	await game.transition("region.blackwood")
	game.player.enabled = false
	for guard in game.enemies:
		guard.set_physics_process(false)
	check.call(game.journey.guards.size() == 2 and game.region.lyra.visible and not is_instance_valid(game.journey.follower), "Forest introduces captive scout and two guards before recruitment")
	game.player.position = game.region.points.lyra + Vector3(0, 0.1, 2)
	await tree.physics_frame
	check.call(game.focus() == "lyra", "Lyra has visible reachable interaction focus")
	game.interact()
	check.call(game.dialogue.visible and game.session.state.campaign.quest_states.get("quest.lyra") == "active", "Scout dialogue starts authored quest")
	game.choices.get_child(0).pressed.emit()
	check.call("ally.lyra" not in game.session.state.campaign.recruited_ally_ids, "Early Join choice cannot bypass scout quest")
	game.leave_dialogue()
	for guard in game.journey.guards:
		guard.receive_hit(game.player.position, 1000, 1, 0)
	check.call("forest.trail_safe" in game.session.state.campaign.facts, "Actual trail encounter defeat commits quest prerequisite")
	game.player.position = game.region.points.satchel + Vector3(0, 0.1, 1)
	game.interact()
	check.call(not game.region.satchel.visible and "pickup.lyra_satchel" in game.session.state.campaign.pickup_claim_ids, "Satchel interaction persists pickup")
	game.player.position = game.region.points.lyra + Vector3(0, 0.1, 2)
	game.interact()
	game.choices.get_child(0).pressed.emit()
	var ally = game.journey.follower
	check.call(is_instance_valid(ally) and not game.region.lyra.visible and ally.health == 70, "Join choice replaces static scout with one active follower")
	check.call(tree.get_nodes_in_group("companions").size() == 1 and game.session.state.campaign.active_companion_id == "ally.lyra", "Exactly one follower and durable active selection exist")
	game.player.enabled = false
	game.player.position = game.region.surface_point(Vector3(0, 0.1, 5))
	ally.position = game.region.surface_point(Vector3(0, 0.1, -3))
	var before: Vector3 = ally.position
	for tick in range(60):
		await tree.physics_frame
	check.call(ally.position.distance_to(before) > 2 and ally.position.distance_to(game.player.position) < before.distance_to(game.player.position), "Follower uses navigation output to close the distance")
	check.call(game.journey.toggle_order() and ally.order == "hold", "Companion command switches to hold")
	before = ally.position
	game.player.position = game.region.surface_point(Vector3(0, 0.1, -8))
	for tick in range(30):
		await tree.physics_frame
	check.call(ally.position.distance_to(before) < 0.15, "Hold actually keeps position while knight moves away")
	check.call(game.journey.toggle_order() and ally.order == "follow", "Follow command resumes after hold")
	ally.set_physics_process(false)
	ally.receive_hit(game.player.position, 1000, 1, 0)
	check.call(ally.health == 0 and ally.state == "downed" and not ally.set_order("follow"), "Companion damage downs without permanent death or accepting orders")
	await game.transition("region.village")
	game.player.enabled = false
	for hostile in game.enemies:
		hostile.set_physics_process(false)
	ally = game.journey.follower
	check.call(is_instance_valid(ally) and ally.health == 70, "Safe passage recovers downed Lyra in permitted region")
	ally.receive_hit(game.player.position, 1000, 1, 0)
	game.player.position = game.region.points.checkpoint + Vector3(-2, 0.1, 0)
	game.rest()
	check.call(ally.health == 70 and ally.state == "follow", "Resting at actual lantern recovers follower")
	game.player.enabled = false
	for hostile in game.enemies:
		hostile.set_physics_process(false)
	ally.set_physics_process(false)
	game.player.position = game.region.surface_point(Vector3(-5, 0.1, 0))
	ally.position = game.region.surface_point(Vector3(-5, 0.1, -1))
	var hostile = game.enemies[0]
	hostile.position = game.region.surface_point(Vector3(-5, 0.1, -2))
	hostile.state = "chase"
	var hp: float = ally.health
	Strike.swing(hostile, &"knight", Sweep.new(), PI, -1.1, 1.1, 2.5, 24, 1, 35)
	check.call(ally.health < hp, "Hostile sword query can damage companion with correct team rules")
	var knight_hp: float = game.player.health
	var enemy_hp: float = hostile.health
	ally.target = hostile
	ally.state = "engage"
	ally.attack_elapsed = 0
	ally.attack_hit = false
	ally._physics_process(0.4)
	check.call(hostile.health < enemy_hp and game.player.health == knight_hp, "Companion melee aids against hostile without friendly fire")
	var damaged: float = hostile.health
	ally._physics_process(0.1)
	check.call(hostile.health == damaged, "One companion attack cannot damage every tick")
	hostile.add_to_group("bosses")
	check.call(ally.choose_target() == null, "Companion cannot independently select or finish a boss")
	hostile.remove_from_group("bosses")
	for actor in game.enemies:
		actor.reset_encounter()
	ally.order = "follow"
	game.player.position = game.region.surface_point(Vector3(0, 0.1, 15))
	ally.position = game.region.surface_point(Vector3(0, 0.1, 22))
	var safe: Dictionary = ally.safe_point(false)
	check.call(not safe.ok or safe.position.z < 18, "Safe regroup candidate cannot cross a closed shortcut barrier")
	ally.recovery_cooldown = 0
	game.player.position = game.region.surface_point(Vector3(100, 0.1, 100))
	ally.recover_if_stuck()
	check.call(ally.state == "suspended" and not ally.visible, "No valid navigation recovery point suspends follower safely")
	game.player.position = game.region.points.checkpoint + Vector3(-2, 0.1, 0)
	game.rest()
	check.call(ally.state == "follow" and ally.visible, "Checkpoint restores suspended follower without teleport loops")
	game.enemies[0].state = "chase"
	ally.position.y = -11
	ally._physics_process(0.016)
	check.call(ally.state == "suspended" and not ally.visible, "Out-of-bounds follower suspends even during combat without unsafe teleport")
	game.enemies[0].state = "idle"
	game.rest()
	check.call(ally.health == 70 and ally.visible, "Lantern recovers out-of-bounds suspension")
	await game.transition("region.crypt")
	game.player.enabled = false
	check.call(not is_instance_valid(game.journey.follower) and tree.get_nodes_in_group("companions").is_empty(), "Restricted boss arena never spawns companion")
	check.call(game.session.state.campaign.active_companion_id == "ally.lyra" and game.journey.status.contains("outside"), "Restriction explains waiting without losing saved selection")
	await game.transition("region.village", "crypt")
	game.player.enabled = false
	check.call(is_instance_valid(game.journey.follower), "Returning from restricted arena restores follower")
	game.session.save_progress()
	check.call(game.session.load_slot(1), "Companion selection/recruitment reloads through save seam")
	await game.transition("region.refuge")
	game.player.enabled = false
	check.call(is_instance_valid(game.journey.follower) and not game.region.lyra.visible, "Reload active selection produces one follower, no duplicate resident")
	game.journey.select(false)
	check.call(not is_instance_valid(game.journey.follower) and game.region.lyra.visible and "ally.lyra" in game.session.state.campaign.recruited_ally_ids, "Dismissal returns Lyra to refuge without losing recruitment")
	check.call(Schema.validate(game.session.state) == "", "Companion journey remains save-valid")
	game.ui_sound.stop()
	game.player.sounds.stop()
	game.pause(true)
	await tree.create_timer(0.2, true).timeout
	game.queue_free()
	await tree.process_frame
