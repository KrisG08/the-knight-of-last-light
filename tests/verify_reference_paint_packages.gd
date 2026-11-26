extends SceneTree

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size()!=2:
		push_error("Expected Windows PCK and Android APK paths"); quit(1); return
	var ids := ["knight","oren","lyra","cael","goblin","gravedigger","maldrek","fallen-commander","iron-warden","thorn-beast"]
	var expected := {}
	var shader_path := "res://assets/materials/meshy_surface.gdshader"
	expected[shader_path]=FileAccess.get_file_as_bytes(shader_path)
	for id in ids:
		var path: String="res://assets/models/meshy/"+id+".json"
		expected[path]=FileAccess.get_file_as_bytes(path)
		var coverage: String="res://assets/models/meshy/front-uv-coverage/"+id+".res"
		expected[coverage]=FileAccess.get_file_as_bytes(coverage)
	if not ProjectSettings.load_resource_pack(ProjectSettings.globalize_path(args[0]),true):
		push_error("Cannot mount Windows PCK"); quit(1); return
	var apk := ZIPReader.new()
	if apk.open(ProjectSettings.globalize_path(args[1]))!=OK:
		push_error("Cannot read Android APK"); quit(1); return
	for path in expected:
		if expected[path].is_empty() or FileAccess.get_file_as_bytes(path)!=expected[path] or apk.read_file("assets/"+path.trim_prefix("res://"))!=expected[path]:
			push_error("Reference paint source mismatch: "+path); quit(1); return
	for view in ["front","rear"]:
		for id in ids:
			var path: String="res://assets/models/meshy/"+view+"-reference-colors/"+id+".png.import"
			var windows_descriptor := FileAccess.get_file_as_string(path)
			var android_descriptor := apk.read_file("assets/"+path.trim_prefix("res://")).get_string_from_utf8()
			var windows_data := windows_descriptor.get_slice("path=\"",1).get_slice("\"",0)
			var android_data := android_descriptor.get_slice("path=\"",1).get_slice("\"",0)
			if windows_data.is_empty() or android_data.is_empty() or FileAccess.get_file_as_bytes(windows_data).is_empty() or apk.read_file("assets/"+android_data.trim_prefix("res://")).is_empty():
				push_error("Missing platform "+view+" texture: "+id); quit(1); return
	apk.close()
	print("REFERENCE PAINT PACKAGES: current shader, ten model definitions and ten UV fields identical; all twenty front/rear textures packaged for Windows and Android: PASS")
	quit()
