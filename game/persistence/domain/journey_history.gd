extends RefCounted
## Durable exploration and victory history. Boss/quest truth stays in campaign.
const REGIONS = ["region.refuge","region.village","region.crypt","region.blackwood","region.grove","region.order","region.sanctum","region.peaks","region.forge","region.citadel","region.ritual","region.training"]
const BOSSES = {"boss.gravedigger":"Gravedigger","boss.thorn_beast":"Thorn Beast","boss.fallen_commander":"Fallen Commander","boss.iron_warden":"Iron Warden","boss.maldrek":"Maldrek"}
const QUESTS = {"quest.main.ch01":"Chapter I · Ashen Village","quest.main.ch02":"Chapter II · Blackwood","quest.main.ch03":"Chapter III · The Order","quest.main.ch04":"Chapter IV · Ashen Peaks","quest.main.ch05":"Chapter V · The Citadel","quest.oren":"Rescue Oren","quest.family_token":"Family keepsake","quest.lyra":"Help Lyra","quest.cael":"Sir Cael's expedition","quest.prisoners":"Free the prisoners"}
const REGION_NAMES = {"region.refuge":"Lantern Refuge","region.village":"Ashen Village","region.crypt":"Burial Chamber","region.blackwood":"Blackwood","region.grove":"Thorn Grove","region.order":"Order's Ruins","region.sanctum":"Commander's Sanctum","region.peaks":"Ashen Peaks","region.forge":"The Forge","region.citadel":"Eclipse Citadel","region.ritual":"Ritual Chamber","region.training":"Training Grounds"}

static func ensure(state: Dictionary, legacy: bool = true) -> void:
	if state.has("journey"): return
	state.schema_version = 8
	var visited: Array = [state.recovery.region_id]
	for checkpoint in state.campaign.checkpoint_ids:
		var id: String = checkpoint.replace("checkpoint.","region.")
		if id in REGIONS and id not in visited: visited.append(id)
	for fact in state.campaign.facts:
		if fact.ends_with(".visited"):
			var id: String = fact.trim_suffix(".visited")
			if id in REGIONS and id not in visited: visited.append(id)
	state.journey = {"name":"Journey %d" % state.slot_id,"created_at":state.saved_at if state.saved_at != "" else Time.get_datetime_string_from_system(true)+"Z","visited_region_ids":visited,"enemy_defeats":{},"legacy_history":legacy}
	if not legacy: state.journey.tutorial_completed_ids = []

static func validate(value: Variant) -> String:
	if not value is Dictionary: return "Missing journey history"
	if value.has("tutorial_completed_ids") and not preload("res://game/campaign/domain/tutorial_progress.gd").valid(value.tutorial_completed_ids): return "Invalid tutorial progress"
	for key in ["name","created_at"]:
		if not value.get(key) is String or value[key].is_empty() or value[key].length() > 80: return "Invalid journey " + key
	if not value.get("legacy_history") is bool: return "Invalid journey history origin"
	if not value.get("visited_region_ids") is Array or value.visited_region_ids.size() > REGIONS.size(): return "Invalid visited regions"
	var seen := {}
	for id in value.visited_region_ids:
		if id not in REGIONS or seen.has(id): return "Invalid or duplicate visited region"
		seen[id] = true
	if not value.get("enemy_defeats") is Dictionary or value.enemy_defeats.size() > 4096: return "Invalid enemy history"
	for id in value.enemy_defeats:
		var entry: Variant = value.enemy_defeats[id]
		if not id is String or id.is_empty() or id.length() > 160 or not entry is Dictionary: return "Invalid enemy identity"
		if not entry.get("name") is String or entry.name.is_empty() or entry.name.length() > 80 or entry.get("region") not in REGIONS: return "Invalid enemy description"
		var count: Variant = entry.get("count")
		if not (count is float or count is int) or not is_finite(float(count)) or count < 1 or count > 1000000 or floorf(count) != count: return "Invalid enemy defeat count"
	return ""

static func enemy_id(region: String, actor: CharacterBody3D) -> String:
	var profile: String = actor.profile.resource_path.get_file().get_basename() if actor.profile != null else "fallen_soldier"
	var at: Vector3 = actor.get_meta("authored_home",actor.home)
	return "%s/%s/%.2f,%.2f,%.2f" % [region,profile,at.x,at.y,at.z]

static func enemy_total(state: Dictionary) -> int:
	var total := 0
	for entry in state.get("journey",{}).get("enemy_defeats",{}).values(): total += int(entry.count)
	return total

static func summary(state: Dictionary) -> String:
	return "Rank %d · %d/5 bosses · %d enemy victories" % [state.character.rank,state.campaign.boss_defeated_ids.size(),enemy_total(state)]

static func describe(state: Dictionary) -> String:
	var text := "%s · WORLD PROGRESS\n" % state.get("journey",{}).get("name","Journey %d" % state.slot_id)+summary(state)+"\n\nBOSSES\n"
	for id in BOSSES: text += ("DEFEATED · " if id in state.campaign.boss_defeated_ids else "Not defeated · ")+BOSSES[id]+"\n"
	text += "\nMISSIONS\n"
	for id in state.campaign.quest_states: text += QUESTS.get(id,"Mission")+" · "+state.campaign.quest_states[id]+"\n"
	text += "\nWORLD\n%d seals broken · %d allies recruited · %d pickups/documents\n" % [state.campaign.broken_seal_ids.size(),state.campaign.recruited_ally_ids.size(),state.campaign.pickup_claim_ids.size()]
	for id in state.campaign.recruited_ally_ids: text += "Recruited · "+id.trim_prefix("ally.").capitalize()+"\n"
	var pickups := {"pickup.family_token":"Family token","pickup.lyra_satchel":"Scout satchel","document.order.expedition":"Expedition record"}
	for id in state.campaign.pickup_claim_ids: text += "Collected · "+pickups.get(id,"Keepsake")+"\n"
	var shortcuts := {"gate.village.shortcut.open":"Village gate","gate.blackwood.shortcut.open":"Forest root bar","gate.peaks.shortcut.open":"Peaks service path"}
	for id in state.campaign.facts:
		if shortcuts.has(id): text += "Shortcut open · "+shortcuts[id]+"\n"
	text += "\nCHARACTER\nSword +%d · %d shards · %d XP toward next rank\n" % [state.character.weapon_tier,state.character.shards,state.character.xp_into_rank]
	text += "Curse broken\n" if state.campaign.completed else "Journey in progress\n"
	text += "\nEXPLORED REGIONS\n"
	for id in state.get("journey",{}).get("visited_region_ids",[]): text += REGION_NAMES.get(id,"Explored area")+"\n"
	text += "\nENEMY VICTORIES\n"
	var groups := {}
	for entry in state.get("journey",{}).get("enemy_defeats",{}).values():
		var key: String = entry.region+"/"+entry.name
		if not groups.has(key): groups[key] = {"name":entry.name,"region":entry.region,"count":0}
		groups[key].count += int(entry.count)
	for entry in groups.values(): text += "%s · %s · defeated %d times\n" % [entry.name,REGION_NAMES.get(entry.region,"Explored area"),entry.count]
	if state.get("journey",{}).get("legacy_history",true): text += "Earlier ordinary-enemy victories were not recorded by older versions.\n"
	text += "\nOrdinary enemies return after resting/reloading; victory history remains. Boss victories and world unlocks persist. Loading resumes safely at the last lantern."
	return text
