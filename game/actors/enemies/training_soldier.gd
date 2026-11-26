extends CharacterBody3D
signal defeated

const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
const Cues = preload("res://game/audio/combat_cues.gd")
const Models = preload("res://game/presentation/hostile_models.gd")
var player: CharacterBody3D
var health: float = 110
var state: String = "idle"
var elapsed: float = 0
var home := Vector3(-5, 0.1, -3)
var attack_yaw: float = 0
var ledger: RefCounted
var visual: Node3D
var weapon: Node3D
var label: Label3D
var material: StandardMaterial3D
var sounds: AudioStreamPlayer3D
var profile: Resource
var max_health: float = 110
var display_name: String = "Fallen Soldier"
var life_number: int = 0
var defense: float = 5
var damage: float = 24
var speed: float = 2.2
var windup: float = 0.8
var recovery: float = 1.1
var reach: float = 2.2
var tint := Color("704a47")
var use_navigation: bool = false
var agent: NavigationAgent3D
var memory_left: float = 0
var last_seen := Vector3.ZERO
var path_update: float = 0
var attack_tempo: float = 1.0
var stagger_duration := 0.4

func _ready() -> void:
	set_meta("authored_home",home)
	if get_parent().has_method("height_at"):
		home.y += get_parent().height_at(home.x,home.z)
	floor_snap_length = 0.4
	if profile != null:
		max_health = profile.maximum_health
		display_name = profile.display_name
		defense = profile.defense
		damage = profile.damage
		speed = profile.speed
		windup = profile.windup
		recovery = profile.recovery
		reach = profile.reach
		tint = profile.tint
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("hostiles")
	sounds = Cues.new()
	add_child(sounds)
	collision_layer = 4
	collision_mask = 3
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.8
	collision.shape = capsule
	collision.position.y = 0.9
	add_child(collision)
	visual = Node3D.new()
	add_child(visual)
	material = StandardMaterial3D.new()
	material.albedo_color = tint
	weapon = Node3D.new()
	weapon.position.y = 1
	visual.add_child(weapon)
	var model_id := "hound" if profile!=null and profile.hound_shape else ("villager" if display_name=="Hollow Villager" else ("shade" if display_name=="Bound Shade" else "soldier"))
	Models.build(model_id,self,visual,weapon,material)
	label = Label3D.new()
	label.font = preload("res://game/presentation/ui_style.gd").font()
	label.position.y = 2.6
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 26
	label.pixel_size = 0.006
	add_child(label)
	var health_meter := preload("res://game/presentation/hostile_health.gd").new()
	add_child(health_meter)
	health_meter.setup(self, label)
	if use_navigation:
		agent = NavigationAgent3D.new()
		agent.path_desired_distance = 0.4
		agent.target_desired_distance = 0.5
		agent.radius = 0.4
		add_child(agent)
	reset_encounter()

func reset_encounter() -> void:
	life_number += 1
	position = home
	velocity = Vector3.ZERO
	health = max_health
	state = "idle"
	elapsed = 0
	collision_layer = 4
	visual.rotation = Vector3.ZERO
	weapon.rotation = Vector3.ZERO
	ledger = null
	memory_left = 0
	path_update = 0

func receive_hit(_source: Vector3, base: float, multiplier: float, guard: float) -> void:
	if health <= 0:
		return
	var result := Damage.resolve(base, multiplier, defense, 0, false, false, false, 0)
	if not result.accepted:
		return
	health = maxf(0, health - result.damage)
	sounds.cue("death" if health <= 0 else "hit")
	state = "dead" if health <= 0 else "stagger"
	stagger_duration = 0.8 if guard >= 50 else 0.4
	elapsed = 0
	ledger = null
	if health <= 0:
		collision_layer = 0
		visual.rotation.z = PI / 2
		defeated.emit()

func _physics_process(delta: float) -> void:
	material.albedo_color = Color("dca458") if state == "windup" else tint
	if health <= 0 or not is_instance_valid(player) or player.health <= 0:
		return
	var offset: Vector3 = player.global_position - global_position
	offset.y = 0
	var action_delta: float = delta * attack_tempo
	elapsed += action_delta
	visual.rotation.x = sin(clampf(elapsed / stagger_duration,0,1)*PI) * (0.30 if stagger_duration > 0.4 else 0.14) if state == "stagger" else 0.0
	memory_left = maxf(0, memory_left - delta)
	path_update -= delta
	var seen: bool = offset.length() < 9 and player.global_position.distance_to(home) < 12 and Strike.visible(self, player)
	if seen:
		last_seen = player.global_position
		memory_left = 2.5
	velocity.x = 0
	velocity.z = 0
	match state:
		"idle", "chase":
			# This prototype uses an open training patch; never chase through walls
			# or outside its leash. Regional navigation belongs to the village.
			if seen or (use_navigation and memory_left > 0 and player.global_position.distance_to(home) < 12):
				visual.rotation.y = atan2(-offset.x, -offset.z)
				if offset.length() < reach - 0.1 and seen:
					state = "windup"
					elapsed = 0
					attack_yaw = visual.rotation.y
					ledger = Sweep.new()
					sounds.cue("windup")
				else:
					state = "chase"
					var toward := chase_direction(last_seen if use_navigation else player.global_position)
					velocity.x = toward.x * speed
					velocity.z = toward.z * speed
			else:
				state = "idle"
				if use_navigation and global_position.distance_to(home) > 0.6:
					var toward := chase_direction(home)
					velocity.x = toward.x * speed
					velocity.z = toward.z * speed
		"windup":
			weapon.rotation.y = -1.0 * minf(1, elapsed / windup)
			if elapsed >= windup:
				state = "strike"
				elapsed = 0
		"strike":
			var before := lerpf(-1, 1, clampf((elapsed - action_delta) / 0.2, 0, 1))
			var after := lerpf(-1, 1, clampf(elapsed / 0.2, 0, 1))
			weapon.rotation.y = after
			Strike.swing(self, &"knight", ledger, attack_yaw, before, after, reach, damage, 1, 35)
			if elapsed >= 0.2:
				state = "recover"
				elapsed = 0
		"recover", "stagger":
			if elapsed >= (recovery if state == "recover" else stagger_duration):
				state = "idle"
				weapon.rotation.y = 0
	if not is_on_floor():
		velocity.y -= 18 * delta
	move_and_slide()
	var recovery_floor: float = get_parent().height_at(position.x,position.z)-12 if get_parent().has_method("height_at") else -12
	if position.y < recovery_floor:
		reset_encounter()

func chase_direction(destination: Vector3) -> Vector3:
	var next := destination
	if use_navigation:
		if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0:
			return Vector3.ZERO
		if path_update <= 0:
			agent.target_position = destination
			path_update = 0.25
		next = agent.get_next_path_position()
	var offset := next - global_position
	offset.y = 0
	return offset.normalized() if offset.length() > 0.1 else Vector3.ZERO
