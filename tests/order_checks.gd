extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const Store = preload("res://game/persistence/infrastructure/save_store.gd")

static func order_state() -> Dictionary:
	var state := Rules.new_game()
	for command in [["DefeatBoss", "boss.gravedigger"], ["BreakSeal", "seal.burial"], ["VisitBlackwood", ""], ["DefeatBoss", "boss.thorn_beast"], ["BreakSeal", "seal.root"], ["VisitOrder", ""]]:
		state = Rules.apply_action(state, command[0], command[1]).next_state
	return state

static func rules(check: Callable) -> void:
	check.call(not Rules.apply_action(Rules.new_game(), "MeetCael").accepted and not Rules.apply_action(Rules.new_game(), "ActivateCheckpoint", "checkpoint.order").accepted, "Cael and Order checkpoint require discovered ruins")
	var state := order_state()
	check.call(not Rules.apply_action(state, "SetActiveCompanion", "ally.cael").accepted and not Rules.apply_action(state, "RecruitAlly", "ally.cael").accepted, "Cael cannot be selected or recruited by proximity")
	state = Rules.apply_action(state, "MeetCael").next_state
	check.call(not Rules.apply_action(state, "ReadExpedition").accepted and not Rules.apply_action(state, "RecruitAlly", "ally.cael").accepted, "Meeting Cael does not skip sentries or record")
	state = Rules.apply_action(state, "ClearOrderCourtyard").next_state
	state = Rules.apply_action(state, "ReadExpedition").next_state
	check.call(not Rules.apply_action(state, "ReadExpedition").accepted and Schema.validate(state) == "", "Recovered expedition record persists once in valid schema four")
	var shards: int = state.character.shards
	state = Rules.apply_action(state, "RecruitAlly", "ally.cael").next_state
	check.call(state.character.shards == shards + 25 and state.campaign.active_companion_id == "ally.cael" and Schema.validate(state) == "", "Explicit Cael recruitment atomically grants reward and active selection")
	check.call(not Rules.apply_action(state, "RecruitAlly", "ally.cael").accepted, "Repeated Cael recruitment rejects duplicate reward")
	var invalid := state.duplicate(true)
	invalid.schema_version = 3
	check.call(Schema.validate(invalid) != "", "New companion progress cannot masquerade as schema three")
	invalid = state.duplicate(true)
	invalid.campaign.pickup_claim_ids.erase("document.order.expedition")
	check.call(Schema.validate(invalid) != "", "Cael recruitment without recovered record is invalid")
	for command in [["MeetLyra", ""], ["ClearForestTrail", ""], ["ClaimPickup", "pickup.lyra_satchel"], ["RecruitAlly", "ally.lyra"], ["SetActiveCompanion", "ally.cael"], ["OpenForestShortcut", ""], ["ActivateCheckpoint", "checkpoint.order"]]:
		state = Rules.apply_action(state, command[0], command[1]).next_state
	check.call(state.schema_version == 4 and state.recovery.region_id == "region.order" and Schema.validate(state) == "", "Legacy companion/forest actions preserve version four and valid Order recovery")
	var store := Store.new("res://.tools/test-order/" + str(Time.get_ticks_usec()))
	check.call(store.save(order_state()).ok and store.save(state).ok, "Version-four promotion preserves a known-good version-three backup")
	var loaded: Dictionary = store.load_slot(1)
	check.call(loaded.ok and loaded.state.campaign.active_companion_id == "ally.cael" and loaded.state.recovery.checkpoint_id == "checkpoint.order" and Schema.validate(loaded.state) == "", "Cael selection and Order recovery survive real JSON round-trip")
	check.call(store.read_file(store.path_for(1) + ".bak", 1).state.schema_version == 3, "Legacy backup remains readable after Order promotion")

static func run(tree: SceneTree, check: Callable) -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	game.session.begin(1, false)
	game.session.state = order_state()
	game.started = true
	check.call(await game.transition("region.order"), "Actual expanded Order transition succeeds")
	game.pause(false)
	game.player.enabled = false
	for guard in game.enemies:
		guard.set_physics_process(false)
	check.call(game.enemies.size() == 3 and game.region.points.has("expedition") and game.region.cael.visible, "Order builds three sentries, memorial record and unrecruited Cael")
	var path := NavigationServer3D.map_get_path(game.region.navigation.get_navigation_map(), game.region.points.spawn, game.region.points.expedition, true)
	check.call(path.size() > 3 and path[path.size() - 1].distance_to(game.region.points.expedition) < 2, "Authored navigation connects forecourt to memorial around barracks")
	game.player.position = game.region.points.checkpoint + Vector3(-2, 0.1, 0)
	check.call(game.rest() and game.session.state.recovery.region_id == "region.order", "Order lantern becomes durable checkpoint")
	game.player.enabled = false
	game.player.position = game.region.points.cael + Vector3(0, 0.1, 1)
	game.interact()
	check.call(tree.paused and "ally.cael.met" in game.session.state.campaign.facts, "Cael interaction opens real quest dialogue and saves encounter")
	game.choices.get_child(0).pressed.emit()
	check.call(tree.paused and "ally.cael" not in game.session.state.campaign.recruited_ally_ids, "Premature join choice leaves quest pending without reward")
	game.leave_dialogue()
	for guard in game.order_chapter.guards:
		guard.receive_hit(game.player.position, 1000, 1, 0)
	check.call("order.courtyard_safe" in game.session.state.campaign.facts, "Three actual sentry defeats commit courtyard quest fact")
	game.player.position = game.region.points.expedition + Vector3(0, 0.1, 1)
	game.interact()
	check.call(tree.paused and not game.region.expedition.visible and game.dialogue_text.text.contains("Cael left to seek help"), "Actual record interaction shows expedition story and claims persistent document")
	game.leave_dialogue()
	game.player.position = game.region.points.cael + Vector3(0, 0.1, 1)
	game.interact()
	var shards: int = game.session.state.character.shards
	game.choices.get_child(0).pressed.emit()
	var cael = game.journey.follower
	check.call(is_instance_valid(cael) and cael.ally_id == "ally.cael" and cael.health == 95 and not game.region.cael.visible and game.session.state.character.shards == shards + 25, "Join choice creates Cael follower, removes static duplicate and commits one-time reward")
	cael.set_physics_process(false)
	cael.receive_hit(game.player.position, 1000, 1, 0)
	check.call(cael.state == "downed" and not cael.set_order("follow"), "Cael is downed rather than permanently killed")
	game.player.position = game.region.points.checkpoint + Vector3(-2, 0.1, 0)
	check.call(game.rest() and cael.health == 95 and cael.state == "follow", "Order lantern safely restores downed Cael")
	for guard in game.enemies:
		guard.set_physics_process(false)
	game.enemies[0].state = "chase"
	check.call(not game.journey.choose("") and game.session.state.campaign.active_companion_id == "ally.cael", "Companion switching rejects active combat")
	game.enemies[0].state = "idle"
	for command in [["MeetLyra", ""], ["ClearForestTrail", ""], ["ClaimPickup", "pickup.lyra_satchel"], ["RecruitAlly", "ally.lyra"]]:
		game.session.act(command[0], command[1])
	game.sync_stats()
	game.journey.refresh_selection()
	check.call(game.journey.follower.ally_id == "ally.lyra" and game.journey.follower.health == 70 and tree.get_nodes_in_group("companions").size() == 1, "Switch to Lyra replaces Cael with exactly one correct follower")
	check.call(game.journey.choose("ally.cael") and game.journey.follower.ally_id == "ally.cael" and tree.get_nodes_in_group("companions").size() == 1, "Selecting Cael again replaces Lyra without duplicate actors")
	check.call(game.journey.toggle_order() and game.journey.follower.order == "hold", "Cael obeys shared hold command")
	await game.transition("region.grove")
	game.player.enabled = false
	check.call(not is_instance_valid(game.journey.follower) and game.journey.status.contains("Sir Cael waits outside"), "Cael obeys guardian restriction while preserving selected identity")
	await game.transition("region.refuge")
	game.player.enabled = false
	check.call(not game.region.cael.visible and game.region.lyra.visible and game.journey.follower.ally_id == "ally.cael", "Refuge shows waiting Lyra and active Cael without static duplicates")
	game.journey.choose("ally.lyra")
	check.call(game.region.cael.visible and not game.region.lyra.visible, "Switching at refuge updates both waiting NPCs")
	game.journey.choose("ally.cael")
	await game.start_selected(true)
	game.player.enabled = false
	check.call(game.region.region_id == "region.order" and game.journey.follower.ally_id == "ally.cael" and game.journey.follower.health == 95 and Schema.validate(game.session.state) == "", "Actual load route accepts Order checkpoint and reconstructs selected Cael")
	game.show_journal()
	var journal_actions: Array[String] = []
	for action in game.choices.get_children():
		if action is Button: journal_actions.append(action.text)
	check.call(game.dialogue_text.text.contains("Sir Cael · recruited") and "Lyra: follow / wait at refuge" in journal_actions and "Sir Cael: follow / wait at refuge" in journal_actions and "Read recovered expedition record" in journal_actions, "Journal exposes both recruited companion choices and recovered record")
	game.ui_sound.stop()
	game.player.sounds.stop()
	for guard in game.enemies:
		guard.sounds.stop()
	await tree.create_timer(0.2, true).timeout
	game.queue_free()
	await tree.process_frame
