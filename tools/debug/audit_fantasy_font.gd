extends SceneTree
func _initialize() -> void:
	var font:=load("res://assets/fonts/ElMessiri.ttf") as FontFile
	var alphabet:=RegEx.new(); alphabet.compile("[\\p{L}\\p{M}]")
	var used: Dictionary={}
	for filename in DirAccess.get_files_at("res://assets/localization"):
		if not filename.ends_with(".json"): continue
		var entries=JSON.parse_string(FileAccess.get_file_as_string("res://assets/localization/"+filename))
		for source in entries:
			for phrase in [source]+entries[source]:
				for character in str(phrase):
					if alphabet.search(character)!=null: used[character]=true
	var missing: Array[String]=[]
	for character in used:
		if not font.has_char(str(character).unicode_at(0)): missing.append(character)
	print("El Messiri family: ",font.get_font_name(),"; alphabet/marks checked: ",used.size(),"; missing: ",missing)
	var ts:=TextServerManager.get_primary_interface()
	for path in ["res://assets/fonts/ui_fantasy_body.tres","res://assets/fonts/ui_fantasy_title.tres"]:
		var face:=load(path) as FontVariation
		print(path," native axis: ",ts.font_get_variation_coordinates(face.get_rids()[0]))
	quit(0 if missing.is_empty() else 1)
