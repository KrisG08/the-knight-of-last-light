extends Control
## Subtle focus diamond and inset rule, mirrored with the navigation's reading direction.
var button: Button
var emphasis := 0.0
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button=get_parent() as Button
func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	var target := 1.0 if not button.disabled and (button.is_hovered() or button.has_focus()) else 0.0
	emphasis=move_toward(emphasis,target,delta*7.0)
	queue_redraw()
func _draw() -> void:
	if not is_instance_valid(button): return
	var x := size.x-18 if button.is_layout_rtl() else 18.0
	var color := Color("c4a0ff"); color.a=(0.3 if button.disabled else 0.65)+emphasis*0.25
	var at := Vector2(x,size.y/2)
	draw_polyline(PackedVector2Array([at+Vector2(0,-4),at+Vector2(4,0),at+Vector2(0,4),at+Vector2(-4,0),at+Vector2(0,-4)]),color,1.0,true)
	color.a=0.12+emphasis*0.35
	draw_line(Vector2(38,size.y-1),Vector2(size.x-16,size.y-1),color,1,true)
