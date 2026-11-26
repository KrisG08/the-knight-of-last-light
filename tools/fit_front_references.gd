extends SceneTree
## Offline fit of mesh-guided front references; original geometry/UVs stay intact.
const Models=preload("res://game/presentation/meshy_models.gd")
func _initialize() -> void:
	for id: String in Models.HEIGHTS:
		var path := Models.ROOT+"front-reference-colors/"+id+".png"
		if not FileAccess.file_exists(path): continue
		var image := Image.new()
		assert(image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))==OK)
		assert(image.detect_alpha()!=Image.ALPHA_NONE,"Front references require alpha")
		if "--masks-only" in OS.get_cmdline_user_args():
			var mask := PackedByteArray(); mask.resize(512*512)
			for y in range(512):
				for x in range(512):
					var px := int((x+.5)*image.get_width()/512.0)
					var py := int((y+.5)*image.get_height()/512.0)
					mask[y*512+x]=1 if image.get_pixel(px,py).a>.95 else 0
			DirAccess.make_dir_recursive_absolute("res://.tools/review/front-uv-coverage")
			FileAccess.open("res://.tools/review/front-uv-coverage/"+id+".mask",FileAccess.WRITE).store_buffer(mask)
			print("FRONT COVERAGE MASK ",id)
			continue
		var lo := Vector2(image.get_width(),image.get_height()); var hi := Vector2.ZERO
		for y in range(0,image.get_height(),2):
			for x in range(0,image.get_width(),2):
				if image.get_pixel(x,y).a>.82:
					lo=lo.min(Vector2(x,y)); hi=hi.max(Vector2(x,y))
		assert(hi.x>lo.x and hi.y>lo.y)
		var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(Models.ROOT+id+".json"))
		var size := Vector2(image.get_size())
		var at := lo/size; var extent := (hi-lo)/size
		data.front_projection={"rect":[at.x,at.y,extent.x,extent.y],"x_bounds":data.rear_projection.x_bounds,"alpha":true}
		var lookup := FileAccess.get_file_as_bytes("res://.tools/review/front-uv-coverage/"+id+".bin")
		assert(lookup.size()==512*512*4,"Missing generated UV coverage coordinates")
		var coordinate_image := Image.create_from_data(512,512,false,Image.FORMAT_RGBA8,lookup)
		var coordinate_texture := ImageTexture.create_from_image(coordinate_image)
		DirAccess.make_dir_recursive_absolute(Models.ROOT+"front-uv-coverage")
		assert(ResourceSaver.save(coordinate_texture,Models.ROOT+"front-uv-coverage/"+id+".res",ResourceSaver.FLAG_COMPRESS)==OK)
		FileAccess.open(Models.ROOT+id+".json",FileAccess.WRITE).store_string(JSON.stringify(data,"\t"))
		print("FRONT REFERENCE FIT ",id)
	quit()
