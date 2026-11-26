extends SceneTree
func _initialize() -> void:
	call_deferred("bake")
func bake() -> void:
	var source = load("res://assets/vendor/polyhaven/pine_sapling_small/pine_sapling_small.gltf").instantiate()
	for original in source.find_children("*","MeshInstance3D",true,false):
		var viewport := SubViewport.new(); viewport.size=Vector2i(512,768)
		viewport.transparent_bg=true; viewport.own_world_3d=true
		viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var tree := MeshInstance3D.new(); tree.mesh=original.mesh
		var bounds := tree.mesh.get_aabb(); var h := bounds.size.y
		tree.position=-Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)
		viewport.add_child(tree)
		for side in [-1,1]:
			var understory := MeshInstance3D.new(); understory.mesh=original.mesh
			understory.scale=Vector3.ONE*0.8
			understory.rotation.y=side*1.8
			understory.position=tree.position*0.8+Vector3(side*h*0.1,h*0.06,0)
			viewport.add_child(understory)
		var environment := WorldEnvironment.new(); environment.environment=Environment.new()
		environment.environment.background_mode=Environment.BG_COLOR
		environment.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
		environment.environment.ambient_light_color=Color.WHITE
		environment.environment.ambient_light_energy=0.65
		viewport.add_child(environment)
		var light := DirectionalLight3D.new(); light.rotation_degrees=Vector3(-35,-25,0); light.light_energy=0.8; viewport.add_child(light)
		var camera := Camera3D.new(); camera.projection=Camera3D.PROJECTION_ORTHOGONAL
		camera.keep_aspect=Camera3D.KEEP_HEIGHT; camera.size=h*1.06
		camera.position=Vector3(0,h*0.5,h*2); viewport.add_child(camera)
		camera.look_at(Vector3(0,h*0.5,0)); camera.make_current()
		for frame in range(6): await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://assets/forest/"+String(original.name)+".png")
		viewport.queue_free(); await process_frame
	source.free(); print("Three full-detail pine silhouettes baked with alpha"); quit()
