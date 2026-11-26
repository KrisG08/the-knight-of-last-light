extends Node

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Store = preload("res://game/persistence/infrastructure/save_store.gd")
const Session = preload("res://game/campaign/application/campaign_session.gd")
const SEAL_POSITION = Vector3(0, 0, -11)
const ANVIL_POSITION = Vector3(5, 0, 7)
var game: Node
var session: RefCounted
var slot_picker: OptionButton
var save_note: Label
var equipment: PanelContainer
var equipment_text: Label
var gate: StaticBody3D
var seal_label: Label3D
var confirmation: ConfirmationDialog

func setup(root: Node, column: VBoxContainer, layer: CanvasLayer, testing: bool) -> void:
	game = root
	process_mode = Node.PROCESS_MODE_ALWAYS
	session = Session.new(Store.new("user://saves", testing))
	slot_picker = OptionButton.new()
	for slot in range(1, 4):
		preload("res://game/localization/localizer.gd").add_item(slot_picker,"Save slot %d" % slot, slot)
	column.add_child(slot_picker)
	slot_picker.item_selected.connect(func(_index): game.set_menu(true))
	button(column, "Load selected slot", load_selected)
	button(column, "New journey in selected slot…", request_new)
	button(column, "Equipment / upgrades [Tab]", show_equipment)
	button(column, "Retry saving progress", func(): session.save_progress())
	save_note = Label.new()
	save_note.custom_minimum_size.x = 440
	save_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_note.add_theme_font_size_override("font_size", 14)
	column.add_child(save_note)
	confirmation = ConfirmationDialog.new()
	confirmation.title = "Replace selected journey?"
	confirmation.dialog_text = "This replaces only the selected save slot.\nOther slots remain unchanged."
	confirmation.confirmed.connect(begin_selected)
	layer.add_child(confirmation)
	equipment = PanelContainer.new()
	equipment.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	equipment.position = Vector2(-250, -200)
	equipment.custom_minimum_size = Vector2(500, 400)
	var background := preload("res://game/presentation/ui_style.gd").frame(Color("19232c"),Color("ad69d4"),24)
	equipment.add_theme_stylebox_override("panel", background)
	layer.add_child(equipment)
	var items := VBoxContainer.new()
	items.add_theme_constant_override("separation", 16)
	equipment.add_child(items)
	equipment_text = Label.new()
	equipment_text.custom_minimum_size.x = 452
	equipment_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	items.add_child(equipment_text)
	button(items, "Upgrade sword (near training anvil)", upgrade)
	button(items, "Back", close_equipment)
	equipment.hide()
	game.enemy.defeated.connect(func(): session.reward_soldier(); sync())
	build_training_props()
	sync()

func button(parent: Node, text: String, callback: Callable) -> void:
	var item := Button.new()
	preload("res://game/localization/localizer.gd").set_text(item, text)
	item.pressed.connect(callback)
	parent.add_child(item)

func build_training_props() -> void:
	gate = game.block(Vector3(0, 1.5, -14), Vector3(5, 3, 0.5), Color("576e90"))
	game.block(SEAL_POSITION + Vector3(0, 0.5, 0), Vector3(0.7, 1, 0.7), Color("9275aa"))
	seal_label = game.signpost(SEAL_POSITION + Vector3(0, 2, 0), "", 0.4)
	game.block(ANVIL_POSITION + Vector3(0, 0.5, 0), Vector3(1.5, 1, 0.7), Color("67717c"))
	game.signpost(ANVIL_POSITION + Vector3(0, 2, 0), "TRAINING ANVIL\nE · Equipment", 0.35)
	game.block(Vector3(0, -0.5, -21), Vector3(6, 1, 14), Color("3d5147"))
	for x in [-3.5, 3.5]:
		game.block(Vector3(x, 1.5, -20), Vector3(1, 3, 13), Color("4a5853"))
	game.block(Vector3(0, 1.5, -27), Vector3(8, 3, 1), Color("4a5853"))
	game.signpost(Vector3(0, 2.5, -24), "PASSAGE UNLOCKED\nTraining alcove · return through arch", 0.45)

func selected_slot() -> int:
	return slot_picker.get_selected_id()

func start_or_continue() -> bool:
	if session.active:
		return true
	if session.store.exists(selected_slot()):
		return load_selected()
	begin_selected()
	return session.active

func request_new() -> void:
	if session.dirty and not session.save_progress():
		return
	if session.store.exists(selected_slot()):
		confirmation.popup_centered()
	else:
		begin_selected()

func begin_selected() -> void:
	if not session.store.memory_only:
		var current: Dictionary = session.store.read_file(session.store.path_for(selected_slot()), selected_slot())
		if current.message.begins_with("Unsupported"):
			session.notice = current.message
			return
	session.begin(selected_slot())
	sync()
	game.reset_training()
	game.started = true
	game.set_menu(false)

func load_selected() -> bool:
	if session.dirty:
		session.notice = "Unsaved progress: retry saving before switching journeys"
		return false
	var candidate: Dictionary = session.store.load_slot(selected_slot())
	if candidate.ok and candidate.state.recovery.region_id != "region.training":
		session.notice = "This training build cannot load campaign regions; save preserved"
		return false
	if not session.load_slot(selected_slot()):
		return false
	sync()
	game.reset_training()
	game.started = true
	game.set_menu(false)
	return true

func sync() -> void:
	var maximum := Rules.max_health(session.state)
	var gained: float = maxf(0, maximum - game.player.max_health)
	game.player.max_health = maximum
	game.player.health = minf(maximum, game.player.health + gained)
	game.player.weapon_damage = Rules.sword_damage(session.state)
	game.health_bar.max_value = maximum
	var open: bool = Rules.gate_access("gate.training", session.state).allowed
	gate.visible = not open
	gate.collision_layer = 0 if open else 1
	preload("res://game/localization/localizer.gd").set_text(seal_label, "SEAL BROKEN" if open else ("E · Break training seal" if "encounter.training.cleared" in session.state.campaign.facts else "Defeat soldier to weaken seal"))

func interact() -> void:
	if not game.player.combat.can_act() or game.player.dodge_left > 0:
		return
	if game.player.position.distance_to(SEAL_POSITION) <= 2.5:
		session.act("BreakSeal", "seal.training")
		sync()
	elif game.player.position.distance_to(ANVIL_POSITION) <= 2:
		show_equipment()
	else:
		game.rest_at_checkpoint()

func interaction_prompt() -> String:
	if game.player.position.distance_to(SEAL_POSITION) <= 2.5:
		return "[E] Training seal"
	if game.player.position.distance_to(ANVIL_POSITION) <= 2:
		return "[E] Training anvil · equipment and upgrades"
	if game.player.position.distance_to(game.CHECKPOINT_POSITION) <= 3:
		return "[E] Rest at lantern · restores resources, resets soldier"
	return ""

func show_equipment() -> void:
	game.set_menu(true)
	game.menu.hide()
	equipment.show()

func close_equipment() -> void:
	equipment.hide()
	game.set_menu(true)

func upgrade() -> void:
	if not session.active or game.player.health <= 0 or not game.player.combat.can_act() or game.player.position.distance_to(ANVIL_POSITION) > 2:
		session.notice = "Stand by the training anvil outside an action to upgrade"
		return
	if game.enemy.health > 0 and game.enemy.state != "idle":
		session.notice = "Cannot upgrade during combat"
		return
	session.act("UpgradeWeapon")
	sync()

func save_and_quit() -> void:
	if session.active and not session.save_progress():
		game.set_menu(true)
		return
	game.get_tree().quit()

func _process(_delta: float) -> void:
	if not is_instance_valid(game) or session == null:
		return
	preload("res://game/localization/localizer.gd").set_text(save_note, session.notice + ("\nUNSAVED · Retry saving before quitting" if session.dirty else ""))
	if equipment.visible:
		var c: Dictionary = session.state.character
		var cost: String = str([60, 120][c.weapon_tier]) + " shards" if c.weapon_tier < 2 else "Maximum tier reached"
		preload("res://game/localization/localizer.gd").set_text(equipment_text, "EQUIPMENT\n\nCharacter rank %d · XP %d / %d\nShards %d\n\nKnight sword · equipped · tier %d\nDamage %d → %d\nWorn shield · equipped\n\nNext upgrade: %s\n\n%s" % [c.rank, c.xp_into_rank, 100 + 50 * (c.rank - 1), c.shards, c.weapon_tier, Rules.sword_damage(session.state), [26, 31, 31][c.weapon_tier], cost, session.notice])
