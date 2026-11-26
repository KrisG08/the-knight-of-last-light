extends SceneTree
var failed := false
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking = true; game.session.begin(1,false); game.started = true; game.pause(false)
	var old_region: Node = game.region
	var launch := func(): await game.transition("region.village")
	launch.call()
	var staged_count := 0
	for child in game.get_children():
		if child.get_script() == preload("res://game/world/regions/graybox_region.gd"): staged_count += 1
	if not game.transitioning or not game.transition_label.visible or game.player.enabled or staged_count != 1 or game.region != old_region:
		failed = true; push_error("Passage feedback and disabled input must precede synchronous scene construction")
	while game.transitioning: await process_frame
	if game.region.region_id != "region.village" or game.transition_label.visible or not game.player.enabled:
		failed = true; push_error("Transition did not finish with playable target and cleared feedback")
	game.queue_free(); await process_frame
	print("Transition feedback: ","FAIL" if failed else "PASS")
	quit(1 if failed else 0)
