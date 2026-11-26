extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func photograph(name: String) -> void:
	for frame in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/" + name + ".png")

func capture() -> void:
	var scene := load("res://game/world/runtime/village_game.tscn") as PackedScene
	var game = scene.instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	game.session.begin(1, false)
	game.started = true
	game.session.act("DefeatBoss", "boss.gravedigger")
	game.session.act("BreakSeal", "seal.burial")
	await game.transition("region.blackwood")
	game.pause(false)
	game.player.enabled = false
	for guard in game.enemies:
		guard.set_physics_process(false)
	game.player.position = game.region.points.lyra + Vector3(0, 0.1, 2)
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	game.journey.talk()
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	await photograph("lyra_quest")
	game.leave_dialogue()
	for guard in game.journey.guards:
		guard.receive_hit(game.player.position, 1000, 1, 0)
	game.session.act("ClaimPickup", "pickup.lyra_satchel")
	game.session.act("RecruitAlly", "ally.lyra")
	game.sync_stats()
	game.journey.refresh_selection()
	game.player.enabled = false
	game.player.position = Vector3(0, 0.1, 3)
	game.player.pivot.rotation = Vector3(-0.25, 0, 0)
	game.journey.follower.set_physics_process(false)
	game.journey.follower.position = Vector3(1.7, 0.1, 0.5)
	game.journey.follower.set_order("hold")
	await photograph("lyra_companion")
	game.journey.follower.receive_hit(game.player.position, 1000, 1, 0)
	game.journey.follower._physics_process(0)
	await photograph("lyra_downed")
	game.ui_sound.stop()
	game.player.sounds.stop()
	for actor in game.enemies:
		actor.sounds.stop()
	await create_timer(0.2, true).timeout
	game.queue_free()
	await process_frame
	quit()
