extends SceneTree
const Population = preload("res://game/presentation/mythic_fauna.gd")
const Creature = preload("res://game/presentation/ambient_creature.gd")
func _initialize() -> void:
	create_timer(90,true).timeout.connect(func(): push_error("Population audit timeout"); quit(1))
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
	var failures := 0
	var total := 0
	for id in Population.INHABITANTS:
		await game.transition(id)
		game.pause(false)
		var count := 0
		for creature in game.region.get_node("MythicFauna").get_children():
			if creature.get_script()!=Creature: continue
			count += 1
			if creature.has_method("receive_hit") or creature.is_in_group("hostiles") or not creature.find_children("*","CollisionObject3D",true,false).is_empty():
				print("INTERACTIVE "+id+" "+creature.species); failures += 1
			if creature.species in ["goblin","dwarf","troll"] and creature.activity=="stroll" and creature.stroll.length()<0.1:
				print("BLOCKED "+id+" "+creature.species+" "+str(creature.position)); failures += 1
			if creature.species in ["goblin","dwarf","troll"]:
				var ray := PhysicsRayQueryParameters3D.create(creature.global_position+Vector3.UP*0.3,creature.global_position-Vector3.UP*0.4,1)
				if game.region.get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
					print("NO FLOOR "+id+" "+str(creature.position)); failures += 1
			if creature.species in ["goblin","dwarf","troll","wraith"]:
				for obstacle in game.region.obstacles:
					if obstacle.grow(0.65).has_point(Vector2(creature.position.x,creature.position.z)):
						print("OVERLAP "+id+" "+creature.species+" "+str(creature.position)); failures += 1; break
		if count<2: failures += 1
		total += count
		print(id+": "+str(count)+" passive inhabitants")
	print("Population audit: "+str(total)+" inhabitants / "+str(Population.INHABITANTS.size())+" areas / "+str(failures)+" failures")
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.queue_free()
	await process_frame
	quit(1 if failures>0 else 0)
