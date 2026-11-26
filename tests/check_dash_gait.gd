extends SceneTree
## Grounded runtime repro; --baseline samples the previous animation guard.
func _initialize() -> void:
	create_timer(20,true).timeout.connect(func(): quit(1))
	call_deferred("run")
func run() -> void:
	var world := Node3D.new(); root.add_child(world)
	var floor_body := StaticBody3D.new(); world.add_child(floor_body)
	var shape := CollisionShape3D.new(); var box := BoxShape3D.new()
	box.size = Vector3(20,0.2,20); shape.shape = box; shape.position.y = -0.1; floor_body.add_child(shape)
	var knight := preload("res://game/actors/player/knight.gd").new()
	knight.position = Vector3(0,0.2,0); world.add_child(knight)
	knight.set_physics_process(false); knight.enabled = true
	for frame in range(20):
		await physics_frame
		knight.velocity = Vector3(0,-2,0); knight.move_and_slide()
	assert(knight.is_on_floor())
	var motion = knight.model.skeletal_locomotion
	var baseline: Node3D
	if "--baseline" in OS.get_cmdline_user_args():
		var script := GDScript.new()
		script.source_code = FileAccess.get_file_as_string("res://game/presentation/knight_locomotion.gd").replace("and actor.is_on_floor() and actor.combat.state in", "and actor.is_on_floor() and actor.dodge_left<=0 and actor.combat.state in")
		assert(script.reload()==OK)
		baseline = script.new()
		baseline.actor = knight; baseline.original = knight.model
		baseline.skeleton = motion.skeleton; baseline.animation = motion.animation
		baseline.visual_root = knight.visual; baseline.current = motion.current
		motion = baseline
	knight.velocity = Vector3(0,0,-8); knight.dodge_left = 0.4
	knight.combat.state = "locomotion"
	motion._process(1.0/60)
	var passed: bool = motion.current=="jog" and motion.animation.speed_scale>2
	print("Dash gait: ",motion.current," / cadence ",motion.animation.speed_scale," / grounded ",knight.is_on_floor()," / ","PASS" if passed else "FAIL")
	if baseline!=null: baseline.free()
	knight.sounds.stop(); world.queue_free(); await process_frame
	quit(0 if passed else 1)
