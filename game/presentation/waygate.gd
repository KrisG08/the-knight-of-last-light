extends Node3D
## Decorative waygate. The existing point/interaction/collider owns all travel.
const Art=preload("res://game/presentation/art_kit.gd")
const Kit=preload("res://game/presentation/village_kit.gd")
var key: String
var family: String
var accessible:=true
var surface: MeshInstance3D
var filaments: MeshInstance3D
var motes: CPUParticles3D
var lock_mark: Node3D
var vortex_material: ShaderMaterial
var filament_material: ShaderMaterial
var effect_active:=true
var width:=3.2
var height:=5.2

func setup(point_key: String, style: String, dimensions: Vector2) -> void:
	key=point_key; family=style; width=dimensions.x; height=dimensions.y
	name="Portal_"+key
	frame()
	vortex_material=ShaderMaterial.new()
	vortex_material.shader=preload("res://assets/materials/waygate_vortex.gdshader")
	vortex_material.set_shader_parameter("gate_seed",float(absi(key.hash())%100)/17.0)
	vortex_material.set_shader_parameter("aspect",height/width)
	surface=Art.mesh(self,aperture(),Vector3(0,0,0.08),vortex_material)
	surface.name="VortexAperture"; surface.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	surface.visibility_range_end=58
	filament_material=ShaderMaterial.new()
	filament_material.shader=preload("res://assets/materials/waygate_filament.gdshader")
	filaments=Art.mesh(self,spirals(),Vector3.ZERO,filament_material)
	filaments.scale=Vector3(width/3.2,height/5.2,1)
	filaments.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF; filaments.visibility_range_end=28
	particles()
	lock_mark=Node3D.new(); lock_mark.name="ClosedSigil"; add_child(lock_mark)
	var batches: Dictionary={}
	for angle in [-PI/4,PI/4]:
		Kit.piece(batches,rune_material(),Vector3(0,height*0.48,0.16),Vector3(width*0.52,0.065,0.08),Basis(Vector3.BACK,angle))
	Kit.flush(lock_mark,batches); lock_mark.hide()

func aperture() -> Mesh:
	var outline: Array[Vector2]=[Vector2(-width*0.5,0),Vector2(width*0.5,0),Vector2(width*0.5,height*0.60)]
	for index in range(1,25):
		var t: float=index/24.0
		outline.append(Vector2(width*0.5*(1-t),height*(0.60+0.40*sqrt(t))))
	for index in range(23,-1,-1):
		var t: float=index/24.0
		outline.append(Vector2(-width*0.5*(1-t),height*(0.60+0.40*sqrt(t))))
	var mesh:=SurfaceTool.new(); mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	var center:=Vector2(0,height*0.48)
	for index in range(outline.size()):
		for point in [center,outline[index],outline[(index+1)%outline.size()]]:
			mesh.set_uv(Vector2(point.x/width+0.5,1-point.y/height))
			mesh.add_vertex(Vector3(point.x,point.y,0))
	mesh.generate_normals(); return mesh.commit()

func spirals() -> Mesh:
	var mesh:=SurfaceTool.new(); mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
	for arm in range(3):
		for step in range(96):
			for corner in [Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]:
				var t: float=(step+corner.y)/96.0
				var radius:=0.06+t*1.30
				var angle: float=arm*TAU/3+t*TAU*1.9
				var across: float=(corner.x-0.5)*(0.018+t*0.055)
				mesh.set_uv(Vector2(corner.x,t))
				mesh.add_vertex(Vector3(sin(angle)*(radius+across),2.35+cos(angle)*(radius+across),0.16+(1-t)*0.45))
	mesh.generate_normals(); return mesh.commit()

static func rune_material() -> Material:
	var mat:=Art.material("waygate_runes",Color("a975d5"),0.35)
	mat.emission_enabled=true; mat.emission=Color("8c35d1"); mat.emission_energy_multiplier=0.7
	return mat

func frame() -> void:
	var stone:=Art.stone().duplicate() as StandardMaterial3D
	stone.albedo_color=Color("62705b") if family=="roots" else (Color("59616d") if family=="iron" else (Color("768087") if family=="gothic" else Color("797469")))
	var batches: Dictionary={}
	for depth in [-0.35,0.0,0.24]:
		Art.pointed_arch(self,Vector3(0,0,depth),width+0.20+(0.24-depth)*0.7,height+0.2+(0.24-depth)*0.45)
	for side in [-1,1]:
		var x: float=side*(width*0.5+0.57)
		Art.cylinder(self,Vector3(x,height*0.29,0),0.28,0.22,height*0.58,stone,12)
		for y in [0.15,height*0.57]:
			Art.cylinder(self,Vector3(x,y,0),0.42,0.42,0.22,stone,12)
		Kit.piece(batches,stone,Vector3(x,0.12,0),Vector3(0.95,0.24,1.4))
		if family=="gothic":
			Art.cylinder(self,Vector3(x,height*0.72,0),0.32,0.0,height*0.28,stone,8)
		for row in range(5):
			var at:=Vector3(side*(width*0.5+0.13),0.65+row*height*0.10,0.64)
			# Carved angular sigils are geometry, independent of font glyph support.
			for angle in [PI/4,-PI/4]:
				Kit.piece(batches,rune_material(),at+Vector3(0,angle*0.06,0),Vector3(0.17,0.028,0.03),Basis(Vector3.BACK,angle))
			Kit.piece(batches,rune_material(),at+Vector3(side*0.06,0.02,0),Vector3(0.025,0.19 if row%2==0 else 0.11,0.03))
		if family=="roots":
			var previous:=Vector3(side*(width*0.5+0.9),0,-0.2)
			for index in range(7):
				var next:=Vector3(side*(width*0.5+0.65+sin(index*0.9)*0.24),(index+1)*height/8,cos(index*0.8)*0.3)
				Art.beam(self,previous,next,0.16-index*0.013,Kit.wood()); previous=next
		if family=="iron":
			for y in [0.5,1.4,2.3,3.2]:
				Kit.piece(batches,Art.material("iron",Color("243239"),0.75),Vector3(x,y,0.31),Vector3(0.72,0.16,0.18))
		if family=="tomb":
			Kit.piece(batches,stone,Vector3(x,height*0.65,-0.28),Vector3(0.65,0.3,1.2))
	Kit.flush(self,batches)
	# Frame meshes remain cosmetic; no new collision or navigation authority.
	for item in find_children("*","GeometryInstance3D",true,false):
		item.visibility_range_end=85
		if item.material_override==Art.stone(): item.material_override=stone

func particles() -> void:
	motes=CPUParticles3D.new(); motes.name="RiftMotes"
	motes.amount=18; motes.lifetime=2.8; motes.preprocess=1.0
	motes.emission_shape=CPUParticles3D.EMISSION_SHAPE_BOX
	motes.emission_box_extents=Vector3(width*0.43,height*0.38,0.12)
	motes.position=Vector3(0,height*0.46,0.30)
	motes.direction=Vector3.UP; motes.spread=45; motes.gravity=Vector3(0,0.06,0.02)
	motes.initial_velocity_min=0.06; motes.initial_velocity_max=0.18
	motes.scale_amount_min=0.04; motes.scale_amount_max=0.09
	motes.local_coords=true; motes.visibility_range_end=24
	motes.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var quad:=QuadMesh.new(); quad.size=Vector2(0.10,0.16)
	quad.material=preload("res://game/presentation/curse_presence.gd").material()
	motes.mesh=quad
	var ramp:=Gradient.new(); ramp.colors=PackedColorArray([Color(1,1,1,0),Color(1,1,1,0.7),Color(1,1,1,0)])
	ramp.offsets=PackedFloat32Array([0,0.3,1]); motes.color_ramp=ramp
	add_child(motes)

func set_accessible(value: bool) -> void:
	accessible=value
	vortex_material.set_shader_parameter("openness",1.0 if value else 0.18)
	filament_material.set_shader_parameter("openness",1.0 if value else 0.12)
	lock_mark.visible=not value

func set_nearby(value: bool) -> void:
	if effect_active==value: return
	effect_active=value
	filaments.visible=value; motes.emitting=value
