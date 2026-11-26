extends RefCounted
const Creature = preload("res://game/presentation/ambient_creature.gd")
const Assets = preload("res://game/presentation/real_assets.gd")
const Art = preload("res://game/presentation/art_kit.gd")
const INHABITANTS = {
	"region.refuge": [["dwarf",Vector3(5,0,77),1.0], ["goblin",Vector3(-4,0,45),0.95], ["goblin",Vector3(5,0,18),1.0], ["wraith",Vector3(6,0,-35),1.0], ["dwarf",Vector3(7,0,-83),1.0]],
	"region.village": [["dwarf",Vector3(-4,0,32),1.0], ["goblin",Vector3(-20,0,3),0.95], ["dwarf",Vector3(22,0,-9),1.0], ["goblin",Vector3(22,0,-28),0.95]],
	"region.crypt": [["wraith",Vector3(-7,0,5),0.85], ["wraith",Vector3(7,0,-5),0.85]],
	"region.blackwood": [["goblin",Vector3(-5,0,9),0.9], ["goblin",Vector3(10,0,-44),1.0], ["wraith",Vector3(17,0,-60),1.0]],
	"region.grove": [["goblin",Vector3(-7,0,7),0.9], ["wraith",Vector3(7,0,-7),1.0]],
	"region.order": [["dwarf",Vector3(-5,0,5),1.0], ["goblin",Vector3(13,0,-26),1.0], ["wraith",Vector3(-16,0,-45),1.0]],
	"region.sanctum": [["wraith",Vector3(-8,0,6),1.0], ["wraith",Vector3(8,0,-6),1.0]],
	"region.peaks": [["dwarf",Vector3(5,0,3),1.0], ["goblin",Vector3(-6,0,-48),0.95]],
	"region.forge": [["dwarf",Vector3(-8,0,6),1.0], ["dwarf",Vector3(8,0,-6),1.0]],
	"region.citadel": [["goblin",Vector3(5,0,0),1.0], ["dwarf",Vector3(-14,0,-12),1.0], ["wraith",Vector3(12,0,-50),1.0]],
	"region.ritual": [["wraith",Vector3(-9,0,6),1.0], ["wraith",Vector3(9,0,-6),1.0], ["wraith",Vector3(-8,0,-8),0.85]]
}

static func place(root: Node3D, id: String, at: Vector3, scale: float, yaw: float) -> Node3D:
	var creature := Creature.new()
	creature.setup(id,scale)
	creature.position = at
	creature.rotation.y = yaw
	root.add_child(creature)
	return creature

static func build(region: Node3D, terrain_height: Callable = Callable()) -> void:
	if not INHABITANTS.has(region.region_id): return
	var root := Node3D.new()
	root.name = "MythicFauna"
	region.add_child(root)
	match region.region_id:
		"region.refuge":
			var at := Vector3(-23,0,70)
			at.y = terrain_height.call(at.x,at.z) if terrain_height.is_valid() else 0.0
			var fox := place(root,"barghest",at,1.4,-0.8)
			if terrain_height.is_valid():
				var dx: float = (terrain_height.call(at.x+0.5,at.z)-terrain_height.call(at.x-0.5,at.z))
				var dz: float = (terrain_height.call(at.x,at.z+0.5)-terrain_height.call(at.x,at.z-0.5))
				fox.quaternion = Quaternion(Vector3.UP,Vector3(-dx,1,-dz).normalized())*fox.quaternion
		"region.blackwood":
			place(root,"goblin",Vector3(12,0,-15),1.0,0.4)
			place(root,"goblin",Vector3(14,0,-16),0.9,-0.8)
			place(root,"barghest",Vector3(-23,0,-9),1.5,-1.0)
			place(root,"wraith",Vector3(-28,0,-42),1.25,-PI/2)
		"region.peaks":
			# Distant ridge beyond the physical western boundary. A source rock is
			# staged under it, so the dragon never occupies a traversal/combat route.
			var base := Vector3(-41,0,-51)
			Assets.place_mesh(root,"rock_moss_set_01","rock_moss_set_01_rock03",base,Vector3(6,8,6),0.3)
			var rock = root.get_child(0).get_child(0) as MeshInstance3D
			var height: float = rock.mesh.get_aabb().size.y*8
			place(root,"ash_dragon",base+Vector3.UP*(height*0.8),5.5,0.7)
			place(root,"troll",Vector3(25,0,-44),1.65,PI/2)
			place(root,"dwarf",Vector3(-15,0,-10),1.0,0.5)
			place(root,"dwarf",Vector3(-15,0,-19),1.0,-0.7)
		"region.citadel":
			place(root,"sentinel",Vector3(-15,0,-40),2.2,PI)
			Art.cylinder(root,Vector3(15,2,-40),1.2,1.2,4,Art.stone(),16)
			place(root,"gargoyle",Vector3(15,4,-40),1.5,PI)
			# Flat-topped exterior bastion supports all four feet; it is entirely
			# beyond the existing physical boundary, not a new playable obstacle.
			Art.cylinder(root,Vector3(36,6,-24),3.6,3.6,12,Art.stone(),20)
			Art.cylinder(root,Vector3(36,11.8,-24),3.9,3.9,0.4,Art.stone(),20)
			place(root,"ash_dragon",Vector3(36,12.02,-24),3.4,-PI/2)
	for entry in INHABITANTS[region.region_id]:
		var at: Vector3 = entry[1]
		if terrain_height.is_valid(): at.y = terrain_height.call(at.x,at.z)
		place(root,entry[0],at,entry[2],-PI/2 if at.x<0 else PI/2)
	for creature in root.get_children():
		if creature.get_script()!=Creature: continue
		if creature.species in ["goblin","dwarf","troll"]:
			creature.terrain_height = terrain_height
			var offset := Vector3(0,0,1.2) if creature.species=="troll" else Vector3(0,0,0.8)
			creature.set_stroll(offset,region.obstacles)
	preload("res://game/presentation/opening_world_story.gd").build(region)
