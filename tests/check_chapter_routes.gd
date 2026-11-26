extends SceneTree
var failures := 0

func _initialize() -> void:
	create_timer(60,true).timeout.connect(func(): push_error("Chapter route check timeout"); quit(1))
	call_deferred("run")

func run() -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	while game.transitioning: await physics_frame
	game.benchmarking = true
	game.session.begin(1,false)
	game.session.state = load("res://tests/finale_checks.gd").citadel_state()
	game.started = true
	var destinations := {
		"region.blackwood":["grove","order_gate"],
		"region.grove":["root_seal"],
		"region.order":["expedition","order_depth","peaks_gate"],
		"region.sanctum":["oath_seal"],
		"region.peaks":["mine","fortress","citadel_gate"],
		"region.forge":["forge_seal"],
		"region.citadel":["prisoners","ritual_lore","citadel_depth"],
		"region.ritual":["artifact"]
	}
	for id in destinations:
		if not await game.transition(id):
			push_error("Route check transition rejected: "+id)
			failures+=1
			continue
		game.pause(false)
		game.player.enabled = false
		for actor in game.enemies: actor.set_physics_process(false)
		for frame in range(3): await physics_frame
		if is_instance_valid(game.region.navigation):
			var navigation: RID = game.region.navigation.get_navigation_map()
			for key in destinations[id]:
				var target: Vector3 = game.region.points[key]
				var path := NavigationServer3D.map_get_path(navigation,game.region.points.spawn,target,true)
				var valid := path.size()>1 and path[path.size()-1].distance_to(target)<3.5
				print("Navigation %s -> %s: %s" % [id,key,"PASS" if valid else "FAIL"])
				if not valid: failures+=1
		else:
			# Original open boss arenas use direct steering, not a navmesh. Confirm
			# their central physical approach remains unobstructed above the floor.
			var origin: Vector3 = game.region.points.spawn+Vector3.UP*0.8
			var target: Vector3 = game.region.points[destinations[id][0]]+Vector3.UP*0.8
			var approach := PhysicsRayQueryParameters3D.create(origin,target,1)
			var clear: bool = game.player.get_world_3d().direct_space_state.intersect_ray(approach).is_empty()
			print("Open arena approach %s: %s" % [id,"PASS" if clear else "FAIL"])
			if not clear: failures+=1
		var spawn: Vector3 = game.region.points.spawn
		var query := PhysicsRayQueryParameters3D.create(spawn+Vector3.UP*0.4,spawn-Vector3.UP*1.5,1)
		var floor_hit: Dictionary = game.player.get_world_3d().direct_space_state.intersect_ray(query)
		var floor_valid := not floor_hit.is_empty() and absf(floor_hit.position.y)<0.1
		print("Physical spawn floor %s: %s" % [id,"PASS" if floor_valid else "FAIL"])
		if not floor_valid: failures+=1
	game.queue_free()
	await process_frame
	print("Chapter route/floor failures: %d" % failures)
	quit(1 if failures>0 else 0)
