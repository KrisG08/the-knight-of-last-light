extends Node3D
## Visible history and local consequences; campaign facts remain the authority.
const Art = preload("res://game/presentation/art_kit.gd")
const Kit = preload("res://game/presentation/village_kit.gd")
const Shapes = preload("res://game/presentation/ambient_entities.gd")
const Detail = preload("res://game/presentation/hostile_regalia.gd")
var region: Node3D
var burial_broken := false
var oren_rescued := false
var omen: Node3D
var renewed: Node3D
var forge: Node3D
var sound: AudioStreamPlayer3D
var clock := 0.0

static func build(owner_region: Node3D) -> void:
	if owner_region.region_id not in ["region.refuge","region.village","region.crypt"]: return
	var story := load("res://game/presentation/opening_world_story.gd").new() as Node3D
	story.name = "OpeningWorldStory"
	story.region = owner_region
	owner_region.add_child(story)
	story.construct()

func branch(id: String) -> Node3D:
	var node := Node3D.new()
	node.name = id
	add_child(node)
	return node

func construct() -> void:
	omen = branch("BurialOmen")
	renewed = branch("FirstRecovery")
	forge = branch("OrenForge")
	match region.region_id:
		"region.refuge": camp()
		"region.village": village()
		"region.crypt": pass
	renewed.hide()
	forge.hide()
	if region.region_id!="region.crypt":
		sound = AudioStreamPlayer3D.new()
		sound.bus = "SFX"
		sound.max_distance = 13
		sound.unit_size = 3
		sound.volume_db = -27
		sound.stream = preload("res://assets/audio/combat/block_0.wav")
		sound.position = Vector3(5,0.7,76) if region.region_id=="region.refuge" else Vector3(22,0.7,-10)
		add_child(sound)
	process_mode = Node.PROCESS_MODE_PAUSABLE

func cot(at: Vector3) -> void:
	var cloth := Art.material("expedition_linen",Color("817960"))
	for side in [-1,1]:
		Art.beam(self,at+Vector3(side*0.44,0.25,-1.2),at+Vector3(side*0.44,0.25,1.2),0.045,Kit.wood())
	var sheet := PlaneMesh.new()
	sheet.size = Vector2(0.8,1.9)
	Art.mesh(self,sheet,at+Vector3.UP*0.26,cloth)
	Shapes.orb(self,at+Vector3(0,0.3,-0.65),Vector3(0.55,0.12,0.3),cloth)
	for z in [-0.75,0.75]:
		Art.beam(self,at+Vector3(-0.4,0,z),at+Vector3(0.4,0.25,z),0.03,Kit.wood())
		Art.beam(self,at+Vector3(0.4,0,z),at+Vector3(-0.4,0.25,z),0.03,Kit.wood())

func bench(parent: Node3D, at: Vector3) -> void:
	Detail.plate(parent,at+Vector3.UP*0.64,Vector3(1.15,0.12,0.55),Kit.wood())
	for x in [-0.45,0.45]:
		Art.beam(parent,at+Vector3(x,0,-0.2),at+Vector3(x,0.62,0.2),0.065,Kit.wood())
	Detail.plate(parent,at+Vector3(0,0.74,0),Vector3(0.44,0.12,0.24),Detail.metal())
	Art.beam(parent,at+Vector3(-0.35,0.72,0),at+Vector3(-0.15,0.72,0.12),0.025,Detail.metal())

func cart(at: Vector3) -> void:
	for x in [-0.45,0,0.45]:
		Art.beam(self,at+Vector3(x,0.4,-0.7),at+Vector3(x,0.4,0.7),0.16,Kit.wood())
	for side in [-1,1]:
		var wheel := Detail.band(self,at+Vector3(side*0.65,0.35,0),0.32,Kit.wood(),0.055)
		wheel.rotation.z = PI/2
		for spoke in range(6):
			var a := spoke*PI/3
			Art.beam(self,at+Vector3(side*0.65,0.35,0),at+Vector3(side*0.65,0.35+sin(a)*0.3,cos(a)*0.3),0.02,Kit.wood())
	Art.beam(self,at+Vector3(0,0.4,0),at+Vector3(0.2,0.1,1.5),0.05,Kit.wood())
	Shapes.orb(self,at+Vector3(0.15,0.6,0.2),Vector3(0.55,0.4,0.5),Art.material("expedition_pack",Color("4f4938")))

func camp() -> void:
	cot(Vector3(-3,0,88))
	cot(Vector3(-1.5,0,88))
	bench(self,Vector3(5,0,76.2))
	cart(Vector3(-4,0,43.8))
	# Fallen standard and abandoned shields imply the expedition's losses.
	Art.beam(self,Vector3(-3,0.08,90),Vector3(-5,0.1,88),0.04,Kit.wood())
	for x in [-2.5,-1.3]:
		var shield := Detail.plate(self,Vector3(x,0.1,90),Vector3(0.6,0.08,0.85),Detail.metal())
		shield.rotation.y = 0.4*x
	bench(forge,Vector3(12,0,-60.6))
	Art.cylinder(forge,Vector3(14,0.3,-61),0.5,0.6,0.6,Art.stone(),16)
	var coal := Art.material("refuge_live_coals",Color("a55024"))
	coal.emission_enabled = true
	coal.emission = Color("b85422")
	coal.emission_energy_multiplier = 1.4
	Art.cylinder(forge,Vector3(14,0.63,-61),0.4,0.4,0.08,coal,16)
	local_light(forge,Vector3(14,1,-61),Color("e59e55"),1.4)
	local_light(renewed,Vector3(1,2,-62),Color("e3bc7d"),0.8)
	assign("dwarf",77,"repair",0)
	assign("goblin",45,"scavenge",0)

func village() -> void:
	bench(self,Vector3(22,0,-9.8))
	assign("dwarf",-9,"repair",0)
	# Domestic defenses: protective threshold lines and hastily nailed shutters.
	var chalk := Art.material("village_threshold_salt",Color("c5bda5"))
	for at in [Vector3(-10,0.025,25.4),Vector3(10,0.025,25.4)]:
		for index in range(9):
			Art.cylinder(self,at+Vector3((index-4)*0.15,0,0),0.035,0.035,0.025,chalk,6)
	for x in [-10,10]:
		Art.beam(self,Vector3(x-0.55,1.65,25.1),Vector3(x+0.55,2.65,25.1),0.065,Kit.wood())
	# Three soul lights hover near the crypt approach until its anchor is broken.
	var glow := Art.material("burial_omen_light",Color("69b8ac"))
	glow.emission_enabled = true
	glow.emission = Color("69b8ac")
	glow.emission_energy_multiplier = 1.6
	for index in range(3):
		Shapes.orb(omen,Vector3(-4+index*1.2,1+index*0.25,-29),Vector3.ONE*0.09,glow)
	local_light(omen,Vector3(-3,1.3,-29),Color("60c8bd"),0.6)
	local_light(renewed,Vector3(-3,1.5,-29),Color("e7b77b"),1.2)
	var wax := Art.material("memorial_candle_wax",Color("c4b28d"))
	var flame := Art.material("memorial_candle_flame",Color("efbb70"))
	flame.emission_enabled = true
	flame.emission = Color("efad55")
	flame.emission_energy_multiplier = 1.8
	for index in range(3):
		var at := Vector3(-4+index*0.3,0,-29)
		Art.cylinder(renewed,at+Vector3.UP*0.1,0.16,0.16,0.2,Art.stone(),12)
		Art.cylinder(renewed,at+Vector3.UP*(0.32+index*0.04),0.055,0.055,0.24+index*0.08,wax,12)
		Shapes.orb(renewed,at+Vector3.UP*(0.48+index*0.08),Vector3(0.06,0.12,0.06),flame)
	for index in range(7):
		Art.beam(renewed,Vector3(-5+index*0.3,0,-28),Vector3(-5+index*0.3,0.2,-28),0.015,Art.material("first_recovery_shoots",Color("728059")))

func local_light(parent: Node3D, at: Vector3, tint: Color, energy: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.position = at
	lamp.light_color = tint
	lamp.light_energy = energy
	lamp.omni_range = 7
	parent.add_child(lamp)

func assign(kind: String, z: float, role: String, facing: float) -> void:
	for actor in region.get_node("MythicFauna").get_children():
		if actor.get_script()==preload("res://game/presentation/ambient_creature.gd") and actor.species==kind and is_equal_approx(actor.position.z,z):
			actor.assign_activity(role,facing)
			if role=="repair": actor.work_struck.connect(work_hit)

func work_hit() -> void:
	if is_instance_valid(sound):
		sound.pitch_scale = 0.75 if region.region_id=="region.refuge" else 0.9
		sound.play()

func apply_state(state: Dictionary) -> void:
	burial_broken = "seal.burial" in state.campaign.broken_seal_ids
	oren_rescued = "ally.oren" in state.campaign.recruited_ally_ids
	omen.visible = not burial_broken
	renewed.visible = burial_broken
	forge.visible = oren_rescued and region.region_id=="region.refuge"
	if region.region_id=="region.crypt":
		for actor in region.get_node("MythicFauna").get_children():
			if actor.get_script()==preload("res://game/presentation/ambient_creature.gd") and actor.species=="wraith":
				actor.visible = not burial_broken
				actor.set_process(not burial_broken)

func _process(delta: float) -> void:
	clock += delta
	if region.region_id=="region.village": omen.position.y = sin(clock*0.8)*0.12

func _exit_tree() -> void:
	if is_instance_valid(sound): sound.stop()
