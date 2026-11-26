extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")

static func build(parent: Node3D, half_width: float, half_length: float, spring_height: float, rise: float) -> MeshInstance3D:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(32):
		var a: float = float(index)/32*PI
		var b: float = float(index+1)/32*PI
		var left := Vector3(cos(a)*half_width,spring_height+sin(a)*rise,0)
		var right := Vector3(cos(b)*half_width,spring_height+sin(b)*rise,0)
		for vertex in [left+Vector3(0,0,-half_length),right+Vector3(0,0,-half_length),left+Vector3(0,0,half_length),right+Vector3(0,0,-half_length),right+Vector3(0,0,half_length),left+Vector3(0,0,half_length)]:
			surface.set_uv(Vector2(vertex.x,vertex.z)*0.25)
			surface.add_vertex(vertex)
		for z in [-half_length,half_length]:
			for vertex in [Vector3(left.x,spring_height,z),Vector3(left.x,left.y,z),Vector3(right.x,right.y,z),Vector3(left.x,spring_height,z),Vector3(right.x,right.y,z),Vector3(right.x,spring_height,z)]:
				surface.set_uv(Vector2(vertex.x,vertex.y)*0.25)
				surface.add_vertex(vertex)
	surface.generate_normals()
	var material := Art.stone().duplicate() as StandardMaterial3D
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return Art.mesh(parent,surface.commit(),Vector3.ZERO,material)
