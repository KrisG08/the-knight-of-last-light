extends AudioStreamPlayer3D

# Original weapon cues and CC0 Kenney-derived footfalls; see asset credits.
var cues: Dictionary = {}
var variants: Dictionary = {}
var footsteps: AudioStreamPlayer3D
var step_index: int = 0
var cue_index: int = 0

func _ready() -> void:
	if AudioServer.get_bus_index("SFX") >= 0:
		bus = "SFX"
	max_polyphony = 1
	max_distance = 24
	unit_size = 5
	volume_db = -15
	var frequencies := {"swing": 260.0, "windup": 140.0, "hit": 85.0, "block": 560.0, "heal": 740.0, "death": 55.0, "rest": 440.0, "step": 95.0, "dodge": 340.0}
	for id in frequencies:
		var frequency: float = frequencies[id]
		var clip := AudioStreamWAV.new()
		clip.format = AudioStreamWAV.FORMAT_16_BITS
		clip.mix_rate = 22050
		var samples := 3308
		var bytes := PackedByteArray()
		bytes.resize(samples * 2)
		for i in range(samples):
			var time: float = float(i) / clip.mix_rate
			var envelope: float = sin(PI * float(i) / samples) * (1.0 - float(i) / samples)
			bytes.encode_s16(i * 2, int(sin(TAU * frequency * time) * envelope * 20000))
		clip.data = bytes
		cues[id] = clip
	for id in ["step","swing","hit","block","windup"]:
		var clips: Array[AudioStream] = []
		for index in range(4 if id=="step" else 3):
			clips.append(load("res://assets/audio/combat/%s_%d.wav" % [id,index]))
		variants[id] = clips
		cues[id] = clips[0]
	footsteps = AudioStreamPlayer3D.new()
	footsteps.bus = bus
	footsteps.volume_db = -13
	footsteps.max_distance = max_distance
	footsteps.unit_size = unit_size
	add_child(footsteps)

func cue(id: String) -> void:
	if id=="step" and is_instance_valid(footsteps):
		footsteps.stream = variants.step[step_index%variants.step.size()]
		footsteps.pitch_scale = 0.98+(step_index%3)*0.02
		step_index += 1
		footsteps.play()
		return
	if cues.has(id):
		stop()
		if id=="death" and is_instance_valid(footsteps): footsteps.stop()
		if variants.has(id):
			stream = variants[id][cue_index%variants[id].size()]
			pitch_scale = 0.98+(cue_index%3)*0.02
			cue_index += 1
		else:
			stream = cues[id]
			pitch_scale = 1
		play()

func _exit_tree() -> void:
	stop()
	if is_instance_valid(footsteps): footsteps.stop()
