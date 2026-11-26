extends Node3D
## A world-space health meter; reads combat state without owning or changing it.
const Surface = preload("res://assets/materials/hostile_health.gdshader")
const Models = preload("res://game/presentation/meshy_models.gd")
var actor: CharacterBody3D
var caption: Label3D
var surface: ShaderMaterial
var fill_fraction: float = 1.0

func setup(owner_actor: CharacterBody3D, name_label: Label3D) -> void:
	actor = owner_actor
	caption = name_label
	name = "HostileHealth"
	var boss := actor.is_in_group("bosses")
	var model_id: String = actor.visual.get_meta("meshy_model", "")
	if Models.HEIGHTS.has(model_id):
		caption.position.y = Models.HEIGHTS[model_id] + 0.48
	elif not boss:
		caption.position.y = 1.6 if actor.profile != null and actor.profile.hound_shape else 2.28
	position.y = caption.position.y - 0.20
	actor.set_meta("lock_height",clampf((caption.position.y-0.48)*0.58,0.7,2.2))
	preload("res://game/localization/localizer.gd").set_text(caption, actor.display_name.to_upper())
	caption.font_size = 24
	caption.pixel_size = 0.005
	var meter := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(1.65, 0.13) if boss else Vector2(1.2, 0.10)
	meter.mesh = quad
	meter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	surface = ShaderMaterial.new()
	surface.shader = Surface
	meter.material_override = surface
	add_child(meter)
	sync()

func _process(_delta: float) -> void:
	sync()

func sync() -> void:
	fill_fraction = clampf(actor.health / maxf(actor.max_health, 1.0), 0.0, 1.0)
	surface.set_shader_parameter("fraction", fill_fraction)
	var camera := get_viewport().get_camera_3d()
	visible = actor.health > 0 and (camera == null or camera.global_position.distance_to(actor.global_position) < 28.0)
	caption.visible = visible
