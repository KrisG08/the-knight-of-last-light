extends SceneTree

const Rules = preload("res://game/actors/player/movement_rules.gd")
const CombatChecks = preload("res://tests/combat_checks.gd")
const ProgressChecks = preload("res://tests/progression_checks.gd")
const VillageChecks = preload("res://tests/village_checks.gd")
const BurialChecks = preload("res://tests/burial_checks.gd")
const SettingsChecks = preload("res://tests/settings_checks.gd")
const CompanionChecks = preload("res://tests/companion_checks.gd")
const BlackwoodChecks = preload("res://tests/blackwood_checks.gd")
const OrderChecks = preload("res://tests/order_checks.gd")
const CommanderChecks = preload("res://tests/commander_checks.gd")
const PeaksChecks = preload("res://tests/peaks_checks.gd")
const FinaleChecks = preload("res://tests/finale_checks.gd")
const LanternChecks = preload("res://tests/lantern_checks.gd")
const ArtChecks = preload("res://tests/art_checks.gd")
const ForestOpeningChecks = preload("res://tests/forest_opening_checks.gd")
const HostileVisualChecks = preload("res://tests/hostile_visual_checks.gd")
const MobileChecks = preload("res://tests/mobile_checks.gd")
const JourneyChecks = preload("res://tests/journey_checks.gd")
var failures: int = 0
var assertions: int = 0

func check(condition: bool, description: String) -> void:
	assertions += 1
	if not condition:
		push_error(description)
		failures += 1

func _initialize() -> void:
	print("Starting deterministic campaign and settings checks")
	create_timer(35, true).timeout.connect(func(): push_error("Test runner timed out"); quit(1))
	CombatChecks.rules(check)
	ProgressChecks.rules(check)
	ProgressChecks.files(check)
	SettingsChecks.rules(check)
	CompanionChecks.rules(check)
	BlackwoodChecks.rules(check)
	OrderChecks.rules(check)
	CommanderChecks.rules(check)
	PeaksChecks.rules(check)
	FinaleChecks.rules(check)
	LanternChecks.rules(check)
	preload("res://tests/journal_checks.gd").rules(check)
	check(Rules.direction(Vector2(1, -1), 0).length() <= 1.001, "Diagonal speed is capped")
	check(Rules.direction(Vector2(0, -1), PI / 2).is_equal_approx(Vector3.LEFT), "Movement follows camera yaw")
	check(Rules.can_dodge(true, false), "Grounded dodge is independent of sprint reserve")
	check(not Rules.can_dodge(false, false), "Airborne dodge rejected")
	check(not Rules.can_dodge(true, true), "Active dodge cannot restart")
	call_deferred("runtime_checks")

func runtime_checks() -> void:
	print("Starting runtime movement, campaign and presentation checks")
	var scene := load("res://game/bootstrap/game_root.tscn") as PackedScene
	var game := scene.instantiate()
	game.testing = true
	root.add_child(game)
	await process_frame
	check(game.player != null, "Boot constructs player")
	check(game.menu.visible and paused, "Boot menu pauses simulation")
	game.started = true
	game.set_menu(false)
	check(game.player.enabled and not paused, "Start enables gameplay")
	for tick in range(10):
		await physics_frame
	Input.action_press("move_forward")
	var origin: Vector3 = game.player.position
	for tick in range(30):
		await physics_frame
	Input.action_release("move_forward")
	check(game.player.position.z < origin.z - 1, "Physics input moves the knight forward")
	game.player.reset_position()
	game.player.position.y = -20
	await physics_frame
	await physics_frame
	check(game.player.position.y > -1, "Fall plane restores safe spawn")
	await CombatChecks.runtime(game, check)
	ProgressChecks.runtime(game, check)
	game.set_menu(true)
	check(not game.player.enabled, "Pause suppresses movement")
	game.player.sounds.stop()
	game.enemy.sounds.stop()
	await create_timer(0.2, true).timeout
	game.queue_free()
	await process_frame
	print("Runtime checks: village")
	await VillageChecks.run(self, check)
	print("Runtime checks: burial")
	await BurialChecks.run(self, check)
	print("Runtime checks: companions")
	await CompanionChecks.run(self, check)
	print("Runtime checks: Blackwood")
	await BlackwoodChecks.run(self, check)
	print("Runtime checks: Order")
	await OrderChecks.run(self, check)
	print("Runtime checks: commander")
	await CommanderChecks.run(self, check)
	print("Runtime checks: peaks")
	await PeaksChecks.run(self, check)
	print("Runtime checks: finale")
	await FinaleChecks.run(self, check)
	print("Runtime checks: lanterns")
	await LanternChecks.run(self, check)
	print("Runtime checks: art")
	await ArtChecks.run(self, check)
	print("Runtime checks: forest and opening")
	await ForestOpeningChecks.run(self, check)
	print("Runtime checks: hostiles and world life")
	await HostileVisualChecks.run(self, check)
	await preload("res://tests/ambient_fauna_checks.gd").run(self,check)
	await preload("res://tests/opening_world_life_checks.gd").run(self,check)
	print("Runtime checks: mobile controls")
	await MobileChecks.run(self, check)
	print("Runtime checks: saved journeys")
	await JourneyChecks.run(self, check)
	preload("res://tests/localization_checks.gd").rules(check)
	print("Starting optional cloud replica checks")
	await preload("res://tests/cloud_checks.gd").run(self,check)
	print("Campaign + presentation: %d assertions, %s" % [assertions, "PASS" if failures == 0 else "FAIL: %d" % failures])
	quit(0 if failures == 0 else 1)
