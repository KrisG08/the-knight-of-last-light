extends SceneTree
var assertions := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, message: String) -> void:
	assertions += 1
	if not ok: failures += 1; push_error(message)
func run() -> void:
	var hostile = load("res://game/presentation/hostile_source_parts.gd")
	for id in ["strong-knight","red-fox"]:
		var runtime: Dictionary = hostile.prepare(id)
		var reference: Dictionary = hostile.prepare_source(id)
		compare(id,runtime,reference)
	var knight = load("res://game/presentation/scanned_knight.gd")
	knight.prepare()
	var reference: Dictionary = knight.prepare_source()
	compare("crusader-knight",knight.parts,reference)
	print("Native parts: %d assertions, %s" % [assertions,"PASS" if failures == 0 else "FAIL"])
	quit(0 if failures == 0 else 1)
func compare(id: String, runtime: Dictionary, reference: Dictionary) -> void:
	check(runtime.keys() == reference.keys(),"Prepared catalog preserves part order: "+id)
	for part in reference:
		var actual: ArrayMesh = runtime[part]
		var expected: ArrayMesh = reference[part]
		check(actual != expected,"Reference is independently converted from original source: "+id+"/"+part)
		check(actual.resource_path.begins_with("res://assets/models/native-parts/"),"Runtime loads a prepared mesh rather than repartitioning: "+id+"/"+part)
		check(actual.get_surface_count() == expected.get_surface_count(),"Surface count preserved: "+id+"/"+part)
		for surface in range(expected.get_surface_count()):
			check(var_to_bytes(actual.surface_get_arrays(surface)) == var_to_bytes(expected.surface_get_arrays(surface)),"All vertex/index/normal/UV/tangent arrays preserved: "+id+"/"+part)
			var a := actual.surface_get_material(surface)
			var b := expected.surface_get_material(surface)
			check(a.get_class() == b.get_class(),"Material type preserved: "+id+"/"+part)
			if a is StandardMaterial3D:
				check(a.albedo_color == b.albedo_color and a.metallic == b.metallic and a.roughness == b.roughness and a.albedo_texture.resource_path == b.albedo_texture.resource_path,"Material color/metal/roughness/texture preserved: "+id+"/"+part)
			elif a is ShaderMaterial:
				check(a.shader.resource_path == b.shader.resource_path and a.get_shader_parameter("fur_texture").resource_path == b.get_shader_parameter("fur_texture").resource_path,"Fur shader and texture preserved: "+id+"/"+part)
