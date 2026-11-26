extends Node3D
## Decorative curse only. No collision, navigation, interaction or combat authority.
const Palette=preload("res://game/presentation/curse_palette.gd")
const REGION_SEALS={"region.village":"seal.burial","region.crypt":"seal.burial","region.blackwood":"seal.root","region.grove":"seal.root","region.order":"seal.oath","region.sanctum":"seal.oath","region.peaks":"seal.forge","region.forge":"seal.forge"}
var region_id: String
var emitters: Array[CPUParticles3D]=[]
var clock:=0.0
static var wisp_material: StandardMaterial3D

static func active_for(id: String, state: Dictionary) -> bool:
	if state.campaign.completed: return false
	return not REGION_SEALS.has(id) or REGION_SEALS[id] not in state.campaign.broken_seal_ids

static func material() -> StandardMaterial3D:
	if wisp_material!=null: return wisp_material
	var gradient:=Gradient.new()
	gradient.colors=PackedColorArray([Color(1,1,1,0.45),Color(1,1,1,0.20),Color(1,1,1,0.035),Color(1,1,1,0)])
	gradient.offsets=PackedFloat32Array([0,0.20,0.60,1])
	var texture:=GradientTexture2D.new()
	texture.gradient=gradient; texture.fill=GradientTexture2D.FILL_RADIAL
	texture.fill_from=Vector2(0.5,0.5); texture.fill_to=Vector2(0.5,1)
	wisp_material=StandardMaterial3D.new()
	wisp_material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	wisp_material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
	wisp_material.blend_mode=BaseMaterial3D.BLEND_MODE_ADD
	wisp_material.billboard_mode=BaseMaterial3D.BILLBOARD_ENABLED
	wisp_material.vertex_color_use_as_albedo=true
	wisp_material.albedo_color=Palette.GLOW; wisp_material.albedo_texture=texture
	return wisp_material

func setup(region: Node3D) -> void:
	name="CursePresence"; region_id=region.region_id
	var spawn: Vector3=region.points.get("spawn",Vector3.ZERO)
	var near_path: Vector3=region.surface_point(Vector3(spawn.x-5,0,spawn.z-6))+Vector3.UP
	var target: Vector3=region.surface_point(Vector3(spawn.x+6,0,spawn.z-12))+Vector3.UP
	if is_instance_valid(region.seal): target=region.seal.position+Vector3.UP*0.4
	else:
		for ward in [region.order_ward,region.peaks_ward,region.citadel_ward,region.interact_colliders.get("forest")]:
			if is_instance_valid(ward): target=ward.position+Vector3.UP; break
	for at in [near_path,target]:
		var particles:=CPUParticles3D.new()
		particles.position=at; particles.amount=16; particles.lifetime=7
		particles.emission_shape=CPUParticles3D.EMISSION_SHAPE_SPHERE
		particles.emission_sphere_radius=2.4; particles.direction=Vector3.UP; particles.spread=35
		particles.gravity=Vector3(0,0.06,0)
		particles.initial_velocity_min=0.12; particles.initial_velocity_max=0.30
		particles.scale_amount_min=0.09; particles.scale_amount_max=0.28
		particles.local_coords=true; particles.preprocess=4
		particles.visibility_aabb=AABB(Vector3(-5,-2,-5),Vector3(10,10,10))
		particles.visibility_range_end=32
		particles.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var quad:=QuadMesh.new(); quad.size=Vector2(0.22,0.65); quad.material=material()
		particles.mesh=quad
		var ramp:=Gradient.new()
		ramp.colors=PackedColorArray([Color(1,1,1,0),Color(1,1,1,0.75),Color(1,1,1,0.4),Color(1,1,1,0)])
		ramp.offsets=PackedFloat32Array([0,0.18,0.72,1])
		particles.color_ramp=ramp
		add_child(particles); emitters.append(particles)
	var fill:=OmniLight3D.new(); fill.position=target+Vector3.UP
	fill.light_color=Palette.GLOW; fill.light_energy=0.65; fill.omni_range=6
	fill.shadow_enabled=false; add_child(fill)

func apply_state(state: Dictionary) -> void:
	var active:=active_for(region_id,state)
	visible=active; set_process(active)
	for particles in emitters:
		if particles.emitting!=active: particles.emitting=active

func _process(delta: float) -> void:
	clock+=delta
	for particles in emitters: particles.rotation.y=clock*0.12
