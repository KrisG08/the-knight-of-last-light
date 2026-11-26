extends RefCounted
const Store = preload("res://game/persistence/infrastructure/save_store.gd")
const Session = preload("res://game/campaign/application/campaign_session.gd")
const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const History = preload("res://game/persistence/domain/journey_history.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	var folder := "user://journey-regression/"+str(Time.get_ticks_usec())
	var store := Store.new(folder)
	var session := Session.new(store)
	session.begin(store.next_journey_id(),false)
	check.call(session.state.schema_version == 8 and Schema.validate(session.state) == "", "New journey starts with validated version-eight history")
	session.visit("region.village")
	check.call(session.record_enemy("region.village/soldier/26,0,-1","Fallen Soldier","region.village"), "Ordinary enemy victory enters journey history")
	session.record_enemy("region.village/soldier/26,0,-1","Fallen Soldier","region.village")
	session.act("DefeatBoss","boss.gravedigger")
	session.act("BreakSeal","seal.burial")
	session.act("VisitBlackwood")
	session.save_progress()
	session.save_progress()
	var original := FileAccess.get_file_as_string(store.path_for(1))
	for index in range(5): session.begin(store.next_journey_id(),false)
	check.call(store.journey_ids().size() == 6 and session.state.slot_id == 6, "More than three journeys are allocated without overwriting")
	check.call(FileAccess.get_file_as_string(store.path_for(1)) == original, "Starting later journeys preserves the first save byte-for-byte")
	var restarted := Session.new(Store.new(folder))
	check.call(restarted.load_slot(1), "A fresh store/session reloads journey from disk")
	check.call(History.enemy_total(restarted.state) == 2 and "region.village" in restarted.state.journey.visited_region_ids, "Exploration and repeat victory counts survive restart")
	check.call("boss.gravedigger" in restarted.state.campaign.boss_defeated_ids and "seal.burial" in restarted.state.campaign.broken_seal_ids and restarted.state.campaign.quest_states["quest.main.ch01"] == "completed", "Boss, seal and quest completion survive restart together")
	check.call(History.describe(restarted.state).contains("DEFEATED · Gravedigger") and History.describe(restarted.state).contains("defeated 2 times"), "Progress view names defeated bosses and ordinary enemies")
	var legacy := Rules.new_game(20)
	legacy = Rules.apply_action(legacy,"DefeatBoss","boss.gravedigger").next_state
	store.save(legacy)
	var legacy_on_disk: Dictionary = store.load_slot(20).state
	var migrated := Session.new(Store.new(folder))
	check.call(migrated.load_slot(20) and migrated.state.schema_version == 8 and migrated.state.journey.legacy_history, "Legacy journeys upgrade without inventing old enemy kills")
	check.call(migrated.state.campaign == legacy_on_disk.campaign and migrated.state.character == legacy_on_disk.character, "Migration preserves old world facts, boss rewards and character data")
	migrated.save_progress()
	check.call(store.read_file(store.path_for(20)+".bak",20).state.schema_version == 1, "Migration preserves original legacy save as backup")
	var invalid := restarted.state.duplicate(true)
	invalid.journey.enemy_defeats.values()[0].count = -1
	check.call(Schema.validate(invalid) != "", "Malformed enemy defeat counts are rejected")
	store.fail_stage = "before_promote"
	restarted.store = store
	restarted.record_enemy("region.village/hound/1","Grave Hound","region.village")
	check.call(not restarted.save_progress() and restarted.dirty, "Failed progress write remains dirty and retryable")
	store.fail_stage = ""
	check.call(restarted.save_progress() and History.enemy_total(store.load_slot(1).state) == 3, "Retry commits the existing victory once")
	var file := FileAccess.open(store.path_for(1),FileAccess.WRITE)
	file.store_string("{broken")
	file.close()
	check.call(Store.new(folder).load_slot(1).message.begins_with("Recovered"), "Journey catalog can recover a corrupt save from its backup")
	var future := legacy.duplicate(true)
	future.slot_id = 25
	future.schema_version = 99
	file = FileAccess.open(store.path_for(25),FileAccess.WRITE)
	file.store_string(JSON.stringify(future))
	file.close()
	check.call(store.next_journey_id() == 26 and not store.load_slot(25).ok, "Future-version files reserve their IDs and are never reused")
	var endgame: Dictionary = preload("res://tests/finale_checks.gd").citadel_state()
	History.ensure(endgame)
	endgame = Rules.apply_action(endgame,"DefeatBoss","boss.maldrek").next_state
	endgame = Rules.apply_action(endgame,"CompleteCampaign").next_state
	check.call(endgame.schema_version == 8 and endgame.has("journey") and Schema.validate(endgame) == "", "Final boss and ending preserve the upgraded journey history schema")
	await runtime(tree,check)

static func runtime(tree: SceneTree, check: Callable) -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning: await tree.physics_frame
	check.call(game.menu.has_method("show_actions") and game.menu.has_method("resume"), "Laptop and Android construct the same v0.5 frontend")
	check.call(not is_instance_valid(game.mobile_controls), "Laptop keeps keyboard/mouse controls without a touch overlay")
	await game.start_selected()
	await game.transition("region.village")
	game.player.enabled = false
	var enemy: CharacterBody3D = game.enemies[0]
	enemy.set_physics_process(false)
	enemy.receive_hit(game.player.position,10000,1,0)
	check.call(History.enemy_total(game.session.state) == 1, "Real ordinary-enemy defeat commits history through runtime signal")
	game.enemy_defeated(enemy)
	check.call(History.enemy_total(game.session.state) == 1, "Duplicate defeat signal cannot duplicate history or reward in one life")
	var first: int = game.session.state.slot_id
	game.request_new()
	while game.transitioning: await tree.physics_frame
	await tree.process_frame
	check.call(game.session.state.slot_id != first and game.session.store.catalog().size() == 2, "New Journey UI allocates a second independent saved campaign")
	check.call(History.enemy_total(game.session.store.load_slot(first).state) == 1, "Creating a new journey leaves prior world progress in the library")
	# A real temporary store exercises disk failure rather than the memory adapter.
	game.session.store = Store.new("user://save-menu-regression/"+str(Time.get_ticks_usec()))
	game.session.save_progress()
	game.pause(true)
	game.session.store.fail_stage = "before_promote"
	game.session.dirty = true
	game.quit_button.pressed.emit()
	check.call(game.session.active and game.started and game.session.dirty and tree.paused, "Failed save-and-menu keeps the live journey available for retry")
	game.session.store.fail_stage = ""
	var returning_slot: int = game.session.state.slot_id
	game.quit_button.pressed.emit()
	await tree.process_frame
	await tree.process_frame
	var backdrop=game.menu.living_scene
	var backdrop_visible: bool=backdrop.is_visible_in_tree() and (backdrop.landscape.is_visible_in_tree() or (is_instance_valid(backdrop.movie) and backdrop.movie.is_visible_in_tree() and backdrop.movie.get_video_texture().get_width()>0))
	check.call(not game.session.active and not game.started and game.menu.visible and tree.paused and not game.player.enabled and backdrop_visible, "Save-and-menu button returns to the title screen without quitting or resuming gameplay")
	check.call(game.session.store.load_slot(returning_slot).ok and not game.load_button.disabled, "Returned journey is saved and Continue is available")
	game.load_button.pressed.emit()
	while game.transitioning: await tree.physics_frame
	await tree.process_frame
	check.call(game.session.active and game.session.state.slot_id == returning_slot and game.player.enabled and not tree.paused, "Continue reloads the same journey after returning to the title screen")
	game.queue_free()
	tree.paused = false
	await tree.process_frame
