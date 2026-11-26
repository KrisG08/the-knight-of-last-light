extends SceneTree
const L=preload("res://game/localization/localizer.gd")
var game: Node
var failed:=false
func _initialize() -> void:
	create_timer(120,true).timeout.connect(func(): push_error("Menu section capture timeout"); quit(1))
	call_deferred("run")
func photo(tag: String) -> void:
	for frame in range(6): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png("res://.tools/review/sections-"+tag+".png")
func press_menu(source: String) -> void:
	for item in game.menu.find_children("*","Button",true,false):
		if item.is_visible_in_tree() and L.source(item)==source:
			item.pressed.emit(); await process_frame; return
	failed=true; push_error("Menu route not visible: "+source)
func scroll_photos(panel: Node, tag: String) -> void:
	var scroll: ScrollContainer=panel.get_child(0)
	scroll.scroll_vertical=0
	await photo(tag+"-top")
	scroll.scroll_vertical=roundi(scroll.get_v_scroll_bar().max_value*0.5)
	await photo(tag+"-middle")
	scroll.scroll_vertical=roundi(scroll.get_v_scroll_bar().max_value)
	await photo(tag+"-bottom")
func run() -> void:
	root.size=Vector2i(1600,900)
	game=load("res://game/world/runtime/village_game.tscn").instantiate(); game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true
	var state=preload("res://tests/finale_checks.gd").citadel_state()
	preload("res://game/persistence/domain/journey_history.gd").ensure(state)
	if not game.session.store.save(state).ok: push_error("Invalid menu capture fixture"); quit(1); return
	game.refresh_journey_picker(1)
	for code in L.LANGUAGES:
		game.set_language(code); game.pause(true)
		await photo(code+"-main")
		await press_menu("Credits")
		await scroll_photos(game.dialogue,code+"-credits")
		game.pause(true); await process_frame
		await press_menu("World progress")
		await scroll_photos(game.dialogue,code+"-progress")
		game.pause(true); await process_frame
		await press_menu("Settings")
		await scroll_photos(game.settings_panel,code+"-settings")
		game.pause(true); await process_frame
		game.menu.account_button.pressed.emit()
		for mode in ["login","signup","verify","recover","reset"]:
			game.account_panel.mode=mode; game.account_panel.refresh()
			await photo(code+"-account-"+mode)
		game.account_panel.close(); game.show_saved_journeys()
		await photo(code+"-journeys")
		game.session.state=state.duplicate(true); game.session.active=true; game.started=true
		game.pause(true); await process_frame
		game.menu.show_actions(true); await photo(code+"-actions")
		game.show_journal(); await scroll_photos(game.dialogue,code+"-journal")
		game.session.active=false; game.started=false; game.pause(true)
	game.queue_free(); await process_frame; L.set_locale("en")
	print("All main/pause menu section captures and button routes: "+("FAIL" if failed else "PASS"))
	quit(1 if failed else 0)
