extends SceneTree
## Memory-only owner review; no real campaign slot/account is loaded.
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.session.begin(1,false)
	game.session.state=load("res://tests/finale_checks.gd").citadel_state(); game.started=true
	if not await game.transition("region.village"): quit(1); return
	game.player.global_position=game.region.points.forest+Vector3(0,0.1,2.4)
	game.player.yaw=0; game.player.pitch=-0.1
	game.pause(false)
	DisplayServer.window_set_title("The Knight of Last Light - Portal Preview v"+ProjectSettings.get_setting("application/config/version"))
