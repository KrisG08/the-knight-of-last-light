extends SceneTree
## Actual gameplay and touch HUD capture with an isolated in-memory journey.
func _initialize() -> void:
	create_timer(120,true).timeout.connect(func(): push_error("Stone HUD capture timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	var touch: bool="--touch" in OS.get_cmdline_user_args()
	root.size=Vector2i(1600,720) if touch else Vector2i(1600,900)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.session.begin(1,false); game.started=true
	game.set_language("bg")
	if not await game.transition("region.village"): quit(1); return
	game.pause(false)
	for actor in game.enemies: actor.set_physics_process(false)
	game.player.global_position=game.region.points.checkpoint+Vector3(1,0.2,2)
	for frame in range(20): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://.tools/review/stone-gameplay-"+("touch" if touch else "desktop")+".png")
	print("Stone HUD native capture: ","touch" if touch else "desktop")
	game.queue_free(); await process_frame; quit()
