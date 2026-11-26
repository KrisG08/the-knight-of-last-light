extends SceneTree
var failures := 0
func _initialize() -> void:
	if "--baseline" in OS.get_cmdline_user_args():
		assert(ProjectSettings.load_resource_pack(ProjectSettings.globalize_path("res://build/windows-v0520/LastLight.pck"),true))
	call_deferred("run")
func run() -> void:
	var baseline := "--baseline" in OS.get_cmdline_user_args()
	var regions: Array = ["village","peaks","citadel"] if baseline else ["refuge","village","crypt","blackwood","grove","order","sanctum","peaks","forge","citadel","ritual"]
	for id in regions:
		var region = load("res://game/world/regions/graybox_region.gd").new()
		region.build("region."+id)
		root.add_child(region)
		var visual: MeshInstance3D
		for node in region.find_children("WoodlandRidges","MeshInstance3D",true,false): visual=node
		assert(visual!=null)
		var legacy := {"village":Vector2(40,45),"peaks":Vector2(32,47),"citadel":Vector2(32,39)}
		var extent: Vector2 = legacy[id] if baseline else visual.get_parent().get_meta("inner_extent")
		var maximum := 0.0; var reach := 0.0; var samples := 0
		for vertex: Vector3 in visual.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
			reach = maxf(reach,Vector2(vertex.x,vertex.z).length())
			var edge_x: bool = absf(absf(vertex.x)-extent.x-0.02)<0.01 and absf(vertex.z)<=extent.y+0.021
			var edge_z: bool = absf(absf(vertex.z)-extent.y-0.02)<0.01 and absf(vertex.x)<=extent.x+0.021
			if edge_x or edge_z:
				var world := visual.global_transform*vertex
				var expected: float = region.height_at(world.x,world.z)-0.08*visual.global_basis.y.length()
				maximum = maxf(maximum,absf(world.y-expected)); samples += 1
		var passed := samples>0 and maximum<0.03 and reach>4000 and visual.find_children("*","CollisionShape3D",true,false).is_empty()
		if not baseline:
			var forest := visual.get_parent().get_node("HillsideForest")
			passed = passed and forest.get_meta("pine_count",0)>5000 and forest.find_children("*","CollisionShape3D",true,false).is_empty()
		print(id," apron samples=",samples," maximum floor seam m=",snappedf(maximum,0.001)," far reach m=",roundi(reach)," ","PASS" if passed else "FAIL")
		if not passed: failures += 1
		region.queue_free(); await process_frame
	quit(1 if failures>0 else 0)
