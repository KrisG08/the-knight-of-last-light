extends SceneTree
const L=preload("res://game/localization/localizer.gd")
var failures:=0
var assertions:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	var expected: String=args[0] if not args.is_empty() else "0.5.27"
	check(ProjectSettings.get_setting("application/config/version")==expected,"Export contains expected version "+expected)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	var state=preload("res://game/campaign/domain/campaign_rules.gd").new_game(12)
	check(game.session.store.save(state).ok,"Package fixture save is valid")
	game.refresh_journey_picker(12)
	var before=JSON.stringify(game.session.store.load_slot(12).state)
	for code in ["bg","ru","fr","ar"]:
		game.set_language(code)
		var shown: String=game.slots.get_item_text(game.slots.selected)
		print(code+" packaged journey: "+shown)
		check(not shown.contains("Rank") and not shown.contains("bosses"),"Packaged picker translates "+code)
		check(game.slots.get_selected_id()==12,"Package language switch preserves selected save")
		check(L.text("Grave Hound")!="Grave Hound","Packaged historical enemy name translated")
		game.show_saved_journeys()
		for item in game.choices.get_children():
			if item is Button: check(not item.text.contains("Rank") and not item.text.contains("enemy victories"),"Packaged library button is translated")
		game.pause(true)
		game.show_credits()
		check(not game.dialogue_text.text.contains("Original gameplay/ruin kit") and not game.dialogue_text.text.contains("Includes refuge, village"),"Packaged credits paragraphs translated")
		check(game.dialogue_text.text.contains("Noto Naskh Arabic"),"Package includes updated font credits")
		game.pause(true); game.show_settings()
		var labels=game.settings_panel.find_children("*","Label",true,false)
		var has_english:=false
		for label in labels:
			if label.text in ["Master volume","Effects volume","Restore default settings and controls"]: has_english=true
		check(not has_english,"Packaged settings labels translated")
		game.pause(true)
	check(JSON.stringify(game.session.store.load_slot(12).state)==before,"Package localization never changes saved data")
	game.queue_free(); await process_frame; L.set_locale("en")
	print("Packaged journey localization: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL"))
	quit(0 if failures==0 else 1)
