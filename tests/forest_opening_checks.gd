extends RefCounted
const Forest = preload("res://game/world/regions/forest_approach.gd")
const Opening = preload("res://game/ui/opening_cinematic.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	check.call(game.region.points.spawn.distance_to(game.region.points.travel)>180,"New start has a substantial woodland journey to the village passage")
	var pines: Dictionary = preload("res://game/presentation/real_assets.gd").meshes.pine_sapling_small
	var bounded := true
	for mesh: Mesh in pines.values():
		bounded = bounded and mesh.surface_get_array_index_len(1)<120000 and mesh.surface_get_arrays(1)[Mesh.ARRAY_TEX_UV].size()>0
	check.call(bounded,"Forest canopies use bounded imported LOD geometry while preserving textured UVs")
	var map: RID = game.region.navigation.get_navigation_map()
	var path := NavigationServer3D.map_get_path(map,game.region.points.spawn,game.region.points.travel,true)
	check.call(path.size()>=2 and path[-1].distance_to(game.region.points.travel)<2,"Physical forest navigation reaches the village passage from the new camp")
	var safe := true
	for index in range(1,Forest.ROAD.size()):
		var from: Vector3 = Forest.ROAD[index-1]+Vector3.UP
		var to: Vector3 = Forest.ROAD[index]+Vector3.UP
		var query := PhysicsRayQueryParameters3D.create(from,to,1)
		if not game.get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			safe = false
	check.call(safe,"Every authored road segment is free of trunk/perimeter blockers at body height")
	var corridor_clear := true
	for index in range(1,Forest.ROAD.size()):
		var start: Vector3 = Forest.ROAD[index-1]
		var finish: Vector3 = Forest.ROAD[index]
		var side := (finish-start).normalized().cross(Vector3.UP)
		for offset in [-1.2,0,1.2]:
			var query := PhysicsRayQueryParameters3D.create(start+side*offset+Vector3.UP,finish+side*offset+Vector3.UP,1)
			corridor_clear = corridor_clear and game.get_world_3d().direct_space_state.intersect_ray(query).is_empty()
	check.call(corridor_clear,"Road dressing preserves a 2.4m clear corridor along every authored segment")
	var tower_query := PhysicsRayQueryParameters3D.create(Vector3(27,12,12),Vector3(27,-2,12),1)
	check.call(not game.get_world_3d().direct_space_state.intersect_ray(tower_query).is_empty(),"Road watchtower visible walls have physical collision")
	var horizon = game.region.get_node("ForestHorizon/WoodlandRidges")
	var outside := true
	for vertex: Vector3 in horizon.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
		outside = outside and (absf(vertex.x)>68 or absf(vertex.z)>112)
	check.call(outside,"Cosmetic horizon stays outside the playable woodland rectangle")
	var ground_query := PhysicsRayQueryParameters3D.create(game.region.points.spawn+Vector3.UP*2,game.region.points.spawn-Vector3.UP*2,1)
	check.call(not game.get_world_3d().direct_space_state.intersect_ray(ground_query).is_empty(),"Forest terrain has upward-facing collision beneath the new spawn")
	# Exercise the actual new-game cinematic branch with a memory-only save store.
	game.testing = false
	game.start_selected()
	for frame in range(180):
		await tree.physics_frame
		if is_instance_valid(game.opening):
			break
	check.call(is_instance_valid(game.opening) and tree.paused and not game.player.enabled,"New game opens the introduction and keeps gameplay paused")
	check.call(not game.region.visible and not game.player.visible,"Film suspends background world drawing while decoding")
	var intro = game.opening
	check.call(intro.video.stream is VideoStreamTheora and intro.controls.get_child_count()==1 and not intro.error_label.visible,"Opening plays an actual Theora movie with one skip control instead of a photo slideshow")
	intro.controls.get_child(0).pressed.emit()
	await tree.process_frame
	check.call(not is_instance_valid(game.opening) and game.started and game.player.position.distance_to(game.region.points.checkpoint)<3,"Skipping finishes the introduction at the authored camp")
	check.call(game.region.visible and game.player.visible,"Finishing the film restores both world and knight visibility")
	game.testing = true
	game.pause(true)
	await game.start_selected(true)
	check.call(not is_instance_valid(game.opening) and game.session.active,"Loading an existing campaign bypasses the introduction")
	game.player.enabled = false
	game.player.position = game.region.points.travel+Vector3(0,0.1,1)
	check.call(game.focus()=="travel","Road endpoint exposes the actual village interaction")
	game.interact()
	while game.transitioning:
		await tree.physics_frame
	check.call(game.region.region_id=="region.village" and game.enemies.size()==5,"Village passage preserves the existing campaign encounters")
	for enemy in game.enemies:
		enemy.sounds.stop()
		enemy.set_physics_process(false)
	game.player.position = game.region.points.travel+Vector3(0,0.1,-1)
	game.interact()
	while game.transitioning:
		await tree.physics_frame
	check.call(game.region.region_id=="region.refuge" and game.player.position.distance_to(game.region.points.travel)<2,"Returning from village arrives at the connected woodland road rather than the distant camp")
	game.player.sounds.stop()
	game.ui_sound.stop()
	game.pause(true)
	game.queue_free()
	await tree.process_frame
