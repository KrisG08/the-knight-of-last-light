extends Control
## Passive marker at the selected actor's torso. Never intercepts touch input.
const Targeting = preload("res://game/combat/domain/targeting_rules.gd")
var game: Node
var point := Vector2.ZERO
func setup(owner_game: Node) -> void:
	game = owner_game
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _process(_delta: float) -> void:
	visible = false
	if not is_instance_valid(game) or not game.started or game.transitioning or game.get_tree().paused: return
	var actor: CharacterBody3D = game.player.target
	if not is_instance_valid(actor) or actor.health <= 0 or game.player.health <= 0 or game.player.occluded_for > 0: return
	var camera := get_viewport().get_camera_3d()
	var aim := Targeting.aim_point(actor)
	if camera == null or camera.is_position_behind(aim): return
	point = camera.unproject_position(aim)
	if not Rect2(Vector2(24,24),get_viewport_rect().size-Vector2(48,48)).has_point(point): return
	visible = true
	queue_redraw()
func _draw() -> void:
	var radius := 14.0 * float(game.settings.values.ui_scale)
	for side in range(4):
		var angle := PI/4 + side*PI/2
		var tip := point + Vector2.from_angle(angle)*radius
		var points := PackedVector2Array([tip+Vector2.from_angle(angle-PI*0.75)*7,tip,tip+Vector2.from_angle(angle+PI*0.75)*7])
		draw_polyline(points,Color(0.015,0.01,0.025,.9),5,true)
		draw_polyline(points,Color("e1c7ff"),2,true)
