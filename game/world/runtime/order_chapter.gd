extends Node

const Enemy = preload("res://game/actors/enemies/training_soldier.gd")
var game: Node
var guards: Array[CharacterBody3D] = []

func setup(root: Node) -> void:
	game = root
	if game.session.state.campaign.completed:
		return
	for at in [Vector3(8, 0.1, -12), Vector3(-18, 0.1, -23), Vector3(10, 0.1, -35)]:
		var guard := Enemy.new()
		guard.player = game.player
		guard.profile = preload("res://content/enemies/fallen_soldier.tres")
		guard.home = at
		guard.use_navigation = true
		game.region.add_child(guard)
		guards.append(guard)
		game.enemies.append(guard)
		guard.defeated.connect(func(): game.enemy_defeated(guard); sentry_defeated())

func sentry_defeated() -> void:
	for guard in guards:
		if guard.health > 0:
			return
	game.session.act("ClearOrderCourtyard")
	game.sync_stats()

func read_record() -> void:
	if game.in_combat():
		game.session.notice = "Finish the encounter before reading"
		return
	if "document.order.expedition" not in game.session.state.campaign.pickup_claim_ids:
		if not game.session.act("ReadExpedition"):
			return
		game.sync_stats()
	game.open_dialogue("EXPEDITION RECORD\nThe Commander ordered us to hold the memorial hall. The wounded were still inside when the ward closed. Cael left to seek help; the report calls him a deserter.\n\nThe oath bound our mentor to this place. The record names the people he tried to save.\n\nReturn to Sir Cael. The recovered record stays in your journal.")
	game.button(game.choices, "Close record", game.leave_dialogue)

func talk() -> void:
	if game.in_combat():
		game.session.notice = "Finish the encounter before talking"
		return
	if "ally.cael" in game.session.state.campaign.recruited_ally_ids:
		game.journey.talk_recruited("ally.cael")
		return
	if "ally.cael.met" not in game.session.state.campaign.facts:
		game.session.act("MeetCael")
	game.open_dialogue("SIR CAEL\nI left this order to find help. No one returned with me. They call that desertion.\n\nThree sentries still patrol the courtyard and barracks. Clear them, then recover the expedition record from the memorial hall to the northwest. I need to know who was left behind.")
	game.button(game.choices, "Return record · ask Cael to join", func():
		if game.session.act("RecruitAlly", "ally.cael"):
			game.sync_stats()
			game.journey.refresh_selection()
			game.leave_dialogue()
		else:
			preload("res://game/localization/localizer.gd").set_text(game.dialogue_text, "SIR CAEL\n" + game.session.notice))
	game.button(game.choices, "Ask about the Commander", func():
		preload("res://game/localization/localizer.gd").set_text(game.dialogue_text, "SIR CAEL\nHis oath is ended. The record will help us remember the man he was." if "seal.oath" in game.session.state.campaign.broken_seal_ids else "SIR CAEL\nHe was your mentor too. His sanctum is north of the collapsed courtyard. Watch for his second crosscut. His lowered blade is your opening. After he falls, break the Oath Seal to open the mountain road."))
	game.button(game.choices, "Leave", game.leave_dialogue)
