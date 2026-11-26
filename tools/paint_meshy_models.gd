extends SceneTree
## Offline rest-space vertex paint; skinning retains paint and detail coordinates.
const Models = preload("res://game/presentation/meshy_models.gd")
const ROOT = "res://assets/models/meshy/"
const PALETTES = {
	"knight":["9a927c","60676b","b18a65","8e7955"],
	"oren":["b0a07e","494d4b","b58b68","a98343"],
	"lyra":["4b503c","4b5960","b28a69","807052"],
	"cael":["34414e","5b6266","a98d73","8e805e"],
	"goblin":["673e28","575b48","617d39","aa8b42"],
	"gravedigger":["625031","414737","9d9a7c","8e7147"],
	"maldrek":["39303c","373548","a59a83","8d8067"],
	"fallen-commander":["4c2930","414348","8c8a75","8f7b55"],
	"iron-warden":["44352b","55504a","8b7760","8d7550"],
	"thorn-beast":["523924","4b5e30","806346","baa172"]}

func _initialize() -> void: call_deferred("paint")

func pigment(id: String, p: Vector3, normal: Vector3, palette: Array) -> Dictionary:
	var armored: bool = id in ["knight","cael","fallen-commander","iron-warden"]
	var color: Color = palette[1] if armored else palette[0]
	var metal := 0.8 if armored else 0.0
	var rough := 0.46 if armored else 0.86
	var front: bool = p.z< -0.025
	var center: bool = absf(p.x)<0.145
	var skin: bool = (p.y>0.845 and p.y<0.965 and front and absf(p.x)<0.115) or (absf(p.x)>0.18 and p.y>0.27 and p.y<0.59)
	var leather := Color("513224")
	if armored:
		if center and p.y>0.36 and p.y<0.81 and absf(p.z)>0.045:
			color = palette[0]; metal = 0; rough = 0.92
		if absf(p.x)<0.18 and p.y>0.48 and p.y<0.525:
			color = Color("30251e"); metal = 0; rough = 0.8
		if absf(p.x)<0.026 and p.y>0.485 and p.y<0.517 and front:
			color = palette[3]; metal = 0.9; rough = 0.5
		if p.y>0.9 and p.y<0.92 and p.z< -0.065:
			color = Color("10171b"); metal = 0.25
		if id=="fallen-commander" and p.y>0.952:
			color = palette[3]; metal = 0.9
		if id=="knight" and absf(p.x)<0.012 and p.y>0.955:
			color = palette[3]; metal = 0.9
		if id=="iron-warden":
			var rust := (sin(p.x*47+p.z*13)*sin(p.y*63)+1)*0.5
			if metal>0.1: color = color.lerp(Color("96552e"),rust*0.48); rough = 0.76
		if id=="cael" and skin:
			color = palette[2]; metal = 0; rough = 0.87
	else:
		if p.y<0.45:
			color = Color("3c3b32") if id!="maldrek" else Color("351a4a")
		if p.y<0.16:
			color = Color("29251f")
		if p.y>0.465 and p.y<0.505 and absf(p.x)<0.19:
			color = Color("38241b"); rough = 0.77
		if id=="oren":
			if p.y>0.30 and p.y<0.78 and front and center: color = Color("653b26"); rough = 0.78
			skin = skin or (absf(p.x)>0.2 and p.y>0.48 and p.y<0.70)
		if id=="lyra":
			if p.y>0.51 and p.y<0.74: color = leather; rough = 0.8
			if p.y>0.74 and p.y<0.85: color = palette[0]
		if id=="goblin":
			skin = p.y>0.82 or (absf(p.x)>0.21 and p.y>0.27 and p.y<0.78)
		if id=="gravedigger":
			skin = p.y>0.85 and p.y<0.94 and front and absf(p.x)<0.065
			if p.y>0.8 and not skin: color = Color("38412d")
			if absf(p.x+(p.y-0.62)*0.32)<0.025 and p.y>0.48 and p.y<0.77 and front: color = leather; rough = 0.78
		if id=="maldrek":
			skin = skin and p.y>0.82
			if absf(p.x)>0.18 and p.y<0.78: color = Color("25283f")
			if front and p.y>0.10 and p.y<0.82 and absf(absf(p.x)-0.105)<0.012:
				color = palette[3]; metal = 0.8; rough = 0.55
			if p.y>0.08 and p.y<0.105: color = palette[3]; metal = 0.7
		if skin: color = palette[2]; metal = 0; rough = 0.87
	# Faces retain warm skin; hair, eyebrows and beards avoid a uniform clay head.
	if id in ["oren","lyra","cael"]:
		if p.y>0.965 or (p.y>(0.79 if id=="lyra" else 0.86) and p.z>0.02): color = Color("30261f") if id=="lyra" else Color("645b4d"); metal = 0
		if id in ["oren","cael"] and p.y>0.848 and p.y<0.888 and front and absf(p.x)<0.07: color = Color("5c5143"); metal = 0
		if p.y>0.925 and p.y<0.937 and front and absf(p.x)>0.018 and absf(p.x)<0.065: color = Color("28251f")
	if id=="maldrek" and p.y>0.955: color = Color("8c8a80"); metal = 0
	if id=="thorn-beast":
		metal = 0; rough = 0.95
		color = palette[0].lerp(palette[1],clampf(normal.y*0.7+sin(p.z*17)*0.15,0,0.65))
		if p.y>0.78 or (p.y>0.60 and absf(p.x)>0.28): color = palette[3]
		if p.z< -0.47 and p.y>0.35 and p.y<0.67: color = Color("9b895e")
		if p.y<0.10: color = Color("30251a")
	var wear := sin(p.x*71+p.z*23)*sin(p.y*93-p.x*27)*0.035
	color = color.darkened(maxf(0,wear))
	color.a = metal
	return {"color":color.srgb_to_linear(),"roughness":rough}

func paint() -> void:
	DirAccess.make_dir_recursive_absolute(ROOT+"painted")
	for id in Models.HEIGHTS:
		var palette: Array = []
		for hex in PALETTES[id]: palette.append(Color(hex))
		var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ROOT+id+".json"))
		var positions := PackedVector3Array()
		var faces := PackedVector3Array()
		for part in definition.parts:
			var spec: Dictionary = definition.parts[part]
			var origin := Vector3(spec.origin[0],spec.origin[1],spec.origin[2])
			var mesh: Mesh = load(ROOT+"refined/"+id+"-"+part+".res")
			for surface in range(mesh.get_surface_count()):
				var arrays := mesh.surface_get_arrays(surface)
				for vertex in arrays[Mesh.ARRAY_VERTEX]: positions.append((vertex+origin)/Models.HEIGHTS[id])
				for index in arrays[Mesh.ARRAY_INDEX]: faces.append(arrays[Mesh.ARRAY_VERTEX][index]+origin)
		var occluder := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := ConcavePolygonShape3D.new()
		shape.set_faces(faces)
		collision.shape = shape; occluder.add_child(collision); root.add_child(occluder)
		await physics_frame
		await physics_frame
		var space := root.world_3d.direct_space_state
		var projection := preload("res://tools/reference_projection.gd").new()
		projection.setup(id,positions)
		var painted := 0
		for part in definition.parts:
			var spec: Dictionary = definition.parts[part]
			var origin := Vector3(spec.origin[0],spec.origin[1],spec.origin[2])
			var mesh: Mesh = load(ROOT+"refined/"+id+"-"+part+".res")
			var output := ArrayMesh.new()
			for surface in range(mesh.get_surface_count()):
				var arrays := mesh.surface_get_arrays(surface)
				var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
				var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
				var colors := PackedColorArray(); var uvs := PackedVector2Array(); var uv2 := PackedVector2Array()
				for index in range(vertices.size()):
					var p: Vector3 = (vertices[index]+origin)/Models.HEIGHTS[id]
					var paint := pigment(id,p,normals[index],palette)
					var coordinate := projection.uv(p)
					var weight := clampf((normals[index].dot(projection.VIEW)+0.1)/0.8,0.0,1.0)
					var rear_head: bool = (p.y>0.84 and p.z> -0.012) or (id=="lyra" and p.y>0.78 and p.z>0.045)
					if normals[index].dot(projection.VIEW)<0.1 or rear_head:
						# Rear clothing reuses corresponding garment detail, never a face.
						weight = 0.85
						if p.y>0.84 or rear_head:
							var metal_head: bool = id in ["knight","fallen-commander","iron-warden"]
							var patch := Vector2(0.38,0.19) if metal_head else Vector2(0.48,0.026)
							var extent := Vector2(0.07,0.04) if metal_head else Vector2(0.025,0.012)
							coordinate = patch+Vector2(fposmod(p.x*5+p.z*2,1),fposmod(p.y*7,1))*extent
					var pixel := coordinate*Vector2(projection.source.get_size())
					var reference := projection.source.get_pixel(clampi(roundi(pixel.x),0,projection.source.get_width()-1),clampi(roundi(pixel.y),0,projection.source.get_height()-1))
					if reference.get_luminance()>0.62 and reference.s<0.12: weight = 0.0
					var normal := normals[index].normalized()
					var tangent := normal.cross(Vector3.UP if absf(normal.y)<0.9 else Vector3.RIGHT).normalized()
					var bitangent := normal.cross(tangent).normalized()
					var from: Vector3 = vertices[index]+origin+normal*Models.HEIGHTS[id]*0.002
					var radius: float = Models.HEIGHTS[id]*0.065
					var shadow := 0.0
					for direction in [normal,(normal+tangent).normalized(),(normal-tangent).normalized(),(normal+bitangent).normalized(),(normal-bitangent).normalized()]:
						var ray := PhysicsRayQueryParameters3D.create(from,from+direction*radius,1)
						var hit := space.intersect_ray(ray)
						if not hit.is_empty(): shadow += 1.0-clampf(from.distance_to(hit.position)/radius,0.0,1.0)
					var ao := 1.0-shadow*0.10
					colors.append(paint.color)
					uvs.append(coordinate); uv2.append(Vector2(paint.roughness,roundi(weight*31)*32+roundi(ao*31)))
					painted += 1
				arrays[Mesh.ARRAY_COLOR] = colors; arrays[Mesh.ARRAY_TEX_UV] = uvs; arrays[Mesh.ARRAY_TEX_UV2] = uv2
				output.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
			var path: String = ROOT+"painted/"+id+"-"+part+".res"
			assert(ResourceSaver.save(output,path,ResourceSaver.FLAG_COMPRESS)==OK)
			spec.mesh = path
		definition["paint"] = "Reference-projected UVs with independent rear paint, roughness and view-confidence masks"
		var file := FileAccess.open(ROOT+id+".json",FileAccess.WRITE)
		file.store_string(JSON.stringify(definition,"\t")); file.close()
		print("PAINTED ",id," / ",painted," vertices")
		occluder.queue_free()
		await physics_frame
	quit()
