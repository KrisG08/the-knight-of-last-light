extends Control
## Layered original menu artwork. Only flexible materials move; no gameplay state.
var landscape: TextureRect
var knight: TextureRect
var foliage: TextureRect
var clock:=0.0
var movie: VideoStreamPlayer
var moonlight: Control
const MOVIE_PATH:="res://assets/cinematics/menu_wind_desktop.ogv"
const MOBILE_MOVIE_PATH:="res://assets/cinematics/menu_wind_mobile.ogv"
const LEGACY_MOVIE_PATH:="res://assets/cinematics/menu_wind_loop.ogv"
const MOVIE_SIZE:=Vector2(1280,720)
const FILM_HELMET:=Vector2(0.483,0.509)
var helmet_anchor:=-1.0
var selected_movie:=""
var movie_ready:=false

func setup(play_movie: bool=true) -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	clip_contents=true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	landscape=layer(preload("res://assets/ui/menu-wind/landscape.png"))
	landscape.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	landscape.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var distance:=ShaderMaterial.new()
	distance.shader=preload("res://assets/materials/menu_living_art.gdshader")
	distance.set_shader_parameter("clouds",preload("res://assets/sky/storm-panorama-v1.png"))
	landscape.material=distance
	knight=layer(preload("res://assets/ui/menu-wind/knight.png"))
	knight.material=wind_material(0)
	foliage=layer(preload("res://assets/ui/menu-wind/foliage.png"))
	foliage.material=wind_material(1)
	selected_movie=MOBILE_MOVIE_PATH if preload("res://game/presentation/ui_style.gd").mobile() else MOVIE_PATH
	if not ResourceLoader.exists(selected_movie):
		selected_movie=MOVIE_PATH if ResourceLoader.exists(MOVIE_PATH) else MOBILE_MOVIE_PATH
	if not ResourceLoader.exists(selected_movie): selected_movie=LEGACY_MOVIE_PATH
	if play_movie and ResourceLoader.exists(selected_movie):
		movie=VideoStreamPlayer.new()
		movie.name="WindLoopFilm"
		movie.expand=true; movie.loop=true; movie.volume=0
		movie.mouse_filter=Control.MOUSE_FILTER_IGNORE
		movie.stream=load(selected_movie) as VideoStream
		var grade:=ShaderMaterial.new()
		grade.shader=preload("res://assets/materials/menu_film_grade.gdshader")
		movie.material=grade
		add_child(movie)
		movie.play()
	if play_movie:
		moonlight=preload("res://game/presentation/menu_moonlight.gd").new()
		add_child(moonlight); moonlight.setup()
	visibility_changed.connect(func():
		if is_instance_valid(movie) and not is_visible_in_tree(): movie.paused=true)
	resized.connect(arrange)
	arrange()

func layer(texture: Texture2D) -> TextureRect:
	var item:=TextureRect.new()
	item.texture=texture; item.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	item.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(item)
	return item

func wind_material(kind: int) -> ShaderMaterial:
	var result:=ShaderMaterial.new()
	result.shader=preload("res://assets/materials/menu_wind_layer.gdshader")
	result.set_shader_parameter("layer_kind",kind)
	return result

func arrange() -> void:
	if not is_instance_valid(knight): return
	if is_instance_valid(movie):
		# Overscan preserves aspect and edge coverage while revealing the citadel.
		var cover:=maxf(size.x*1.46/MOVIE_SIZE.x,size.y/MOVIE_SIZE.y)
		movie.size=MOVIE_SIZE*cover
		var target_x:=helmet_anchor if helmet_anchor>=0 else size.x*0.30
		movie.position=Vector2(target_x-movie.size.x*FILM_HELMET.x,size.y*0.51-movie.size.y*FILM_HELMET.y)
		movie.position.x=clampf(movie.position.x,size.x-movie.size.x,0.0)
		movie.position.y=clampf(movie.position.y,size.y-movie.size.y,0.0)
	var frame_size: Vector2=movie.size if is_instance_valid(movie) else size
	var frame_origin: Vector2=movie.position if is_instance_valid(movie) else Vector2.ZERO
	if is_instance_valid(movie):
		landscape.set_anchors_preset(Control.PRESET_TOP_LEFT)
		landscape.size=frame_size; landscape.position=frame_origin
	var height:=frame_size.y*0.56
	knight.size=Vector2(height*knight.texture.get_width()/knight.texture.get_height(),height)
	knight.position=frame_origin+Vector2(frame_size.x*0.46-knight.size.x*0.5,frame_size.y*0.46)
	height=frame_size.y*0.49
	foliage.size=Vector2(height*foliage.texture.get_width()/foliage.texture.get_height(),height)
	foliage.position=frame_origin+Vector2(-frame_size.x*0.025,frame_size.y*0.53)

func reframe_for_menu(tagline_end: float, navigation: Rect2) -> void:
	var desired:=clampf(tagline_end+8.0,size.x*0.26,size.x*0.35)
	helmet_anchor=minf(desired,navigation.position.x-size.x*0.27)
	arrange()

func advance(delta: float, enabled: bool) -> void:
	if is_instance_valid(movie):
		var texture_allocated:=movie.get_video_texture()!=null and movie.get_video_texture().get_width()>0
		if texture_allocated and movie.stream_position>=1.0/30.0: movie_ready=true
		# Decode the initial pose even with reduced motion; allocation is not a frame.
		movie.paused=not is_visible_in_tree() or (not enabled and movie_ready)
		for item in [landscape,knight,foliage]: item.visible=not movie_ready
	if not is_visible_in_tree(): return
	if enabled: clock+=delta
	if is_instance_valid(movie): movie.material.set_shader_parameter("animation_clock",clock)
	if is_instance_valid(moonlight): moonlight.advance(clock)
	for item in [landscape,knight,foliage]:
		item.material.set_shader_parameter("animation_clock",clock)

func place_moon(title_rect: Rect2, navigation: Rect2) -> void:
	if is_instance_valid(moonlight):
		moonlight.place(title_rect,navigation)
		moonlight.look_toward(knight.position+knight.size*Vector2(0.5,0.3))

