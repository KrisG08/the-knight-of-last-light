extends Node

const Wizard = preload("res://game/actors/bosses/maldrek.gd")
const Enemy = preload("res://game/actors/enemies/training_soldier.gd")
var game: Node
var actor: CharacterBody3D
var summons: Array[CharacterBody3D] = []

func setup(root: Node) -> void:
	game = root
	if game.region.region_id == "region.ritual":
		actor = Wizard.new()
		actor.player = game.player
		game.region.add_child(actor)
		actor.encounter_started.connect(update_barrier)
		actor.summons_requested.connect(summon)
		actor.defeated.connect(on_defeated)
		if "boss.maldrek" in game.session.state.campaign.boss_defeated_ids:
			actor.restore_defeated()
		update_barrier()
	elif not game.session.state.campaign.completed:
		for at in [Vector3(7,0.1,-14),Vector3(-19,0.1,-25),Vector3(0,0.1,-43)]:
			var enemy := create_enemy(at,preload("res://content/enemies/fallen_soldier.tres"))
			enemy.defeated.connect(func():
				game.enemy_defeated(enemy)
				if at.x == -19:
					game.session.act("ClearPrison"))

func create_enemy(at: Vector3, profile: Resource) -> CharacterBody3D:
	var enemy := Enemy.new()
	enemy.player = game.player
	enemy.profile = profile
	enemy.home = at
	enemy.use_navigation = true
	game.region.add_child(enemy)
	game.enemies.append(enemy)
	return enemy

func summon() -> void:
	if actor.health <= 0:
		return
	for at in [Vector3(-6,0.1,-2),Vector3(6,0.1,-2)]:
		var living := 0
		for shade in summons:
			if is_instance_valid(shade) and shade.health > 0:
				living += 1
		if living >= 2:
			break
		var shade := create_enemy(at,preload("res://content/enemies/bound_shade.tres"))
		summons.append(shade)
		shade.defeated.connect(func(): game.summoned_enemy_defeated(shade))

func active() -> bool:
	return is_instance_valid(actor) and actor.health > 0 and actor.state != "dormant"

func update_barrier() -> void:
	game.region.entrance_barrier.visible = active()
	game.region.entrance_barrier.collision_layer = 1 if active() else 0

func on_defeated() -> void:
	for shade in summons:
		if is_instance_valid(shade):
			shade.health = 0
			shade.state = "dead"
			shade.collision_layer = 0
			shade.set_physics_process(false)
			shade.hide()
	game.session.act("DefeatBoss","boss.maldrek")
	game.sync_stats()
	update_barrier()
	game.play_wizard_defeat(actor)

func artifact() -> void:
	if is_instance_valid(game.opening): return
	if "boss.maldrek" not in game.session.state.campaign.boss_defeated_ids:
		game.session.notice = "Defeat Maldrek before breaking the central artifact"
		return
	game.open_dialogue("CENTRAL ARTIFACT\nThe wizard has fallen, but the curse still clings to this anchor. All four seals are broken. Shatter the artifact and end the curse?\n\nYour journey will be saved at the restored refuge. You can continue exploring afterward.")
	game.button(game.choices,"Break the artifact · end the curse",finish_ritual)
	game.button(game.choices,"Not yet",game.leave_dialogue)

func finish_ritual() -> void:
	if not game.session.state.campaign.completed:
		if not game.session.act("CompleteCampaign"):
			return
	if game.session.dirty and not game.session.save_progress():
		game.open_dialogue("The ritual could not be saved. Your session is preserved. Retry saving to finish.")
		game.button(game.choices,"Retry saving ritual",finish_ritual)
		return
	# The chapter node is freed during travel; finish on the persistent controller.
	game.finish_ending()

func read_lore() -> void:
	if game.in_combat():
		game.session.notice = "Finish the encounter before reading"
		return
	game.session.act("LearnRitual")
	game.open_dialogue("RITUAL INSCRIPTION\nFour seals feed one anchor. Defeat the wizard, then shatter the central artifact by your own hand. His death alone will not cleanse the kingdom.")
	game.button(game.choices,"Leave inscription",game.leave_dialogue)
