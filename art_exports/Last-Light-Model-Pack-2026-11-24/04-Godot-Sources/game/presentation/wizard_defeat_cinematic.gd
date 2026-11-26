extends CanvasLayer
## Live arena choreography. Victory is already durable; this never grants rewards.
signal finished
const DURATION:=16.0
const Localizer=preload("res://game/localization/localizer.gd")
const Film=preload("res://game/presentation/film_script.gd")
var spoken_cue := -1
var spoken_language := ""
var game: Node
var wizard: CharacterBody3D
var camera: Camera3D
var previous_camera: Camera3D
var stage: Node3D
var clock:=0.0
var done:=false
var anchor:=Vector3.ZERO
var artifact:=Vector3.ZERO
var facing:=Basis.IDENTITY
var hero_transform: Transform3D
var hero_sword: Transform3D
var wizard_label_visible:=false
var world_labels: Array[Dictionary]=[]
var sparks: Array[MeshInstance3D]=[]
var light: OmniLight3D
var caption: Label
var fade: ColorRect
var pose: RefCounted

func setup(owner_game: Node, actor: CharacterBody3D) -> void:
	set_meta("score_theme", "dawn")
	game=owner_game; wizard=actor
	process_mode=Node.PROCESS_MODE_ALWAYS; layer=30
	anchor=wizard.global_position
	artifact=game.region.seal.global_position if is_instance_valid(game.region.seal) else anchor+Vector3(0,1,-5)
	var toward: Vector3=game.player.global_position-anchor; toward.y=0
	if toward.length_squared()<0.01: toward=Vector3.BACK
	facing=Basis.looking_at(toward.normalized(),Vector3.UP)
	hero_transform=game.player.visual.transform; hero_sword=game.player.sword_pivot.transform
	previous_camera=get_viewport().get_camera_3d()
	game.player.target=null; game.player.velocity=Vector3.ZERO
	game.player.combat.clear_buffer(); game.player.enabled=false
	game.player.sounds.stop()
	game.menu.hide(); game.dialogue.hide(); game.hud_overlay.hide(); game.hud_panel.hide()
	game.hud.hide()
	if is_instance_valid(game.mobile_controls): game.mobile_controls.release_all(); game.mobile_controls.hide()
	get_tree().paused=true; Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	wizard_label_visible=wizard.label.visible; wizard.label.hide()
	var meter:=wizard.get_node_or_null("HostileHealth") as Node3D
	if meter!=null: meter.hide()
	for warning in game.region.find_children("AttackTelegraph","MeshInstance3D",true,false): warning.hide()
	pose=preload("res://game/presentation/wizard_defeat_pose.gd").new(); pose.setup(wizard.visual)
	for node in game.region.find_children("*","Label3D",true,false):
		world_labels.append({"node":weakref(node),"visible":node.visible}); node.hide()
	stage=Node3D.new(); add_child(stage)
	camera=Camera3D.new(); camera.near=0.08; camera.far=6500; stage.add_child(camera)
	camera.make_current()
	light=OmniLight3D.new(); light.light_color=Color("b37aff")
	light.omni_range=8; light.shadow_enabled=false; stage.add_child(light)
	var material:=StandardMaterial3D.new()
	material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color=Color("bd8aff"); material.emission_enabled=true
	material.emission=Color("9955df"); material.emission_energy_multiplier=1.3
	var sphere:=SphereMesh.new(); sphere.radius=0.035; sphere.height=0.07
	sphere.radial_segments=8; sphere.rings=4
	for index in range(54):
		var spark:=MeshInstance3D.new(); spark.mesh=sphere; spark.material_override=material
		spark.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		stage.add_child(spark); sparks.append(spark)
	var screen:=Control.new(); screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.layout_direction=Control.LAYOUT_DIRECTION_LOCALE
	screen.theme=preload("res://game/presentation/ui_style.gd").theme(1.0); add_child(screen)
	for top in [true,false]:
		var bar:=ColorRect.new(); bar.color=Color.BLACK
		bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE if top else Control.PRESET_BOTTOM_WIDE)
		if top: bar.offset_bottom=50
		else: bar.offset_top=-105
		bar.mouse_filter=Control.MOUSE_FILTER_IGNORE; screen.add_child(bar)
	caption=Label.new(); caption.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	caption.offset_left=24; caption.offset_right=-24; caption.offset_top=-100; caption.offset_bottom=-12
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; caption.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size",22); screen.add_child(caption)
	var skip:=Button.new(); Localizer.set_text(skip,"Skip film")
	skip.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	skip.offset_left=-190; skip.offset_right=-18; skip.offset_top=10; skip.offset_bottom=66
	skip.pressed.connect(complete); screen.add_child(skip)
	fade=ColorRect.new(); fade.color=Color.BLACK
	fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter=Control.MOUSE_FILTER_IGNORE; screen.add_child(fade)
	advance(0)

func _process(delta: float) -> void:
	if done: return
	advance(minf(DURATION,clock+delta))
	if clock>=DURATION: complete()

func advance(time: float) -> void:
	clock=clampf(time,0,DURATION)
	var kneel:=smoothstep(1.6,4.6,clock)
	var collapse:=smoothstep(4.8,7.4,clock)
	pose.advance(kneel,collapse)
	wizard.visual.basis=facing*Basis.from_euler(Vector3(-0.25*kneel-1.18*collapse,0,sin(clock*2.0)*0.035*(1-collapse)))
	wizard.visual.position=Vector3(0,-0.65*kneel*(1-collapse)+0.12*collapse,0)
	wizard.staff.rotation=Vector3(-0.25*kneel,0,-0.8*kneel+0.5*collapse)
	var left:=wizard.visual.get_node_or_null("left_arm") as Node3D
	if left!=null: left.rotation=Vector3(-0.9*sin(kneel*PI)*(1-collapse),0,0.18*kneel)
	var hero_toward: Vector3=anchor-game.player.global_position; hero_toward.y=0
	if hero_toward.length_squared()>0.01:
		game.player.visual.basis=Basis.looking_at(hero_toward.normalized(),Vector3.UP)
	game.player.sword_pivot.rotation=hero_sword.basis.get_euler().lerp(Vector3(0,0,-0.32),smoothstep(0,3,clock))
	var view: Vector3
	var aim: Vector3
	if clock<3.3:
		var blend:=smoothstep(0,3.3,clock)
		view=anchor+facing*Vector3(1.8,1.75,lerpf(-4.6,-3.5,blend))
		aim=anchor+Vector3.UP*lerpf(2.1,1.65,blend); camera.fov=lerpf(49,43,blend)
	elif clock<7.8:
		var blend:=smoothstep(3.3,7.8,clock)
		view=anchor+facing*Vector3(lerpf(3.7,4.7,blend),lerpf(1.7,2.8,blend),-2.5)
		aim=anchor+Vector3.UP*lerpf(1.4,0.65,blend); camera.fov=51
	else:
		var blend:=smoothstep(7.8,DURATION,clock)
		var midpoint:=anchor.lerp(artifact,0.4)
		view=midpoint+facing*Vector3(lerpf(5,7,blend),lerpf(3.2,4.5,blend),lerpf(-6,-8,blend))
		aim=midpoint+Vector3.UP; camera.fov=lerpf(51,60,blend)
	# Keep the directed camera inside actual arena geometry.
	var ray:=PhysicsRayQueryParameters3D.create(aim,view,1)
	var hit: Dictionary=game.region.get_world_3d().direct_space_state.intersect_ray(ray)
	if not hit.is_empty(): view=hit.position+hit.normal*0.25
	camera.global_position=view; camera.look_at(aim)
	var release:=smoothstep(2.8,5.6,clock)*(1-smoothstep(8.0,10.5,clock))
	for index in range(sparks.size()):
		var progress:=fposmod(float(index%18)/18.0+clock*0.22,1.0)
		var angle:=progress*TAU*2.0+float(index/18)*TAU/3.0-clock
		var spread:=sin(progress*PI)*0.65
		var source:=anchor+Vector3.UP*(1.7-0.9*collapse)
		sparks[index].global_position=source.lerp(artifact,progress)+Vector3(cos(angle)*spread,sin(progress*PI)*1.6+sin(angle)*spread,0)
		sparks[index].scale=Vector3.ONE*release*(0.25+0.75*sin(progress*PI))
	light.global_position=(anchor+Vector3.UP).lerp(artifact,smoothstep(3,10,clock))
	light.light_energy=0.3+release*1.4
	var cue := 0 if clock<10 else 1
	if cue != spoken_cue or spoken_language != Localizer.language:
		spoken_cue = cue; spoken_language = Localizer.language
		Localizer.set_text(caption,Film.VICTORY[cue])
		game.voice.say(Film.VICTORY[cue],"narrator",self)
	fade.color.a=maxf(1-smoothstep(0,0.45,clock),smoothstep(DURATION-0.35,DURATION,clock))

func complete() -> void:
	if done: return
	done=true
	game.voice.stop_for(self)
	pose.restore()
	if is_instance_valid(wizard):
		wizard.restore_defeated()
		wizard.visual.position=Vector3.ZERO
		wizard.staff.rotation=Vector3.ZERO
		var left:=wizard.visual.get_node_or_null("left_arm") as Node3D
		if left!=null: left.rotation=Vector3.ZERO
		wizard.label.visible=wizard_label_visible
	if is_instance_valid(game.player):
		game.player.visual.transform=hero_transform
		game.player.sword_pivot.transform=hero_sword
	if is_instance_valid(previous_camera): previous_camera.make_current()
	for entry in world_labels:
		var node: Node3D=entry.node.get_ref()
		if is_instance_valid(node): node.visible=entry.visible
	finished.emit()
	queue_free()

func _exit_tree() -> void:
	if is_instance_valid(game) and is_instance_valid(game.voice): game.voice.stop_for(self)
