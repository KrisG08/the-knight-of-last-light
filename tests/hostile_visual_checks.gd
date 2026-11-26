extends RefCounted
const Sources = preload("res://game/presentation/hostile_source_parts.gd")
const Enemy = preload("res://game/actors/enemies/training_soldier.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	tree.paused = false
	var player := preload("res://game/actors/player/knight.gd").new()
	tree.root.add_child(player)
	player.enabled = false
	player.position = Vector3(0,0,40)
	player.set_physics_process(false)
	var actors: Array[CharacterBody3D] = []
	for profile in ["hollow_villager","fallen_soldier","grave_hound","bound_shade"]:
		var actor := Enemy.new()
		actor.profile = load("res://content/enemies/"+profile+".tres")
		actor.player = player
		tree.root.add_child(actor)
		actor.set_physics_process(false)
		actors.append(actor)
	for id in ["gravedigger","thorn_beast","fallen_commander","iron_warden","maldrek"]:
		var actor = load("res://game/actors/bosses/"+id+".gd").new()
		actor.player = player
		tree.root.add_child(actor)
		actor.set_physics_process(false)
		actors.append(actor)
	var upgraded := true
	var physical := true
	for actor in actors:
		upgraded = upgraded and actor.visual.has_meta("hostile_model")
		for mesh in actor.visual.find_children("*","MeshInstance3D",true,false):
			upgraded = upgraded and not mesh.mesh is BoxMesh
		physical = physical and actor.find_children("*","CollisionShape3D",true,false).size()==1 and actor.collision_layer==4
	check.call(upgraded,"All ordinary enemy profiles and five bosses use the new non-block models")
	check.call(physical,"Hostile visual upgrades add no extra physics shapes or change actor collision layers")
	var fitted := true
	var valid_fittings := true
	for actor in actors:
		var fittings: Array[Node] = actor.visual.find_children("CharacterRegalia","Node3D",true,false)
		fitted = fitted and (fittings.size()==1 or actor.visual.has_meta("meshy_model"))
		for outfit in fittings:
			valid_fittings = valid_fittings and outfit.get_child_count()<=7
			for mesh in outfit.find_children("*","MeshInstance3D",true,false):
				for surface in range(mesh.mesh.get_surface_count()):
					var arrays: Array = mesh.mesh.surface_get_arrays(surface)
					valid_fittings = valid_fittings and arrays[Mesh.ARRAY_VERTEX].size()==arrays[Mesh.ARRAY_NORMAL].size() and arrays[Mesh.ARRAY_VERTEX].size()==arrays[Mesh.ARRAY_TEX_UV].size()
	check.call(fitted,"All nine actual enemy/boss types have their individual fitted appearance")
	check.call(valid_fittings,"Static fittings are batched with preserved geometry normals and UVs")
	var preserved := true
	for id in ["strong-knight","red-fox"]:
		for mesh: Mesh in Sources.prepare(id).values():
			preserved = preserved and mesh.get_surface_count()>0
			for surface in range(mesh.get_surface_count()):
				var arrays := mesh.surface_get_arrays(surface)
				var count: int = arrays[Mesh.ARRAY_VERTEX].size()
				preserved = preserved and count>0 and arrays[Mesh.ARRAY_NORMAL].size()==count and arrays[Mesh.ARRAY_TEX_UV].size()==count
				for index in arrays[Mesh.ARRAY_INDEX]:
					preserved = preserved and index>=0 and index<count
	check.call(preserved,"Imported hostile limb partitions preserve valid compacted geometry, normals, UVs and indices")
	var actor := actors[0]
	actor.state = "windup"
	await tree.process_frame
	await tree.process_frame
	check.call(actor.visual.get_node("AttackTelegraph").visible,"New model visibly signals the actual windup state")
	actor.state = "idle"
	actor.velocity = Vector3(2,0,0)
	await tree.process_frame
	await tree.process_frame
	var pose: Node
	for child in actor.visual.get_children():
		if child.get_script()==preload("res://game/presentation/hostile_pose.gd"):
			pose = child
	var before: float = pose.clock
	tree.paused = true
	await tree.process_frame
	await tree.process_frame
	check.call(pose.clock==before,"Hostile presentation animation obeys pause rather than advancing through menus")
	tree.paused = false
	var tracks_damage := true
	var hides_on_death := true
	var resets_health := true
	for hostile in actors:
		var meter = hostile.get_node("HostileHealth")
		hostile.state = "idle"
		hostile.receive_hit(Vector3.ZERO, 20.0, 1.0, 0.0)
		meter.sync()
		tracks_damage = tracks_damage and meter.fill_fraction > 0 and meter.fill_fraction < 1 and is_equal_approx(meter.fill_fraction, hostile.health / hostile.max_health) and hostile.label.text == hostile.display_name.to_upper()
		hostile.health = 0
		meter.sync()
		hides_on_death = hides_on_death and not meter.visible and not hostile.label.visible
		if hostile.has_method("reset_encounter"):
			hostile.reset_encounter()
			meter.sync()
			resets_health = resets_health and is_equal_approx(meter.fill_fraction, 1.0)
	check.call(tracks_damage, "All nine hostile types show a proportional health meter after actual damage, with name only")
	check.call(hides_on_death, "Dead hostiles hide both overhead health meter and caption")
	check.call(resets_health, "Respawned ordinary hostiles refill their overhead health meter")
	for index in range(actors.size()):
		actors[index].sounds.stop()
		if index==4:
			actors[index].burst_marker.queue_free()
		actors[index].queue_free()
	player.sounds.stop()
	player.queue_free()
	await tree.process_frame
