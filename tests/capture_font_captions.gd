extends SceneTree
func _initialize() -> void:
	call_deferred("capture")
func capture() -> void:
	var film = preload("res://game/ui/opening_cinematic.gd").new()
	root.add_child(film)
	for second in [4.0,12.0,19.0,26.0]:
		film.video.stream_position=second
		for frame in range(8): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/cinzel-film-"+str(int(second))+".png")
	film.complete(); await process_frame
	quit()
