extends CharacterBody3D

signal defeated
signal encounter_started
const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
const Cues = preload("res://game/audio/combat_cues.gd")
const Models = preload("res://game/presentation/hostile_models.gd")
const ATTACKS = {
	"hammer_sweep": {"windup": 1.0, "active": 0.3, "recovery": 1.9, "reach": 3.6, "arc": 1.5, "damage": 30.0, "guard": 45.0},
	"forge_slam": {"windup": 1.4, "active": 0.2, "recovery": 2.4, "reach": 4.3, "arc": PI, "damage": 34.0, "guard": 60.0},
}
var player: CharacterBody3D
var health: float = 720
var max_health: float = 720
var display_name: String = "Iron Warden"
var phase: int = 1
var state: String = "dormant"
var attack: String = "hammer_sweep"
var elapsed: float = 0
var attack_tempo: float = 1
var attack_index: int = 0
var attack_yaw: float = 0
var ledger: RefCounted
var visual: Node3D
var hammer: Node3D
var material: StandardMaterial3D
var label: Label3D
var sounds: AudioStreamPlayer3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("hostiles")
	add_to_group("bosses")
	collision_layer = 4
	collision_mask = 3
	position = Vector3(0, 0.1, -4)
	if get_parent().has_method("height_at"):
		position.y += get_parent().height_at(position.x,position.z)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.8
	capsule.height = 3
	shape.shape = capsule
	shape.position.y = 1.5
	add_child(shape)
	visual = Node3D.new()
	add_child(visual)
	material = StandardMaterial3D.new()
	material.albedo_color = Color("70675d")
	hammer = Node3D.new()
	hammer.position = Vector3(0.8, 2, 0)
	visual.add_child(hammer)
	Models.build("warden",self,visual,hammer,material)
	label = Label3D.new()
	label.font = preload("res://game/presentation/ui_style.gd").font()
	label.position.y = 3.8
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
	var result := Damage.resolve(base, multiplier, 20, 0, false, false, false, 0)
	if result.accepted:
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
	hammer.rotation = Vector3.ZERO
	var offset := player.global_position - global_position
	attack_yaw = atan2(-offset.x, -offset.z)
	visual.rotation.y = attack_yaw
	sounds.cue("windup")

func _physics_process(delta: float) -> void:
	material.albedo_color = Color("d3a15d") if state == "windup" else Color("70675d")
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
	var definition: Dictionary = ATTACKS[attack]
	var offset: Vector3 = player.global_position - global_position
	offset.y = 0
	match state:
		"approach":
			visual.rotation.y = atan2(-offset.x, -offset.z)
			if offset.length() < 4.5:
				begin_attack("hammer_sweep" if attack_index % 2 == 0 else "forge_slam")
				attack_index += 1
			else:
				velocity.x = offset.normalized().x * 1.9
				velocity.z = offset.normalized().z * 1.9
		"windup":
			if attack == "forge_slam":
				hammer.rotation.x = lerpf(0, 1.4, minf(1, elapsed / definition.windup))
			else:
				hammer.rotation.y = lerpf(0, -1.5, minf(1, elapsed / definition.windup))
			if elapsed >= definition.windup:
				state = "strike"
				elapsed = 0
				sounds.cue("swing")
		"strike":
			if attack == "forge_slam":
				hammer.rotation.x = lerpf(1.4, -0.5, clampf(elapsed / definition.active, 0, 1))
				Strike.swing(self, &"knight", ledger, attack_yaw, -PI, PI, definition.reach, definition.damage, 1, definition.guard)
			else:
				var before := lerpf(-1.5, 1.5, clampf((elapsed - step) / definition.active, 0, 1))
				var after := lerpf(-1.5, 1.5, clampf(elapsed / definition.active, 0, 1))
				hammer.rotation.y = after
				Strike.swing(self, &"knight", ledger, attack_yaw, before, after, definition.reach, definition.damage, 1, definition.guard)
			if elapsed >= definition.active:
				state = "recover"
				elapsed = 0
				hammer.rotation = Vector3(-0.5, 0, 0)
		"recover":
			if elapsed >= definition.recovery:
				state = "approach"
				hammer.rotation = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= 18 * delta
	move_and_slide()
	position.x = clampf(position.x, -10.2, 10.2)
	position.z = clampf(position.z, -10.2, 10.2)
