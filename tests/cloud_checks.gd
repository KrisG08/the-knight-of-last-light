extends RefCounted
const Rules=preload("res://game/cloud/sync_rules.gd")
const Account=preload("res://game/cloud/cloud_account.gd")
const Sync=preload("res://game/cloud/cloud_sync.gd")
const Store=preload("res://game/persistence/infrastructure/save_store.gd")
const Session=preload("res://game/campaign/application/campaign_session.gd")
const Campaign=preload("res://game/campaign/domain/campaign_rules.gd")

class ReplicaGame extends Node:
	var testing := true
	var session: RefCounted
	func refresh_journey_picker() -> void: pass

class FakeAuth extends Node:
	signal changed
	var user: Dictionary={}
	var rows: Dictionary={}
	var online := true
	func authenticated() -> bool: return not user.is_empty()
	func request(path: String, _method: int, body: Variant=null, _authorized: bool=false) -> Dictionary:
		if not online: return {"ok":false,"status":0,"data":{}}
		if path.contains("/rpc/"):
			var prior: Dictionary=rows.get(body.p_id,{})
			if (not prior.is_empty() and prior.owner!=user.id) or int(prior.get("revision",0))!=int(body.p_expected_revision):
				return {"ok":false,"status":409,"data":{}}
			var row={"id":body.p_id,"owner":user.id,"revision":int(body.p_expected_revision)+1,"snapshot":body.p_snapshot.duplicate(true),"content_hash":body.p_content_hash}
			rows[body.p_id]=row
			return {"ok":true,"status":200,"data":{"revision":row.revision}}
		var result: Array=[]
		for row in rows.values():
			if row.owner!=user.id: continue
			if path.contains("?id=eq.") and not path.contains(str(row.id)): continue
			result.append(row.duplicate(true))
		return {"ok":true,"status":200,"data":result}

static func replica(tree: SceneTree, server: Dictionary, uid: String) -> Dictionary:
	var game=ReplicaGame.new(); game.session=Session.new(Store.new("user://unused-cloud-test",true)); tree.root.add_child(game)
	game.session.begin(1,false); game.session.save_progress(); game.session.active=false
	var auth=FakeAuth.new(); auth.rows=server; game.add_child(auth)
	var sync=Sync.new(); game.add_child(sync); sync.setup(game,auth)
	auth.user={"id":uid}; auth.changed.emit()
	return {"game":game,"auth":auth,"sync":sync}

static func run(tree: SceneTree, check: Callable) -> void:
	var id:=Rules.uuid()
	check.call(Rules.valid_uuid(id) and id[14]=="4","Cloud identities use random UUID v4")
	check.call(not Rules.valid_uuid("../another-account") and not Rules.valid_uuid(null),"Cloud identities reject paths and malformed values")
	check.call(not Rules.valid_entry({"id":id,"revision":1.5,"base":""}) and not Rules.valid_entry([]),"Sync metadata rejects fractional revisions and corrupt shapes")
	var snapshot:=Campaign.new_game(1)
	var other:=snapshot.duplicate(true); other.slot_id=83; other.saved_at="different device time"
	check.call(Rules.content_hash(snapshot)==Rules.content_hash(other),"Cloud content equality ignores device slot IDs and save timestamps")
	for values in [["a","","","upload"],["a","a","b","same"],["a","b","a","download"],["a","b","b","upload"],["a","b","c","fork"]]:
		check.call(Rules.decision(values[0],values[1],values[2])==values[3],"Cloud three-way decision: "+values[3])
	var auth=Account.new(); auth.enabled=false; tree.root.add_child(auth)
	auth.public_key="sb_secret_forbidden"; check.call(not auth.configured(),"Game refuses a secret backend key")
	check.call(not auth.accept_session({"access_token":"test","user":{"id":"../../bad"}}),"Auth rejects malformed account identities before selecting a local store")
	auth.queue_free()
	var server: Dictionary={}
	var first:=replica(tree,server,id)
	var second:=replica(tree,server,id)
	var guest_before:=JSON.stringify(first.sync.guest_store.load_slot(1).state)
	check.call(first.sync.import_guest()==1 and first.sync.import_guest()==0,"Guest journey import is explicit and idempotent")
	check.call(JSON.stringify(first.sync.guest_store.load_slot(1).state)==guest_before,"Cloud import preserves original offline journey byte content")
	check.call(await first.sync.sync_once(first.sync.epoch) and server.size()==1,"First device uploads its validated journey")
	check.call(await second.sync.sync_once(second.sync.epoch) and second.game.session.store.catalog().size()==1,"Second device discovers and restores cloud journey")
	var edited: Dictionary=first.game.session.store.load_slot(1).state
	edited=Campaign.apply_action(edited,"DefeatBoss","boss.gravedigger").next_state
	first.game.session.store.save(edited)
	check.call(await first.sync.sync_once(first.sync.epoch) and await second.sync.sync_once(second.sync.epoch),"A later boss victory propagates to the other device")
	check.call("boss.gravedigger" in second.game.session.store.load_slot(1).state.campaign.boss_defeated_ids,"Cloud replica preserves defeated boss facts")
	var left: Dictionary=first.game.session.store.load_slot(1).state
	var right: Dictionary=second.game.session.store.load_slot(1).state
	left.character.shards+=11; right.character.shards+=19
	first.game.session.store.save(left); second.game.session.store.save(right)
	await first.sync.sync_once(first.sync.epoch)
	check.call(await second.sync.sync_once(second.sync.epoch) and second.game.session.store.catalog().size()==2 and server.size()==2,"Concurrent offline edits preserve both branches as separate journeys")
	var values: Array=[]
	for item in second.game.session.store.catalog(): values.append(item.state.character.shards)
	check.call(left.character.shards in values and right.character.shards in values,"Conflict recovery retains both devices' exact progression values")
	var stranger:=replica(tree,server,Rules.uuid())
	check.call(await stranger.sync.sync_once(stranger.sync.epoch) and stranger.game.session.store.catalog().is_empty(),"Another account cannot see the first account's journeys")
	first.auth.online=false
	var before_offline:=JSON.stringify(first.game.session.store.load_slot(1).state)
	check.call(not await first.sync.sync_once(first.sync.epoch) and JSON.stringify(first.game.session.store.load_slot(1).state)==before_offline,"Network failure retains local progress without destructive fallback")
	first.game.queue_free(); second.game.queue_free(); stranger.game.queue_free()
	await tree.process_frame
