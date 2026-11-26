extends "res://tools/render_opening_film.gd"
## Offline authored 3D film. No AI-video or performance claims are made.
const Motion = preload("res://tools/film_body_motion.gd")
var village: Node3D
var artifact: Node3D
var core: Node3D
var flecks: Array[MeshInstance3D] = []
var look: Environment
var ready_to_render := false
var captured_frames := 0
var export_fps := 60

func setup() -> void:
	super.setup()
	root.size=Vector2i(1920,1080)
	root.content_scale_size=Vector2i(1920,1080)
	root.msaa_3d=Viewport.MSAA_4X
	look=world.find_children("*","WorldEnvironment",true,false)[0].environment
	look.ambient_light_energy=.48
	look.fog_density=.0025
	look.fog_light_color=Color("21152e")
	village=Region.new(); world.add_child(village); village.build("region.village")
	for region in [forest,fortress,village]:
		for label in region.find_children("*","Label3D",true,false): label.hide()
		for fauna in region.find_children("MythicFauna","Node3D",true,false): fauna.hide()
		for portals in region.find_children("RegionPortals","Node3D",true,false): portals.hide()
	# Film has no active gameplay simulations or independent random character poses.
	for actor in knights:
		actor.node.model.sword.visible=true
		actor.node.model.shield.visible=true
	build_anchor()
	build_wind()
	ready_to_render=true
	update_film(0)
	print("PROLOGUE_V6_READY: authored eight-shot 80-second 3D film")
	if not "--preview" in OS.get_cmdline_user_args(): stream_frames.call_deferred()

func _process(_delta: float) -> bool:
	return false

func build_anchor() -> void:
	artifact=Node3D.new(); world.add_child(artifact)
	artifact.position=wizard.position+Vector3(-1.3,0,1.6)
	var brass:=Art.material("film_anchor_brass",Color("89734d"),.75)
	Art.cylinder(artifact,Vector3(0,.24,0),.65,.51,.48,Art.stone(),24)
	for y in [.62,2.05]:
		var ring:=TorusMesh.new(); ring.inner_radius=.35; ring.outer_radius=.43; ring.rings=32; ring.ring_segments=12
		Art.mesh(artifact,ring,Vector3(0,y,0),brass)
	for i in range(6):
		var angle:=i*TAU/6
		Art.cylinder(artifact,Vector3(cos(angle)*.39,1.33,sin(angle)*.39),.026,.026,1.43,brass,10)
	core=Node3D.new(); artifact.add_child(core); core.position.y=1.33
	Art.box(core,Vector3.ZERO,Vector3.ONE,brass).hide()
	preload("res://game/presentation/seal_crystal.gd").attach(core,Palette.LIGHT).scale=Vector3.ONE*.68

func build_wind() -> void:
	var mat:=Art.material("film_dead_leaves",Color("796455"))
	for i in range(64):
		var mesh:=QuadMesh.new(); mesh.size=Vector2(.05,.11)
		var leaf:=Art.mesh(world,mesh,Vector3.ZERO,mat)
		leaf.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		flecks.append(leaf)

func arm_pose(gait: Node3D, left: Vector3, right: Vector3, bend: float) -> void:
	for i in range(2):
		var arm: Dictionary=gait.upper_body.arms[i]
		arm.skeleton.set_bone_pose_rotation(0,Quaternion.from_euler(left if i==0 else right))
		arm.skeleton.set_bone_pose_rotation(1,Quaternion(Vector3.RIGHT,bend))
		arm.equipment.transform=arm.skeleton.get_bone_global_pose(2)*arm.wrist_inverse*arm.equipment_rest

func walk(actor: Node3D, gait: Node3D, t: float, phase: float=0.0) -> void:
	for side in range(2):
		var angles: Vector3=gait.pose(fposmod(t/.82+phase+side*.5,1.0))*.8
		for joint in range(3): gait.skeleton.set_bone_pose_rotation(side*3+joint,Quaternion(Vector3.RIGHT,angles[joint]))
	gait.upper_body.clock=t
	gait.upper_body.weight=1.0
	gait.upper_body.advance(1.0/60,true,false)
	actor.position.y+=absf(sin((t/.82+phase)*TAU))*.022

func view(at: Vector3, target: Vector3, fov: float) -> void:
	camera.position=at; camera.fov=fov; camera.look_at(target)

func update_film(t: float) -> void:
	if not ready_to_render: return
	var shot:=clampi(int(t/10),0,7)
	var local:=t-shot*10.0
	var u:=clampf(local/10.0,0,1)
	var ease:=smoothstep(0,1,u)
	forest.visible=shot in [3,5,6,7]
	fortress.visible=shot in [0,1,4]
	village.visible=shot==2
	wizard.visible=shot in [1,4]
	artifact.visible=shot==1
	curse.visible=shot in [1,4]
	wave.visible=shot==5
	shade.color.a=maxf(1-smoothstep(0,.45,local),smoothstep(9.55,10,local))
	core.rotation.y=t*.32
	core.position.y=1.33+sin(t*1.4)*.035
	wizard.rotation=Vector3.ZERO
	wizard_rig.body.rotation=Vector3(sin(t*1.7)*.012,0,sin(t*.9)*.009)
	wizard_rig.left_arm.rotation=Vector3.ZERO; wizard_rig.right_arm.rotation=Vector3.ZERO
	staff.rotation=Vector3.ZERO
	glow.light_energy=0
	for i in range(knights.size()):
		var actor: Node3D=knights[i].node
		var gait: Node3D=knights[i].gait
		actor.visible=shot in [3,5] or (shot in [6,7] and i==0)
		actor.rotation=Vector3.ZERO
		actor.model.sword.visible=true; actor.model.shield.visible=true
		actor.sword_pivot.rotation=Vector3.ZERO
		gait.upper_body.chest.rotation=Vector3.ZERO
		gait.upper_body.chest.position=gait.upper_body.torso_rest
		for bone in range(6): gait.skeleton.set_bone_pose_rotation(bone,Quaternion.IDENTITY)
		arm_pose(gait,Vector3.ZERO,Vector3.ZERO,0)
	# Wind-born leaves move in depth, not a full-screen stock overlay.
	var wind_center:=Vector3(3,0,19) if shot in [3,5] else Vector3(1,0,82)
	for i in range(flecks.size()):
		var leaf:=flecks[i]
		leaf.visible=shot in [2,3,5,6,7]
		var drift:=t*(1.4 if shot==5 else .35)
		leaf.position=wind_center+Vector3(fposmod(i*1.17+drift*2,17)-8, .15+fposmod(i*.37+drift*.22,2.9),fposmod(i*.71-drift,13)-6)
		if shot==2: leaf.position+=Vector3(12,0,-30)
		leaf.rotation=Vector3(t*2+i,t*1.3+i*.3,t*3+i)
	match shot:
		0:
			# Continuous aerial reveal of the enlarged, authored castle.
			view(Vector3(115,110,148).lerp(Vector3(62,89,94),ease),Vector3(0,66,-43),lerpf(58,49,ease))
		1:
			# A deliberate binding gesture links the visible artifact and sorcerer.
			var gather:=smoothstep(1.0,5.0,local)
			wizard_rig.left_arm.rotation=Vector3(.65*gather,-.2*gather,-.65*gather)
			wizard_rig.right_arm.rotation=Vector3(.35,0,.15)
			wizard.rotation.y=PI-.18
			view(wizard.position+Vector3(-4.3+ease*1.4,2.5,5.8-ease),wizard.position+Vector3(-.6,1.65,.5),43)
			curse.animate(local,artifact.position+Vector3.UP*1.33,camera,.28+gather*.55,.10+gather*.06)
			glow.position=artifact.position+Vector3.UP*1.5; glow.light_energy=.6+gather*.8
		2:
			# Actual village street, then the real Oren cell in the same story beat.
			if local<5:
				view(Vector3(3,2.0,13-local*.8),Vector3(0,1.7,-12),57)
			else:
				var cell: Vector3=village.points.oren
				view(cell+Vector3(-2.3+(local-5)*.15,1.85,5.4-(local-5)*.32),cell+Vector3(0,1.3,0),47)
				var hinge:=village.captured_gate.get_node_or_null("DoorHinge") as Node3D
				if hinge!=null: hinge.rotation.y=-1.0*(1-smoothstep(5.0,6.3,local))
				village.oren.rotation.y=PI+sin(local)*.045
		3:
			for i in range(knights.size()):
				var actor: Node3D=knights[i].node
				actor.position=Vector3(-4+u*4,0,33-u*12)+Vector3((i%2)*1.4,0,floorf(i/2.0)*2.7)
				actor.position.y=forest.height_at(actor.position.x,actor.position.z)
				actor.rotation.y=-.32
				walk(actor,knights[i].gait,local,i*.17)
			var leader: Vector3=knights[0].node.position
			view(leader+Vector3(-5.5+ease,2.2,6.5),leader+Vector3(.4,1.15,1.0),lerpf(53,45,ease))
		4:
			var charge:=smoothstep(.7,4.8,local)
			var release:=smoothstep(5.0,7.5,local)
			wizard_rig.right_arm.rotation=Vector3(charge*(1.0+release*.24),charge*.08,charge*.42)
			wizard_rig.left_arm.rotation=Vector3(charge*.8,charge*(.25+release*.12),-charge*.7)
			wizard_rig.body.rotation.x=-charge*.07+release*.12
			wizard.rotation.y=PI+charge*.10-release*.24
			staff.rotation.z=-charge*.35
			var angle:=lerpf(-.5,.4,ease)
			var radius:=lerpf(6.1,4.5,charge)+release*5
			view(wizard.position+Vector3(sin(angle)*radius,2.5+release*2,cos(angle)*radius),wizard.position+Vector3.UP*(1.7+release*.8),43+release*15)
			curse.animate(local,staff.to_global(Vector3(0,1.72,0)),camera,charge,release,false,true)
			glow.position=wizard.position+Vector3.UP*2.8; glow.light_energy=charge*(1.3+release*1.5)
		5:
			for i in range(knights.size()):
				var actor: Node3D=knights[i].node
				var gait: Node3D=knights[i].gait
				actor.position=Vector3(2+(i%2)*1.6,0,21+floorf(i/2.0)*2.8)
				actor.position.y=forest.height_at(actor.position.x,actor.position.z)
				actor.rotation.y=-.1
				if i==0:
					# Brace, lower to a knee, reach, and only then succumb. No frozen root.
					var kneel:=smoothstep(.8,2.7,local)
					actor.position.y-=kneel*.52
					gait.upper_body.chest.rotation=Vector3(kneel*.35,sin(local)*.06,0)
					for leg in range(2):
						var angles:=Vector3(.65,-1.4,.70)*kneel if leg==0 else Vector3(-.3,-1.15,.8)*kneel
						for joint in range(3): gait.skeleton.set_bone_pose_rotation(leg*3+joint,Quaternion(Vector3.RIGHT,angles[joint]))
					arm_pose(gait,Vector3(.45,0,-.22)*kneel,Vector3(-.9,0,-.3)*smoothstep(2.4,5,local),.5)
					actor.model.sword.visible=local<2.2
					if local>6: Motion.pose(actor,gait,(local-6)*.8,false,-1)
				else:
					Motion.pose(actor,gait,maxf(0,local-1-i*.28),false,1 if i%2 else -1)
			var lead: Vector3=knights[0].node.position
			view(Vector3(-2.5+u*1.6,2.5-u*.9,26-u*1.6),lead+Vector3(.8,.9,1.4),48)
			camera.position+=Vector3(sin(local*37),sin(local*43),0)*exp(-maxf(0,local-1)*2)*.035
			wave.animate(local,Vector3(3,.12,28),camera,1-smoothstep(5.4,9,local),smoothstep(0,2.5,local),true)
			glow.position=Vector3(3,2,23); glow.light_energy=(1-smoothstep(2,8,local))*.9
		6:
			var actor: Node3D=knights[0].node
			actor.position=Vector3(1,forest.height_at(1,82)+.025,82)
			actor.rotation.y=PI
			Motion.pose(actor,knights[0].gait,local*.74,true,-1)
			var rise:=smoothstep(2.5,8.5,local)
			view(Vector3(3,.9,85.7).lerp(Vector3(2.5,2.1,85.4),rise),Vector3(1,.45+rise*1.1,82),lerpf(45,40,rise))
		7:
			var actor: Node3D=knights[0].node
			actor.position=Vector3(1,0,82-u*5)
			actor.position.y=forest.height_at(actor.position.x,actor.position.z)
			actor.rotation.y=PI*(1-smoothstep(0,1.5,local))
			walk(actor,knights[0].gait,local)
			view(actor.position+Vector3(2.8,2.4,5.1+u*2),Vector3(0,1.6,65-u*6),lerpf(52,60,ease))

func preview() -> void:
	var directory:="res://.tools/review/prologue-v6-authored"
	DirAccess.make_dir_recursive_absolute(directory)
	for second in [2.0,12.0,17.0,22.0,27.0,33.0,37.0,43.0,47.0,52.0,55.0,58.0,62.0,66.0,68.5,73.0,77.0]:
		update_film(second)
		for tick in range(3): await process_frame
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_jpg(directory+"/shot-"+str(second)+".jpg",.92)==OK)
		print("PROLOGUE_V6_PREVIEW ",second)
	quit()

func stream_frames() -> void:
	print("PROLOGUE_STREAM_STARTED")
	for index in range(80*export_fps):
		update_film(float(index)/export_fps)
		await process_frame
		await RenderingServer.frame_post_draw
		var jpeg:=root.get_texture().get_image().save_jpg_to_buffer(.98)
		print("PROLOGUE_IMAGE ",Marshalls.raw_to_base64(jpeg))
		captured_frames+=1
		if index%120==0: print("PROLOGUE_V6_FRAME ",index,"/",80*export_fps)
	print("PROLOGUE_V6_COMPLETE ",captured_frames)
	quit()
