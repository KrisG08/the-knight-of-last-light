extends SceneTree
const Text = preload("res://game/audio/speech_text.gd")
const Film = preload("res://game/presentation/film_script.gd")
const L = preload("res://game/localization/localizer.gd")
var entries: Dictionary = {}
func _initialize() -> void:
	var matcher := RegEx.new()
	matcher.compile('"(?:[^"\\\\]|\\\\.)*"')
	for path in ["res://game/world/runtime/village_game.gd","res://game/allies/runtime/companion_journey.gd","res://game/world/runtime/order_chapter.gd","res://game/world/runtime/citadel_chapter.gd"]:
		for match_value in matcher.search_all(FileAccess.get_file_as_string(path)):
			var value = JSON.parse_string(match_value.get_string())
			if value is String and Text.is_narrative(value):
				for part in Text.parts(value): add_line(part,Text.speaker(value))
	for actor in ["lyra","cael"]:
		add_line("We travel together, or I wait at the refuge. Only one companion can follow. Rest at a lantern to recover a downed companion.",actor)
	add_line("His oath is ended. I will carry the names from the memorial, not the shame that kept me here.","cael")
	add_line("Complete the ally's authored rescue or recruitment quest","lyra")
	add_line("Recover the expedition record and return to Sir Cael","cael")
	for line in ["Sword is already fully upgraded","Need 60 shards","Need 120 shards","Sword upgraded to tier 1","Sword upgraded to tier 2"]: add_line(line,"oren")
	for line in Film.CAPTIONS+Film.VICTORY: add_line(line,"narrator")
	var output := {"version":1,"languages":L.LANGUAGES.keys(),"lines":entries,"opening":{"starts":Film.STARTS,"durations":Film.DURATIONS,"length":Film.LENGTH,"captions":Film.CAPTIONS},"victory":{"starts":[0,10],"durations":[10,6],"captions":Film.VICTORY}}
	var args := OS.get_cmdline_user_args()
	var destination: String = args[0] if not args.is_empty() else "res://.tools/voice-build/script.json"
	FileAccess.open(destination,FileAccess.WRITE).store_string(JSON.stringify(output,"  ",false))
	print("Authored voice script: ",entries.size()," lines × 5 languages")
	quit()
func add_line(source: String, actor: String) -> void:
	if source.is_empty(): return
	var key := Text.key(source,actor)
	if entries.has(key): return
	var localized := {}
	for code in L.LANGUAGES:
		L.set_locale(code)
		localized[code] = L.text(source)
	entries[key] = {"source":source,"speaker":actor,"text":localized}
