extends RefCounted
## Offline UV authoring from the original project reference, not a runtime service.
var source: Image
var bounds: Rect2
var horizontal := Vector2(-0.4,0.4)
const RIGHT = Vector3(0.94,0,0.342)
const VIEW = Vector3(0.342,0,-0.94)

func setup(id: String, positions: PackedVector3Array) -> void:
	source = Image.new()
	assert(source.load_png_from_buffer(FileAccess.get_file_as_bytes("res://art/reference-pack/characters/"+id+".png"))==OK)
	var lo := Vector2(source.get_width(),source.get_height())
	var hi := Vector2.ZERO
	for y in range(0,source.get_height(),4):
		for x in range(0,source.get_width(),4):
			var color := source.get_pixel(x,y)
			if minf(color.r,minf(color.g,color.b))<0.56:
				lo = lo.min(Vector2(x,y)); hi = hi.max(Vector2(x,y))
	bounds = Rect2(lo,hi-lo)
	horizontal = Vector2(INF,-INF)
	for at in positions:
		var x := at.dot(RIGHT)
		horizontal.x = minf(horizontal.x,x); horizontal.y = maxf(horizontal.y,x)

func uv(at: Vector3) -> Vector2:
	var u := inverse_lerp(horizontal.x,horizontal.y,at.dot(RIGHT))
	return (bounds.position+Vector2(u,1.0-at.y)*bounds.size)/Vector2(source.get_size())

func sample(at: Vector3) -> Color:
	var coordinate := uv(at)*Vector2(source.get_size())
	return source.get_pixel(clampi(roundi(coordinate.x),0,source.get_width()-1),clampi(roundi(coordinate.y),0,source.get_height()-1))
