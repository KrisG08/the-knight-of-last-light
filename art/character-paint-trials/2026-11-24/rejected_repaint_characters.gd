extends SceneTree
## Offline material paint over existing geometry; original painted meshes stay intact.
const Models = preload("res://game/presentation/meshy_models.gd")
const ROOT = "res://assets/models/meshy/"
# Cloth, steel, skin/bone, trim. All pigments are authored in sRGB.
const PALETTES = {
	"knight":["bdb59f","6b7988","bf9675","a78347"],
	"oren":["b5a07d","5f6870","c39070","9a7645"],
	"lyra":["385840","596977","bd896b","a78a56"],
	"cael":["273e61","788693","b99579","a4864c"],
	"goblin":["653d2c","555c50","78864c","a68b50"],
	"gravedigger":["364535","444c49","b3ab8d","8b7045"],
	"maldrek":["362b42","4b4860","b7b1a0","92794d"],
	"fallen-commander":["662735","556579","a29a86","a5874d"],
	"iron-warden":["3c3029","515b67","9a8970","976e3f"],
	"thorn-beast":["3c3b2c","4e5c38","867252","bcb093"]}

func _initialize() -> void: call_deferred("repaint")

func paint(id: String, p: Vector3, normal: Vector3, palette: Array) -> Dictionary:
	var armored := id in ["knight","cael","fallen-commander","iron-warden"]
	var color: Color=palette[1] if armored else palette[0]
	var metal := .86 if armored else 0.0
	var rough := .43 if armored else .91
	var front := p.z<-.025
	var center := absf(p.x)<.15
	var skin := (p.y>.845 and p.y<.965 and front and absf(p.x)<.115)
	var leather := Color("503021")
	if armored:
		# Surcoats wrap the torso; upper Warden breastplate remains forged metal.
		if center and p.y>.34 and p.y<.81 and absf(p.z)>.045 and (id!="iron-warden" or p.y<.54):
			color=palette[0]; metal=0; rough=.91
		if absf(p.x)<.19 and p.y>.48 and p.y<.525:
			color=Color("34251f"); metal=0; rough=.75
		if absf(p.x)<.028 and p.y>.485 and p.y<.517 and front:
			color=palette[3]; metal=.78; rough=.41
		if p.y>.90 and p.y<.919 and p.z<-.065:
			color=Color("10171d"); metal=.12; rough=.74
		if id=="fallen-commander" and p.y>.952:
			color=palette[3]; metal=.78; rough=.45
		if id=="knight" and absf(p.x)<.012 and p.y>.955:
			color=palette[3]; metal=.78
		if id=="iron-warden" and metal>.5:
			var tarnish := smoothstep(.2,.85,sin(p.x*31+p.z*19)*sin(p.y*27))
			color=color.lerp(Color("805735"),tarnish*.28); rough=.53
		if id=="cael": skin=skin or (absf(p.x)>.18 and p.y>.27 and p.y<.48)
		else: skin=false
	else:
		if p.y<.45: color=Color("34382c") if id!="maldrek" else Color("34203e")
		if p.y<.16: color=Color("2f241e"); rough=.76
		if p.y>.465 and p.y<.505 and absf(p.x)<.19:
			color=Color("32221b"); rough=.74
		if id=="oren":
			if p.y>.3 and p.y<.78 and center:
				color=Color("69402b"); rough=.75
			if p.y>.3 and p.y<.78 and not front and absf(p.x)<.13:
				color=palette[0]; rough=.91
			skin=skin or (absf(p.x)>.2 and p.y>.32 and p.y<.7)
		if id=="lyra":
			if p.y>.47 and p.y<.74: color=leather; rough=.74
			if p.y>.74 and p.y<.85: color=palette[0]; rough=.91
			skin=skin or (absf(p.x)>.18 and p.y>.28 and p.y<.49)
		if id=="goblin":
			skin=p.y>.82 or (absf(p.x)>.21 and p.y>.27 and p.y<.78)
		if id=="gravedigger":
			skin=p.y>.85 and p.y<.94 and front and absf(p.x)<.065
			if p.y>.8 and not skin: color=Color("2a3b31")
			if absf(p.x+(p.y-.62)*.32)<.025 and p.y>.48 and p.y<.77 and front:
				color=leather; rough=.75
		if id=="maldrek":
			skin=skin and p.y>.82
			color=palette[0].lerp(Color("28263d"),smoothstep(.15,.5,absf(p.x)))
			if absf(absf(p.x)-.105)<.012 and p.y>.10 and p.y<.82:
				color=palette[3]; metal=.72; rough=.48
			if p.y>.08 and p.y<.105: color=palette[3]; metal=.72
	if skin: color=palette[2]; metal=0; rough=.64
	if id in ["oren","lyra","cael"]:
		var hair := p.y>.965 or (p.y>(.79 if id=="lyra" else .86) and p.z>.02)
		if hair:
			color=Color("241b18") if id=="lyra" else Color("655a4c"); metal=0; rough=.94
		if id in ["oren","cael"] and p.y>.848 and p.y<.888 and front and absf(p.x)<.07:
			color=Color("625547"); metal=0; rough=.94
		if p.y>.925 and p.y<.937 and front and absf(p.x)>.018 and absf(p.x)<.065:
			color=Color("28221d"); metal=0; rough=.94
	if id=="maldrek" and (p.y>.955 or (p.y>.83 and p.z>.005)):
		color=Color("8b8b83"); metal=0; rough=.93
	if id=="thorn-beast":
		metal=0; rough=.94
		color=palette[0].lerp(palette[1],clampf(normal.y*.6+sin(p.z*17)*.1,0,.6))
		if p.y>.78 or (p.y>.60 and absf(p.x)>.28):
			color=palette[3].lerp(Color("7c715a"),clampf((1-p.y)*1.2,0,.6)); rough=.73
		if p.z<-.47 and p.y>.35 and p.y<.67: color=palette[2]
		if p.y<.10: color=Color("29261f")
	# Dirt collects at hems rather than washing every material to the same brown.
	var dirt := (1-smoothstep(.05,.25,p.y))*.23
	color=color.lerp(Color("332d29"),dirt)
	color=color.srgb_to_linear(); color.a=metal
	return {"color":color,"roughness":rough}

func repaint() -> void:
	DirAccess.make_dir_recursive_absolute(ROOT+"repainted")
	for id: String in Models.HEIGHTS:
		var palette: Array=[]
		for hex: String in PALETTES[id]: palette.append(Color(hex))
		var definition: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(ROOT+id+".json"))
		var count := 0
		for part: String in definition.parts:
			var spec: Dictionary=definition.parts[part]
			var origin := Vector3(spec.origin[0],spec.origin[1],spec.origin[2])
			var source: ArrayMesh=load(ROOT+"painted/"+id+"-"+part+".res")
			var output := ArrayMesh.new()
			for surface in range(source.get_surface_count()):
				var arrays := source.surface_get_arrays(surface)
				var vertices: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
				var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
				var colors := PackedColorArray()
				var uv2: PackedVector2Array=arrays[Mesh.ARRAY_TEX_UV2]
				for index in range(vertices.size()):
					var p: Vector3 = (vertices[index]+origin)/Models.HEIGHTS[id]
					var pigment := paint(id,p,normals[index],palette)
					colors.append(pigment.color)
					uv2[index].x=pigment.roughness
					# Remove the old rear-facing photo reuse, keeping authored cavity.
					if normals[index].dot(Vector3(.342,0,-.94))<.12:
						uv2[index].y=fposmod(uv2[index].y,32.0)
					count+=1
				arrays[Mesh.ARRAY_COLOR]=colors; arrays[Mesh.ARRAY_TEX_UV2]=uv2
				output.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
			var path := ROOT+"repainted/"+id+"-"+part+".res"
			assert(ResourceSaver.save(output,path,ResourceSaver.FLAG_COMPRESS)==OK)
			spec.mesh=path
		definition.paint="Authored material pigments; front-only reference detail; rest-space PBR finish"
		definition.erase("surface_patch"); definition.erase("surface_patch_luminance")
		FileAccess.open(ROOT+id+".json",FileAccess.WRITE).store_string(JSON.stringify(definition,"\t"))
		print("REPAINTED ",id," vertices=",count)
	quit()
