extends SceneTree
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(condition: bool, description: String) -> void:
	checks+=1
	if not condition: failures+=1; push_error(description)
func run() -> void:
	await preload("res://tests/hostile_visual_checks.gd").run(self,check)
	print("HOSTILE APPEARANCE RUNTIME: ",checks," checks; failures=",failures)
	quit(0 if failures==0 else 1)
