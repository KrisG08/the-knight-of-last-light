extends CharacterBody3D

signal defeated
signal encounter_started
const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
const Cues = preload("res://game/audio/combat_cues.gd")
const Models = preload("res://game/presentation/hostile_models.gd")
var player: CharacterBody3D
var health: float = 500
var max_health: float = 500
var display_name: String = "Thorn Beast"
var state: String = "dormant"
var phase: int = 1
var elapsed: float = 0
var attack_tempo: float = 1
var attack: String = "lunge"
var attack_index: int = 0
var attack_yaw: float = 0
var ledger: RefCounted
var visual: Node3D
var head: Node3D
var material: StandardMaterial3D
var sounds: AudioStreamPlayer3D
var label: Label3D
var home := Vector3(0, 0.1, -4)
const ATTACKS = {
	"lunge": {"windup": 0.95, "active": 0.4, "recovery": 1.65, "reach": 2.6, "arc": 0.45, "damage": 26.0, "guard": 45.0},
	"sweep": {"windup": 1.1, "active": 0.25, "recovery": 1.8, "reach": 4.1, "arc": 1.6, "damage": 24.0, "guard": 40.0},
}

func _ready() -> void:
	if get_parent().has_method("height_at"):
		home.y += get_parent().height_at(home.x,home.z)
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("hostiles")
	add_to_group("bosses")
	collision_layer = 4
	collision_mask = 3
	position = home
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.7
	shape.height = 2.2
	collision.shape = shape
	collision.position.y = 1.1
	add_child(collision)
	visual = Node3D.new()
	add_child(visual)
	material = StandardMaterial3D.new()
	material.albedo_color = Color("526247")
	head = Node3D.new()
	head.position = Vector3(0, 1.3, -1.5)
	visual.add_child(head)
	Models.build("thorn",self,visual,head,material)
	sounds = Cues.new()
	add_child(sounds)
	label = Label3D.new()
	label.font = preload("res://game/presentation/ui_style.gd").font()
	label.position.y = 3.4
	label.font_size = 24
	label.pixel_size = 0.005
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	var health_meter := preload("res://game/presentation/hostile_health.gd").new()
	add_child(health_meter)
	health_meter.setup(self, label)

func start() -> void:
	if state != "dormant" or health <= 0:
		return
	state = "stalk"
	elapsed = 0
	encounter_started.emit()

func restore_defeated() -> void:
	health = 0
	state = "dead"
	ledger = null
	velocity = Vector3.ZERO
	collision_layer = 0
	visual.rotation.z = PI / 2

func receive_hit(_source: Vector3, base: float, multiplier: float, _guard: float) -> void:
	if health <= 0 or state == "dormant":
		return
	var result := Damage.resolve(base, multiplier, 6, 0, false, false, false, 0)
	if not result.accepted:
		return
	health = maxf(0, health - result.damage)
	sounds.cue("hit")
	if health <= 0:
		restore_defeated()
		defeated.emit()

func begin_attack(kind: String) -> void:
	attack = kind
	state = "windup"
	elapsed = 0
	ledger = Sweep.new()
	var offset := player.global_position - global_position
	attack_yaw = atan2(-offset.x, -offset.z)
	visual.rotation.y = attack_yaw
	sounds.cue("windup")

func _physics_process(delta: float) -> void:
	material.albedo_color = Color("b5a260") if state == "windup" else Color("526247")
	if health <= 0 or not is_instance_valid(player) or player.health <= 0:
		return
	if state == "dormant":
		if player.position.z < 6 and absf(player.position.x) < 10:
			start()
		return
	var action_delta: float = delta * attack_tempo
	elapsed += action_delta
	velocity.x = 0
	velocity.z = 0
	var offset: Vector3 = player.global_position - global_position
	offset.y = 0
	match state:
		"stalk":
			visual.rotation.y = atan2(-offset.x, -offset.z)
			if offset.length() < 5:
				begin_attack("lunge" if attack_index % 2 == 0 else "sweep")
				attack_index += 1
			else:
				velocity.x = offset.normalized().x * 2.4
				velocity.z = offset.normalized().z * 2.4
		"windup":
			head.rotation.x = -0.35 * minf(1, elapsed / ATTACKS[attack].windup)
			if attack == "sweep":
				head.rotation.y = -0.8 * minf(1, elapsed / ATTACKS[attack].windup)
			if elapsed >= ATTACKS[attack].windup:
				state = "strike"
				elapsed = 0
		"strike":
			var definition: Dictionary = ATTACKS[attack]
			var arc: float = definition.arc
			if attack == "lunge":
				velocity.x = -sin(attack_yaw) * 8 * attack_tempo
				velocity.z = -cos(attack_yaw) * 8 * attack_tempo
			else:
				head.rotation.y = lerpf(-0.8, 0.8, clampf(elapsed / definition.active, 0, 1))
			var before := lerpf(-arc, arc, clampf((elapsed - action_delta) / definition.active, 0, 1))
			var after := lerpf(-arc, arc, clampf(elapsed / definition.active, 0, 1))
			Strike.swing(self, &"knight", ledger, attack_yaw, before, after, definition.reach, definition.damage, 1, definition.guard)
			if elapsed >= definition.active:
				state = "recover"
				elapsed = 0
		"recover":
			if elapsed >= ATTACKS[attack].recovery:
				state = "stalk"
				head.rotation = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= 18 * delta
	move_and_slide()
	position.x = clampf(position.x, -10.2, 10.2)
	position.z = clampf(position.z, -10.2, 10.2)
