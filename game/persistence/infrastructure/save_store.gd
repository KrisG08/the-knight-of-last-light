extends RefCounted
signal saved(slot: int)

const Schema = preload("res://game/persistence/domain/save_schema.gd")
const MAX_BYTES = 2097152
var directory: String
var memory_only: bool = false
var slots: Dictionary = {}
var fail_stage: String = ""

func _init(root: String = "user://saves", use_memory: bool = false) -> void:
	directory = root
	memory_only = use_memory

func path_for(slot: int) -> String:
	return directory.path_join("slot_%02d.json" % slot)

func exists(slot: int) -> bool:
	return slots.has(slot) if memory_only else FileAccess.file_exists(path_for(slot)) or FileAccess.file_exists(path_for(slot) + ".bak")

func read_file(path: String, slot: int) -> Dictionary:
	if not FileAccess.file_exists(path):
		return failure("No saved game in this slot")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return failure("Cannot read save")
	if file.get_length() > MAX_BYTES:
		return failure("Save exceeds size limit")
	var json := JSON.new()
	var error := json.parse(file.get_as_text())
	file.close()
	if error != OK:
		return failure("Save is incomplete or corrupt")
	var reason := Schema.validate(json.data)
	if reason != "":
		return failure(reason)
	if json.data.slot_id != slot:
		return failure("Save belongs to another slot")
	return {"ok": true, "state": json.data, "message": "Save loaded"}

func load_slot(slot: int) -> Dictionary:
	if slot < 1 or slot > 999999:
		return failure("Invalid slot")
	if memory_only:
		return {"ok": true, "state": slots[slot].duplicate(true), "message": "Save loaded"} if slots.has(slot) else failure("No saved game in this slot")
	var primary := read_file(path_for(slot), slot)
	if primary.ok or primary.message.begins_with("Unsupported"):
		return primary
	var backup := read_file(path_for(slot) + ".bak", slot)
	if backup.ok:
		backup.message = "Recovered backup; latest unsaved progress may be lost"
		return backup
	return failure(primary.message + ". Backup unavailable; files preserved")

func save(state: Dictionary) -> Dictionary:
	var reason := Schema.validate(state)
	if reason != "":
		return failure(reason)
	var snapshot := state.duplicate(true)
	snapshot.saved_at = Time.get_datetime_string_from_system(true) + "Z"
	if memory_only:
		slots[int(snapshot.slot_id)] = snapshot
		saved.emit(int(snapshot.slot_id))
		return {"ok": true, "message": "Progress saved; resume at the lantern checkpoint"}
	if DirAccess.make_dir_recursive_absolute(directory) != OK:
		return failure("Cannot create save directory")
	var slot: int = snapshot.slot_id
	var path := path_for(slot)
	var existing := read_file(path, slot)
	if existing.message.begins_with("Unsupported"):
		return failure("Unsupported save version; original preserved")
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return failure("Cannot write temporary save")
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.flush()
	var written: bool = file.get_error() == OK
	file.close()
	if not written or not read_file(temporary, slot).ok:
		return failure("Temporary save verification failed")
	if fail_stage == "before_backup":
		return failure("Simulated write failure; progress remains unsaved")
	if existing.ok:
		var backup_temp := path + ".bak.tmp"
		if DirAccess.copy_absolute(path, backup_temp) != OK or not read_file(backup_temp, slot).ok:
			return failure("Cannot preserve save backup")
		if DirAccess.rename_absolute(backup_temp, path + ".bak") != OK:
			return failure("Cannot promote backup")
	if fail_stage == "before_promote":
		return failure("Simulated write failure; progress remains unsaved")
	if DirAccess.rename_absolute(temporary, path) != OK:
		return failure("Cannot replace save; previous save and backup preserved")
	if not read_file(path, slot).ok:
		return failure("Save verification failed; use backup recovery")
	saved.emit(slot)
	return {"ok": true, "message": "Progress saved; resume at the lantern checkpoint"}

static func failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}

func journey_ids() -> Array[int]:
	var found: Dictionary = {}
	if memory_only:
		for id in slots: found[int(id)] = true
	elif DirAccess.dir_exists_absolute(directory):
		var pattern := RegEx.new()
		pattern.compile("^slot_([0-9]+)\\.json(?:\\.bak|\\.tmp|\\.bak\\.tmp)?$")
		for filename in DirAccess.get_files_at(directory):
			var match_value := pattern.search(filename)
			if match_value != null:
				var id := int(match_value.get_string(1))
				if id >= 1 and id <= 999999: found[id] = true
	var result: Array[int] = []
	for id in found: result.append(int(id))
	result.sort()
	return result

func next_journey_id() -> int:
	var ids := journey_ids()
	var candidate: int = 1 if ids.is_empty() else ids.back()+1
	while candidate <= 999999 and (exists(candidate) or (not memory_only and FileAccess.file_exists(path_for(candidate)+".tmp"))): candidate += 1
	return candidate if candidate <= 999999 else -1

func catalog() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in journey_ids():
		var loaded := load_slot(id)
		result.append({"id":id,"ok":loaded.ok,"message":loaded.message,"state":loaded.get("state",{})})
	return result
