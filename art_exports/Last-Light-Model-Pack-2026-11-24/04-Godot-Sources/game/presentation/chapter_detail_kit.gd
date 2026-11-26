extends RefCounted
## Shared authored props. Builders add visual children, never gameplay state.
const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")
const Assets = preload("res://game/presentation/real_assets.gd")

static func ground(region: Node3D, routes: Array, biome: int) -> void:
	var material := ShaderMaterial.new()
	material.shader = preload("res://assets/materials/chapter_ground.gdshader")
	material.set_shader_parameter("soil_color",load("res://assets/vendor/polyhaven/forest_ground_04/Diffuse.jpg"))
	material.set_shader_parameter("soil_normal",load("res://assets/vendor/polyhaven/forest_ground_04/nor_gl.jpg"))
	material.set_shader_parameter("stone_color",Art.stone().albedo_texture)
	material.set_shader_parameter("biome",biome)
	var segments := PackedVector4Array()
	for route in routes:
		for index in range(1,route.size()):
			segments.append(Vector4(route[index-1].x,route[index-1].z,route[index].x,route[index].z))
	material.set_shader_parameter("path_count",mini(segments.size(),24))
	segments.resize(24)
	material.set_shader_parameter("paths",segments)
	for child in region.get_children():
		if child is StaticBody3D and child.position.y<0 and child.position.y>-1 and child.get_child_count()>0:
			var visual = child.get_child(0)
			if visual is MeshInstance3D and visual.mesh is BoxMesh and visual.mesh.size.x>10:
				visual.material_override = material
		elif child is Node3D and child.position.y>=0 and child.position.y<0.05 and child.get_child_count()>0:
			var visual = child.get_child(0)
			if visual is MeshInstance3D and visual.mesh is BoxMesh and visual.mesh.size.y<0.1:
				visual.hide() # Flat graybox road strips are replaced by blended soil.

static func fern_mesh() -> Mesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for frond in range(7):
		var angle: float = frond*TAU/7
		for leaf in range(6):
			var t: float = float(leaf)/6
			var stem := Vector3(0,0.1+sin(t*PI)*0.28,t*0.65).rotated(Vector3.UP,angle)
			for side in [-1,1]:
				var tip := stem+Vector3(side*(0.18-t*0.12),-0.02,0.11).rotated(Vector3.UP,angle)
				var middle := stem.lerp(tip,0.5)
				var width := Vector3(0,0.018,0.033).rotated(Vector3.UP,angle)
				for vertex in [stem,middle-width,tip,stem,tip,middle+width]:
					surface.add_vertex(vertex)
	surface.generate_normals()
	return surface.commit()

static func vegetation(region: Node3D, root: Node3D, routes: Array, bounds: Rect2, seed_value: int, dry := false) -> void:
	var random := RandomNumberGenerator.new()
	random.seed = seed_value
	var transforms: Array[Transform3D] = []
	for index in range(clampi(int(bounds.get_area()/8.0),50,650)):
		var at := Vector3(random.randf_range(bounds.position.x,bounds.end.x),0.025,random.randf_range(bounds.position.y,bounds.end.y))
		if not clear_of_routes(region,at,routes,2.6): continue
		var scale: float = random.randf_range(0.55,1.05)
		transforms.append(Transform3D(Basis(Vector3.UP,random.randf()*TAU).scaled(Vector3.ONE*scale),at))
	var material := Art.material("chapter_fern_dry" if dry else "chapter_fern",Color("665f48") if dry else Color("405a39"))
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	Dressing.instances(root,fern_mesh(),material,transforms)

static func clear_of_routes(region: Node3D, at: Vector3, routes: Array, radius: float) -> bool:
	for point in region.points.values():
		if at.distance_to(point)<3: return false
	for obstacle in region.obstacles:
		if obstacle.has_point(Vector2(at.x,at.z)): return false
	for route in routes:
		for index in range(1,route.size()):
			var nearest := Geometry3D.get_closest_point_to_segment(at,route[index-1],route[index])
			if at.distance_to(nearest)<radius: return false
	return true

static func crate(root: Node3D, at: Vector3, size := Vector3.ONE) -> void:
	var batches: Dictionary = {}
	Kit.piece(batches,Kit.wood(),at+Vector3.UP*size.y*0.5,size*0.94)
	for side in [-1,1]:
		for y in [0.1,size.y-0.1]:
			Kit.piece(batches,Kit.wood(),at+Vector3(0,y,side*size.z*0.49),Vector3(size.x,0.1,0.08))
		for x in [-size.x*0.43,size.x*0.43]:
			Kit.piece(batches,Kit.wood(),at+Vector3(x,size.y*0.5,side*size.z*0.49),Vector3(0.1,size.y,0.08))
		Kit.beam(batches,at+Vector3(-size.x*0.4,0.12,side*size.z*0.51),at+Vector3(size.x*0.4,size.y-0.12,side*size.z*0.51),0.08)
	Kit.flush(root,batches)

static func barrel(root: Node3D, at: Vector3, scale := 1.0) -> void:
	Art.cylinder(root,at+Vector3.UP*0.48*scale,0.35*scale,0.35*scale,0.96*scale,Kit.wood(),16)
	var iron := Art.material("barrel_hoop",Color("393d40"),0.6)
	for y in [0.1,0.3,0.7,0.88]:
		var ring := TorusMesh.new()
		ring.inner_radius = 0.34*scale
		ring.outer_radius = 0.37*scale
		ring.rings = 16
		ring.ring_segments = 6
		Art.mesh(root,ring,at+Vector3.UP*y*scale,iron)

static func niche(root: Node3D, at: Vector3, yaw: float, tint: Color, height := 4.2) -> void:
	var face := Node3D.new()
	face.position = at
	face.rotation.y = yaw
	root.add_child(face)
	var dark := Art.material("alcove_shadow",Color("171e27"))
	Art.box(face,Vector3(0,height*0.45,0),Vector3(1.65,height*0.9,0.025),dark)
	Art.pointed_arch(face,Vector3(0,0,0.07),1.85,height)
	var glass := Art.material("chapter_glass_"+tint.to_html(),tint,0.1)
	glass.emission_enabled = true
	glass.emission = tint
	glass.emission_energy_multiplier = 0.35
	var shards: Array[Transform3D] = []
	for row in range(7):
		for column in [-1,0,1]:
			var basis := Basis(Vector3.BACK,PI if (row+column)%2==0 else 0.0)
			shards.append(Transform3D(basis,Vector3(column*0.43,0.5+row*height*0.1,0.045)))
	var shard := PrismMesh.new()
	shard.size = Vector3(0.38,0.36,0.025)
	Dressing.instances(face,shard,glass,shards)
	for y in [0.3,height*0.45,height*0.85]:
		Art.box(face,Vector3(0,y,0.11),Vector3(1.7,0.055,0.07),Art.material("iron",Color("303b43"),0.65))

static func banner(root: Node3D, at: Vector3, yaw: float, tint: Color, length := 2.8) -> void:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for vertex in [Vector3(-0.7,0,0),Vector3(0.7,0,0),Vector3(-0.7,-length+0.3,0),Vector3(0.7,0,0),Vector3(0.7,-length+0.3,0),Vector3(-0.7,-length+0.3,0),Vector3(-0.7,-length+0.3,0),Vector3(0.7,-length+0.3,0),Vector3(0,-length,0)]:
		surface.set_uv(Vector2(vertex.x+0.7,-vertex.y)/Vector2(1.4,length))
		surface.add_vertex(vertex)
	surface.generate_normals()
	var cloth := ShaderMaterial.new()
	cloth.shader = preload("res://assets/materials/weathered_canvas.gdshader")
	cloth.set_shader_parameter("cloth_color",tint)
	var face := Node3D.new()
	face.position = at
	face.rotation.y = yaw
	root.add_child(face)
	Art.mesh(face,surface.commit(),Vector3.ZERO,cloth)
	Art.beam(face,Vector3(-0.9,0.05,0),Vector3(0.9,0.05,0),0.045,Kit.wood())
