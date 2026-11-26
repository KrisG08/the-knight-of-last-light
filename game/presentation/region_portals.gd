extends Node3D
## All physical campaign links, including their return portals. Read-only state.
const Gate=preload("res://game/presentation/waygate.gd")
const Rules=preload("res://game/campaign/domain/campaign_rules.gd")
const ROUTES={
	"region.refuge":["travel"],"region.village":["travel","crypt","forest"],
	"region.crypt":["crypt_exit"],"region.blackwood":["forest_exit","grove","order_gate"],
	"region.grove":["grove_exit"],"region.order":["order_exit","order_depth","peaks_gate"],
	"region.sanctum":["sanctum_exit"],"region.peaks":["peaks_exit","fortress","citadel_gate"],
	"region.forge":["forge_exit"],"region.citadel":["citadel_exit","citadel_depth"],
	"region.ritual":["ritual_exit"]}
const LOCKS={"forest":"gate.village_to_blackwood","order_gate":"gate.blackwood_to_order","peaks_gate":"gate.order_to_peaks","citadel_gate":"gate.peaks_to_citadel"}
var portals: Dictionary={}
var region: Node3D
var fill: OmniLight3D
var elapsed:=0.0

static func build(owner_region: Node3D) -> void:
	var manager=load("res://game/presentation/region_portals.gd").new()
	manager.name="RegionPortals"; manager.region=owner_region; owner_region.add_child(manager)
	manager.setup()

func setup() -> void:
	var family: String="roots" if region.region_id in ["region.refuge","region.blackwood","region.grove"] else ("iron" if region.region_id in ["region.peaks","region.forge"] else ("gothic" if region.region_id in ["region.citadel","region.ritual"] else "tomb"))
	for key in ROUTES.get(region.region_id,[]):
		var gate:=Gate.new(); add_child(gate)
		var dimensions:=Vector2(3.2,5.2)
		if key in ["citadel_gate","citadel_exit"]: dimensions=Vector2(4.2,6.6)
		if key=="citadel_depth": dimensions=Vector2(5.2,8.2)
		if key=="fortress": dimensions=Vector2(4.2,6.4)
		gate.setup(key,"roots" if key=="forest" else family,dimensions)
		gate.position=region.points[key]
		var returning: bool=key.ends_with("_exit") or (key=="travel" and region.region_id=="region.village")
		gate.rotation.y=PI if returning else 0.0
		gate.position+=gate.basis*Vector3(0,0,0.12)
		portals[key]=gate
		# Preserve collision/state, replacing only the flat ward's visible rectangle.
		if key in LOCKS and region.interact_colliders.has(key): region.interact_colliders[key].get_child(0).hide()
	fill=OmniLight3D.new(); fill.name="NearestPortalLight"; fill.light_color=Color("a95aee")
	fill.light_energy=1.5; fill.omni_range=6; fill.shadow_enabled=false
	add_child(fill); fill.hide()
	set_process(false if portals.is_empty() else true)

func apply_state(state: Dictionary) -> void:
	for key in portals:
		portals[key].set_accessible(not LOCKS.has(key) or Rules.gate_access(LOCKS[key],state).allowed)

func _process(delta: float) -> void:
	elapsed+=delta
	if elapsed<0.25: return
	elapsed=0
	var camera:=get_viewport().get_camera_3d()
	if camera==null: fill.hide(); return
	var nearest: Node3D=null; var distance:=18.0
	for key in portals:
		var gate: Node3D=portals[key]
		var range_to_gate:=camera.global_position.distance_to(gate.global_position+Vector3.UP*2)
		gate.set_nearby(range_to_gate<32)
		if key.ends_with("_exit") and is_instance_valid(region.entrance_barrier):
			gate.set_accessible(region.entrance_barrier.collision_layer==0)
		if range_to_gate<distance: nearest=gate; distance=range_to_gate
	fill.visible=nearest!=null
	if nearest!=null:
		fill.global_position=nearest.global_position+Vector3.UP*2.3+nearest.basis*Vector3(0,0,0.8)
		fill.light_energy=(1.5 if nearest.accessible else 0.5)*clampf((18-distance)/8,0,1)
