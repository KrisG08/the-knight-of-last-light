extends RefCounted

static func setup() -> void:
	var keys := {"move_forward": KEY_W, "move_back": KEY_S, "move_left": KEY_A, "move_right": KEY_D, "sprint": KEY_SHIFT, "jump": KEY_F, "dodge": KEY_SPACE, "pause": KEY_ESCAPE, "reset": KEY_BACKSPACE, "heavy_attack": KEY_Q, "heal": KEY_R, "interact": KEY_E, "equipment": KEY_TAB, "journal": KEY_J, "companion_order": KEY_C}
	for action in keys:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventKey.new()
			event.physical_keycode = keys[action]
			InputMap.action_add_event(action, event)
	var buttons := {"light_attack": MOUSE_BUTTON_LEFT, "block": MOUSE_BUTTON_RIGHT, "target_lock": MOUSE_BUTTON_MIDDLE, "cycle_target": MOUSE_BUTTON_WHEEL_UP}
	for action in buttons:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			var event := InputEventMouseButton.new()
			event.button_index = buttons[action]
			InputMap.action_add_event(action, event)
			if action == "cycle_target":
				var down := InputEventMouseButton.new()
				down.button_index = MOUSE_BUTTON_WHEEL_DOWN
				InputMap.action_add_event(action, down)
