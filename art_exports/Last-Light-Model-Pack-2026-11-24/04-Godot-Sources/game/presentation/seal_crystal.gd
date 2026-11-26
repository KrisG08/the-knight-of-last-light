extends RefCounted

const Art = preload("res://game/presentation/art_kit.gd")

static func attach(seal: Node3D, _regional_tint: Color) -> MeshInstance3D:
	var tint:=preload("res://game/presentation/curse_palette.gd").LIGHT
	seal.get_child(0).hide()
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(8):
		var a: float = index*TAU/8
		var b: float = (index+1)*TAU/8
		var upper_a := Vector3(cos(a)*0.36,0.27,sin(a)*0.36)
		var upper_b := Vector3(cos(b)*0.36,0.27,sin(b)*0.36)
		var lower_a := Vector3(cos(a)*0.25,-0.45,sin(a)*0.25)
		var lower_b := Vector3(cos(b)*0.25,-0.45,sin(b)*0.25)
		for vertex in [Vector3(0,0.9,0),upper_a,upper_b,upper_a,lower_a,upper_b,upper_b,lower_a,lower_b,Vector3(0,-0.9,0),lower_b,lower_a]:
			surface.add_vertex(vertex)
	surface.generate_normals()
	var material := Art.material("seal_crystal_"+tint.to_html(),tint,0.25)
	material.roughness = 0.3
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 0.35
	return Art.mesh(seal,surface.commit(),Vector3.ZERO,material)
