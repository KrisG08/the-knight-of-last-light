extends SceneTree
func _initialize() -> void:
	for id in ["crusader-knight","strong-knight","red-fox"]:
		var path: String = "res://assets/models/native-parts/"+id+".res"
		print("CATALOG DEPENDENCIES ",id,": ",ResourceLoader.get_dependencies(path))
	quit()
