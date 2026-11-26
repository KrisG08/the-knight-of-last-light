extends SceneTree
## Requires real bundled speech. Fails closed on missing language/audio coverage.
const Text = preload("res://game/audio/speech_text.gd")
const L = preload("res://game/localization/localizer.gd")
const Film = preload("res://game/presentation/film_script.gd")
var assertions := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	var manifest_path := "res://assets/audio/voice/manifest.json"
	if not FileAccess.file_exists(manifest_path):
		push_error("Real localized speech has not been generated; no voice acceptance claim is possible")
		quit(1); return
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	for key in manifest.lines:
		var entry: Dictionary = manifest.lines[key]
		check(key == Text.key(entry.source,entry.speaker),"Audio belongs to the authored source and speaker")
		for code in L.LANGUAGES:
			L.set_locale(code)
			var path: String = entry.clips.get(code,"")
			var stream: AudioStream = load(path) as AudioStream if not path.is_empty() else null
			check(stream != null and stream.get_length()>.1,"Actual decoded speech exists: "+key+" "+code)
			check(entry.metadata.get(code,{}).get("text","")==L.text(entry.source),"Speech transcript matches the UI locale: "+key+" "+code)
			if entry.source in Film.CAPTIONS:
				var budget: float = Film.DURATIONS[Film.CAPTIONS.find(entry.source)]
				check(stream != null and stream.get_length()<budget-.5,"Opening narration finishes before its shot changes: "+code)
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true; root.add_child(game)
	while game.transitioning: await process_frame
	game.session.begin(1,false); game.started = true; game.pause(false)
	var args := OS.get_cmdline_user_args()
	var output: String = args[0] if not args.is_empty() else ""
	if not output.is_empty(): DirAccess.make_dir_recursive_absolute(output)
	var source := "OREN\nThe things in the churchyard were our neighbors. Something below the graves keeps calling them back.\n\nPlease free me. I can work again if the chapel still stands."
	for code in L.LANGUAGES:
		game.settings.set_value("language",code); game.apply_settings()
		game.show_settings(); await process_frame
		var volume_label: Label
		var voice_toggle: CheckButton
		for label in game.settings_panel.find_children("*","Label",true,false):
			if L.source(label)=="Voice volume": volume_label=label
		for toggle in game.settings_panel.find_children("*","CheckButton",true,false):
			if L.source(toggle)=="Spoken dialogue and narration": voice_toggle=toggle
		check(volume_label!=null and voice_toggle!=null and volume_label.text==L.text("Voice volume") and voice_toggle.text==L.text("Spoken dialogue and narration"),"Voice controls are reachable and localized: "+code)
		if volume_label!=null and voice_toggle!=null:
			voice_toggle.button_pressed=false
			check(not game.settings.values.voice_enabled,"Actual settings toggle disables narration: "+code)
			voice_toggle.button_pressed=true
			var slider := volume_label.get_parent().get_child(1) as HSlider
			slider.value=0
			check(game.settings.values.voice_volume==0 and AudioServer.is_bus_mute(AudioServer.get_bus_index("Voice")),"Actual voice slider mutes its independent bus: "+code)
			slider.value=.9
		game.open_dialogue(source)
		await process_frame; await process_frame
		var expected: String = manifest.lines[Text.key(Text.parts(source)[0],"oren")].clips[code]
		check(game.voice.current_key == expected and game.voice.pending.size()==1,"NPC starts the selected language with an ordered second paragraph: "+code)
		if not output.is_empty() and DisplayServer.get_name() != "headless":
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(output+"/npc-"+code+".png")
		if code=="en":
			game.voice.player.seek(game.voice.player.stream.get_length()-.04)
			await create_timer(.4,true).timeout; await process_frame
			var second: String = manifest.lines[Text.key(Text.parts(source)[1],"oren")].clips[code]
			check(game.voice.current_key==second and game.voice.pending.is_empty(),"Actual audio completion starts the next paragraph while the conversation pauses gameplay")
		game.leave_dialogue()
		check(game.voice.current_key.is_empty() and game.voice.pending.is_empty() and not game.voice.player.playing,"Closing the dialogue cancels speech and queue: "+code)
	L.set_locale("en")
	var first_owner := Node.new(); var second_owner := Node.new()
	game.add_child(first_owner); game.add_child(second_owner)
	game.voice.say(Film.CAPTIONS[0],"narrator",first_owner)
	game.voice.say(Film.CAPTIONS[1],"narrator",second_owner)
	var expected_second: String = game.voice.current_key
	game.voice.stop_for(first_owner)
	check(game.voice.current_key == expected_second and not expected_second.is_empty(),"A stale view cannot cancel a later view's speech")
	game.voice.stop_for(second_owner)
	check(not game.voice.player.playing,"Current cinematic owner cancels its own audio")
	game.settings.set_value("voice_enabled",false)
	game.voice.say(Film.CAPTIONS[0],"narrator",first_owner)
	check(not game.voice.player.playing and game.voice.pending.is_empty(),"Voice opt-out prevents playback")
	game.settings.set_value("voice_enabled",true)
	game.settings.set_value("voice_volume",0.0)
	game.voice.say(Film.CAPTIONS[0],"narrator",first_owner)
	check(not game.voice.speaking(),"Zero voice volume does not duck the score")
	game.settings.set_value("voice_volume",.9)
	game.voice.say(Film.CAPTIONS[0],"narrator",first_owner)
	L.set_locale("bg"); await process_frame
	check(not game.voice.player.playing,"Changing language cancels the previous spoken language")
	L.set_locale("en")
	game.voice.dialogue("CLOUD SAVES\nprivate@example.invalid",first_owner)
	check(not game.voice.player.playing,"Account text is never narrated or sent to a synthesis service")
	check(not Text.is_narrative("Equipment") and not Text.is_narrative("SAVED JOURNEYS"),"Narration does not become a menu/statistics screen reader")
	check(Text.parts("OREN\nYou came back. My tools are rough, but this sword can still hold an edge.\nSword tier 2 · shards 999").size()==1,"Shop statistics do not contaminate character prose")
	game.queue_free(); await process_frame
	print("Localized voice: %d assertions, %s"%[assertions,"PASS" if failures==0 else "FAIL"])
	quit(0 if failures==0 else 1)
