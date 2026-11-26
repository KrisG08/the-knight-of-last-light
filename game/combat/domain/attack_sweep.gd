extends RefCounted

# Each instance represents exactly one swing. The angular interval is swept
# analytically, so a low frame rate cannot skip a target between samples.
var hit_ids: Dictionary = {}

func claim(target_id: int) -> bool:
	if hit_ids.has(target_id):
		return false
	hit_ids[target_id] = true
	return true

static func intersects(origin: Vector3, facing_yaw: float, target: Vector3, from_angle: float, to_angle: float, reach: float) -> bool:
	var offset := target - origin
	if absf(offset.y) > 1.5:
		return false
	offset.y = 0
	if offset.length() > reach + 0.45:
		return false
	if offset.length() < 0.45:
		return true
	var angle := wrapf(atan2(-offset.x, -offset.z) - facing_yaw, -PI, PI)
	var nearest := clampf(angle, minf(from_angle, to_angle), maxf(from_angle, to_angle))
	var ray := Vector3(-sin(facing_yaw + nearest), 0, -cos(facing_yaw + nearest))
	var closest := ray * clampf(offset.dot(ray), 0, reach)
	return offset.distance_to(closest) <= 0.45
