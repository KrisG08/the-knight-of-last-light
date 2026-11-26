class_name MovementRules
extends RefCounted

static func direction(input: Vector2, yaw: float) -> Vector3:
	return (Basis(Vector3.UP, yaw) * Vector3(input.x, 0, input.y)).limit_length(1.0)

static func can_dodge(grounded: bool, active: bool) -> bool:
	return grounded and not active
