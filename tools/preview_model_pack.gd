extends SceneTree
## Local visual inspection of the portable copies; no game or save access.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size=Vector2i(900,900)
	var space := Node3D.new(); root.add_child(space)
	var environment := WorldEnvironment.new(); environment.environment=Environment.new()
	environment.environment.background_mode=Environment.BG_COLOR
	environment.environment.background_color=Color("232631")
	environment.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color=Color.WHITE
	environment.environment.ambient_light_energy=.65
	space.add_child(environment)
	var light := DirectionalLight3D.new(); light.rotation_degrees=Vector3(-35,-30,0)
	light.light_energy=1.6; space.add_child(light)
	var camera := Camera3D.new(); camera.fov=35; space.add_child(camera); camera.current=true
	for file: String in ["characters/meshy-knight","villains/soldier","props/scout_satchel"]:
		var document := GLTFDocument.new(); var state := GLTFState.new()
		var path := "res://art_exports/Last-Light-Model-Pack-2026-11-24/02-GLB/"+file+".glb"
		if document.append_from_file(path,state)!=OK: quit(1); return
		var model := document.generate_scene(state); space.add_child(model)
		var bounds := AABB(); var first := true
		for part in model.find_children("*","MeshInstance3D",true,false):
			for surface in range(part.mesh.get_surface_count()):
				var material: Material=part.mesh.surface_get_material(surface)
				var colors = part.mesh.surface_get_arrays(surface)[Mesh.ARRAY_COLOR]
				if material is StandardMaterial3D and colors is PackedColorArray and not colors.is_empty():
					material.vertex_color_use_as_albedo=true
			var box: AABB=part.global_transform*part.get_aabb()
			bounds=box if first else bounds.merge(box); first=false
		var center := bounds.get_center(); var extent := bounds.size.length()
		camera.position=center+Vector3(.25,.12,1).normalized()*extent*1.5
		camera.look_at(center)
		for frame in range(6): await process_frame
		await RenderingServer.frame_post_draw
		var output := "res://.tools/review/model-pack-"+file.get_file()+".png"
		root.get_texture().get_image().save_png(ProjectSettings.globalize_path(output))
		print("PREVIEW ",output)
		model.free()
	quit()
