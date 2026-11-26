extends RefCounted
const IDS = ["move","look","sprint","jump","light","heavy","block","dodge","rest","interact","lock","heal"]
static func valid(value: Variant) -> bool:
	if not value is Array or value.size() > IDS.size(): return false
	var seen := []
	for id in value:
		if id not in IDS or id in seen: return false
		seen.append(id)
	return true
