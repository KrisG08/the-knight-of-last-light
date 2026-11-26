extends RefCounted

const Rules = preload("res://game/campaign/domain/campaign_rules.gd")
const History = preload("res://game/persistence/domain/journey_history.gd")
var state: Dictionary = Rules.new_training()
var store: RefCounted
var active: bool = false
var dirty: bool = false
var revision: int = 0
var notice: String = "Select a slot, then start or load a journey."

func _init(save_store: RefCounted) -> void:
	store = save_store

func begin(slot: int, training: bool = true) -> void:
	state = Rules.new_training(slot) if training else Rules.new_game(slot)
	History.ensure(state,false)
	active = true
	dirty = true
	revision += 1
	save_progress()

func load_slot(slot: int) -> bool:
	var result: Dictionary = store.load_slot(slot)
	notice = result.message
	if not result.ok:
		return false
	state = result.state.duplicate(true)
	History.ensure(state)
	active = true
	dirty = false
	revision += 1
	return true

func act(action: String, id: String = "") -> bool:
	if not active:
		return false
	var result := Rules.apply_action(state, action, id)
	notice = result.reason
	if not result.accepted:
		return false
	state = result.next_state
	dirty = true
	revision += 1
	var action_notice: String = notice
	save_progress()
	if not dirty:
		notice = action_notice + " · Saved"
	return true

func save_progress() -> bool:
	if not active:
		return false
	var result: Dictionary = store.save(state)
	notice = result.message
	dirty = not result.ok
	return result.ok

func reward_soldier() -> void:
	if not active:
		return
	if "reward.training.victory" not in state.campaign.reward_claim_ids:
		act("CompleteTraining")
		return
	state = state.duplicate(true)
	Rules.grant_xp(state.character, 10)
	state.character.shards += 5
	revision += 1
	dirty = true
	save_progress()
	if not dirty:
		notice = "Soldier defeated · +10 XP · +5 shards · Saved"

func visit(region: String) -> void:
	if not active or region not in History.REGIONS: return
	History.ensure(state)
	if region not in state.journey.visited_region_ids:
		state = state.duplicate(true)
		state.journey.visited_region_ids.append(region)
		dirty = true
		revision += 1

func record_enemy(id: String, name: String, region: String) -> bool:
	if not active or region not in History.REGIONS: return false
	var next := state.duplicate(true)
	History.ensure(next)
	var entry: Dictionary = next.journey.enemy_defeats.get(id,{"name":name,"region":region,"count":0})
	entry.count += 1
	next.journey.enemy_defeats[id] = entry
	if History.validate(next.journey) != "": return false
	state = next
	dirty = true
	revision += 1
	return true
