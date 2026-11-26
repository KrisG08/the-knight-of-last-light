extends SceneTree
var game: Node
var failures:=0
var assertions:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void:
	create_timer(100,true).timeout.connect(func(): push_error("Wind menu capture timeout"); quit(1))
	call_deferred("run")
func settle() -> void:
	# Native window resize and RTL notifications also need wall-clock delivery
	# when the QA scene runs with an uncapped frame rate.
	await create_timer(0.08,true).timeout
	for frame in range(8): await process_frame
func painted_overlap(layer: TextureRect, area: Rect2) -> bool:
	# Check visible paint, not transparent PNG canvas or sub-10% alpha residue.
	var overlap:=layer.get_rect().intersection(area)
	if not overlap.has_area(): return false
	var picture:=layer.texture.get_image()
	var to_pixels:=Vector2(picture.get_size())/layer.size
	var first:=Vector2i(((overlap.position-layer.position)*to_pixels).floor())
	var last:=Vector2i(((overlap.end-layer.position)*to_pixels).ceil())
	for y in range(maxi(0,first.y),mini(picture.get_height(),last.y)):
		for x in range(maxi(0,first.x),mini(picture.get_width(),last.x)):
			if picture.get_pixel(x,y).a>=0.1: return true
	return false
func photo(name_value: String) -> Image:
	await settle(); RenderingServer.force_draw(false)
	var picture:=root.get_texture().get_image()
	picture.save_png("res://.tools/review/wind-"+name_value+".png")
	return picture
func run() -> void:
	root.size=Vector2i(1600,900)
	game=load("res://game/world/runtime/village_game.tscn").instantiate(); game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true
	for dimensions in [Vector2i(1600,900),Vector2i(1600,720),Vector2i(1280,960)]:
		root.size=dimensions; await settle()
		for language in ["en","bg","ru","fr","ar"]:
			game.set_language(language); await settle()
			var text_rect: Rect2=game.menu.title_protected_rect
			check(not painted_overlap(game.menu.living_scene.knight,text_rect),language+" title and knight do not overlap at "+str(dimensions))
			check(not painted_overlap(game.menu.living_scene.foliage,text_rect),language+" title and foreground plants do not overlap at "+str(dimensions))
			check(game.menu.atmosphere.exclusion_rect==text_rect,"Motes avoid the complete title/tagline rectangle")
			var moon_rect: Rect2=game.menu.living_scene.moonlight.moon.get_global_rect()
			check(not text_rect.intersects(moon_rect),language+" moon leaves title unobstructed at "+str(dimensions))
			check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(moon_rect),language+" moon stays inside viewport")
			var moon_layer=game.menu.living_scene.moonlight
			var knight=game.menu.living_scene.knight
			var to_knight: Vector2=(knight.position+knight.size*Vector2(0.5,0.3)-moon_layer.center).normalized()
			var gaze: Vector2=moon_layer.moon.material.get_shader_parameter("gaze_direction")
			check(gaze.dot(to_knight)>0.99,language+" moon gaze follows the knight across menu layouts")
			await photo(language+"-"+str(dimensions.x)+"x"+str(dimensions.y))
	root.size=Vector2i(1600,900); game.set_language("bg"); await settle()
	var first: float=game.menu.living_scene.clock
	await create_timer(0.15,true).timeout
	check(game.menu.living_scene.clock>first,"Wind clock advances while enabled")
	game.settings.values.menu_motion=false; await settle()
	var frozen: float=game.menu.living_scene.clock
	await create_timer(0.15,true).timeout
	check(game.menu.living_scene.clock==frozen,"Reduced motion freezes every artwork layer")
	check(is_equal_approx(float(game.menu.title.material.get_shader_parameter("animation_clock")),frozen),"Reduced motion freezes title sheen")
	check(game.menu.living_scene.moonlight.clock==frozen,"Reduced motion freezes moon halo")
	check(is_equal_approx(float(game.menu.living_scene.moonlight.moon.material.get_shader_parameter("animation_clock")),frozen),"Reduced motion freezes the moon's eyes and mouth")
	var clouds=game.menu.living_scene.moonlight.foreground_clouds
	check(clouds.get_index()>game.menu.living_scene.moonlight.moon.get_index(),"Clouds composite in front of the moon")
	check(is_equal_approx(float(clouds.material.get_shader_parameter("animation_clock")),frozen),"Reduced motion also freezes foreground clouds")
	check(is_equal_approx(float(game.menu.living_scene.movie.material.get_shader_parameter("animation_clock")),frozen),"Reduced motion freezes curse and warm-light shader")
	var quiet:=await photo("reduced-motion")
	game.settings.values.menu_motion=true; await settle()
	var scene=game.menu.living_scene
	scene.clock=0; scene.advance(0,true)
	await photo("motion-a")
	scene.clock=3; scene.advance(0,true)
	await photo("motion-b")
	check(quiet.get_size().x>0,"Native menu rendered")
	game.queue_free(); await process_frame
	print("Layered wind menu: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
