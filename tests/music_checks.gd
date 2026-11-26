extends SceneTree
var assertions := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	while game.transitioning: await process_frame
	var music = game.music
	music.set_process(false)
	music._process(2.1)
	check(music.current == "menu" and music.decks[music.selected].playing,"Real boot starts menu music")
	var initial: int = music.switches
	music._process(1.0)
	check(music.switches == initial,"Steady state does not restart the music")
	for key in music.streams:
		var stream: AudioStreamOggVorbis = music.streams[key]
		check(stream.loop and stream.get_length() >= 19.9,"Streaming loop exists: " + key)
	game.session.begin(1,false)
	game.started = true
	game.pause(false)
	music._process(.2)
	check(music.current == "exploration","Journey selects exploration")
	check(music.decks[0].playing and music.decks[1].playing,"Theme change crossfades overlapping decks")
	music._process(2.1)
	check(not music.decks[1-music.selected].playing,"Silent old deck stops decoding")
	game.settings.values.music = 0.0; game.settings.apply_audio()
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")),"Music slider mutes the real music bus")
	check(not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")),"Music mute preserves effects")
	game.settings.values.music = .6; game.settings.apply_audio()
	check(not AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")),"Music slider unmutes")
	game.pause(true); music._process(2.1)
	check(is_equal_approx(music.levels[music.selected],.55),"Paused journey ducks score")
	game.opening = CanvasLayer.new(); game.add_child(game.opening)
	music._process(.2)
	check(music.current.is_empty() and not music.decks[0].playing and not music.decks[1].playing,"Film silences background score")
	game.opening.set_meta("score_theme","dawn")
	music._process(2.1)
	check(music.current == "dawn" and music.levels[music.selected] == 1.0,"Live victory choreography receives its own unducked dawn cue")
	game.opening.queue_free(); game.opening = null
	game.pause(false)
	await game.transition("region.village")
	var enemy = game.enemies[0]
	enemy.state = "windup"
	music._process(.2)
	check(music.current == "combat","Ordinary enemy aggro selects combat")
	for actor in game.enemies: actor.state = "idle"
	music._process(.5)
	check(music.current == "combat","Combat release hold prevents flickering music")
	music._process(3.1)
	check(music.current == "exploration","Combat theme releases after quiet interval")
	await game.transition("region.crypt")
	var encounter: Node = game.current_encounter()
	encounter.actor.state = "windup"
	music._process(.2)
	check(music.current == "boss","Active guardian selects boss theme")
	game.player.health = 0
	music._process(.2)
	check(music.current == "exploration","Death releases encounter music")
	game.player.health = 110
	game.session.state.campaign.completed = true
	music._process(2.1)
	check(music.current == "dawn","Completed campaign gets peaceful theme")
	game.started = false
	music._process(2.1)
	check(music.current == "menu","Returning to main menu restores menu theme")
	check(music.get_child_count() == 2 and music.decks[0].bus == "Music" and music.decks[1].bus == "Music","One persistent pair of Music bus players")
	if DisplayServer.get_name() != "headless":
		var music_bus := AudioServer.get_bus_index("Music")
		var capture := AudioEffectCapture.new()
		AudioServer.add_bus_effect(music_bus,capture)
		for theme in ["menu", "exploration", "combat", "boss", "dawn"]:
			music.select_track(theme); music._process(2.1)
			await create_timer(.25,true).timeout
			capture.clear_buffer()
			await create_timer(.08,true).timeout
			var samples := capture.get_buffer(capture.get_frames_available())
			var peak := 0.0
			for sample in samples: peak = maxf(peak,maxf(absf(sample.x),absf(sample.y)))
			check(samples.size() > 0 and peak > .0001 and peak < 1.0,"Native decoded output is audible and unclipped: "+theme)
		AudioServer.remove_bus_effect(music_bus,AudioServer.get_bus_effect_count(music_bus)-1)
	game.queue_free(); await process_frame
	print("Journey music: %d assertions, %s" % [assertions,"PASS" if failures == 0 else "FAIL"])
	quit(0 if failures == 0 else 1)
