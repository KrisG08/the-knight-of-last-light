extends SceneTree
## Fits paired rear reference projections without changing geometry or original paint.
const Models=preload("res://game/presentation/meshy_models.gd")
func _initialize() -> void:
	for id: String in Models.HEIGHTS:
		var path := Models.ROOT+"rear-reference-colors/"+id+".png"
		if not FileAccess.file_exists(path): continue
		var image := Image.new()
		assert(image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))==OK)
		var has_alpha := image.detect_alpha()!=Image.ALPHA_NONE
		var lo := Vector2(image.get_width(),image.get_height()); var hi := Vector2.ZERO
		for y in range(0,image.get_height(),2):
			for x in range(0,image.get_width(),2):
				var pixel := image.get_pixel(x,y)
				var foreground := pixel.a>.82 if has_alpha else minf(pixel.r,minf(pixel.g,pixel.b))<.56
				if foreground: lo=lo.min(Vector2(x,y)); hi=hi.max(Vector2(x,y))
		var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(Models.ROOT+id+".json"))
		var min_x := INF; var max_x := -INF
		for part: String in data.parts:
			var spec: Dictionary=data.parts[part]
			var origin := Vector3(spec.origin[0],spec.origin[1],spec.origin[2])
			var mesh: ArrayMesh=load(spec.mesh)
			for s in range(mesh.get_surface_count()):
				for vertex: Vector3 in mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]:
					var x: float=(vertex.x+origin.x)/Models.HEIGHTS[id]
					min_x=minf(min_x,x); max_x=maxf(max_x,x)
		var size := Vector2(image.get_size())
		var at := lo/size; var extent := (hi-lo)/size
		data.rear_projection={"rect":[at.x,at.y,extent.x,extent.y],"x_bounds":[min_x,max_x],"alpha":has_alpha}
		FileAccess.open(Models.ROOT+id+".json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
		print("PAIRED REFERENCE FIT ",id)
	quit()
