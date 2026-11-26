extends RefCounted

const BOSSES = {"boss.gravedigger": "seal.burial", "boss.thorn_beast": "seal.root", "boss.fallen_commander": "seal.oath", "boss.iron_warden": "seal.forge", "boss.maldrek": ""}
const GATES = {"gate.village_to_blackwood": ["seal.burial"], "gate.blackwood_to_order": ["seal.root"], "gate.order_to_peaks": ["seal.oath"], "gate.peaks_to_citadel": ["seal.burial", "seal.root", "seal.oath", "seal.forge"], "gate.training": ["seal.training"]}
const BOSS_REWARDS = {"boss.gravedigger": [180, 80], "boss.thorn_beast": [240, 110], "boss.fallen_commander": [300, 140], "boss.iron_warden": [360, 160], "boss.maldrek": [500, 250]}

static func new_game(slot: int = 1) -> Dictionary:
	return {
		"schema_version": 1, "content_version": "prototype", "slot_id": slot, "saved_at": "",
		"character": {"rank": 1, "xp_into_rank": 0, "shards": 0, "weapon_id": "weapon.knight_sword", "weapon_tier": 0, "owned_item_ids": ["weapon.knight_sword", "shield.worn_shield"], "equipped_relic_ids": []},
		"campaign": {"facts": [], "boss_defeated_ids": [], "broken_seal_ids": [], "recruited_ally_ids": [], "active_companion_id": null, "reward_claim_ids": [], "pickup_claim_ids": [], "checkpoint_ids": ["checkpoint.refuge"], "quest_states": {"quest.main.ch01": "active"}, "completed": false},
		"recovery": {"region_id": "region.refuge", "checkpoint_id": "checkpoint.refuge", "spawn_id": "spawn.refuge.safe"},
	}

static func max_health(state: Dictionary) -> float:
	return 100.0 + 5.0 * (state.character.rank - 1)

static func lantern_destination(state: Dictionary, checkpoint: String) -> Dictionary:
	var names := {"refuge":"Lantern Refuge", "village":"Ashen Village", "blackwood":"Blackwood", "order":"Order's Ruins", "peaks":"Ashen Peaks", "citadel":"Eclipse Citadel"}
	var suffix := checkpoint.trim_prefix("checkpoint.")
	if not names.has(suffix) or checkpoint != "checkpoint." + suffix or checkpoint not in state.campaign.checkpoint_ids:
		return {"allowed":false,"reason":"Activate that lantern before travelling to it"}
	var gates := {"blackwood":"gate.village_to_blackwood", "order":"gate.blackwood_to_order", "peaks":"gate.order_to_peaks", "citadel":"gate.peaks_to_citadel"}
	if gates.has(suffix) and not gate_access(gates[suffix],state).allowed:
		return {"allowed":false,"reason":"The route is still warded"}
	return {"allowed":true,"region":"region."+suffix,"name":names[suffix]}

static func new_training(slot: int = 1) -> Dictionary:
	var state := new_game(slot)
	state.campaign.checkpoint_ids = ["checkpoint.training"]
	state.recovery = {"region_id": "region.training", "checkpoint_id": "checkpoint.training", "spawn_id": "spawn.training.safe"}
	return state

static func sword_damage(state: Dictionary) -> float:
	return [22.0, 26.0, 31.0][state.character.weapon_tier] + preload("res://game/campaign/domain/relics.gd").bonus(state.character,"damage")

static func grant_xp(character: Dictionary, amount: int) -> void:
	character.xp_into_rank += amount
	while character.rank < 100 and character.xp_into_rank >= 100 + 50 * (character.rank - 1):
		character.xp_into_rank -= 100 + 50 * (character.rank - 1)
		character.rank += 1
	if character.rank == 100:
		character.xp_into_rank = mini(character.xp_into_rank, 5049)

static func gate_access(id: String, state: Dictionary) -> Dictionary:
	if not GATES.has(id):
		return {"allowed": false, "reason": "Unknown passage"}
	for seal in GATES[id]:
		if not state.campaign.broken_seal_ids.has(seal):
			return {"allowed": false, "reason": "Break " + seal.trim_prefix("seal.") + " seal first"}
	return {"allowed": true, "reason": "Passage open"}

static func apply_action(state: Dictionary, action: String, id: String = "") -> Dictionary:
	var next := state.duplicate(true)
	var world: Dictionary = next.campaign
	var character: Dictionary = next.character
	var reason := "Progress updated"
	if action in ["MeetLyra", "ClearForestTrail", "SetActiveCompanion"] or (action == "ClaimPickup" and id == "pickup.lyra_satchel") or (action == "RecruitAlly" and id == "ally.lyra"):
		next.schema_version = maxi(2, int(next.schema_version))
	if action in ["OpenForestShortcut", "VisitOrder"] or (action == "ActivateCheckpoint" and id == "checkpoint.blackwood") or (action == "DefeatBoss" and id == "boss.thorn_beast") or (action == "BreakSeal" and id == "seal.root"):
		next.schema_version = maxi(3, int(next.schema_version))
	if action in ["MeetCael", "ClearOrderCourtyard", "ReadExpedition"] or (action == "RecruitAlly" and id == "ally.cael") or (action == "ActivateCheckpoint" and id == "checkpoint.order"):
		next.schema_version = maxi(4, int(next.schema_version))
	if action == "VisitPeaks" or (action == "DefeatBoss" and id == "boss.fallen_commander") or (action == "BreakSeal" and id == "seal.oath"):
		next.schema_version = maxi(5, int(next.schema_version))
	if action in ["OpenPeaksShortcut", "VisitCitadel"] or (action == "ActivateCheckpoint" and id == "checkpoint.peaks") or (action == "DefeatBoss" and id == "boss.iron_warden") or (action == "BreakSeal" and id == "seal.forge"):
		next.schema_version = maxi(6, int(next.schema_version))
	if action in ["LearnRitual", "ClearPrison", "FreePrisoners", "CompleteCampaign"] or (action == "DefeatBoss" and id == "boss.maldrek") or (action == "ActivateCheckpoint" and id == "checkpoint.citadel"):
		next.schema_version = maxi(7, int(next.schema_version))
	match action:
		"EquipRelic", "RemoveRelic":
			var relics = preload("res://game/campaign/domain/relics.gd")
			if not relics.ITEMS.has(id): return rejected(state,"Unknown relic")
			if action == "RemoveRelic":
				if id not in character.equipped_relic_ids: return rejected(state,"Relic is not equipped")
				character.equipped_relic_ids.erase(id)
			else:
				if id not in relics.available(state): return rejected(state,"Relic is not earned yet")
				if id in character.equipped_relic_ids or character.equipped_relic_ids.size() >= 2: return rejected(state,"Remove a relic before equipping another")
				character.equipped_relic_ids.append(id)
		"LearnRitual", "ClearPrison", "FreePrisoners":
			if "region.citadel.visited" not in world.facts:
				return rejected(state,"Discover the citadel first")
			var fact: String = {"LearnRitual":"citadel.ritual_known", "ClearPrison":"citadel.prison_safe", "FreePrisoners":"citadel.prisoners_freed"}[action]
			if fact in world.facts:
				return rejected(state,"Already completed")
			if action == "FreePrisoners" and "citadel.prison_safe" not in world.facts:
				return rejected(state,"Defeat the jailer first")
			world.facts.append(fact)
			if action == "FreePrisoners":
				world.reward_claim_ids.append("reward.quest.prisoners")
				world.quest_states["quest.prisoners"] = "completed"
				grant_xp(character,30)
				character.shards += 20
				reason = "Two prisoners freed · +30 XP · +20 shards"
		"OpenPeaksShortcut":
			if "region.peaks.visited" not in world.facts or "gate.peaks.shortcut.open" in world.facts:
				return rejected(state, "Service path is unknown or already open")
			world.facts.append("gate.peaks.shortcut.open")
			reason = "Service path opened · return to the bridge"
		"VisitCitadel":
			if not gate_access("gate.peaks_to_citadel", state).allowed or "region.citadel.visited" in world.facts:
				return rejected(state, "Break all four regional seals before entering the citadel")
			world.facts.append("region.citadel.visited")
			world.quest_states["quest.main.ch04"] = "completed"
			reason = "Chapter IV complete · Eclipse Citadel discovered"
		"VisitPeaks":
			if not gate_access("gate.order_to_peaks", state).allowed or "region.peaks.visited" in world.facts:
				return rejected(state, "Break the Oath Seal to discover Ashen Peaks")
			world.facts.append("region.peaks.visited")
			world.quest_states["quest.main.ch03"] = "completed"
			reason = "Chapter III complete · Ashen Peaks discovered"
		"MeetCael":
			if "region.order.visited" not in world.facts or "ally.cael.met" in world.facts:
				return rejected(state, "Meet Sir Cael in the Order's Ruins")
			world.facts.append("ally.cael.met")
			world.quest_states["quest.cael"] = "active"
			reason = "Recover the expedition record from the memorial hall"
		"ClearOrderCourtyard":
			if "region.order.visited" not in world.facts or "order.courtyard_safe" in world.facts:
				return rejected(state, "Courtyard already secured or undiscovered")
			world.facts.append("order.courtyard_safe")
			reason = "The courtyard sentries have fallen"
		"ReadExpedition":
			if "ally.cael.met" not in world.facts or "order.courtyard_safe" not in world.facts or "document.order.expedition" in world.pickup_claim_ids:
				return rejected(state, "Speak to Cael and secure the courtyard before recovering the record")
			world.pickup_claim_ids.append("document.order.expedition")
			reason = "Expedition record recovered · return to Sir Cael"
		"OpenForestShortcut":
			if "region.blackwood.visited" not in world.facts or "gate.blackwood.shortcut.open" in world.facts:
				return rejected(state, "Shortcut is unknown or already open")
			world.facts.append("gate.blackwood.shortcut.open")
			reason = "Forest shortcut opened · direct route to lantern"
		"VisitOrder":
			if not gate_access("gate.blackwood_to_order", state).allowed or "region.order.visited" in world.facts:
				return rejected(state, "Break the Root Seal to discover the Order's Ruins")
			world.facts.append("region.order.visited")
			world.quest_states["quest.main.ch02"] = "completed"
			reason = "Chapter II complete · Order's Ruins discovered"
		"MeetLyra":
			if "region.blackwood.visited" not in world.facts or "ally.lyra.met" in world.facts:
				return rejected(state, "Lyra must be met in Blackwood")
			world.facts.append("ally.lyra.met")
			world.quest_states["quest.lyra"] = "active"
			reason = "Lyra needs her scout satchel and a safe trail"
		"ClearForestTrail":
			if "region.blackwood.visited" not in world.facts or "forest.trail_safe" in world.facts:
				return rejected(state, "Forest trail already secured or undiscovered")
			world.facts.append("forest.trail_safe")
			reason = "The trail hounds are defeated"
		"SetActiveCompanion":
			if id != "" and (id not in ["ally.lyra", "ally.cael"] or id not in world.recruited_ally_ids):
				return rejected(state, "Recruit that companion before selecting them")
			world.active_companion_id = id if id != "" else null
			reason = ("Sir Cael" if id == "ally.cael" else "Lyra") + " will accompany you" if id != "" else "Companions will wait at the refuge"
		"VisitBlackwood":
			if "region.blackwood.visited" in world.facts:
				return rejected(state, "Blackwood already discovered")
			if not gate_access("gate.village_to_blackwood", state).allowed:
				return rejected(state, "Break the Burial Seal before entering Blackwood")
			world.facts.append("region.blackwood.visited")
			world.quest_states["quest.main.ch01"] = "completed"
			reason = "Chapter I complete · Blackwood discovered"
		"ActivateCheckpoint":
			if id not in ["checkpoint.refuge", "checkpoint.village", "checkpoint.blackwood", "checkpoint.order", "checkpoint.peaks", "checkpoint.citadel"]:
				return rejected(state, "Unknown checkpoint")
			if id == "checkpoint.citadel" and "region.citadel.visited" not in world.facts:
				return rejected(state,"Discover the citadel before activating its lantern")
			if id == "checkpoint.peaks" and "region.peaks.visited" not in world.facts:
				return rejected(state, "Discover Ashen Peaks before activating its lantern")
			if id == "checkpoint.order" and "region.order.visited" not in world.facts:
				return rejected(state, "Discover the Order's Ruins before activating its lantern")
			if id == "checkpoint.blackwood" and "region.blackwood.visited" not in world.facts:
				return rejected(state, "Discover Blackwood before activating its lantern")
			if id not in world.checkpoint_ids:
				world.checkpoint_ids.append(id)
			var suffix: String = id.trim_prefix("checkpoint.")
			if not world.completed:
				next.recovery = {"checkpoint_id": id, "region_id": "region." + suffix, "spawn_id": "spawn." + suffix + ".safe"}
			reason = "Checkpoint activated; progress saved"
		"ClearMill", "OpenShortcut":
			var fact: String = "mill.guards_cleared" if action == "ClearMill" else "gate.village.shortcut.open"
			if fact in world.facts:
				return rejected(state, "Already completed")
			world.facts.append(fact)
			reason = "Mill guard defeated" if action == "ClearMill" else "Village shortcut opened"
		"RescueOren":
			if "mill.guards_cleared" not in world.facts or "ally.oren" in world.recruited_ally_ids:
				return rejected(state, "Defeat the mill guard before freeing Oren")
			world.recruited_ally_ids.append("ally.oren")
			world.facts.append("ally.oren.rescued")
			world.reward_claim_ids.append("reward.quest.oren")
			world.quest_states["quest.oren"] = "completed"
			grant_xp(character, 60)
			character.shards += 60
			reason = "Oren rescued · he will meet you at the refuge · +60 XP / shards"
		"ClaimPickup":
			if id == "pickup.lyra_satchel":
				if "ally.lyra.met" not in world.facts or "forest.trail_safe" not in world.facts or id in world.pickup_claim_ids:
					return rejected(state, "Speak to Lyra and secure the trail before recovering her satchel")
				world.pickup_claim_ids.append(id)
				reason = "Scout satchel recovered · return to Lyra"
				return {"accepted": true, "reason": reason, "next_state": next}
			if id != "pickup.family_token" or id in world.pickup_claim_ids:
				return rejected(state, "Unknown or already collected pickup")
			world.pickup_claim_ids.append(id)
			world.facts.append("family_token.found")
			world.quest_states["quest.family_token"] = "active"
			reason = "Family token found · bring it to the refuge memorial"
		"CompleteQuest":
			if id != "quest.family_token" or "family_token.found" not in world.facts or "reward.quest.family_token" in world.reward_claim_ids:
				return rejected(state, "Find the family token before returning it")
			world.reward_claim_ids.append("reward.quest.family_token")
			world.quest_states[id] = "completed"
			grant_xp(character, 40)
			character.shards += 30
			reason = "A name remembered · +40 XP · +30 shards"
		"CompleteTraining":
			if world.reward_claim_ids.has("reward.training.victory"):
				return rejected(state, "Training reward already claimed")
			world.facts.append("encounter.training.cleared")
			world.reward_claim_ids.append("reward.training.victory")
			grant_xp(character, 100)
			character.shards += 60
			reason = "Trial cleared · +100 XP · +60 shards"
		"DefeatBoss":
			if not BOSSES.has(id) or world.boss_defeated_ids.has(id):
				return rejected(state, "Unknown or already defeated boss")
			if id == "boss.thorn_beast" and "region.blackwood.visited" not in world.facts:
				return rejected(state, "Discover Blackwood before challenging its guardian")
			if id == "boss.fallen_commander" and "region.order.visited" not in world.facts:
				return rejected(state, "Discover the Order's Ruins before challenging the Commander")
			if id == "boss.iron_warden" and "region.peaks.visited" not in world.facts:
				return rejected(state, "Discover Ashen Peaks before challenging the Warden")
			if id == "boss.maldrek" and "region.citadel.visited" not in world.facts:
				return rejected(state,"Discover the citadel before challenging Maldrek")
			world.boss_defeated_ids.append(id)
			world.facts.append(id + ".defeated")
			world.reward_claim_ids.append("reward." + id)
			var reward: Array = BOSS_REWARDS.get(id, [180, 80])
			grant_xp(character, reward[0])
			character.shards += reward[1]
		"BreakSeal":
			if world.broken_seal_ids.has(id):
				return rejected(state, "Seal already broken")
			var permitted: bool = id == "seal.training" and world.facts.has("encounter.training.cleared")
			for boss in BOSSES:
				if BOSSES[boss] == id and id != "" and world.boss_defeated_ids.has(boss):
					permitted = true
			if not permitted:
				return rejected(state, "Defeat the seal guardian first")
			world.broken_seal_ids.append(id)
			world.facts.append(id + ".broken")
			reason = "Seal broken · passage unlocked"
		"UpgradeWeapon":
			var tier: int = character.weapon_tier
			if tier >= 2:
				return rejected(state, "Sword is already fully upgraded")
			var cost: int = [60, 120][tier]
			if character.shards < cost:
				return rejected(state, "Need %d shards" % cost)
			character.shards -= cost
			character.weapon_tier += 1
			reason = "Sword upgraded to tier %d" % character.weapon_tier
		"RecruitAlly":
			if id == "ally.cael":
				if id in world.recruited_ally_ids or "ally.cael.met" not in world.facts or "order.courtyard_safe" not in world.facts or "document.order.expedition" not in world.pickup_claim_ids:
					return rejected(state, "Recover the expedition record and return to Sir Cael")
				world.recruited_ally_ids.append(id)
				world.active_companion_id = id
				world.quest_states["quest.cael"] = "completed"
				world.reward_claim_ids.append("reward.quest.cael")
				grant_xp(character, 50)
				character.shards += 25
				return {"accepted": true, "reason": "Sir Cael joins · +50 XP · +25 shards", "next_state": next}
			if id != "ally.lyra" or id in world.recruited_ally_ids or "ally.lyra.met" not in world.facts or "forest.trail_safe" not in world.facts or "pickup.lyra_satchel" not in world.pickup_claim_ids:
				return rejected(state, "Complete the ally's authored rescue or recruitment quest")
			world.recruited_ally_ids.append(id)
			world.active_companion_id = id
			world.quest_states["quest.lyra"] = "completed"
			world.reward_claim_ids.append("reward.quest.lyra")
			grant_xp(character, 40)
			character.shards += 20
			reason = "Lyra joins your journey · +40 XP · +20 shards"
		"CompleteCampaign":
			if world.completed or not world.boss_defeated_ids.has("boss.maldrek") or not gate_access("gate.peaks_to_citadel", next).allowed:
				return rejected(state, "The wizard and four seals must be defeated first")
			world.completed = true
			world.facts.append("curse.cleansed")
			world.quest_states["quest.main.ch05"] = "completed"
			next.recovery = {"checkpoint_id":"checkpoint.refuge", "region_id":"region.refuge", "spawn_id":"spawn.refuge.ending"}
			reason = "The curse is broken · return to the restored refuge"
		_:
			return rejected(state, "Unknown action")
	return {"accepted": true, "reason": reason, "next_state": next}

static func rejected(state: Dictionary, reason: String) -> Dictionary:
	return {"accepted": false, "reason": reason, "next_state": state}
