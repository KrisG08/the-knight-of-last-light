extends CharacterBody3D

const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
var game: Node
var player: CharacterBody3D
var health: float = 70
var max_health: float = 70
var ally_id: String = "ally.lyra"
var display_name: String = "Lyra"
var attack_damage: float = 6
var defense: float = 5

var order: String = "follow"
var state: String = "follow"
var agent: NavigationAgent3D
var visual: Node3D
var nameplate: Label3D
var target: CharacterBody3D
var path_update: float = 0
var last_destination := Vector3(10000, 0, 10000)
var stuck_for: float = 0
var previous_position := Vector3.ZERO
var recovery_cooldown: float = 0
var attack_elapsed: float = -1
var attack_hit: bool = false
var attack_cooldown: float = 0
var moving: bool = false
var weapon: Node3D
var model: Dictionary = {}
var walk_clock: float = 0

func configure(id: String) -> void:
	ally_id = id
	if id == "ally.cael":
		display_name = "Sir Cael"
		max_health = 95
		health = max_health
		attack_damage = 8
		defense = 12

func setup(root: Node, spawn: Vector3) -> void:
	game = root
	player = root.player
	position = spawn
	previous_position = spawn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("companions")
	collision_layer = 8
	collision_mask = 5
	floor_snap_length = 0.3
	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.7
	collision.shape = shape
	collision.position.y = 0.85
	add_child(collision)
	visual = Node3D.new()
	add_child(visual)
	weapon = Node3D.new()
	visual.add_child(weapon)
	model = preload("res://game/presentation/friendly_models.gd").build(visual,"cael" if ally_id=="ally.cael" else "lyra",weapon)
	agent = NavigationAgent3D.new()
	agent.path_desired_distance = 0.4
	agent.target_desired_distance = 0.8
	agent.radius = 0.35
	add_child(agent)
	nameplate = Label3D.new()
	nameplate.font = preload("res://game/presentation/ui_style.gd").font()
	nameplate.position.y = 2.2
	nameplate.font_size = 24
	nameplate.pixel_size = 0.005
	nameplate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(nameplate)

func _process(delta: float) -> void:
	walk_clock += delta*7
	var weight := minf(1,Vector2(velocity.x,velocity.z).length()/2.5) if health>0 and attack_elapsed<0 else 0.0
	var legs: Array = model.get("legs",[])
	for index in range(legs.size()):
		legs[index].rotation.x = lerpf(legs[index].rotation.x,sin(walk_clock+index*PI)*0.35*weight,minf(1,delta*12))

func set_order(request: String) -> bool:
	if request not in ["follow", "hold"] or health <= 0 or state == "suspended":
		return false
	order = request
	state = request
	moving = false
	target = null
	attack_elapsed = -1
	weapon.rotation = Vector3.ZERO
	velocity.x = 0
	velocity.z = 0
	path_update = 0
	return true

func receive_hit(_source: Vector3, base: float, multiplier: float, _guard: float) -> void:
	if health <= 0 or state == "suspended":
		return
	var result := Damage.resolve(base, multiplier, defense, 0, false, false, false, 0)
	if not result.accepted:
		return
	health = maxf(0, health - result.damage)
	if health <= 0:
		state = "downed"
		attack_elapsed = -1
		weapon.rotation = Vector3.ZERO
		target = null
		velocity = Vector3.ZERO
		visual.rotation.z = PI / 2

func recover() -> void:
	health = max_health
	state = "follow"
	order = "follow"
	attack_elapsed = -1
	attack_cooldown = 0
	visual.rotation.z = 0
	weapon.rotation = Vector3.ZERO
	path_update = 0
	stuck_for = 0
	moving = false
	target = null
	show()
	collision_layer = 8

func choose_target() -> CharacterBody3D:
	var best: CharacterBody3D
	var distance: float = 5.0 if order == "follow" else 2.0
	if not game.in_combat():
		return null
	for hostile in get_tree().get_nodes_in_group("hostiles"):
		if hostile.health <= 0 or hostile.is_in_group("bosses") or hostile.global_position.distance_to(player.global_position) > 7:
			continue
		var proximity := global_position.distance_to(hostile.global_position)
		if proximity < distance and Strike.visible(self, hostile):
			best = hostile
			distance = proximity
	return best

func navigate(destination: Vector3, delta: float) -> Vector3:
	if NavigationServer3D.map_get_iteration_id(agent.get_navigation_map()) == 0:
		return Vector3.ZERO
	path_update -= delta
	if path_update <= 0 and (destination.distance_to(last_destination) > 0.6 or agent.is_navigation_finished()):
		agent.target_position = destination
		last_destination = destination
		path_update = 0.3
	var next := agent.get_next_path_position() - global_position
	next.y = 0
	return next.normalized() if next.length() > 0.1 else Vector3.ZERO

func safe_point(require_hidden: bool) -> Dictionary:
	if not is_instance_valid(game.region.navigation):
		return {"ok": false}
	var map: RID = game.region.navigation.get_navigation_map()
	if NavigationServer3D.map_get_iteration_id(map) == 0:
		return {"ok": false}
	var camera := player.arm.get_child(0) as Camera3D
	for offset in [Vector3(1.8, 0, 1.5), Vector3(-1.8, 0, 1.5), Vector3(0, 0, 3), Vector3(0, 0, -2)]:
		var point := NavigationServer3D.map_get_closest_point(map, player.global_position + offset)
		if point.distance_to(player.global_position) > 4 or point.distance_to(player.global_position) < 1:
			continue
		if require_hidden and camera.is_position_in_frustum(point + Vector3.UP):
			continue
		var ray := PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP, point + Vector3.UP, 1)
		if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		var query := PhysicsShapeQueryParameters3D.new()
		var sphere := SphereShape3D.new()
		sphere.radius = 0.35
		query.shape = sphere
		query.transform.origin = point + Vector3.UP
		query.collision_mask = 5
		if get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty():
			return {"ok": true, "position": point + Vector3(0, 0.1, 0)}
	return {"ok": false}

func recover_if_stuck() -> void:
	if game.in_combat() or order == "hold" or recovery_cooldown > 0:
		return
	var candidate := safe_point(true)
	if candidate.ok:
		global_position = candidate.position
		velocity = Vector3.ZERO
		path_update = 0
		stuck_for = 0
		recovery_cooldown = 10
		state = "regroup"
	else:
		suspend(display_name + " cannot find a safe route; regroup at a lantern or next safe passage.")

func suspend(reason: String) -> void:
	state = "suspended"
	velocity = Vector3.ZERO
	attack_elapsed = -1
	target = null
	hide()
	collision_layer = 0
	game.session.notice = reason

func _physics_process(delta: float) -> void:
	preload("res://game/localization/localizer.gd").set_text(nameplate, "%s · %s\n%d / %d" % [display_name.to_upper(), state.to_upper(), health, max_health])
	if not is_instance_valid(player) or player.health <= 0 or health <= 0 or state == "suspended":
		return
	recovery_cooldown = maxf(0, recovery_cooldown - delta)
	attack_cooldown = maxf(0, attack_cooldown - delta)
	var desired := Vector3.ZERO
	if attack_elapsed >= 0:
		attack_elapsed += delta
		if attack_elapsed < 0.35:
			weapon.rotation.y = lerpf(0, -0.8, attack_elapsed / 0.35)
		else:
			weapon.rotation.y = lerpf(-0.8, 0.8, clampf((attack_elapsed - 0.35) / 0.15, 0, 1))
		if attack_elapsed >= 0.35 and not attack_hit:
			attack_hit = true
			if is_instance_valid(target) and target.health > 0 and not target.is_in_group("bosses") and global_position.distance_to(target.global_position) < 2.1 and Strike.visible(self, target):
				target.receive_hit(global_position, attack_damage, 1, 0)
		if attack_elapsed >= 0.85:
			attack_elapsed = -1
			attack_cooldown = 1.2
			weapon.rotation = Vector3.ZERO
	else:
		target = choose_target()
		if is_instance_valid(target):
			state = "engage"
			var offset := target.global_position - global_position
			visual.rotation.y = atan2(-offset.x, -offset.z)
			if offset.length() < 1.9 and attack_cooldown <= 0:
				attack_elapsed = 0
				attack_hit = false
			elif order == "follow":
				desired = navigate(target.global_position, delta) * 3.5
		elif order == "hold":
			state = "hold"
		else:
			state = "follow"
			var separation := global_position.distance_to(player.global_position)
			if separation > 3.5:
				moving = true
			elif separation < 1.8:
				moving = false
			if moving:
				var trailing: Vector3 = player.global_position + player.visual.global_basis.z * 2 + player.visual.global_basis.x * 0.7
				desired = navigate(trailing, delta) * 4.8
	velocity.x = move_toward(velocity.x, desired.x, 16 * delta)
	velocity.z = move_toward(velocity.z, desired.z, 16 * delta)
	if not is_on_floor():
		velocity.y -= 18 * delta
	if desired.length() > 0.1 and not is_instance_valid(target):
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-desired.x, -desired.z), 10 * delta)
	move_and_slide()
	if position.y < game.region.height_at(position.x,position.z)-10:
		suspend(display_name + " lost the path; regroup at the next lantern.")
		return
	if order == "follow" and moving and global_position.distance_to(player.global_position) > 4 and global_position.distance_to(previous_position) < 0.01:
		stuck_for += delta
	else:
		stuck_for = 0
	previous_position = global_position
	if stuck_for > 4 or global_position.distance_to(player.global_position) > 20:
		recover_if_stuck()
