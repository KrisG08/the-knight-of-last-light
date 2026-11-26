extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var knight = preload("res://game/actors/player/knight.gd").new()
	root.add_child(knight)
	knight.set_physics_process(false)
	var skeleton: Skeleton3D = knight.model.skeletal_locomotion.skeleton
	var valid := true
	for index in range(skeleton.get_bone_count()):
		valid = valid and skeleton.get_bone_global_rest(index).origin.distance_to(skeleton.get_bone_global_pose(index).origin)<0.001
	print("Skinned leg standing pose matches bind origins: %s" % ("PASS" if valid else "FAIL"))
	knight.queue_free()
	await process_frame
	quit(0 if valid else 1)
