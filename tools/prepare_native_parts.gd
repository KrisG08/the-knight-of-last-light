extends SceneTree
## Offline, lossless partitioning of the credited static source meshes.
const OUTPUT := "res://assets/models/native-parts/"
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	var knight = load("res://game/presentation/scanned_knight.gd")
	var parts: Dictionary
	parts = knight.prepare_source()
	save_catalog("crusader-knight",parts)
	var hostile = load("res://game/presentation/hostile_source_parts.gd")
	for id in ["strong-knight","red-fox"]:
		parts = hostile.prepare_source(id)
		save_catalog(id,parts)
	quit()
func save_catalog(id: String, parts: Dictionary) -> void:
	var catalog := Resource.new()
	catalog.set_meta("parts",parts)
	catalog.set_meta("source","Lossless offline partition; see assets/models/native-parts/README.md")
	var result := ResourceSaver.save(catalog,OUTPUT+id+".res",ResourceSaver.FLAG_COMPRESS)
	if result != OK: push_error("Cannot save native parts: "+id); quit(1); return
	print("Prepared ",id," parts=",parts.size())
