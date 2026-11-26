extends SceneTree
const Region=preload("res://game/world/regions/graybox_region.gd")
var failures:=0
var assertions:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void:
	create_timer(120,true).timeout.connect(func(): push_error("Late world checks timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	var region:=Region.new(); region.build("region.citadel"); root.add_child(region)
	await physics_frame; await physics_frame
	check(region.points.spawn.z==54 and region.points.citadel_exit.z==57,"Arrival/return use the enlarged forecourt")
	check(region.points.citadel_depth.z==-55 and region.points.prisoners.x==-19,"Existing progression interactions retain upper-castle positions")
	for point in [Vector3(0,0,54),Vector3(-7,0,38),Vector3(36,0,40),Vector3(-36,0,14),Vector3(0,0,28),Vector3(0,0,-54)]:
		var at: Vector3=region.surface_point(point)
		var ray:=PhysicsRayQueryParameters3D.create(at+Vector3.UP*0.8,at-Vector3.UP*0.8,1)
		var hit:=root.world_3d.direct_space_state.intersect_ray(ray)
		check(not hit.is_empty() and absf(hit.position.y-at.y)<0.08,"Expanded playable ground has matching collision at "+str(point))
	var map:=region.navigation.get_navigation_map()
	NavigationServer3D.map_set_active(map,true); NavigationServer3D.map_force_update(map)
	for frame in range(90):
		if NavigationServer3D.map_get_closest_point_owner(map,region.points.spawn)==region.navigation.get_rid(): break
		await physics_frame
	for goal in ["checkpoint","prisoners","ritual_lore","citadel_depth","citadel_exit"]:
		var path:=NavigationServer3D.map_get_path(map,region.points.spawn,region.points[goal],true)
		check(path.size()>1 and path[-1].distance_to(region.points[goal])<1.5,"New entrance reaches "+goal+" through actual navigation")
	region.queue_free(); await process_frame
	for entry in [["region.blackwood",["checkpoint","grove","order_gate"]],["region.order",["checkpoint","expedition","order_depth","peaks_gate"]]]:
		region=Region.new(); region.build(entry[0]); root.add_child(region)
		await physics_frame; await physics_frame
		map=region.navigation.get_navigation_map()
		NavigationServer3D.map_set_active(map,true); NavigationServer3D.map_force_update(map)
		for frame in range(90):
			if NavigationServer3D.map_get_closest_point_owner(map,region.points.spawn)==region.navigation.get_rid(): break
			await physics_frame
		for goal in entry[1]:
			var path:=NavigationServer3D.map_get_path(map,region.points.spawn,region.points[goal],true)
			check(path.size()>1 and path[-1].distance_to(region.points[goal])<1.5,entry[0]+" new arch colliders preserve route to "+goal)
		region.queue_free(); await process_frame
	print("Late world collision/navigation: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL"))
	quit(1 if failures else 0)
