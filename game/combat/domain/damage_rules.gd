extends RefCounted

static func resolve(base: float, multiplier: float, defense: float, stamina: float, guarding: bool, frontal: bool, invulnerable: bool, guard_cost: float) -> Dictionary:
	for value in [base, multiplier, defense, stamina, guard_cost]:
		if not is_finite(value) or value < 0:
			return {"accepted": false, "damage": 0, "stamina": stamina, "guard_broken": false}
	if invulnerable:
		return {"accepted": false, "damage": 0, "stamina": stamina, "guard_broken": false}
	var damage: int = maxi(1, roundi(base * multiplier * 100.0 / (100.0 + defense)))
	var blocked := guarding and frontal
	return {
		"accepted": true,
		"damage": maxf(1, roundf(damage * 0.2)) if blocked else damage,
		"stamina": maxf(0, stamina - guard_cost) if blocked else stamina,
		"guard_broken": blocked and guard_cost > 0 and stamina <= guard_cost,
	}

static func in_guard_cone(forward: Vector3, to_source: Vector3) -> bool:
	var flat := Vector3(to_source.x, 0, to_source.z)
	return flat.length_squared() > 0.0001 and forward.normalized().dot(flat.normalized()) >= 0.5
