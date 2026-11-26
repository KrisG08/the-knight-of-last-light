extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func photograph(name: String) -> void:
	for frame in range(8):
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
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	await photograph("dark_fantasy_menu")
	await game.start_selected()
	game.player.enabled = false
	game.player.position = Vector3(0,0.1,8)
	game.player.pivot.rotation = Vector3(-0.2,0,0)
	await photograph("dark_fantasy_refuge")
	game.player.yaw = PI
	game.player.pitch = -0.15
	await photograph("dark_fantasy_knight")
	game.settings.values.ui_scale = 1.5
	game.apply_settings()
	game.player.yaw = 0
	await photograph("dark_fantasy_hud_150")
	game.show_journal()
	await photograph("dark_fantasy_journal_150")
	game.player.sounds.stop()
	game.ui_sound.stop()
	await create_timer(0.2,true).timeout
	game.queue_free()
	await process_frame
	quit()
