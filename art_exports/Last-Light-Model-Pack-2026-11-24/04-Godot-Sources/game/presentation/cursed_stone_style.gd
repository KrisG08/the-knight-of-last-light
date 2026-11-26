extends StyleBox
## Shared stone slab rendering; decoration never owns text, input or layout.
const STONE=preload("res://assets/ui/cursed-stone/basalt-v1.png")
var bg_color:=Color("17202c")
var border_color:=Color("b267e8")
var glow:=0.65
var rim:=6.0
var shadow_size:=4.0
var shadow_offset:=Vector2(0,3)
var shadow_color:=Color(0,0,0,0.45)

func _get_minimum_size() -> Vector2:
	# Native content margins own layout; the texture never enlarges hit targets.
	return Vector2.ZERO

func _get_draw_rect(rect: Rect2) -> Rect2:
	return rect.grow(shadow_size+1)

func silhouette(rect: Rect2, cut: float) -> PackedVector2Array:
	var p:=rect.position; var s:=rect.size
	return PackedVector2Array([p+Vector2(cut,0),p+Vector2(s.x-cut*1.4,0),p+Vector2(s.x,cut*0.7),p+Vector2(s.x,s.y-cut),p+Vector2(s.x-cut*0.8,s.y),p+Vector2(cut*1.5,s.y),p+Vector2(0,s.y-cut*0.6),p+Vector2(0,cut)])

func fractures(rect: Rect2) -> Array[PackedVector2Array]:
	# Connected, unequal plate seams. Keep the caption area free of luminous cuts.
	var w:=rect.size.x; var h:=rect.size.y
	var top:=minf(get_content_margin(SIDE_TOP)*0.58,h*0.20)
	var left:=minf(get_content_margin(SIDE_LEFT)*0.50,w*0.08)
	var right:=minf(get_content_margin(SIDE_RIGHT)*0.50,w*0.08)
	var a:=Vector2(w*0.12,top*0.78)
	var b:=Vector2(left*0.82,h*0.33)
	var c:=Vector2(w-right*0.85,h*0.30)
	var d:=Vector2(w*0.73,h-top*0.65)
	var paths: Array[PackedVector2Array]=[
		PackedVector2Array([Vector2(w*0.21,1),Vector2(w*0.17,top*0.35),a,Vector2(left*1.08,top),b,Vector2(left*0.46,h*0.48),Vector2(1,h*0.61)]),
		PackedVector2Array([a,Vector2(w*0.08,top*0.40),Vector2(w*0.055,1)]),
		PackedVector2Array([b,Vector2(left*0.35,h*0.24),Vector2(1,h*0.21)]),
		PackedVector2Array([Vector2(w*0.83,1),Vector2(w*0.87,top*0.55),Vector2(w-right*1.2,top),c,Vector2(w-right*0.40,h*0.43),Vector2(w-1,h*0.49)]),
		PackedVector2Array([c,Vector2(w-right*0.3,h*0.20),Vector2(w-1,h*0.13)]),
		PackedVector2Array([Vector2(w*0.56,h-1),Vector2(w*0.61,h-top*0.48),Vector2(w*0.66,h-top*0.93),d,Vector2(w*0.81,h-top*0.88),Vector2(w*0.88,h-1)]),
		PackedVector2Array([d,Vector2(w*0.76,h-top*0.22),Vector2(w*0.78,h-1)]),
		PackedVector2Array([Vector2(1,h*0.79),Vector2(left*0.65,h*0.76),Vector2(left,h-top),Vector2(w*0.08,h-top*0.57),Vector2(w*0.11,h-1)])
	]
	for index in range(paths.size()):
		paths[index]=weather_path(paths[index],rect)
	return paths

func weather_path(points: PackedVector2Array, rect: Rect2) -> PackedVector2Array:
	var result:=PackedVector2Array()
	for index in range(points.size()-1):
		var start:=points[index]; var finish:=points[index+1]
		var tangent: Vector2=(finish-start).normalized()
		var normal:=Vector2(-tangent.y,tangent.x)
		var steps:=clampi(ceili(start.distance_to(finish)/8.0),1,20)
		for step in range(steps):
			var fraction:=float(step)/float(steps)
			var point:=start.lerp(finish,fraction)
			var grain:=sin(point.x*1.73+point.y*2.37)*sin(point.x*0.63-point.y*1.21)
			point+=normal*grain*1.65*sin(fraction*PI)
			point=point.clamp(Vector2.ONE,rect.size-Vector2.ONE)
			result.append(point+rect.position)
	result.append(points[-1]+rect.position)
	return result

func draw_fracture(canvas: RID, path: PackedVector2Array, strength: float, branch: bool) -> void:
	var width:=0.65 if branch else 1.0
	# Recess and raised stone lip give the seam depth before the light is added.
	RenderingServer.canvas_item_add_polyline(canvas,path,PackedColorArray([Color(0.005,0.008,0.015,0.90*bg_color.a)]),4.0*width,true)
	var lip:=path.duplicate()
	for index in range(lip.size()): lip[index]+=Vector2(0,-0.8)
	RenderingServer.canvas_item_add_polyline(canvas,lip,PackedColorArray([Color(0.35,0.41,0.50,0.32*bg_color.a)]),1.0,true)
	RenderingServer.canvas_item_add_polyline(canvas,path,PackedColorArray([Color(border_color,0.07*strength)]),10.0*width,true)
	RenderingServer.canvas_item_add_polyline(canvas,path,PackedColorArray([Color(border_color,0.20*strength)]),5.0*width,true)
	RenderingServer.canvas_item_add_polyline(canvas,path,PackedColorArray([Color(border_color,0.78*strength)]),1.7*width,true)
	RenderingServer.canvas_item_add_polyline(canvas,path,PackedColorArray([Color(border_color.lightened(0.22),0.65*strength)]),0.60*width,true)

func _draw(canvas: RID, rect: Rect2) -> void:
	if rect.size.x<2 or rect.size.y<2: return
	var reach:=minf(rim,minf(rect.size.x,rect.size.y)*0.09)
	var outline:=silhouette(rect,maxf(2,reach))
	var shadow:=outline.duplicate()
	for index in range(shadow.size()): shadow[index]+=shadow_offset
	RenderingServer.canvas_item_add_polygon(canvas,shadow,PackedColorArray([shadow_color]))
	RenderingServer.canvas_item_add_polygon(canvas,outline,PackedColorArray([Color(0.025,0.04,0.06,bg_color.a)]))
	var inner:=rect.grow(-maxf(2,reach*0.65))
	RenderingServer.canvas_item_add_texture_rect(canvas,inner,STONE.get_rid(),true,Color(0.65,0.77,0.92,bg_color.a))
	# Quiet ink-like center makes small captions readable over the mineral grain.
	RenderingServer.canvas_item_add_rect(canvas,inner,Color(bg_color.r,bg_color.g,bg_color.b,0.48*bg_color.a))
	var edge:=outline.duplicate(); edge.append(outline[0])
	RenderingServer.canvas_item_add_polyline(canvas,edge,PackedColorArray([Color(0.16,0.23,0.30,bg_color.a)]),1.0,true)
	RenderingServer.canvas_item_add_polyline(canvas,PackedVector2Array([outline[0],outline[1],outline[2]]),PackedColorArray([Color(0.31,0.42,0.49,0.40*bg_color.a)]),1.0,true)
	var strength:=glow*border_color.a
	var paths:=fractures(rect)
	for index in range(paths.size()):
		draw_fracture(canvas,paths[index],strength,index in [1,2,4,6])
