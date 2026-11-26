extends SceneTree
func _initialize() -> void:
	var svg := FileAccess.get_file_as_string("res://assets/ui/lantern.svg")
	var image := Image.new()
	image.load_svg_from_string(svg, 4.0)
	image.save_png("res://assets/ui/mobile_icon.png")
	var mono := Image.new()
	mono.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="432" height="432" viewBox="0 0 128 128"><path d="M51 30V21a13 13 0 0 1 26 0v9M35 36h58L81 48H47zM47 48l-7 47h48l-7-47M35 101h58v9H35" fill="none" stroke="white" stroke-width="7" stroke-linejoin="round"/><path d="M64 48l14 26-14 17-14-17z" fill="white"/></svg>')
	mono.save_png("res://assets/ui/mobile_monochrome.png")
	quit()
