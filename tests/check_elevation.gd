extends SceneTree
const Region = preload("res://game/world/regions/graybox_region.gd")
var failures := 0
func _initialize() -> void:
	for action in ["move_forward","move_back","move_left","move_right","sprint","jump","dodge","pause","reset","light_attack","heavy_attack","block","heal","target_lock","cycle_target"]:
		if not InputMap.has_action(action): InputMap.add_action(action)
	create_timer(140).timeout.connect(func(): push_error("Elevation check timed out"); quit(1))
	call_deferred("run")
func run() -> void:
	for id in ["region.village","region.blackwood","region.order","region.peaks","region.citadel","region.ritual"]:
		var region := Region.new()
		region.build(id)
		root.add_child(region)
		await physics_frame
		await physics_frame
		var samples := [6.0,-3.0,-12.0,-21.0,-30.0,-39.0,-48.0,-54.0]
		if id=="region.ritual": samples=[6.0,0.0,-6.0]
		if id=="region.village": samples=[6.0,-3.0,-12.0,-21.0]
		var good := true
		for z in samples:
			var expected := region.height_at(0,z)
			var query := PhysicsRayQueryParameters3D.create(Vector3(0,expected+0.8,z),Vector3(0,expected-0.8,z),1)
			var hit := root.world_3d.direct_space_state.intersect_ray(query)
			if hit.is_empty() or absf(hit.position.y-expected)>0.08:
				good = false
				print("Bad floor ",id," z=",z," expected=",expected," hit=",hit)
		if not good: failures += 1
		print(id," authored surface/collision ","PASS" if good else "FAIL")
		if id=="region.citadel":
			var map := region.navigation.get_navigation_map()
			NavigationServer3D.map_set_active(map,true)
			NavigationServer3D.map_force_update(map)
			for tick in range(90):
				if NavigationServer3D.map_get_closest_point_owner(map,region.points.spawn)==region.navigation.get_rid(): break
				await physics_frame
			print("Nav vertices/polygons/iteration: ",region.navigation.navigation_mesh.vertices.size()," / ",region.navigation.navigation_mesh.get_polygon_count()," / ",NavigationServer3D.map_get_iteration_id(map)," closest ",NavigationServer3D.map_get_closest_point(map,region.points.spawn))
			var path := NavigationServer3D.map_get_path(region.navigation.get_navigation_map(),region.points.spawn,region.surface_point(Vector3(0,0,-54)),true)
			var valid_path := path.size()>2 and path[path.size()-1].y>43.5
			print("Three-flight navigation path ",path," ","PASS" if valid_path else "FAIL")
			if not valid_path: failures += 1
			if "--nav-only" in OS.get_cmdline_user_args():
				region.queue_free()
				await process_frame
				continue
			var knight := preload("res://game/actors/player/knight.gd").new()
			root.add_child(knight)
			knight.position = region.points.spawn
			knight.enabled = true
			knight.set_process_input(false)
			Input.action_press("move_forward")
			for tick in range(2000): await physics_frame
			Input.action_release("move_forward")
			var climbed := knight.position.z< -53 and knight.position.y>43.5
			print("Actual knight three-flight ascent: ",knight.position," ","PASS" if climbed else "FAIL")
			if not climbed: failures += 1
			Input.action_press("move_back")
			for tick in range(2000): await physics_frame
			Input.action_release("move_back")
			var descended := knight.position.z>53 and absf(knight.position.y-26)<0.1
			print("Actual knight descent: ",knight.position," ","PASS" if descended else "FAIL")
			if not descended: failures += 1
			knight.queue_free()
		region.queue_free()
		await process_frame
	quit(1 if failures>0 else 0)
