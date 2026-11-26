extends RefCounted
## Compare durable content, never wall clocks or device-local slot numbers.
static func valid_uuid(value: Variant) -> bool:
	if not value is String: return false
	var pattern := RegEx.new()
	pattern.compile("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}$")
	return pattern.search(value)!=null

static func valid_hash(value: Variant, allow_empty: bool=false) -> bool:
	if not value is String: return false
	if allow_empty and value.is_empty(): return true
	return value.length()==64 and value.is_valid_hex_number(false)

static func valid_entry(value: Variant) -> bool:
	if not value is Dictionary: return false
	var revision=value.get("revision")
	return valid_uuid(value.get("id")) and (revision is int or revision is float) and is_finite(float(revision)) and revision>=0 and revision==floor(revision) and valid_hash(value.get("base"),true)

static func valid_remote(value: Variant) -> bool:
	if not value is Dictionary: return false
	return valid_entry({"id":value.get("id"),"revision":value.get("revision"),"base":value.get("content_hash")}) and value.revision>0 and valid_hash(value.get("content_hash"))

static func content_hash(snapshot: Dictionary) -> String:
	var canonical: Dictionary=JSON.parse_string(JSON.stringify(snapshot))
	canonical.erase("slot_id"); canonical.erase("saved_at")
	return JSON.stringify(canonical,"",true).sha256_text()

static func decision(local_hash: String, remote_hash: String, base_hash: String) -> String:
	if remote_hash.is_empty(): return "upload"
	if local_hash==remote_hash: return "same"
	if local_hash==base_hash: return "download"
	if remote_hash==base_hash: return "upload"
	return "fork"

static func uuid() -> String:
	var bytes := Crypto.new().generate_random_bytes(16)
	bytes[6]=(bytes[6]&15)|64; bytes[8]=(bytes[8]&63)|128
	var value := bytes.hex_encode()
	return "%s-%s-%s-%s-%s"%[value.substr(0,8),value.substr(8,4),value.substr(12,4),value.substr(16,4),value.substr(20,12)]
