extends RefCounted

const Sweep = preload("res://game/combat/domain/attack_sweep.gd")

static func visible(actor: Node3D, target: Node3D) -> bool:
	var query := PhysicsRayQueryParameters3D.create(actor.global_position + Vector3.UP, target.global_position + Vector3.UP, 1)
	return actor.get_world_3d().direct_space_state.intersect_ray(query).is_empty()

static func swing(actor: Node3D, group: StringName, ledger: RefCounted, yaw: float, from_angle: float, to_angle: float, reach: float, damage: float, multiplier: float, guard_cost: float) -> void:
	var targets: Array = actor.get_tree().get_nodes_in_group(group)
	if group == &"knight":
		targets.append_array(actor.get_tree().get_nodes_in_group("companions"))
	for target in targets:
		if not is_instance_valid(target) or target.health <= 0:
			continue
		if target.is_in_group("companions") and target.state == "suspended":
			continue
		if Sweep.intersects(actor.global_position, yaw, target.global_position, from_angle, to_angle, reach) and visible(actor, target) and ledger.claim(target.get_instance_id()):
			target.receive_hit(actor.global_position, damage, multiplier, guard_cost)
