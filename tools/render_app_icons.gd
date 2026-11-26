extends SceneTree

const ICON := "res://assets/ui/last-light-icon.svg"
const HELMET := "<path xmlns=\"http://www.w3.org/2000/svg\" d=\"M64 32 88 47 92 77 79 93 64 99 49 93 36 77 40 47Z M43 56 43 63 60 70 60 64Z M85 56 68 64 68 70 85 63Z\" fill=\"white\" fill-rule=\"evenodd\"/>"

func _initialize() -> void:
	var source := FileAccess.get_file_as_string(ICON)
	var legacy := Image.new()
	var adaptive := Image.new()
	var monochrome := Image.new()
	var foreground := source.substr(source.find("<path"))
	foreground = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"432\" height=\"432\" viewBox=\"0 0 128 128\">" + "<defs>" + source.get_slice("</defs>", 0).get_slice("<defs>", 1) + "</defs>" + foreground
	var mask := "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"432\" height=\"432\" viewBox=\"0 0 128 128\">" + HELMET + "</svg>"
	if legacy.load_svg_from_string(source, 192.0 / 432.0) != OK or adaptive.load_svg_from_string(foreground) != OK or monochrome.load_svg_from_string(mask) != OK:
		quit(1)
		return
	var background := Image.create_empty(432, 432, false, Image.FORMAT_RGBA8)
	background.fill(Color("#22192f"))
	var failed := false
	for entry in [[legacy, "launcher"], [adaptive, "foreground"], [monochrome, "monochrome"], [background, "background"]]:
		if entry[0].save_png("res://assets/ui/last-light-" + entry[1] + ".png") != OK:
			failed = true
	quit(1 if failed else 0)
