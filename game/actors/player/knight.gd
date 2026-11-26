extends CharacterBody3D

const Rules = preload("res://game/actors/player/movement_rules.gd")
const Combat = preload("res://game/actors/player/knight_combat.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
const Model = preload("res://game/presentation/meshy_models.gd")
const Cues = preload("res://game/audio/combat_cues.gd")
const Targeting = preload("res://game/combat/domain/targeting_rules.gd")
signal died
signal looked
signal reset_requested
var health: float = 100
var max_health: float = 100
var weapon_damage: float = 22
var defense: float = 10
var flask_healing: float = 45
var healing_charges: int = 3
var combat: RefCounted
var sword_pivot: Node3D
var target: CharacterBody3D
var occluded_for: float = 0
var sounds: AudioStreamPlayer3D
var stamina: float = 100.0
var dodge_left: float = 0.0
var regeneration_delay: float = 0.0
var dodge_direction := Vector3.FORWARD
var yaw: float = 0.0
var pitch: float = -0.25
var pivot: Node3D
var arm: SpringArm3D
var visual: Node3D
var enabled: bool = false
var discard_mouse_events: int = 2
var input_grace_ticks: int = 0
var sensitivity: float = 1.0
var invert_y: bool = false
var incoming_damage: float = 1.0
var debug_reset: bool = true
var step_timer: float = 0
var model: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("knight")
	combat = Combat.new(self)
	sounds = Cues.new()
	add_child(sounds)
	collision_layer = 2
	collision_mask = 5
	floor_snap_length = 0.3
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	visual = Node3D.new()
	add_child(visual)
	sword_pivot = Node3D.new()
	sword_pivot.position = Vector3(0,1,0)
	visual.add_child(sword_pivot)
	model = Model.knight(visual,sword_pivot)
	if not "--legacy-locomotion" in OS.get_cmdline_user_args():
		var locomotion := preload("res://game/presentation/knight_locomotion.gd").new()
		locomotion.setup(self,model)
		visual.add_child(locomotion)
		model.skeletal_locomotion = locomotion
	pivot = Node3D.new()
	pivot.position.y = 1.45
	pivot.rotation = Vector3(pitch, yaw, 0)
	add_child(pivot)
	arm = SpringArm3D.new()
	arm.process_mode = Node.PROCESS_MODE_ALWAYS
	arm.spring_length = 4.0
	arm.margin = 0.15
	arm.collision_mask = 1
	var sweep := SphereShape3D.new()
	sweep.radius = 0.18
	arm.shape = sweep
	arm.add_excluded_object(get_rid())
	pivot.add_child(arm)
	var camera := Camera3D.new()
	camera.current = true
	camera.fov = 70
	camera.far = 6500
	arm.add_child(camera)

func part(at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	mesh.position = at
	visual.add_child(mesh)
	return mesh

func _unhandled_input(event: InputEvent) -> void:
	if enabled and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		if discard_mouse_events > 0 or event.relative.length() > 150:
			discard_mouse_events = maxi(0, discard_mouse_events - 1)
			return
		apply_look(event.relative)

func apply_look(relative: Vector2) -> void:
	if relative.length() > 2: looked.emit()
	yaw -= relative.x * 0.003 * sensitivity
	pitch = clampf(pitch - relative.y * 0.003 * sensitivity * (-1 if invert_y else 1), -1.1, 0.45)

func reset_position() -> void:
	position = Vector3(0, 0.2, 7)
	velocity = Vector3.ZERO
	dodge_left = 0
	stamina = 100
	regeneration_delay = 0
	yaw = 0
	pitch = -0.25
	health = max_health
	healing_charges = 3
	target = null
	if combat:
		combat.state = "locomotion"
		combat.elapsed = 0
		combat.ledger = null
		combat.clear_buffer()
		sword_pivot.rotation = Vector3.ZERO

func receive_hit(source: Vector3, base: float, multiplier: float, guard: float) -> void:
	combat.receive_hit(source, base, multiplier, guard)

func update_target(delta: float) -> void:
	if Input.is_action_just_pressed("target_lock"):
		if is_instance_valid(target):
			target = null
		else:
			select_target(false)
	if Input.is_action_just_pressed("cycle_target"):
		select_target(true)
	if is_instance_valid(target):
		occluded_for = 0 if Strike.visible(self, target) else occluded_for + delta
		if target.health <= 0 or global_position.distance_to(target.global_position) > Targeting.RELEASE_RANGE or occluded_for > Targeting.OCCLUSION_GRACE:
			target = null
		else:
			var offset := Targeting.aim_point(target) - pivot.global_position
			yaw = lerp_angle(yaw, atan2(-offset.x, -offset.z), Targeting.smoothing(delta,8))
			pitch = lerpf(pitch,Targeting.lock_pitch(offset),Targeting.smoothing(delta,5))
			if combat.can_act() and dodge_left <= 0:
				visual.rotation.y = atan2(-offset.x, -offset.z)

func target_candidates() -> Array[CharacterBody3D]:
	var candidates: Array[CharacterBody3D] = []
	var camera := arm.get_child(0) as Camera3D
	for hostile in get_tree().get_nodes_in_group("hostiles"):
		if hostile.health > 0 and global_position.distance_to(hostile.global_position) <= Targeting.ACQUIRE_RANGE and Strike.visible(self, hostile) and camera.is_position_in_frustum(Targeting.aim_point(hostile)):
			candidates.append(hostile)
	return candidates

func select_target(cycle: bool) -> void:
	var candidates := target_candidates()
	if candidates.is_empty(): return
	var camera := arm.get_child(0) as Camera3D
	if cycle:
		# Stable left-to-right cycling instead of changing order as enemies move closer.
		candidates.sort_custom(func(a,b): return camera.unproject_position(Targeting.aim_point(a)).x < camera.unproject_position(Targeting.aim_point(b)).x)
		var index := candidates.find(target)
		target = candidates[(index+1) % candidates.size()]
	else:
		candidates.sort_custom(func(a,b): return _target_score(a,camera) < _target_score(b,camera))
		target = candidates[0]
	occluded_for = 0

func _target_score(actor: CharacterBody3D, camera: Camera3D) -> float:
	return Targeting.screen_score(camera.unproject_position(Targeting.aim_point(actor)),
		get_viewport().get_visible_rect().size,global_position.distance_to(actor.global_position))

func select_target_at(point: Vector2) -> bool:
	var camera := arm.get_child(0) as Camera3D
	var radius := clampf(get_viewport().get_visible_rect().size.y * 0.085,44,84)
	var best: CharacterBody3D
	var best_distance := radius
	var candidates := target_candidates()
	# A retained lock may be beyond acquisition range; tapping it must still unlock.
	if is_instance_valid(target) and target.health > 0 and not candidates.has(target):
		if global_position.distance_to(target.global_position) <= Targeting.RELEASE_RANGE and Strike.visible(self,target) and camera.is_position_in_frustum(Targeting.aim_point(target)):
			candidates.append(target)
	for hostile in candidates:
		# A capsule around the visible body accepts head/body taps, not only the marker.
		var height := float(hostile.get_meta("lock_height",1.1))
		var lower := camera.unproject_position(hostile.global_position+Vector3.UP*height*.2)
		var upper := camera.unproject_position(hostile.global_position+Vector3.UP*height*1.65)
		var nearest := Geometry2D.get_closest_point_to_segment(point,lower,upper)
		var distance := point.distance_to(nearest)
		if distance < best_distance:
			best_distance = distance
			best = hostile
	if best == null: return false
	target = null if best == target else best
	occluded_for = 0
	return true

func _physics_process(delta: float) -> void:
	pivot.rotation = Vector3(pitch, yaw, 0)
	if not enabled:
		return
	if health <= 0:
		return
	if input_grace_ticks > 0:
		input_grace_ticks -= 1
		return
	update_target(delta)
	pivot.rotation = Vector3(pitch,yaw,0)
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := Rules.direction(input, yaw)
	regeneration_delay = maxf(0, regeneration_delay - delta)
	if Input.is_action_just_pressed("dodge") and combat.can_act() and Rules.can_dodge(is_on_floor(), dodge_left > 0):
		combat.clear_buffer()
		combat.state = "locomotion"
		dodge_left = 0.65
		sounds.cue("dodge")
		dodge_direction = direction if direction.length() > 0.1 else -visual.basis.z
	combat.tick(delta)
	# A lethal strike can synchronously hand control to a paused cinematic.
	if not enabled or get_tree().paused:
		return
	var sprinting: bool = Input.is_action_pressed("sprint") and direction.length() > 0.1 and stamina >= 10 * delta and dodge_left <= 0 and combat.state == "locomotion"
	if dodge_left > 0:
		dodge_left = maxf(0, dodge_left - delta)
		velocity.x = dodge_direction.x * 8
		velocity.z = dodge_direction.z * 8
	else:
		var speed: float = 6.5 if sprinting else 4.5
		if combat.state == "block":
			speed = 2
		elif combat.state != "locomotion":
			speed = 0
		velocity.x = move_toward(velocity.x, direction.x * speed, 18 * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, 18 * delta)
		if sprinting:
			stamina -= 10 * delta
			regeneration_delay = 0.8
		if Input.is_action_just_pressed("jump") and is_on_floor() and combat.state == "locomotion":
			velocity.y = 6
	if regeneration_delay <= 0 and not sprinting:
		stamina = minf(100, stamina + 22 * delta)
	if not is_on_floor():
		velocity.y -= 18 * delta
	if direction.length() > 0.1 and combat.can_act() and not is_instance_valid(target):
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-direction.x, -direction.z), 12 * delta)
	move_and_slide()
	var stride := sin(Time.get_ticks_msec()*0.012)*minf(0.45,Vector2(velocity.x,velocity.z).length()*0.09)
	for index in range(model.legs.size()):
		model.legs[index].rotation.x = stride*(-1 if index == 0 else 1)
	step_timer -= delta
	if not model.has("skeletal_locomotion") and is_on_floor() and Vector2(velocity.x, velocity.z).length() > 1 and dodge_left <= 0 and step_timer <= 0:
		sounds.cue("step")
		step_timer = 0.3 if sprinting else 0.45
	var recovery_floor := -12.0
	var region = get_parent().get("region")
	if is_instance_valid(region) and region.has_method("height_at"):
		recovery_floor = region.height_at(position.x,position.z)-12
	if position.y < recovery_floor or (debug_reset and Input.is_action_just_pressed("reset")):
		reset_position()
		reset_requested.emit()
