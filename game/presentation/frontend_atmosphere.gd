extends Control
## Original lightweight animated embers. No simulation or campaign authority.
var clock := 0.0
var enabled := true
var exclusion_rect:=Rect2()
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	if enabled: clock += delta
	queue_redraw()
func _draw() -> void:
	if not enabled: return
	for index in range(24):
		var seed_value := float(index)*137.508
		var travel := fposmod(clock*0.025+index*0.071,1.0)
		var x := fposmod(seed_value,size.x*0.7)+sin(clock*0.5+index)*18
		var y := size.y*(1.1-travel)
		var alpha := sin(travel*PI)*0.5
		if exclusion_rect.grow(18).has_point(Vector2(x,y)): continue
		draw_circle(Vector2(x,y),1.3+fposmod(seed_value,1.7),Color(0.68,0.35,0.96,alpha))
