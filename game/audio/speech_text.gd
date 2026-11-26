extends RefCounted
## Extract authored narration, never account data, journal statistics or credits.
const HEADINGS = ["OREN", "LYRA", "SIR CAEL", "ABANDONED MINE", "EXPEDITION RECORD", "CENTRAL ARTIFACT", "RITUAL INSCRIPTION", "DAWN OVER VEYR"]

static func speaker(source: String) -> String:
	var heading := source.get_slice("\n",0)
	if heading.begins_with("OREN"): return "oren"
	if heading.begins_with("LYRA"): return "lyra"
	if heading.begins_with("SIR CAEL"): return "cael"
	return "narrator"

static func is_narrative(source: String) -> bool:
	var heading := source.get_slice("\n",0).get_slice(" · ",0)
	return heading in HEADINGS

static func parts(source: String, has_heading: bool = true) -> PackedStringArray:
	var result := PackedStringArray()
	var lines := source.split("\n")
	for index in range(1 if has_heading else 0,lines.size()):
		var line := lines[index].strip_edges()
		if line in ["THE END", "Credits"]: break
		# Shop values remain visible; only spoken character/narrator prose is voiced.
		if line.is_empty() or line.begins_with("Sword tier ") or line.begins_with("Sword damage ") or line.begins_with("Upgrade costs "): continue
		result.append(line)
	return result

static func key(text: String, actor: String) -> String:
	return (actor+"\n"+text.strip_edges()).sha256_text().substr(0,20)
