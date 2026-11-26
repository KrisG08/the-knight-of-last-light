extends CharacterBody3D

signal defeated
signal encounter_started
const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
const Cues = preload("res://game/audio/combat_cues.gd")
const Models = preload("res://game/presentation/hostile_models.gd")
const ATTACKS = {
	"crosscut": {"windup": 0.8, "active": 0.18, "recovery": 1.6, "reach": 3.2, "arc": 1.2, "damage": 20.0, "guard": 28.0},
	"thrust": {"windup": 1.05, "active": 0.28, "recovery": 1.8, "reach": 3.5, "arc": 0.22, "damage": 27.0, "guard": 40.0},
	"overhead": {"windup": 1.25, "active": 0.22, "recovery": 2.1, "reach": 3.4, "arc": 0.45, "damage": 32.0, "guard": 55.0},
}
var player: CharacterBody3D
var health: float = 600
var max_health: float = 600
var display_name: String = "Fallen Commander"
var state: String = "dormant"
var phase: int = 1
var attack: String = "crosscut"
var attack_tempo: float = 1
var elapsed: float = 0
var attack_index: int = 0
var combo_step: int = 0
var attack_yaw: float = 0
var ledger: RefCounted
var visual: Node3D
var sword: Node3D
var material: StandardMaterial3D
var sounds: AudioStreamPlayer3D
var label: Label3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("hostiles")
	add_to_group("bosses")
	collision_layer = 4
	collision_mask = 3
	position = Vector3(0, 0.1, -4)
	if get_parent().has_method("height_at"):
		position.y += get_parent().height_at(position.x,position.z)
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.6
	capsule.height = 2.6
	collision.shape = capsule
	collision.position.y = 1.3
	add_child(collision)
	visual = Node3D.new()
	add_child(visual)
	material = StandardMaterial3D.new()
	material.albedo_color = Color("6e7482")
	sword = Node3D.new()
	sword.position = Vector3(0.6, 1.7, 0)
	visual.add_child(sword)
	Models.build("commander",self,visual,sword,material)
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
	if state == "dormant" and health > 0:
		state = "approach"
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
	var result := Damage.resolve(base, multiplier, 12, 0, false, false, false, 0)
	if result.accepted:
		health = maxf(0, health - result.damage)
		sounds.cue("hit")
		if health <= 0:
			restore_defeated()
			defeated.emit()

func begin_attack(kind: String, second_cut: bool = false) -> void:
	attack = kind
	combo_step = 1 if second_cut else 0
	state = "windup"
	elapsed = 0
	ledger = Sweep.new()
	sword.rotation = Vector3.ZERO
	var offset := player.global_position - global_position
	attack_yaw = atan2(-offset.x, -offset.z)
	visual.rotation.y = attack_yaw
	sounds.cue("windup")

func _physics_process(delta: float) -> void:
	material.albedo_color = Color("b5a260") if state == "windup" else Color("6e7482")
	if health <= 0 or not is_instance_valid(player) or player.health <= 0:
		return
	if state == "dormant":
		if player.position.z < 6 and absf(player.position.x) < 10:
			start()
		return
	var step: float = delta * attack_tempo
	elapsed += step
	velocity.x = 0
	velocity.z = 0
	var offset: Vector3 = player.global_position - global_position
	offset.y = 0
	var definition: Dictionary = ATTACKS[attack]
	match state:
		"approach":
			visual.rotation.y = atan2(-offset.x, -offset.z)
			if offset.length() < 4:
				begin_attack(["crosscut", "thrust", "overhead"][attack_index % 3])
				attack_index += 1
			else:
				velocity.x = offset.normalized().x * 2.3
				velocity.z = offset.normalized().z * 2.3
		"windup":
			var windup: float = 0.65 if combo_step == 1 else definition.windup
			if attack == "overhead":
				sword.rotation.x = lerpf(0, 1.4, minf(1, elapsed / windup))
			else:
				sword.rotation.y = lerpf(0, 1.2 if combo_step == 1 else -1.2, minf(1, elapsed / windup))
			if elapsed >= windup:
				state = "strike"
				elapsed = 0
		"strike":
			var arc: float = definition.arc
			var before := lerpf(-arc, arc, clampf((elapsed - step) / definition.active, 0, 1))
			var after := lerpf(-arc, arc, clampf(elapsed / definition.active, 0, 1))
			if combo_step == 1:
				before = -before
				after = -after
			if attack == "overhead":
				sword.rotation.x = lerpf(1.4, -0.4, clampf(elapsed / definition.active, 0, 1))
			else:
				sword.rotation.y = after
			if attack == "thrust":
				velocity.x = -sin(attack_yaw) * 4 * attack_tempo
				velocity.z = -cos(attack_yaw) * 4 * attack_tempo
			Strike.swing(self, &"knight", ledger, attack_yaw, before, after, definition.reach, definition.damage, 1, definition.guard)
			if elapsed >= definition.active:
				if attack == "crosscut" and combo_step == 0:
					begin_attack("crosscut", true)
				else:
					state = "recover"
					elapsed = 0
					sword.rotation = Vector3(-0.55, 0, 0)
		"recover":
			if elapsed >= definition.recovery:
				state = "approach"
				sword.rotation = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= 18 * delta
	move_and_slide()
	position.x = clampf(position.x, -10.2, 10.2)
	position.z = clampf(position.z, -10.2, 10.2)
