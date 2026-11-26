extends ProgressBar
## Labelled resource meter; retains ProgressBar value/max_value semantics.
var caption := "HEALTH"
var tint := Color("ce5b68")
var trail := 100.0
var initialized := false

func _ready() -> void:
	show_percentage = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(280,38)
	add_theme_stylebox_override("background",StyleBoxEmpty.new())
	add_theme_stylebox_override("fill",StyleBoxEmpty.new())

func _process(delta: float) -> void:
	if not initialized:
		trail = value
		initialized = true
	trail = maxf(value,move_toward(trail,value,max_value*delta*0.65))
	tooltip_text = "%s: %d / %d" % [caption,value,max_value]
	queue_redraw()

func _draw() -> void:
	var font: Font = preload("res://game/presentation/ui_style.gd").font()
	var text_size := 17
	var ratio := clampf(value/maxf(1,max_value),0,1)
	var track := Rect2(0,25,size.x,11)
	var frame := StyleBoxFlat.new()
	frame.bg_color = Color("121b25")
	frame.border_color = Color("80629d")
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(3)
	frame.draw(get_canvas_item(),track)
	var inner := track.grow(-2)
	if trail>value:
		draw_rect(Rect2(inner.position,Vector2(inner.size.x*clampf(trail/maxf(1,max_value),0,1),inner.size.y)),Color("c4a0ff"))
	if ratio>0:
		draw_rect(Rect2(inner.position,Vector2(inner.size.x*ratio,inner.size.y)),tint)
		draw_line(inner.position,inner.position+Vector2(inner.size.x*ratio,0),tint.lightened(0.35),1)
	for index in range(1,4):
		var x := inner.position.x+inner.size.x*index/4.0
		draw_line(Vector2(x,inner.position.y),Vector2(x,inner.end.y),Color(0.02,0.03,0.04,0.5),1)
	var title: String=preload("res://game/localization/localizer.gd").text(caption+(" · LOW" if ratio<=0.25 and value>0 else ""))
	draw_string(font,Vector2(0,18),title,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size,Color("e1e7e9"))
	var amount := "%d / %d" % [ceili(value),ceili(max_value)]
	var width := font.get_string_size(amount,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size).x
	draw_string(font,Vector2(size.x-width,18),amount,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size,tint.lightened(0.45))
