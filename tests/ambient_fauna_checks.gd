extends RefCounted
const Creature = preload("res://game/presentation/ambient_creature.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	tree.paused = false
	var creatures: Array[Node3D] = []
	var passive := true
	var visual := true
	for id in ["barghest","ash_dragon","wraith","sentinel","gargoyle","goblin","troll","dwarf"]:
		var creature := Creature.new()
		creature.setup(id,1.0)
		creature.position = Vector3(5,0,5)
		tree.root.add_child(creature)
		creatures.append(creature)
		passive = passive and not creature.is_in_group("hostiles") and not creature.has_method("receive_hit") and creature.find_children("*","CollisionObject3D",true,false).is_empty()
		visual = visual and not creature.find_children("*","MeshInstance3D",true,false).is_empty()
	check.call(passive,"All mythical fauna have no hostile membership, damage receiver or physical blockers")
	check.call(visual,"All eight passive creatures and entities use actual 3D geometry")
	var cached_count: int = Creature.dragon_parts.size()
	var repeated := Creature.new()
	repeated.setup("ash_dragon",1.0)
	tree.root.add_child(repeated)
	check.call(Creature.dragon_parts.size()==cached_count,"Repeated dragon instances share stable recolored mesh resources")
	var source_scene: PackedScene = Creature.scenes["icy-dragon"]
	var original := source_scene.instantiate()
	var retained := true
	for mesh in original.find_children("*","MeshInstance3D",true,false):
		for surface in range(mesh.mesh.get_surface_count()): retained = retained and mesh.mesh.surface_get_material(surface) is StandardMaterial3D
	check.call(retained,"Dark recoloring preserves the original source model materials")
	original.free()
	repeated.queue_free()
	for frame in range(3): await tree.process_frame
	var fixed := true
	for creature in creatures: fixed = fixed and creature.position==Vector3(5,0,5) and creature.clock>0
	check.call(fixed,"Unconfigured decorative actors remain at their authored position")
	var wandered := true
	var bounded := true
	var articulated := true
	for creature in creatures:
		if creature.species not in ["goblin","troll","dwarf"]: continue
		creature.set_stroll(Vector3(0,0,1),[])
		var travelled := false
		var swung := false
		for step in range(400):
			creature._process(0.1)
			travelled = travelled or creature.position.distance_to(Vector3(5,0,5))>0.3
			swung = swung or absf(creature.body.get_node("Leg1").rotation.x)>0.1
			bounded = bounded and creature.position.x==5 and creature.position.y==0 and creature.position.z>=5 and creature.position.z<=6
		wandered = wandered and travelled
		articulated = articulated and swung
	check.call(wandered and bounded and articulated,"Passive folk walk with articulated limbs and stay inside their authored corridor")
	var blocked := Creature.new()
	blocked.setup("goblin",1.0)
	blocked.position = Vector3(5,0,5)
	tree.root.add_child(blocked)
	blocked.set_stroll(Vector3(0,0,1),[Rect2(4,4,3,3)])
	blocked._process(10)
	check.call(blocked.stroll==Vector3.ZERO and blocked.position==Vector3(5,0,5),"Blocked ambient corridors fall back to stationary idle")
	check.call(blocked.body.get_node("Leg1").get_child(0).mesh==creatures[5].body.get_node("Leg1").get_child(0).mesh,"Articulated folk reuse cached limb meshes")
	blocked.queue_free()
	var before: float = creatures[0].clock
	var tail_before: Vector3 = creatures[0].tails[0].rotation
	var walking_before: Vector3 = creatures[5].position
	tree.paused = true
	for frame in range(2): await tree.process_frame
	check.call(creatures[0].clock==before and creatures[0].tails[0].rotation==tail_before and creatures[5].position==walking_before,"Ambient breathing, tails and walking stop with game pause")
	tree.paused = false
	for creature in creatures: creature.queue_free()
	await tree.process_frame
