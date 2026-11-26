extends Node
## Dispatch menu actions through the same named input actions on every platform.
var pending: Dictionary = {}
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
func send(action: String, pressed: bool) -> void:
	if pressed: Input.action_press(action)
	else: Input.action_release(action)
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)
func pulse(action: String) -> void:
	if get_tree().paused: return
	pending[action] = 2
	send(action,true)
func _physics_process(_delta: float) -> void:
	for action in pending.keys():
		pending[action] -= 1
		if pending[action] <= 0:
			pending.erase(action)
			send(action,false)
func cancel() -> void:
	for action in pending.keys(): send(action,false)
	pending.clear()
func _exit_tree() -> void:
	cancel()
