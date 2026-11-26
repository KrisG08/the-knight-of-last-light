extends SceneTree
# Editor-only diagnostic: standard export templates ignore external --script.
# Use the game's built-in --benchmark workload for actual release EXEs.
func _initialize() -> void:
	print("RELEASE PROBE READY pid=",OS.get_process_id()," editor=",OS.has_feature("editor"))
	quit()
