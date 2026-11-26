extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const Store = preload("res://game/persistence/infrastructure/save_store.gd")

static func peaks_state() -> Dictionary:
	var state: Dictionary = preload("res://tests/order_checks.gd").order_state()
	for command in [["DefeatBoss", "boss.fallen_commander"], ["BreakSeal", "seal.oath"], ["VisitPeaks", ""]]:
		state = Rules.apply_action(state, command[0], command[1]).next_state
	return state

static func rules(check: Callable) -> void:
	check.call(not Rules.apply_action(Rules.new_game(), "ActivateCheckpoint", "checkpoint.peaks").accepted and not Rules.apply_action(Rules.new_game(), "DefeatBoss", "boss.iron_warden").accepted, "Peaks checkpoint and Warden require discovered mountains")
	var state := peaks_state()
	var legacy := state.duplicate(true)
	check.call(not Rules.apply_action(state, "VisitCitadel").accepted, "Three seals do not unlock citadel")
	for command in [["ActivateCheckpoint", "checkpoint.peaks"], ["OpenPeaksShortcut", ""], ["DefeatBoss", "boss.iron_warden"]]:
		state = Rules.apply_action(state, command[0], command[1]).next_state
	check.call(state.schema_version == 6 and state.character.shards == 490 and state.character.rank == 6 and state.character.xp_into_rank == 80 and Schema.validate(state) == "", "Warden grants 360 XP and 160 shards once in valid schema six")
	check.call(not Rules.apply_action(state, "DefeatBoss", "boss.iron_warden").accepted and not Rules.apply_action(state, "VisitCitadel").accepted, "Repeated Warden victory cannot duplicate reward or bypass Forge Seal")
	state = Rules.apply_action(state, "BreakSeal", "seal.forge").next_state
	state = Rules.apply_action(state, "VisitCitadel").next_state
	check.call(state.campaign.quest_states["quest.main.ch04"] == "completed" and Schema.validate(state) == "", "Four seals allow citadel discovery and chapter-four completion")
	var invalid := state.duplicate(true)
	invalid.schema_version = 5
	check.call(Schema.validate(invalid) != "", "New Peaks facts reject mislabeled legacy schema")
	state = Rules.apply_action(state, "MeetCael").next_state
	state = Rules.apply_action(state, "ActivateCheckpoint", "checkpoint.order").next_state
	check.call(state.schema_version == 6 and Schema.validate(state) == "", "Backtracking and older companion actions preserve schema six")
	var store := Store.new("res://.tools/test-peaks/" + str(Time.get_ticks_usec()))
	check.call(store.save(legacy).ok and store.save(state).ok, "Schema-six promotion preserves prior snapshot")
	var loaded: Dictionary = store.load_slot(1)
	check.call(loaded.ok and "seal.forge" in loaded.state.campaign.broken_seal_ids and "region.citadel.visited" in loaded.state.campaign.facts, "Forge Seal and citadel discovery survive actual JSON round-trip")
	check.call(store.read_file(store.path_for(1) + ".bak", 1).state.schema_version == 5, "Known-good version-five backup remains readable")

static func run(tree: SceneTree, check: Callable) -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	game.session.begin(1, false)
	game.started = true
	check.call(not await game.transition("region.forge") and not await game.transition("region.citadel"), "Runtime rejects undiscovered forge and locked citadel")
	game.session.state = peaks_state()
	for command in [["MeetLyra", ""], ["ClearForestTrail", ""], ["ClaimPickup", "pickup.lyra_satchel"], ["RecruitAlly", "ally.lyra"]]:
		game.session.act(command[0], command[1])
	await game.transition("region.peaks")
	game.pause(false)
	game.player.enabled = false
	for enemy in game.enemies:
		enemy.set_physics_process(false)
	check.call(game.enemies.size() == 3 and game.region.points.has("mine") and game.region.points.has("fortress"), "Peaks constructs mine, bridge, fortress and three ordinary encounters")
	check.call(preload("res://game/persistence/domain/journey_history.gd").enemy_id("region.peaks",game.enemies[0]) == "region.peaks/grave_hound/-18.00,0.10,-19.00", "Raised mountain enemies retain their original persistent journey identity")
	game.player.position = game.region.points.checkpoint + Vector3(-2, 0.1, 0)
	check.call(game.rest() and game.session.state.recovery.region_id == "region.peaks", "Peaks lantern sets durable recovery")
	game.player.enabled = false
	var path := NavigationServer3D.map_get_path(game.region.navigation.get_navigation_map(), game.region.surface_point(Vector3(0,0,-22)), game.region.surface_point(Vector3(0,0,-40)), true)
	var on_bridge := path.size() > 2 and path[path.size()-1].z < -39
	for point in path:
		if point.z < -26 and point.z > -34 and absf(point.x) > 1.7:
			on_bridge = false
	check.call(on_bridge, "Navigation crosses real gorge only inside railed bridge")
	game.player.position = game.region.surface_point(Vector3(0, 0.1, -22))
	game.journey.follower.position = game.region.surface_point(Vector3(0, 0.1, -19))
	game.player.enabled = true
	Input.action_press("move_forward")
	for tick in range(240):
		await tree.physics_frame
	Input.action_release("move_forward")
	game.player.enabled = false
	check.call(game.player.position.z < -37 and game.player.position.y > -1, "Actual knight physics crosses bridge without falling through gap")
	check.call(game.journey.follower.position.z < -30 and game.journey.follower.position.y > -1, "Selected companion follows actual bridge route over gorge")
	game.player.position = Vector3(8, -13, -30)
	game.player.enabled = true
	await tree.physics_frame
	await tree.physics_frame
	while game.transitioning:
		await tree.physics_frame
	game.player.enabled = false
	check.call(game.region.region_id == "region.peaks" and game.player.position.distance_to(game.region.points.checkpoint) < 3, "Falling into gorge restores real Peaks lantern safely")
	for enemy in game.enemies:
		enemy.set_physics_process(false)
	game.player.position = game.region.points.peaks_shortcut
	game.interact()
	check.call(game.region.peaks_shortcut.collision_layer == 0, "Fortress-side service bar opens persistent shortcut")
	await game.transition("region.forge")
	game.player.enabled = false
	var boss = game.peaks_chapter.actor
	boss.set_physics_process(false)
	check.call(boss.health == 720 and boss.state == "dormant" and not is_instance_valid(game.journey.follower), "Forge constructs dormant Warden and excludes selected companion")
	check.call(not game.peaks_chapter.break_seal(), "Living Warden protects Forge Seal")
	game.player.position = game.region.surface_point(Vector3(0,0.1,5))
	boss._physics_process(0.016)
	check.call(game.in_combat() and game.region.entrance_barrier.collision_layer == 1 and not game.rest(), "Forge encounter closes ward and rejects rest")
	game.player.position = boss.position + Vector3(0,0,2)
	boss.begin_attack("forge_slam")
	var hp: float = game.player.health
	boss._physics_process(1.39)
	check.call(game.player.health == hp and boss.state == "windup", "Slam has full damage-free raised-hammer telegraph")
	game.player.position = boss.position + Vector3(6,0,0)
	boss._physics_process(0.02)
	boss._physics_process(0.2)
	check.call(game.player.health == hp and boss.state == "recover", "Local slam can be avoided by leaving its reach")
	game.player.position = boss.position + Vector3(0,0,2)
	boss.begin_attack("forge_slam")
	boss._physics_process(1.41)
	boss._physics_process(0.1)
	var after: float = game.player.health
	boss._physics_process(0.1)
	check.call(after < hp and game.player.health == after, "One local slam cannot damage target repeatedly during active window")
	game.player.combat.state = "block"
	game.player.stamina = 100
	game.player.visual.rotation.y = 0
	boss.begin_attack("hammer_sweep")
	boss._physics_process(1.01)
	boss._physics_process(0.3)
	check.call(game.player.health == after - 5 and game.player.stamina == 100, "Actual hammer sweep respects frontal blocking without spending sprint reserve")
	game.player.health = 0
	await game.respawn()
	check.call(game.region.region_id == "region.peaks" and game.player.health == game.player.max_health, "Warden loss restores Peaks checkpoint")
	await game.transition("region.forge")
	game.player.enabled = false
	boss = game.peaks_chapter.actor
	boss.set_physics_process(false)
	check.call(boss.health == 720 and boss.state == "dormant" and boss.attack_index == 0, "Unfinished Warden fully resets on re-entry")
	boss.start()
	var shards: int = game.session.state.character.shards
	boss.receive_hit(game.player.position,10000,1,0)
	check.call(boss.health == 0 and boss.ledger == null and game.session.state.character.shards == shards + 160 and game.region.entrance_barrier.collision_layer == 0, "Real Warden victory clears ward/damage and commits one-time reward")
	check.call(not await game.transition("region.citadel"), "Warden victory alone cannot unlock citadel")
	await game.start_selected(true)
	check.call(game.region.region_id == "region.peaks", "Actual load accepts newly activated mountain checkpoint")
	await game.transition("region.forge")
	game.player.enabled = false
	check.call(game.peaks_chapter.actor.health == 0 and game.region.seal.visible and game.session.state.character.shards == shards + 160, "Reload preserves Warden defeat and unbroken Forge Seal without duplicate reward")
	game.player.position = game.region.points.forge_seal + Vector3(0,0.1,1)
	game.interact()
	check.call("seal.forge" in game.session.state.campaign.broken_seal_ids and not game.region.seal.visible and not game.peaks_chapter.break_seal(), "Explicit Forge Seal interaction persists once")
	await game.transition("region.peaks", "fortress")
	game.player.enabled = false
	check.call(game.player.position.z == -62 and game.region.citadel_ward.collision_layer == 0 and game.region.peaks_shortcut.collision_layer == 0 and is_instance_valid(game.journey.follower), "Returning to fortress reflects both open routes and reconstructs companion")
	check.call(await game.transition("region.citadel") and game.session.state.campaign.quest_states.get("quest.main.ch04") == "completed", "Four seals permit actual playable citadel entrance and chapter-four completion")
	game.player.enabled = false
	await game.transition("region.peaks", "citadel_gate")
	check.call(game.player.position.x == 23 and game.player.position.z == -66, "Citadel return arrives safely on mountain plateau")
	await game.transition("region.refuge")
	check.call(game.region.refuge_echo.text.contains("FOUR SEALS HAVE FALLEN") and Schema.validate(game.session.state) == "", "Four-seal refuge feedback and full saved state stay consistent")
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.pause(true)
	await tree.create_timer(0.2,true).timeout
	game.queue_free()
	await tree.process_frame
