extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const Store = preload("res://game/persistence/infrastructure/save_store.gd")
const OrderChecks = preload("res://tests/order_checks.gd")

static func rules(check: Callable) -> void:
	check.call(not Rules.apply_action(Rules.new_game(), "DefeatBoss", "boss.fallen_commander").accepted, "Commander defeat requires discovered Order")
	var state := OrderChecks.order_state()
	check.call(not Rules.apply_action(state, "VisitPeaks").accepted, "Peaks discovery requires Oath Seal")
	var legacy := state.duplicate(true)
	state = Rules.apply_action(state, "DefeatBoss", "boss.fallen_commander").next_state
	check.call(state.schema_version == 5 and state.character.shards == 330 and state.character.rank == 5 and state.character.xp_into_rank == 20 and Schema.validate(state) == "", "Commander grants 300 XP and 140 shards once without optional Cael quest")
	check.call(not Rules.apply_action(state, "DefeatBoss", "boss.fallen_commander").accepted and not Rules.gate_access("gate.order_to_peaks", state).allowed, "Victory cannot duplicate reward or automatically break Oath Seal")
	state = Rules.apply_action(state, "BreakSeal", "seal.oath").next_state
	state = Rules.apply_action(state, "VisitPeaks").next_state
	check.call(state.campaign.quest_states["quest.main.ch03"] == "completed" and Schema.validate(state) == "", "Peaks discovery completes chapter three after explicit seal action")
	var invalid := state.duplicate(true)
	invalid.schema_version = 4
	check.call(Schema.validate(invalid) != "", "Commander progress cannot masquerade as schema four")
	invalid = state.duplicate(true)
	invalid.campaign.quest_states.erase("quest.main.ch03")
	check.call(Schema.validate(invalid) != "", "Peaks discovery requires matching chapter-three completion")
	state = Rules.apply_action(state, "MeetCael").next_state
	state = Rules.apply_action(state, "OpenForestShortcut").next_state
	check.call(state.schema_version == 5 and Schema.validate(state) == "", "Older Cael and forest mutations preserve schema five")
	var store := Store.new("res://.tools/test-commander/" + str(Time.get_ticks_usec()))
	check.call(store.save(legacy).ok and store.save(state).ok, "Schema-five snapshot promotes safely over earlier version")
	var loaded: Dictionary = store.load_slot(1)
	check.call(loaded.ok and "seal.oath" in loaded.state.campaign.broken_seal_ids and "region.peaks.visited" in loaded.state.campaign.facts and Schema.validate(loaded.state) == "", "Oath Seal and Peaks discovery survive real JSON round-trip")
	check.call(store.read_file(store.path_for(1) + ".bak", 1).state.schema_version == 3, "Commander promotion preserves readable legacy backup")

static func run(tree: SceneTree, check: Callable) -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	game.session.begin(1, false)
	game.started = true
	check.call(not await game.transition("region.sanctum") and not await game.transition("region.peaks"), "Direct runtime travel rejects undiscovered sanctum and locked Peaks")
	game.session.state = OrderChecks.order_state()
	for command in [["MeetCael", ""], ["ClearOrderCourtyard", ""], ["ReadExpedition", ""], ["RecruitAlly", "ally.cael"], ["ActivateCheckpoint", "checkpoint.order"]]:
		game.session.act(command[0], command[1])
	await game.transition("region.order")
	game.pause(false)
	game.player.enabled = false
	for guard in game.enemies:
		guard.set_physics_process(false)
	game.player.position = game.region.points.order_depth + Vector3(0, 0.1, 1)
	game.interact()
	while game.transitioning:
		await tree.physics_frame
	game.player.enabled = false
	var boss = game.commander.actor
	boss.set_physics_process(false)
	check.call(game.region.region_id == "region.sanctum" and boss.health == 600 and boss.state == "dormant" and game.region.entrance_barrier.collision_layer == 0, "Sanctum interaction constructs dormant Commander with open entrance")
	check.call(not is_instance_valid(game.journey.follower) and game.journey.status.contains("Sir Cael waits outside"), "Selected companion waits outside Commander arena")
	check.call(not game.commander.break_seal(), "Living Commander rejects Oath Seal interaction")
	game.player.position = game.region.surface_point(Vector3(0, 0.1, 5))
	boss._physics_process(0.016)
	check.call(game.in_combat() and game.region.entrance_barrier.collision_layer == 1 and not game.rest(), "Encounter trigger closes ward and prevents resting")
	game.player.position = game.region.points.sanctum_exit
	game.interact()
	check.call(game.region.region_id == "region.sanctum" and not game.transitioning and game.session.notice.contains("ward holds"), "Actual exit interaction cannot escape active Commander")
	game.player.position = boss.position + Vector3(0, 0, 2)
	boss.begin_attack("crosscut")
	var hp: float = game.player.health
	boss._physics_process(0.79)
	check.call(game.player.health == hp and boss.state == "windup", "First crosscut has a damage-free readable windup")
	boss._physics_process(0.02)
	boss._physics_process(0.18)
	var first_hp: float = game.player.health
	check.call(first_hp < hp and boss.state == "windup" and boss.combo_step == 1, "First crosscut hits once then telegraphs a distinct second swing")
	boss._physics_process(0.64)
	check.call(game.player.health == first_hp and boss.state == "windup", "Second crosscut cannot hit before its own telegraph ends")
	boss._physics_process(0.02)
	boss._physics_process(0.18)
	check.call(game.player.health < first_hp and boss.state == "recover", "Second swing has a fresh hit claim and ends in counter window")
	var after: float = game.player.health
	var boss_hp: float = boss.health
	boss.receive_hit(game.player.position, 22, 1, 0)
	boss._physics_process(1.5)
	check.call(game.player.health == after and boss.health < boss_hp and boss.state == "recover", "Recovery allows knight damage and cannot repeat sword damage")
	game.player.combat.state = "block"
	game.player.stamina = 100
	game.player.visual.rotation.y = 0
	boss.begin_attack("thrust")
	boss._physics_process(1.06)
	boss._physics_process(0.28)
	check.call(game.player.health == after - 5 and game.player.stamina == 100, "Actual Commander thrust respects frontal blocking without spending sprint reserve")
	game.player.combat.state = "locomotion"
	game.player.dodge_left = 0.5
	after = game.player.health
	boss.begin_attack("overhead")
	boss._physics_process(1.26)
	boss._physics_process(0.22)
	check.call(game.player.health == after and boss.state == "recover", "Actual overhead strike respects knight dodge invulnerability")
	game.player.health = 0
	await game.respawn()
	check.call(game.region.region_id == "region.order" and game.player.health == game.player.max_health and is_instance_valid(game.journey.follower), "Boss loss restores Order lantern and selected companion")
	await game.transition("region.sanctum")
	game.player.enabled = false
	boss = game.commander.actor
	boss.set_physics_process(false)
	check.call(boss.health == 600 and boss.attack_index == 0 and boss.combo_step == 0 and boss.state == "dormant", "Unfinished Commander resets health, pattern and combo on re-entry")
	boss.start()
	var before: int = game.session.state.character.shards
	boss.receive_hit(game.player.position, 10000, 1, 0)
	check.call(boss.health == 0 and boss.ledger == null and game.region.entrance_barrier.collision_layer == 0 and game.session.state.character.shards == before + 140, "Actual victory clears damage/ward and commits 140-shard reward once")
	check.call("seal.oath" not in game.session.state.campaign.broken_seal_ids and not await game.transition("region.peaks"), "Victory leaves Oath Seal intact and mountain route locked")
	await game.start_selected(true)
	check.call(game.region.region_id == "region.order", "Menu load resumes safely at Order checkpoint after victory")
	await game.transition("region.sanctum")
	game.player.enabled = false
	check.call(game.commander.actor.health == 0 and game.region.seal.visible and game.session.state.character.shards == before + 140, "Reload keeps Commander dead, seal available and reward unchanged")
	game.player.position = game.region.points.oath_seal + Vector3(0, 0.1, 1)
	game.interact()
	check.call("seal.oath" in game.session.state.campaign.broken_seal_ids and not game.region.seal.visible and not game.commander.break_seal(), "Explicit Oath Seal interaction persists once and removes visual seal")
	await game.transition("region.order", "order_depth")
	game.player.enabled = false
	check.call(game.player.position.z == -45 and game.region.peaks_ward.collision_layer == 0 and game.journey.follower.ally_id == "ally.cael", "Sanctum return places knight safely and reconstructs companion beside open mountain ward")
	for guard in game.enemies:
		guard.set_physics_process(false)
	game.player.position = game.region.points.peaks_gate + Vector3(0, 0.1, 1)
	game.interact()
	while game.transitioning:
		await tree.physics_frame
	game.player.enabled = false
	check.call(game.region.region_id == "region.peaks" and game.session.state.campaign.quest_states.get("quest.main.ch03") == "completed" and is_instance_valid(game.journey.follower), "Actual mountain ward interaction loads playable Peaks approach with companion and chapter-three completion")
	check.call(game.region.points.checkpoint == game.region.surface_point(Vector3(-7, 0, 5)), "Expanded Peaks exposes its authored lantern checkpoint")
	await game.transition("region.order", "peaks_gate")
	game.player.enabled = false
	check.call(game.player.position.x == 22 and game.player.position.z == -45, "Mountain return spawn avoids immediate retrigger")
	await game.transition("region.refuge")
	check.call(game.region.refuge_echo.text.contains("OATH WARD HAS FALLEN") and Schema.validate(game.session.state) == "", "Refuge reflects Oath Seal and completed state remains valid")
	game.ui_sound.stop()
	game.player.sounds.stop()
	game.pause(true)
	await tree.create_timer(0.2, true).timeout
	game.queue_free()
	await tree.process_frame
