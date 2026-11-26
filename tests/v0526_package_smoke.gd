extends SceneTree
var failures := 0
func check(ok: bool, description: String) -> void:
	print(("PASS: " if ok else "FAIL: ")+description)
	if not ok: failures+=1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(ProjectSettings.get_setting("application/config/version")=="0.5.26","Packaged version is 0.5.26")
	var config=JSON.parse_string(FileAccess.get_file_as_string("res://game/cloud/cloud_config.json"))
	check(config is Dictionary and config.get("publishable_key","").begins_with("sb_publishable_") and not config.get("email_codes_ready",true),"Public cloud config and pending email status are packaged")
	var localizer=load("res://game/localization/localizer.gd")
	for language in ["bg","ru","fr","ar"]:
		localizer.set_locale(language)
		check(localizer.text("Continue journey")!="Continue journey","Packaged catalog loads "+language)
	localizer.set_locale("en")
	check(ResourceLoader.exists("res://assets/ui/main-menu-original-v1.png"),"Original panorama is packaged")
	check(ResourceLoader.exists("res://assets/fonts/ui_arabic.tres") and ResourceLoader.exists("res://assets/fonts/ui_serif.tres"),"Arabic and Cyrillic fonts are packaged")
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	check(game.menu.visible and game.account_panel!=null,"Export constructs menu and account route")
	game.show_account(); await process_frame
	check(game.account_panel.visible and game.get_tree().paused,"Export opens account screen without starting gameplay")
	game.account_panel.close(); game.queue_free(); await process_frame
	quit(0 if failures==0 else 1)
