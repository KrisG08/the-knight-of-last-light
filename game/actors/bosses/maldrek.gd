extends CharacterBody3D

signal defeated
signal encounter_started
signal summons_requested
const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")
const Spell = preload("res://game/actors/bosses/maldrek_spell.gd")
const Cues = preload("res://game/audio/combat_cues.gd")
const Models = preload("res://game/presentation/hostile_models.gd")
var player: CharacterBody3D
var health: float = 780
var max_health: float = 780
var display_name: String = "Maldrek"
var state: String = "dormant"
var phase: int = 1
var attack: String = "orb"
var attack_tempo: float = 1
var attack_index: int = 0
var elapsed: float = 0
var aim := Vector3.ZERO
var ledger: RefCounted
var spells: Array[Node3D] = []
var visual: Node3D
var staff: Node3D
var material: StandardMaterial3D
var label: Label3D
var sounds: AudioStreamPlayer3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("hostiles")
	add_to_group("bosses")
	collision_layer = 4
	collision_mask = 3
	position = Vector3(0,0.1,-4)
	if get_parent().has_method("height_at"):
		position.y += get_parent().height_at(position.x,position.z)
	var collider := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.6
	capsule.height = 2.5
	collider.shape = capsule
	collider.position.y = 1.25
	add_child(collider)
	visual = Node3D.new()
	add_child(visual)
	material = StandardMaterial3D.new()
	material.albedo_color = Color("695078")
	staff = Node3D.new()
	staff.position = Vector3(0.7,1.7,0)
	visual.add_child(staff)
	Models.build("maldrek",self,visual,staff,material)
	label = Label3D.new()
	label.font = preload("res://game/presentation/ui_style.gd").font()
	label.position.y = 3.6
	label.font_size = 24
	label.pixel_size = 0.005
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	var health_meter := preload("res://game/presentation/hostile_health.gd").new()
	add_child(health_meter)
	health_meter.setup(self, label)
	sounds = Cues.new()
	add_child(sounds)

func start() -> void:
	if state == "dormant" and health > 0:
		state = "ready"
		elapsed = 0
		encounter_started.emit()

func clear_casts() -> void:
	for spell in spells:
		if is_instance_valid(spell):
			spell.set_physics_process(false)
			spell.queue_free()
	spells.clear()

func restore_defeated() -> void:
	health = 0
	state = "dead"
	ledger = null
	clear_casts()
	collision_layer = 0
	visual.rotation.z = PI / 2

func receive_hit(_source: Vector3, base: float, multiplier: float, _guard: float) -> void:
	if health <= 0 or state == "dormant":
		return
	var result := Damage.resolve(base,multiplier,10,0,false,false,false,0)
	if not result.accepted:
		return
	health = maxf(0,health-result.damage)
	sounds.cue("hit")
	if health <= 0:
		restore_defeated()
		defeated.emit()
	elif health <= max_health/2 and phase == 1:
		phase = 2
		summons_requested.emit()

func begin_attack(kind: String) -> void:
	attack = kind
	state = "windup"
	elapsed = 0
	aim = player.global_position
	ledger = Sweep.new()
	var offset := aim-global_position
	visual.rotation.y = atan2(-offset.x,-offset.z)
	sounds.cue("windup")

func cast() -> void:
	if attack == "burst":
		return
	# Remove expired references and bound simultaneous spells even in scripted use.
	spells = spells.filter(func(spell): return is_instance_valid(spell) and not spell.is_queued_for_deletion())
	if spells.size() >= 3:
		return
	var spell := Spell.new()
	spell.player = player
	spell.kind = attack
	spell.tempo = attack_tempo
	if attack == "orb":
		spell.position = global_position + Vector3.UP
		spell.direction = (aim + Vector3.UP - spell.position).normalized()
	else:
		spell.position = Vector3(aim.x,aim.y+0.05,aim.z)
	get_parent().add_child(spell)
	spells.append(spell)

func _physics_process(delta: float) -> void:
	material.albedo_color = Color("b78dc6") if state == "windup" else Color("695078")
	if health <= 0 or not is_instance_valid(player) or player.health <= 0:
		return
	if state == "dormant":
		if player.position.z < 6 and absf(player.position.x) < 10:
			start()
		return
	elapsed += delta * attack_tempo
	match state:
		"ready":
			if elapsed >= 0.8:
				var kind: String = ["orb","ground","burst"][attack_index%3]
				if kind == "burst" and player.global_position.distance_to(global_position) > 4:
					kind = "orb"
				begin_attack(kind)
				attack_index += 1
		"windup":
			staff.rotation.z = -minf(1,elapsed)*0.5
			if elapsed >= (1.1 if attack == "burst" else 0.9):
				state = "strike"
				elapsed = 0
				cast()
		"strike":
			if attack == "burst":
				Strike.swing(self,&"knight",ledger,visual.rotation.y,-PI,PI,3.5,26,1,40)
			if elapsed >= 0.2:
				state = "recover"
				elapsed = 0
		"recover":
			if elapsed >= 1.6:
				staff.rotation = Vector3.ZERO
				state = "ready"
				elapsed = 0
