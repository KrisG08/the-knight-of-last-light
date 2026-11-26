extends SceneTree
const Presence=preload("res://game/presentation/curse_presence.gd")
const Campaign=preload("res://game/campaign/domain/campaign_rules.gd")
var failures:=0
var assertions:=0
const REGIONS=["region.refuge","region.village","region.crypt","region.blackwood","region.grove","region.order","region.sanctum","region.peaks","region.forge","region.citadel","region.ritual"]
func check(ok: bool, message: String) -> void:
	assertions+=1
	if not ok: failures+=1; push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var state=Campaign.new_game(1)
	for id in REGIONS: check(Presence.active_for(id,state),"Curse visible on first arrival: "+id)
	state.campaign.broken_seal_ids=["seal.burial"]
	check(not Presence.active_for("region.village",state) and not Presence.active_for("region.crypt",state),"Burial Seal cleanses its two areas")
	check(Presence.active_for("region.blackwood",state),"Breaking one seal does not cleanse another region")
	state.campaign.broken_seal_ids=["seal.burial","seal.root","seal.oath","seal.forge"]
	for id in Presence.REGION_SEALS: check(not Presence.active_for(id,state),"Broken regional seals hide local curse: "+id)
	check(Presence.active_for("region.citadel",state) and Presence.active_for("region.ritual",state),"Final curse persists until artifact completion")
	state.campaign.completed=true
	for id in REGIONS: check(not Presence.active_for(id,state),"Ending removes curse presence: "+id)
	var region=load("res://game/world/regions/graybox_region.gd").new()
	root.add_child(region); region.build("region.crypt")
	state=Campaign.new_game(1); region.apply_state(state)
	var effect=region.curse_presence
	check(effect.emitters.size()==2,"Real region owns exactly two bounded decorative emitters")
	var total:=0
	for emitter in effect.emitters: total+=emitter.amount
	check(total==32,"Curse particle count remains bounded")
	check(effect.find_children("*","CollisionObject3D",true,false).is_empty(),"Decorative curse cannot block or interact")
	state.campaign.broken_seal_ids=["seal.burial"]; region.apply_state(state)
	check(not effect.visible and not effect.emitters[0].emitting,"Live seal change hides and stops emission")
	for type in ["AudioStreamPlayer","AudioStreamPlayer2D","AudioStreamPlayer3D"]:
		for audio in root.find_children("*",type,true,false): audio.stop()
	region.queue_free(); await process_frame
	await create_timer(0.3,true).timeout
	print("Violet curse presentation: %d assertions, "%assertions+("PASS" if failures==0 else "FAIL %d"%failures))
	quit(0 if failures==0 else 1)
