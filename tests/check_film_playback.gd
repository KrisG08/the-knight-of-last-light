extends SceneTree
var completed := false
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var film = preload("res://game/ui/opening_cinematic.gd").new()
	film.finished.connect(func(): completed=true)
	root.add_child(film)
	var arguments:=OS.get_cmdline_user_args()
	if "--silent-score" in arguments: film.score.stop()
	var start:=0.0
	for argument in arguments:
		if argument.begins_with("--start="): start=float(argument.trim_prefix("--start="))
		if argument.begins_with("res://") and argument.ends_with(".ogv"):
			film.video.stop()
			film.video.stream=load(argument) as VideoStream
			film.video.play()
	if start>0: film.video.stream_position=start
	var begin := Time.get_ticks_usec()
	var previous := begin
	var intervals: Array[float] = []
	var last_position := 0.0
	var advancing := false
	var duration: float = preload("res://game/presentation/film_script.gd").LENGTH
	for argument in arguments:
		if argument.begins_with("--duration="): duration=float(argument.trim_prefix("--duration="))
	while not completed and Time.get_ticks_usec()-begin<int((duration+10)*1000000):
		await process_frame
		var now := Time.get_ticks_usec()
		intervals.append((now-previous)/1000.0); previous=now
		if is_instance_valid(film):
			var position: float = film.video.stream_position
			advancing = advancing or position>last_position+0.001
			last_position=position
			if start>0 and position>=start+duration-.03: film.complete()
	var elapsed := (Time.get_ticks_usec()-begin)/1000000.0
	intervals.sort()
	print("Film playback mobile=",preload("res://game/presentation/mobile_controls.gd").requested()," completed=",completed," advancing=",advancing," position=",last_position," elapsed=",elapsed," frames=",intervals.size()," median/p95 ms=",intervals[intervals.size()/2]," / ",intervals[int(intervals.size()*0.95)])
	quit(0 if completed and advancing and elapsed>=duration-1 and elapsed<duration+3 else 1)
