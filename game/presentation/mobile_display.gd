extends RefCounted
## World fills the screen; only controls are inset from cutouts/system gestures.
static func safe_margins(extent: Vector2) -> Vector4:
	var margins := Vector4(32,24,32,24)
	if not (OS.has_feature("android") or OS.has_feature("ios")): return margins
	var screen := Vector2(DisplayServer.screen_get_size())
	var safe := DisplayServer.get_display_safe_area()
	if screen.x <= 0 or screen.y <= 0 or safe.size.x <= 0 or safe.size.y <= 0: return margins
	margins.x = maxf(margins.x, safe.position.x * extent.x / screen.x)
	margins.y = maxf(margins.y, safe.position.y * extent.y / screen.y)
	margins.z = maxf(margins.z, (screen.x-safe.end.x) * extent.x / screen.x)
	margins.w = maxf(margins.w, (screen.y-safe.end.y) * extent.y / screen.y)
	return margins

static func apply() -> void:
	if OS.has_feature("android") or OS.has_feature("ios"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
