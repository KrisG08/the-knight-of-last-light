extends SceneTree
## Actual campaign actors and region lighting, isolated from player saves.
func _initialize() -> void: call_deferred("capture")
func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.session.begin(1,false); game.started=true
	await game.transition("region.refuge")
	game.pause(false); game.ui_layer.hide()
	game.player.enabled=false; game.player.set_physics_process(false)
	game.player.visual.rotation.y=0
	var camera := Camera3D.new(); game.add_child(camera); camera.fov=42
	await photograph(camera,game.player,Vector3(.65,1.25,-3.7),.98,"refuge-front")
	await photograph(camera,game.player,Vector3(-.65,1.25,3.7),.98,"refuge-back")
	game.session.state=load("res://tests/finale_checks.gd").citadel_state()
	await game.transition("region.ritual")
	game.pause(false); game.ui_layer.hide(); game.player.hide()
	var boss = game.citadel_chapter.actor
	boss.set_physics_process(false)
	await photograph(camera,boss,Vector3(1.1,1.8,-5.2),1.4,"maldrek-front")
	await photograph(camera,boss,Vector3(-1.1,1.8,5.2),1.4,"maldrek-back")
	game.player.sounds.stop(); game.ui_sound.stop()
	game.queue_free(); await process_frame
	print("NATIVE NIGHT MATERIAL CAPTURES COMPLETE")
	quit()
func photograph(camera: Camera3D, subject: Node3D, offset: Vector3, target_y: float, id: String) -> void:
	camera.current=true
	camera.global_position=subject.global_position+offset
	camera.look_at(subject.global_position+Vector3.UP*target_y)
	for frame in range(12): await process_frame
	await RenderingServer.frame_post_draw
	var args := OS.get_cmdline_user_args()
	var tag: String=args[0]+"-" if not args.is_empty() else ""
	assert(root.get_texture().get_image().save_png("res://.tools/review/character-reference-night-"+tag+id+".png")==OK)
	print("NATIVE NIGHT ",id)
