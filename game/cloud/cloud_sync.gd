extends Node
## Own-account local stores and revision-checked cloud replicas. Local save first.
const Store = preload("res://game/persistence/infrastructure/save_store.gd")
const Schema = preload("res://game/persistence/domain/save_schema.gd")
const Rules = preload("res://game/cloud/sync_rules.gd")
signal changed
var game: Node
var account: Node
var guest_store: RefCounted
var uid := ""
var entries: Dictionary = {}
var imported: Dictionary = {}
var epoch := 0
var generation := 0
var pending := false
var busy := false
var notice := "Play offline"
var timer: Timer

func setup(owner_game: Node, auth: Node) -> void:
	process_mode=Node.PROCESS_MODE_ALWAYS
	game=owner_game; account=auth; guest_store=game.session.store
	account.changed.connect(account_changed)
	timer=Timer.new(); timer.wait_time=5; timer.one_shot=true; add_child(timer)
	timer.timeout.connect(synchronize)

func account_changed() -> void:
	var next: String=account.user.get("id","")
	if next==uid:
		if account.authenticated(): schedule()
		return
	if game.session.active:
		notice="Save and return to the menu before switching accounts."; changed.emit(); return
	if game.session.store.saved.is_connected(schedule): game.session.store.saved.disconnect(schedule)
	epoch+=1; uid=next; entries={}; imported={}; pending=false
	game.session.store=guest_store if uid.is_empty() else Store.new(profile_root().path_join("saves"),game.testing)
	if not uid.is_empty():
		var file := profile_root().path_join("sync-index.json")
		if FileAccess.file_exists(file):
			var index=JSON.parse_string(FileAccess.get_file_as_string(file))
			if index is Dictionary:
				var candidates=index.get("entries",{})
				if candidates is Dictionary:
					for key in candidates:
						if str(key).is_valid_int() and int(key)>0 and Rules.valid_entry(candidates[key]): entries[str(key)]=candidates[key]
				var prior=index.get("imported",{})
				if prior is Dictionary:
					for key in prior:
						if Rules.valid_hash(key): imported[key]=true
		game.session.store.saved.connect(schedule)
	game.session.revision+=1
	game.refresh_journey_picker()
	notice="Play offline" if uid.is_empty() else "Syncing journeys…"
	changed.emit()
	if not uid.is_empty(): schedule()

func profile_root() -> String:
	return "user://accounts/"+uid

func save_index() -> bool:
	if game.testing: return true
	if DirAccess.make_dir_recursive_absolute(profile_root())!=OK: return false
	var path := profile_root().path_join("sync-index.json")
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file==null: return false
	file.store_string(JSON.stringify({"entries":entries,"imported":imported})); file.flush()
	var ok := file.get_error()==OK; file.close()
	return ok and DirAccess.rename_absolute(path+".tmp",path)==OK

func schedule(_slot: int=0) -> void:
	generation+=1; pending=true
	if account.authenticated() and not busy and not game.testing: timer.start(2)

func entry(slot: int) -> Dictionary:
	var key := str(slot)
	if not entries.has(key): entries[key]={"id":Rules.uuid(),"revision":0,"base":""}
	return entries[key]

func import_guest() -> int:
	if uid.is_empty() or game.session.active or busy: return 0
	var count := 0
	for item in guest_store.catalog():
		if not item.ok: continue
		var hash := Rules.content_hash(item.state)
		if imported.has(hash): continue
		var snapshot: Dictionary=item.state.duplicate(true)
		var slot: int=game.session.store.next_journey_id()
		if slot<1: break
		snapshot.slot_id=slot
		if game.session.store.save(snapshot).ok:
			imported[hash]=slot; entry(slot); count+=1
	save_index(); game.refresh_journey_picker(); schedule()
	return count

func synchronize() -> void:
	if busy or uid.is_empty() or not account.authenticated() or game.testing: return
	busy=true; notice="Syncing journeys…"; changed.emit()
	var ticket := epoch; var began := generation
	var ok: bool=await sync_once(ticket)
	if ticket==epoch:
		pending=not ok or began!=generation
		notice="Journeys synchronized" if ok and not pending else "Connection unavailable. Progress remains saved locally."
		game.refresh_journey_picker()
	busy=false; changed.emit()
	if pending and not uid.is_empty() and account.authenticated(): timer.start(20 if not ok else 3)

func sync_once(ticket: int) -> bool:
	var remote: Dictionary={}
	var offset := 0
	while true:
		var response: Dictionary=await account.request("/rest/v1/last_light_journeys?select=id,revision,content_hash&order=id.asc&limit=100&offset="+str(offset),HTTPClient.METHOD_GET,null,true)
		if ticket!=epoch or not response.ok or not response.data is Array: return false
		for row in response.data:
			if not Rules.valid_remote(row): return false
			remote[row.id]=row
		if response.data.size()<100: break
		offset+=100
		if offset>10000: return false
	var catalog: Array=game.session.store.catalog()
	var known: Dictionary={}
	for item in catalog:
		if not item.ok: continue
		known[entry(item.id).id]=int(item.id)
	if not save_index(): return false
	# Discover remote journeys before comparing edits to already known identities.
	for id in remote:
		if known.has(id): continue
		var slot: int=game.session.store.next_journey_id()
		if slot<1 or not await download(remote[id],slot,ticket): return false
	for item in catalog:
		if ticket!=epoch: return false
		if not item.ok: continue
		var meta := entry(item.id)
		var row: Dictionary=remote.get(meta.id,{})
		var hash := Rules.content_hash(item.state)
		var action := Rules.decision(hash,row.get("content_hash",""),meta.base)
		if action=="same":
			meta.revision=row.revision; meta.base=hash
		elif action=="download":
			if game.session.active and int(game.session.state.slot_id)==int(item.id): return false
			if not await download(row,item.id,ticket): return false
		elif action=="fork":
			# Keep this device's branch at its current slot; retain remote as another journey.
			var remote_slot: int=game.session.store.next_journey_id()
			if remote_slot<1 or not await download(row,remote_slot,ticket): return false
			entries[str(item.id)]={"id":Rules.uuid(),"revision":0,"base":""}
			if not save_index() or not await upload(item.state,item.id,0,ticket): return false
		else:
			if not await upload(item.state,item.id,int(row.get("revision",0)),ticket): return false
	return save_index()

func upload(snapshot: Dictionary, slot: int, expected: int, ticket: int) -> bool:
	var meta := entry(slot)
	var hash := Rules.content_hash(snapshot)
	var response: Dictionary=await account.request("/rest/v1/rpc/commit_last_light_journey",HTTPClient.METHOD_POST,{"p_id":meta.id,"p_expected_revision":expected,"p_snapshot":snapshot,"p_content_hash":hash},true)
	if ticket!=epoch or not response.ok or not response.data is Dictionary: return false
	meta.revision=int(response.data.get("revision",0)); meta.base=hash
	return meta.revision>0 and save_index()

func download(row: Dictionary, slot: int, ticket: int) -> bool:
	var before: Dictionary=game.session.store.load_slot(slot)
	var before_hash: String=Rules.content_hash(before.state) if before.ok else ""
	var response: Dictionary=await account.request("/rest/v1/last_light_journeys?id=eq."+str(row.id)+"&select=id,revision,snapshot,content_hash&limit=1",HTTPClient.METHOD_GET,null,true)
	if ticket!=epoch or not response.ok or not response.data is Array or response.data.size()!=1: return false
	if game.session.active and int(game.session.state.slot_id)==slot: return false
	var current: Dictionary=game.session.store.load_slot(slot)
	var current_hash: String=Rules.content_hash(current.state) if current.ok else ""
	if current_hash!=before_hash: return false
	if not Rules.valid_remote(response.data[0]): return false
	var latest: Dictionary=response.data[0]
	if latest.id!=row.id: return false
	if not latest.get("snapshot") is Dictionary or Schema.validate(latest.snapshot)!="": return false
	var snapshot: Dictionary=latest.snapshot.duplicate(true)
	snapshot.slot_id=slot
	if Rules.content_hash(snapshot)!=latest.content_hash: return false
	# Suppress the local-save hook for replicas: metadata is committed only after disk success.
	game.session.store.saved.disconnect(schedule)
	var result: Dictionary=game.session.store.save(snapshot)
	game.session.store.saved.connect(schedule)
	if not result.ok: return false
	entries[str(slot)]={"id":latest.id,"revision":int(latest.revision),"base":latest.content_hash}
	return save_index()
