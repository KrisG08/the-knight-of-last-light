extends RefCounted

const Damage = preload("res://game/combat/domain/damage_rules.gd")
const Sweep = preload("res://game/combat/domain/attack_sweep.gd")
const Strike = preload("res://game/combat/runtime/strike_query.gd")
var actor: CharacterBody3D
var state: String = "locomotion"
var elapsed: float = 0
var ledger: RefCounted
var attack_yaw: float = 0
var buffered: String = ""
var buffer_left: float = 0
var message: String = "Approach the fallen soldier. Middle mouse locks target."
var heavy: bool = false
var combo_step := -1
var combo_left := 0.0
const Attacks = preload("res://game/combat/domain/knight_attacks.gd")

func _init(knight: CharacterBody3D) -> void:
	actor = knight

func clear_buffer() -> void:
	buffered = ""
	buffer_left = 0
	combo_left = 0
	if state != "attack":
		combo_step = -1
		actor.sword_pivot.rotation.x = 0

func can_act() -> bool:
	return state in ["locomotion", "block"] and actor.health > 0

func request_action(action: String) -> void:
	if actor.health <= 0 or actor.dodge_left > 0:
		return
	if action in ["light_attack", "heavy_attack"]:
		buffered = action
		buffer_left = 0.12
		if state == "attack" and elapsed >= Attacks.resolve(heavy,combo_step).duration - 0.30:
			buffer_left = 0.34
	elif action == "heal" and can_act() and actor.healing_charges > 0 and actor.health < actor.max_health:
		actor.healing_charges -= 1
		state = "heal"
		elapsed = 0
		message = "Healing… damage interrupts"

func tick(delta: float) -> void:
	if actor.health <= 0:
		state = "dead"
		return
	elapsed += delta
	combo_left = maxf(0,combo_left-delta)
	buffer_left = maxf(0, buffer_left - delta)
	for action in ["light_attack", "heavy_attack"]:
		if Input.is_action_just_pressed(action):
			request_action(action)
	if state == "attack":
		var attack := Attacks.resolve(heavy,combo_step)
		var windup: float = attack.windup
		var active: float = attack.active
		var duration: float = attack.duration
		# Sweep the entire crossed active interval, including when one tick
		# passes both boundaries. Physics time is the sole hit authority.
		if elapsed >= windup and elapsed - delta <= windup + active:
			var before := lerpf(attack.from, attack.to, clampf((elapsed - delta - windup) / active, 0, 1))
			var after := lerpf(attack.from, attack.to, clampf((elapsed - windup) / active, 0, 1))
			actor.sword_pivot.rotation.y = after
			Strike.swing(actor, &"hostiles", ledger, attack_yaw, before, after, attack.reach, actor.weapon_damage, attack.multiplier, 60 if heavy else 20)
		elif elapsed < windup:
			actor.sword_pivot.rotation.y = lerpf(0, attack.from, elapsed / windup)
		else:
			var recovery := clampf((elapsed-windup-active)/(duration-windup-active),0,1)
			actor.sword_pivot.rotation.y = lerpf(attack.to,0,smoothstep(0,1,recovery))
		if heavy or combo_step == 2:
			actor.sword_pivot.rotation.x = -0.65 * sin(clampf(elapsed / (windup+active),0,1)*PI)
		if elapsed >= duration:
			state = "locomotion"
			actor.sword_pivot.rotation = Vector3.ZERO
			combo_left = 0.65 if not heavy and combo_step < 2 else 0.0
	elif state == "heal":
		if elapsed >= 1.0:
			actor.health = minf(actor.max_health, actor.health + actor.flask_healing)
			state = "locomotion"
			message = "Healed +%d HP" % int(actor.flask_healing)
			actor.sounds.cue("heal")
	elif state == "stagger":
		if elapsed >= 0.65:
			state = "locomotion"
	if actor.dodge_left > 0:
		return
	if can_act():
		state = "block" if Input.is_action_pressed("block") else "locomotion"
		if Input.is_action_just_pressed("heal") and actor.healing_charges > 0 and actor.health < actor.max_health:
			request_action("heal")
		elif buffer_left > 0:
			heavy = buffered == "heavy_attack"
			combo_step = combo_step + 1 if not heavy and combo_left > 0 else 0
			combo_left = 0
			buffered = ""
			buffer_left = 0
			state = "attack"
			elapsed = 0
			ledger = Sweep.new()
			attack_yaw = actor.visual.rotation.y
			message = "Heavy attack" if heavy else "Light attack"
			actor.sounds.cue("swing")

func receive_hit(source: Vector3, base: float, multiplier: float, _guard: float) -> void:
	if actor.health <= 0:
		return
	var dodge_elapsed: float = 0.65 - actor.dodge_left
	var invulnerable: bool = actor.dodge_left > 0 and dodge_elapsed >= 0.10 and dodge_elapsed <= 0.28
	var frontal := Damage.in_guard_cone(-actor.visual.global_basis.z, source - actor.global_position)
	# Player stamina is a sprint reserve; blocking never spends it.
	var result := Damage.resolve(base, multiplier * actor.incoming_damage, actor.defense, actor.stamina, state == "block", frontal, invulnerable, 0)
	if not result.accepted:
		message = "Dodged" if invulnerable else "Hit rejected"
		return
	actor.health = maxf(0, actor.health - result.damage)
	actor.stamina = result.stamina
	message = "Blocked · -%d HP" % result.damage if state == "block" and frontal else "Hit · -%d HP" % result.damage
	actor.sounds.cue("block" if state == "block" and frontal else "hit")
	if result.guard_broken:
		message = "Guard broken!"
	if not (state == "block" and frontal) or result.guard_broken:
		state = "stagger"
		elapsed = 0
		actor.dodge_left = 0
		ledger = null
		actor.sword_pivot.rotation.y = 0
		clear_buffer()
	if actor.health <= 0:
		state = "dead"
		actor.dodge_left = 0
		ledger = null
		clear_buffer()
		actor.died.emit()
		actor.sounds.cue("death")
