extends Node3D

var player: CharacterBody3D
var kind: String = "orb"
var direction := Vector3.FORWARD
var tempo: float = 1
var elapsed: float = 0
var spent: bool = false
var visual: MeshInstance3D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	visual = MeshInstance3D.new()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("bc86ff") if kind == "orb" else Color("9955df")
	material.emission_enabled=true
	material.emission=preload("res://game/presentation/curse_palette.gd").GLOW
	material.emission_energy_multiplier=0.65
	if kind == "orb":
		var sphere := SphereMesh.new()
		sphere.radius = 0.3
		sphere.height = 0.6
		visual.mesh = sphere
	else:
		var disc := CylinderMesh.new()
		disc.top_radius = 2.3
		disc.bottom_radius = 2.3
		disc.height = 0.05
		visual.mesh = disc
	visual.material_override = material
	add_child(visual)

func _physics_process(delta: float) -> void:
	if spent or not is_instance_valid(player) or player.health <= 0:
		return
	elapsed += delta * tempo
	if kind == "orb":
		var previous := global_position
		var next := previous + direction * 7 * delta * tempo
		var ray := PhysicsRayQueryParameters3D.create(previous, next, 1)
		if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			spent = true
			queue_free()
			return
		global_position = next
		var closest := Geometry3D.get_closest_point_to_segment(player.global_position + Vector3.UP, previous, next)
		if closest.distance_to(player.global_position + Vector3.UP) < 0.7:
			spent = true
			player.receive_hit(previous, 22, 1, 30)
			queue_free()
	elif elapsed >= 1.1:
		spent = true
		var offset := player.global_position - global_position
		if Vector2(offset.x, offset.z).length() <= 2.7 and absf(offset.y) < 1.5:
			player.receive_hit(global_position, 28, 1, 40)
		queue_free()
	if elapsed >= 3:
		queue_free()
