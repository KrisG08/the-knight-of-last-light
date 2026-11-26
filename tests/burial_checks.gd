extends RefCounted

const Schema = preload("res://game/persistence/domain/save_schema.gd")
const SettingsChecks = preload("res://tests/settings_checks.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	var scene := load("res://game/world/runtime/village_game.tscn") as PackedScene
	var game = scene.instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	await game.start_selected()
	check.call(not await game.transition("region.blackwood"), "Blackwood region cannot be entered before Burial Seal")
	await game.transition("region.village")
	for actor in game.enemies:
		actor.set_physics_process(false)
	game.player.position = game.region.points.checkpoint + Vector3(-2, 0.1, 0)
	game.rest()
	await game.transition("region.crypt")
	game.player.enabled = false
	var boss = game.burial.actor
	var ambience = game.region.get_node("BurialAmbience")
	await tree.process_frame
	check.call(ambience.air.playing and ambience.air.bus=="SFX" and ambience.seal_tone.playing,"Crypt starts region-owned ambience and intact-seal resonance on the effects bus")
	var clear_floor := true
	for x in [-6.0,0,6.0]:
		var query := PhysicsRayQueryParameters3D.create(Vector3(x,1.2,6),Vector3(x,1.2,-6),1)
		clear_floor = clear_floor and game.get_world_3d().direct_space_state.intersect_ray(query).is_empty()
	check.call(clear_floor,"Burial architecture leaves three full-length combat corridors free of world blockers")
	boss.set_physics_process(false)
	check.call(boss.state == "dormant" and boss.health == 420 and game.region.entrance_barrier.collision_layer == 0, "Crypt builds dormant full-health boss and open entrance")
	check.call(not game.burial.break_seal(), "Living guardian prevents Burial Seal interaction")
	boss.receive_hit(game.player.position, 1000, 1, 0)
	check.call(boss.health == 420, "Dormant boss rejects damage before encounter")
	game.player.position = game.region.surface_point(Vector3(0, 0.1, 4))
	boss._physics_process(0.016)
	check.call(game.burial.active() and game.region.entrance_barrier.collision_layer == 1, "Entering arena starts encounter and closes barrier")
	await SettingsChecks.runtime(game, check)
	game.player.enabled = false
	game.player.health = game.player.max_health
	game.player.combat.state = "locomotion"
	check.call(not game.rest(), "Cannot rest during boss encounter")
	game.player.position = boss.position + Vector3(0, 0, 2)
	await tree.physics_frame
	boss.begin_attack("sweep")
	var before: float = game.player.health
	boss._physics_process(0.79)
	check.call(game.player.health == before and boss.state == "windup", "Sweep has full readable windup before damage")
	boss._physics_process(0.02)
	boss._physics_process(0.25)
	check.call(game.player.health < before, "Boss sweep damages a real knight during active window")
	var after: float = game.player.health
	boss._physics_process(0.2)
	check.call(game.player.health == after, "Boss recovery cannot deal repeated sweep damage")
	game.player.combat.state = "locomotion"
	game.player.health = game.player.max_health
	game.player.position = boss.position + Vector3(0, 0, 2)
	boss.begin_attack("slam")
	boss._physics_process(0.6)
	check.call(boss.shovel.rotation.x > 0.4 and game.player.health == game.player.max_health, "Slam raises shovel during harmless windup")
	game.player.position = boss.position + Vector3(5, 0, 1)
	boss._physics_process(0.61)
	boss._physics_process(0.2)
	check.call(game.player.health == game.player.max_health, "Telegraphed slam can be avoided by lateral movement")
	game.player.position = boss.position + Vector3(0, 0, 3)
	boss.begin_attack("grab")
	var grab_origin: Vector3 = boss.position
	boss.set_physics_process(true)
	for tick in range(20):
		await tree.physics_frame
	boss.set_physics_process(false)
	check.call(boss.position.distance_to(grab_origin) > 0.3, "Grab slowly advances in its telegraphed direction")
	game.player.position = boss.position + Vector3(0, 0, 1.5)
	game.player.dodge_left = 0.5
	boss._physics_process(0.8)
	boss._physics_process(0.3)
	check.call(game.player.health == game.player.max_health, "Grab respects the knight's timed dodge invulnerability")
	game.player.dodge_left = 0
	boss.receive_hit(game.player.position, 230, 1, 0)
	check.call(boss.phase == 2 and boss.state == "phase_shift" and boss.ledger == null, "Half-health phase transition cancels outgoing attack once")
	boss._physics_process(1.5)
	boss.receive_hit(game.player.position, 1, 1, 0)
	check.call(boss.phase == 2 and boss.state != "phase_shift", "Phase two cannot retrigger")
	boss.begin_attack("burst")
	var danger: Vector3 = boss.burst_at
	game.player.position = danger + Vector3(5, 0.1, 0)
	boss._physics_process(1.41)
	before = game.player.health
	boss._physics_process(0.2)
	check.call(game.player.health == before and not boss.burst_marker.visible, "Delayed ground burst can be escaped and cleans up marker")
	game.player.health = 0
	await game.respawn()
	check.call(game.region.region_id == "region.village" and game.player.health == game.player.max_health, "Boss defeat of player restores activated village checkpoint")
	await game.transition("region.crypt")
	game.player.enabled = false
	boss = game.burial.actor
	boss.set_physics_process(false)
	check.call(boss.health == 420 and boss.phase == 1 and boss.state == "dormant" and not boss.burst_marker.visible, "Re-entry resets unfinished boss HP, phase and hazards")
	game.player.position = game.region.surface_point(Vector3(0, 0.1, 4))
	boss.start()
	boss.receive_hit(game.player.position, 1000, 1, 0)
	check.call(boss.health == 0 and boss.ledger == null and game.region.entrance_barrier.collision_layer == 0, "Boss death clears attacks and releases arena")
	check.call("boss.gravedigger" in game.session.state.campaign.boss_defeated_ids and "seal.burial" not in game.session.state.campaign.broken_seal_ids, "Persistent boss victory and seal break remain separate")
	check.call(game.session.state.character.rank == 2 and game.session.state.character.xp_into_rank == 80 and game.session.state.character.shards == 80, "Actual boss grants exactly specified 180 XP and 80 shards")
	boss.receive_hit(game.player.position, 1000, 1, 0)
	check.call(game.session.state.character.shards == 80, "Repeated damage after boss death cannot duplicate rewards")
	check.call(game.session.load_slot(1), "Victory can be reloaded before breaking seal")
	await game.transition("region.crypt")
	game.player.enabled = false
	check.call(game.burial.actor.health == 0 and game.region.seal.visible and game.session.state.character.shards == 80, "Reload keeps boss dead and unbroken seal available without reward duplication")
	ambience = game.region.get_node("BurialAmbience")
	game.player.position = game.region.points.seal + Vector3(0, 0.1, 1)
	game.interact()
	check.call("seal.burial" in game.session.state.campaign.broken_seal_ids and not game.region.seal.visible, "Real Burial Seal interaction persists and updates prop")
	await tree.process_frame
	check.call(not ambience.seal_tone.playing,"Breaking Burial Seal stops its spatial resonance")
	check.call(not game.burial.break_seal() and game.session.state.character.shards == 80, "Repeated seal interaction cannot grant boss reward")
	await game.transition("region.village", "crypt")
	await tree.process_frame
	check.call(not is_instance_valid(ambience),"Leaving crypt frees its ambience, drip timer and sound players")
	game.player.enabled = false
	for actor in game.enemies:
		actor.set_physics_process(false)
	check.call(game.player.position.z < -30 and game.region.interact_colliders.forest.collision_layer == 0, "Crypt exit arrives safely and removes village forest ward")
	check.call(await game.transition("region.blackwood"), "Broken seal allows actual forest region transition")
	game.player.enabled = false
	check.call(game.region.region_id == "region.blackwood" and game.enemies.size() == 5 and game.region.points.has("forest_exit"), "Expanded forest retains scout trail, return passage and five authored encounters")
	check.call(game.session.state.campaign.quest_states["quest.main.ch01"] == "completed", "Entering Blackwood completes chapter-one objective")
	check.call(await game.transition("region.village", "forest"), "Forest return transition reaches village")
	game.player.enabled = false
	check.call(game.player.position.x == 26 and game.player.position.z == -30, "Forest return spawn avoids immediate retrigger")
	check.call(game.session.load_slot(1), "Completed route can reload")
	await game.transition(game.session.state.recovery.region_id)
	game.player.enabled = false
	check.call(game.region.region_id == "region.village" and game.region.interact_colliders.forest.collision_layer == 0 and game.session.state.character.shards == 80, "Reload retains chapter, open ward and one-time reward at village checkpoint")
	check.call(Schema.validate(game.session.state) == "", "Boss/seal/forest campaign snapshot validates")
	for actor in game.enemies:
		actor.sounds.stop()
	game.ui_sound.stop()
	game.player.sounds.stop()
	game.pause(true)
	await tree.create_timer(0.2, true).timeout
	game.queue_free()
	await tree.process_frame
