extends RefCounted
const L=preload("res://game/localization/localizer.gd")
const Settings=preload("res://game/settings/game_settings.gd")
static func rules(check: Callable) -> void:
	var settings=Settings.new("res://.tools/locale-settings.cfg")
	check.call(settings.set_value("language","ar") and not settings.set_value("language","invalid"),"Language preferences accept only supported codes")
	settings.save_settings()
	var loaded=Settings.new("res://.tools/locale-settings.cfg"); loaded.load_settings()
	check.call(loaded.values.language=="ar","Chosen language survives a settings reload")
	var label=Label.new()
	var picker=OptionButton.new()
	L.add_item(picker,"Journey 12 · Rank 3 · 2/5 bosses",12)
	L.set_text(label,"Continue journey")
	for code in ["bg","ru","fr","ar"]:
		L.set_locale(code)
		check.call(label.text!="Continue journey" and L.source(label)=="Continue journey","Live language switch retains English source and translates "+code)
		check.call(L.text("Rank 9 · 2/5 bosses · 67 enemy victories").contains("67"),"Dynamic progress text preserves numeric values in "+code)
		check.call(L.text("region.blackwood")=="region.blackwood","Localization leaves stable progression IDs unchanged in "+code)
		check.call(not picker.get_item_text(0).contains("Rank") and not picker.get_item_text(0).contains("bosses") and picker.get_item_id(0)==12,"Saved journey caption translates on live language change in "+code)
	var token:=RegEx.new(); token.compile("%[-+0-9.]*[sdf]")
	for file in DirAccess.get_files_at("res://assets/localization"):
		if not file.ends_with(".json"): continue
		var entries=JSON.parse_string(FileAccess.get_file_as_string("res://assets/localization/"+file))
		var valid: bool=entries is Dictionary
		if valid:
			for original in entries:
				var values=entries[original]
				valid=valid and values is Array and values.size()==4
				if not valid: break
				for value in values:
					valid=valid and value is String and not value.is_empty() and token.search_all(value).size()==token.search_all(original).size()
		check.call(valid,"Catalog has four nonempty translations with preserved format fields: "+file)
	L.set_locale("en")
	check.call(label.text=="Continue journey","English language restores the original UI text")
	label.free()
	picker.free()
