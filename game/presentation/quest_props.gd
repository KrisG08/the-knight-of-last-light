extends RefCounted
## Recognizable quest props attached to existing stateful owner nodes.
## Static meshes are merged by material; original nodes keep pickup/collision IDs.
const Art=preload("res://game/presentation/art_kit.gd")
const Kit=preload("res://game/presentation/village_kit.gd")
static var cache: Dictionary={}
static var leather: ShaderMaterial

static func hide_proxy(owner_node: Node3D) -> void:
	if owner_node.get_child_count()>0 and owner_node.get_child(0) is MeshInstance3D: owner_node.get_child(0).hide()

static func build(region: Node3D) -> void:
	if is_instance_valid(region.satchel): attach(region.satchel,"scout_satchel")
	if is_instance_valid(region.token): attach(region.token,"family_locket")
	if region.interact_colliders.has("memorial"): attach(region.interact_colliders.memorial,"memorial")
	if is_instance_valid(region.seal): attach(region.seal,"reliquary")

static func attach(owner_node: Node3D, kind: String) -> Node3D:
	hide_proxy(owner_node)
	var model:=Node3D.new(); model.name="Detailed_"+kind; owner_node.add_child(model)
	owner_node.set_meta("authored_prop",kind)
	if cache.has(kind):
		for part in cache[kind]: Art.mesh(model,part.mesh,Vector3.ZERO,part.material)
		return model
	match kind:
		"scout_satchel": satchel(model)
		"family_locket": locket(model)
		"memorial": memorial(model)
		"reliquary": reliquary(model)
	var groups: Dictionary={}
	collect(model,Transform3D.IDENTITY,groups)
	for child in model.get_children(): model.remove_child(child); child.queue_free()
	var parts: Array=[]
	for group in groups.values():
		var mesh: ArrayMesh=group.tool.commit()
		Art.mesh(model,mesh,Vector3.ZERO,group.material)
		parts.append({"mesh":mesh,"material":group.material})
	cache[kind]=parts
	return model

static func collect(parent: Node3D, frame: Transform3D, groups: Dictionary) -> void:
	for child in parent.get_children():
		if not child is Node3D: continue
		var transform: Transform3D=frame*child.transform
		if child is MeshInstance3D:
			for surface in range(child.mesh.get_surface_count()):
				var material: Material=child.material_override if child.material_override!=null else child.mesh.surface_get_material(surface)
				var id: int=material.get_instance_id()
				if not groups.has(id):
					var tool:=SurfaceTool.new(); tool.begin(Mesh.PRIMITIVE_TRIANGLES)
					groups[id]={"tool":tool,"material":material}
				var arrays: Array=child.mesh.surface_get_arrays(surface)
				var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
				var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
				var uv: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV] if arrays[Mesh.ARRAY_TEX_UV]!=null else PackedVector2Array()
				var indices: PackedInt32Array=arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array()
				for index in range(indices.size() if not indices.is_empty() else vertices.size()):
					var vertex: int=indices[index] if not indices.is_empty() else index
					groups[id].tool.set_normal((transform.basis.inverse().transposed()*normals[vertex]).normalized())
					groups[id].tool.set_uv(uv[vertex] if not uv.is_empty() else Vector2.ZERO)
					groups[id].tool.add_vertex(transform*vertices[vertex])
		collect(child,transform,groups)

static func hide_material() -> Material:
	if leather==null:
		leather=ShaderMaterial.new(); leather.shader=preload("res://assets/materials/quest_leather.gdshader")
	return leather

static func metal() -> Material:
	var result:=Art.material("quest_tarnished_brass",Color("c7a15c"),0.45)
	if result.albedo_texture==null:
		var source:=Art.material("iron",Color("243239"),0.75)
		result.normal_enabled=true
		result.normal_texture=source.normal_texture; result.normal_scale=0.08
		result.uv1_triplanar=true; result.uv1_scale=Vector3.ONE*3
	result.roughness=0.62
	return result

static func pouch(root: Node3D, at: Vector3, width: float, depth: float, height: float) -> void:
	var rows: Array[Vector2]=[Vector2(-0.5,0),Vector2(-0.5,0.72),Vector2(-0.40,0.96),Vector2(0.24,1),Vector2(0.46,0.88),Vector2(0.48,0)]
	var tool:=SurfaceTool.new(); tool.begin(Mesh.PRIMITIVE_TRIANGLES); tool.set_smooth_group(0)
	for row in range(rows.size()-1):
		for side in range(40):
			for corner in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
				var data: Vector2=rows[row+int(corner.y)]
				var angle: float=(side+corner.x)*TAU/40
				var x:=signf(cos(angle))*pow(absf(cos(angle)),0.42)
				var z:=signf(sin(angle))*pow(absf(sin(angle)),0.42)
				tool.set_uv(Vector2((side+corner.x)/40,(row+corner.y)/(rows.size()-1)))
				tool.add_vertex(at+Vector3(x*width*data.y*0.5,data.x*height,z*depth*data.y*0.5))
	tool.generate_normals(); Art.mesh(root,tool.commit(),Vector3.ZERO,hide_material())

static func satchel(root: Node3D) -> void:
	pouch(root,Vector3.ZERO,0.76,0.37,0.60)
	pouch(root,Vector3(0.38,-0.06,-0.02),0.16,0.24,0.32)
	var tool:=SurfaceTool.new(); tool.begin(Mesh.PRIMITIVE_TRIANGLES); tool.set_smooth_group(0)
	for row in range(12):
		for col in range(12):
			for corner in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
				var u: float=(col+corner.x)/12; var v: float=(row+corner.y)/12
				tool.set_uv(Vector2(u,v))
				tool.add_vertex(Vector3((u-0.5)*0.70*(1-v*0.08),0.28-v*0.36+sin(v*PI)*0.055,-0.03-sin(v*PI*0.5)*0.20-cos((u-0.5)*PI)*0.012))
	tool.generate_normals(); Art.mesh(root,tool.commit(),Vector3.ZERO,hide_material())
	# A broad curved shoulder strap, rather than a torus handle or thin wire.
	var strap:=SurfaceTool.new(); strap.begin(Mesh.PRIMITIVE_TRIANGLES); strap.set_smooth_group(0)
	for step in range(32):
		for corner in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
			var angle: float=(step+corner.y)*PI/32
			var across: float=(corner.x-0.5)*0.065
			strap.set_uv(Vector2(corner.x,(step+corner.y)/32))
			strap.add_vertex(Vector3(cos(angle)*(0.34+across),-0.03+sin(angle)*(0.61+across),0.12+sin(angle*2)*0.025))
	strap.generate_normals(); Art.mesh(root,strap.commit(),Vector3.ZERO,hide_material())
	var brass:=metal(); var stitches:=Art.material("quest_linen_stitches",Color("b6a27c"))
	for x in [-0.075,0.075]: Art.box(root,Vector3(x,-0.10,-0.25),Vector3(0.018,0.12,0.022),brass)
	for y in [-0.16,-0.04]: Art.box(root,Vector3(0,y,-0.25),Vector3(0.16,0.018,0.022),brass)
	Art.box(root,Vector3(0,-0.10,-0.264),Vector3(0.11,0.012,0.018),brass)
	for index in range(22):
		var x: float=-0.29+index*0.027
		Art.box(root,Vector3(x,-0.065,-0.247),Vector3(0.014,0.009,0.008),stitches).rotation.z=0.45
	for side in [-1,1]:
		for row in range(8):
			var v: float=0.12+row*0.11
			var u: float=0.055 if side==-1 else 0.945
			var seam:=Vector3((u-0.5)*0.70*(1-v*0.08),0.28-v*0.36+sin(v*PI)*0.055,-0.036-sin(v*PI*0.5)*0.20-cos((u-0.5)*PI)*0.012)
			Art.box(root,seam,Vector3(0.012,0.016,0.008),stitches)
	var parchment:=Art.material("quest_rolled_parchment",Color("b3a286"))
	var roll:=Art.cylinder(root,Vector3(-0.18,0.35,0.12),0.075,0.075,0.62,parchment,20); roll.rotation.z=PI/2
	for x in [-0.32,0.03]:
		var tie:=Art.cylinder(root,Vector3(x,0.35,0.12),0.079,0.079,0.035,hide_material(),16); tie.rotation.z=PI/2

static func locket(root: Node3D) -> void:
	var brass:=metal()
	Art.cylinder(root,Vector3(0,-0.34,0),0.18,0.18,0.045,brass,32)
	var ring:=TorusMesh.new(); ring.inner_radius=0.145; ring.outer_radius=0.177; ring.rings=40; ring.ring_segments=8
	Art.mesh(root,ring,Vector3(0,-0.309,0),brass)
	var inset:=Art.material("locket_enamel",Color("283e3b"),0.2)
	Art.cylinder(root,Vector3(0,-0.309,0),0.14,0.14,0.008,inset,32)
	# Embossed branching tree and open hinged lid identify a family keepsake.
	Art.beam(root,Vector3(0,-0.295,0.09),Vector3(0,-0.295,-0.10),0.008,brass)
	for side in [-1,1]:
		for row in range(3): Art.beam(root,Vector3(0,-0.295,0.03-row*0.05),Vector3(side*(0.07-row*0.012),-0.295,-0.015-row*0.04),0.006,brass)
	var lid:=Node3D.new(); lid.position=Vector3(0,-0.34,0.18); lid.rotation.x=-0.65; root.add_child(lid)
	Art.cylinder(lid,Vector3(0,0,0.16),0.17,0.17,0.025,brass,32)
	for index in range(28):
		var loop:=TorusMesh.new(); loop.inner_radius=0.017; loop.outer_radius=0.024; loop.rings=10; loop.ring_segments=6
		var angle: float=index*TAU/28
		var link:=Art.mesh(root,loop,Vector3(sin(angle)*0.20,-0.33,0.35+cos(angle)*0.12),brass)
		link.rotation.z=(index%2)*0.8

static func memorial(root: Node3D) -> void:
	var stone:=Art.stone()
	Art.cylinder(root,Vector3(0,-0.88,0),0.72,0.68,0.22,stone,16)
	var outline: Array[Vector2]=[Vector2(-0.48,-0.77),Vector2(0.48,-0.77),Vector2(0.48,0.65),Vector2(0.3,1.0),Vector2(0,1.2),Vector2(-0.3,1.0),Vector2(-0.48,0.65)]
	var tool:=SurfaceTool.new(); tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(outline.size()):
		var a: Vector2=outline[index]; var b: Vector2=outline[(index+1)%outline.size()]
		for v in [Vector3(0,0,-0.2),Vector3(a.x,a.y,-0.2),Vector3(b.x,b.y,-0.2),Vector3(0,0,0.2),Vector3(b.x,b.y,0.2),Vector3(a.x,a.y,0.2),Vector3(a.x,a.y,-0.2),Vector3(a.x,a.y,0.2),Vector3(b.x,b.y,0.2),Vector3(a.x,a.y,-0.2),Vector3(b.x,b.y,0.2),Vector3(b.x,b.y,-0.2)]: tool.set_uv(Vector2(v.x,v.y)); tool.add_vertex(v)
	tool.generate_normals(); Art.mesh(root,tool.commit(),Vector3.ZERO,stone)
	var carving:=Art.material("memorial_incisions",Color("333e40"))
	for row in range(6): Art.box(root,Vector3(0,0.15-row*0.095,-0.204),Vector3(0.57-(row%3)*0.07,0.018,0.008),carving)
	var sun:=TorusMesh.new(); sun.inner_radius=0.12; sun.outer_radius=0.15; sun.rings=24; sun.ring_segments=6
	Art.mesh(root,sun,Vector3(0,0.68,-0.22),metal()).rotation.x=PI/2
	for index in range(8):
		var a: float=index*TAU/8
		Art.beam(root,Vector3(sin(a)*0.18,0.68+cos(a)*0.18,-0.22),Vector3(sin(a)*0.24,0.68+cos(a)*0.24,-0.22),0.012,metal())

static func reliquary(root: Node3D) -> void:
	var brass:=metal()
	var ring:=TorusMesh.new(); ring.inner_radius=0.33; ring.outer_radius=0.38; ring.rings=32; ring.ring_segments=8
	Art.mesh(root,ring,Vector3(0,-0.68,0),brass)
	for index in range(6):
		var angle: float=index*TAU/6
		var base:=Vector3(sin(angle)*0.31,-0.70,cos(angle)*0.31)
		var tip:=Vector3(sin(angle)*0.52,-0.06,cos(angle)*0.52)
		Art.beam(root,base,tip,0.025,brass)
		Art.beam(root,tip,tip+Vector3(-sin(angle)*0.11,0.18,-cos(angle)*0.11),0.018,brass)
