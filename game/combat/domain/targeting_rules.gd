extends RefCounted
## Screen intent outranks proximity; retention tolerates brief obstruction.
const ACQUIRE_RANGE := 15.0
const RELEASE_RANGE := 22.0
const OCCLUSION_GRACE := 0.6
const FRAMING_BIAS := 0.24

static func screen_score(point: Vector2, extent: Vector2, distance: float) -> float:
	var offset := (point - extent * 0.5) / maxf(extent.y, 1.0)
	return offset.length_squared() + 0.12 * distance / ACQUIRE_RANGE

static func aim_point(actor: Node3D) -> Vector3:
	return actor.global_position + Vector3.UP * float(actor.get_meta("lock_height",1.1))

static func smoothing(delta: float, speed: float) -> float:
	return 1.0 - exp(-maxf(0,delta) * speed)

static func lock_pitch(offset: Vector3) -> float:
	var elevation := atan2(offset.y,maxf(Vector2(offset.x,offset.z).length(),0.5))
	# Place the opponent above the knight's shoulders instead of behind the helmet.
	return clampf(elevation-FRAMING_BIAS,-0.8,0.4)
