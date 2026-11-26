extends RefCounted
## Original code-drawn symbols; no third-party icon pack.
static func points(center: Vector2, coordinates: Array, scale_value: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for value in coordinates: result.append(center+value*scale_value)
	return result

static func paint(canvas: CanvasItem, kind: String, center: Vector2, scale_value: float, color: Color) -> void:
	var shape: Array = []
	match kind:
		"attack": shape = [Vector2(-13,15),Vector2(12,-15),Vector2(16,-18),Vector2(16,-10),Vector2(-9,18)]
		"block": shape = [Vector2(-15,-15),Vector2(15,-15),Vector2(14,4),Vector2(0,19),Vector2(-14,4),Vector2(-15,-15)]
		"heal": shape = [Vector2(-6,-17),Vector2(6,-17),Vector2(6,-7),Vector2(14,2),Vector2(13,16),Vector2(-13,16),Vector2(-14,2),Vector2(-6,-7),Vector2(-6,-17)]
		"interact": shape = [Vector2(0,-18),Vector2(18,0),Vector2(0,18),Vector2(-18,0),Vector2(0,-18)]
		"dodge":
			canvas.draw_arc(center,14*scale_value,-PI*0.85,PI*0.5,24,color,3*scale_value,true)
			shape = [Vector2(-8,9),Vector2(0,17),Vector2(8,9)]
	if not shape.is_empty(): canvas.draw_polyline(points(center,shape,scale_value),color,2.5*scale_value,true)
	if kind == "attack":
		canvas.draw_line(center+Vector2(-15,2)*scale_value,center+Vector2(0,15)*scale_value,color,3*scale_value,true)
	if kind in ["heal","interact"]:
		canvas.draw_line(center+Vector2(-5,0)*scale_value,center+Vector2(5,0)*scale_value,color,2*scale_value,true)
		canvas.draw_line(center+Vector2(0,-5)*scale_value,center+Vector2(0,5)*scale_value,color,2*scale_value,true)
