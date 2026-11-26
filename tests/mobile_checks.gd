extends RefCounted
const Touch = preload("res://game/presentation/mobile_controls.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	preload("res://game/core/input_bindings.gd").setup()
	var touch := Touch.new()
	tree.root.add_child(touch)
	touch.set_process(false)
	touch.set_physics_process(false)
	touch.active = true
	touch.move_stick(touch.pad + Vector2(75,-75))
	check.call(Input.get_vector("move_left","move_right","move_forward","move_back").length() <= 1.001 and Input.is_action_pressed("move_forward"), "Touch joystick follows named movement actions and caps diagonals")
	touch.move_stick(touch.pad + Vector2(1,1))
	check.call(not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("move_right"), "Touch joystick deadzone releases movement")
	touch.fingers[4] = "block"
	touch.fingers[5] = "block"
	touch.press("block")
	touch.press("block")
	touch.release_finger(4)
	check.call(Input.is_action_pressed("block"), "One released finger does not cancel another held guard finger")
	touch.release_finger(5)
	check.call(not Input.is_action_pressed("block"), "Last guard finger releases block")
	touch.press("light_attack")
	touch.move_stick(touch.pad + Vector2(0,-75))
	touch._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check.call(not Input.is_action_pressed("light_attack") and not Input.is_action_pressed("move_forward") and touch.fingers.is_empty(), "Focus loss flushes touch attacks, movement and finger ownership")
	var all_fit := true
	for action in touch.buttons:
		all_fit = all_fit and touch.hit_button(touch.buttons[action]) == action
	check.call(all_fit and touch.buttons.size() == 4, "Exactly four distinct primary touch buttons remain")
	touch.release_all()
	var tap := InputEventScreenTouch.new()
	tap.index = 8
	tap.position = touch.buttons.attack
	tap.pressed = true
	touch._input(tap)
	check.call(not Input.is_action_pressed("light_attack"), "Attack waits for tap or hold instead of firing both attacks")
	tap.pressed = false
	touch._input(tap)
	check.call(Input.is_action_pressed("light_attack") and not Input.is_action_pressed("heavy_attack"), "Short attack tap dispatches only light attack")
	touch.release_all()
	tap.pressed = true
	touch._input(tap)
	touch.advance_gestures(0.4)
	tap.pressed = false
	touch._input(tap)
	check.call(Input.is_action_pressed("heavy_attack") and not Input.is_action_pressed("light_attack"), "Holding attack dispatches only heavy attack, including on release")
	touch.release_all()
	tap.pressed = true
	touch._input(tap)
	tap.pressed = false
	tap.canceled = true
	touch._input(tap)
	check.call(not Input.is_action_pressed("light_attack") and not Input.is_action_pressed("heavy_attack"), "Cancelled attack gesture does not strike")
	tap.canceled = false
	touch.context_action = "interact"
	tap.position = touch.buttons.context
	tap.pressed = true
	touch._input(tap)
	tap.pressed = false
	touch._input(tap)
	check.call(Input.is_action_pressed("interact") and not Input.is_action_pressed("heal"), "Context button snapshots interaction without consuming a flask")
	touch.release_all()
	touch.context_action = "heal"
	tap.pressed = true
	touch._input(tap)
	touch.advance_gestures(0.7)
	tap.pressed = false
	touch._input(tap)
	check.call(not Input.is_action_pressed("pause") and Input.is_action_pressed("heal"), "Holding and releasing context uses one flask without opening menu")
	touch.release_all()
	touch.move_stick(touch.pad + Vector2(0,-75))
	check.call(Input.is_action_pressed("sprint"), "Full joystick tilt enables running without a fifth button")
	touch.release_all()
	check.call(not Input.is_action_pressed("sprint") and touch.pulses.is_empty() and touch.gestures.is_empty(), "Release clears sprint, pending gestures and pulses")
	tap.position = touch.buttons.dodge
	tap.pressed = true
	touch._input(tap)
	var swipe := InputEventScreenDrag.new()
	swipe.index = tap.index
	swipe.position = tap.position+Vector2(0,-55)
	touch._input(swipe)
	check.call(Input.is_action_pressed("jump") and not Input.is_action_pressed("dodge"),"Upward dodge-button swipe jumps without spending a dodge")
	tap.pressed = false
	touch._input(tap)
	check.call(not Input.is_action_pressed("dodge"),"Releasing jump swipe cannot also dodge")
	touch.release_all()
	tap.pressed = true
	touch._input(tap)
	tap.pressed = false
	touch._input(tap)
	check.call(Input.is_action_pressed("dodge") and not Input.is_action_pressed("jump"),"Short dodge tap still dodges without jumping")
	touch.release_all()
	tap.pressed = true
	touch._input(tap)
	tap.pressed = false
	tap.canceled = true
	touch._input(tap)
	check.call(not Input.is_action_pressed("dodge") and not Input.is_action_pressed("jump"),"Cancelled dodge contact performs neither action")
	tap.canceled = false
	touch.release_all()
	tap.position = touch.buttons.attack
	tap.index = 21
	tap.pressed = true
	touch._input(tap)
	tap.index = 22
	touch._input(tap)
	check.call(touch.gestures.size() == 1, "Second attack finger cannot create a second heavy/tap gesture on the same button")
	touch.release_all()
	check.call(ProjectSettings.get_setting("display/window/stretch/aspect", "keep") == "expand", "Wide mobile viewports expand rather than letterboxing the world")
	check.call(preload("res://game/presentation/ui_style.gd").BODY_FONT.base_font == preload("res://game/presentation/ui_style.gd").TITLE_FONT.base_font, "Gameplay and bold title share one font family")
	check.call(preload("res://game/presentation/ui_style.gd").BUTTON_FONT.base_font == preload("res://game/presentation/ui_style.gd").TITLE_FONT.base_font, "Buttons and bold title share one font family")
	check.call(touch.hit_button(touch.buttons.attack+Vector2(42,42)) == "attack", "Rounded-square button corners match the visible touch target")
	var settings := preload("res://game/settings/game_settings.gd").new("user://menu-test.cfg",true)
	check.call(settings.set_value("menu_motion",false) and not settings.values.menu_motion, "Menu motion can be disabled without changing game controls")
	touch.queue_free()
	await tree.process_frame
