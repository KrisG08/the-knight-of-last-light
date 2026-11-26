extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func photograph(name: String) -> void:
	for frame in range(4):
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/"+name+".png")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	game.session.begin(1,false)
	game.session.state = load("res://tests/finale_checks.gd").citadel_state()
	game.started = true
	await game.transition("region.citadel")
	game.pause(false)
	game.player.enabled = false
	for enemy in game.enemies:
		enemy.set_physics_process(false)
	game.player.position = Vector3(-19,0.1,-12)
	game.player.pivot.rotation = Vector3(-0.25,0,0)
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	await photograph("citadel_prison")
	await game.transition("region.ritual")
	game.player.enabled = false
	game.player.position = Vector3(0,0.1,3)
	game.player.pivot.rotation = Vector3(-0.25,0,0)
	var boss = game.citadel_chapter.actor
	boss.set_physics_process(false)
	boss.start()
	boss.receive_hit(game.player.position,430,1,0)
	for shade in game.citadel_chapter.summons:
		shade.set_physics_process(false)
	boss.begin_attack("ground")
	boss._physics_process(0.91)
	boss.spells[0].set_physics_process(false)
	await photograph("maldrek_phase_two")
	boss.receive_hit(game.player.position,10000,1,0)
	game.opening.complete()
	game.citadel_chapter.artifact()
	game.choices.get_child(0).pressed.emit()
	while game.transitioning:
		await physics_frame
	await photograph("campaign_ending")
	game.choices.get_child(0).pressed.emit()
	game.player.enabled = false
	game.player.position = Vector3(0,0.1,3)
	game.player.pivot.rotation = Vector3(-0.25,0,0)
	await photograph("cleansed_refuge")
	game.player.sounds.stop()
	game.ui_sound.stop()
	await create_timer(0.2,true).timeout
	game.queue_free()
	await process_frame
	quit()
