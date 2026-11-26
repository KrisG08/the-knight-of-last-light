extends Node
var button: Button
var tween: Tween
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	button = get_parent() as Button
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.button_down.connect(func(): animate(true))
	button.button_up.connect(func(): animate(false))
	button.visibility_changed.connect(func():
		if not button.is_visible_in_tree():
			if is_instance_valid(tween): tween.kill()
			button.scale = Vector2.ONE)
func animate(down: bool) -> void:
	if is_instance_valid(tween): tween.kill()
	button.pivot_offset = button.size/2
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(button,"scale",Vector2.ONE*(0.975 if down else 1.0),0.1)
