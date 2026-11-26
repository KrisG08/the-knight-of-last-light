extends SceneTree
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var apk := ZIPReader.new()
	var apk_path: String=args[1] if args.size()>1 else "res://build/android/LastLight.apk"
	if apk.open(apk_path) != OK:
		push_error("Cannot read Android package"); quit(1); return
	var path := ProjectSettings.globalize_path(args[0] if args.size()>0 else "res://build/windows-v05/LastLight.pck")
	# Platform openings use different resolutions but must both match the current encodes.
	var desktop_opening:=FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://assets/cinematics/opening_film.ogv"))
	var mobile_opening:=FileAccess.get_file_as_bytes(ProjectSettings.globalize_path("res://assets/cinematics/opening_mobile.ogv"))
	var face_path:="res://assets/materials/menu_moon_face.gdshader"
	var expected_face:=FileAccess.get_file_as_bytes(face_path)
	var cloud_path:="res://assets/materials/menu_moon_clouds.gdshader"
	var expected_clouds:=FileAccess.get_file_as_bytes(cloud_path)
	var title_path:="res://assets/materials/title_enchantment.gdshader"
	var expected_title:=FileAccess.get_file_as_bytes(title_path)
	var sky_path:="res://assets/materials/storm_sky.gdshader"
	var expected_sky:=FileAccess.get_file_as_bytes(sky_path)
	var license_path:="res://assets/fonts/ElMessiri-OFL.txt"
	var expected_font_license:=FileAccess.get_file_as_bytes(license_path)
	var desktop_menu_path:="res://assets/cinematics/menu_wind_desktop.ogv"
	var phone_menu_path:="res://assets/cinematics/menu_wind_mobile.ogv"
	var expected_desktop_menu:=FileAccess.get_file_as_bytes(desktop_menu_path)
	var expected_phone_menu:=FileAccess.get_file_as_bytes(phone_menu_path)
	var voice_manifest_path:="res://assets/audio/voice/manifest.json"
	var expected_voice_manifest:=FileAccess.get_file_as_bytes(voice_manifest_path) if FileAccess.file_exists(voice_manifest_path) else PackedByteArray()
	var opening_score_descriptor:=FileAccess.get_file_as_string("res://assets/cinematics/opening_score.ogg.import")
	var opening_score_path:=opening_score_descriptor.get_slice("path=\"",1).get_slice("\"",0)
	var expected_opening_score:=FileAccess.get_file_as_bytes(opening_score_path) if not opening_score_path.is_empty() else PackedByteArray()
	if not ProjectSettings.load_resource_pack(path,true):
		push_error("Cannot mount Windows package"); quit(1); return
	if desktop_opening.is_empty() or mobile_opening.is_empty() or FileAccess.get_file_as_bytes("res://assets/cinematics/opening_film.ogv")!=desktop_opening:
		push_error("Windows opening differs from current rendered film"); quit(1); return
	if apk.read_file("assets/assets/cinematics/opening_mobile.ogv")!=mobile_opening or apk.file_exists("assets/assets/cinematics/opening_film.ogv"):
		push_error("Android opening missing, outdated or includes desktop encode"); quit(1); return
	print("Windows / Android current platform opening encodes packaged: PASS")
	if expected_opening_score.is_empty() or FileAccess.get_file_as_bytes(opening_score_path)!=expected_opening_score or apk.read_file("assets/"+opening_score_path.trim_prefix("res://"))!=expected_opening_score:
		push_error("Independent opening score missing or different across platforms"); quit(1); return
	print("Windows / Android independent opening score identical: PASS")
	if expected_desktop_menu.is_empty() or expected_phone_menu.is_empty() or FileAccess.get_file_as_bytes(desktop_menu_path)!=expected_desktop_menu or apk.read_file("assets/"+phone_menu_path.trim_prefix("res://"))!=expected_phone_menu or apk.file_exists("assets/"+desktop_menu_path.trim_prefix("res://")):
		push_error("Current platform-specific high-resolution menu film missing or mismatched"); quit(1); return
	print("Windows QHD / Android Full HD menu films match current encodes: PASS")
	if expected_face.is_empty() or FileAccess.get_file_as_bytes(face_path)!=expected_face or apk.read_file("assets/"+face_path.trim_prefix("res://"))!=expected_face:
		push_error("Current animated moon face shader missing or outdated in platform packages"); quit(1); return
	print("Windows / Android current animated moon face shader identical: PASS")
	if expected_sky.is_empty() or FileAccess.get_file_as_bytes(sky_path)!=expected_sky or apk.read_file("assets/"+sky_path.trim_prefix("res://"))!=expected_sky:
		push_error("Current violet world sky shader missing or outdated in platform packages"); quit(1); return
	print("Windows / Android violet world sky shader identical: PASS")
	if expected_clouds.is_empty() or FileAccess.get_file_as_bytes(cloud_path)!=expected_clouds or apk.read_file("assets/"+cloud_path.trim_prefix("res://"))!=expected_clouds:
		push_error("Current foreground cloud shader missing or outdated in platform packages"); quit(1); return
	print("Windows / Android foreground cloud shader identical: PASS")
	if expected_title.is_empty() or FileAccess.get_file_as_bytes(title_path)!=expected_title or apk.read_file("assets/"+title_path.trim_prefix("res://"))!=expected_title:
		push_error("Current title effect missing or outdated in platform packages"); quit(1); return
	if expected_font_license.is_empty() or FileAccess.get_file_as_bytes(license_path)!=expected_font_license or apk.read_file("assets/"+license_path.trim_prefix("res://"))!=expected_font_license:
		push_error("El Messiri license missing or outdated in platform packages"); quit(1); return
	var font_import:="res://assets/fonts/ElMessiri.ttf.import"
	var font_descriptor:=FileAccess.get_file_as_string(font_import)
	var font_data:=font_descriptor.get_slice("path=\"",1).get_slice("\"",0)
	if font_data.is_empty() or not FileAccess.file_exists(font_data) or not apk.file_exists("assets/"+font_data.trim_prefix("res://")) or apk.read_file("assets/"+font_data.trim_prefix("res://"))!=FileAccess.get_file_as_bytes(font_data):
		push_error("Shared El Messiri font data missing or different across platforms"); quit(1); return
	print("Windows / Android shared El Messiri font, OFL and animated title identical: PASS")
	for theme in ["menu", "exploration", "combat", "boss", "dawn"]:
		var descriptor_path: String = "res://assets/audio/music/"+theme+".ogg.import"
		var descriptor := FileAccess.get_file_as_string(descriptor_path)
		var data_path := descriptor.get_slice("path=\"",1).get_slice("\"",0)
		if data_path.is_empty() or not FileAccess.file_exists(data_path) or apk.read_file("assets/"+data_path.trim_prefix("res://")) != FileAccess.get_file_as_bytes(data_path):
			push_error("Missing or mismatched score: "+theme); quit(1); return
	print("Windows / Android five streaming music tracks identical: PASS")
	if not expected_voice_manifest.is_empty():
		if FileAccess.get_file_as_bytes(voice_manifest_path)!=expected_voice_manifest or apk.read_file("assets/"+voice_manifest_path.trim_prefix("res://"))!=expected_voice_manifest:
			push_error("Localized speech manifest missing or outdated"); quit(1); return
		var voice_manifest: Dictionary=JSON.parse_string(expected_voice_manifest.get_string_from_utf8())
		var voice_count:=0
		for entry in voice_manifest.lines.values():
			for code in ["en","bg","ru","fr","ar"]:
				var clip_path: String=entry.clips.get(code,"")
				var descriptor:=FileAccess.get_file_as_string(clip_path+".import")
				var data_path:=descriptor.get_slice("path=\"",1).get_slice("\"",0)
				if data_path.is_empty() or not FileAccess.file_exists(data_path) or apk.read_file("assets/"+data_path.trim_prefix("res://"))!=FileAccess.get_file_as_bytes(data_path):
					push_error("Missing or mismatched localized voice: "+clip_path); quit(1); return
				voice_count+=1
		if voice_count<185:
			push_error("Localized speech coverage is incomplete"); quit(1); return
		print("Windows / Android five-language voice clips identical: ",voice_count," PASS")
	for model in ["crusader-knight","strong-knight","red-fox"]:
		var part_path: String = "res://assets/models/native-parts/"+model+".res"
		if not FileAccess.file_exists(part_path) or apk.read_file("assets/"+part_path.trim_prefix("res://")) != FileAccess.get_file_as_bytes(part_path):
			push_error("Missing or mismatched native parts: "+model); quit(1); return
	print("Windows / Android lossless native mesh catalogs identical: PASS")
	var count := 0
	var model_count := 0
	var catalog_count := 0
	var grade_count := 0
	var flame_count := 0
	var stone_count := 0
	var waygate_count := 0
	var character_shader_count:=0
	for entry in apk.get_files():
		if entry in ["assets/assets/materials/quest_leather.gdshader","assets/assets/materials/meshy_surface.gdshader"]:
			var source_path: String="res://"+entry.trim_prefix("assets/")
			if not FileAccess.file_exists(source_path) or apk.read_file(entry)!=FileAccess.get_file_as_bytes(source_path):
				push_error("Character/quest materials differ between platforms"); quit(1); return
			character_shader_count+=1
		if entry in ["assets/assets/materials/waygate_vortex.gdshader","assets/assets/materials/waygate_filament.gdshader"]:
			var shader_path: String="res://"+entry.trim_prefix("assets/")
			if not FileAccess.file_exists(shader_path) or apk.read_file(entry)!=FileAccess.get_file_as_bytes(shader_path):
				push_error("Platform waygate shaders differ"); quit(1); return
			waygate_count+=1
		if entry=="assets/assets/ui/cursed-stone/basalt-v1.png.import":
			var import_path:="res://assets/ui/cursed-stone/basalt-v1.png.import"
			if not FileAccess.file_exists(import_path):
				push_error("Windows basalt material import missing"); quit(1); return
			var descriptor:=apk.read_file(entry).get_string_from_utf8()
			var android_texture:=descriptor.get_slice("path=\"",1).get_slice("\"",0)
			if android_texture.is_empty() or not apk.file_exists("assets/"+android_texture.trim_prefix("res://")):
				push_error("Android basalt material texture missing"); quit(1); return
			stone_count+=1
		if entry=="assets/assets/materials/torch_flame.gdshader":
			var flame_path:="res://assets/materials/torch_flame.gdshader"
			if not FileAccess.file_exists(flame_path) or apk.read_file(entry)!=FileAccess.get_file_as_bytes(flame_path):
				push_error("Platform torch shaders differ"); quit(1); return
			flame_count+=1
		if entry=="assets/assets/materials/menu_film_grade.gdshader":
			var grade_path:="res://assets/materials/menu_film_grade.gdshader"
			if not FileAccess.file_exists(grade_path) or apk.read_file(entry)!=FileAccess.get_file_as_bytes(grade_path):
				push_error("Platform menu grading shaders differ"); quit(1); return
			grade_count+=1
		if entry.begins_with("assets/assets/localization/") and entry.ends_with(".json") or entry=="assets/game/cloud/cloud_config.json":
			var data_path := "res://"+entry.trim_prefix("assets/")
			if not FileAccess.file_exists(data_path) or apk.read_file(entry)!=FileAccess.get_file_as_bytes(data_path):
				push_error("Platform locale/cloud configuration differs: "+entry); quit(1); return
			catalog_count+=1
		if entry.begins_with("assets/assets/models/meshy/"):
			# Texture import remaps select S3TC on Windows and ETC2 on Android.
			if entry.ends_with(".png.import"): continue
			var resource_path := "res://"+entry.trim_prefix("assets/")
			if not FileAccess.file_exists(resource_path) or apk.read_file(entry)!=FileAccess.get_file_as_bytes(resource_path):
				push_error("Platform character resource differs: "+entry); quit(1); return
			model_count += 1
		if not entry.begins_with("assets/game/") or not entry.ends_with(".gdc"): continue
		var windows_path := "res://"+entry.trim_prefix("assets/")
		if not FileAccess.file_exists(windows_path) or apk.read_file(entry) != FileAccess.get_file_as_bytes(windows_path):
			push_error("Platform game script differs: "+entry); quit(1); return
		count += 1
	apk.close()
	if character_shader_count!=2:
		push_error("Character/quest shaders missing from platform packages"); quit(1); return
	print("Windows / Android character and quest shaders identical: PASS")
	if count == 0:
		push_error("No compiled game scripts compared"); quit(1); return
	print("Windows / Android compiled game scripts identical: %d PASS" % count)
	if waygate_count!=2:
		push_error("Waygate shaders missing from platform packages"); quit(1); return
	print("Windows / Android animated waygate shaders identical: PASS")
	if stone_count!=1:
		push_error("Cursed basalt interface material missing"); quit(1); return
	print("Windows / Android cursed basalt UI material packaged: PASS")
	if model_count<50:
		push_error("Missing prepared character resources in platform packages"); quit(1); return
	print("Windows / Android prepared character resources identical: %d PASS" % model_count)
	if catalog_count<3:
		push_error("Missing packaged translations or cloud configuration"); quit(1); return
	print("Windows / Android locale/cloud configuration identical: %d PASS" % catalog_count)
	if FileAccess.file_exists("res://assets/materials/menu_film_grade.gdshader"):
		if grade_count!=1:
			push_error("Android menu grading shader missing"); quit(1); return
		print("Windows / Android menu grading shader identical: PASS")
	if FileAccess.file_exists("res://assets/materials/torch_flame.gdshader"):
		if flame_count!=1:
			push_error("Android torch shader missing"); quit(1); return
		print("Windows / Android elevation-safe torch shader identical: PASS")
	quit()
