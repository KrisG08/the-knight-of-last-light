extends SceneTree
var assertions:=0
var failures:=0
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	await preload("res://tests/cloud_checks.gd").run(self,check)
	print("Cloud replica regression: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
