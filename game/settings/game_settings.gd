extends RefCounted

const Bindings = preload("res://game/core/input_bindings.gd")
const DEFAULTS = {"sensitivity": 1.0, "invert_y": false, "ui_scale": 1.0, "master": 0.8, "music": 0.6, "effects": 0.8, "ui_volume": 0.7, "voice_volume": 0.9, "voice_enabled": true, "incoming_damage": 1.0, "enemy_tempo": 1.0, "low_graphics": false, "fullscreen": false, "menu_motion": true,"language":"en","graphics_quality":"high","frame_limit":60,"show_fps":false,"render_resolution":"profile"}
const FRAME_LIMITS=[30,60,90,120]
const LIMITS = {"sensitivity": [0.25, 3.0], "ui_scale": [1.0, 1.5], "master": [0.0, 1.0], "music": [0.0, 1.0], "effects": [0.0, 1.0], "ui_volume": [0.0, 1.0], "voice_volume": [0.0, 1.0], "incoming_damage": [0.25, 1.0], "enemy_tempo": [0.6, 1.0]}
var values: Dictionary = DEFAULTS.duplicate()
var bindings: Dictionary = {}
var path: String
var memory_only: bool
var notice: String = ""

func _init(file_path: String = "user://settings.cfg", memory: bool = false) -> void:
	path = file_path
	memory_only = memory
	Bindings.setup()
	for action in actions():
		bindings[action] = encoded_binding(action)

static func actions() -> Array:
	return ["move_forward", "move_back", "move_left", "move_right", "sprint", "jump", "dodge", "light_attack", "heavy_attack", "block", "heal", "target_lock", "cycle_target", "interact", "equipment", "journal", "pause", "companion_order"]

static func encoded_binding(action: String) -> int:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			return event.physical_keycode
		if event is InputEventMouseButton:
			return -event.button_index
	return 0

func set_value(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key):
		return false
	if key=="graphics_quality":
		if value not in ["high","balanced","performance"]: return false
		values[key]=value; values.low_graphics=value=="performance"
		return true
	if key=="frame_limit":
		if not value is int or value not in FRAME_LIMITS: return false
		values[key]=value
		return true
	if key=="render_resolution":
		if value not in ["profile","native"]: return false
		values[key]=value
		return true
	if key=="language":
		if value not in ["en","bg","ru","fr","ar"]: return false
		values[key]=value
		return true
	if LIMITS.has(key):
		if not (value is float or value is int) or not is_finite(float(value)):
			return false
		values[key] = clampf(float(value), LIMITS[key][0], LIMITS[key][1])
	elif value is bool:
		values[key] = value
		if key=="low_graphics": values.graphics_quality="performance" if value else "high"
	else:
		return false
	return true

func rebind(action: String, code: int) -> bool:
	if action not in actions() or code == 0 or code < -9 or code > 0x7fffff:
		notice = "Unsupported input"
		return false
	for other in bindings:
		if other != action and (bindings[other] == code or (other == "cycle_target" and bindings[other] == -MOUSE_BUTTON_WHEEL_UP and code == -MOUSE_BUTTON_WHEEL_DOWN)):
			notice = "Already bound to " + other.replace("_", " ")
			return false
	bindings[action] = code
	apply_bindings()
	notice = "Binding updated"
	return true

func apply_bindings() -> void:
	for action in bindings:
		InputMap.action_erase_events(action)
		var code: int = bindings[action]
		if code > 0:
			var key := InputEventKey.new()
			key.physical_keycode = code
			InputMap.action_add_event(action, key)
		else:
			var mouse := InputEventMouseButton.new()
			mouse.button_index = -code
			InputMap.action_add_event(action, mouse)
			if action == "cycle_target" and code == -MOUSE_BUTTON_WHEEL_UP:
				var down := InputEventMouseButton.new()
				down.button_index = MOUSE_BUTTON_WHEEL_DOWN
				InputMap.action_add_event(action, down)

func hint(action: String) -> String:
	if preload("res://game/presentation/mobile_controls.gd").requested():
		return {"interact":"Use", "journal":"Journal", "pause":"Menu"}.get(action, action.replace("_", " ").capitalize())
	var code: int = bindings.get(action, 0)
	if code > 0:
		return OS.get_keycode_string(code)
	return {-1: "LMB", -2: "RMB", -3: "MMB", -4: "Wheel ↑", -5: "Wheel ↓"}.get(code, "Mouse %d" % -code)

func load_settings() -> void:
	if memory_only:
		return
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return
	for key in DEFAULTS:
		if key=="graphics_quality" and not config.has_section_key("settings",key): continue
		set_value(key, config.get_value("settings", key, DEFAULTS[key]))
	# Validate bindings as one set, rejecting the entire set on conflicts.
	var candidate: Dictionary = {}
	var seen: Dictionary = {}
	for action in bindings:
		var code: Variant = config.get_value("bindings", action, bindings[action])
		if action == "companion_order" and not config.has_section_key("bindings", action) and seen.has(code):
			for fallback in [KEY_C, KEY_V, KEY_B, KEY_F6]:
				if not seen.has(fallback):
					code = fallback
					break
		if not code is int or code == 0 or code < -9 or code > 0x7fffff or seen.has(code):
			notice = "Invalid controls ignored; defaults retained"
			return
		candidate[action] = code
		seen[code] = true
	if candidate.get("cycle_target") == -MOUSE_BUTTON_WHEEL_UP:
		for action in candidate:
			if action != "cycle_target" and candidate[action] == -MOUSE_BUTTON_WHEEL_DOWN:
				notice = "Conflicting mouse-wheel controls ignored"
				return
	bindings = candidate
	apply_bindings()

func save_settings() -> bool:
	if memory_only:
		return true
	var config := ConfigFile.new()
	for key in values:
		config.set_value("settings", key, values[key])
	for action in bindings:
		config.set_value("bindings", action, bindings[action])
	var result := config.save(path + ".tmp")
	if result == OK:
		result = DirAccess.rename_absolute(path + ".tmp", path)
	notice = "Settings saved" if result == OK else "Settings could not be saved; changes apply this session"
	return result == OK

func restore_defaults() -> void:
	values = DEFAULTS.duplicate()
	var keys := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "sprint": KEY_SHIFT, "jump": KEY_F, "dodge": KEY_SPACE, "heavy_attack": KEY_Q, "heal": KEY_R, "interact": KEY_E, "equipment": KEY_TAB, "journal": KEY_J, "pause": KEY_ESCAPE, "companion_order": KEY_C}
	bindings = keys
	bindings.merge({"light_attack": -1, "block": -2, "target_lock": -3, "cycle_target": -4})
	apply_bindings()

func apply_audio() -> void:
	for bus_name in ["Music", "SFX", "UI", "Voice"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
			AudioServer.set_bus_send(AudioServer.bus_count - 1, "Master")
	for bus_name in {"Master": "master", "Music": "music", "SFX": "effects", "UI": "ui_volume", "Voice": "voice_volume"}:
		var index := AudioServer.get_bus_index(bus_name)
		var level: float = values[{"Master": "master", "Music": "music", "SFX": "effects", "UI": "ui_volume", "Voice": "voice_volume"}[bus_name]]
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(level, 0.0001)))
		AudioServer.set_bus_mute(index, level == 0)
