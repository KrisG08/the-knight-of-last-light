extends SceneTree
var failures := 0
func check(value: bool, description: String) -> void:
	if not value: failures+=1; push_error(description)
	else: print("PASS: "+description)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var rules=preload("res://game/cloud/sync_rules.gd")
	var uid: String=rules.uuid()
	var store=preload("res://game/persistence/infrastructure/save_store.gd").new("user://cloud-disk-smoke/"+uid)
	var events: Array=[0]
	store.saved.connect(func(_slot): events[0]+=1)
	var state=preload("res://game/campaign/domain/campaign_rules.gd").new_game(1)
	check(store.save(state).ok and events[0]==1,"Successful durable save emits the sync hook once")
	store.fail_stage="before_promote"; state.character.shards+=1
	check(not store.save(state).ok and events[0]==1,"Failed promotion does not announce a successful cloud save")
	var game=preload("res://tests/cloud_checks.gd").ReplicaGame.new(); game.testing=false; root.add_child(game)
	var sync=preload("res://game/cloud/cloud_sync.gd").new(); game.add_child(sync); sync.game=game; sync.uid=uid
	sync.entries["1"]={"id":rules.uuid(),"revision":1,"base":""}
	check(sync.save_index(),"First sync sidecar commits on Windows")
	sync.entries["1"].revision=2
	check(sync.save_index(),"Updated sync sidecar replaces its earlier file on Windows")
	var file=JSON.parse_string(FileAccess.get_file_as_string(sync.profile_root().path_join("sync-index.json")))
	check(file.entries["1"].revision==2,"Promoted metadata contains the latest revision")
	game.queue_free(); await process_frame
	quit(0 if failures==0 else 1)
