extends SceneTree
func _initialize() -> void:
	var forests = preload("res://game/presentation/distant_forests.gd")
	forests.prepare()
	for id in forests.prototypes:
		var mesh: Mesh = forests.prototypes[id]
		var count := 0
		for surface in range(mesh.get_surface_count()): count += mesh.surface_get_arrays(surface)[Mesh.ARRAY_INDEX].size()/3
		print(id," triangles=",count," height=",mesh.get_aabb().size.y)
		assert(count<=(11000 if id.ends_with("near") else 4500))
		assert(mesh.get_aabb().size.y>0.75 and mesh.get_aabb().size.y<=1.1 and absf(mesh.get_aabb().position.y)<0.03)
	quit()
