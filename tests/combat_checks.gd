extends RefCounted

const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")

static func rules(check: Callable) -> void:
	var result := Damage.resolve(22, 1, 10, 100, false, true, false, 35)
	check.call(result.accepted and result.damage == 20, "Defense formula rounds expected damage")
	result = Damage.resolve(24, 1, 10, 20, true, true, false, 35)
	check.call(result.damage == 4 and result.stamina == 0 and result.guard_broken, "Guard break retains blocked damage for this hit")
	result = Damage.resolve(24, 1, 10, 100, true, false, false, 35)
	check.call(result.damage == 22 and result.stamina == 100, "Rear hit bypasses block")
	result = Damage.resolve(24,1,10,0,true,true,false,0)
	check.call(result.damage==4 and result.stamina==0 and not result.guard_broken,"Free guard still blocks at zero sprint reserve")
	check.call(not Damage.resolve(24, 1, 0, 100, false, true, true, 35).accepted, "Invulnerability rejects damage")
	for invalid in [-1.0, INF, NAN]:
		check.call(not Damage.resolve(invalid, 1, 0, 100, false, false, false, 0).accepted, "Invalid damage rejected")
	check.call(Damage.in_guard_cone(Vector3.FORWARD, Vector3(1, 0, -1)), "Front diagonal can block")
	check.call(not Damage.in_guard_cone(Vector3.FORWARD, Vector3.BACK), "Rear is outside guard cone")
	var swing := Sweep.new()
	check.call(swing.claim(42) and not swing.claim(42), "One swing cannot claim the same target twice")
	check.call(Sweep.intersects(Vector3.ZERO, 0, Vector3(0, 0, -2), -1.1, 1.1, 2.3), "Entire active window swept in one slow tick")
	check.call(not Sweep.intersects(Vector3.ZERO, 0, Vector3(0, 0, 2), -1.1, 1.1, 2.3), "Sword cannot hit behind attacker")
	check.call(not Sweep.intersects(Vector3.ZERO, 0, Vector3(0, 3, -2), -1.1, 1.1, 2.3), "Sword rejects other elevation")

static func runtime(game: Node, check: Callable) -> void:
	var player = game.player
	var enemy = game.enemy
	player.enabled = false
	player.sounds.cue("swing")
	var swing_sound: AudioStream = player.sounds.stream
	player.sounds.cue("step")
	var footfall: AudioStream = player.sounds.footsteps.stream
	check.call(player.sounds.stream==swing_sound and player.sounds.playing and player.sounds.footsteps.playing,"Footfall layer cannot cut off an active weapon cue")
	player.sounds.cue("step")
	check.call(player.sounds.footsteps.stream!=footfall,"Consecutive steps use different individual footfall samples")
	player.sounds.cue("death")
	check.call(not player.sounds.footsteps.playing,"Death cue stops residual footfall playback")
	player.sounds.stop()
	enemy.set_physics_process(false)
	player.position = Vector3(-5, 0, -1)
	enemy.position = Vector3(-5, 0, -3)
	player.visual.rotation.y = 0
	await game.get_tree().physics_frame
	player.combat.request_action("light_attack")
	player.combat.tick(0.016)
	Input.action_release("light_attack")
	check.call(player.combat.state == "attack" and player.stamina == 100, "Light input starts attack without spending sprint reserve")
	await game.get_tree().physics_frame
	player.combat.tick(0.5)
	check.call(enemy.health == 89, "Light swing damages a real hostile once across active window")
	player.combat.tick(0.03)
	check.call(enemy.health == 89, "Recovery cannot apply repeated damage")
	player.combat.tick(0.5)
	player.stamina = 0
	player.combat.request_action("light_attack")
	player.combat.tick(0.016)
	Input.action_release("light_attack")
	check.call(player.combat.state == "attack" and player.stamina == 0, "Empty sprint reserve cannot prevent a light attack")
	player.combat.tick(0.7)
	player.combat.request_action("heavy_attack")
	player.combat.tick(0.016)
	check.call(player.combat.state == "attack" and player.combat.heavy and player.stamina == 0,"Heavy attack also starts with empty reserve and costs nothing")
	player.combat.tick(1.4)
	await game.get_tree().physics_frame
	player.health = 100
	player.stamina = 20
	player.combat.state = "block"
	player.receive_hit(player.position + Vector3.FORWARD, 24, 1, 35)
	check.call(player.health == 96 and player.stamina == 20 and player.combat.state == "block", "Frontal guard reduces damage without spending sprint reserve")
	player.combat.state = "locomotion"
	player.receive_hit(player.position + Vector3.FORWARD, 24, 1, 35)
	check.call(player.health == 74, "Hit after releasing guard is unblocked")
	player.dodge_left = 0.5
	player.receive_hit(player.position + Vector3.FORWARD, 24, 1, 35)
	check.call(player.health == 74, "Runtime dodge rejects hit within invulnerability window")
	player.dodge_left = 0.3
	player.receive_hit(player.position + Vector3.FORWARD, 24, 1, 35)
	check.call(player.health == 52, "Dodge recovery is vulnerable")
	player.combat.state = "locomotion"
	player.combat.request_action("heal")
	player.combat.tick(0.016)
	Input.action_release("heal")
	check.call(player.combat.state == "heal" and player.healing_charges == 2, "Heal consumes charge at start")
	await game.get_tree().physics_frame
	player.receive_hit(player.position + Vector3.FORWARD, 24, 1, 35)
	player.combat.tick(1.1)
	check.call(player.health == 30, "Damage interrupts healing without a late restore")
	player.combat.state = "locomotion"
	player.combat.request_action("heal")
	player.combat.tick(0.016)
	Input.action_release("heal")
	await game.get_tree().physics_frame
	player.combat.tick(1.1)
	check.call(player.health == 75 and player.healing_charges == 1, "Uninterrupted healing restores 45 HP")
	player.position = Vector3(0, 0, 7)
	enemy.state = "chase"
	check.call(not game.rest_at_checkpoint(), "Checkpoint rejects rest during combat")
	enemy.state = "idle"
	check.call(game.rest_at_checkpoint() and player.health == 100 and player.healing_charges == 3 and enemy.health == 110, "Checkpoint resets health, charges and encounter")
	player.health = 1
	player.combat.state = "attack"
	player.combat.ledger = Sweep.new()
	player.receive_hit(player.position + Vector3.FORWARD, 24, 1, 35)
	check.call(player.health == 0 and player.combat.state == "dead" and player.combat.ledger == null, "Death cancels outgoing attack immediately")
	check.call(game.menu.visible and game.get_tree().paused, "Death freezes encounter and exposes retry")
	game.start_or_retry()
	check.call(player.health == 100 and enemy.health == 110 and not game.get_tree().paused, "Death retry restores entire training encounter")
	player.enabled = false
	player.position = Vector3(-5, 0, -1)
	player.visual.rotation.y = 0
	enemy.position = Vector3(-5, 0, -3)
	await game.get_tree().physics_frame
	player.select_target(false)
	check.call(player.target == enemy, "Lock selects visible living hostile")
	player.update_target(0.1)
	check.call(absf(wrapf(player.yaw, -PI, PI)) < 0.01, "Locked camera faces hostile rather than away")
	enemy._physics_process(0.01)
	check.call(enemy.state == "windup" and player.health == 100, "Enemy telegraphs before dealing damage")
	enemy._physics_process(0.79)
	check.call(player.health == 100, "Windup cannot damage player")
	enemy._physics_process(0.02)
	enemy._physics_process(0.2)
	check.call(player.health == 78, "Enemy active sweep applies damage")
	enemy._physics_process(0.1)
	check.call(player.health == 78, "Enemy recovery cannot repeat damage")
	enemy.receive_hit(player.position, 1000, 1, 0)
	player.update_target(0.1)
	check.call(player.target == null, "Dead target is removed from lock")
	check.call(enemy.health == 0 and enemy.ledger == null and enemy.collision_layer == 0, "Enemy death clears attack and body obstruction")
	game.reset_training()
	enemy.set_physics_process(true)
