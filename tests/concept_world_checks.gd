extends SceneTree
const Schema = preload("res://game/persistence/domain/save_schema.gd")
var assertions := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	var builder = preload("res://game/presentation/concept_landmarks.gd").new()
	var start := Vector3(1,2,3); var finish := Vector3(5,8,-2)
	builder.beam(start,finish,.1)
	var transform: Transform3D = builder.ribs[0]
	check((transform*Vector3(0,-.5,0)).is_equal_approx(start) and (transform*Vector3(0,.5,0)).is_equal_approx(finish),"Rotated architectural ribs preserve their authored endpoints")
	root.size = Vector2i(1600,900)
	var args := OS.get_cmdline_user_args()
	var output: String = args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review/concept-worlds")
	var fixture_path: String = args[1] if args.size()>1 else ProjectSettings.globalize_path("res://.tools/wizard-defeat-fixture.json")
	DirAccess.make_dir_recursive_absolute(output)
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true; root.add_child(game)
	while game.transitioning: await process_frame
	if not is_instance_valid(game.region):
		push_error("Initial concept region failed to stage"); game.queue_free(); quit(1); return
	game.benchmarking = true; game.session.begin(1,false)
	game.session.state = JSON.parse_string(FileAccess.get_file_as_string(fixture_path))
	game.started = true
	var views := [
		["region.refuge",Vector3(1,0,98),Vector3(-12,5,47)],
		["region.village",Vector3(-9,0,8),Vector3(0,6,-18)],
		["region.blackwood",Vector3(0,0,-5),Vector3(-13,7,-38)],
		["region.order",Vector3(0,0,0),Vector3(0,10,-43)],
		["region.peaks",Vector3(0,0,0),Vector3(0,15,-64)],
		["region.citadel",Vector3(0,0,54),Vector3(0,28,-68)],
		["region.crypt",Vector3(0,0,3),Vector3(0,5,-9)],
		["region.grove",Vector3(0,0,9),Vector3(0,7,-12)],
		["region.sanctum",Vector3(0,0,9),Vector3(0,8,-12)],
		["region.forge",Vector3(0,0,9),Vector3(0,8,-12)],
		["region.ritual",Vector3(0,0,9),Vector3(0,14,-12)]
	]
	var camera := Camera3D.new(); camera.fov = 75; camera.far = 6500; game.add_child(camera)
	for view in views:
		var id: String = view[0]
		var transitioned: bool = await game.transition(id)
		check(transitioned,"Concept region remains reachable: "+id)
		if not transitioned:
			game.queue_free(); await process_frame; quit(1); return
		var details: Node3D = game.region.get_node("ConceptLandmarks")
		check(details.get_meta("concept_region") == id and details.get_meta("rib_instances",0)>100,"Authored complex detail is present: "+id)
		check(float(game.atmosphere.sky.sky_material.get_shader_parameter("violet_night")) == 1.0,"Violet night applies: "+id)
		check(game.atmosphere.ambient_light_energy >= .28 and game.sun.light_energy > 0,"Dark palette retains readable light: "+id)
		check(Schema.validate(game.session.state).is_empty(),"Visual changes retain valid progress: "+id)
		game.player.set_physics_process(false); game.player.hide()
		game.ui_layer.hide()
		for actor in get_nodes_in_group("hostiles"):
			actor.set_physics_process(false); actor.hide()
		camera.position = game.region.surface_point(view[1])+Vector3.UP*1.8
		camera.look_at(game.region.surface_point(view[2])); camera.make_current()
		game.pause(false); Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await create_timer(.25,true).timeout
		if DisplayServer.get_name() != "headless":
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(output+"/"+id.trim_prefix("region.")+".png")
		print("CONCEPT VIEW ",id)
	game.session.state.campaign.completed = true
	check(await game.transition("region.refuge"),"Restored camp remains reachable")
	check(float(game.atmosphere.sky.sky_material.get_shader_parameter("violet_night")) == 0.0,"Cleansed-world dawn does not retain the curse palette")
	game.queue_free(); await process_frame
	print("Concept worlds: %d assertions, %s" % [assertions,"PASS" if failures == 0 else "FAIL"])
	quit(0 if failures == 0 else 1)
