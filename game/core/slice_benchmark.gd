extends Node

# Opt-in local workload. Uses memory-only saves and restores runner HP so the
# timed route remains repeatable; it is not a clean-start human acceptance run.
var game: Node
var phase: String = ""
var active: bool = false
var started_at: int = 0
var last_attack: float = 0
var frames: Array[float] = []
var stage_frames: Dictionary = {}
var last_frame_usec: int = 0
var peaks := {"static_memory_bytes": 0.0, "video_memory_bytes": 0.0, "draw_calls": 0.0, "physics_ms": 0.0, "navigation_ms": 0.0}

func start(root: Node) -> void:
	game = root
	process_mode = Node.PROCESS_MODE_ALWAYS
	await game.start_selected()
	game.settings.restore_defaults()
	game.apply_settings()
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	started_at = Time.get_ticks_usec()
	last_frame_usec = started_at
	active = true
	phase = "refuge"
	await get_tree().create_timer(10, true).timeout
	await game.transition("region.village")
	game.player.position = Vector3(20, 0.1, 28)
	phase = "village_combat"
	await get_tree().create_timer(25, true).timeout
	await game.transition("region.crypt")
	game.player.position = Vector3(0, 0.1, 4)
	game.burial.actor.start()
	game.burial.actor.receive_hit(game.player.position, 230, 1, 0)
	phase = "boss_phase_two"
	await get_tree().create_timer(25, true).timeout
	active = false
	for action in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)
	var stages: Dictionary = {}
	for key in stage_frames:
		stages[key] = summarize(stage_frames[key])
	var report := {"engine": Engine.get_version_info().string, "exported": not OS.has_feature("editor"), "gpu": RenderingServer.get_video_adapter_name(), "cpu": OS.get_processor_name(), "viewport": get_viewport().get_visible_rect().size, "window_pixels": DisplayServer.window_get_size(), "render_texture_pixels": get_viewport().get_texture().get_size(), "renderer": ProjectSettings.get_setting("rendering/renderer/rendering_method"), "vsync": "enabled", "shadows": game.sun.shadow_enabled, "elapsed_seconds": (Time.get_ticks_usec() - started_at) / 1000000.0, "frame_times": summarize(frames), "stages": stages, "peaks": peaks, "limits": "Wall-clock intervals between rendered process callbacks. Scripted workload with HP replenishment and forced boss phase; no human victory/FPS guarantee. Not headless. Power mode/background tasks recorded separately."}
	DirAccess.make_dir_recursive_absolute("user://benchmarks")
	var file := FileAccess.open("user://benchmarks/slice.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	print("BENCHMARK COMPLETE: ", JSON.stringify(report))
	game.ui_sound.stop()
	game.player.sounds.stop()
	if is_instance_valid(game.burial):
		game.burial.actor.sounds.stop()
	await get_tree().create_timer(0.2, true).timeout
	get_tree().quit()

func _process(_delta: float) -> void:
	if not active:
		return
	var now: int = Time.get_ticks_usec()
	var frame_ms: float = (now - last_frame_usec) / 1000.0
	last_frame_usec = now
	frames.append(frame_ms)
	if not stage_frames.has(phase):
		stage_frames[phase] = []
	stage_frames[phase].append(frame_ms)
	peaks.static_memory_bytes = maxf(peaks.static_memory_bytes, Performance.get_monitor(Performance.MEMORY_STATIC))
	peaks.video_memory_bytes = maxf(peaks.video_memory_bytes, Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	peaks.draw_calls = maxf(peaks.draw_calls, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	peaks.physics_ms = maxf(peaks.physics_ms, Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000)
	peaks.navigation_ms = maxf(peaks.navigation_ms, Performance.get_monitor(Performance.TIME_NAVIGATION_PROCESS) * 1000)

func _physics_process(_delta: float) -> void:
	if not active or game.transitioning:
		return
	var time: float = (Time.get_ticks_usec() - started_at) / 1000000.0
	game.player.health = game.player.max_health
	var target := Vector3(0, 0, sin(time * 0.4) * 8)
	if phase == "village_combat":
		target = Vector3(20, 0, 18 + sin(time * 0.5) * 7)
	elif phase == "boss_phase_two":
		target = Vector3(sin(time * 0.8) * 4, 0, cos(time * 0.8) * 4)
		if game.burial.actor.health < 80:
			game.burial.actor.health = 207
	var offset: Vector3 = target - game.player.position
	offset.y = 0
	offset = offset.limit_length(1)
	for entry in [["move_right", maxf(offset.x, 0)], ["move_left", maxf(-offset.x, 0)], ["move_back", maxf(offset.z, 0)], ["move_forward", maxf(-offset.z, 0)]]:
		if entry[1] > 0.1:
			Input.action_press(entry[0], entry[1])
		else:
			Input.action_release(entry[0])
	if phase != "refuge" and time - last_attack > 1.3:
		game.player.combat.request_action("light_attack")
		last_attack = time

func summarize(samples: Array) -> Dictionary:
	if samples.is_empty():
		return {}
	var sorted := samples.duplicate()
	sorted.sort()
	var total: float = 0
	for value in samples:
		total += value
	return {"samples": samples.size(), "mean_fps": 1000.0 * samples.size() / total, "p50_ms": sorted[int((sorted.size() - 1) * 0.50)], "p95_ms": sorted[int((sorted.size() - 1) * 0.95)], "p99_ms": sorted[int((sorted.size() - 1) * 0.99)], "worst_ms": sorted.back()}
