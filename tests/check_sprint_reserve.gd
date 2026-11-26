extends SceneTree
var failed := false

func _initialize() -> void:
	call_deferred("run")

func verify(valid: bool, message: String) -> void:
	print(message+": "+("PASS" if valid else "FAIL"))
	failed = failed or not valid

func run() -> void:
	preload("res://game/core/input_bindings.gd").setup()
	var floor_body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(100,1,100)
	collision.shape = shape
	collision.position.y = -0.5
	floor_body.add_child(collision)
	root.add_child(floor_body)
	var knight = preload("res://game/actors/player/knight.gd").new()
	root.add_child(knight)
	knight.enabled = true
	for frame in range(12): await physics_frame
	knight.stamina = 50
	knight.regeneration_delay = 100 # Isolate consumption from regeneration.
	var origin: Vector3 = knight.position
	Input.action_press("move_forward")
	for frame in range(30): await physics_frame
	verify(knight.position.distance_to(origin)>1 and is_equal_approx(knight.stamina,50),"Real walking moves without spending stamina")
	Input.action_press("sprint")
	for frame in range(30): await physics_frame
	verify(knight.stamina<46 and knight.stamina>44,"Real sprint spends ten stamina per second")
	Input.action_release("sprint")
	Input.action_release("move_forward")
	for frame in range(80): await physics_frame
	verify(knight.stamina>50,"Reserve regenerates after sprint stops")
	knight.stamina = 0
	knight.regeneration_delay = 100
	Input.action_press("dodge")
	await physics_frame
	await physics_frame
	Input.action_release("dodge")
	verify(knight.dodge_left>0 and is_zero_approx(knight.stamina),"Real dodge works with empty reserve and costs nothing")
	knight.sounds.stop()
	knight.queue_free()
	floor_body.queue_free()
	await process_frame
	quit(1 if failed else 0)
