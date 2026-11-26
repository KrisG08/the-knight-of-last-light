extends RefCounted
## Presentation adapter. Saves, rule IDs and user-entered data stay untranslated.
const LANGUAGES = {"en":"English","bg":"Български","ru":"Русский","fr":"Français","ar":"العربية"}
const CODES = ["bg","ru","fr","ar"]
static var initialized := false
static var language := "en"
static var tables: Dictionary = {}
static var templates: Array[Dictionary] = []
static var bindings: Dictionary = {}
static var combos: Dictionary = {}
static var cache: Dictionary = {}

static func setup() -> void:
	if initialized: return
	initialized=true
	for code in CODES: tables[code]={}
	var filenames:=DirAccess.get_files_at("res://assets/localization")
	filenames.sort()
	for filename in filenames:
		if not filename.ends_with(".json"): continue
		var entries = JSON.parse_string(FileAccess.get_file_as_string("res://assets/localization/"+filename))
		if not entries is Dictionary: continue
		for original in entries:
			var values = entries[original]
			if not values is Array or values.size()!=4: continue
			for index in range(4):
				var target: String=values[index]
				tables[CODES[index]][original]=target
				tables[CODES[index]][original.to_upper()]=target.to_upper()
				tables[CODES[index]][original.to_lower()]=target.to_lower()
			if original.contains("%"):
				var pattern := RegEx.new()
				pattern.compile("%[-+0-9.]*[sdf]")
				var parts := pattern.search_all(original)
				if parts.is_empty() or original.length()<5: continue
				var expression := "^"; var offset := 0
				for part in parts:
					expression+=escape(original.substr(offset,part.get_start()-offset))
					expression+="(.+?)" if part.get_string().ends_with("s") else "(-?[0-9]+(?:\\.[0-9]+)?)"
					offset=part.get_end()
				expression+=escape(original.substr(offset))+"$"
				var matcher := RegEx.new()
				if matcher.compile(expression)==OK: templates.append({"source":original,"regex":matcher,"spec":pattern})
	templates.sort_custom(func(a,b): return a.source.length()>b.source.length())

static func escape(value: String) -> String:
	var result := value
	for character in ["\\",".","+","*","?","^","$","(",")","[","]","{","}","|"]:
		result=result.replace(character,"\\"+character)
	return result

static func text(original: String, depth: int=0) -> String:
	setup()
	if language=="en" or original.is_empty() or depth>5: return original
	if tables[language].has(original): return tables[language][original]
	var stripped := original.strip_edges()
	if not stripped.is_empty() and stripped!=original:
		return original.replace(stripped,text(stripped,depth+1))
	if cache.has(original): return cache[original]
	var result := original
	for entry in templates:
		var match_value: RegExMatch=entry.regex.search(original)
		if match_value==null: continue
		var target: String=tables[language][entry.source]
		var parameters: Array=[]
		for index in range(1,match_value.get_group_count()+1): parameters.append(text(match_value.get_string(index),depth+1))
		target=entry.spec.sub(target,"%s",true)
		result=target%parameters
		break
	if result==original:
		for delimiter in ["\n"," · "]:
			if not original.contains(delimiter): continue
			var parts: PackedStringArray=[]
			for part in original.split(delimiter): parts.append(text(part,depth+1))
			result=delimiter.join(parts)
			break
	if cache.size()>4096: cache.clear()
	cache[original]=result
	return result

static func set_text(node: Node, original: String, translate_value: bool=true) -> void:
	if not is_instance_valid(node): return
	bindings[node.get_instance_id()]={"node":weakref(node),"source":original,"translate":translate_value}
	node.auto_translate_mode=Node.AUTO_TRANSLATE_MODE_DISABLED
	var translated := text(original) if translate_value else original
	if node.text!=translated: node.text=translated

static func source(node: Node) -> String:
	return bindings.get(node.get_instance_id(),{}).get("source",node.text)

static func append_text(node: Node, suffix: String) -> void:
	set_text(node,source(node)+suffix)

static func add_item(node: OptionButton, original: String, id: int=-1) -> void:
	var key := node.get_instance_id()
	if node.item_count==0: combos[key]={"node":weakref(node),"items":{}}
	if not combos.has(key): combos[key]={"node":weakref(node),"items":{}}
	combos[key].items[node.item_count]=original
	node.add_item(text(original),id)

static func set_locale(code: String) -> void:
	setup(); language=code if LANGUAGES.has(code) else "en"
	cache.clear(); TranslationServer.set_locale(language)
	var face = preload("res://game/presentation/ui_style.gd").font()
	for key in bindings.keys():
		var entry: Dictionary=bindings[key]
		var node: Node=entry.node.get_ref()
		if not is_instance_valid(node): bindings.erase(key); continue
		node.text=text(entry.source) if entry.get("translate",true) else entry.source
		if node is Label3D: node.font=face
		elif node is Control:
			node.layout_direction=Control.LAYOUT_DIRECTION_LOCALE
			if node.has_theme_font_override("font"):
				var chosen=preload("res://game/presentation/ui_style.gd").title_font() if node.get_meta("font_role","body")=="title" else face
				node.add_theme_font_override("font",chosen)
	for key in combos.keys():
		var entry: Dictionary=combos[key]
		var node=entry.node.get_ref()
		if not is_instance_valid(node): combos.erase(key); continue
		for index in entry.items:
			if index<node.item_count: node.set_item_text(index,text(entry.items[index]))
