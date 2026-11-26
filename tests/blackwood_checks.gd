extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const Store = preload("res://game/persistence/infrastructure/save_store.gd")

static func rules(check: Callable) -> void:
	var state := Rules.new_game()
	check.call(not Rules.apply_action(state, "ActivateCheckpoint", "checkpoint.blackwood").accepted, "Blackwood checkpoint requires discovered forest")
	check.call(not Rules.apply_action(state, "DefeatBoss", "boss.thorn_beast").accepted, "Thorn Beast victory rejects undiscovered region")
	for action in [["DefeatBoss", "boss.gravedigger"], ["BreakSeal", "seal.burial"], ["VisitBlackwood", ""], ["ActivateCheckpoint", "checkpoint.blackwood"], ["OpenForestShortcut", ""]]:
		state = Rules.apply_action(state, action[0], action[1]).next_state
	check.call(state.schema_version == 3 and state.recovery.region_id == "region.blackwood" and Schema.validate(state) == "", "Forest checkpoint/shortcut upgrades valid copied state to schema three")
	check.call(not Rules.apply_action(state, "VisitOrder").accepted and not Rules.gate_access("gate.blackwood_to_order", state).allowed, "Order passage is locked by Root Seal")
	state = Rules.apply_action(state, "DefeatBoss", "boss.thorn_beast").next_state
	check.call(state.character.shards == 190 and state.character.rank == 3 and state.character.xp_into_rank == 170, "Thorn Beast grants authored 240 XP / 110 shards once")
	check.call(not Rules.apply_action(state, "DefeatBoss", "boss.thorn_beast").accepted and not Rules.gate_access("gate.blackwood_to_order", state).allowed, "Repeated victory cannot duplicate reward or skip seal")
	state = Rules.apply_action(state, "BreakSeal", "seal.root").next_state
	state = Rules.apply_action(state, "VisitOrder").next_state
	check.call(state.campaign.quest_states["quest.main.ch02"] == "completed" and Schema.validate(state) == "", "Order discovery completes chapter two only after Root Seal")
	var misleading := state.duplicate(true)
	misleading.schema_version = 2
	check.call(Schema.validate(misleading) != "", "Forest chapter progress cannot masquerade as older schema")
	state = Rules.apply_action(state, "MeetLyra").next_state
	check.call(state.schema_version == 3, "Companion quest action cannot downgrade newer chapter schema")
	var directory := "res://.tools/test-blackwood/" + str(Time.get_ticks_usec())
	var store := Store.new(directory)
	check.call(store.save(Rules.new_game()).ok and store.save(state).ok, "Version-three state promotes over legacy save")
	var result := store.load_slot(1)
	check.call(result.ok and result.state.recovery.checkpoint_id == "checkpoint.blackwood" and Schema.validate(result.state) == "", "Forest checkpoint, rewards and order facts survive real JSON round-trip")
	check.call(store.read_file(store.path_for(1) + ".bak", 1).state.schema_version == 1, "Chapter schema promotion preserves known-good legacy backup")

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
	for hostile in game.enemies:
		hostile.set_physics_process(false)
	check.call(game.enemies.size() == 5 and game.region.points.has("grove") and game.region.points.has("order_gate"), "Expanded forest constructs five encounters, shrine and Order route")
	var assets = preload("res://game/presentation/real_assets.gd")
	var b: Mesh = assets.meshes["pine_sapling_small@8000"].pine_sapling_small_b
	var c: Mesh = assets.meshes["pine_sapling_small@4000"].pine_sapling_small_c
	check.call(b.surface_get_array_index_len(1)<=24000 and c.surface_get_array_index_len(1)<=12000,"Later forest canopies honor their rendering budgets")
	check.call(b!=assets.meshes.pine_sapling_small.pine_sapling_small_b and c!=assets.meshes.pine_sapling_small.pine_sapling_small_c,"Later forest optimization cannot mutate the starting/village tree meshes")
	var map: RID = game.region.navigation.get_navigation_map()
	var path := NavigationServer3D.map_get_path(map, Vector3(0, 0, 10), game.region.points.grove, true)
	check.call(path.size() >= 3 and path[path.size() - 1].distance_to(game.region.points.grove) < 2, "Navigation connects scout trail to root shrine around blocked ridge")
	check.call(not await game.transition("region.order"), "Direct Order transition enforces locked Root Seal")
	game.player.position = game.region.points.checkpoint + Vector3(-2, 0.1, 0)
	check.call(game.rest() and game.session.state.recovery.checkpoint_id == "checkpoint.blackwood", "Actual forest lantern sets durable safe recovery")
	game.player.enabled = false
	game.player.position = game.region.points.forest_shortcut
	game.interact()
	check.call(game.region.forest_shortcut.collision_layer == 0, "North-side root bar interaction opens shortcut")
	await game.transition("region.grove")
	game.player.enabled = false
	var boss = game.forest_chapter.actor
	boss.set_physics_process(false)
	check.call(boss.health == 500 and boss.state == "dormant" and game.region.entrance_barrier.collision_layer == 0, "Grove constructs dormant full-health Thorn Beast with open entrance")
	check.call(not game.forest_chapter.break_seal(), "Living Thorn Beast prevents Root Seal break")
	game.player.position = game.region.surface_point(Vector3(0, 0.1, 5))
	boss._physics_process(0.016)
	check.call(game.forest_chapter.active() and game.region.entrance_barrier.collision_layer == 1, "Entering grove starts guardian encounter and blocks exit")
	check.call(not game.rest(), "Grove fight cannot rest at a fake checkpoint")
	game.player.position = boss.position + Vector3(0, 0, 3)
	boss.begin_attack("lunge")
	var hp: float = game.player.health
	boss._physics_process(0.9)
	check.call(boss.state == "windup" and game.player.health == hp, "Lunge telegraph cannot deal early damage")
	game.player.position = boss.position + Vector3(5, 0, 1)
	boss._physics_process(0.06)
	var origin: Vector3 = boss.position
	boss.set_physics_process(true)
	for tick in range(20):
		await tree.physics_frame
	boss.set_physics_process(false)
	check.call(boss.position.distance_to(origin) > 1 and game.player.health == hp, "Locked-direction lunge physically advances and can be sidestepped")
	boss._physics_process(0.2)
	game.player.position = boss.position + Vector3(0, 0, 2)
	boss.begin_attack("sweep")
	boss._physics_process(1.11)
	boss._physics_process(0.25)
	check.call(game.player.health < hp, "Thorn sweep hits real knight in active window")
	var after: float = game.player.health
	boss._physics_process(0.1)
	check.call(game.player.health == after, "Sweep recovery cannot repeat damage")
	game.player.health = 0
	await game.respawn()
	check.call(game.region.region_id == "region.blackwood" and game.player.health == game.player.max_health, "Losing boss restores activated Blackwood lantern")
	await game.transition("region.grove")
	game.player.enabled = false
	boss = game.forest_chapter.actor
	boss.set_physics_process(false)
	check.call(boss.health == 500 and boss.state == "dormant" and boss.attack_index == 0, "Re-entering unfinished grove resets guardian and attack sequence")
	boss.start()
	var before_shards: int = game.session.state.character.shards
	boss.receive_hit(game.player.position, 1000, 1, 0)
	check.call(boss.health == 0 and boss.ledger == null and game.region.entrance_barrier.collision_layer == 0, "Thorn Beast death clears damage and exit barrier")
	check.call(game.session.state.character.shards == before_shards + 110 and "seal.root" not in game.session.state.campaign.broken_seal_ids, "Real victory commits reward but leaves Root Seal intact")
	check.call(game.session.load_slot(1), "Guardian victory reloads before Root Seal break")
	await game.transition("region.grove")
	game.player.enabled = false
	check.call(game.forest_chapter.actor.health == 0 and game.region.seal.visible and game.session.state.character.shards == before_shards + 110, "Reload preserves dead guardian, intact seal and reward once")
	game.player.position = game.region.points.root_seal + Vector3(0, 0.1, 1)
	game.interact()
	check.call("seal.root" in game.session.state.campaign.broken_seal_ids and not game.region.seal.visible, "Explicit Root Seal interaction updates durable and visible state")
	check.call(not game.forest_chapter.break_seal() and game.session.state.character.shards == before_shards + 110, "Repeated Root Seal cannot grant reward twice")
	await game.transition("region.blackwood", "grove")
	game.player.enabled = false
	for hostile in game.enemies:
		hostile.set_physics_process(false)
	check.call(game.player.position.z == -55 and game.region.order_ward.collision_layer == 0 and game.region.forest_shortcut.collision_layer == 0, "Return arrives outside shrine with both unlocked routes reflected")
	check.call(await game.transition("region.order"), "Broken Root Seal permits actual Order entrance transition")
	game.player.enabled = false
	check.call(game.region.region_id == "region.order" and game.region.points.has("order_exit") and game.session.state.campaign.quest_states.get("quest.main.ch02") == "completed", "Playable ruin forecourt and chapter-two completion exist")
	check.call(await game.transition("region.blackwood", "order_gate"), "Order return transition restores forest")
	game.player.enabled = false
	check.call(game.player.position.x == 22 and game.player.position.z == -63, "Order return spawn avoids immediate transition retrigger")
	check.call(game.session.load_slot(1), "Completed forest chapter reloads")
	await game.transition(game.session.state.recovery.region_id)
	game.player.enabled = false
	check.call(game.region.region_id == "region.blackwood" and game.region.order_ward.collision_layer == 0 and Schema.validate(game.session.state) == "", "Reload restores forest checkpoint, open gate and valid chapter state")
	await game.transition("region.refuge")
	check.call(game.region.refuge_echo.text.contains("ROOT WARD HAS FALLEN"), "Returning refuge reflects durable Root Seal change")
	for hostile in game.enemies:
		hostile.sounds.stop()
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.pause(true)
	await tree.create_timer(0.2, true).timeout
	game.queue_free()
	await tree.process_frame


