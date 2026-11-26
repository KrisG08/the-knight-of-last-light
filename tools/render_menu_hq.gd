extends SceneTree
## Supersampled raw RGB avoids JPEG loss and costly PNG pipe compression.
const FPS:=60
const FRAMES:=720
const DESKTOP:="res://assets/cinematics/menu_wind_desktop.ogv"
const MOBILE:="res://assets/cinematics/menu_wind_mobile.ogv"
const REVIEW:="res://.tools/review/menu-hfr-v062"
var encoder: Dictionary
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size=Vector2i(3840,2160)
	root.content_scale_size=Vector2i(1280,720)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var scene=load("res://game/presentation/menu_living_scene.gd").new()
	root.add_child(scene); scene.setup(false)
	for frame in range(12): await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REVIEW))
	var ffmpeg:=ProjectSettings.globalize_path("res://.tools/video-encoder/imageio_ffmpeg/binaries/ffmpeg-win-x86_64-v7.1.exe")
	var args:=PackedStringArray(["-hide_banner","-loglevel","error","-y","-f","rawvideo","-pixel_format","rgb24","-video_size","3840x2160","-framerate",str(FPS),"-i","pipe:0","-filter_complex","[0:v]split=2[d][m];[d]scale=2560:1440:flags=lanczos[desktop];[m]scale=1920:1080:flags=lanczos[mobile]","-map","[desktop]","-c:v","libtheora","-q:v","10","-pix_fmt","yuv420p","-an",ProjectSettings.globalize_path(DESKTOP),"-map","[mobile]","-c:v","libtheora","-q:v","10","-pix_fmt","yuv420p","-an",ProjectSettings.globalize_path(MOBILE)])
	encoder=OS.execute_with_pipe(ffmpeg,args,true)
	if encoder.is_empty(): push_error("Cannot start menu encoders"); quit(1); return
	var pipe: FileAccess=encoder.stdio
	var first: Image
	for frame in range(FRAMES):
		scene.clock=float(frame)/FPS; scene.advance(0,true)
		await process_frame; RenderingServer.force_draw(false)
		var picture:=root.get_texture().get_image()
		if picture.get_size()!=Vector2i(3840,2160): push_error("Wrong menu master resolution"); OS.kill(encoder.pid); quit(1); return
		picture.convert(Image.FORMAT_RGB8)
		if frame==0: first=picture.duplicate()
		if frame in [0,90,180]: picture.save_png(REVIEW+"/master-%04d.png"%frame)
		pipe.store_buffer(picture.get_data())
		if pipe.get_error()!=OK: push_error("Menu encoder pipe failed"); OS.kill(encoder.pid); quit(1); return
		if frame%30==0: print("HQ menu streamed frame ",frame," / ",FRAMES)
	pipe.close()
	var deadline:=Time.get_ticks_msec()+60000
	while OS.is_process_running(encoder.pid) and Time.get_ticks_msec()<deadline:
		await create_timer(0.1,true).timeout
	if OS.is_process_running(encoder.pid): OS.kill(encoder.pid); push_error("Menu encoder finish timeout"); quit(1); return
	var errors: PackedByteArray=encoder.stderr.get_buffer(4096)
	if not errors.is_empty(): push_error(errors.get_string_from_utf8()); quit(1); return
	encoder.stderr.close()
	scene.clock=12.0; scene.advance(0,true)
	await process_frame; RenderingServer.force_draw(false)
	var end:=root.get_texture().get_image()
	end.convert(Image.FORMAT_RGB8)
	var seam: Dictionary=first.compute_image_metrics(end,false)
	var report:={"master_size":[3840,2160],"desktop_size":[2560,1440],"mobile_size":[1920,1080],"frames":FRAMES,"fps":FPS,"seconds":12,"quality":10,"source":"original layered art and native shaders; raw RGB stream without a JPEG intermediary","loop_endpoint_metrics":seam}
	FileAccess.open(REVIEW+"/render.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	scene.queue_free(); await process_frame
	print("High quality menu render complete: 720 original 4K frames at 60 fps, QHD desktop and Full HD mobile")
	quit()
