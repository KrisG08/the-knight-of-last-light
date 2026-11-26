extends SceneTree
func _initialize() -> void:
	var snapshot=JSON.parse_string(JSON.stringify({"schema_version":8,"slot_id":1,"character":{},"campaign":{},"recovery":{}}))
	print("Loaded-save HTTP JSON: ",JSON.stringify({"p_expected_revision":0,"p_snapshot":snapshot}))
	quit()
