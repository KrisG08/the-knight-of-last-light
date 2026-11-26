extends RefCounted
const Relics = preload("res://game/campaign/domain/relics.gd")
const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const L = preload("res://game/localization/localizer.gd")
class RelicIcon extends Control:
	var kind := "block"
	func _draw() -> void:
		draw_circle(size/2,27,Color("292036"))
		preload("res://game/presentation/action_icons.gd").paint(self,kind,size/2,1.0,Color("dab0f4"))
static func stats(character: Dictionary) -> String:
	var damage := int(Rules.sword_damage({"character":character}))
	return L.text("Sword damage")+" "+str(damage)+" · "+L.text("Defense")+" "+str(10+Relics.bonus(character,"defense"))+" · "+L.text("Flask healing")+" "+str(45+Relics.bonus(character,"healing"))
static func open(game: Node) -> void:
	game.open_dialogue("Equipment")
	var character: Dictionary = game.session.state.character
	var text := L.text("Equipment")+"\n\n"+L.text("Knight sword")+" +"+str(int(character.weapon_tier))+" · "+L.text("Worn shield")+"\n\n"+stats(character)+"\n\n"+L.text("Relic slots")+" "+str(character.equipped_relic_ids.size())+" / 2\n"+L.text("Relics are earned from guardians and completed quests. Equip up to two outside combat.")
	L.set_text(game.dialogue_text,text,false)
	var unlocked := Relics.available(game.session.state)
	for id in Relics.ITEMS:
		var item: Dictionary = Relics.ITEMS[id]
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel",preload("res://game/presentation/ui_style.gd").frame(Color("111923"),Color("79518e"),12))
		game.choices.add_child(card)
		var body := VBoxContainer.new(); card.add_child(body)
		var heading := HBoxContainer.new(); body.add_child(heading)
		var icon := RelicIcon.new()
		icon.kind = "block" if item.defense > 0 else ("heal" if item.healing > 0 else "attack")
		icon.custom_minimum_size = Vector2(64,64)
		heading.add_child(icon)
		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var description: String = L.text(item.description)
		if id in unlocked:
			description = description.get_slice(" · ",1)
		L.set_text(label,L.text(item.name)+"\n"+description,false)
		heading.add_child(label)
		if id not in unlocked: continue
		var equipped: bool = id in character.equipped_relic_ids
		var candidate: Dictionary = character.duplicate(true)
		if equipped: candidate.equipped_relic_ids.erase(id)
		elif character.equipped_relic_ids.size() < 2: candidate.equipped_relic_ids.append(id)
		var comparison := Label.new()
		comparison.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		L.set_text(comparison,L.text("After change")+"\n"+stats(candidate),false)
		if not equipped and character.equipped_relic_ids.size() >= 2:
			L.set_text(comparison,"Remove a relic before equipping another")
		body.add_child(comparison)
		var action: Button = game.button(body,"Remove relic" if equipped else "Equip relic",func(): change(game,id,equipped))
		action.disabled = game.in_combat() or game.player.health <= 0 or (not equipped and character.equipped_relic_ids.size() >= 2)
	game.button(game.choices,"Back to journal",game.show_journal)
	game.button(game.choices,"Close",game.leave_dialogue)
static func change(game: Node, id: String, equipped: bool) -> void:
	if not game.session.active or game.player.health <= 0 or game.in_combat(): return
	game.session.act("RemoveRelic" if equipped else "EquipRelic",id)
	game.sync_stats()
	open(game)
