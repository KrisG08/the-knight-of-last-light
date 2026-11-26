extends Node
## Persistent two-deck score. Region nodes own ambience; this owns only music.
const TRACKS = {
	"menu": preload("res://assets/audio/music/menu.ogg"),
	"exploration": preload("res://assets/audio/music/exploration.ogg"),
	"combat": preload("res://assets/audio/music/combat.ogg"),
	"boss": preload("res://assets/audio/music/boss.ogg"),
	"dawn": preload("res://assets/audio/music/dawn.ogg")
}
const FADE_SECONDS := 2.0
const RELEASE_SECONDS := 3.0
var game: Node
var decks: Array[AudioStreamPlayer] = []
var levels: Array[float] = [0.0, 0.0]
var current := ""
var selected := -1
var combat_release := 0.0
var last_battle := ""
var switches := 0
var streams: Dictionary = {}

func setup(owner_game: Node) -> void:
	game = owner_game
	process_mode = Node.PROCESS_MODE_ALWAYS
	for key in TRACKS:
		var stream: AudioStreamOggVorbis = TRACKS[key].duplicate()
		stream.loop = true
		streams[key] = stream
	for index in range(2):
		var deck := AudioStreamPlayer.new()
		deck.name = "ScoreDeck%d" % index
		deck.bus = "Music"
		deck.volume_db = -80
		add_child(deck)
		decks.append(deck)

func desired_track() -> String:
	if not is_instance_valid(game) or not is_instance_valid(game.player): return ""
	# Encoded films own their soundtrack; live victory choreography uses our dawn cue.
	if is_instance_valid(game.opening): return str(game.opening.get_meta("score_theme", ""))
	if not game.started: return "menu"
	if game.session.state.campaign.completed: return "dawn"
	if game.player.health <= 0: return "exploration"
	var encounter: Node = game.current_encounter()
	if is_instance_valid(encounter) and encounter.active(): return "boss"
	if game.in_combat(): return "combat"
	return "exploration"

func _process(delta: float) -> void:
	if not is_instance_valid(game) or decks.size() != 2: return
	var wanted := desired_track()
	if wanted in ["boss", "combat"]:
		combat_release = RELEASE_SECONDS
		last_battle = wanted
	elif wanted == "exploration" and game.player.health > 0 and not game.transitioning:
		combat_release = maxf(0, combat_release - delta)
		if combat_release > 0: wanted = last_battle
	else:
		combat_release = 0
	# Preserve the current track across a region's short loading interval.
	if game.transitioning and wanted == "exploration" and not current.is_empty(): wanted = current
	select_track(wanted)
	var duck := 0.55 if game.started and game.get_tree().paused and not is_instance_valid(game.opening) else 1.0
	if is_instance_valid(game.voice) and game.voice.speaking(): duck *= .48
	for index in range(2):
		var target := duck if index == selected and not current.is_empty() else 0.0
		# Cutscenes must not inherit a two-second overlap with their baked score.
		var speed := 8.0 if wanted.is_empty() else 1.0 / FADE_SECONDS
		levels[index] = move_toward(levels[index], target, delta * speed)
		decks[index].volume_db = linear_to_db(maxf(levels[index] * 0.42, 0.0001))
		if levels[index] == 0 and index != selected: decks[index].stop()

func select_track(wanted: String) -> void:
	if wanted == current: return
	current = wanted
	switches += 1
	if wanted.is_empty():
		selected = -1
		return
	var next := 0 if selected < 0 else 1 - selected
	# Reuse a fading deck when rapidly returning to its theme.
	for index in range(2):
		if decks[index].stream == streams[wanted] and decks[index].playing:
			next = index
	selected = next
	if decks[next].stream != streams[wanted] or not decks[next].playing:
		decks[next].stream = streams[wanted]
		decks[next].play()
