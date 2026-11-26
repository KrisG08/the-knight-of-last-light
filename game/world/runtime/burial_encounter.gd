extends Node

const Boss = preload("res://game/actors/bosses/gravedigger.gd")
var game: Node
var actor: CharacterBody3D

func setup(root: Node) -> void:
	game = root
	actor = Boss.new()
	actor.player = game.player
	game.region.add_child(actor)
	actor.encounter_started.connect(update_barrier)
	actor.defeated.connect(on_defeated)
	if "boss.gravedigger" in game.session.state.campaign.boss_defeated_ids:
		actor.restore_defeated()
	update_barrier()

func active() -> bool:
	return is_instance_valid(actor) and actor.health > 0 and actor.state != "dormant"

func update_barrier() -> void:
	game.region.entrance_barrier.visible = active()
	game.region.entrance_barrier.collision_layer = 1 if active() else 0

func on_defeated() -> void:
	game.session.act("DefeatBoss", "boss.gravedigger")
	game.sync_stats()
	update_barrier()

func break_seal() -> bool:
	var accepted: bool = game.session.act("BreakSeal", "seal.burial")
	game.sync_stats()
	return accepted
