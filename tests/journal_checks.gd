extends RefCounted

const Journal = preload("res://game/ui/journal_content.gd")
const Campaign = preload("res://game/campaign/domain/campaign_rules.gd")

static func rules(check: Callable) -> void:
	var state := Campaign.new_game()
	var before := JSON.stringify(state)
	var fresh := Journal.render(state,"region.refuge","Find survivors")
	var hidden := true
	for name in ["Blackwood","Thorn Beast","Order ruins","Sir Cael","Lyra","Ashen Peaks","Iron Warden","Maldrek","artifact"]:
		hidden = hidden and not fresh.contains(name)
	check.call(hidden and fresh.contains("Find survivors"),"Fresh journal shows the current lead without future chapter/ally/boss/finale spoilers")
	check.call(JSON.stringify(state)==before,"Reading the journal cannot mutate campaign state")
	state.campaign.facts.append("region.blackwood.visited")
	var forest := Journal.render(state,"region.refuge","Return to the trail")
	check.call(forest.contains("watchtower") and not forest.contains("Order ruins"),"Discovered forest notes remain on returning to refuge without revealing later regions")
	state.campaign.quest_states["quest.lyra"] = "active"
	check.call(Journal.render(state,"region.refuge","Help the scout").contains("Lyra · active"),"Met ally quest appears in journal")
	state.campaign.boss_defeated_ids.append("boss.gravedigger")
	check.call(Journal.render(state,"region.refuge","Continue").contains("Gravedigger · defeated"),"Journal records actual boss victory")
	var legacy := Campaign.new_game()
	legacy.campaign.checkpoint_ids.append("checkpoint.peaks")
	check.call(Journal.render(legacy,"region.refuge","Explore").contains("Ashen Peaks"),"Legacy checkpoint discovery unlocks its journal notes without schema changes")
