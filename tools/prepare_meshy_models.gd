extends SceneTree
## Offline geometry preparation. Original GLBs remain untouched outside assets.
const HEIGHTS = {"knight":1.9,"oren":1.85,"lyra":1.8,"cael":1.9,"goblin":1.45,"gravedigger":2.6,"maldrek":2.8,"fallen-commander":2.65,"iron-warden":3.1,"thorn-beast":2.3}
const OUT = "res://assets/models/meshy/"

func _initialize() -> void:
	call_deferred("prepare")

func part_at(id: String, p: Vector3, height: float) -> String:
	var q := p/height
	if id=="thorn-beast":
		if q.y<0.38 and absf(q.x)>0.12:
			return ("front_" if q.z<0 else "back_")+("left_leg" if q.x<0 else "right_leg")
		return "body"
	if q.y<0.46 and (id!="maldrek" or q.y<0.13):
		return "left_leg" if q.x<0 else "right_leg"
	if q.y>0.34 and q.y<0.83 and absf(q.x)>0.16+(0.8-q.y)*0.12:
		return "left_arm" if q.x<0 else "right_arm"
	return "body"

func origin_at(id: String, part: String, h: float) -> Vector3:
	var side := -1.0 if part.contains("left") else 1.0
	if id=="thorn-beast":
		return Vector3(side*h*0.23,h*0.42,(-0.48 if part.begins_with("front") else 0.48)*h) if part.ends_with("leg") else Vector3.ZERO
	if part.ends_with("leg"): return Vector3(side*h*0.0895,h*0.474,0)
	if part.ends_with("arm"): return Vector3(side*h*0.18,h*0.77,0)
	return Vector3.ZERO

func compact(vertices: PackedVector3Array, normals: PackedVector3Array, indices: PackedInt32Array, origin: Vector3) -> Array:
	var result := []; result.resize(Mesh.ARRAY_MAX)
	var points := PackedVector3Array(); var directions := PackedVector3Array(); var selected := PackedInt32Array(); var remap := {}
	for old in indices:
		if not remap.has(old):
			remap[old] = points.size()
			points.append(vertices[old]-origin)
			directions.append(normals[old])
		selected.append(remap[old])
	result[Mesh.ARRAY_VERTEX] = points
	result[Mesh.ARRAY_NORMAL] = directions
	result[Mesh.ARRAY_INDEX] = selected
	return result

func prepare() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var refined := "--refined" in OS.get_cmdline_user_args()
	if refined: DirAccess.make_dir_recursive_absolute(OUT+"refined")
	var report := {}
	for id in HEIGHTS:
		var document := GLTFDocument.new(); var state := GLTFState.new()
		var error := document.append_from_file("res://art/model-sources/meshy/"+id+"-meshy6-lite.glb",state)
		assert(error==OK)
		var source := document.generate_scene(state)
		var node: MeshInstance3D = source.find_children("*","MeshInstance3D",true,false)[0]
		var mesh: Mesh = node.mesh
		var importer := ImporterMesh.new()
		for surface in range(mesh.get_surface_count()):
			var surface_tool := SurfaceTool.new()
			surface_tool.create_from(mesh,surface)
			surface_tool.generate_normals()
			importer.add_surface(Mesh.PRIMITIVE_TRIANGLES,surface_tool.commit_to_arrays())
		importer.generate_lods(60,60,[])
		var h: float = HEIGHTS[id]; var bounds := mesh.get_aabb()
		var scale_factor := h/bounds.size.y
		var center := Vector3(bounds.get_center().x,bounds.position.y,bounds.get_center().z)
		# Meshy exports face +Z; game actors face -Z.
		var turn := Basis(Vector3.UP,PI)
		var parts := {}; var total := 0; var original := 0
		for surface in range(importer.get_surface_count()):
			var arrays := importer.get_surface_arrays(surface)
			var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			original += indices.size()/3
			var target := 12000 if id=="goblin" else (28000 if h>2 else 20000)
			if refined: target = 17000 if id=="goblin" else (65000 if h>2 else 45000)
			for lod in range(importer.get_surface_lod_count(surface)):
				var candidate := importer.get_surface_lod_indices(surface,lod)
				if candidate.size()/3>=target/2 and absi(candidate.size()/3-target)<absi(indices.size()/3-target): indices = candidate
			for index in range(vertices.size()):
				vertices[index] = turn*(vertices[index]-center)*scale_factor
				normals[index] = turn*normals[index]
			if refined: normals = smooth_normals(vertices,normals,indices)
			var groups := {}
			for triangle in range(0,indices.size(),3):
				var p := (vertices[indices[triangle]]+vertices[indices[triangle+1]]+vertices[indices[triangle+2]])/3
				var part := part_at(id,p,h)
				if not groups.has(part): groups[part] = PackedInt32Array()
				var selected: PackedInt32Array = groups[part]
				selected.append_array(indices.slice(triangle,triangle+3)); groups[part] = selected
			for part in groups:
				if not parts.has(part): parts[part] = ArrayMesh.new()
				var output: ArrayMesh = parts[part]
				output.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,compact(vertices,normals,groups[part],origin_at(id,part,h)))
				total += groups[part].size()/3
		var definition := {"height":h,"triangles":total,"source_triangles":original,"parts":{}}
		for part in parts:
			var path: String = OUT+("refined/" if refined else "")+id+"-"+part+".res"
			assert(ResourceSaver.save(parts[part],path,ResourceSaver.FLAG_COMPRESS)==OK)
			definition.parts[part] = {"mesh":path,"origin":Array([origin_at(id,part,h).x,origin_at(id,part,h).y,origin_at(id,part,h).z])}
		var file := FileAccess.open(OUT+id+".json",FileAccess.WRITE)
		file.store_string(JSON.stringify(definition,"\t")); file.close()
		report[id] = {"source":original,"triangles":total}
		print(id," ",original," -> ",total)
		source.free()
	var file := FileAccess.open(OUT+"preparation-report.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t")); file.close()
	quit()

func smooth_normals(vertices: PackedVector3Array, source: PackedVector3Array, indices: PackedInt32Array) -> PackedVector3Array:
	var sums := {}
	for triangle in range(0,indices.size(),3):
		var a := indices[triangle]; var b := indices[triangle+1]; var c := indices[triangle+2]
		var face := (vertices[b]-vertices[a]).cross(vertices[c]-vertices[a])
		if face.dot(source[a])<0: face = -face
		for index in [a,b,c]:
			var key := Vector3i((vertices[index]*100000).round())
			sums[key] = sums.get(key,Vector3.ZERO)+face
	var result := source.duplicate()
	for index in range(vertices.size()):
		var key := Vector3i((vertices[index]*100000).round())
		if sums.has(key) and sums[key].length_squared()>0.0000000001:
			result[index] = sums[key].normalized()
	return result
