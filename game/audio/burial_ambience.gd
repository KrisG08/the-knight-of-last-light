extends Node3D

# Region-owned original soundscape, paused with gameplay and freed on transition.
var air: AudioStreamPlayer
var seal_tone: AudioStreamPlayer3D
var drip: AudioStreamPlayer3D
var timer: Timer
var random := RandomNumberGenerator.new()
var fade: float = 0
const DRIPS = [preload("res://assets/audio/burial/drip_0.wav"),preload("res://assets/audio/burial/drip_1.wav"),preload("res://assets/audio/burial/drip_2.wav")]

func looped(source: AudioStreamWAV) -> AudioStreamWAV:
	var stream := source.duplicate() as AudioStreamWAV
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = roundi(stream.get_length()*stream.mix_rate)
	return stream

func _ready() -> void:
	random.seed = 4851
	air = AudioStreamPlayer.new()
	air.bus = "SFX"
	air.stream = looped(preload("res://assets/audio/burial/chamber_air.wav"))
	air.volume_db = -60
	add_child(air)
	air.play()
	seal_tone = AudioStreamPlayer3D.new()
	seal_tone.bus = "SFX"
	seal_tone.position = Vector3(0,1,-7)
	seal_tone.stream = looped(preload("res://assets/audio/burial/seal_resonance.wav"))
	seal_tone.volume_db = -22
	seal_tone.max_distance = 15
	seal_tone.unit_size = 3
	add_child(seal_tone)
	drip = AudioStreamPlayer3D.new()
	drip.bus = "SFX"
	drip.max_distance = 22
	drip.unit_size = 5
	drip.volume_db = -13
	add_child(drip)
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(drop)
	add_child(timer)
	timer.start(2.8)
	get_parent().seal.visibility_changed.connect(update_seal)
	update_seal()

func _process(delta: float) -> void:
	fade = minf(1,fade+delta/1.5)
	air.volume_db = lerpf(-60,-19,fade)

func update_seal() -> void:
	var region := get_parent()
	var intact: bool = is_instance_valid(region.seal) and region.seal.visible
	if intact and not seal_tone.playing:
		seal_tone.play()
	elif not intact and seal_tone.playing:
		seal_tone.stop()

func drop() -> void:
	drip.position = Vector3(random.randf_range(-8,8),random.randf_range(2,4),random.randf_range(-8,8))
	drip.stream = DRIPS[random.randi_range(0,DRIPS.size()-1)]
	drip.pitch_scale = random.randf_range(0.92,1.08)
	drip.play()
	timer.start(random.randf_range(3.1,7.5))

func _exit_tree() -> void:
	if is_instance_valid(timer): timer.stop()
	for player in [air,seal_tone,drip]:
		if is_instance_valid(player): player.stop()
