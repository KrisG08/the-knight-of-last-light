extends SceneTree
var failures := 0
var assertions := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	root.size = Vector2i(1280,720)
	var game = load("res://game/world/runtime/village_game.tscn").instantiate()
	game.testing = true; root.add_child(game)
	while game.transitioning: await process_frame
	game.session.begin(1,false); game.started = true; game.pause(false)
	var player = game.player
	player.enabled = false; player.stamina = 0
	player.position = game.region.points.spawn
	player.visual.rotation.y = 0
	var enemy = load("res://game/actors/enemies/training_soldier.gd").new()
	enemy.player = player; enemy.home = player.position + Vector3(0,0,-2)
	game.region.add_child(enemy); enemy.set_physics_process(false)
	enemy.position = player.position + Vector3(0,0,-2)
	enemy.health = 1000
	var camera := Camera3D.new()
	game.region.add_child(camera)
	camera.position = player.position + Vector3(3,2.4,-3.6)
	camera.look_at(player.position + Vector3(0,1,-0.7))
	camera.make_current()
	await physics_frame
	var combat = player.combat
	combat.request_action("light_attack"); combat.tick(0.016)
	for index in range(3):
		check(combat.combo_step == index,"Three distinct combo stages")
		if index == 1:
			var ledger = combat.ledger
			combat.clear_buffer()
			check(combat.combo_step == 1 and combat.ledger == ledger,"Pausing mid-combo preserves the active swing and its hit ledger")
		var attack: Dictionary = combat.Attacks.resolve(false,index)
		var before: float = enemy.health
		combat.tick(attack.windup*0.5)
		await photo("light-"+str(index)+"-windup")
		combat.tick(attack.duration-0.08-attack.windup*0.5)
		await photo("light-"+str(index)+"-followthrough")
		check(enemy.health < before,"Each combo swing hits a real hostile")
		check(is_equal_approx(before-enemy.health,28.0 if index == 2 else 21.0),"Finisher rewards completing the three-hit chain")
		var hit_health: float = enemy.health
		combat.tick(0.01)
		check(enemy.health == hit_health,"A swing cannot hit twice in recovery")
		if index < 2: combat.request_action("light_attack")
		combat.tick(0.09)
	check(combat.state == "locomotion" and player.stamina == 0,"Combo finishes without sprint reserve")
	combat.request_action("light_attack"); combat.tick(0.016)
	check(combat.combo_step == 0,"Finisher restarts the chain")
	combat.tick(0.7); combat.tick(0.8)
	combat.request_action("light_attack"); combat.tick(0.016)
	check(combat.combo_step == 0,"Idle gap resets combo")
	combat.request_action("light_attack")
	combat.tick(1.0)
	check(combat.state == "locomotion","Early attack input expires instead of producing an unwanted follow-up")
	combat.clear_buffer(); combat.state = "locomotion"
	combat.request_action("heavy_attack"); combat.tick(0.016)
	combat.tick(0.7)
	enemy.set_physics_process(true)
	await photo("heavy-impact")
	enemy.set_physics_process(false)
	check(enemy.stagger_duration == 0.8 and enemy.state == "stagger","Heavy strike gives an ordinary enemy a longer stagger")
	check(player.stamina == 0,"Heavy strike remains stamina-free")
	combat.request_action("light_attack"); combat.clear_buffer()
	check(combat.buffered.is_empty() and combat.heavy,"Pause clears queued input while preserving the active attack")
	game.queue_free(); await process_frame
	print("Combat combo: %d assertions, " % assertions + ("PASS" if failures == 0 else "FAIL"))
	quit(0 if failures == 0 else 1)
func photo(label_value: String) -> void:
	if DisplayServer.get_name() == "headless": return
	for frame in range(8): await process_frame
	RenderingServer.force_draw(false)
	var args := OS.get_cmdline_user_args()
	var output: String = args[0] if not args.is_empty() else ProjectSettings.globalize_path("res://.tools/review/combo")
	DirAccess.make_dir_recursive_absolute(output)
	root.get_texture().get_image().save_png(output+"/"+label_value+".png")
