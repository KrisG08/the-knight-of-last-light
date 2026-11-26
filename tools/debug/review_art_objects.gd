extends SceneTree
## Renderer review of actual actor constructors and all authored region meshes.
const Art=preload("res://game/presentation/art_kit.gd")
var report: Dictionary={}
var output: String
func _initialize() -> void:
	create_timer(240,true).timeout.connect(func(): push_error("Art review timeout"); quit(1))
	call_deferred("run")
func photo(tag: String) -> void:
	for frame in range(8): await process_frame
	RenderingServer.force_draw(false)
	root.get_texture().get_image().save_png(output+"/"+tag+".png")
func run() -> void:
	var args:=OS.get_cmdline_user_args()
	output=args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review/object-audit-before")
	DirAccess.make_dir_recursive_absolute(output)
	root.size=Vector2i(1200,1000)
	var game=load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing=true; root.add_child(game)
	while game.transitioning: await process_frame
	game.benchmarking=true; game.region.hide(); game.ui_layer.hide(); game.player.hide(); game.player.enabled=false; game.pause(false)
	game.menu.hide()
	var stage:=Node3D.new(); game.add_child(stage)
	Art.box(stage,Vector3(0,-0.1,0),Vector3(20,0.2,20),Art.stone())
	var fill:=DirectionalLight3D.new(); fill.rotation_degrees=Vector3(-30,25,0); fill.light_energy=0.65; stage.add_child(fill)
	var camera:=Camera3D.new(); stage.add_child(camera); camera.current=true; camera.fov=42
	var knight:=Node3D.new(); stage.add_child(knight)
	var sword:=Node3D.new(); knight.add_child(sword)
	load("res://game/presentation/meshy_models.gd").knight(knight,sword)
	camera.position=Vector3(2,1.3,-4); camera.look_at(Vector3(0,0.9,0)); await photo("hero-knight")
	knight.queue_free(); await process_frame
	var entries:={"villager":"hollow_villager","soldier":"fallen_soldier","hound":"grave_hound","shade":"bound_shade","gravedigger":"gravedigger","thorn":"thorn_beast","commander":"fallen_commander","warden":"iron_warden","maldrek":"maldrek"}
	for id in entries:
		var actor: CharacterBody3D
		if id in ["villager","soldier","hound","shade"]:
			actor=load("res://game/actors/enemies/training_soldier.gd").new()
			actor.profile=load("res://content/enemies/"+entries[id]+".tres"); actor.home=Vector3.ZERO
		else: actor=load("res://game/actors/bosses/"+entries[id]+".gd").new()
		actor.player=game.player; stage.add_child(actor); actor.set_physics_process(false)
		actor.position=Vector3.ZERO
		actor.label.hide()
		for label in actor.find_children("*","Label3D",true,false): label.hide()
		var height: float=3.0 if id in ["warden","maldrek","commander","gravedigger"] else 2.0
		camera.position=Vector3(2.5,height*0.65,-5.4); camera.look_at(Vector3(0,height*0.46,0))
		await photo("hostile-"+id)
		actor.queue_free(); await process_frame
	for id in ["oren","lyra","cael","survivor"]:
		var model:=Node3D.new(); stage.add_child(model)
		var weapon:=Node3D.new(); model.add_child(weapon)
		load("res://game/presentation/friendly_models.gd").build(model,id,weapon)
		camera.position=Vector3(2,1.3,-4); camera.look_at(Vector3(0,0.9,0))
		await photo("friendly-"+id)
		model.queue_free(); await process_frame
	for id in ["goblin","dwarf","troll","wraith","sentinel","gargoyle","barghest","ash_dragon"]:
		var creature=load("res://game/presentation/ambient_creature.gd").new(); creature.setup(id,1.0); stage.add_child(creature)
		creature.set_process(false)
		var height: float=3.5 if id in ["troll","ash_dragon"] else 2.0
		camera.position=Vector3(height*1.1,height*0.65,-height*2.4); camera.look_at(Vector3(0,height*0.45,0))
		await photo("ambient-"+id)
		creature.queue_free(); await process_frame
	if args.size()>1 and args[1]=="actors":
		print("Art review: hero, nine hostile, four friendly and eight passive final models captured")
		game.queue_free(); await process_frame; quit(); return
	stage.hide()
	for id in ["refuge","village","crypt","blackwood","grove","order","sanctum","peaks","forge","citadel","ritual"]:
		var region=load("res://game/world/regions/graybox_region.gd").new()
		region.build("region."+id); stage.add_child(region); stage.show()
		region.apply_state(load("res://game/campaign/domain/campaign_rules.gd").new_game(1))
		var flat: Array=[]; var meshes:=0
		for visual in region.find_children("*","MeshInstance3D",true,false):
			if not visual.is_visible_in_tree(): continue
			meshes+=1
			if visual.mesh is BoxMesh and visual.material_override is StandardMaterial3D and visual.material_override.albedo_texture==null:
				flat.append({"path":str(region.get_path_to(visual)),"position":str(visual.global_position),"size":str(visual.mesh.size)})
		var batches:=0; var instances:=0
		for visual in region.find_children("*","MultiMeshInstance3D",true,false):
			if visual.is_visible_in_tree() and visual.multimesh!=null:
				batches+=1; instances+=visual.multimesh.instance_count
		report[id]={"visible_mesh_nodes":meshes,"multimesh_batches":batches,"batched_instances":instances,"untextured_box_candidates":flat}
		camera.position=Vector3(26,24,-30); camera.look_at(Vector3(0,4,0)); await photo("region-"+id)
		for key in ["satchel","token"]:
			var item=region.get(key)
			if not is_instance_valid(item): continue
			var center: Vector3=item.global_position
			camera.position=center+Vector3(0.95,0.60,-1.4); camera.look_at(center)
			await photo(id+"-"+key)
		for key in ["memorial","seal"]:
			var item=region.interact_colliders.get(key) if key=="memorial" else region.seal
			if not is_instance_valid(item): continue
			camera.position=item.global_position+Vector3(2,1,-3); camera.look_at(item.global_position)
			await photo(id+"-"+key)
		region.queue_free(); await process_frame
	var file:=FileAccess.open(output+"/inventory.json",FileAccess.WRITE); file.store_string(JSON.stringify(report,"\t")); file.close()
	print("Art review: hero, nine hostile/four friendly/eight passive constructors, all eleven region inventories and quest pickups captured")
	game.queue_free(); await process_frame; quit()
