extends SceneTree
var failed := false
func _initialize() -> void:
	call_deferred("probe")
func probe() -> void:
	var aspect: String = ProjectSettings.get_setting("display/window/stretch/aspect", "keep")
	if aspect != "expand":
		print("FAIL: phone aspect is %s, so wide phones retain a 16:9 frame" % aspect)
		failed = true
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning:
		await physics_frame
	await process_frame
	for item in game.menu.find_children("*", "Button", true, false):
		if item.text == "Drink flask" and item.is_visible_in_tree():
			print("FAIL: initial menu shows in-game utilities before a journey is active")
			failed = true
	game.queue_free()
	await process_frame
	print("Mobile layout probe: "+("FAIL" if failed else "PASS"))
	quit(1 if failed else 0)
