extends SceneTree
func _initialize() -> void:
	create_timer(30,true).timeout.connect(func(): push_error("Platform film verification timed out"); quit(1))
	var desktop := "res://assets/cinematics/opening_film.ogv"
	var mobile := "res://assets/cinematics/opening_mobile.ogv"
	# Run from the exported folder with --main-pack, so absence checks cannot
	# fall through to an accidentally discovered source project in the cwd.
	var workspace := OS.get_cmdline_user_args()[0]
	var desktop_hash := FileAccess.get_sha256(workspace.path_join("assets/cinematics/opening_film.ogv"))
	var mobile_bytes := FileAccess.get_file_as_bytes(workspace.path_join("assets/cinematics/opening_mobile.ogv"))
	var apk := ZIPReader.new()
	assert(apk.open(workspace.path_join("build/android/LastLight.apk"))==OK)
	assert(apk.file_exists(mobile.replace("res://","assets/")))
	assert(not apk.file_exists(desktop.replace("res://","assets/")))
	assert(apk.read_file(mobile.replace("res://","assets/"))==mobile_bytes)
	apk.close()
	assert(FileAccess.file_exists(desktop) and not FileAccess.file_exists(mobile))
	assert(FileAccess.get_sha256(desktop)==desktop_hash)
	assert(load(desktop) is VideoStreamTheora)
	print("Platform films: exact desktop/mobile encode present, alternate encode excluded PASS")
	quit()
