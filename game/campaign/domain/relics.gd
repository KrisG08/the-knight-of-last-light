extends RefCounted
## Ownership is derived from durable boss victories, including older journeys.
const ITEMS = {
	"relic.burial_ward":{"name":"Burial Ward","boss":"boss.gravedigger","defense":6,"damage":0,"healing":0,"description":"Defeat the Gravedigger · +6 defense"},
	"relic.thorn_heart":{"name":"Thorn Heart","boss":"boss.thorn_beast","defense":0,"damage":0,"healing":10,"description":"Defeat the Thorn Beast · +10 flask healing"},
	"relic.oath_edge":{"name":"Oath Edge","boss":"boss.fallen_commander","defense":0,"damage":3,"healing":0,"description":"Defeat the Fallen Commander · +3 sword damage"},
	"relic.keepsake":{"name":"Family Keepsake","boss":"","reward":"reward.quest.family_token","defense":3,"damage":0,"healing":5,"description":"Return the family token · +3 defense and +5 flask healing"}
}
static func available(state: Dictionary) -> Array:
	var result := []
	var victories = state.get("campaign",{}).get("boss_defeated_ids",[])
	var rewards = state.get("campaign",{}).get("reward_claim_ids",[])
	if not victories is Array or not rewards is Array: return result
	for id in ITEMS:
		if ITEMS[id].boss in victories or ITEMS[id].get("reward","") in rewards: result.append(id)
	return result
static func bonus(character: Dictionary, stat: String) -> int:
	var result := 0
	for id in character.get("equipped_relic_ids",[]):
		if ITEMS.has(id): result += ITEMS[id].get(stat,0)
	return result
static func valid(state: Dictionary) -> bool:
	var equipped = state.get("character",{}).get("equipped_relic_ids",[])
	if not equipped is Array or equipped.size() > 2: return false
	var unlocked := available(state)
	var seen := []
	for id in equipped:
		if id not in unlocked or id in seen: return false
		seen.append(id)
	return true
