extends SceneTree
## Native fixed-frame master avoids the slow Windows PNG-to-encoder pipe.
var scene: Control
var frame := 0
var first: Image
const FPS = 60.0
const REVIEW = "res://.tools/review/menu-hfr-v062"
func _initialize() -> void: call_deferred("setup")
func setup() -> void:
	root.content_scale_size=Vector2i(1280,720)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	scene=load("res://game/presentation/menu_living_scene.gd").new()
	root.add_child(scene); scene.setup(false)
	DirAccess.make_dir_recursive_absolute(REVIEW)
	print("MENU_MASTER_READY 3840x2160 / 60 fps / 12 seconds")
func _process(_delta: float) -> bool:
	if not is_instance_valid(scene): return false
	scene.clock=float(frame)/FPS; scene.advance(0,true)
	if frame in [0,180,360,720]: capture.call_deferred(frame)
	frame+=1
	if frame%60==0: print("MENU_MASTER_FRAME ",frame)
	return false
func capture(index: int) -> void:
	RenderingServer.force_draw(false)
	var picture:=root.get_texture().get_image()
	if index==0: first=picture.duplicate()
	picture.save_png(REVIEW+"/master-%04d.png"%index)
	if index==720:
		var report:={"master_size":[3840,2160],"desktop_size":[2560,1440],"mobile_size":[1920,1080],"frames":720,"fps":60,"seconds":12,"quality":10,"source":"original layered art and native shaders; fixed-frame master","loop_endpoint_metrics":first.compute_image_metrics(picture,false)}
		FileAccess.open(REVIEW+"/render.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
