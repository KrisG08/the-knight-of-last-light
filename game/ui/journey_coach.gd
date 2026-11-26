extends PanelContainer
## Passive, contextual lessons. No gameplay gates or additional touch buttons.
const Progress = preload("res://game/campaign/domain/tutorial_progress.gd")
const L = preload("res://game/localization/localizer.gd")
const COPY = {
	"lock":["Press %s to lock onto a visible enemy.","Tap an enemy to focus; tap again or drag to release. Attacks can focus automatically."],
	"heal":["Press %s to drink a flask when hurt. Rest at a lantern to refill.","Tap the flask icon when hurt. Rest at a lantern to refill."],
	"move":["Move with %s / %s / %s / %s.","Move with the left stick."],
	"look":["Move the mouse to look around.","Drag empty space on the right to look around."],
	"sprint":["Hold %s while moving to sprint. Only sprinting spends stamina.","Push the stick to its edge to sprint. Only sprinting spends stamina."],
	"jump":["Press %s to jump.","Swipe upward on the curved arrow to jump."],
	"light":["Press %s for a light attack. Time three presses for a combo.","Tap the sword for a light strike. Time three taps for a combo."],
	"heavy":["Press %s for a heavy attack. Its slower windup rewards an opening.","Hold the sword for a heavy strike. Watch for an opening."],
	"block":["Hold %s to guard. Face the incoming attack.","Hold the shield icon and face the incoming attack."],
	"dodge":["Press %s to dodge an incoming attack.","Tap the curved arrow to evade an incoming attack."],
	"rest":["Use %s beside a lantern to recover and save your checkpoint.","Tap the diamond icon beside a lantern to recover and save."],
	"interact":["Use %s near an ally to talk. Open %s for your journal and map.","Tap the diamond icon near an ally to talk. Find your journal and map in Pause."]
}
var game: Node
var label: Label
var origin := Vector3.ZERO
var region_id := ""
var key := ""
var active_lesson := ""
var showing_for := 0.0
var cooldown := 0.0
var replaying := false
var save_queued := false
func setup(owner_game: Node) -> void:
	game = owner_game
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_stylebox_override("panel",preload("res://game/presentation/ui_style.gd").frame(Color("111820ed"),Color("ae7ed1"),12))
	label = Label.new(); label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font",preload("res://game/presentation/ui_style.gd").font())
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label); hide()
	game.player.looked.connect(func(): mark("look"))
func mark(id: String) -> void:
	if not game.session.active or id not in Progress.IDS: return
	var history: Dictionary = game.session.state.get("journey",{})
	if history.is_empty(): return
	if not history.has("tutorial_completed_ids"): return
	var done: Array = history.get("tutorial_completed_ids",[])
	if id in done: return
	done.append(id); history.tutorial_completed_ids = done
	game.session.dirty = true; game.session.revision += 1
	if not save_queued:
		save_queued = true
		call_deferred("persist")
	if active_lesson == id: active_lesson = ""; cooldown = 2.0; hide()
func persist() -> void:
	save_queued = false
	if game.session.active: game.session.save_progress()
func skip() -> void:
	if not game.session.active: return
	game.session.state.journey.tutorial_completed_ids = Progress.IDS.duplicate()
	game.session.dirty = true; game.session.revision += 1; game.session.save_progress()
	active_lesson = ""; cooldown = 0
	hide()
func replay() -> void:
	if not game.session.active: return
	game.session.state.journey.tutorial_completed_ids = []
	replaying = true; active_lesson = ""; cooldown = 0
	key = str(game.session.state.slot_id)+str(game.session.state.journey.get("created_at",""))
	origin = game.player.position
	game.session.dirty = true; game.session.revision += 1; game.session.save_progress()
func _process(delta: float) -> void:
	if not game.session.active or not game.started or game.transitioning or not game.player.enabled or game.player.health <= 0:
		hide(); return
	var history: Dictionary = game.session.state.get("journey",{})
	var identity := str(game.session.state.slot_id)+str(history.get("created_at",""))
	if key != identity:
		key = identity; replaying = false; origin = game.player.position
		active_lesson = ""; cooldown = 0
	if not history.has("tutorial_completed_ids"): hide(); return
	if history.tutorial_completed_ids.size() == Progress.IDS.size(): hide(); return
	if region_id != game.region.region_id:
		region_id = game.region.region_id; origin = game.player.position
	if game.player.position.distance_to(origin) > 3 and Vector2(game.player.velocity.x,game.player.velocity.z).length() > 0.2: mark("move")
	if game.player.stamina < 99 and Input.is_action_pressed("sprint"): mark("sprint")
	if Input.is_action_pressed("jump") and game.player.velocity.y > 1 and not game.player.is_on_floor(): mark("jump")
	if game.player.dodge_left > 0: mark("dodge")
	if game.player.combat.state == "attack": mark("heavy" if game.player.combat.heavy else "light")
	if game.player.combat.state == "block": mark("block")
	if is_instance_valid(game.player.target): mark("lock")
	if game.player.combat.state == "heal": mark("heal")
	var done: Array = history.get("tutorial_completed_ids",[])
	cooldown = maxf(0,cooldown-delta)
	var choices := ["lock","light","heavy","block","dodge"] if game.in_combat() else (["move","look","sprint","jump"] if game.region.region_id == "region.refuge" or replaying else [])
	if game.player.health < game.player.max_health-1 and game.player.healing_charges > 0: choices.push_front("heal")
	if game.region.region_id in ["region.refuge","region.village","region.blackwood","region.order","region.peaks","region.citadel"] and game.player.position.distance_to(game.region.points.checkpoint) <= 3: choices.append("rest")
	if game.region.region_id == "region.village": choices.append("interact")
	if active_lesson.is_empty() and cooldown <= 0:
		for id in choices:
			if id not in done: active_lesson = id; showing_for = 0; break
	if active_lesson.is_empty(): hide(); return
	if active_lesson not in choices: active_lesson = ""; hide(); return
	showing_for += delta
	if showing_for > 7: active_lesson = ""; cooldown = 15; hide(); return
	var mobile := preload("res://game/presentation/mobile_controls.gd").requested()
	var text: String = COPY[active_lesson][1 if mobile else 0]
	if not mobile:
		text = L.text(text)
		if active_lesson == "move": text = text % [game.settings.hint("move_forward"),game.settings.hint("move_left"),game.settings.hint("move_back"),game.settings.hint("move_right")]
		elif active_lesson == "interact": text = text % [game.settings.hint("interact"),game.settings.hint("journal")]
		elif "%s" in text: text = text % game.settings.hint({"light":"light_attack","heavy":"heavy_attack","rest":"interact","block":"block","lock":"target_lock"}.get(active_lesson,active_lesson))
	L.set_text(label,text,mobile)
	var font_size := roundi(18 * game.settings.values.ui_scale)
	if label.get_theme_font_size("font_size") != font_size: label.add_theme_font_size_override("font_size",font_size)
	var extent := get_viewport_rect().size
	var width := minf(420,extent.x*0.4)
	label.custom_minimum_size.x = width-28
	size = Vector2(width,get_combined_minimum_size().y)
	position = Vector2((extent.x-width)/2,extent.y-size.y-110)
	show()
