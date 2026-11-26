extends SceneTree
## Small native animation preview. No scene, account or owner save is opened.
const OUTPUT:="res://.tools/review/living-moon/frames"
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size=Vector2i(640,640)
	root.content_scale_size=Vector2i(640,640)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	RenderingServer.set_default_clear_color(Color(0.013,0.018,0.032))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var face=load("res://game/presentation/menu_moonlight.gd").new()
	root.add_child(face); face.setup()
	for frame in range(8): await process_frame
	face.moon.position=Vector2(64,64); face.moon.size=Vector2(512,512)
	face.center=Vector2(320,320); face.halo_radius=294
	for frame in range(240):
		face.advance(float(frame)/24.0)
		await process_frame; RenderingServer.force_draw(false)
		root.get_texture().get_image().save_jpg(OUTPUT+"/%04d.jpg"%frame,0.91)
	face.queue_free(); await process_frame
	print("Living moon: 240 native shader frames at 24 fps")
	quit()
