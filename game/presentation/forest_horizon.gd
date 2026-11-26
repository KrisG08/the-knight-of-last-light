extends RefCounted
## Cosmetic authored relief bands outside playable bounds; no collision/navmesh.
const Art = preload("res://game/presentation/art_kit.gd")
const SEGMENTS = 384
const RINGS = 64
static var relief: FastNoiseLite
static var erosion: FastNoiseLite

static func build(region: Node3D, extent: Vector2 = Vector2(72,118), id: String = "ForestHorizon", playable_extent: Vector2 = Vector2.ZERO) -> void:
	if relief==null:
		relief=FastNoiseLite.new()
		relief.seed=7319
		relief.noise_type=FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		relief.frequency=0.0024
		relief.fractal_octaves=4
		relief.fractal_gain=0.40
		erosion=FastNoiseLite.new(); erosion.seed=417
		erosion.frequency=0.012; erosion.fractal_octaves=3; erosion.fractal_gain=0.35
	var root := Node3D.new()
	root.name = id
	root.set_meta("landscape_horizon",true)
	root.set_meta("inner_extent",playable_extent)
	root.set_meta("outer_extent",extent)
	region.add_child(root)
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(SEGMENTS):
		var angle := float(index)/SEGMENTS*TAU
		var next := float(index+1)/SEGMENTS*TAU
		if playable_extent!=Vector2.ZERO:
			quad(surface,border(angle,playable_extent+Vector2.ONE*0.02,-0.08),border(next,playable_extent+Vector2.ONE*0.02,-0.08),point(angle,0,extent),point(next,0,extent))
		for ring in range(RINGS):
			quad(surface,point(angle,ring,extent),point(next,ring,extent),point(angle,ring+1,extent),point(next,ring+1,extent))
		# The far skirt descends below every allowed camera angle, through opaque haze.
		var a := point(angle,RINGS,extent); var b := point(next,RINGS,extent)
		var c := border(angle,extent+Vector2.ONE*4200,-1600)
		var d := border(next,extent+Vector2.ONE*4200,-1600)
		quad(surface,a,b,c,d)
	surface.index()
	surface.generate_normals()
	var material := ShaderMaterial.new()
	material.shader = preload("res://assets/materials/distant_landscape.gdshader")
	material.set_shader_parameter("rock_color",load("res://assets/vendor/polyhaven/rock_face_03/Diffuse.jpg"))
	material.set_shader_parameter("rock_normal",load("res://assets/vendor/polyhaven/rock_face_03/nor_gl.jpg"))
	material.set_shader_parameter("rock_rough",load("res://assets/vendor/polyhaven/rock_face_03/Rough.jpg"))
	material.set_shader_parameter("soil_color",load("res://assets/vendor/polyhaven/forest_ground_04/Diffuse.jpg"))
	Art.mesh(root,surface.commit(),Vector3.ZERO,material).name = "WoodlandRidges"

static func quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for vertex in [a,b,c,b,d,c]:
		tool.set_uv(Vector2(vertex.x,vertex.z)*0.025)
		tool.add_vertex(vertex)

static func point(angle: float, ring: int, extent: Vector2) -> Vector3:
	var distance := pow(float(ring)/RINGS,1.6)*1800.0
	var rise := smoothstep(80.0,500.0,distance)
	var at := border(angle,extent+Vector2.ONE*distance,0)
	# Noise adds rock-scale relief only to the cosmetic background, never routes.
	var ridge := pow(clampf(0.5+relief.get_noise_2d(at.x,at.z)*0.9,0.0,1.0),1.8)
	var height := -0.9+rise*(20.0+sqrt(distance)*7.0)*(0.15+ridge*0.85)
	height += rise*erosion.get_noise_2d(at.x,at.z)*(14.0+sqrt(distance)*0.8)
	# An authored northern saddle frames the castle and moon rather than walling them off.
	var north := pow(maxf(0,-cos(angle)),10)
	height *= 1.0-north*0.40
	height -= smoothstep(1350,1800,distance)*180
	at.y=height
	return at

static func border(angle: float, extent: Vector2, height: float) -> Vector3:
	var edge := minf(extent.x/maxf(absf(sin(angle)),0.001),extent.y/maxf(absf(cos(angle)),0.001))
	return Vector3(sin(angle)*edge,height,cos(angle)*edge)

static func fit(region: Node3D) -> void:
	fit_children(region,region,Transform3D.IDENTITY)

static func atmosphere(region: Node3D, color: Color) -> void:
	for visual in region.find_children("WoodlandRidges","MeshInstance3D",true,false):
		visual.material_override.set_shader_parameter("haze_color",color)

static func fit_children(region: Node3D, parent: Node3D, frame: Transform3D) -> void:
	for child in parent.get_children():
		if not child is Node3D: continue
		var transform: Transform3D = frame*child.transform
		if child.has_meta("landscape_horizon"):
			if child.has_meta("terrain_fitted"): continue
			var visual: MeshInstance3D = child.get_node("WoodlandRidges")
			var original: Mesh = visual.mesh
			var arrays := original.surface_get_arrays(0)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			# Some art roots were raised rigidly by the elevation pass. Subtract that
			# inherited rise and sample each apron vertex against the actual local floor.
			for index in range(vertices.size()):
				var world := transform*vertices[index]
				var rise: float = region.height_at(world.x,world.z)-transform.origin.y
				vertices[index] += transform.basis.inverse()*Vector3.UP*rise
			arrays[Mesh.ARRAY_VERTEX] = vertices
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			var normals := PackedVector3Array(); normals.resize(vertices.size()); normals.fill(Vector3.ZERO)
			for triangle in range(0,indices.size(),3):
				var a := indices[triangle]; var b := indices[triangle+1]; var c := indices[triangle+2]
				var normal := (vertices[c]-vertices[a]).cross(vertices[b]-vertices[a])
				normals[a] += normal; normals[b] += normal; normals[c] += normal
			for index in range(normals.size()): normals[index] = normals[index].normalized()
			arrays[Mesh.ARRAY_NORMAL] = normals
			var mesh := ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
			visual.mesh = mesh
			visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			child.set_meta("terrain_fitted",true)
			var extent: Vector2 = child.get_meta("outer_extent")
			preload("res://game/presentation/distant_forests.gd").build(child,sample_surface.bind(region,transform,extent,{}),transform)
		else:
			fit_children(region,child,transform)

static func sample_surface(angle: float, distance: float, region: Node3D, frame: Transform3D, extent: Vector2, cache: Dictionary) -> Vector3:
	var radial := pow(clampf(distance/1800.0,0,1),1.0/1.6)*RINGS
	var angular := fposmod(angle,TAU)/TAU*SEGMENTS
	var ring := mini(floori(radial),RINGS-1); var sector := floori(angular)
	var u := angular-sector; var v := radial-ring
	var corners: Array[Vector3] = []
	for offset in [Vector2i(0,0),Vector2i(1,0),Vector2i(0,1),Vector2i(1,1)]:
		var key := Vector2i(sector+offset.x,ring+offset.y)
		if not cache.has(key):
			var at := point(float(key.x)/SEGMENTS*TAU,key.y,extent)
			var world: Vector3 = frame*at
			cache[key] = at+frame.basis.inverse()*Vector3.UP*(region.height_at(world.x,world.z)-frame.origin.y)
		corners.append(cache[key])
	return corners[0]+(corners[1]-corners[0])*u+(corners[2]-corners[0])*v if u+v<=1 else corners[3]+(corners[2]-corners[3])*(1-u)+(corners[1]-corners[3])*(1-v)
