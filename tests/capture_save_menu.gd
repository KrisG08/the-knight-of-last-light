extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.benchmarking = true
	await game.start_selected()
	game.pause(true)
	game.quit_button.pressed.emit()
	for frame in range(12): await process_frame
	if game.session.active or not game.menu.visible or game.player.enabled:
		push_error("Save-and-menu did not return to title"); quit(1); return
	await RenderingServer.frame_post_draw
	var suffix := "mobile" if "--touch" in OS.get_cmdline_user_args() else "desktop"
	root.get_texture().get_image().save_png("res://.tools/review/save-menu-"+suffix+".png")
	print("Native save-and-menu title screen ",suffix," PASS")
	quit()
