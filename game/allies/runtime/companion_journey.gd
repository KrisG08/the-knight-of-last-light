extends Node

const Lyra = preload("res://game/allies/runtime/lyra_companion.gd")
const Enemy = preload("res://game/actors/enemies/training_soldier.gd")
var game: Node
var follower: CharacterBody3D
var guards: Array[CharacterBody3D] = []
var status: String = ""

func setup(root: Node) -> void:
	game = root

func region_ready() -> void:
	follower = null
	guards.clear()
	status = ""
	if game.region.region_id == "region.blackwood" and not game.session.state.campaign.completed:
		for at in [Vector3(-1, 0.1, -13), Vector3(9, 0.1, -16)]:
			var guard := Enemy.new()
			guard.player = game.player
			guard.profile = preload("res://content/enemies/grave_hound.tres")
			guard.home = at
			guard.use_navigation = true
			game.region.add_child(guard)
			guards.append(guard)
			game.enemies.append(guard)
			guard.defeated.connect(func(): game.enemy_defeated(guard); trail_defeated())
	refresh_selection()

func trail_defeated() -> void:
	for guard in guards:
		if guard.health > 0:
			return
	game.session.act("ClearForestTrail")
	game.sync_stats()

func refresh_selection() -> void:
	var selected = game.session.state.campaign.active_companion_id
	if is_instance_valid(follower) and follower.ally_id != selected:
		follower.get_parent().remove_child(follower)
		follower.queue_free()
		follower = null
	if selected not in ["ally.lyra", "ally.cael"]:
		if is_instance_valid(follower):
			follower.get_parent().remove_child(follower)
			follower.queue_free()
		follower = null
		status = ""
		return
	if game.region.region_id in ["region.crypt", "region.grove", "region.sanctum", "region.forge", "region.ritual"]:
		status = ("Sir Cael" if selected == "ally.cael" else "Lyra") + " waits outside the guardian arena and will rejoin on return."
		return
	if game.region.region_id not in ["region.refuge", "region.village", "region.blackwood", "region.order", "region.peaks", "region.citadel"]:
		return
	if is_instance_valid(follower):
		return
	follower = Lyra.new()
	follower.configure(selected)
	follower.setup(game, game.player.position + Vector3(1.8, 0.1, 1.5))
	game.region.add_child(follower)
	var spawn: Dictionary = follower.safe_point(false)
	if spawn.ok:
		follower.global_position = spawn.position
	else:
		follower.state = "suspended"
		follower.hide()
		follower.collision_layer = 0
		status = follower.display_name + " will regroup at the next lantern; no safe arrival point was found."

func recover_at_checkpoint() -> void:
	refresh_selection()
	if not is_instance_valid(follower):
		return
	var spawn: Dictionary = follower.safe_point(false)
	if spawn.ok:
		follower.global_position = spawn.position
		follower.recover()
		status = ""

func toggle_order() -> bool:
	if not is_instance_valid(follower):
		game.session.notice = status if status != "" else "Recruit and select a companion before giving orders"
		return false
	var command: String = "hold" if follower.order == "follow" else "follow"
	if not follower.set_order(command):
		game.session.notice = follower.display_name + " needs safe recovery at a lantern"
		return false
	game.session.notice = follower.display_name + ": " + command
	return true

func select(active: bool) -> bool:
	return choose("ally.lyra" if active else "")

func choose(id: String) -> bool:
	if game.in_combat() or game.player.health <= 0:
		game.session.notice = "Change companions outside combat"
		return false
	if not game.session.act("SetActiveCompanion", id):
		return false
	game.sync_stats()
	refresh_selection()
	return true

func talk() -> void:
	if game.in_combat():
		game.session.notice = "Finish the encounter before talking"
		return
	var recruited: bool = "ally.lyra" in game.session.state.campaign.recruited_ally_ids
	if recruited:
		talk_recruited("ally.lyra")
		return
	else:
		if "ally.lyra.met" not in game.session.state.campaign.facts:
			game.session.act("MeetLyra")
		game.open_dialogue("LYRA · Scout\nI thought the ward would never lift. The hounds drove me from the watchtower. My bandages and maps are in a satchel by the fallen wall.\n\nClear the two trail hounds, recover the satchel and I will travel with you.")
		game.button(game.choices, "Return satchel · ask Lyra to join", func():
			if game.session.act("RecruitAlly", "ally.lyra"):
				game.sync_stats()
				refresh_selection()
				game.leave_dialogue()
			else:
				preload("res://game/localization/localizer.gd").set_text(game.dialogue_text, "LYRA\n" + game.session.notice))
		game.button(game.choices, "Ask where to look", func(): preload("res://game/localization/localizer.gd").set_text(game.dialogue_text, "LYRA\nThe satchel lies southeast of here, behind the fallen wall by the watchtower post. Stay on the open ground and watch the hounds' windups."))
	game.button(game.choices, "Leave", game.leave_dialogue)

func if_follow_order() -> void:
	if is_instance_valid(follower):
		follower.set_order("follow")

func hud_status() -> String:
	if is_instance_valid(follower):
		return "%s %d / %d · %s · [%s] follow / hold" % [follower.display_name, follower.health, follower.max_health, follower.state, game.settings.hint("companion_order")]
	return status

func talk_recruited(id: String) -> void:
	if game.in_combat():
		game.session.notice = "Finish the encounter before talking"
		return
	var speaker := "SIR CAEL" if id == "ally.cael" else "LYRA"
	var memory := ""
	if id == "ally.cael" and "seal.oath" in game.session.state.campaign.broken_seal_ids:
		memory = "His oath is ended. I will carry the names from the memorial, not the shame that kept me here.\n\n"
	game.open_dialogue(speaker + "\n" + memory + "We travel together, or I wait at the refuge. Only one companion can follow. Rest at a lantern to recover a downed companion.")
	game.button(game.choices, "Follow me", func(): choose(id); if_follow_order(); game.leave_dialogue())
	game.button(game.choices, "Hold this position", func():
		if choose(id) and is_instance_valid(follower):
			follower.set_order("hold")
		game.leave_dialogue())
	game.button(game.choices, "Wait at the refuge", func():
		if game.session.state.campaign.active_companion_id == id:
			choose("")
		game.leave_dialogue())
	game.button(game.choices, "Leave", game.leave_dialogue)
