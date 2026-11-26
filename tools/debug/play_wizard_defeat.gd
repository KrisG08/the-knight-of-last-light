extends SceneTree
## Owner review: continuous real-time playback using isolated authored test state.
func _initialize() -> void:
	create_timer(60,true).timeout.connect(func(): quit(1))
	call_deferred("run")
func run() -> void:
	root.size=Vector2i(1280,720)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.session.begin(1,false)
	game.session.state=load("res://tests/finale_checks.gd").citadel_state()
	game.started=true
	await game.transition("region.ritual"); game.pause(false)
	DisplayServer.window_set_title("The Knight of Last Light - Victory animation preview")
	var boss=game.citadel_chapter.actor
	game.player.global_position=boss.global_position+Vector3(0,0,1.8)
	boss.start(); boss.receive_hit(game.player.global_position,10000,1,0)
	await game.opening.finished
	await create_timer(1.0,true).timeout
	game.player.sounds.stop(); game.ui_sound.stop()
	game.queue_free(); await process_frame; quit()
