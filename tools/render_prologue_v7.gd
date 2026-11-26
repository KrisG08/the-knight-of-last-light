extends "res://tools/render_prologue_v6.gd"
const Timeline=preload("res://tools/prologue_v7_timeline.gd")
const Skinning=preload("res://tools/film_stitched_skin.gd")
const Grounded=preload("res://tools/film_grounded_motion.gd")
var skins: Array[RefCounted]=[]
var caster_skin: RefCounted
var staged:=false
var dropped: Array[Dictionary]=[]
var weapon_geometry: Dictionary={}

func prop_geometry(mesh: Mesh) -> Dictionary:
	var key:=mesh.get_instance_id()
	if weapon_geometry.has(key): return weapon_geometry[key]
	var points:=PackedVector3Array()
	for surface in range(mesh.get_surface_count()):
		var vertices: PackedVector3Array=mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]
		for i in range(0,vertices.size(),3): points.append(vertices[i])
	var center:=Vector3.ZERO
	for p in points: center+=p
	center/=points.size()
	var covariance:=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
	for point in points:
		var d:=point-center
		covariance.x+=d*d.x; covariance.y+=d*d.y; covariance.z+=d*d.z
	covariance.x.x+=.00001; covariance.y.y+=.00001; covariance.z.z+=.00001
	var inverse:=covariance.inverse()
	var normal:=Vector3(.37,.57,.73).normalized()
	for i in range(20): normal=(inverse*normal).normalized()
	weapon_geometry[key]={"points":points,"normal":normal}
	return weapon_geometry[key]

func setup() -> void:
	super.setup()
	export_fps=30
	for item in knights:
		var skin:=Skinning.new()
		skin.setup(item.node.visual,"knight",item.node.model)
		skin.attach(item.node.model.shield,10); skin.attach(item.node.model.sword,13)
		skins.append(skin)
		for kind in ["sword","shield"]:
			var source: MeshInstance3D=item.node.model[kind]
			var prop:=MeshInstance3D.new(); prop.name="Dropped"+kind
			prop.mesh=source.mesh; prop.material_override=source.material_override
			world.add_child(prop)
			dropped.append({"mesh":prop,"actor":knights.find(item),"kind":kind,"geometry":prop_geometry(prop.mesh)})
	# Control anchors stay attached to the torso, while the continuous skin shares
	# shoulder weights across the old cuts. Rotating a loose mesh is insufficient.
	for part in ["left_arm","right_arm"]: wizard_rig[part].reparent(wizard_rig.body,true)
	caster_skin=Skinning.new(); caster_skin.setup(wizard,"maldrek",wizard_rig)
	caster_skin.attach(staff,13)
	curse.free(); wave.free()
	curse=preload("res://tools/film_curse_v7.gd").new(); world.add_child(curse)
	wave=preload("res://tools/film_curse_v7.gd").new(); world.add_child(wave)
	wave.terrain=forest
	var cell_light:=OmniLight3D.new(); cell_light.name="CaptiveFaceLight"
	cell_light.position=village.points.oren+Vector3(-.9,2.0,1.0)
	cell_light.light_color=Color("d7b293"); cell_light.light_energy=1.0; cell_light.omni_range=5.5
	village.add_child(cell_light)
	staged=true; update_film(0)
	print("PROLOGUE_V7_READY: grounded continuous skins and occupied cell")

func update_film(t: float) -> void:
	if not staged: return
	var shot:=Timeline.shot(t)
	var local: float=t-Timeline.STARTS[shot]
	var duration: float=Timeline.DURATIONS[shot]
	var u:=clampf(local/duration,0,1)
	super.update_film(shot*10.0+u*10.0)
	# All staged poses are time-addressable; repeated sampling cannot accumulate drift.
	if shot==2:
		village.oren.rotation=Vector3.ZERO
		var prisoner:=village.oren.get_child(0) as Node3D
		prisoner.rotation.y=PI+sin(local*.8)*.035
		prisoner.position=village.points.oren+Vector3(-.28,0,-.25)
		var at: Vector3=village.points.oren
		var hinge:=village.captured_gate.get_node("DoorHinge") as Node3D
		hinge.rotation.y=-1.08*(1-pow(clampf((local-3.8)/.75,0,1),2))
		if local<1.6:
			view(Vector3(3,2.0,11-local),Vector3(0,1.7,-12),57)
		elif local<4.6:
			view(at+Vector3(-1.0,1.6,3.3).lerp(Vector3(-.45,1.62,2.15),smoothstep(1.6,4.4,local)),at+Vector3(-.28,1.38,-.25),44)
		else:
			view(at+Vector3(-.45+(local-4.6)*.16,1.7,2.15+(local-4.6)*.28),at+Vector3(-.28,1.30,-.25),44+(local-4.6)*1.1)
	if shot==3:
		for i in range(knights.size()):
			var actor: Node3D=knights[i].node
			actor.position=Vector3(-3.2 if i%2==0 else 3.2,0,33-u*12+floorf(i/2.0)*4.4)
			actor.position.y=forest.height_at(actor.position.x,actor.position.z)
		view(knights[0].node.position+Vector3(-5,2.4,7),Vector3(0,1.3,26-u*8),50)
	if shot==1:
		wizard_rig.left_arm.rotation+=Vector3(sin(local*1.7)*.045,sin(local*.8)*.055,0)
	if shot==5 or shot==6:
		for i in range(knights.size()):
			var actor: Node3D=knights[i].node
			var gait: Node3D=knights[i].gait
			actor.position=Vector3(-3.2 if i%2==0 else 3.2,0,21+floorf(i/2.0)*4.4)
			actor.position.y=forest.height_at(actor.position.x,actor.position.z)
			actor.rotation=Vector3.ZERO
			var age:=maxf(0,local-(3.8 if i==0 else .8+i*.48))
			if shot==6:
				actor.position=Vector3(1,forest.height_at(1,82),82)
				Grounded.recover(actor,gait,local)
			else:
				# Small authored contact variations follow the slope of each landing lane.
				Grounded.fall(actor,gait,age,1 if i%2==0 else -1,[1.58,1.54,1.56,1.51][i])
				if i==0 and local<3.8:
					var reaction:=smoothstep(.6,1.4,local)*(1-smoothstep(2.8,3.8,local))
					gait.upper_body.chest.rotation=Vector3(-.12*reaction,.22*reaction,0)
					arm_pose(gait,Vector3(.35,0,-.12)*reaction,Vector3(-.5,0,.1)*reaction,.25*reaction)
				elif i==0:
					gait.upper_body.chest.rotation.x+=sin(local*1.8)*.008*smoothstep(6,7,local)
			actor.model.sword.visible=age<.45 and shot==5
			actor.model.shield.visible=age<.75 and shot==5
		if shot==5:
			if local<3.5:
				view(Vector3(-8,3.6,31).lerp(Vector3(-6.8,2.8,29),smoothstep(0,3.5,local)),Vector3(0,1,23),56)
			elif local<6.5:
				view(Vector3(-6.8,1.8,25.8).lerp(Vector3(-7.4,1.15,24.8),smoothstep(3.5,6.5,local)),Vector3(-3.5,.85,21),47-3*smoothstep(3.5,6.5,local))
			else:
				view(Vector3(-8,1.4,25).lerp(Vector3(-7.2,.8,24),smoothstep(6.5,9.0,local)),Vector3(-3.8,.6,21),43)
	for i in range(knights.size()):
		var actor: Node3D=knights[i].node
		if not actor.visible: continue
		skins[i].apply(knights[i].gait)
		if shot in [5,6]: skins[i].ground(actor,forest)
		# Equipment shares the final grounded world transform.
		skins[i].apply(knights[i].gait)
	if wizard.visible:
		var left: Vector3=wizard_rig.left_arm.rotation
		var right: Vector3=wizard_rig.right_arm.rotation
		left.x=clampf(left.x,-.75,.75); left.z=clampf(left.z,-.10,.10)
		right.x=clampf(right.x,-.95,.95); right.z=clampf(right.z,-.08,.08)
		caster_skin.apply(null,left,right,wizard_rig.body.rotation)
		# The hand carries the staff; the wrist compensates to keep its shaft upright.
		staff.global_basis=wizard.global_basis*Basis.from_euler(Vector3(.035,0,sin(t*.7)*.06))
		if shot==4:
			var charge:=smoothstep(.7,4.8,u*10)
			var release:=smoothstep(5.0,7.5,u*10)
			curse.animate(u*10,staff.to_global(Vector3(0,1.72,0)),camera,charge,release,false,true)
	if shot==5:
		wave.animate(local,Vector3(0,forest.height_at(0,31)+.12,31),camera,1-smoothstep(4.5,8.0,local),clampf(local/3.0,0,1),true)
	for item in dropped:
		var prop: MeshInstance3D=item.mesh
		var delay: float=3.8 if item.actor==0 else .8+item.actor*.48
		var flight: float=clampf((local-delay-(.45 if item.kind=="sword" else .75))/.65,0,1)
		prop.visible=shot==5 and flight>0
		if not prop.visible: continue
		var at:=Vector3(-2.0 if item.actor%2==0 else 2.0,0,20.5+floorf(item.actor/2.0)*4.4)
		if item.kind=="shield": at+=Vector3(.45,0,.65)
		var bounds:=prop.mesh.get_aabb()
		var normal: Vector3=item.geometry.normal
		prop.basis=Basis(Vector3.UP,1.2+item.actor*.4)*Basis(Quaternion(normal,Vector3.UP))
		prop.basis=Basis(Vector3.RIGHT,(1-flight)*.6)*prop.basis
		prop.position=at-prop.basis*bounds.get_center()+Vector3.UP*((1-flight)*1.1+sin(flight*PI)*.25)
		var lift: float=-INF
		for point: Vector3 in item.geometry.points:
			var p: Vector3=prop.to_global(point)
			lift=maxf(lift,forest.height_at(p.x,p.z)+.02-p.y)
		if flight==1: prop.position.y+=lift
		else: prop.position.y=maxf(prop.position.y,prop.position.y+lift)
	# Short motivated cuts replace equal ten-second, uniformly eased camera holds.
	shade.color.a=maxf(1-smoothstep(0,.22,local),smoothstep(duration-.20,duration,local))

func preview() -> void:
	var path:="res://.tools/review/prologue-v7"
	DirAccess.make_dir_recursive_absolute(path)
	var times:=[45.2,51.6,57.7,63.2] if "--contact-preview" in OS.get_cmdline_user_args() else [12.0,15.5,22.5,24.3,25.4,41.3,45.2,49.6,51.6,55.7,57.7,60.0,63.2,67.0,73.5]
	for second in times:
		update_film(second)
		for tick in range(2): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_jpg(path+"/shot-"+str(second)+".jpg",.95)
		print("PROLOGUE_V7_PREVIEW ",second)
	quit()

func stream_frames() -> void:
	print("PROLOGUE_STREAM_STARTED")
	var frames: Array=[]
	if "--patch-soft-depth" in OS.get_cmdline_user_args():
		frames.append_array(range(1434,1770))
	elif "--patch-violet" in OS.get_cmdline_user_args():
		frames.append_array(range(300,600))
		frames.append_array(range(1164,1770))
	else: frames.append_array(range(2400))
	var received:=0
	for index in frames:
		update_film(float(index)/30.0)
		await process_frame
		await RenderingServer.frame_post_draw
		print("PROLOGUE_IMAGE ",Marshalls.raw_to_base64(root.get_texture().get_image().save_jpg_to_buffer(.98)))
		received+=1
		if received%120==0: print("PROLOGUE_V7_FRAME ",received,"/",frames.size())
	print("PROLOGUE_V7_COMPLETE ",received); quit()
