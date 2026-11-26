extends Node
## Bundled localized speech. No microphone, account text or network dependency.
const Text = preload("res://game/audio/speech_text.gd")
const L = preload("res://game/localization/localizer.gd")
const MANIFEST = "res://assets/audio/voice/manifest.json"
var game: Node
var player: AudioStreamPlayer
var catalog: Dictionary = {}
var pending: Array[String] = []
var owner_ref: WeakRef
var language := ""
var current_key := ""
var unavailable: Array[String] = []

func setup(owner_game: Node) -> void:
	game = owner_game
	process_mode = Node.PROCESS_MODE_ALWAYS
	if FileAccess.file_exists(MANIFEST):
		var data = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
		if data is Dictionary: catalog = data.get("lines",{})
	player = AudioStreamPlayer.new()
	player.name = "LocalizedVoice"
	player.bus = "Voice"
	add_child(player)
	player.finished.connect(play_next)

func enabled() -> bool:
	return is_instance_valid(game) and game.settings.values.get("voice_enabled",true) and float(game.settings.values.get("voice_volume",.9))>0

func speaking() -> bool:
	return enabled() and is_instance_valid(player) and player.playing

func say(source: String, actor: String, owner_node: Node, has_heading: bool = false) -> void:
	stop()
	if not enabled(): return
	language = L.language
	owner_ref = weakref(owner_node)
	for line in Text.parts(source,has_heading):
		var key := Text.key(line,actor)
		var localized: Dictionary = catalog.get(key,{}).get("clips",{})
		var path: String = localized.get(language,"")
		if path.is_empty() or not ResourceLoader.exists(path):
			# Never silently speak another language when a localized clip is missing.
			if key+language not in unavailable: unavailable.append(key+language)
			continue
		pending.append(path)
	play_next()

func dialogue(source: String, owner_node: Node) -> void:
	if Text.is_narrative(source): say(source,Text.speaker(source),owner_node,true)
	else: stop_for(owner_node)

func play_next() -> void:
	if not enabled() or owner_ref == null or not is_instance_valid(owner_ref.get_ref()):
		stop(); return
	if pending.is_empty():
		current_key = ""; return
	current_key = pending.pop_front()
	player.stream = load(current_key) as AudioStream
	if player.stream == null:
		stop(); return
	player.play()

func stop_for(owner_node: Node) -> void:
	if owner_ref != null and owner_ref.get_ref() == owner_node: stop()

func stop() -> void:
	if is_instance_valid(player):
		player.stop(); player.stream = null
	pending.clear(); owner_ref = null; current_key = ""

func _process(_delta: float) -> void:
	if owner_ref != null and (not enabled() or language != L.language or not is_instance_valid(owner_ref.get_ref())): stop()

func _exit_tree() -> void:
	stop()
