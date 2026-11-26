extends RefCounted
const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const Store = preload("res://game/persistence/infrastructure/save_store.gd")

static func citadel_state() -> Dictionary:
	var state: Dictionary = preload("res://tests/peaks_checks.gd").peaks_state()
	for command in [["DefeatBoss","boss.iron_warden"],["BreakSeal","seal.forge"],["VisitCitadel",""]]:
		state = Rules.apply_action(state,command[0],command[1]).next_state
	return state

static func rules(check: Callable) -> void:
	check.call(not Rules.apply_action(Rules.new_game(),"DefeatBoss","boss.maldrek").accepted and not Rules.apply_action(citadel_state(),"CompleteCampaign").accepted,"Finale rejects unknown wizard encounter and ritual before victory")
	var state := citadel_state()
	check.call(not Rules.apply_action(state,"FreePrisoners").accepted,"Prison rescue requires jailer defeat")
	for command in [["ClearPrison",""],["FreePrisoners",""],["LearnRitual",""],["ActivateCheckpoint","checkpoint.citadel"],["DefeatBoss","boss.maldrek"]]:
		state = Rules.apply_action(state,command[0],command[1]).next_state
	check.call(state.schema_version == 7 and not state.campaign.completed and Schema.validate(state) == "","Wizard victory records reward without cleansing or credits")
	check.call(not Rules.apply_action(state,"FreePrisoners").accepted and not Rules.apply_action(state,"DefeatBoss","boss.maldrek").accepted,"Prison and wizard rewards are finite")
	var legacy := state.duplicate(true)
	state = Rules.apply_action(state,"CompleteCampaign").next_state
	check.call(state.campaign.completed and state.recovery.spawn_id == "spawn.refuge.ending" and Schema.validate(state) == "","Explicit ritual atomically completes chapter and restores refuge recovery")
	check.call(not Rules.apply_action(state,"CompleteCampaign").accepted,"Completed ritual rejects repeated completion")
	state = Rules.apply_action(state,"ActivateCheckpoint","checkpoint.peaks").next_state
	check.call(state.recovery.region_id == "region.refuge" and state.schema_version == 7,"Postgame rest keeps completed-save recovery at refuge")
	var invalid := state.duplicate(true)
	invalid.schema_version = 6
	check.call(Schema.validate(invalid) != "","Finale cannot masquerade as older schema")
	var store := Store.new("res://.tools/test-finale/"+str(Time.get_ticks_usec()))
	check.call(store.save(legacy).ok and store.save(state).ok and store.load_slot(1).state.campaign.completed,"Completed campaign survives actual JSON promotion and reload")
	check.call(not store.read_file(store.path_for(1)+".bak",1).state.campaign.completed,"Ritual promotion preserves prior uncompleted victory backup")

static func run(tree: SceneTree, check: Callable) -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	game.session.begin(1,false)
	game.started = true
	check.call(not await game.transition("region.ritual"),"Undiscovered ritual chamber rejects direct travel")
	game.session.state = citadel_state()
	for command in [["MeetLyra",""],["ClearForestTrail",""],["ClaimPickup","pickup.lyra_satchel"],["RecruitAlly","ally.lyra"]]:
		game.session.act(command[0],command[1])
	await game.transition("region.citadel")
	game.pause(false)
	game.player.enabled = false
	for enemy in game.enemies:
		enemy.set_physics_process(false)
	check.call(game.enemies.size() == 3 and game.region.points.has("ritual_lore"),"Citadel constructs gatehouse, jailer and ritual approach")
	game.player.position = game.region.points.checkpoint+Vector3(-2,0.1,0)
	check.call(game.rest() and game.session.state.recovery.region_id == "region.citadel","Citadel lantern becomes durable checkpoint")
	game.player.enabled = false
	game.enemies[1].receive_hit(game.player.position,1000,1,0)
	game.player.position = game.region.points.prisoners+Vector3(0,0.1,1)
	game.interact()
	check.call("citadel.prisoners_freed" in game.session.state.campaign.facts and game.region.prison_bars.collision_layer == 0,"Jailer defeat and actual prison interaction free captives")
	game.citadel_chapter.read_lore()
	check.call(tree.paused and game.dialogue_text.text.contains("His death alone"),"Ritual inscription explains separate curse-breaking interaction")
	game.leave_dialogue()
	await game.transition("region.ritual")
	game.player.enabled = false
	var boss = game.citadel_chapter.actor
	boss.set_physics_process(false)
	check.call(boss.health == 780 and boss.state == "dormant" and not is_instance_valid(game.journey.follower) and game.journey.status.contains("Lyra waits outside"),"Ritual constructs dormant wizard while selected Lyra explicitly waits outside")
	game.citadel_chapter.artifact()
	check.call(not tree.paused and not game.session.state.campaign.completed,"Living wizard prevents ending confirmation")
	game.player.position = game.region.surface_point(Vector3(0,0.1,5))
	boss._physics_process(0.016)
	check.call(game.in_combat() and game.region.entrance_barrier.collision_layer == 1 and not game.rest(),"Maldrek trigger closes ward and blocks resting")
	game.player.position = boss.position+Vector3(0,0,3)
	boss.begin_attack("orb")
	boss._physics_process(0.91)
	var orb = boss.spells[0]
	orb.set_physics_process(false)
	var hp: float = game.player.health
	orb._physics_process(0.6)
	check.call(game.player.health < hp and orb.spent,"Swept projectile detects real knight even across a long physics step")
	game.player.combat.state = "locomotion"
	game.player.position = boss.position+Vector3(0,0,3)
	boss.begin_attack("ground")
	boss._physics_process(0.91)
	var hazard = boss.spells[boss.spells.size()-1]
	hazard.set_physics_process(false)
	hp = game.player.health
	hazard._physics_process(1.09)
	check.call(game.player.health == hp,"Marked ground gives a damage-free escape window")
	game.player.position += Vector3(5,0,0)
	hazard._physics_process(0.02)
	check.call(game.player.health == hp,"Leaving marked ground avoids the hazard")
	game.player.position = boss.position+Vector3(0,0,2)
	game.player.combat.state = "locomotion"
	boss.begin_attack("burst")
	boss._physics_process(1.11)
	boss._physics_process(0.1)
	var burst_hp: float = game.player.health
	boss._physics_process(0.1)
	check.call(burst_hp < hp and game.player.health == burst_hp,"Close spell burst hits once throughout its active window")
	game.player.combat.state = "locomotion"
	game.player.dodge_left = 0.5
	boss.begin_attack("burst")
	boss._physics_process(1.11)
	boss._physics_process(0.2)
	check.call(game.player.health == burst_hp,"Wizard burst respects basic knight dodge invulnerability")
	game.player.dodge_left = 0
	for cast_index in range(5):
		boss.begin_attack("orb")
		boss.cast()
	check.call(boss.spells.size() == 3,"Simultaneous wizard spells remain bounded")
	boss.clear_casts()
	boss.receive_hit(game.player.position,430,1,0)
	check.call(boss.phase == 2 and game.citadel_chapter.summons.size() == 2,"Half health starts phase two and creates two shades")
	game.citadel_chapter.summon()
	check.call(game.citadel_chapter.summons.size() == 2,"Summons remain capped at two living shades")
	for shade in game.citadel_chapter.summons:
		shade.set_physics_process(false)
	game.player.health = 0
	await game.respawn()
	check.call(game.region.region_id == "region.citadel" and game.player.health == game.player.max_health,"Wizard loss restores citadel lantern")
	await game.transition("region.ritual")
	game.player.enabled = false
	boss = game.citadel_chapter.actor
	boss.set_physics_process(false)
	check.call(boss.health == 780 and boss.phase == 1 and boss.spells.is_empty() and game.citadel_chapter.summons.is_empty(),"Retry resets wizard phase, spells and summons")
	boss.start()
	boss.receive_hit(game.player.position,430,1,0)
	var shades: Array = game.citadel_chapter.summons.duplicate()
	boss.begin_attack("orb")
	boss._physics_process(0.91)
	boss.receive_hit(game.player.position,10000,1,0)
	check.call(boss.health == 0 and boss.spells.is_empty() and shades[0].health == 0 and shades[1].health == 0 and game.region.entrance_barrier.collision_layer == 0,"Victory immediately cancels active magic and summons and releases ward")
	check.call(not game.session.state.campaign.completed and tree.paused and is_instance_valid(game.opening),"Wizard victory plays a cinematic without completing the ritual")
	var victory_camera: Camera3D=tree.root.get_camera_3d()
	check.call(victory_camera==game.opening.camera and not game.player.enabled,"Victory camera owns view and suppresses knight input")
	var victory_save: Dictionary=game.session.store.load_slot(game.session.state.slot_id)
	check.call(victory_save.ok and "boss.maldrek" in victory_save.state.campaign.boss_defeated_ids and not victory_save.state.campaign.completed,"Victory is durable before cinematic; artifact remains unbroken")
	game.citadel_chapter.artifact()
	check.call(not game.dialogue.visible and not await game.transition("region.citadel"),"Cinematic suppresses artifact and region-travel interaction")
	game.opening.complete()
	check.call(not tree.paused and game.player.enabled,"Skipping victory cinematic restores gameplay before artifact interaction")
	check.call(tree.root.get_camera_3d()!=victory_camera and not is_instance_valid(game.opening),"Skipping returns original camera and clears cinematic ownership")
	await game.start_selected(true)
	await game.transition("region.ritual")
	game.player.enabled = false
	check.call(game.citadel_chapter.actor.health == 0 and game.region.seal.visible,"Reload between wizard victory and ritual preserves dead boss and intact artifact")
	game.citadel_chapter.artifact()
	check.call(tree.paused and game.choices.get_child_count() == 2,"Artifact explicitly asks to confirm ending")
	game.choices.get_child(1).pressed.emit()
	check.call(not tree.paused and not game.session.state.campaign.completed,"Declining ritual preserves unfinished campaign")
	var store := Store.new("res://.tools/test-ritual-failure/"+str(Time.get_ticks_usec()))
	game.session.store = store
	game.session.save_progress()
	store.fail_stage = "before_promote"
	game.citadel_chapter.artifact()
	game.choices.get_child(0).pressed.emit()
	check.call(game.session.dirty and game.region.region_id == "region.ritual" and game.dialogue_text.text.contains("could not be saved") and not store.load_slot(1).state.campaign.completed,"Failed ritual save stays in arena with retry and preserves known-good victory")
	store.fail_stage = ""
	game.choices.get_child(0).pressed.emit()
	while game.transitioning:
		await tree.physics_frame
	await tree.process_frame
	check.call(game.region.region_id == "region.refuge" and not game.session.dirty and game.dialogue_text.text.contains("THE END") and game.region.refuge_echo.text.contains("DAWN"),"Successful retry saves before restored refuge ending and credits")
	game.choices.get_child(0).pressed.emit()
	check.call(not tree.paused,"Ending permits continued exploration")
	for id in ["region.village","region.blackwood","region.order","region.peaks","region.citadel"]:
		await game.transition(id)
		check.call(game.enemies.is_empty() and not game.in_combat(),"Cleansed "+id+" has no respawning main hostile encounters")
	game.rest()
	await game.start_selected(true)
	check.call(game.region.region_id == "region.refuge" and game.session.state.campaign.completed and Schema.validate(game.session.state) == "","Completed postgame reload returns to restored refuge after backtracking")
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.pause(true)
	await tree.create_timer(0.2,true).timeout
	game.queue_free()
	await tree.process_frame
