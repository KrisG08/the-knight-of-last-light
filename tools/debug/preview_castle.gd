extends SceneTree
## Playable owner review of the castle in an isolated memory-only journey.
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.session.begin(1,false)
	game.session.state=load("res://tests/finale_checks.gd").citadel_state()
	game.started=true
	if not await game.transition("region.citadel"): quit(1); return
	game.pause(false)
	DisplayServer.window_set_title("The Knight of Last Light - Castle Preview v"+ProjectSettings.get_setting("application/config/version"))
