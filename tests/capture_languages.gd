extends SceneTree
const L=preload("res://game/localization/localizer.gd")
var game: Node
func _initialize() -> void:
	create_timer(90,true).timeout.connect(func(): push_error("Language capture timeout"); quit(1))
	call_deferred("capture")
func photo(name_value: String) -> void:
	for tick in range(8): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://.tools/review/"+name_value+".png")
func capture() -> void:
	root.size=Vector2i(1600,900)
	game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true
	for code in L.LANGUAGES:
		game.set_language(code)
		await photo("menu-"+code)
		game.show_account()
		await photo("account-"+code)
		game.account_panel.close()
		game.show_settings()
		await photo("settings-"+code)
		game.settings_panel.hide(); game.menu.show()
	root.size=Vector2i(1600,720)
	game.set_language("bg")
	await game.start_selected()
	game.pause(false)
	await photo("world-bg")
	game.set_language("ar")
	await photo("world-ar")
	game.queue_free(); await process_frame
	L.set_locale("en")
	print("Language menu, account, settings and HUD captures complete")
	quit()
