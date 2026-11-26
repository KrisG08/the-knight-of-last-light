extends RefCounted

static func run(tree: SceneTree, check: Callable) -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	check.call(preload("res://game/presentation/art_kit.gd").stone().albedo_texture != null,"Stone surface texture is imported and used by actual stone material")
	var dressing: Node3D = game.region.get_node("AuthoredRuinDressing")
	check.call(dressing.find_children("*","MultiMeshInstance3D",true,false).size() >= 3,"Dense paving/rubble/foliage use instanced rendering")
	check.call(dressing.find_children("*","CollisionShape3D",true,false).is_empty(),"Cosmetic dressing does not silently change collision/navigation routes")
	check.call(game.player.model.legs.size() == 2 and game.player.sword_pivot.find_children("*","MeshInstance3D",true,false).size() >= 2,"Detailed knight retains articulated legs and real combat weapon pivot")
	check.call(game.player.model.get("meshy_id","")=="knight","Prepared Meshy knight is the active player model")
	var sky: ShaderMaterial = game.atmosphere.sky.sky_material
	check.call(sky.get_shader_parameter("moon_texture") is Texture2D and sky.get_shader_parameter("cloud_panorama") is Texture2D,"Night sky uses real moon-face and cloud panorama assets")
	check.call(sky.get_shader_parameter("horizon_color")==game.atmosphere.fog_light_color and game.atmosphere.fog_sky_affect==0,"Sky horizon and terrain haze share the regional atmosphere without double fog")
	preload("res://tests/locomotion_checks.gd").run(game.player,check)
	var imported: Node3D = game.region.get_node("PhotogrammetryDressing")
	check.call(imported.get_child_count() >= 12 and imported.find_children("*","CollisionShape3D",true,false).is_empty(),"Verified imported environment meshes dress refuge without changing physics routes")
	var ground: StandardMaterial3D = preload("res://game/presentation/real_assets.gd").ground()
	check.call(ground.albedo_texture != null and ground.normal_texture != null and ground.roughness_texture != null,"Ground uses actual diffuse, normal and roughness maps")
	var mesh: Mesh = game.player.model.leg_meshes[0].mesh
	check.call(mesh.surface_get_material(0) is ShaderMaterial and mesh.surface_get_arrays(0)[Mesh.ARRAY_NORMAL].size()>0,"Prepared hero has procedural surface material and valid geometry normals")
	await game.start_selected()
	game.player.enabled = false
	game.player.position = game.region.points.checkpoint+Vector3(-2,0.1,0)
	game._process(0.1)
	check.call(game.prompt_label.text.contains("Rest") and game.prompt_panel.visible,"Interaction moved into visible dedicated prompt")
	check.call(not game.hud.text.contains("Find survivors") and game.objective_label.text.contains("Find survivors"),"Objective is separate from compact resource HUD")
	game.pause(true)
	check.call(not game.hud_overlay.visible and not game.hud_panel.visible,"Menus hide all separate gameplay overlays")
	game.settings.values.ui_scale = 1.5
	game.apply_settings()
	check.call(game.hud_overlay.theme.default_font_size == 24,"Scalable text applies to new objective and interaction overlays")
	game.player.sounds.stop()
	game.ui_sound.stop()
	await tree.create_timer(0.2,true).timeout
	game.queue_free()
	await tree.process_frame
