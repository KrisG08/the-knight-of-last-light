extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.benchmarking = true # Suppress external focus pause in this scripted capture.
	await game.start_selected()
	game.pause(false)
	game.player.enabled = true
	game.ui_layer.hide()
	if not game.player.model.has("skeletal_locomotion"):
		push_error("Run with --skeletal-preview")
		quit(1)
		return
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 55
	DirAccess.make_dir_recursive_absolute("res://.tools/review")
	var origin: Vector3 = game.player.position
	Input.action_press("move_forward")
	for frame in range(60):
		await physics_frame
		camera.position = game.player.position+Vector3(3,1.35,0.2)
		camera.look_at(game.player.position+Vector3.UP*0.95)
		if frame in [10,20,30,40,50]:
			var rig = game.player.model.skeletal_locomotion
			print("Gait frame %d: %s %.3f hip %.3f knee %.3f" % [frame,rig.current,rig.animation.current_animation_position,rig.skeleton.get_bone_pose_rotation(3).get_euler().x,rig.skeleton.get_bone_pose_rotation(4).get_euler().x])
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://.tools/review/skeletal-gait-%d.png" % frame)
	Input.action_release("move_forward")
	print("Actual physical locomotion distance: %.2f" % origin.distance_to(game.player.position))
	for frame in range(12): await physics_frame
	game.player.combat.request_action("light_attack")
	for frame in range(12): await physics_frame
	print("Attack transition: %s / %s" % [game.player.combat.state,game.player.model.skeletal_locomotion.current])
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/skeletal-attack.png")
	for frame in range(40): await physics_frame
	Input.action_press("dodge")
	await physics_frame
	Input.action_release("dodge")
	for frame in range(8): await physics_frame
	print("Dodge transition: %.2f / %s" % [game.player.dodge_left,game.player.model.skeletal_locomotion.current])
	assert(game.player.model.skeletal_locomotion.current=="jog")
	assert(game.player.model.skeletal_locomotion.animation.speed_scale>2)
	camera.position = game.player.position+Vector3(3,1.35,0.2)
	camera.look_at(game.player.position+Vector3.UP*0.95)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/skeletal-dodge.png")
	for frame in range(50): await physics_frame
	Input.action_press("move_forward")
	Input.action_press("sprint")
	for frame in range(24): await physics_frame
	print("Sprint transition: %s" % game.player.model.skeletal_locomotion.current)
	camera.position = game.player.position+Vector3(3,1.35,0.2)
	camera.look_at(game.player.position+Vector3.UP*0.95)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/skeletal-sprint.png")
	Input.action_release("move_forward")
	Input.action_release("sprint")
	for frame in range(24): await physics_frame
	Input.action_press("block")
	for frame in range(20): await physics_frame
	camera.position = game.player.position+Vector3(2.2,1.6,-3.2)
	camera.look_at(game.player.position+Vector3.UP*1.05)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/natural-guard.png")
	Input.action_release("block")
	for frame in range(24): await physics_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/natural-idle.png")
	game.player.enabled = false
	var motion = game.player.model.skeletal_locomotion
	motion.set_process(false)
	motion.animation.play("jog")
	motion.animation.seek(motion.animation.get_animation("jog").length*0.8,true)
	motion.animation.pause()
	var source = preload("res://game/presentation/scanned_knight.gd")
	for mesh in game.player.visual.find_children("*","MeshInstance3D",true,false):
		if mesh.mesh==source.parts.shield: mesh.hide()
	for frame in range(6): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/skeletal-knee-inspection.png")
	motion.animation.play("stand")
	motion.set_process(true)
	for mesh in game.player.visual.find_children("*","MeshInstance3D",true,false):
		if mesh.mesh==source.parts.shield: mesh.show()
	game.player.enabled = true
	game.player.arm.get_child(0).make_current()
	game.ui_layer.show()
	for frame in range(12): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.tools/review/refined-in-game.png")
	var samples: Array[float] = []
	var previous := Time.get_ticks_usec()
	for frame in range(180):
		await process_frame
		var now := Time.get_ticks_usec()
		samples.append(float(now-previous)/1000.0)
		previous = now
	samples.sort()
	print("Stationary forest sample median/p95 ms: %.2f / %.2f; static memory %.1f MiB; rendered primitives %d" % [samples[90],samples[171],Performance.get_monitor(Performance.MEMORY_STATIC)/1048576.0,Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)])
	game.player.sounds.stop()
	game.queue_free()
	await process_frame
	quit(0)
