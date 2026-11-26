extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")

static func integer(value: Variant, low: int, high: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value)) and value >= low and value <= high

static func ids(value: Variant, allowed: Array) -> bool:
	if not value is Array or value.size() > 128:
		return false
	var seen: Dictionary = {}
	for id in value:
		if not id is String or id.length() > 128 or id not in allowed or seen.has(id):
			return false
		seen[id] = true
	return true

static func validate(document: Variant) -> String:
	if not document is Dictionary:
		return "Save must be an object"
	if not integer(document.get("schema_version"), 1, 1000000):
		return "Invalid save schema"
	if int(document.schema_version) not in [1, 2, 3, 4, 5, 6, 7, 8]:
		return "Unsupported save version; original preserved"
	if document.get("content_version") != "prototype" or not integer(document.get("slot_id"), 1, 999999):
		return "Invalid content version or slot"
	if not document.get("saved_at") is String or document.saved_at.length() > 64:
		return "Invalid save timestamp"
	if int(document.schema_version) == 8 or document.has("journey"):
		var history_error: String = preload("res://game/persistence/domain/journey_history.gd").validate(document.get("journey"))
		if history_error != "": return history_error
	for key in ["character", "campaign", "recovery"]:
		if not document.get(key) is Dictionary:
			return "Missing " + key
	var c: Dictionary = document.character
	if not integer(c.get("rank"), 1, 100) or not integer(c.get("xp_into_rank"), 0, 5049) or not integer(c.get("shards"), 0, 10000000) or not integer(c.get("weapon_tier"), 0, 2):
		return "Invalid character numbers"
	if c.xp_into_rank >= 100 + 50 * (c.rank - 1):
		return "Experience exceeds next rank threshold"
	if c.get("weapon_id") != "weapon.knight_sword" or not ids(c.get("owned_item_ids"), ["weapon.knight_sword", "shield.worn_shield"]) or "weapon.knight_sword" not in c.owned_item_ids or not ids(c.get("equipped_relic_ids"), preload("res://game/campaign/domain/relics.gd").ITEMS.keys()) or not preload("res://game/campaign/domain/relics.gd").valid(document):
		return "Invalid equipment"
	var w: Dictionary = document.campaign
	var bosses: Array = Rules.BOSSES.keys()
	var seals: Array = ["seal.training", "seal.burial", "seal.root", "seal.oath", "seal.forge"]
	var facts: Array = ["encounter.training.cleared", "curse.cleansed", "mill.guards_cleared", "gate.village.shortcut.open", "ally.oren.rescued", "family_token.found", "region.blackwood.visited", "ally.lyra.met", "forest.trail_safe", "gate.blackwood.shortcut.open", "region.order.visited"]
	var rewards: Array = ["reward.training.victory", "reward.quest.oren", "reward.quest.family_token", "reward.quest.lyra"]
	facts.append_array(["ally.cael.met", "order.courtyard_safe"])
	facts.append("region.peaks.visited")
	facts.append_array(["gate.peaks.shortcut.open", "region.citadel.visited", "citadel.ritual_known", "citadel.prison_safe", "citadel.prisoners_freed"])
	rewards.append("reward.quest.prisoners")
	rewards.append("reward.quest.cael")
	for boss in bosses:
		facts.append(boss + ".defeated")
		rewards.append("reward." + boss)
	for seal in seals:
		facts.append(seal + ".broken")
	var catalogs := {"facts": facts, "boss_defeated_ids": bosses, "broken_seal_ids": seals, "reward_claim_ids": rewards, "recruited_ally_ids": ["ally.oren", "ally.lyra", "ally.cael"], "pickup_claim_ids": ["pickup.family_token", "pickup.lyra_satchel"], "checkpoint_ids": ["checkpoint.refuge", "checkpoint.village", "checkpoint.training", "checkpoint.blackwood"]}
	catalogs.pickup_claim_ids.append("document.order.expedition")
	catalogs.checkpoint_ids.append("checkpoint.order")
	catalogs.checkpoint_ids.append_array(["checkpoint.peaks", "checkpoint.citadel"])
	for key in catalogs:
		if not ids(w.get(key), catalogs[key]):
			return "Invalid or duplicate entries in " + key
	for boss in bosses:
		var defeated: bool = boss in w.boss_defeated_ids
		if defeated != (boss + ".defeated" in w.facts) or defeated != ("reward." + boss in w.reward_claim_ids):
			return "Boss reward/fact mismatch"
	var training: bool = "encounter.training.cleared" in w.facts
	if training != ("reward.training.victory" in w.reward_claim_ids):
		return "Training reward mismatch"
	for seal in seals:
		var broken: bool = seal in w.broken_seal_ids
		if broken != (seal + ".broken" in w.facts):
			return "Seal fact mismatch"
		if broken:
			var guardian: bool = seal == "seal.training" and training
			for boss in bosses:
				if Rules.BOSSES[boss] == seal and boss in w.boss_defeated_ids:
					guardian = true
			if not guardian:
				return "Broken seal has no defeated guardian"
	if not w.get("quest_states") is Dictionary or w.quest_states.size() > 10 or w.quest_states.get("quest.main.ch01") not in ["active", "completed"]:
		return "Invalid quest state"
	for quest in w.quest_states:
		if quest not in ["quest.main.ch01", "quest.main.ch02", "quest.main.ch03", "quest.main.ch04", "quest.main.ch05", "quest.prisoners", "quest.oren", "quest.family_token", "quest.lyra", "quest.cael"] or w.quest_states[quest] not in ["active", "completed"]:
			return "Unknown quest or state"
	if "region.blackwood.visited" in w.facts and ("seal.burial" not in w.broken_seal_ids or w.quest_states.get("quest.main.ch01") != "completed"):
		return "Blackwood discovery prerequisites missing"
	var chapter_two: bool = "gate.blackwood.shortcut.open" in w.facts or "region.order.visited" in w.facts or "checkpoint.blackwood" in w.checkpoint_ids or "boss.thorn_beast" in w.boss_defeated_ids or "seal.root" in w.broken_seal_ids
	if chapter_two and (int(document.schema_version) < 3 or "region.blackwood.visited" not in w.facts):
		return "Blackwood chapter progress requires discovered forest and save schema 3"
	if (w.quest_states.get("quest.main.ch02") == "completed") != ("region.order.visited" in w.facts):
		return "Chapter two objective mismatch"
	if "region.order.visited" in w.facts and "seal.root" not in w.broken_seal_ids:
		return "Order route requires broken Root Seal"
	var commander_progress: bool = "boss.fallen_commander" in w.boss_defeated_ids or "seal.oath" in w.broken_seal_ids or "region.peaks.visited" in w.facts or w.quest_states.has("quest.main.ch03")
	if commander_progress and (int(document.schema_version) < 5 or "region.order.visited" not in w.facts):
		return "Commander progress requires discovered Order and schema five"
	if (w.quest_states.get("quest.main.ch03") == "completed") != ("region.peaks.visited" in w.facts):
		return "Chapter three objective mismatch"
	if "region.peaks.visited" in w.facts and "seal.oath" not in w.broken_seal_ids:
		return "Peaks route requires broken Oath Seal"
	var peaks_progress: bool = "checkpoint.peaks" in w.checkpoint_ids or "gate.peaks.shortcut.open" in w.facts or "boss.iron_warden" in w.boss_defeated_ids or "seal.forge" in w.broken_seal_ids or "region.citadel.visited" in w.facts or w.quest_states.has("quest.main.ch04")
	if peaks_progress and (int(document.schema_version) < 6 or "region.peaks.visited" not in w.facts):
		return "Peaks chapter progress requires discovery and schema six"
	if (w.quest_states.get("quest.main.ch04") == "completed") != ("region.citadel.visited" in w.facts):
		return "Chapter four objective mismatch"
	if "region.citadel.visited" in w.facts and not Rules.gate_access("gate.peaks_to_citadel", document).allowed:
		return "Citadel discovery requires four broken seals"
	if ("ally.oren.rescued" in w.facts) != ("reward.quest.oren" in w.reward_claim_ids):
		return "Oren reward mismatch"
	if ("ally.oren" in w.recruited_ally_ids) != ("ally.oren.rescued" in w.facts):
		return "Oren recruitment/rescue mismatch"
	if "ally.oren.rescued" in w.facts and ("ally.oren" not in w.recruited_ally_ids or "mill.guards_cleared" not in w.facts or w.quest_states.get("quest.oren") != "completed"):
		return "Oren rescue prerequisites missing"
	if ("family_token.found" in w.facts) != ("pickup.family_token" in w.pickup_claim_ids):
		return "Family token mismatch"
	if (w.quest_states.get("quest.family_token") == "completed") != ("reward.quest.family_token" in w.reward_claim_ids):
		return "Family quest reward mismatch"
	if "reward.quest.family_token" in w.reward_claim_ids and "family_token.found" not in w.facts:
		return "Family quest has no token"
	var lyra: bool = "ally.lyra" in w.recruited_ally_ids
	if document.schema_version == 1 and ("ally.lyra.met" in w.facts or "forest.trail_safe" in w.facts or "pickup.lyra_satchel" in w.pickup_claim_ids or lyra):
		return "Companion progress requires save schema 2"
	if lyra != ("reward.quest.lyra" in w.reward_claim_ids) or lyra != (w.quest_states.get("quest.lyra") == "completed"):
		return "Lyra recruitment/reward mismatch"
	if ("ally.lyra.met" in w.facts or "forest.trail_safe" in w.facts) and "region.blackwood.visited" not in w.facts:
		return "Forest quest has no discovery"
	if "ally.lyra.met" in w.facts and not w.quest_states.has("quest.lyra"):
		return "Lyra quest missing"
	if "pickup.lyra_satchel" in w.pickup_claim_ids and ("ally.lyra.met" not in w.facts or "forest.trail_safe" not in w.facts):
		return "Satchel prerequisites missing"
	if lyra and "pickup.lyra_satchel" not in w.pickup_claim_ids:
		return "Lyra recruitment has no recovered satchel"
	var cael: bool = "ally.cael" in w.recruited_ally_ids
	var record: bool = "document.order.expedition" in w.pickup_claim_ids
	var order_progress: bool = cael or record or "ally.cael.met" in w.facts or "order.courtyard_safe" in w.facts or "checkpoint.order" in w.checkpoint_ids or w.quest_states.has("quest.cael")
	if order_progress and (int(document.schema_version) < 4 or "region.order.visited" not in w.facts):
		return "Order quest progress requires discovered ruins and schema four"
	if cael != ("reward.quest.cael" in w.reward_claim_ids) or cael != (w.quest_states.get("quest.cael") == "completed"):
		return "Cael recruitment/reward mismatch"
	if ("ally.cael.met" in w.facts) != w.quest_states.has("quest.cael"):
		return "Cael encounter/quest mismatch"
	if record and ("ally.cael.met" not in w.facts or "order.courtyard_safe" not in w.facts):
		return "Expedition record prerequisites missing"
	if cael and not record:
		return "Cael recruitment requires expedition record"
	if w.get("active_companion_id") != null and (w.active_companion_id not in ["ally.lyra", "ally.cael"] or w.active_companion_id not in w.recruited_ally_ids):
		return "Invalid active companion"
	if not w.get("completed") is bool or w.completed != ("curse.cleansed" in w.facts):
		return "Invalid ending state"
	if w.completed and ("boss.maldrek" not in w.boss_defeated_ids or not Rules.gate_access("gate.peaks_to_citadel", document).allowed):
		return "Ending prerequisites missing"
	var finale: bool = "boss.maldrek" in w.boss_defeated_ids or w.completed or "checkpoint.citadel" in w.checkpoint_ids or "citadel.ritual_known" in w.facts or "citadel.prison_safe" in w.facts or "citadel.prisoners_freed" in w.facts
	if finale and (int(document.schema_version) < 7 or "region.citadel.visited" not in w.facts):
		return "Finale progress requires discovered citadel and schema seven"
	var rescued: bool = "citadel.prisoners_freed" in w.facts
	if rescued != ("reward.quest.prisoners" in w.reward_claim_ids) or rescued != (w.quest_states.get("quest.prisoners") == "completed") or (rescued and "citadel.prison_safe" not in w.facts):
		return "Prison rescue prerequisites/reward mismatch"
	if w.completed != (w.quest_states.get("quest.main.ch05") == "completed"):
		return "Final chapter mismatch"
	var r: Dictionary = document.recovery
	if w.completed and (r.get("region_id") != "region.refuge" or r.get("checkpoint_id") != "checkpoint.refuge" or r.get("spawn_id") != "spawn.refuge.ending"):
		return "Completed campaign must recover at restored refuge"
	var spawns := {"checkpoint.refuge": ["region.refuge", "spawn.refuge.safe"], "checkpoint.village": ["region.village", "spawn.village.safe"], "checkpoint.training": ["region.training", "spawn.training.safe"], "checkpoint.blackwood": ["region.blackwood", "spawn.blackwood.safe"]}
	spawns["checkpoint.order"] = ["region.order", "spawn.order.safe"]
	spawns["checkpoint.peaks"] = ["region.peaks", "spawn.peaks.safe"]
	spawns["checkpoint.citadel"] = ["region.citadel", "spawn.citadel.safe"]
	if w.completed:
		spawns["checkpoint.refuge"] = ["region.refuge", "spawn.refuge.ending"]
	if not spawns.has(r.get("checkpoint_id")) or r.checkpoint_id not in w.checkpoint_ids:
		return "Unknown recovery checkpoint"
	if r.get("region_id") != spawns[r.checkpoint_id][0] or r.get("spawn_id") != spawns[r.checkpoint_id][1]:
		return "Invalid recovery spawn"
	return ""
