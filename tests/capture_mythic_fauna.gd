extends SceneTree
func _initialize() -> void:
	create_timer(180,true).timeout.connect(func(): push_error("Fauna capture timeout"); quit(1))
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
	var camera := Camera3D.new()
	game.add_child(camera)
	camera.current = true
	camera.fov = 58
	for id in preload("res://game/presentation/mythic_fauna.gd").INHABITANTS:
		if not OS.get_cmdline_user_args().is_empty() and id not in OS.get_cmdline_user_args(): continue
		await game.transition(id)
		game.pause(false)
		game.player.enabled = false
		game.player.hide()
		game.ui_layer.hide()
		for actor in game.enemies: actor.set_physics_process(false)
		for creature in game.region.get_node("MythicFauna").get_children():
			if creature.get_script()!=preload("res://game/presentation/ambient_creature.gd"): continue
			if creature.species in ["goblin","troll","dwarf"] and creature.activity=="stroll":
				if creature.stroll.length()<0.1:
					push_error("Authored folk route blocked: "+str(creature.global_position)); quit(1); return
				creature.stroll_time = 2.1
			if creature.species in ["barghest","goblin","dwarf","troll"]:
				var point := Vector2(creature.position.x,creature.position.z)
				for obstacle in game.region.obstacles:
					if obstacle.grow(0.75).has_point(point):
						push_error("Fox placement overlaps an authored physical footprint: "+id)
						quit(1)
						return
			var target: Vector3 = creature.global_position+Vector3.UP*(1.8 if creature.species=="ash_dragon" else 0.8)
			camera.global_position = target+Vector3(7,3,9) if creature.species=="ash_dragon" else target+Vector3(3,1,4)
			if creature.species in ["wraith","sentinel","gargoyle","goblin","troll","dwarf"]:
				target = creature.global_position+Vector3.UP*(2.5 if creature.species=="sentinel" else 1.4)
				camera.global_position = target+creature.basis*Vector3(3,1,-7)
			if creature.species in ["goblin","dwarf"]:
				target = creature.global_position+Vector3.UP*0.9
				camera.global_position = target+creature.basis*Vector3(1.5,0.3,-3)
			if creature.species=="troll":
				target = creature.global_position+Vector3.UP*2
				camera.global_position = target+creature.basis*Vector3(4,1,-8)
			if id in ["region.crypt","region.grove","region.sanctum","region.forge","region.ritual"]:
				camera.global_position = target+Vector3(-signf(target.x)*3.5,0.7,-signf(target.z)*1.5)
			if id=="region.order" and creature.species=="wraith": camera.global_position = target+Vector3(2,0.7,4)
			if id=="region.refuge" and creature.species=="goblin" and creature.get_index()==2: camera.global_position = target+Vector3(-2,0.5,3)
			camera.look_at(target)
			for frame in range(10): await process_frame
			await RenderingServer.frame_post_draw
			var filename: String = "res://.tools/review/population-"+id.trim_prefix("region.")+"-"+creature.species+"-"+str(creature.get_index())+".png"
			root.get_texture().get_image().save_png(filename)
			print("Captured "+filename)
			if creature.species in ["goblin","troll","dwarf"] and creature.activity=="stroll":
				var before: Vector3 = creature.position
				for frame in range(45): await process_frame
				await RenderingServer.frame_post_draw
				if creature.position.distance_to(before)<0.02:
					push_error("Passive folk did not walk in native runtime"); quit(1); return
				root.get_texture().get_image().save_png(filename.trim_suffix(".png")+"-walking.png")
				print("Native walking verified: "+creature.species)
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.queue_free()
	await process_frame
	quit(0)
