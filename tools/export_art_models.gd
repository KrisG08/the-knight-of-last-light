extends SceneTree
const Art = preload("res://game/presentation/art_kit.gd")
const Knight = preload("res://game/presentation/knight_model.gd")
const Dressing = preload("res://game/presentation/ruin_dressing.gd")

func _initialize() -> void:
	call_deferred("export_models")

func export_models() -> void:
	for id in ["knight_v2","gothic_lantern","gothic_arch","dead_tree"]:
		var model := Node3D.new()
		model.name = id
		root.add_child(model)
		match id:
			"knight_v2":
				var pivot := Node3D.new()
				pivot.position.y = 1
				model.add_child(pivot)
				Knight.build(model,pivot)
			"gothic_lantern": Art.lantern(model,Vector3.ZERO)
			"gothic_arch": Art.pointed_arch(model,Vector3.ZERO,6,8)
			"dead_tree": Dressing.tree(model,Vector3.ZERO,1)
		var document := GLTFDocument.new()
		var state := GLTFState.new()
		var path: String = "res://art_exports/"+id+".glb"
		if document.append_from_scene(model,state) != OK or document.write_to_filesystem(state,path) != OK:
			push_error("Cannot export "+id)
			quit(1)
			return
		var imported := GLTFState.new()
		if document.append_from_file(path,imported) != OK:
			push_error("Export cannot be read back: "+id)
			quit(1)
			return
		var restored := document.generate_scene(imported)
		if restored == null or restored.find_children("*","MeshInstance3D",true,false).is_empty():
			push_error("Export is missing meshes: "+id)
			quit(1)
			return
		restored.free()
		model.queue_free()
		print("GLB round-trip PASS: ",path)
	quit(0)
