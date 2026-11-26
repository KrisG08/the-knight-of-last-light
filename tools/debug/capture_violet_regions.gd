extends SceneTree
## Authored QA cameras, not a campaign playthrough. Never touches owner saves.
func _initialize() -> void:
	create_timer(180,true).timeout.connect(func(): push_error("Violet region capture timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	root.size=Vector2i(1280,720)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.session.begin(1,false)
	game.session.state=load("res://tests/finale_checks.gd").citadel_state()
	game.started=true
	var camera:=Camera3D.new(); game.add_child(camera); camera.current=true; camera.fov=70
	for id in ["region.refuge","region.village","region.crypt","region.blackwood","region.order","region.peaks","region.citadel","region.ritual"]:
		if not await game.transition(id): push_error("Cannot load QA region "+id); quit(1); return
		# Inspect the authored corrupted appearance, independent of debug travel prerequisites.
		game.region.apply_state(load("res://game/campaign/domain/campaign_rules.gd").new_game(1))
		game.pause(false); game.player.enabled=false; game.player.hide(); game.ui_layer.hide()
		for actor in game.enemies: actor.set_physics_process(false)
		var encounter=game.current_encounter()
		if is_instance_valid(encounter) and is_instance_valid(encounter.actor): encounter.actor.set_physics_process(false)
		var target: Vector3=game.region.curse_presence.emitters[1].position
		camera.position=target+Vector3(6,2.5,8); camera.look_at(target+Vector3.UP)
		for frame in range(12): await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://.tools/review/violet-"+id.trim_prefix("region.")+".png")
		print("Native violet region view: ",id)
	game.player.sounds.stop(); game.ui_sound.stop()
	game.queue_free(); await process_frame; quit()
