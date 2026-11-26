extends RefCounted
const Rules = preload("res://game/campaign/domain/campaign_rules.gd")

static func rules(check: Callable) -> void:
	var state := Rules.new_game()
	check.call(Rules.lantern_destination(state,"checkpoint.refuge").allowed,"Starting refuge is a known safe lantern")
	check.call(not Rules.lantern_destination(state,"checkpoint.citadel").allowed and not Rules.lantern_destination(state,"checkpoint.training").allowed,"Unknown campaign and training destinations cannot bypass discoveries")
	state.campaign.checkpoint_ids.append("checkpoint.citadel")
	check.call(not Rules.lantern_destination(state,"checkpoint.citadel").allowed,"Even malformed activated destination cannot bypass citadel seal gate")

static func run(tree: SceneTree, check: Callable) -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	await game.start_selected()
	game.player.enabled = false
	game.player.position = game.region.points.checkpoint+Vector3(-2,0.1,0)
	check.call(game.lantern_travel_ready(),"Standing at refuge lantern enables map")
	check.call(not await game.travel_to_lantern("checkpoint.village"),"Actual travel refuses unactivated village lantern")
	await game.transition("region.village")
	game.player.enabled = false
	for enemy in game.enemies:
		enemy.set_physics_process(false)
	game.player.position = game.region.points.checkpoint+Vector3(-2,0.1,0)
	check.call(not game.lantern_travel_ready(),"Source lantern must also be activated")
	game.rest()
	game.player.enabled = false
	game.show_lantern_map()
	check.call(tree.paused and game.choices.get_child(0).text == "Travel to Lantern Refuge","Map offers only activated reachable destinations")
	game.choices.get_child(0).pressed.emit()
	while game.transitioning:
		await tree.physics_frame
	check.call(game.region.region_id == "region.refuge" and game.player.position.distance_to(game.region.points.checkpoint) < 3 and not tree.paused,"Map button actually travels and restores control at destination lantern")
	check.call(game.session.state.recovery.region_id == "region.refuge" and game.player.health == game.player.max_health,"Travel commits destination recovery and restores resources")
	game.player.position = game.region.surface_point(Vector3(0,0.1,-8))
	check.call(not await game.travel_to_lantern("checkpoint.village"),"Travel rejects remote journal use away from lantern")
	game.show_lantern_map()
	check.call(game.dialogue_text.text.contains("Stand beside"),"Unavailable map explains safe travel requirement")
	game.leave_dialogue()
	game.player.position = game.region.points.checkpoint+Vector3(-2,0.1,0)
	check.call(await game.travel_to_lantern("checkpoint.village"),"Activated route permits return journey")
	game.player.enabled = false
	for enemy in game.enemies:
		enemy.set_physics_process(false)
	game.enemies[0].state = "chase"
	check.call(not await game.travel_to_lantern("checkpoint.refuge"),"Combat prevents lantern escape even beside checkpoint")
	game.enemies[0].state = "idle"
	game.player.combat.state = "heal"
	check.call(not game.lantern_travel_ready(),"In-progress player actions cannot be interrupted by travel")
	game.player.combat.state = "locomotion"
	await game.travel_to_lantern("checkpoint.refuge")
	check.call(game.session.load_slot(1) and game.session.state.recovery.region_id == "region.refuge","Travel recovery survives actual session reload")
	game.session.state = preload("res://tests/finale_checks.gd").citadel_state()
	for command in [["MeetLyra",""],["ClearForestTrail",""],["ClaimPickup","pickup.lyra_satchel"],["RecruitAlly","ally.lyra"],["DefeatBoss","boss.maldrek"],["CompleteCampaign",""],["ActivateCheckpoint","checkpoint.village"]]:
		game.session.act(command[0],command[1])
	await game.transition("region.refuge")
	game.player.position = game.region.points.checkpoint+Vector3(-2,0.1,0)
	game.journey.follower.receive_hit(game.player.position,1000,1,0)
	check.call(await game.travel_to_lantern("checkpoint.village") and game.journey.follower.health == 70 and game.session.state.recovery.region_id == "region.refuge","Postgame lantern travel restores selected companion while retaining refuge reload")
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.pause(true)
	await tree.create_timer(0.2,true).timeout
	game.queue_free()
	await tree.process_frame
