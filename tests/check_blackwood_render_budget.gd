extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.benchmarking = true
	game.session.begin(1,false)
	game.session.state = load("res://tests/finale_checks.gd").citadel_state()
	game.started = true
	await game.transition("region.blackwood")
	game.pause(false)
	game.player.enabled = false
	game.player.hide()
	game.ui_layer.hide()
	for actor in game.enemies: actor.set_physics_process(false)
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 72
	camera.position = Vector3(0,2,10)
	camera.look_at(Vector3(8,3,-17))
	for frame in range(20): await process_frame
	await RenderingServer.frame_post_draw
	var primitives := int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	var valid := primitives>0 and primitives<2000000
	print("Blackwood native fixed-view primitive budget (<2M including current render passes): %d %s" % [primitives,"PASS" if valid else "FAIL"])
	game.queue_free()
	await process_frame
	quit(0 if valid else 1)
