extends SceneTree

# Offline, deterministic 1080p/60 cinematic. Render once, decode at runtime.
const Region = preload("res://game/world/regions/graybox_region.gd")
const Knight = preload("res://game/actors/player/knight.gd")
const Art = preload("res://game/presentation/art_kit.gd")
const Palette=preload("res://game/presentation/curse_palette.gd")
const Film = preload("res://tools/legacy_opening_timeline.gd")
var world: Node3D
var camera: Camera3D
var knights: Array[Dictionary] = []
var wizard: Node3D
var staff: Node3D
var curse: Node3D
var wave: Node3D
var wizard_rig: Dictionary
var glow: OmniLight3D
var subtitle: Label
var shade: ColorRect
var time: float = 0
var frame: int = 0
const FPS := 60.0
var forest: Node3D
var fortress: Node3D

func _initialize() -> void:
	call_deferred("setup")

func setup() -> void:
	root.size=Vector2i(2560,1440)
	root.content_scale_size=Vector2i(1920,1080)
	root.msaa_3d=Viewport.MSAA_8X
	world = Node3D.new()
	root.add_child(world)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ShaderMaterial.new()
	sky_material.shader = preload("res://assets/materials/storm_sky.gdshader")
	sky_material.set_shader_parameter("cloud_panorama",preload("res://assets/sky/storm-panorama-v1.png"))
	sky_material.set_shader_parameter("moon_texture",preload("res://assets/sky/curse-moon-v1.png"))
	sky_material.set_shader_parameter("horizon_color",Color("1b272e"))
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("8baba7")
	environment.ambient_light_energy = 0.45
	environment.fog_enabled = true
	environment.fog_density = 0.004
	environment.fog_sky_affect = 0
	environment.fog_light_color = Color("1b272e")
	environment.tonemap_mode=Environment.TONE_MAPPER_FILMIC
	var atmosphere := WorldEnvironment.new()
	atmosphere.environment = environment
	world.add_child(atmosphere)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-30,-40,0)
	sun.light_color = Color("b5c9ce")
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance=120
	world.add_child(sun)
	preload("res://game/presentation/region_look.gd").apply(environment,sun,"region.refuge",false)
	environment.ambient_light_energy=.48
	sun.light_energy=.85
	var rim := DirectionalLight3D.new()
	rim.rotation_degrees=Vector3(-18,125,0); rim.light_color=Color("d4badf"); rim.light_energy=.3
	world.add_child(rim)
	forest = Region.new()
	world.add_child(forest)
	forest.build("region.refuge")
	fortress=Region.new(); world.add_child(fortress); fortress.build("region.citadel")
	fortress.hide()
	for region in [forest,fortress]:
		preload("res://game/presentation/forest_horizon.gd").atmosphere(region,environment.fog_light_color)
		for label in region.find_children("*","Label3D",true,false): label.hide()
		for inhabitants in region.find_children("MythicFauna","Node3D",true,false): inhabitants.hide()
		# Journey waygates and quest prompts belong to play, not the historical film.
		for portals in region.find_children("RegionPortals","Node3D",true,false): portals.hide()
	for item in forest.find_children("*","Label3D",true,false):
		item.hide()
	for item in [forest.oren,forest.lyra,forest.cael,forest.rescued_survivors]:
		item.hide()
	# Clear foreground rocks only for this film's formation/camera corridor.
	for item in forest.get_node("PhotogrammetryDressing").get_children():
		if item.position.z>4 and item.position.z<45 and absf(item.position.x)<19:
			var meshes := item.find_children("*","MeshInstance3D",true,false)
			if not meshes.is_empty() and String(meshes[0].mesh.resource_name).contains("rock"):
				item.hide()
	for index in range(4):
		var knight := Knight.new()
		world.add_child(knight)
		knight.set_physics_process(false); knight.set_process_unhandled_input(false)
		knight.enabled=true; knight.collision_layer=0; knight.collision_mask=0
		var gait = knight.model.skeletal_locomotion
		gait.set_process(false); gait.animation.active=false
		knights.append({"node":knight,"gait":gait,"weapon":knight.sword_pivot})
	build_wizard()
	curse = preload("res://tools/film_curse.gd").new(); world.add_child(curse)
	wave = preload("res://tools/film_curse.gd").new(); world.add_child(wave)
	glow = OmniLight3D.new()
	glow.light_color = Palette.LIGHT
	glow.omni_range = 24
	world.add_child(glow)
	camera = Camera3D.new()
	camera.fov = 54
	camera.far=6500
	camera.current = true
	camera.attributes = CameraAttributesPractical.new()
	world.add_child(camera)
	build_overlay()
	update_film(0)
	print("FILM_RENDER_READY: 2400 frames at 60 fps / 2560x1440")
	if "--preview" in OS.get_cmdline_user_args(): preview.call_deferred()

func preview() -> void:
	DirAccess.make_dir_recursive_absolute("res://.tools/review/opening-v5")
	for second in [1.0,3.0,5.5,8.3,10.0,15.0,23.0,26.0,33.0,37.0]:
		update_film(second)
		for tick in range(8): await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.tools/review/opening-v5/shot-"+str(second).replace(".","-")+".png")
	quit()

func build_wizard() -> void:
	wizard = Node3D.new()
	wizard.position = fortress.surface_point(Vector3(0,0,-54))
	world.add_child(wizard)
	wizard_rig = preload("res://game/presentation/meshy_models.gd").build(wizard,"maldrek")
	staff = Node3D.new()
	wizard_rig.right_arm.add_child(staff)
	var bounds: AABB=wizard_rig.right_arm.get_child(0).mesh.get_aabb()
	staff.position=bounds.position+Vector3(bounds.size.x*0.5,bounds.size.y*0.15,bounds.size.z*0.5)
	var emissive := Art.material("film_curse_gem_violet",Palette.LIGHT)
	emissive.emission_enabled = true
	emissive.emission = Palette.GLOW
	emissive.emission_energy_multiplier = 1.7
	preload("res://game/presentation/hostile_models.gd").weapon(staff,"maldrek",emissive)

func build_overlay() -> void:
	var layer := CanvasLayer.new()
	world.add_child(layer)
	for top in [true,false]:
		var bar := ColorRect.new()
		bar.color = Color.BLACK
		bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE if top else Control.PRESET_BOTTOM_WIDE)
		if top:
			bar.offset_bottom = 48
		else:
			bar.offset_top = -92
		layer.add_child(bar)
	# All captions are now native localized overlays, never baked English text.
	subtitle = Label.new()
	subtitle.hide()
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	subtitle.offset_left = 55
	subtitle.offset_right = -55
	subtitle.offset_top = -78
	subtitle.offset_bottom = -14
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_override("font",preload("res://game/presentation/ui_style.gd").BODY_FONT)
	subtitle.add_theme_font_size_override("font_size",30)
	layer.add_child(subtitle)
	shade = ColorRect.new()
	shade.color = Color.BLACK
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(shade)

func _process(_delta: float) -> bool:
	if "--preview" in OS.get_cmdline_user_args(): return false
	if not is_instance_valid(camera):
		return false
	# Exact frame time makes animation independent of offline render speed.
	time = frame/FPS
	update_film(time)
	frame += 1
	if frame%120==0:
		print("FILM_RENDER_FRAME: ",frame)
	return false

func update_film(t: float) -> void:
	var shot := Film.shot(t)
	var actual_local: float = t-Film.STARTS[shot]
	var duration: float = Film.DURATIONS[shot]
	var progress: float = clampf(actual_local/duration,0,1)
	# Retain authored poses but give each story beat time for localized narration.
	var local: float = progress*[8.0,8.0,6.0,8.0][shot]
	fortress.visible=shot==0
	forest.visible=shot!=0
	shade.color.a = maxf(clampf(1-actual_local/0.6,0,1),clampf((actual_local-duration+0.5)/0.5,0,1))
	wizard.visible = shot==0
	curse.visible = shot==0
	wave.visible = shot==2
	staff.rotation.z = -smoothstep(0,1,progress)*0.8
	# Establish the actual expanded fortress before cutting into the spell performance.
	var casting := smoothstep(2.7,4.5,local) if shot==0 else 0.0
	var release := smoothstep(5.3,7.3,local) if shot==0 else 0.0
	wizard_rig.right_arm.rotation=Vector3(casting*(1.05+release*0.3),sin(local*1.7)*casting*0.08,casting*0.45)
	wizard_rig.left_arm.rotation=Vector3(casting*0.8,casting*(0.3+sin(local*1.2)*0.12),-casting*0.65)
	wizard.rotation.y=casting*0.12-release*0.3
	wizard_rig.body.rotation.x=-casting*0.07+sin(t*1.7)*0.006
	if shot==0: curse.animate(local,staff.to_global(Vector3(0,1.72,0)),camera,casting,release)
	glow.position = wizard.position+Vector3.UP*2.6 if shot==0 else Vector3(2,2,18)
	glow.light_energy = (1.3+sin(t*3)*0.3) if shot in [0,2] else 0
	for index in range(knights.size()):
		var rig: Dictionary = knights[index]
		var actor: Node3D = rig.node
		actor.visible = shot in [1,2] or (shot==3 and index==0)
		actor.rotation = Vector3.ZERO
		var march: float = progress if shot==1 else 1.0
		actor.position = Vector3(-7,0,30).lerp(Vector3(5,0,12),march)+Vector3(0.832,0,0.555)*((index%2)*1.3-0.65)+Vector3(-0.555,0,0.832)*floorf(index/2.0)*2.8
		actor.rotation.y = -0.53
		actor.position.y=forest.height_at(actor.position.x,actor.position.z)
		var gait = rig.gait
		for side in range(2):
			var angles: Vector3 = gait.pose(fposmod((local+index*0.11)/0.72+side*0.5,1.0))*0.9 if shot==1 else Vector3.ZERO
			for joint in range(3): gait.skeleton.set_bone_pose_rotation(side*3+joint,Quaternion(Vector3.RIGHT,angles[joint]))
		gait.upper_body.clock=t+index
		gait.upper_body.advance(1.0/FPS,shot==1,false)
		if shot==1:
			actor.position.y += absf(sin(local*TAU/0.72+index))*0.025
		elif shot==2:
			var age := maxf(0,local-0.5-index*0.18)
			actor.position += Vector3((1 if index%2 else -1)*smoothstep(0.4,2.5,age)*1.0,0,smoothstep(0,1.5,age)*0.7)
			preload("res://tools/film_body_motion.gd").pose(actor,gait,age,false,-1.0 if index%2==0 else 1.0)
		elif shot==3:
			actor.position = Vector3(1,0.05,82)
			actor.rotation.y = sin(t*0.8)*0.04
			actor.position.y=forest.height_at(1,82)+0.025
			rig.weapon.rotation = Vector3.ZERO
			preload("res://tools/film_body_motion.gd").pose(actor,gait,local,true,-1.0)
			# Subtle recovery, breathing and a look toward the road after standing.
			gait.upper_body.chest.rotation.y += smoothstep(6.0,8.0,local)*sin(local*.8)*.045
			gait.upper_body.chest.rotation.x += sin(t*2.1)*.009
	if shot==0:
		if local<2.6:
			var approach:=smoothstep(0,2.6,local)
			camera.position=Vector3(112,108,150).lerp(Vector3(77,96,110),approach)
			camera.fov=lerpf(58,53,approach)
			camera.look_at(Vector3(0,66,-44))
		else:
			var close := Vector3(3.0,2.7,6)
			camera.position = wizard.position+Vector3(6.5,3.6,10).lerp(close,smoothstep(2.6,5.2,local)).lerp(Vector3(11,6,16),release)+Vector3(sin(local*.7)*.3,0,0)
			camera.fov=lerpf(53,43,casting)+release*14
			camera.look_at(wizard.position+Vector3.UP*(1.7+casting*0.4))
		subtitle.text = "Maldrek seized the citadel. Through four ancient seals, his curse reached the kingdom."
	elif shot==1:
		camera.fov=lerpf(58,48,smoothstep(0,1,progress))
		var leader: Vector3 = knights[0].node.position
		var formation := leader+Vector3(0.65,0,3.0)
		camera.position = formation+Vector3(-6+progress,2.6,9)
		camera.look_at(formation+Vector3(0,1.15,0))
		subtitle.text = "The Order marched along the old forest road. You went with them."
	elif shot==2:
		var shock := smoothstep(0,1.2,local)
		camera.position=Vector3(1,2.0,20).lerp(Vector3(-2,3.8,24),shock).lerp(Vector3(1,2.3,21),smoothstep(2.5,6,local))
		camera.fov=lerpf(43,56,shock)-smoothstep(3,6,local)*8
		camera.look_at(Vector3(4,1.1-smoothstep(0.8,3,local)*0.7,15))
		wave.animate(local,Vector3(2,0.1,22),camera,1.0-smoothstep(3.8,5.8,local),smoothstep(0,1.6,local),true)
		subtitle.text = "The curse broke the expedition. Beneath the eclipse, the road fell silent."
	else:
		var rise := smoothstep(2,6.8,local)
		camera.position = Vector3(4,0.9,86).lerp(Vector3(2.5,2.2,85.5),rise).lerp(Vector3(4,2.7,88),smoothstep(6.5,8,local))
		camera.fov=lerpf(48,38,rise)+smoothstep(6.5,8,local)*14
		camera.look_at(Vector3(1,0.45+rise*0.95,82))
		subtitle.text = "You survived. One lantern still burns. Find the others."
