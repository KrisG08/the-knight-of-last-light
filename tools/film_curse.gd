extends Node3D
## Offline animated filaments: gathering spell, branching release and ground veins.
var ribbons: MeshInstance3D
var embers: Array[MeshInstance3D] = []
var mist: Array[MeshInstance3D] = []
func _ready() -> void:
	ribbons=MeshInstance3D.new(); add_child(ribbons)
	ribbons.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code="shader_type spatial; render_mode unshaded,cull_disabled,depth_draw_never; void fragment(){float edge=pow(max(0.0,1.0-abs(UV.x*2.0-1.0)),1.6); ALBEDO=COLOR.rgb; ALPHA=COLOR.a*edge;}"
	material.shader=shader
	ribbons.material_override=material
	var spark := SphereMesh.new(); spark.radius=0.025; spark.height=0.05
	var glow := StandardMaterial3D.new(); glow.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color=preload("res://game/presentation/curse_palette.gd").LIGHT
	for index in range(32):
		var ember := MeshInstance3D.new(); ember.mesh=spark; ember.material_override=glow
		ember.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(ember); embers.append(ember)
	var vapor := ShaderMaterial.new(); var smoke := Shader.new()
	smoke.code="shader_type spatial; render_mode unshaded,cull_disabled,depth_draw_never; instance uniform float opacity=0.2; void vertex(){float s=length(MODEL_MATRIX[0].xyz); MODELVIEW_MATRIX=VIEW_MATRIX*mat4(INV_VIEW_MATRIX[0]*s,INV_VIEW_MATRIX[1]*s,INV_VIEW_MATRIX[2]*s,MODEL_MATRIX[3]);} void fragment(){vec2 p=(UV-0.5)*2.0; float n=sin(p.x*9.0+TIME*0.8)*sin(p.y*7.0-TIME*0.6)*0.15+sin(p.x*17.0-p.y*11.0+TIME)*0.06; float density=smoothstep(1.0,0.05,length(p)+n); ALBEDO=vec3(0.035,0.027,0.055); ALPHA=density*opacity;}"
	vapor.shader=smoke
	var card := QuadMesh.new()
	for index in range(24):
		var cloud := MeshInstance3D.new(); cloud.mesh=card; cloud.material_override=vapor
		cloud.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(cloud); mist.append(cloud)

func animate(t: float, origin: Vector3, camera: Camera3D, charge: float, release: float, ground: bool=false, upward: bool=false) -> void:
	var surface := SurfaceTool.new(); surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for strand in range(11):
		var angle := strand*2.39996
		var distance := 0.5+release*(9.0+strand*1.7)
		var direction := Vector3(sin(angle),0.12+sin(strand*1.3)*0.15,cos(angle)).normalized()
		if ground: direction=Vector3(sin(angle)*0.7,0,-0.8-absf(cos(angle))*0.3).normalized()
		if upward: direction=Vector3(sin(angle)*.38,.8+sin(strand*1.3)*.15,cos(angle)*.38).normalized()
		var end := origin+direction*distance
		if ground: end.y=0.07+sin(strand)*0.04
		var points: Array[Vector3] = []
		for segment in range(25):
			var u := segment/24.0
			var curl := Vector3(sin(u*13+t*3+strand),cos(u*11-t*2+strand),sin(u*17-t*2))*sin(u*PI)
			var at := origin.lerp(end,u)+curl*(0.12+u*distance*0.055)
			if ground: at.y=maxf(0.06,at.y+sin(u*PI)*(1-release)*1.4)
			points.append(at)
		for segment in range(24):
			var a := points[segment]; var b := points[segment+1]
			var side := (b-a).cross(camera.global_position-(a+b)*0.5).normalized()
			var fade := charge*(1.0-segment/25.0)
			# Broad dark-violet vapor around a thin bright, irregular lightning vein.
			for layer in range(2):
				var width := (0.12 if layer==0 else 0.016)*(1+sin(segment*3.1+t*9)*0.3)
				var color := Color(0.18,0.07,0.30,fade*0.35) if layer==0 else Color(0.72,0.42,1.0,fade*0.85)
				var vertices := [a-side*width,a+side*width,b-side*width,a+side*width,b+side*width,b-side*width]
				var uvs := [Vector2(0,0),Vector2(1,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),Vector2(0,1)]
				for corner in range(6):
					surface.set_uv(uvs[corner]); surface.set_color(color); surface.add_vertex(vertices[corner])
	ribbons.mesh=surface.commit()
	for index in range(embers.size()):
		var angle := index*2.39996+t*(0.8+index*0.01)
		var radius := (0.25+fmod(index*0.137+t*0.18,1.0))*(1+release*8)
		embers[index].position=origin+Vector3(sin(angle)*radius,cos(angle*1.7)*radius*0.5,cos(angle)*radius)
		embers[index].scale=Vector3.ONE*charge*(0.5+sin(t*5+index)*0.25)
	for index in range(mist.size()):
		var angle := index*2.39996
		var radius := 0.4+release*(2+fmod(index*0.71,12.0))
		var direction := Vector3(sin(angle),sin(angle*1.3)*0.2,cos(angle))
		if ground: direction=Vector3(sin(angle)*0.7,0,-1).normalized()
		mist[index].position=origin+direction*radius+Vector3.UP*(0.4+sin(t+index)*0.15)
		mist[index].scale=Vector3.ONE*(1.4+release*1.8+sin(index*1.7+t)*0.3)
		mist[index].set_instance_shader_parameter("opacity",charge*(0.18 if ground else 0.1))
