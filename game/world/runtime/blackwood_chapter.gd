extends Node

const Beast = preload("res://game/actors/bosses/thorn_beast.gd")
const Enemy = preload("res://game/actors/enemies/training_soldier.gd")
var game: Node
var actor: CharacterBody3D

func setup(root: Node) -> void:
	game = root
	if game.region.region_id == "region.grove":
		actor = Beast.new()
		actor.player = game.player
		game.region.add_child(actor)
		actor.encounter_started.connect(update_barrier)
		actor.defeated.connect(on_defeated)
		if "boss.thorn_beast" in game.session.state.campaign.boss_defeated_ids:
			actor.restore_defeated()
		update_barrier()
	elif game.region.region_id == "region.blackwood":
		if game.session.state.campaign.completed:
			return
		for placement in [["hollow_villager", Vector3(21, 0.1, -28)], ["grave_hound", Vector3(19, 0.1, -47)], ["fallen_soldier", Vector3(-13, 0.1, -49)]]:
			var enemy := Enemy.new()
			enemy.profile = load("res://content/enemies/" + placement[0] + ".tres")
			enemy.player = game.player
			enemy.home = placement[1]
			enemy.use_navigation = true
			game.region.add_child(enemy)
			game.enemies.append(enemy)
			enemy.defeated.connect(func(): game.enemy_defeated(enemy))

func active() -> bool:
	return is_instance_valid(actor) and actor.health > 0 and actor.state != "dormant"

func update_barrier() -> void:
	game.region.entrance_barrier.visible = active()
	game.region.entrance_barrier.collision_layer = 1 if active() else 0

func on_defeated() -> void:
	game.session.act("DefeatBoss", "boss.thorn_beast")
	game.sync_stats()
	update_barrier()

func break_seal() -> bool:
	var result: bool = game.session.act("BreakSeal", "seal.root")
	game.sync_stats()
	return result
