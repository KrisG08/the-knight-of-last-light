extends SceneTree
func _initialize() -> void:
	if not FileAccess.file_exists("res://assets/cinematics/menu_wind_desktop.ogv") or FileAccess.file_exists("res://assets/cinematics/menu_wind_mobile.ogv") or FileAccess.file_exists("res://assets/cinematics/menu_wind_loop.ogv"):
		push_error("Desktop pack must contain only its QHD menu encode"); quit(1); return
	print("Isolated Windows pack contains QHD menu without mobile/legacy films: PASS")
	quit()
