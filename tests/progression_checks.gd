extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const Store = preload("res://game/persistence/infrastructure/save_store.gd")
const Session = preload("res://game/campaign/application/campaign_session.gd")

static func rules(check: Callable) -> void:
	var state := Rules.new_game()
	check.call(Schema.validate(state) == "", "New campaign validates")
	check.call(not Rules.gate_access("gate.training", state).allowed, "Training passage starts locked")
	check.call(not Rules.apply_action(state, "BreakSeal", "seal.burial").accepted, "Seal requires defeated guardian")
	check.call(not Rules.apply_action(state, "DefeatBoss", "unknown").accepted, "Unknown boss rejected")
	var result := Rules.apply_action(state, "DefeatBoss", "boss.gravedigger")
	state = result.next_state
	check.call(state.character.rank == 2 and state.character.xp_into_rank == 80 and state.character.shards == 80, "Boss reward matches fixture and rank threshold")
	check.call(not Rules.apply_action(state, "DefeatBoss", "boss.gravedigger").accepted, "Repeated boss cannot duplicate reward")
	check.call(not Rules.gate_access("gate.village_to_blackwood", state).allowed, "Boss death alone does not unlock passage")
	state = Rules.apply_action(state, "BreakSeal", "seal.burial").next_state
	check.call(Rules.gate_access("gate.village_to_blackwood", state).allowed, "Explicit seal break opens passage")
	check.call(not Rules.apply_action(state, "BreakSeal", "seal.burial").accepted, "Repeated seal break rejected")
	check.call(not Rules.gate_access("gate.peaks_to_citadel", state).allowed, "Citadel requires all four seals")
	check.call(not Rules.apply_action(state, "CompleteCampaign").accepted, "Ending rejects missing prerequisites")
	check.call(not Rules.apply_action(Rules.new_game(), "UpgradeWeapon").accepted, "Unaffordable upgrade rejected")
	state = Rules.apply_action(state, "UpgradeWeapon").next_state
	check.call(state.character.weapon_tier == 1 and state.character.shards == 20 and Rules.sword_damage(state) == 26, "Upgrade spends exact price and changes damage")
	var character: Dictionary = Rules.new_game().character
	Rules.grant_xp(character, 450)
	check.call(character.rank == 4 and character.xp_into_rank == 0, "Large reward crosses multiple rank thresholds")
	for name in ["save-v1-new-game.json", "save-v1-boss-defeated-seal-intact.json"]:
		check.call(Schema.validate(JSON.parse_string(FileAccess.get_file_as_string("res://examples/" + name))) == "", "Pack save fixture validates: " + name)
	for defect in ["duplicate", "type", "future", "unknown_id", "contradiction", "spawn"]:
		var bad := Rules.new_game()
		match defect:
			"duplicate": bad.campaign.reward_claim_ids = ["reward.training.victory", "reward.training.victory"]
			"type": bad.character.rank = "one"
			"future": bad.schema_version = 99
			"unknown_id": bad.character.weapon_id = "res://arbitrary.tres"
			"contradiction": bad.campaign.broken_seal_ids = ["seal.burial"]
			"spawn": bad.recovery.spawn_id = "missing"
		check.call(Schema.validate(bad) != "", "Invalid save rejected: " + defect)

static func files(check: Callable) -> void:
	# Dedicated disposable workspace folder, never user://saves.
	var directory := "res://.tools/test-saves/" + str(Time.get_ticks_usec())
	var store := Store.new(directory)
	var initial := Rules.new_game(1)
	check.call(store.save(initial).ok, "Windows file save creates primary")
	var victory: Dictionary = Rules.apply_action(initial, "CompleteTraining").next_state
	check.call(store.save(victory).ok, "Windows replacement preserves backup and promotes primary")
	check.call(store.load_slot(1).state.character.rank == 2, "Save round-trip preserves reward and rank")
	check.call(store.read_file(store.path_for(1) + ".bak", 1).state.character.rank == 1, "Backup is previous known-good state")
	var file := FileAccess.open(store.path_for(1), FileAccess.WRITE)
	file.store_string("{truncated")
	file.close()
	var recovered := store.load_slot(1)
	check.call(recovered.ok and recovered.state.character.rank == 1 and recovered.message.begins_with("Recovered"), "Corrupt primary explicitly recovers backup")
	check.call(store.save(victory).ok, "Saving after recovery preserves valid backup")
	check.call(store.read_file(store.path_for(1) + ".bak", 1).ok, "Recovery does not replace backup with corrupt primary")
	file = FileAccess.open(store.path_for(1), FileAccess.WRITE)
	file.store_string("{}")
	file.close()
	check.call(store.load_slot(1).ok, "Missing schema is corruption eligible for backup recovery")
	var future := initial.duplicate(true)
	future.schema_version = 99
	file = FileAccess.open(store.path_for(1), FileAccess.WRITE)
	file.store_string(JSON.stringify(future))
	file.close()
	var before := FileAccess.get_file_as_string(store.path_for(1))
	check.call(not store.load_slot(1).ok and not store.save(initial).ok, "Future schema blocks load and overwrite")
	check.call(FileAccess.get_file_as_string(store.path_for(1)) == before, "Future save remains byte-for-byte intact")
	var session := Session.new(store)
	session.begin(2)
	store.fail_stage = "before_promote"
	check.call(session.act("CompleteTraining") and session.dirty, "Write failure leaves accepted action dirty")
	check.call(session.state.character.shards == 60, "Failed save retains reward in current session")
	check.call(store.read_file(store.path_for(2), 2).state.character.rank == 1, "Failed promotion preserves previous primary")
	check.call(not session.act("CompleteTraining") and session.state.character.shards == 60, "Retry cannot grant finite reward again")
	store.fail_stage = ""
	check.call(session.save_progress() and not session.dirty, "Save retry commits existing state")
	check.call(store.load_slot(2).state.character.shards == 60, "Retried reward persists once")
	check.call(store.save(Rules.new_game(3)).ok and store.load_slot(2).state.character.shards == 60, "Independent slot writes preserve other slots")
	check.call(not store.load_slot(0).ok, "Out-of-range slot rejected")
	check.call(not store.read_file(store.path_for(3), 2).ok, "Slot identity mismatch rejected")

static func runtime(game: Node, check: Callable) -> void:
	var progress = game.progression
	progress.session.begin(3)
	game.reset_training()
	game.player.enabled = false
	game.enemy.set_physics_process(false)
	game.enemy.receive_hit(game.player.position, 1000, 1, 0)
	check.call(progress.session.state.character.rank == 2 and game.player.max_health == 105 and game.player.health == 105, "Actual soldier victory awards rank and gained maximum HP")
	check.call(game.enemy.health == 0 and progress.gate.collision_layer == 1, "Victory leaves physical gate locked until seal interaction")
	game.player.combat.state = "locomotion"
	game.player.position = progress.SEAL_POSITION
	progress.interact()
	check.call(progress.gate.collision_layer == 0 and not progress.gate.visible, "Real seal interaction removes passage collision")
	game.player.position = progress.ANVIL_POSITION
	progress.upgrade()
	check.call(game.player.weapon_damage == 26 and progress.session.state.character.shards == 0, "Actual anvil upgrade applies runtime sword damage")
	game.player.health = 1
	progress.slot_picker.select(2)
	check.call(progress.load_selected(), "Saved training journey can be loaded via menu controller")
	check.call(game.player.health == 105 and game.player.healing_charges == 3 and game.enemy.health == 110, "Load restores safe checkpoint resources and resets ordinary soldier")
	check.call(game.player.weapon_damage == 26 and progress.gate.collision_layer == 0, "Reload retains sword upgrade and derived open gate")
	check.call(not progress.session.act("CompleteTraining"), "Load retains finite reward claim")
	game.enemy.receive_hit(game.player.position, 1000, 1, 0)
	check.call(progress.session.state.character.xp_into_rank == 10 and progress.session.state.character.shards == 5, "Actual respawn grants small repeatable reward")
