extends SceneTree
const L=preload("res://game/localization/localizer.gd")
const History=preload("res://game/persistence/domain/journey_history.gd")
const Rules=preload("res://game/campaign/domain/campaign_rules.gd")
var failures:=0
var assertions:=0
func check(ok: bool, description: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(description)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	preload("res://tests/localization_checks.gd").rules(check)
	var picker:=OptionButton.new(); root.add_child(picker)
	var state:=Rules.new_game(12)
	var progressed: Dictionary=preload("res://tests/finale_checks.gd").citadel_state()
	History.ensure(progressed)
	progressed.journey.enemy_defeats["fixture"]={"name":"Fallen Soldier","region":"region.village","count":3}
	var caption:="Journey %d · Rank %d · %d/5 bosses"%[12,state.character.rank,0]
	var saved_before:=JSON.stringify(progressed)
	L.add_item(picker,caption,12)
	for code in ["bg","ru","fr","ar"]:
		L.set_locale(code)
		var shown:=picker.get_item_text(0)
		print(code+" picker: "+shown)
		check(not shown.contains("Rank") and not shown.contains("bosses"),code+" journey picker translates rank and boss count")
		check(shown.contains("12") and shown.contains("0/5") and picker.get_item_id(0)==12,code+" localization preserves journey identity and numbers")
		var summary:=L.text(History.summary(state))
		check(not summary.contains("Rank") and not summary.contains("enemy victories"),code+" journey summary is translated")
		var library:=L.text("Journey %d · %s"%[12,History.summary(progressed)])
		check(not library.contains("Rank") and not library.contains("bosses") and not library.contains("enemy victories"),code+" saved journey buttons translate nested summaries")
		var report:=L.text(History.describe(progressed))
		var journal:=L.text(preload("res://game/ui/journal_content.gd").render(progressed,"region.citadel","Activate the lantern · free captives or face Maldrek to the north"))
		FileAccess.open("res://.tools/journey-report-"+code+".txt",FileAccess.WRITE).store_string(report+"\n\n"+journal)
		for word in ["WORLD PROGRESS","Rank ","bosses","enemy victories","completed","active","recruited","defeated","Chapter ","The Order","Sword ","shards"]:
			check(not report.contains(word),code+" progress report translates "+word)
		check(not journal.contains("recruited") and not journal.contains("completed"),code+" journal quest/ally states are translated")
		if code!="fr":
			var latin:=RegEx.new(); latin.compile("[A-Za-z]{3,}")
			var numerals:=RegEx.new(); numerals.compile("\\b[IVX]+\\b")
			check(latin.search(numerals.sub(report,"",true))==null and latin.search(numerals.sub(journal,"",true))==null,code+" fixture reports contain no leftover English words")
		check(L.text("  Rank 23  ")=="  "+L.text("Rank 23")+"  ",code+" dynamic templates preserve surrounding whitespace")
		check(not L.text("completed · active · follow · hold · downed").contains("active"),code+" standalone status fragments are translated")
	L.set_locale("en")
	check(JSON.stringify(progressed)==saved_before,"Language switches never rewrite persisted journey facts or English save metadata")
	check(picker.get_item_text(0)==caption,"English restores the original picker caption")
	picker.queue_free(); await process_frame
	print("Journey translation regression: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
