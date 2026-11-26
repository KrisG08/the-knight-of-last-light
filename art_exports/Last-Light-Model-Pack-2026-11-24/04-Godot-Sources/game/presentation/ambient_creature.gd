extends Node3D
signal work_struck
## Passive scenery only: authored movement, no health, hitboxes or interactions.
const Art = preload("res://game/presentation/art_kit.gd")
const Sources = preload("res://game/presentation/hostile_source_parts.gd")
static var fox_parts: Dictionary = {}
static var dragon_parts: Dictionary = {}
static var scenes: Dictionary = {}
var species := "barghest"
var body: Node3D
var tails: Array[Node3D] = []
var clock := 0.0
var body_scale := Vector3.ONE
var stroll := Vector3.ZERO
var stroll_origin := Vector3.ZERO
var stroll_time := 0.0
var stroll_speed := 0.35
var moving := false
var terrain_height := Callable()
var activity := "stroll"

func assign_activity(id: String, facing: float) -> void:
	activity = id
	rotation.y = facing

func set_stroll(offset: Vector3, obstacles: Array) -> void:
	# Validate the entire short corridor, including the actor's visual width.
	var clearance := 1.5 if species=="troll" else 0.65
	for attempt in range(5):
		var clear := true
		for step in range(17):
			var point := position+offset*(float(step)/16)
			for obstacle in obstacles:
				if obstacle.grow(clearance).has_point(Vector2(point.x,point.z)): clear = false
		if clear:
			stroll = offset
			break
		offset *= 0.5
	stroll_origin = position
	stroll_time = fposmod(absf(position.x*0.7+position.z*0.3),2.0)
	stroll_speed = 0.28 if species=="troll" else 0.4

func setup(kind: String, size: float) -> void:
	species = kind
	name = kind.to_pascal_case()
	body_scale = Vector3.ONE*size
	if species=="barghest": body_scale*=Vector3(1.15,1.1,1.2)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	add_to_group("ambient_creatures")
	body = Node3D.new()
	add_child(body)
	if species=="barghest":
		fox()
	elif species=="ash_dragon":
		imported("icy-dragon")
	elif species in ["goblin","troll","dwarf"]:
		preload("res://game/presentation/folk_models.gd").build(body,species)
	elif species in ["wraith","sentinel","gargoyle"]:
		var entities = preload("res://game/presentation/ambient_entities.gd")
		match species:
			"wraith": entities.wraith(body)
			"sentinel": entities.sentinel(body)
			"gargoyle": entities.gargoyle(body)
	else:
		push_error("Unknown passive creature: "+species)
	body.scale = body_scale

func imported(id: String) -> void:
	if not scenes.has(id): scenes[id] = load("res://assets/vendor/mythic_fauna/"+id+".glb")
	var source: Node3D = scenes[id].instantiate()
	add_child(source)
	# Copy only static visual meshes/materials. Imported files cannot add behavior
	# or collision to the passive scenery, even if a future asset revision has it.
	for original in source.find_children("*","MeshInstance3D",true,false):
		var mesh := MeshInstance3D.new()
		mesh.mesh = original.mesh
		var key: String = id+"/"+str(original.mesh.get_instance_id())
		# Cache an independently recolored mesh, leaving the credited source and
		# its ice palette unchanged for provenance and comparison.
		if not dragon_parts.has(key):
			var recolored := original.mesh.duplicate() as ArrayMesh
			for surface in range(recolored.get_surface_count()):
				var source_material := recolored.surface_get_material(surface) as StandardMaterial3D
				var material := ShaderMaterial.new()
				material.shader = preload("res://assets/materials/ashen_dragon.gdshader")
				material.set_shader_parameter("source_tint",source_material.albedo_color)
				material.set_shader_parameter("has_texture",source_material.albedo_texture!=null)
				material.set_shader_parameter("scale_texture",source_material.albedo_texture)
				material.set_shader_parameter("has_normal",source_material.normal_texture!=null)
				material.set_shader_parameter("scale_normal",source_material.normal_texture)
				recolored.surface_set_material(surface,material)
			dragon_parts[key] = recolored
		mesh.mesh = dragon_parts[key]
		mesh.transform = source.global_transform.affine_inverse()*original.global_transform
		mesh.visibility_range_end = 180
		body.add_child(mesh)
	remove_child(source)
	source.queue_free()

static func moon_part(part: String) -> Mesh:
	if fox_parts.has(part): return fox_parts[part]
	var mesh := Sources.prepare("red-fox")[part].duplicate() as ArrayMesh
	for surface in range(mesh.get_surface_count()):
		var original := mesh.surface_get_material(surface) as ShaderMaterial
		var material := ShaderMaterial.new()
		material.shader = preload("res://assets/materials/moon_fur.gdshader")
		material.set_shader_parameter("skull_mark",part=="head")
		for parameter in ["fur_texture","fur_normal","has_normal"]:
			material.set_shader_parameter(parameter,original.get_shader_parameter(parameter))
		mesh.surface_set_material(surface,material)
	fox_parts[part] = mesh
	return mesh

func fox() -> void:
	Art.mesh(body,moon_part("body"),Vector3.ZERO,null)
	for part in ["head","front_left","front_right","back_left","back_right"]:
		Art.mesh(body,moon_part(part),Sources.pivot("red-fox",part),null)
	var tail := Node3D.new()
	tail.position = Sources.pivot("red-fox","tail")
	tail.rotation = Vector3(-0.08,0,0)
	tail.set_meta("rest_rotation",tail.rotation)
	body.add_child(tail)
	Art.mesh(tail,moon_part("tail"),Vector3.ZERO,null)
	tails.append(tail)

func _process(delta: float) -> void:
	clock+=delta
	if activity=="stroll": advance_stroll(delta)
	else: moving = false
	body.scale = body_scale*Vector3(1,1+sin(clock*1.1)*0.0025,1)
	if species in ["goblin","troll","dwarf"]:
		var swing := sin(stroll_time*stroll_speed*19)*0.32 if moving else sin(clock*0.8)*0.025
		for side in [-1,1]:
			body.get_node("Leg"+str(side)).rotation.x = swing*side if moving else 0.0
			body.get_node("Arm"+str(side)).rotation.x = -swing*side*0.7
		body.position.y = absf(swing)*0.025 if moving else 0.0
		if activity in ["repair","scavenge"]:
			body.rotation.x = 0.08 if activity=="repair" else 0.18+sin(clock*0.7)*0.04
			body.get_node("Arm1").rotation.x = -0.8+sin(clock*2.8)*0.38 if activity=="repair" else -0.65+sin(clock*1.1)*0.22
			body.get_node("Arm-1").rotation.x = -0.65+sin(clock*0.9)*0.08
			if activity=="repair" and floori((clock*2.8-PI/2)/TAU)!=floori(((clock-delta)*2.8-PI/2)/TAU): work_struck.emit()
	if species=="wraith":
		body.position.y = sin(clock*0.7)*0.18
		body.position.x = sin(clock*0.43)*0.08
		body.rotation.y = sin(clock*0.3)*0.1
	for index in range(tails.size()):
		var rest: Vector3 = tails[index].get_meta("rest_rotation")
		tails[index].rotation = rest+Vector3(0,sin(clock*0.65+index)*0.035,0)

func advance_stroll(delta: float) -> void:
	moving = false
	if stroll.length_squared()<0.01: return
	stroll_time += delta
	var duration := stroll.length()/stroll_speed
	var phase := fposmod(stroll_time,duration*2+4)
	var distance := 0.0
	var direction := stroll
	if phase<2: pass
	elif phase<duration+2:
		distance = (phase-2)/duration
		moving = true
	elif phase<duration+4: distance = 1.0
	else:
		distance = 1-(phase-duration-4)/duration
		direction = -stroll
		moving = true
	position = stroll_origin+stroll*distance
	if terrain_height.is_valid(): position.y = terrain_height.call(position.x,position.z)
	if moving: rotation.y = lerp_angle(rotation.y,atan2(-direction.x,-direction.z),minf(delta*4,1))
