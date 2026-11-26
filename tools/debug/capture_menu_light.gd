extends SceneTree
## Visual A/B fixture: same paused movie frame, no owner saves or account traffic.
var output_directory: String
func _initialize() -> void:
	var args:=OS.get_cmdline_user_args()
	output_directory=args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review")
	DirAccess.make_dir_recursive_absolute(output_directory)
	call_deferred("run")
func settle() -> void:
	for frame in range(8): await process_frame
func photo(label: String) -> void:
	await settle(); RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(output_directory+"/menu-light-"+label+".png")
func run() -> void:
	root.size=Vector2i(1600,900)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.set_language("bg")
	await create_timer(1.0,true).timeout
	game.settings.values.menu_motion=false; await settle()
	var scene=game.menu.living_scene
	var shade: TextureRect=game.menu.shell.get_node("MenuReadabilityShade")
	var gradient: Gradient=shade.texture.gradient
	await photo("desktop-after")
	scene.movie.material.set_shader_parameter("grade_amount",0.0)
	gradient.set_color(0,Color(0.008,0.014,0.022,0.42))
	gradient.set_color(1,Color(0.015,0.025,0.03,0.62))
	var old_cover:=maxf(scene.size.x/1280.0,scene.size.y/720.0)
	scene.movie.size=Vector2(1280,720)*old_cover
	scene.movie.position=(scene.size-scene.movie.size)*0.5
	await photo("desktop-before")
	scene.movie.material.set_shader_parameter("grade_amount",1.0)
	gradient.set_color(0,Color(0.008,0.014,0.022,0.30))
	gradient.set_color(1,Color(0.015,0.025,0.03,0.48))
	scene.arrange()
	for dimensions in [Vector2i(1600,720),Vector2i(1280,960)]:
		root.size=dimensions; await photo("after-%dx%d"%[dimensions.x,dimensions.y])
	game.queue_free(); await process_frame
	print("Menu light: native paused-frame A/B, desktop, wide phone and tablet captures complete")
	quit()
