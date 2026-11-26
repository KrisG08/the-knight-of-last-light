extends SceneTree
const Region=preload("res://game/world/regions/graybox_region.gd")
const Portals=preload("res://game/presentation/region_portals.gd")
const Rules=preload("res://game/campaign/domain/campaign_rules.gd")
var assertions:=0
var failures:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void:
	create_timer(150,true).timeout.connect(func(): push_error("Portal checks timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	var camera:=Camera3D.new(); root.add_child(camera); camera.current=true
	var count:=0
	var locked:=Rules.new_game(1)
	var args:=OS.get_cmdline_user_args()
	var unlocked: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(args[0])) if not args.is_empty() else load("res://tests/finale_checks.gd").citadel_state()
	for id in Portals.ROUTES:
		var region:=Region.new(); region.build(id); root.add_child(region)
		var manager: Node3D=region.get_node("RegionPortals")
		var before:=JSON.stringify(locked)
		manager.apply_state(locked)
		check(manager.find_children("*","CollisionObject3D",true,false).is_empty(),id+" cosmetic portals never block physics/focus rays")
		for key in manager.portals:
			var gate: Node3D=manager.portals[key]; count+=1
			check(gate.position.distance_to(region.points[key])<0.15,id+" portal stays on actual travel point "+key)
			check(gate.surface.mesh.get_aabb().size.y>4 and gate.surface.mesh.get_faces().size()>100,"Portal aperture has an authored pointed-arch silhouette")
			if Portals.LOCKS.has(key): check(not gate.accessible,"Progress-locked route has a closed sigil: "+key)
		manager.apply_state(unlocked)
		for gate in manager.portals.values(): check(gate.accessible,id+" all eligible links activate with completed prerequisites")
		if id=="region.ritual":
			region.entrance_barrier.collision_layer=1
			await create_timer(0.35).timeout
			check(not manager.portals.ritual_exit.accessible,"Actual active boss barrier closes the return portal visual")
			region.entrance_barrier.collision_layer=0
			await create_timer(0.35).timeout
			check(manager.portals.ritual_exit.accessible,"Actual released boss barrier restores the return portal visual")
		check(before==JSON.stringify(locked),"Portal presentation never mutates campaign progress")
		check(not manager.fill.shadow_enabled,"At most one local shadowless light per loaded region")
		region.queue_free(); await process_frame
	check(count==20,"Every authored forward/return link is covered")
	print("Campaign portals: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL"))
	quit(1 if failures else 0)
