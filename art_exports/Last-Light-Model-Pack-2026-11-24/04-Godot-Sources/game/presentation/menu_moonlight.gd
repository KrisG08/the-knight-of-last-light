extends Control
var moon: TextureRect
var foreground_clouds: ColorRect
var center:=Vector2.ZERO
var halo_radius:=0.0
var clock:=0.0
func setup() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	moon=TextureRect.new(); moon.texture=preload("res://assets/sky/curse-moon-v1.png")
	moon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	moon.mouse_filter=Control.MOUSE_FILTER_IGNORE
	moon.modulate=Color.WHITE
	var face:=ShaderMaterial.new()
	face.shader=preload("res://assets/materials/menu_moon_face.gdshader")
	face.set_shader_parameter("cloud_map",preload("res://assets/sky/storm-panorama-v1.png"))
	moon.material=face
	add_child(moon)
	foreground_clouds=ColorRect.new()
	foreground_clouds.name="MoonForegroundClouds"
	foreground_clouds.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var cloud_material:=ShaderMaterial.new()
	cloud_material.shader=preload("res://assets/materials/menu_moon_clouds.gdshader")
	foreground_clouds.material=cloud_material
	add_child(foreground_clouds)
func place(title_rect: Rect2, navigation: Rect2) -> void:
	var gap:=maxf(24,navigation.position.x-title_rect.end.x)
	var diameter:=minf(size.y*0.125,gap*0.65)
	center=Vector2((title_rect.end.x+navigation.position.x)*0.5,maxf(size.y*0.115,diameter*0.5+8))
	moon.size=Vector2.ONE*diameter
	moon.position=center-moon.size*0.5
	foreground_clouds.size=Vector2(diameter*6.0,diameter*3.0)
	foreground_clouds.position=center-foreground_clouds.size*0.5
	halo_radius=minf(diameter*0.95,gap*0.45)
	queue_redraw()
func look_toward(target: Vector2) -> void:
	if is_instance_valid(moon):
		moon.material.set_shader_parameter("gaze_direction",(target-center).normalized())
func advance(value: float) -> void:
	clock=value
	if is_instance_valid(moon):
		moon.material.set_shader_parameter("animation_clock",clock)
	if is_instance_valid(foreground_clouds):
		foreground_clouds.material.set_shader_parameter("animation_clock",clock)
	queue_redraw()
func _draw() -> void:
	if halo_radius<=0: return
	var breath:=1.0+sin(clock*TAU/12.0)*0.035
	for ring in range(20,0,-1):
		var fraction:=float(ring)/20.0
		draw_circle(center,halo_radius*fraction,Color(0.38,0.48,0.72,(1.0-fraction)*0.004*breath))
