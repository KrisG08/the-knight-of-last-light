extends SceneTree
var game: Node
func _initialize() -> void:
	create_timer(60,true).timeout.connect(func(): push_error("Mobile frontend capture timeout"); quit(1))
	call_deferred("capture")
func photo(label: String, dimensions: Vector2i) -> void:
	root.size = dimensions
	for frame in range(6): await process_frame
	var logical := root.get_visible_rect().size
	if absf(logical.x/logical.y - float(dimensions.x)/dimensions.y) > 0.01:
		push_error("Viewport does not fill aspect %s: %s" % [dimensions,logical])
		quit(1)
		return
	RenderingServer.force_draw(false)
	var filename := "laptop-"+label.trim_prefix("mobile-") if "--desktop" in OS.get_cmdline_user_args() else label
	root.get_texture().get_image().save_png("res://.tools/review/"+filename+".png")
	print("Filled viewport %s -> logical %s: PASS" % [dimensions,logical])
func capture() -> void:
	game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	await process_frame
	game.benchmarking = true # Startup is finished; do not spawn the benchmark fixture.
	await photo("mobile-start-wide",Vector2i(1600,720))
	await photo("mobile-start-tablet",Vector2i(1280,960))
	game.settings.values.ui_scale = 1.5
	game.apply_settings()
	await photo("mobile-start-large-text",Vector2i(1600,720))
	game.settings.values.ui_scale = 1.0
	game.apply_settings()
	game.show_settings()
	await photo("mobile-settings-wide",Vector2i(1600,720))
	game.pause(true)
	await game.start_selected()
	game.pause(false)
	await photo("mobile-world-wide",Vector2i(1600,720))
	game.pause(true)
	await photo("mobile-pause-wide",Vector2i(1600,720))
	game.menu.show_actions(true)
	await photo("mobile-actions-wide",Vector2i(1600,720))
	game.settings.set_value("menu_motion",false)
	for frame in range(3): await process_frame
	var frozen: float = game.menu.atmosphere.clock
	await create_timer(0.15,true).timeout
	if not is_equal_approx(frozen,game.menu.atmosphere.clock):
		push_error("Disabled menu atmosphere continues animating")
		quit(1)
		return
	print("Reduced menu motion freezes ambient animation: PASS")
	game.queue_free()
	await process_frame
	quit()
