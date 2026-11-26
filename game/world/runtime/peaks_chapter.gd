extends Node

const Warden = preload("res://game/actors/bosses/iron_warden.gd")
const Enemy = preload("res://game/actors/enemies/training_soldier.gd")
var game: Node
var actor: CharacterBody3D

func setup(root: Node) -> void:
	game = root
	if game.region.region_id == "region.forge":
		actor = Warden.new()
		actor.player = game.player
		game.region.add_child(actor)
		actor.encounter_started.connect(update_barrier)
		actor.defeated.connect(on_defeated)
		if "boss.iron_warden" in game.session.state.campaign.boss_defeated_ids:
			actor.restore_defeated()
		update_barrier()
	else:
		if game.session.state.campaign.completed:
			return
		for placement in [["grave_hound", Vector3(-18, 0.1, -19)], ["fallen_soldier", Vector3(-5, 0.1, -46)], ["fallen_soldier", Vector3(2, 0.1, -59)]]:
			var enemy := Enemy.new()
			enemy.player = game.player
			enemy.profile = load("res://content/enemies/" + placement[0] + ".tres")
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
	game.session.act("DefeatBoss", "boss.iron_warden")
	game.sync_stats()
	update_barrier()

func break_seal() -> bool:
	var result: bool = game.session.act("BreakSeal", "seal.forge")
	game.sync_stats()
	return result
