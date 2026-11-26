extends Node3D
## Authored smooth energy and rolling haze; no spoke fan or polygonal ground web.
var terrain: Node3D
var ribbons: MeshInstance3D
var clouds: Array[MeshInstance3D]=[]
var cloud_material: ShaderMaterial
var core: MeshInstance3D
var core_material: ShaderMaterial
var max_segment_length:=0.0

func _ready() -> void:
	ribbons=MeshInstance3D.new(); add_child(ribbons)
	ribbons.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shader:=Shader.new()
	shader.code="""shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform float clock=0.0;
void fragment(){
 float edge=pow(max(0.0,1.0-abs(UV.x*2.0-1.0)),2.4);
 float flow=.62+.38*sin(UV.y*23.0-clock*2.4);
 ALBEDO=COLOR.rgb; EMISSION=COLOR.rgb*.7;
 ALPHA=COLOR.a*edge*flow;
}"""
	var ribbon_material:=ShaderMaterial.new(); ribbon_material.shader=shader
	ribbons.material_override=ribbon_material
	var fog:=Shader.new()
	fog.code="""shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform float clock=0.0;
uniform sampler2D scene_depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform float ground_softness=0.0;
instance uniform float opacity=0.0;
instance uniform float phase=0.0;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
float fbm(vec2 p){float n=0.0,a=.55; for(int i=0;i<4;i++){n+=a*noise(p);p=p*2.03+vec2(4.1,7.3);a*=.5;} return n;}
void vertex(){float s=length(MODEL_MATRIX[0].xyz);
 MODELVIEW_MATRIX=VIEW_MATRIX*mat4(INV_VIEW_MATRIX[0]*s,INV_VIEW_MATRIX[1]*s,INV_VIEW_MATRIX[2]*s,MODEL_MATRIX[3]);}
void fragment(){vec2 p=UV*2.0-1.0;
 vec2 warp=vec2(sin(p.y*4.2+phase+clock*.43),cos(p.x*4.9-phase-clock*.32))*.17;
 vec2 q=p+warp;
 float density=.50+.23*sin(q.x*5.1+sin(q.y*5.8+clock*.25)*1.8+phase)
  +.16*cos(q.y*7.3-q.x*3.2-clock*.38+phase)+.08*sin(q.x*11.7+q.y*9.1+phase);
 float edge=exp(-dot(q,q)*2.8)*(1.0-smoothstep(.78,1.0,length(p)));
 vec3 shade=mix(vec3(.045,.018,.075),vec3(.19,.06,.31),smoothstep(.2,.8,density));
 ALBEDO=shade; EMISSION=shade*.2;
 float scene_sample=texture(scene_depth_texture,SCREEN_UV).r;
 #if CURRENT_RENDERER == RENDERER_COMPATIBILITY
 vec3 ndc=vec3(SCREEN_UV,scene_sample)*2.0-1.0;
 #else
 vec3 ndc=vec3(SCREEN_UV*2.0-1.0,scene_sample);
 #endif
 vec4 scene_view=INV_PROJECTION_MATRIX*vec4(ndc,1.0);
 float scene_distance=-scene_view.z/scene_view.w;
 float soft=smoothstep(0.0,.85,scene_distance+VERTEX.z);
 ALPHA=edge*density*density*opacity*mix(1.0,soft,ground_softness);
}"""
	cloud_material=ShaderMaterial.new(); cloud_material.shader=fog
	var quad:=QuadMesh.new(); quad.size=Vector2.ONE
	for i in range(36):
		var cloud:=MeshInstance3D.new(); cloud.mesh=quad; cloud.material_override=cloud_material
		cloud.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(cloud); clouds.append(cloud)
		cloud.set_instance_shader_parameter("phase",i*1.79)
	var orb_shader:=Shader.new()
	orb_shader.code="""shader_type spatial; render_mode unshaded,cull_disabled,depth_draw_never;
uniform float clock=0.0; uniform float opacity=0.0;
void fragment(){float fresnel=pow(1.0-clamp(dot(normalize(NORMAL),normalize(VIEW)),0.0,1.0),2.0);
 float swirl=.5+.5*sin(UV.x*19.0+sin(UV.y*17.0-clock*1.9)*2.0-clock*2.2);
 vec3 light=mix(vec3(.15,.025,.30),vec3(.48,.18,.75),swirl);
 ALBEDO=light; EMISSION=light*(.6+fresnel); ALPHA=opacity*(.14+.3*fresnel)*(.4+.6*swirl);
}"""
	core_material=ShaderMaterial.new(); core_material.shader=orb_shader
	var sphere:=SphereMesh.new(); sphere.radius=.4; sphere.height=.8; sphere.radial_segments=40; sphere.rings=24
	core=MeshInstance3D.new(); core.mesh=sphere; core.material_override=core_material
	core.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(core)

func ground_height(p: Vector3) -> float:
	return terrain.height_at(p.x,p.z) if is_instance_valid(terrain) else 0.0

func animate(t: float,origin: Vector3,camera: Camera3D,charge: float,release: float,ground: bool=false,_upward: bool=false) -> void:
	var material:=ribbons.material_override as ShaderMaterial
	material.set_shader_parameter("clock",t)
	cloud_material.set_shader_parameter("clock",t)
	cloud_material.set_shader_parameter("ground_softness",1.0 if ground else 0.0)
	core_material.set_shader_parameter("clock",t)
	core_material.set_shader_parameter("opacity",charge)
	core.visible=not ground and charge>.01 and release<.45
	core.position=origin+Vector3.UP*release*.45
	core.scale=Vector3.ONE*(.25+charge*.35)
	var surface:=SurfaceTool.new(); surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	max_segment_length=0.0
	var count:=160
	for strand in range(6):
		var points: Array[Vector3]=[]
		var phase:=strand*TAU/6
		for segment in range(count+1):
			var u:=float(segment)/count
			var p: Vector3
			if ground:
				p=origin+Vector3((strand-2.5)*2.0+sin(u*TAU*1.3+t*.65+phase)*.75,0,-t*2.1-u*9.0)
				p.y=ground_height(p)+.16+.20*sin(u*PI+phase)*sin(u*PI)
			else:
				var angle:=phase+t*1.1+u*TAU*(1.2+release*.7)
				var radius: float=(.20+.32*sin(u*PI))*(1+release*1.8)
				var orbit:=origin+Vector3(cos(angle)*radius,sin(angle*1.1+phase)*radius*.65,sin(angle)*radius)
				var rising:=origin+Vector3(cos(angle)*radius,u*(2+release*13),sin(angle)*radius)
				p=orbit.lerp(rising,smoothstep(.03,.8,release))
			points.append(p)
		for segment in range(count):
			var a:=points[segment]; var b:=points[segment+1]
			max_segment_length=maxf(max_segment_length,a.distance_to(b))
			var side: Vector3=(b-a).cross(camera.global_position-(a+b)*.5).normalized()
			var u:=float(segment)/count; var next:=float(segment+1)/count
			var fade: float=charge*pow(sin(u*PI),.6)
			for layer in range(2):
				var width: float=(.21 if ground else .12) if layer==0 else (.035 if ground else .018)
				var color:=Color(.20,.045,.36,fade*.20) if layer==0 else Color(.46,.15,.70,fade*.30)
				var vertices:=[a-side*width,a+side*width,b-side*width,a+side*width,b+side*width,b-side*width]
				var uv:=[Vector2(0,u),Vector2(1,u),Vector2(0,next),Vector2(1,u),Vector2(1,next),Vector2(0,next)]
				for corner in range(6): surface.set_uv(uv[corner]); surface.set_color(color); surface.add_vertex(vertices[corner])
	ribbons.mesh=surface.commit()
	for i in range(clouds.size()):
		var phase:=i*2.39996+t*.4
		var p: Vector3
		if ground:
			p=origin+Vector3((i%9-4)*1.55+sin(phase)*.35,0,-t*2.1-floorf(i/9.0)*2.0)
			p.y=ground_height(p)+.65+sin(phase)*.14
		else:
			var u:=float(i)/clouds.size()
			var radius: float=.3+release*(.6+u*.9)
			p=origin+Vector3(cos(phase)*radius,u*release*10.0+sin(phase*1.2)*.25,sin(phase)*radius)
		clouds[i].position=p
		clouds[i].scale=Vector3.ONE*((2.2 if ground else 1.0)+sin(i*1.7+t*.6)*.3+release*.6)
		var proximity: float=smoothstep(3.0,7.0,p.distance_to(camera.global_position)) if ground else 1.0
		clouds[i].set_instance_shader_parameter("opacity",charge*(.28 if ground else .20)*proximity)
