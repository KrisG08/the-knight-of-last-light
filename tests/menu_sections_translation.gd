extends SceneTree
const L=preload("res://game/localization/localizer.gd")
var game: Node
var failures:=0
var assertions:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: call_deferred("run")
func all_text(node: Node) -> String:
	var output:=""
	if node is Label or node is Button: output+=str(node.text)+"\n"
	for child in node.get_children(): output+=all_text(child)
	return output
func run() -> void:
	game=load("res://game/world/runtime/village_game.tscn").instantiate(); game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true
	var state=preload("res://tests/finale_checks.gd").citadel_state()
	preload("res://game/persistence/domain/journey_history.gd").ensure(state)
	for definition in ["fallen_soldier","hollow_villager","grave_hound","bound_shade"]:
		var profile=load("res://content/enemies/"+definition+".tres")
		state.journey.enemy_defeats["fixture/"+definition]={"name":profile.display_name,"region":"region.village","count":1}
	check(game.session.store.save(state).ok,"Progress fixture is valid")
	game.refresh_journey_picker(1)
	for code in ["bg","ru","fr","ar"]:
		game.set_language(code)
		game.show_credits()
		var credits: String=game.dialogue_text.text
		FileAccess.open("res://.tools/menu-credits-"+code+".txt",FileAccess.WRITE).store_string(credits)
		for phrase in ["Campaign development build","Original gameplay/ruin kit","Includes refuge, village","Gamepad and final animation"]:
			check(not credits.contains(phrase),code+" credits narrative translated: "+phrase)
		for paragraph in L.source(game.dialogue_text).split("\n"):
			if not paragraph.is_empty(): check(L.text(paragraph)!=paragraph,code+" every credits paragraph has a translation")
		for attribution in ["Kenney","Poly Haven","Meshy","https://www.meshy.ai/","CC BY 4.0","Andy Woodhead","afk.ai","chengzijieczj","Coffeek","Alexei Ostapenko","DJMaesen","SIL OFL 1.1","MIT"]:
			check(credits.contains(attribution),code+" credits retain original attribution: "+attribution)
		game.show_font_licenses()
		for face in ["ElMessiri","Cinzel","SourceSans3","Barlow","NotoSerif","NotoNaskhArabic"]:
			var legal:=FileAccess.get_file_as_string("res://assets/fonts/"+face+"-OFL.txt")
			check(game.dialogue_text.text.contains(legal),code+" legal notice stays verbatim: "+face)
		game.pause(true); game.show_journey_progress()
		var progress: String=game.dialogue_text.text
		for phrase in ["WORLD PROGRESS","Chapter ","Rank ","bosses","completed"]:
			check(not progress.contains(phrase),code+" full progress section translated: "+phrase)
		for definition in ["fallen_soldier","hollow_villager","grave_hound","bound_shade"]:
			var profile=load("res://content/enemies/"+definition+".tres")
			check(not progress.contains(profile.display_name),code+" saved enemy history translated: "+profile.display_name)
		game.pause(true); game.show_settings()
		var settings_text:=all_text(game.settings_panel)
		FileAccess.open("res://.tools/menu-settings-"+code+".txt",FileAccess.WRITE).store_string(settings_text)
		for phrase in ["Camera sensitivity","Master volume","Effects volume","Animated menus","Restore default settings","Save settings and back","Gamepad is not supported"]:
			check(not settings_text.contains(phrase),code+" full settings section translated: "+phrase)
		game.pause(true); game.show_account()
		var account_text:=all_text(game.account_panel)
		for phrase in ["Create account","Forgot password?","Verification code","Import local journeys"]:
			check(not account_text.contains(phrase),code+" account section translated: "+phrase)
		game.account_panel.close(); game.show_saved_journeys()
		var library:=all_text(game.dialogue)
		check(not library.contains("Rank ") and not library.contains("enemy victories"),code+" saved library translated")
		game.pause(true)
	var legal_label:=Label.new(); root.add_child(legal_label)
	L.set_text(legal_label,"Master volume",false); L.set_locale("bg")
	check(legal_label.text=="Master volume","Verbatim bindings survive language changes")
	L.set_text(legal_label,"Master volume")
	check(legal_label.text=="Обща сила на звука","Normal translation resumes after a verbatim binding")
	legal_label.queue_free()
	game.queue_free(); await process_frame; L.set_locale("en")
	print("Full menu section translation: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
