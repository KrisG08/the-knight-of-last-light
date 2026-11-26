extends SceneTree
## Real layout and signal routes, without owner saves or signing in.
var assertions:=0
var failures:=0
var game: Node
func _initialize() -> void:
	create_timer(100,true).timeout.connect(func(): push_error("Menu utilities timeout"); quit(1))
	call_deferred("run")
func check(condition: bool, message: String) -> void:
	assertions+=1
	if not condition: failures+=1; push_error(message)
func settle() -> void:
	for frame in range(8): await process_frame
func photo(path: String) -> void:
	RenderingServer.force_draw(false)
	var result:=root.get_texture().get_image().save_png(path)
	check(result==OK,"Menu screenshot saved")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	var output: String=args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review/menu-utilities-layout")
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(1600,900)
	game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.settings.values.menu_motion=true
	# Wait for the real initial movie pose before freezing layout screenshots.
	# Texture allocation alone is not proof that a decoded frame is available.
	for frame in range(120):
		if game.menu.living_scene.movie.stream_position>0.08: break
		await process_frame
	check(game.menu.living_scene.movie.stream_position>0.08,"Real menu video decoded before frozen layout review")
	game.settings.values.menu_motion=false
	for dimensions in [Vector2i(1600,900),Vector2i(1600,720),Vector2i(1280,960)]:
		root.size=dimensions
		for language in ["en","bg","ru","fr","ar"]:
			game.set_language(language)
			for scale_value in [1.0,1.25,1.5]:
				game.settings.values.ui_scale=scale_value; await settle()
				var menu=game.menu
				var bar: Rect2=menu.utility_bar.get_rect()
				var bounds:=Rect2(Vector2.ZERO,menu.size)
				var label: String="%s %s scale%s"%[dimensions,language,scale_value]
				check(menu.title.get_theme_font("font")==preload("res://game/presentation/ui_style.gd").TITLE_FONT,label+" translated title retains its bold font role")
				check(bounds.encloses(bar),label+" utility bar stays in viewport")
				check(bar.position.x<menu.size.x*0.10 and bar.position.y>menu.size.y*0.70,label+" utilities stay bottom left")
				check(not bar.intersects(menu.card.get_rect()),label+" utilities do not cover navigation")
				check(not bar.intersects(menu.title_protected_rect),label+" utilities leave title readable")
				var account_rect: Rect2=menu.account_button.get_global_rect()
				var language_rect: Rect2=menu.language_picker.get_global_rect()
				check(menu.utility_bar.get_global_rect().encloses(account_rect) and menu.utility_bar.get_global_rect().encloses(language_rect),label+" both controls fit inside bar")
				check(not account_rect.intersects(language_rect),label+" account and language do not overlap")
				check(account_rect.end.y<=language_rect.position.y,label+" account stays above language")
				check(absf(account_rect.position.x-language_rect.position.x)<1.0,label+" stacked utilities share left alignment")
				check(account_rect.size.y>=48 and language_rect.size.y>=48,label+" touch targets remain usable")
				var scenery=menu.living_scene
				var film_rect: Rect2=scenery.movie.get_rect()
				check(film_rect.grow(0.5).encloses(bounds),label+" reframed movie covers every viewport edge")
				var helmet: Vector2=scenery.movie.position+scenery.movie.size*scenery.FILM_HELMET
				check(absf(helmet.x-scenery.helmet_anchor)<1.0,label+" helmet follows the tagline composition anchor")
				var castle: Vector2=scenery.movie.position+scenery.movie.size*Vector2(0.66,0.40)
				check(castle.x<menu.card.position.x,label+" main castle landmark stays left of navigation")
				if language in ["bg","ar"] and scale_value in [1.0,1.5]:
					await photo(output+"/%dx%d-%s-%s.png"%[dimensions.x,dimensions.y,language,scale_value])
	root.size=Vector2i(1600,900)
	game.settings.values.ui_scale=1.0; game.set_language("bg"); await settle()
	game.menu.account_button.pressed.emit(); await settle()
	check(is_instance_valid(game.account_panel) and game.account_panel.visible,"Relocated account button opens the account panel")
	await photo(output+"/account-panel.png")
	game.account_panel.hide(); await settle()
	game.show_settings(); await settle()
	check(game.settings_panel.visible,"Settings route remains available with stone styling")
	await photo(output+"/settings-panel.png")
	game.queue_free(); await process_frame
	print("Bottom-left utilities: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
