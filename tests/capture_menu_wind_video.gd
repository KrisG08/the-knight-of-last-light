extends SceneTree
## Deterministic native menu preview, isolated from owner saves.
func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	root.size=Vector2i(1280,720)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true
	game.set_language("bg")
	for frame in range(10): await process_frame
	game.menu.set_process(false)
	game.menu.atmosphere.set_process(false)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tools/review/wind-frames"))
	for frame in range(180):
		game.menu.living_scene.clock=float(frame)/30.0
		game.menu.living_scene.advance(0,true)
		game.menu.atmosphere.clock=float(frame)/30.0
		game.menu.atmosphere.queue_redraw()
		await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://.tools/review/wind-frames/%04d.png"%frame)
	game.queue_free(); await process_frame
	print("Native wind preview: 180 frames at 30 fps captured")
	quit()
