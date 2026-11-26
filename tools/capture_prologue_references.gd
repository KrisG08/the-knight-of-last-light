extends "res://tools/render_opening_film.gd"
## Current world/character registration guides for a separate AI video workflow.
func preview() -> void:
	var directory := "res://art/cinematics/opening-v6/native-guides"
	DirAccess.make_dir_recursive_absolute(directory)
	for sample in [{"id":"citadel-wide","time":1.0},{"id":"citadel-approach","time":4.0},{"id":"maldrek-casting","time":8.3},{"id":"order-march","time":15.0},{"id":"curse-impact","time":24.0},{"id":"fallen-expedition","time":27.0},{"id":"survivor","time":33.0},{"id":"refuge","time":37.0}]:
		update_film(sample.time)
		for tick in range(8): await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(directory+"/"+sample.id+".png")==OK)
		print("PROLOGUE REFERENCE ",sample.id)
	forest.hide(); fortress.hide(); wizard.hide(); curse.hide(); wave.hide()
	for item in knights: item.node.hide()
	var village := Region.new(); world.add_child(village); village.build("region.village")
	for label in village.find_children("*","Label3D",true,false): label.hide()
	for inhabitants in village.find_children("MythicFauna","Node3D",true,false): inhabitants.hide()
	camera.position=Vector3(3,2.5,18); camera.look_at(Vector3(0,1.8,-10)); camera.fov=58
	shade.color.a=0
	for tick in range(8): await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(directory+"/village.png")==OK)
	print("PROLOGUE REFERENCE village")
	quit()
