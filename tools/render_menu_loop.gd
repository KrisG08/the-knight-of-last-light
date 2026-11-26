extends SceneTree
## Bake only the original animated scenery; menu text stays native and translated.
var frame:=0
var scene: Control
var output:= "res://.tools/review/menu-loop-v2"
const FPS:=30
const SECONDS:=12

func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size=Vector2i(1280,720)
	scene=load("res://game/presentation/menu_living_scene.gd").new()
	root.add_child(scene); scene.setup(false)
	for index in range(20): await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	if "--probe" in OS.get_cmdline_user_args():
		scene.clock=0; scene.advance(0,true)
		await process_frame; RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png("res://.tools/review/menu-loop-probe.png")
		scene.queue_free(); await process_frame; quit(); return
	for index in range(FPS*SECONDS+1):
		scene.clock=float(index)/FPS
		scene.advance(0,true)
		await process_frame
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png(output+"/%04d.png"%index)
		if index%90==0: print("Menu loop rendered frame ",index)
	scene.queue_free(); await process_frame
	quit()
