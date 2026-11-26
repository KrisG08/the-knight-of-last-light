extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	var scene := load("res://game/world/runtime/village_game.tscn") as PackedScene
	var game = scene.instantiate()
	game.testing = true
	tree.root.add_child(game)
	await tree.process_frame
	while game.transitioning:
		await tree.physics_frame
	check.call(game.region.region_id == "region.refuge" and game.enemies.is_empty(), "Refuge loads with no hostiles")
	await game.start_selected()
	check.call(game.session.active and game.region.region_id == "region.refuge", "New campaign starts through actual menu controller")
	var original = game.region
	check.call(not await game.transition("region.missing") and game.region == original, "Missing region transition preserves current area")
	check.call(not game.session.act("RescueOren"), "Oren cannot be recruited before mill guard defeat")
	await game.transition("region.village")
	game.player.enabled = false
	for actor in game.enemies:
		actor.set_physics_process(false)
	check.call(game.region.region_id == "region.village" and game.enemies.size() == 5, "Village builds five authored encounters")
	check.call(game.region.navigation.navigation_mesh.get_polygon_count() > 0, "Village has walkable navigation polygons")
	await tree.physics_frame
	var nav_map: RID = game.region.navigation.get_navigation_map()
	var path := NavigationServer3D.map_get_path(nav_map, Vector3(20, 0, 24), Vector3(26, 0, -3), true)
	check.call(path.size() >= 2, "Navigation path connects street and mill around buildings")
	var connected := true
	for key in ["checkpoint","oren","token","crypt","forest","travel"]:
		var destination: Vector3 = game.region.points[key]
		if key == "oren": destination += Vector3(0, 0, 2.5) # Approach the outside of the locked cell.
		var route := NavigationServer3D.map_get_path(nav_map,game.region.points.spawn,destination,true)
		connected = connected and route.size()>=2 and route[-1].distance_to(destination)<2.1
	check.call(connected,"Detailed village houses and well preserve connected routes to every story interaction")
	var terrain: ShaderMaterial = game.region.village_ground.get_child(0).material_override
	var cursed_tint: Color = terrain.get_shader_parameter("curse_tint")
	var freed: Dictionary = game.session.state.duplicate(true)
	freed.campaign.broken_seal_ids.append("seal.burial")
	game.region.apply_state(freed)
	check.call(terrain.get_shader_parameter("curse_tint")!=cursed_tint,"Blended village terrain still changes appearance after the burial seal breaks")
	game.region.apply_state(game.session.state)
	var outside := true
	for vertex: Vector3 in game.region.get_node("VillageHorizon/WoodlandRidges").mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]:
		outside = outside and (absf(vertex.x)>40 or absf(vertex.z)>45)
	check.call(outside,"Village backdrop stays outside all playable streets and yards")
	var mausoleum_roof := PhysicsRayQueryParameters3D.create(Vector3(4,16,-39),Vector3(4,7.5,-39),1)
	check.call(not game.get_world_3d().direct_space_state.intersect_ray(mausoleum_roof).is_empty(),"New mausoleum roof has collision above the original crypt shell")
	var stall_canopy := PhysicsRayQueryParameters3D.create(Vector3(29,4,16),Vector3(29,2.5,16),1)
	check.call(not game.get_world_3d().direct_space_state.intersect_ray(stall_canopy).is_empty(),"Village market canopy blocks the camera above its counter")
	var storage := PhysicsRayQueryParameters3D.create(game.region.surface_point(Vector3(34.4,0.7,-11)),game.region.surface_point(Vector3(34.4,0.7,-7)),1)
	check.call(not game.get_world_3d().direct_space_state.intersect_ray(storage).is_empty(),"Village storage props have physical blockers")
	var awning := PhysicsRayQueryParameters3D.create(Vector3(-4.2,4,19),Vector3(-4.2,2.7,19),1)
	check.call(not game.get_world_3d().direct_space_state.intersect_ray(awning).is_empty(),"Projecting village door canopy has real collision for the camera")
	var rectangular := true
	for house in game.region.find_children("TimberHouse","Node3D",true,false):
		for batch in house.get_children():
			if batch is MultiMeshInstance3D:
				for index in range(batch.multimesh.instance_count):
					var basis: Basis = batch.multimesh.get_instance_transform(index).basis
					rectangular = rectangular and absf(basis.x.normalized().dot(basis.y.normalized()))<0.001 and absf(basis.y.normalized().dot(basis.z.normalized()))<0.001
	check.call(rectangular,"Rotated timber braces retain perpendicular box axes instead of shearing into roof spikes")
	var detour := NavigationServer3D.map_get_path(nav_map, Vector3(0, 0, 28), Vector3(0, 0, 8), true)
	var detour_length: float = 0
	for index in range(1, detour.size()):
		detour_length += detour[index - 1].distance_to(detour[index])
	check.call(detour_length > 24, "Navigation routes around the barred central street")
	var profiles: Dictionary = {}
	for actor in game.enemies:
		profiles[actor.display_name] = true
	check.call(profiles.size() == 3, "Three authored enemy profiles instantiate")
	game.player.position = game.region.surface_point(Vector3(20, 0.1, 18))
	var pursuer = game.enemies[0]
	var before: Vector3 = pursuer.position
	pursuer.set_physics_process(true)
	for tick in range(30):
		await tree.physics_frame
	pursuer.set_physics_process(false)
	check.call(pursuer.position.z < before.z - 0.3, "NavigationAgent output actually moves the pursuing actor")
	pursuer.reset_encounter()
	game.player.position = game.region.points.checkpoint + Vector3(-2, 0.1, 0)
	check.call(game.rest() and game.session.state.recovery.region_id == "region.village", "Village lantern changes durable respawn checkpoint")
	game.player.enabled = false
	game.mill_guard.receive_hit(game.player.position, 1000, 1, 0)
	check.call(game.mill_guard.profile.maximum_health == 110 and game.enemies[4].health == 110, "Shared enemy definitions do not share mutable health")
	check.call("mill.guards_cleared" in game.session.state.campaign.facts, "Mill encounter defeat commits prerequisite")
	game.player.position = game.region.points.oren + Vector3(0, 0.1, 2)
	await tree.physics_frame
	check.call(game.focus() == "oren", "Visible nearby Oren is interaction focus")
	game.interact()
	check.call(game.dialogue.visible and tree.paused, "Oren dialogue opens and pauses combat")
	var free_button = game.choices.get_child(0)
	free_button.pressed.emit()
	check.call("ally.oren" in game.session.state.campaign.recruited_ally_ids and not game.region.oren.visible, "Free choice recruits Oren and removes captive representation")
	check.call(not game.session.act("RescueOren"), "Oren rescue reward is exactly once")
	game.player.position = game.region.points.shortcut
	game.interact()
	check.call(game.region.shortcut.collision_layer == 0, "Shortcut opens from north village side")
	game.player.position = game.region.points.token + Vector3(0, 0.1, 1)
	game.interact()
	check.call(not game.region.token.visible and "pickup.family_token" in game.session.state.campaign.pickup_claim_ids, "Optional token pickup persists and hides prop")
	check.call(Schema.validate(game.session.state) == "", "Rescue/shortcut/token snapshot validates")
	await game.transition("region.refuge")
	game.player.enabled = false
	check.call(game.enemies.is_empty() and game.region.oren.visible, "Rescued Oren appears once at hostile-free refuge")
	game.player.position = game.region.points.memorial + Vector3(0, 0.1, 2)
	game.interact()
	check.call(game.session.state.campaign.quest_states.get("quest.family_token") == "completed", "Memorial returns family token and completes optional quest")
	var shards: int = game.session.state.character.shards
	game.interact()
	check.call(game.session.state.character.shards == shards, "Repeated memorial interaction cannot duplicate reward")
	game.player.position = game.region.points.oren + Vector3(0, 0.1, 2)
	game.interact()
	check.call(game.dialogue.visible, "Resident Oren exposes forge dialogue")
	game.choices.get_child(0).pressed.emit()
	check.call(game.player.weapon_damage == 26, "Resident blacksmith upgrade changes real sword damage")
	game.leave_dialogue()
	check.call(game.session.load_slot(1), "Campaign state round-trips through dedicated slot adapter")
	await game.transition(game.session.state.recovery.region_id)
	game.player.enabled = false
	for actor in game.enemies:
		actor.set_physics_process(false)
	check.call(game.region.region_id == "region.village" and not game.region.oren.visible and game.region.shortcut.collision_layer == 0, "Reload restores checkpoint, rescued NPC absence and shortcut")
	check.call(game.player.weapon_damage == 26 and game.enemies.size() == 5, "Reload preserves upgrades and respawns ordinary enemies")
	game.player.health = 0
	await game.respawn()
	check.call(game.region.region_id == "region.village" and game.player.health == game.player.max_health, "Death returns to activated village checkpoint with full HP")
	check.call(Schema.validate(game.session.state) == "", "Completed M4 route remains save-valid")
	for actor in game.enemies:
		actor.sounds.stop()
	game.ui_sound.stop()
	game.player.sounds.stop()
	game.pause(true)
	await tree.create_timer(0.2, true).timeout
	game.queue_free()
	await tree.process_frame
