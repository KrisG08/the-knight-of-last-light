extends CanvasLayer

signal finished

const MOVIE_PATH = "res://assets/cinematics/opening_film.ogv"
const MOBILE_MOVIE_PATH = "res://assets/cinematics/opening_mobile.ogv"
var done: bool = false
var video: VideoStreamPlayer
var score: AudioStreamPlayer
var controls: HBoxContainer
var error_label: Label
var caption_mask: ColorRect
var caption_label: Label
var film_overlay: Control
const Film = preload("res://game/presentation/film_script.gd")
const CAPTIONS = Film.CAPTIONS
var voice: Node
var spoken_shot := -1
var spoken_language := ""
var previous_physics_step_budget := 8
var restored_timing := false

func _ready() -> void:
	# The world is paused. Avoid clipping the film clock when one decode/upload
	# takes longer than the gameplay physics catch-up budget permits.
	previous_physics_step_budget = Engine.max_physics_steps_per_frame
	Engine.max_physics_steps_per_frame = maxi(32, previous_physics_step_budget)
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30
	var screen := Control.new()
	screen.theme=preload("res://game/presentation/ui_style.gd").theme(1.0)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(screen)
	var background := ColorRect.new()
	background.color = Color.BLACK
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.add_child(background)
	var frame := AspectRatioContainer.new()
	frame.ratio = 16.0/9.0
	frame.stretch_mode = AspectRatioContainer.STRETCH_FIT
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.add_child(frame)
	video = VideoStreamPlayer.new()
	video.name = "OpeningFilm"
	video.expand = true
	video.bus = "Music"
	video.mouse_filter = Control.MOUSE_FILTER_IGNORE
	video.finished.connect(complete)
	frame.add_child(video)
	score = AudioStreamPlayer.new()
	score.name = "OpeningScore"
	score.stream = preload("res://assets/cinematics/opening_score.ogg")
	score.bus = "Music"
	add_child(score)
	# Localized native captions stay readable independently of the encoded movie.
	film_overlay=Control.new()
	film_overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE
	frame.add_child(film_overlay)
	caption_mask=ColorRect.new(); caption_mask.color=Color.BLACK
	caption_mask.mouse_filter=Control.MOUSE_FILTER_IGNORE
	caption_mask.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	film_overlay.add_child(caption_mask)
	caption_label=Label.new()
	caption_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption_label.offset_left=24; caption_label.offset_right=-24
	caption_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	caption_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	caption_label.mouse_filter=Control.MOUSE_FILTER_IGNORE
	caption_mask.add_child(caption_label)
	film_overlay.resized.connect(layout_captions)
	controls = HBoxContainer.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	controls.offset_left = -220
	controls.offset_top = 12
	controls.offset_right = -22
	controls.offset_bottom = 46
	screen.add_child(controls)
	var skip := Button.new()
	preload("res://game/localization/localizer.gd").set_text(skip, "Skip film · Esc")
	skip.custom_minimum_size = Vector2(198,34)
	if preload("res://game/presentation/mobile_controls.gd").requested():
		controls.offset_top = 18
		controls.offset_bottom = 74
		skip.custom_minimum_size.y = 56
		preload("res://game/localization/localizer.gd").set_text(skip, "Skip film")
	skip.pressed.connect(complete)
	controls.add_child(skip)
	error_label = Label.new()
	preload("res://game/localization/localizer.gd").set_text(error_label, "The opening film could not be loaded. Continue to the camp.")
	error_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	error_label.offset_left = -320
	error_label.offset_right = 320
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error_label.hide()
	screen.add_child(error_label)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var path: String = MOBILE_MOVIE_PATH if preload("res://game/presentation/mobile_controls.gd").requested() else MOVIE_PATH
	# Desktop exports omit the mobile encode, but may still be reviewed with --touch.
	if not ResourceLoader.exists(path): path=MOVIE_PATH
	if ResourceLoader.exists(path):
		video.stream = load(path) as VideoStream
	if video.stream != null:
		video.play()
		score.play()
	else:
		error_label.show()
		preload("res://game/localization/localizer.gd").set_text(skip, "Continue to camp")
		caption_mask.hide()

func layout_captions() -> void:
	var height := film_overlay.size.y
	caption_mask.offset_top=-height*132.0/1080.0
	caption_label.add_theme_font_size_override("font_size",maxi(12,roundi(height*30.0/1080.0)))

func _process(delta: float) -> void:
	if done or video.stream==null: return
	var time := video.stream_position
	var shot := Film.shot(time)
	var language: String = preload("res://game/localization/localizer.gd").language
	if shot != spoken_shot or language != spoken_language:
		preload("res://game/localization/localizer.gd").set_text(caption_label,CAPTIONS[shot])
		spoken_shot = shot; spoken_language = language
		if is_instance_valid(voice): voice.say(CAPTIONS[shot],"narrator",self)
	var score_level := -9.0 if is_instance_valid(voice) and voice.speaking() else 0.0
	score.volume_db = move_toward(score.volume_db,score_level,delta*30)
	var local: float=time-Film.STARTS[shot]
	var duration: float=Film.DURATIONS[shot]
	caption_label.modulate.a=1.0-maxf(clampf(1.0-local/0.6,0,1),clampf((local-duration+0.5)/0.5,0,1))

func complete() -> void:
	if done:
		return
	done = true
	if is_instance_valid(voice): voice.stop_for(self)
	video.stop()
	score.stop()
	finished.emit()
	queue_free()

func _exit_tree() -> void:
	if is_instance_valid(voice): voice.stop_for(self)
	if not restored_timing:
		Engine.max_physics_steps_per_frame = previous_physics_step_budget
		restored_timing = true
