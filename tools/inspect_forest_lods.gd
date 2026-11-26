extends SceneTree
func _initialize() -> void:
	var source = load("res://assets/vendor/polyhaven/pine_sapling_small/pine_sapling_small.gltf").instantiate()
	for node in source.find_children("*","MeshInstance3D",true,false):
		for index in range(node.mesh.get_surface_count()):
			var data := RenderingServer.mesh_get_surface(node.mesh.get_rid(),index)
			var lods: Array = data.get("lods",[])
			var report: Array = []
			for lod in lods:
				report.append({"edge_length":lod.get("edge_length"),"index_bytes":lod.get("index_data",PackedByteArray()).size()})
			print(node.name," surface ",index," vertices=",data.get("vertex_count")," indices=",data.get("index_count")," lods=",report)
	source.free()
	quit()
