extends Control
## Touch adapter: owns fingers, not combat rules. --touch enables desktop review.
var game: Node
var fingers: Dictionary = {}
var held: Dictionary = {}
var stick := Vector2.ZERO
var active := false
var pad := Vector2.ZERO
var buttons: Dictionary = {}
var gestures: Dictionary = {}
var pulses: Dictionary = {}
var context_action := "heal"
var pause_taps: Dictionary = {}
var look_taps: Dictionary = {}
const HEAVY_HOLD := 0.36

static func requested() -> bool:
	return OS.has_feature("android") or OS.has_feature("ios") or "--touch" in OS.get_cmdline_user_args()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout_controls()

func layout_controls() -> void:
	var extent := get_viewport_rect().size
	var inset: Vector4 = preload("res://game/presentation/mobile_display.gd").safe_margins(extent)
	pad = Vector2(111 + inset.x, extent.y - 115 - inset.w)
	buttons.clear()
	var corner := Vector2(extent.x - 82 - inset.z, extent.y - 82 - inset.w)
	buttons.attack = corner
	buttons.dodge = corner + Vector2(-133, 0)
	buttons.block = corner + Vector2(0, -133)
	buttons.context = corner + Vector2(-133, -133)

func _process(delta: float) -> void:
	var playable: bool = is_instance_valid(game) and is_instance_valid(game.player) and game.player.enabled and game.player.health > 0 and not get_tree().paused and not game.transitioning
	if not playable and active:
		active = false
		release_all()
	active = playable
	visible = active
	layout_controls()
	if active:
		context_action = "interact" if game.focus() != "" and not game.in_combat() else "heal"
		advance_gestures(delta)
	queue_redraw()

func advance_gestures(delta: float) -> void:
	for tap in look_taps.values(): tap.elapsed += delta
	for index in gestures.keys():
		if not gestures.has(index):
			continue
		gestures[index].elapsed += delta
		var gesture: Dictionary = gestures[index]
		if gesture.action == "attack" and not gesture.fired and gesture.elapsed >= HEAVY_HOLD:
			gestures[index].fired = true
			fire_attack("heavy_attack")

func _physics_process(_delta: float) -> void:
	for action in pulses.keys():
		pulses[action] -= 1
		if pulses[action] <= 0:
			pulses.erase(action)
			send(action, false)

func pulse(action: String) -> void:
	pulses[action] = 2
	send(action, true)

func fire_attack(action: String) -> void:
	if is_instance_valid(game) and is_instance_valid(game.player) and not is_instance_valid(game.player.target):
		game.player.select_target(false)
	pulse(action)

func _input(event: InputEvent) -> void:
	if not active:
		return
	if is_instance_valid(game) and (game.get_tree().paused or game.transitioning or not game.player.enabled):
		# Released actions generate input events too. Deactivate before dispatching them.
		active = false; release_all()
		return
	if event is InputEventScreenTouch:
		if event.pressed and not event.canceled:
			if pause_rect().has_point(event.position):
				fingers[event.index] = "pause_hud"
				pause_taps[event.index] = event.position
				get_viewport().set_input_as_handled()
				return
			var action := hit_button(event.position)
			if action != "":
				if action in ["attack", "context", "dodge"] and fingers.values().has(action):
					get_viewport().set_input_as_handled()
					return
				fingers[event.index] = action
				if action in ["attack", "context", "dodge"]:
					gestures[event.index] = {"action":action,"elapsed":0.0,"fired":false,"tap_action":context_action,"origin":event.position}
				else:
					press(action)
			elif event.position.distance_to(pad) < 110 and not fingers.values().has("stick"):
				fingers[event.index] = "stick"
				move_stick(event.position)
			elif event.position.x > get_viewport_rect().size.x * 0.4 and not fingers.values().has("look"):
				fingers[event.index] = "look"
				look_taps[event.index] = {"origin":event.position,"travel":0.0,"elapsed":0.0}
			elif event.position.x <= get_viewport_rect().size.x * 0.4:
				fingers[event.index] = "target_tap"
				look_taps[event.index] = {"origin":event.position,"travel":0.0,"elapsed":0.0}
		else:
			release_finger(event.index, event.canceled)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and fingers.has(event.index):
		if fingers[event.index] == "dodge" and gestures.has(event.index):
			var gesture: Dictionary = gestures[event.index]
			var offset: Vector2 = event.position-gesture.origin
			if not gesture.fired and offset.y<=-44 and absf(offset.x)<65:
				gestures[event.index].fired = true
				pulse("jump")
		if fingers[event.index] == "pause_hud" and event.position.distance_to(pause_taps.get(event.index,event.position)) > 22:
			pause_taps.erase(event.index)
		if fingers[event.index] == "stick":
			move_stick(event.position)
		elif fingers[event.index] in ["look", "target_tap"]:
			if look_taps.has(event.index): look_taps[event.index].travel += event.relative.length()
			if fingers[event.index] == "look":
				if look_taps.get(event.index,{}).get("travel",0.0) > 24: game.player.target = null
				game.player.apply_look(event.relative.limit_length(100))
		get_viewport().set_input_as_handled()

func hit_button(at: Vector2) -> String:
	for action in buttons:
		if Rect2(buttons[action]-Vector2(52,52),Vector2(104,104)).has_point(at):
			return action
	return ""

func pause_rect() -> Rect2:
	if not is_instance_valid(game) or not is_instance_valid(game.hud_panel): return Rect2()
	var panel: Rect2 = game.hud_panel.get_global_rect()
	return Rect2(Vector2(panel.end.x+12,panel.position.y),Vector2(96,48))

func send(action: String, down: bool, strength: float = 1.0) -> void:
	if down:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)
	var event := InputEventAction.new()
	event.action = action
	event.pressed = down
	event.strength = strength if down else 0.0
	Input.parse_input_event(event)

func press(action: String) -> void:
	held[action] = int(held.get(action, 0)) + 1
	if held[action] == 1:
		send(action, true)

func release_finger(index: int, canceled: bool = false) -> void:
	var action: String = fingers.get(index, "")
	fingers.erase(index)
	if look_taps.has(index):
		var tap: Dictionary = look_taps[index]
		look_taps.erase(index)
		if not canceled and tap.travel <= 18 and tap.elapsed <= 0.32 and is_instance_valid(game):
			game.player.select_target_at(tap.origin)
	if action == "pause_hud":
		var valid_tap := pause_taps.has(index)
		pause_taps.erase(index)
		if valid_tap and not canceled: pulse("pause")
	if gestures.has(index):
		var gesture: Dictionary = gestures[index]
		gestures.erase(index)
		if not canceled and not gesture.fired:
			if action == "attack":
				fire_attack("light_attack")
			elif action == "dodge":
				pulse("dodge")
			else:
				pulse(gesture.tap_action)
	if action == "stick":
		move_stick(pad)
	elif held.has(action):
		held[action] -= 1
		if held[action] <= 0:
			held.erase(action)
			send(action, false)

func move_stick(at: Vector2) -> void:
	stick = ((at - pad) / 75.0).limit_length(1)
	if stick.length() < 0.16:
		stick = Vector2.ZERO
	send("sprint", stick.length() >= 0.95)
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		var amount: float = {"move_left":maxf(0,-stick.x),"move_right":maxf(0,stick.x),"move_forward":maxf(0,-stick.y),"move_back":maxf(0,stick.y)}[action]
		send(action, amount > 0, amount)

func release_all() -> void:
	pause_taps.clear()
	look_taps.clear()
	gestures.clear()
	for action in pulses.keys():
		send(action, false)
	pulses.clear()
	for action in held.keys():
		send(action, false)
	held.clear()
	fingers.clear()
	move_stick(pad)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		release_all()

func _exit_tree() -> void:
	release_all()

func _draw() -> void:
	if not active: return
	var accent := Color("d4b5ff")
	var style = preload("res://game/presentation/ui_style.gd")
	var icons = preload("res://game/presentation/action_icons.gd")
	draw_circle(pad,94,Color(0.025,0.035,0.045,0.48))
	draw_arc(pad,94,0,TAU,64,Color(0.65,0.73,0.74,0.45),1.5,true)
	draw_circle(pad+stick*65,30,Color(0.57,0.65,0.65,0.65))
	for action in buttons:
		var center: Vector2 = buttons[action]
		var pressed: bool = fingers.values().has(action)
		var rect := Rect2(center-Vector2(51,51),Vector2(102,102))
		var box = style.button_panel(action == "attack","pressed" if pressed else "normal")
		box.bg_color.a = 0.88 if pressed else 0.72
		box.draw(get_canvas_item(),rect)
		icons.paint(self,context_action if action == "context" else action,center,1.25,accent)
		for gesture in gestures.values():
			if gesture.action == action and action == "attack":
				draw_line(center+Vector2(-36,43),center+Vector2(-36+72*clampf(gesture.elapsed/HEAVY_HOLD,0,1),43),accent,3,true)
	var pause_area := pause_rect()
	if pause_area.has_area():
		style.button_panel(false).draw(get_canvas_item(),pause_area)
		var center := pause_area.get_center()
		for x in [-6,6]: draw_line(center+Vector2(x,-10),center+Vector2(x,10),accent,4,true)
