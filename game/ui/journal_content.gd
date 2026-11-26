extends RefCounted

const History = preload("res://game/persistence/domain/journey_history.gd")

static func discovered(state: Dictionary, id: String, current: String) -> bool:
	return current==id or id+".visited" in state.campaign.facts or id in state.get("journey",{}).get("visited_region_ids",[]) or "checkpoint."+id.trim_prefix("region.") in state.campaign.checkpoint_ids

static func render(state: Dictionary, current: String, objective: String) -> String:
	var campaign: Dictionary = state.campaign
	var text := "JOURNAL\n\nCURRENT LEAD\n"+objective+"\n\nKNOWN ROUTES\n"
	text += "The old forest road connects Lantern Refuge and Ashen Village.\nVillage: eastern mill, western burial yard, crypt north of the square.\nThe barred central street can be opened from its northern side.\n"
	if discovered(state,"region.blackwood",current):
		text += "\nBlackwood: the eastern watchtower road leads north. Turn west at the northern trail to reach the root shrine. The root bar opens from the northern side.\n"
	if discovered(state,"region.order",current):
		text += "\nOrder ruins: barracks flank the courtyard. The memorial hall lies northwest; the sanctum is north.\n"
	if discovered(state,"region.peaks",current):
		text += "\nAshen Peaks: the abandoned mine is west. Cross the railed bridge to reach the forge fortress. The service bar opens from the fortress side.\n"
	if discovered(state,"region.citadel",current):
		text += "\nCitadel: prison cells lie west, the inscription east, and the ritual chamber north.\n"
	var allies := ""
	if "ally.oren" in campaign.recruited_ally_ids:
		allies += "Oren · safe at the refuge; sword upgrades available.\n"
	elif "quest.oren" in campaign.quest_states:
		allies += "Oren · "+str(campaign.quest_states["quest.oren"])+"\n"
	for entry in [["ally.lyra","quest.lyra","Lyra"],["ally.cael","quest.cael","Sir Cael"]]:
		if entry[0] in campaign.recruited_ally_ids or entry[1] in campaign.quest_states:
			allies += entry[2]+" · "+("recruited" if entry[0] in campaign.recruited_ally_ids else str(campaign.quest_states[entry[1]]))+"\n"
	if not allies.is_empty():
		text += "\nALLIES\n"+allies+"Companions wait outside guardian arenas.\n"
	if "quest.family_token" in campaign.quest_states:
		text += "\nKEEPSAKE\nFamily token · "+str(campaign.quest_states["quest.family_token"])+"\n"
	if not campaign.boss_defeated_ids.is_empty():
		text += "\nRECORDED VICTORIES\n"
		for id in campaign.boss_defeated_ids:
			text += History.BOSSES.get(id,"Guardian")+" · defeated\n"
	if campaign.completed:
		text += "\nThe curse is broken. Your discoveries and victories remain recorded.\n"
	return text
