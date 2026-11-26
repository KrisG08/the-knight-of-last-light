extends RefCounted
const Region = preload("res://game/world/regions/graybox_region.gd")
const Rules = preload("res://game/campaign/domain/campaign_rules.gd")

static func run(tree: SceneTree, check: Callable) -> void:
	tree.paused = false
	var before := Rules.new_game()
	var victory := before.duplicate(true)
	victory.campaign.boss_defeated_ids.append("boss.gravedigger")
	var cleansed := victory.duplicate(true)
	cleansed.campaign.broken_seal_ids.append("seal.burial")
	cleansed.campaign.recruited_ally_ids.append("ally.oren")
	for id in ["region.refuge","region.village","region.crypt"]:
		var region := Region.new()
		tree.root.add_child(region)
		region.build(id)
		region.apply_state(before)
		var story := region.get_node("OpeningWorldStory")
		check.call(story.omen.visible and not story.renewed.visible and not story.forge.visible,"Opening world starts cursed and Oren's forge remains unlit: "+id)
		region.apply_state(victory)
		check.call(story.omen.visible and not story.renewed.visible,"Boss victory alone does not cleanse the opening world: "+id)
		region.apply_state(cleansed)
		check.call(not story.omen.visible and story.renewed.visible,"Burial seal fact restores the opening-world presentation: "+id)
		if id=="region.refuge":
			check.call(story.forge.visible,"Rescuing Oren lights his refuge work area")
		if id=="region.crypt":
			var released := true
			for actor in region.get_node("MythicFauna").get_children():
				if actor.get_script()==preload("res://game/presentation/ambient_creature.gd") and actor.species=="wraith": released = released and not actor.visible and not actor.is_processing()
			check.call(released,"Burial spirits are released after breaking their seal")
		else:
			var worker: Node3D
			for actor in region.get_node("MythicFauna").get_children():
				if actor.get_script()==preload("res://game/presentation/ambient_creature.gd") and actor.activity=="repair": worker = actor; break
			var at := worker.position
			var arm_before: float = worker.body.get_node("Arm1").rotation.x
			worker._process(0.5)
			check.call(worker.position==at and worker.body.get_node("Arm1").rotation.x!=arm_before and worker.find_children("*","CollisionObject3D",true,false).is_empty(),"Workers animate at their station without interaction/collision: "+id)
			var clock_before: float = worker.clock
			tree.paused = true
			await tree.process_frame
			check.call(worker.clock==clock_before,"Work animation stops with game pause: "+id)
			tree.paused = false
		region.queue_free()
		await tree.process_frame
