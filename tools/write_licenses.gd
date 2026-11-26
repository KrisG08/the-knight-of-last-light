extends SceneTree

func _initialize() -> void:
	var directory := "res://build/windows"
	if not OS.get_cmdline_user_args().is_empty():
		directory = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(directory)
	var license_file := FileAccess.open(directory.path_join("GODOT_LICENSE.txt"), FileAccess.WRITE)
	license_file.store_string(Engine.get_license_text())
	license_file.close()
	var notices := FileAccess.open(directory.path_join("THIRD_PARTY_NOTICES.txt"), FileAccess.WRITE)
	notices.store_string("Godot bundled components and fonts\n\n" + JSON.stringify(Engine.get_copyright_info(), "\t") + "\n\n")
	var licenses: Dictionary = Engine.get_license_info()
	for id in licenses:
		notices.store_string("\n=== " + id + " ===\n" + licenses[id] + "\n")
	for name in ["ElMessiri","Cinzel","SourceSans3","Barlow","NotoSerif","NotoNaskhArabic"]:
		notices.store_string("\n=== " + name + " · SIL OFL 1.1 ===\n" + FileAccess.get_file_as_string("res://assets/fonts/"+name+"-OFL.txt") + "\n")
	notices.store_string("\n=== Kenney footfall source · CC0 1.0 ===\n"+FileAccess.get_file_as_string("res://assets/vendor/kenney_fps_audio/LICENSE.txt")+"\n")
	notices.store_string("\n=== Passive mythical fauna · CC BY 4.0 ===\n"+FileAccess.get_file_as_string("res://assets/vendor/mythic_fauna/LICENSE.txt")+"\n")
	notices.store_string("\n=== Meshy generated geometry · CC BY 4.0 ===\n"+FileAccess.get_file_as_string("res://assets/models/meshy/LICENSE.txt")+"\n")
	notices.close()
	quit(0)
