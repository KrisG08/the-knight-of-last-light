extends SceneTree
var failures:=0
var assertions:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var scene=load("res://game/presentation/menu_living_scene.gd").new()
	root.add_child(scene); scene.setup()
	check(scene.movie!=null and scene.movie.stream!=null,"Actual menu film included in package")
	check(scene.movie.loop,"Packaged menu player loops the film")
	for item in [scene.landscape,scene.knight,scene.foliage]:
		check(item.texture.get_width()>1000,"Packaged high resolution artwork loads")
		check(item.material.shader!=null,"Packaged animation shader loads")
	check(scene.knight.texture.get_height()==1536,"Full knight alpha texture included")
	check(scene.foliage.texture.get_width()==1536,"Full vegetation alpha texture included")
	scene.advance(0.2,true)
	var before: float=scene.clock
	scene.advance(1.0,false)
	check(scene.clock==before and before>0,"Packaged reduced motion freezes pose")
	for item in [scene.landscape,scene.knight,scene.foliage]:
		check(is_equal_approx(item.material.get_shader_parameter("animation_clock"),before),"Every layer shares frozen clock")
	scene.queue_free(); await process_frame
	print("Packaged living menu: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL"))
	quit(0 if failures==0 else 1)
