extends SceneTree
const Targeting = preload("res://game/combat/domain/targeting_rules.gd")
const Enemy = preload("res://game/actors/enemies/training_soldier.gd")
var assertions := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	root.size = Vector2i(1280,720)
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking = true; game.session.begin(1,false); game.started = true; game.pause(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game.region.hide()
	for node in game.region.find_children("*","CollisionObject3D",true,false): node.collision_layer = 0
	var player = game.player
	player.set_physics_process(false); player.position = Vector3(0,0,4)
	player.yaw = 0; player.pitch = -.12; player.pivot.rotation = Vector3(-.12,0,0)
	var actors: Array[CharacterBody3D] = []
	for at in [Vector3(0,0,-4),Vector3(2.8,0,0),Vector3(-3,0,-3)]:
		var enemy := Enemy.new()
		enemy.home = at; enemy.player = player
		game.add_child(enemy); enemy.set_physics_process(false)
		enemy.position = at; actors.append(enemy)
	var floor_body := StaticBody3D.new()
	floor_body.position = Vector3(0,-.5,0)
	var floor_mesh := MeshInstance3D.new(); var box := BoxMesh.new(); box.size = Vector3(15,1,20); floor_mesh.mesh = box
	var material := StandardMaterial3D.new(); material.albedo_color = Color("24222e"); floor_mesh.material_override = material
	floor_body.add_child(floor_mesh); game.add_child(floor_body)
	var floor_shape := CollisionShape3D.new(); var floor_box := BoxShape3D.new(); floor_box.size = box.size; floor_shape.shape = floor_box; floor_body.add_child(floor_shape)
	# Controlled fixture keeps region dressing hidden; actors still use real models.
	await physics_frame; await physics_frame
	var camera := player.arm.get_child(0) as Camera3D
	player.select_target(false)
	check(player.target == actors[0],"Screen-centred enemy outranks a closer off-centre enemy")
	player.select_target(true)
	check(player.target == actors[1],"Cycle advances rightward in screen order")
	player.select_target(true)
	check(player.target == actors[2],"Cycle wraps to leftmost target")
	actors[1].health = 0
	check(not player.target_candidates().has(actors[1]),"Dead hostiles cannot be acquired")
	actors[1].health = 110
	var original: Vector3 = actors[1].position
	actors[1].position = Vector3(0,0,12)
	check(not player.target_candidates().has(actors[1]),"Hostiles behind the camera cannot be acquired")
	actors[1].position = Vector3(0,0,-20)
	check(not player.target_candidates().has(actors[1]),"Out-of-range hostiles cannot be acquired")
	actors[1].position = original
	var tap_point := camera.unproject_position(Targeting.aim_point(actors[0]))
	player.target = null
	check(player.select_target_at(tap_point) and player.target == actors[0],"Direct screen tap selects the intended enemy")
	check(player.select_target_at(tap_point) and player.target == null,"Tapping the same enemy releases focus")
	var head_point := camera.unproject_position(actors[0].global_position+Vector3.UP*1.8)
	check(player.select_target_at(head_point) and player.target == actors[0],"Body capsule accepts taps on the enemy head")
	actors[0].position.z = -14
	var retained_point := camera.unproject_position(Targeting.aim_point(actors[0]))
	check(player.select_target_at(retained_point) and player.target == null,"Tap can release retained focus beyond acquisition range")
	actors[0].position.z = -4
	player.target = null
	check(not player.select_target_at(Vector2(5,5)) and player.target == null,"Empty-space tap does not select a distant screen target")
	player.target = actors[0]
	actors[0].position.y = 5
	player.update_target(.1)
	check(player.pitch > 0 and player.pitch <= .4,"Locked camera follows elevated targets within pitch bounds")
	player.input_grace_ticks = 0; player.set_physics_process(true)
	for frame in range(30): await physics_frame
	player.set_physics_process(false)
	check(is_equal_approx(player.pivot.rotation.x,player.pitch) and camera.is_position_in_frustum(Targeting.aim_point(actors[0])),"Real physics updates apply elevated tracking to the camera")
	actors[0].position.y = 0
	var once := lerpf(0,1,Targeting.smoothing(1.0/30,8))
	var twice := lerpf(lerpf(0,1,Targeting.smoothing(1.0/60,8)),1,Targeting.smoothing(1.0/60,8))
	check(is_equal_approx(once,twice),"Tracking smoothing is independent of step subdivision")
	var wall := StaticBody3D.new(); wall.position = Vector3(0,1,0)
	var collider := CollisionShape3D.new(); var shape := BoxShape3D.new(); shape.size = Vector3(1,4,.5); collider.shape = shape; wall.add_child(collider); game.add_child(wall)
	await physics_frame
	check(not player.target_candidates().has(actors[0]),"Wall blocks acquisition")
	player.occluded_for = 0; player.update_target(.3)
	check(player.target == actors[0],"Brief obstruction preserves lock")
	game.target_indicator._process(.01)
	check(not game.target_indicator.visible,"Obstructed target marker is hidden")
	player.update_target(.31)
	check(player.target == null,"Sustained obstruction releases lock")
	wall.queue_free(); await physics_frame
	player.target = actors[0]; player.occluded_for = 0
	actors[0].position.z = -25
	player.update_target(.01)
	check(player.target == null,"Retention range releases distant target")
	actors[0].position.z = -4
	player.yaw = 0; player.pitch = -.12; player.pivot.rotation = Vector3(-.12,0,0)
	await physics_frame
	tap_point = camera.unproject_position(Targeting.aim_point(actors[0]))
	var touch = game.mobile_controls
	if not is_instance_valid(touch):
		touch = preload("res://game/presentation/mobile_controls.gd").new(); touch.game = game; game.add_child(touch)
	touch.set_process(false); touch.active = true
	var tap := InputEventScreenTouch.new(); tap.index = 41; tap.position = tap_point; tap.pressed = true
	touch._input(tap); tap.pressed = false; touch._input(tap)
	check(player.target == actors[0],"Real mobile tap gesture acquires enemy")
	tap.pressed = true; touch._input(tap); tap.pressed = false; tap.canceled = true; touch._input(tap)
	check(player.target == actors[0],"Cancelled mobile tap cannot release focus")
	tap.canceled = false; tap.pressed = true; touch._input(tap)
	var drag := InputEventScreenDrag.new(); drag.index = tap.index; drag.position = tap_point+Vector2(30,0); drag.relative = Vector2(30,0)
	touch._input(drag); tap.pressed = false; touch._input(tap)
	check(player.target == null,"Intentional look drag releases auto-tracking without retapping")
	tap.pressed = true; touch._input(tap); touch.advance_gestures(.4); tap.pressed = false; touch._input(tap)
	check(player.target == null,"Long empty-space press is not a target tap")
	tap.pressed = true; touch._input(tap); touch.release_all()
	check(touch.look_taps.is_empty() and touch.fingers.is_empty() and touch.buttons.size() == 4,"Focus cleanup clears pending target gestures; four buttons remain")
	player.target = actors[0]; player.occluded_for = 0
	game.target_indicator._process(.01)
	check(game.target_indicator.visible and game.target_indicator.mouse_filter == Control.MOUSE_FILTER_IGNORE,"Live target has a passive torso indicator")
	game.pause(true); game.target_indicator._process(.01)
	check(not game.target_indicator.is_visible_in_tree(),"Pause hides target marker")
	touch.active = true; tap.pressed = true; touch._input(tap)
	check(not touch.active and touch.fingers.is_empty(),"Pending touch cannot retarget or activate controls after pause")
	game.pause(false); Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.input_grace_ticks = 0; player.set_physics_process(true)
	for frame in range(60): await physics_frame
	player.set_physics_process(false)
	var enemy_point := camera.unproject_position(Targeting.aim_point(actors[0]))
	var helmet_point := camera.unproject_position(player.global_position+Vector3.UP*1.9)
	check(enemy_point.y < helmet_point.y-18,"Locked framing keeps enemy marker above the knight helmet")
	var camera_wall := StaticBody3D.new(); camera_wall.position = Vector3(0,1.5,6)
	var camera_shape := CollisionShape3D.new(); var camera_box := BoxShape3D.new(); camera_box.size = Vector3(4,4,.3); camera_shape.shape = camera_box
	camera_wall.add_child(camera_shape); game.add_child(camera_wall)
	for frame in range(4): await physics_frame
	check(player.arm.get_hit_length() < 3 and player.arm.get_hit_length() > .3,"Spring camera retracts in front of solid geometry")
	camera_wall.queue_free()
	for frame in range(4): await physics_frame
	check(player.arm.get_hit_length() > 3.8,"Spring camera restores distance after obstruction clears")
	if DisplayServer.get_name() != "headless":
		var args := OS.get_cmdline_user_args()
		var output: String = args[0] if not args.is_empty() and args[0] != "--touch" else ProjectSettings.globalize_path("res://.tools/review/targeting")
		DirAccess.make_dir_recursive_absolute(output)
		game.settings.values.ui_scale = 1.5; game.apply_settings()
		for language in ["bg","en","ru","fr","ar"]:
			game.set_language(language)
			await create_timer(.15,true).timeout
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(output+"/"+language+".png")
			check(game.target_indicator.visible,"Translated HUD preserves target marker: "+language)
			var help: String = game.control_help()
			var translated: String = preload("res://game/localization/localizer.gd").text(help)
			check(language == "en" or (translated != help and not translated.contains("Tap an enemy") and not translated.contains("Curved arrow")),"New touch help translates: "+language)
			game.show_journal()
			for item in game.choices.get_children():
				if item is Button and preload("res://game/localization/localizer.gd").source(item) == "Controls":
					item.pressed.emit(); break
			await create_timer(.1,true).timeout
			check(game.dialogue_text.text == translated,"Updated instructions are reachable through real Controls: "+language)
			check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(game.dialogue.get_global_rect()),"Large-text Controls remain inside viewport: "+language)
			RenderingServer.force_draw(false)
			root.get_texture().get_image().save_png(output+"/"+language+"-controls.png")
			game.leave_dialogue(); Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game.queue_free(); await process_frame
	print("Targeting: %d assertions, %s" % [assertions,"PASS" if failures == 0 else "FAIL"])
	quit(0 if failures == 0 else 1)
