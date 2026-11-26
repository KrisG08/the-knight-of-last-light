extends SceneTree
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func frames(count: int = 8) -> void:
	for index in range(count): await process_frame
func run() -> void:
	if DisplayServer.get_name()=="headless": quit(2); return
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.benchmarking=true
	await game.start_selected()
	game.testing=false
	for mode in [DisplayServer.WINDOW_MODE_MAXIMIZED,DisplayServer.WINDOW_MODE_FULLSCREEN]:
		DisplayServer.window_set_mode(mode); await frames()
		var before := DisplayServer.window_get_size()
		game.player.position=game.region.points.travel+Vector3(0,0.1,1)
		game.pause(false)
		var key := InputEventKey.new(); key.physical_keycode=KEY_E; key.pressed=true
		game._input(key)
		while game.transitioning: await physics_frame
		await frames()
		var passed: bool = game.region.region_id=="region.village" and DisplayServer.window_get_mode()==mode and DisplayServer.window_get_size()==before
		print("E passage mode=",mode," retained=",DisplayServer.window_get_mode()," size=",before," -> ",DisplayServer.window_get_size()," ","PASS" if passed else "FAIL")
		if not passed: failures+=1
		DisplayServer.window_set_mode(mode); await frames()
		await game.transition("region.crypt"); await frames()
		passed=game.region.region_id=="region.crypt" and DisplayServer.window_get_mode()==mode and DisplayServer.window_get_size()==before
		print("Boss entrance mode=",mode," retained=",DisplayServer.window_get_mode()," ","PASS" if passed else "FAIL")
		if not passed: failures+=1
		game.testing=true
		await game.transition("region.refuge")
		game.testing=false
	game.settings.set_value("fullscreen",true); game.apply_settings(); await frames()
	var toggled: bool = DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_FULLSCREEN
	game.settings.set_value("fullscreen",false); game.apply_settings(); await frames()
	toggled = toggled and DisplayServer.window_get_mode()==DisplayServer.WINDOW_MODE_WINDOWED
	print("Explicit fullscreen setting still toggles display ","PASS" if toggled else "FAIL")
	if not toggled: failures+=1
	game.testing=true; game.pause(true); game.queue_free()
	await process_frame
	quit(1 if failures else 0)
