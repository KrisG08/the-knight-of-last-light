extends SceneTree
const Settings=preload("res://game/settings/game_settings.gd")
const Profiles=preload("res://game/presentation/graphics_profile.gd")
const L=preload("res://game/localization/localizer.gd")
var assertions:=0
var failures:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void:
	create_timer(70,true).timeout.connect(func(): push_error("Graphics checks timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	var evidence: String=args[0] if not args.is_empty() and args[0]!="--touch" else ProjectSettings.globalize_path("res://.tools")
	root.size=Vector2i(1600,720)
	var directory:=evidence+"/graphics-settings-check-"+str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(directory)
	var model:=Settings.new(directory+"/settings.cfg")
	check(not model.set_value("graphics_quality","unknown") and not model.set_value("graphics_quality",true),"Unsupported graphics modes rejected")
	check(not model.set_value("frame_limit",true) and not model.set_value("frame_limit",59) and not model.set_value("frame_limit",60.0),"Frame limit validates integer supported rates")
	check(not model.set_value("frame_limit",160) and not model.set_value("render_resolution","2160p"),"Unsupported phone targets are rejected rather than mislabeled")
	model.set_value("render_resolution","native"); model.set_value("frame_limit",120)
	check(model.save_settings(),"Native resolution and high-refresh preference save")
	var high_refresh:=Settings.new(model.path); high_refresh.load_settings()
	check(high_refresh.values.render_resolution=="native" and high_refresh.values.frame_limit==120,"Native/120 preferences survive reconstruction")
	model.set_value("graphics_quality","balanced"); model.set_value("frame_limit",30); model.set_value("show_fps",true)
	check(model.save_settings(),"Graphics preferences save independently of journeys")
	var loaded:=Settings.new(model.path); loaded.load_settings()
	check(loaded.values.graphics_quality=="balanced" and loaded.values.frame_limit==30 and loaded.values.show_fps,"Graphics preferences survive reconstruction")
	var legacy:=ConfigFile.new(); legacy.set_value("settings","low_graphics",true); legacy.save(directory+"/legacy.cfg")
	var old:=Settings.new(directory+"/legacy.cfg"); old.load_settings()
	check(old.values.graphics_quality=="performance" and old.values.low_graphics,"Legacy low graphics migrates without silent quality increase")
	old.set_value("graphics_quality","high")
	check(not old.values.low_graphics,"Explicit quality selection supersedes legacy toggle")
	for mobile in [false,true]:
		var last_scale:=2.0; var last_lod:=0.0
		for quality in Profiles.QUALITIES:
			var profile:=Profiles.resolve(quality,mobile,Vector2i(2392,1080) if mobile else Vector2i(2880,1620))
			check(profile.scale<=last_scale and profile.lod>=last_lod,"Quality modes reduce pixel cost/detail monotonically")
			last_scale=profile.scale; last_lod=profile.lod
		var huge:=Profiles.resolve("high",mobile,Vector2i(7680,4320))
		check(float(7680*4320)*huge.scale*huge.scale<=huge.pixel_budget+2,"HiDPI/large displays cannot bypass pixel budget")
	var phone:=Profiles.resolve("high",true,Vector2i(2392,1080))
	check(is_equal_approx(phone.scale,1.0) and phone.shadows and phone.shadow_distance==48.0,"Phone high quality uses its native screen and longer bounded shadows")
	check(phone.msaa==Viewport.MSAA_4X and phone.anisotropy==Viewport.ANISOTROPY_16X and phone.lod==0.8,"Phone high quality matches desktop edge filtering and mesh detail")
	var native:=Profiles.resolve("high",true,Vector2i(2392,1080),"native")
	check(is_equal_approx(native.scale,1.0) and native.pixel_budget>=2392*1080,"Phone (3a) native mode genuinely renders its full pixel grid")
	var fast:=Profiles.resolve("high",true,Vector2i(2392,1080),"profile",120)
	check(fast.scale<phone.scale and fast.pixel_budget<phone.pixel_budget,"Mobile 120 target lowers profile-mode pixel work")
	check(is_equal_approx(Profiles.resolve("high",true,Vector2i(2392,1080),"native",120).scale,1.0),"Explicit native resolution remains full detail at a high target")
	var oversized:=Profiles.resolve("high",true,Vector2i(7680,4320),"native")
	check(7680.0*4320.0*oversized.scale*oversized.scale<=2600002,"Native mode still bounds oversized Android buffers")
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.session.begin(1,false); game.started=true; game.pause(false)
	var progress:=JSON.stringify(game.session.state)
	var size_before:=DisplayServer.window_get_size(); var mode_before:=DisplayServer.window_get_mode()
	game.show_settings()
	var quality_picker:=game.settings_panel.find_child("GraphicsQuality",true,false) as OptionButton
	var limit_picker:=game.settings_panel.find_child("FrameLimit",true,false) as OptionButton
	var resolution_picker:=game.settings_panel.find_child("RenderResolution",true,false) as OptionButton
	check(quality_picker!=null and limit_picker!=null,"Graphics controls are reachable in actual Settings")
	quality_picker.item_selected.emit(2)
	check(not game.sun.shadow_enabled and game.settings.values.graphics_quality=="performance","Real quality control applies performance rendering")
	quality_picker.item_selected.emit(0)
	check(game.sun.shadow_enabled and root.anisotropic_filtering_level>=Viewport.ANISOTROPY_8X,"Quality restores actual shadows and texture filtering")
	limit_picker.item_selected.emit(0)
	check(Engine.max_fps==30,"Actual frame limit control applies pacing cap")
	limit_picker.item_selected.emit(3)
	check(Engine.max_fps==120,"Mobile and desktop 120 target reaches the real engine without a hidden 60 cap")
	limit_picker.item_selected.emit(2)
	check(Engine.max_fps==90,"90 target applies through actual UI")
	resolution_picker.item_selected.emit(1)
	check(game.settings.values.render_resolution=="native" and game.graphics_profile.resolution=="native","Native option controls the actual viewport profile")
	check(not game.settings_panel.find_child("RenderInfo",true,false).text.is_empty(),"Actual render dimensions/target are visible")
	resolution_picker.item_selected.emit(0)
	limit_picker.item_selected.emit(1)
	game.settings.set_value("show_fps",true); game.pause(false)
	await process_frame
	check(game.fps_label.is_visible_in_tree(),"Optional FPS counter appears in gameplay")
	game.pause(true); await process_frame
	check(not game.fps_label.is_visible_in_tree(),"FPS counter stays out of paused menu")
	check(DisplayServer.window_get_size()==size_before and DisplayServer.window_get_mode()==mode_before,"Changing graphics preserves window size and mode")
	check(JSON.stringify(game.session.state)==progress,"Rendering preferences never alter journey progress")
	check(limit_picker.item_count==4,"Mobile and desktop offer 30/60/90/120 targets")
	game.settings.set_value("frame_limit",120); game.settings.set_value("render_resolution","native"); game.apply_settings()
	DirAccess.make_dir_recursive_absolute(evidence+"/review/graphics")
	for language in ["bg","en","ru","fr","ar"]:
		game.set_language(language); game.show_settings()
		check(L.text("High quality")!="High quality" or language=="en","Graphics labels translated: "+language)
		if DisplayServer.get_name()!="headless":
			for frame in range(4): await process_frame
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(evidence+"/review/graphics/settings-"+language+("-touch" if OS.get_cmdline_user_args().has("--touch") else "-desktop")+".png")
	game.player.sounds.stop(); game.ui_sound.stop(); game.queue_free()
	await process_frame; Engine.max_fps=0
	print("Device graphics: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL"))
	quit(0 if failures==0 else 1)
