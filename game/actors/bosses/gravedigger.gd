extends CharacterBody3D

signal defeated
signal encounter_started
const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
const Cues = preload("res://game/audio/combat_cues.gd")
const Models = preload("res://game/presentation/hostile_models.gd")
var player: CharacterBody3D
var health: float = 420
var max_health: float = 420
var display_name: String = "The Gravedigger"
var state: String = "dormant"
var phase: int = 1
var elapsed: float = 0
var attack_index: int = 0
var attack: String = "sweep"
var attack_yaw: float = 0
var ledger: RefCounted
var visual: Node3D
var shovel: Node3D
var material: StandardMaterial3D
var sounds: AudioStreamPlayer3D
var burst_marker: MeshInstance3D
var burst_at := Vector3.ZERO
var label: Label3D
var home := Vector3(0, 0.1, -3)
var attack_tempo: float = 1.0
const ATTACKS = {
	"sweep": {"windup": 0.8, "active": 0.25, "recovery": 1.2, "reach": 3.3, "arc": 1.3, "damage": 22.0, "guard": 35.0},
	"slam": {"windup": 1.2, "active": 0.18, "recovery": 1.6, "reach": 3.8, "arc": 0.32, "damage": 28.0, "guard": 50.0},
	"grab": {"windup": 1.0, "active": 0.3, "recovery": 1.5, "reach": 2.1, "arc": 0.4, "damage": 26.0, "guard": 100.0},
	"burst": {"windup": 1.4, "active": 0.15, "recovery": 1.5, "reach": 2.4, "arc": PI, "damage": 24.0, "guard": 45.0},
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("hostiles")
	add_to_group("bosses")
	collision_layer = 4
	collision_mask = 3
	position = home
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.height = 2.8
	capsule.radius = 0.55
	collision.shape = capsule
	collision.position.y = 1.4
	add_child(collision)
	visual = Node3D.new()
	add_child(visual)
	material = StandardMaterial3D.new()
	material.albedo_color = Color("675667")
	shovel = Node3D.new()
	shovel.position.y = 1.2
	visual.add_child(shovel)
	Models.build("gravedigger",self,visual,shovel,material)
	sounds = Cues.new()
	add_child(sounds)
	label = Label3D.new()
	label.font = preload("res://game/presentation/ui_style.gd").font()
	label.position.y = 3.5
	label.font_size = 26
	label.pixel_size = 0.005
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	var health_meter := preload("res://game/presentation/hostile_health.gd").new()
	add_child(health_meter)
	health_meter.setup(self, label)
	burst_marker = MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 2.4
	disc.bottom_radius = 2.4
	disc.height = 0.04
	burst_marker.mesh = disc
	var warning := StandardMaterial3D.new()
	warning.albedo_color = Color("c69452")
	burst_marker.material_override = warning
	get_parent().add_child(burst_marker)
	burst_marker.hide()

func restore_defeated() -> void:
	health = 0
	state = "dead"
	collision_layer = 0
	ledger = null
	visual.rotation.z = PI / 2
	burst_marker.hide()

func start() -> void:
	if state != "dormant" or health <= 0:
		return
	state = "approach"
	elapsed = 0
	encounter_started.emit()

func begin_attack(kind: String) -> void:
	attack = kind
	state = "windup"
	elapsed = 0
	ledger = Sweep.new()
	var offset := player.global_position - global_position
	attack_yaw = atan2(-offset.x, -offset.z)
	visual.rotation.y = attack_yaw
	if kind == "burst":
		burst_at = player.global_position
		burst_at.y = 0.03
		burst_marker.position = burst_at
		burst_marker.show()
	sounds.cue("windup")

func receive_hit(_source: Vector3, base: float, multiplier: float, _guard: float) -> void:
	if health <= 0 or state == "dormant":
		return
	var result := Damage.resolve(base, multiplier, 8, 0, false, false, false, 0)
	if not result.accepted:
		return
	health = maxf(0, health - result.damage)
	sounds.cue("hit")
	if health <= 0:
		restore_defeated()
		defeated.emit()
	elif health <= 210 and phase == 1:
		phase = 2
		state = "phase_shift"
		elapsed = 0
		ledger = null
		shovel.rotation = Vector3.ZERO
		burst_marker.hide()
		sounds.cue("windup")

func _physics_process(delta: float) -> void:
	material.albedo_color = Color("b99a6b") if state in ["windup", "phase_shift"] else Color("675667")
	if health <= 0 or not is_instance_valid(player) or player.health <= 0:
		return
	if state == "dormant":
		if player.position.z < 5 and absf(player.position.x) < 9:
			start()
		return
	var action_delta: float = delta * attack_tempo
	elapsed += action_delta
	velocity.x = 0
	velocity.z = 0
	var offset: Vector3 = player.global_position - global_position
	offset.y = 0
	match state:
		"approach":
			visual.rotation.y = atan2(-offset.x, -offset.z)
			if offset.length() < 3.8:
				var pattern: Array = ["sweep", "slam", "grab", "burst"] if phase == 2 else ["sweep", "slam", "grab"]
				begin_attack(pattern[attack_index % pattern.size()])
				attack_index += 1
			else:
				velocity.x = offset.normalized().x * 1.8
				velocity.z = offset.normalized().z * 1.8
		"windup":
			var duration: float = ATTACKS[attack].windup
			shovel.rotation.x = minf(1, elapsed / duration) if attack in ["slam", "burst"] else 0.0
			shovel.rotation.y = -1.3 * minf(1, elapsed / duration) if attack == "sweep" else 0.0
			if attack == "grab":
				velocity = Vector3(-sin(attack_yaw) * 1.4 * attack_tempo, velocity.y, -cos(attack_yaw) * 1.4 * attack_tempo)
			if elapsed >= duration:
				state = "strike"
				elapsed = 0
		"strike":
			var definition: Dictionary = ATTACKS[attack]
			if attack == "burst":
				burst_marker.scale = Vector3(1, 4, 1)
				if player.global_position.distance_to(burst_at) < 2.8 and ledger.claim(player.get_instance_id()):
					player.receive_hit(burst_at, definition.damage, 1, definition.guard)
			else:
				var arc: float = definition.arc
				var before := lerpf(-arc, arc, clampf((elapsed - action_delta) / definition.active, 0, 1))
				var after := lerpf(-arc, arc, clampf(elapsed / definition.active, 0, 1))
				shovel.rotation.y = after
				shovel.rotation.x = 0
				Strike.swing(self, &"knight", ledger, attack_yaw, before, after, definition.reach, definition.damage, 1, definition.guard)
			if elapsed >= definition.active:
				state = "recover"
				elapsed = 0
				burst_marker.hide()
				burst_marker.scale = Vector3.ONE
		"recover":
			if elapsed >= ATTACKS[attack].recovery:
				state = "approach"
				shovel.rotation = Vector3.ZERO
		"phase_shift":
			if elapsed >= 1.4:
				state = "approach"
	if not is_on_floor():
		velocity.y -= 18 * delta
	move_and_slide()
	position.x = clampf(position.x, -8.5, 8.5)
	position.z = clampf(position.z, -8.5, 8.5)
