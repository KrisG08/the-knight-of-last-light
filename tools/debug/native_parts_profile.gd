extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var report := {}
	var start := Time.get_ticks_usec()
	var knight = load("res://game/presentation/scanned_knight.gd")
	knight.prepare()
	report.knight_ms = float(Time.get_ticks_usec()-start)/1000
	var hostile = load("res://game/presentation/hostile_source_parts.gd")
	for id in ["strong-knight","red-fox"]:
		start = Time.get_ticks_usec()
		var parts: Dictionary = hostile.prepare(id)
		report[id] = {"ms":float(Time.get_ticks_usec()-start)/1000,"parts":parts.size()}
	print("NATIVE PARTS PROFILE ",JSON.stringify(report))
	quit()
