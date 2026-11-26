extends SceneTree
const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const Relics = preload("res://game/campaign/domain/relics.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
var failures := 0
var assertions := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	var fresh := Rules.new_game()
	check(Schema.validate(fresh).is_empty(),"Legacy empty equipment remains valid")
	check(not Rules.apply_action(fresh,"EquipRelic","relic.burial_ward").accepted,"Locked relic cannot be equipped")
	var optional := fresh.duplicate(true)
	optional.campaign.reward_claim_ids.append("reward.quest.family_token")
	check("relic.keepsake" in Relics.available(optional),"Optional exploration quest unlocks its own relic")
	var state: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://.tools/wizard-defeat-fixture.json"))
	check(Relics.available(state).size() == 3,"Existing guardian victories unlock relics without replay")
	state = Rules.apply_action(state,"EquipRelic","relic.burial_ward").next_state
	check(Schema.validate(state).is_empty(),"Equipped relic snapshot validates")
	check(not Rules.apply_action(state,"EquipRelic","relic.burial_ward").accepted,"Duplicate relic rejected")
	state = Rules.apply_action(state,"EquipRelic","relic.thorn_heart").next_state
	check(not Rules.apply_action(state,"EquipRelic","relic.oath_edge").accepted,"Third relic rejected")
	var forged := state.duplicate(true)
	forged.character.equipped_relic_ids.append("relic.oath_edge")
	check(not Schema.validate(forged).is_empty(),"Invalid three-slot save rejected")
	forged = fresh.duplicate(true)
	forged.character.equipped_relic_ids = ["relic.oath_edge"]
	check(not Schema.validate(forged).is_empty(),"Unearned relic in save rejected")
	var store = preload("res://game/persistence/infrastructure/save_store.gd").new("user://relic-tests",true)
	check(store.save(state).ok and store.load_slot(state.slot_id).state.character.equipped_relic_ids == state.character.equipped_relic_ids,"Relic selection survives persistence")
	var disk_store = preload("res://game/persistence/infrastructure/save_store.gd").new("user://relic-roundtrip-"+str(Time.get_ticks_usec()))
	check(disk_store.save(state).ok and disk_store.load_slot(int(state.slot_id)).state.character.equipped_relic_ids == state.character.equipped_relic_ids,"Serialized relic selection reloads from disk")
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true; root.add_child(game)
	while game.transitioning: await process_frame
	game.session.begin(1,false); game.started = true
	game.session.state = state; game.sync_stats()
	game.player.health = 20
	check(game.player.defense == 16 and game.player.flask_healing == 55,"Equipped effects reach real actor stats")
	var event := InputEventAction.new(); event.action = "equipment"; event.pressed = true
	game._input(event)
	check(game.dialogue.visible and paused,"Tab input opens actual equipment screen")
	var first: PanelContainer = game.choices.get_child(0)
	var button: Button = first.find_children("*","Button",true,false)[0]
	button.pressed.emit()
	check("relic.burial_ward" not in game.session.state.character.equipped_relic_ids and game.player.defense == 10,"Actual remove button updates actor stats")
	first = game.choices.get_child(0); button = first.find_children("*","Button",true,false)[0]
	button.pressed.emit()
	check(game.player.health == 20 and game.player.healing_charges == 3,"Equipment toggling cannot generate health or flask charges")
	game.player.enabled = false
	game.player.combat.state = "locomotion"
	game.player.combat.request_action("heal"); game.player.combat.tick(1.1)
	check(game.player.health == 75 and game.player.healing_charges == 2,"Relic healing changes a real consumed flask")
	game.player.combat.state = "locomotion"
	game.player.receive_hit(game.player.position+Vector3.FORWARD,24,1,0)
	check(game.player.health == 54,"Defense relic reduces actual incoming damage")
	game.show_equipment()
	first = game.choices.get_child(0); button = first.find_children("*","Button",true,false)[0]
	button.pressed.emit()
	var blade: PanelContainer = game.choices.get_child(2)
	button = blade.find_children("*","Button",true,false)[0]
	button.pressed.emit()
	check(game.player.weapon_damage == 25 and game.player.defense == 10,"Real equipment controls exchange defense for sword damage")
	check(game.session.act("UpgradeWeapon"),"Existing blacksmith upgrade remains available")
	game.sync_stats()
	check(game.player.weapon_damage == 29,"Relic bonus composes with sword upgrades")
	check(game.session.store.load_slot(int(game.session.state.slot_id)).state.character.equipped_relic_ids == game.session.state.character.equipped_relic_ids,"Runtime selection is automatically saved")
	var hostile = load("res://game/actors/enemies/training_soldier.gd").new()
	hostile.player = game.player; hostile.home = game.player.position
	game.region.add_child(hostile); hostile.set_physics_process(false)
	hostile.state = "chase"; game.enemies.append(hostile)
	game.show_equipment()
	var before := JSON.stringify(game.session.state)
	first = game.choices.get_child(0); button = first.find_children("*","Button",true,false)[0]
	check(button.disabled,"Equipment changes disabled during an encounter")
	button.pressed.emit()
	check(JSON.stringify(game.session.state) == before,"Runtime guard rejects equipment changes even if a disabled button signal is emitted")
	game.enemies.erase(hostile); hostile.queue_free(); await process_frame
	var output := ProjectSettings.globalize_path("res://.tools/review/equipment")
	var args := OS.get_cmdline_user_args()
	if not args.is_empty() and args[0] != "--touch": output = args[0]
	DirAccess.make_dir_recursive_absolute(output)
	root.size = Vector2i(1280,600)
	game.settings.values.ui_scale = 1.5
	game.apply_settings()
	for language in ["bg","en","ru","fr","ar"]:
		game.set_language(language); game.show_equipment()
		await create_timer(0.15,true).timeout
		RenderingServer.force_draw(false)
		root.get_texture().get_image().save_png(output+"/"+language+".png")
		check(game.choices.get_child_count() == 6,"All cards and navigation retained in every language")
		check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(game.dialogue.get_global_rect()),"Large equipment text stays within screen")
	game.queue_free(); await process_frame
	print("Relics: %d assertions, " % assertions + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
