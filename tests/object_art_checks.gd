extends SceneTree
## Presentation regressions: pickup identity, cached geometry and combat-pivot isolation.
const Region=preload("res://game/world/regions/graybox_region.gd")
const Props=preload("res://game/presentation/quest_props.gd")
const Rules=preload("res://game/campaign/domain/campaign_rules.gd")
const Grip=preload("res://game/presentation/hostile_grip.gd")
var assertions:=0
var failures:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void:
	create_timer(180,true).timeout.connect(func(): push_error("Object art timeout"); quit(1))
	call_deferred("run")
func run() -> void:
	for spec in [["blackwood","satchel","scout_satchel","pickup.lyra_satchel"],["village","token","family_locket","pickup.family_token"]]:
		var region:=Region.new(); region.build("region."+spec[0]); root.add_child(region)
		var owner_node: Node3D=region.get(spec[1])
		var transform:=owner_node.transform
		var state:=Rules.new_game(1); region.apply_state(state)
		check(owner_node.is_visible_in_tree(),"Unclaimed quest item remains discoverable")
		check(not owner_node.get_child(0).visible,"Original pickup cube is hidden")
		check(owner_node.has_node("Detailed_"+spec[2]),"Recognizable quest model replaces proxy")
		var model: Node3D=owner_node.get_node("Detailed_"+spec[2])
		check(model.get_child_count()<=5,"Small static props merge their detail by material")
		var vertices:=0
		for instance in model.get_children():
			check(instance.mesh is ArrayMesh and instance.material_override!=null,"Baked prop retains geometry and material")
			vertices+=instance.mesh.surface_get_array_len(0)
		check(vertices>1000,"Quest item has authored curved geometry")
		if spec[0]=="blackwood":
			for action in [["DefeatBoss","boss.gravedigger"],["BreakSeal","seal.burial"],["VisitBlackwood",""],["MeetLyra",""],["ClearForestTrail",""]]:
				state=Rules.apply_action(state,action[0],action[1]).next_state
		var claim:=Rules.apply_action(state,"ClaimPickup",spec[3])
		check(claim.accepted,"Authored quest rules accept collecting the detailed item")
		state=claim.next_state; var snapshot:=JSON.stringify(state); region.apply_state(state)
		check(not owner_node.visible,"Existing pickup claim hides entire detailed model")
		check(owner_node.transform==transform,"Presentation never moves quest focus point")
		check(snapshot==JSON.stringify(state),"Visual refresh never mutates collected progress")
		region.queue_free(); await process_frame
	var parent:=Node3D.new(); root.add_child(parent)
	for kind in ["scout_satchel","family_locket","memorial","reliquary"]:
		var model:=Props.attach(parent,kind)
		check(model.get_child_count()>0,"Cached prop geometry can be reused: "+kind)
	parent.queue_free(); await process_frame
	for id in ["gravedigger","fallen_commander","iron_warden","maldrek","hollow_villager","bound_shade"]:
		var ordinary: bool=id in ["hollow_villager","bound_shade"]
		var actor=load("res://game/actors/enemies/training_soldier.gd" if ordinary else "res://game/actors/bosses/"+id+".gd").new()
		if ordinary: actor.profile=load("res://content/enemies/"+id+".tres")
		root.add_child(actor); actor.set_physics_process(false)
		var rig: Dictionary={}
		for node in actor.find_children("*","Node",true,false):
			if node.get_script()!=null and node.get_script().resource_path.ends_with("hostile_pose.gd"): rig=node.rig; node.set_process(false)
		check(rig.has("grip_material"),"Imported boss has isolated arm grip material: "+id)
		if rig.has("grip_material"):
			var pivot: Node3D=rig.weapon_visual.get_parent(); var before:=pivot.transform
			Grip.update(rig,true,false,1)
			var arm: Node3D=rig.grip_arm
			var gap: float=arm.to_global(rig.rest_wrist).distance_to(rig.weapon_visual.to_global(rig.grip_local))
			check(gap<0.025,"Rest weapon meets actual palm: "+id+" gap="+str(gap))
			Grip.update(rig,true,true,1)
			check(pivot.transform==before,"Attack authority pivot remains unchanged: "+id)
			check(rig.weapon_visual.position.is_zero_approx(),"Strike returns weapon appearance to original sweep")
			Grip.update(rig,false,false,1)
			check(not rig.grip_material.get_shader_parameter("grip_enabled"),"Death cinematic disables live arm deformation")
		actor.queue_free(); await process_frame
	print("Object art checks: %d assertions, %d failures" % [assertions,failures]); quit(1 if failures else 0)
