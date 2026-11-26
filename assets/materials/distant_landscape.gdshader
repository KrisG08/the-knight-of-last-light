shader_type spatial;
render_mode fog_disabled;
uniform vec4 haze_color : source_color = vec4(0.20,0.27,0.33,1.0);
uniform sampler2D rock_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D rock_rough : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
varying vec3 world_point;
varying vec3 world_normal;
float terrain_noise(vec2 p) {
    vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(fract(sin(dot(i,vec2(127.1,311.7)))*43758.5453),fract(sin(dot(i+vec2(1,0),vec2(127.1,311.7)))*43758.5453),f.x),mix(fract(sin(dot(i+vec2(0,1),vec2(127.1,311.7)))*43758.5453),fract(sin(dot(i+vec2(1,1),vec2(127.1,311.7)))*43758.5453),f.x),f.y);
}
void vertex() {
    world_point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
    world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);
}
void fragment() {
    vec3 weights=pow(abs(world_normal),vec3(4.0));
    weights/=max(dot(weights,vec3(1.0)),0.0001);
    vec3 p=world_point*0.08;
    vec3 rock=texture(rock_color,p.yz).rgb*weights.x+texture(rock_color,p.xz).rgb*weights.y+texture(rock_color,p.xy).rgb*weights.z;
    vec3 soil=texture(soil_color,world_point.xz*0.055).rgb;
    float ledges=smoothstep(0.55,0.85,world_normal.y);
    vec3 base=mix(rock*vec3(0.68,0.69,0.72),soil*vec3(0.25,0.34,0.25),ledges*0.65);
    float woodland=smoothstep(0.25,0.65,terrain_noise(world_point.xz*0.012))*smoothstep(0.3,0.7,world_normal.y)*(1.0-smoothstep(280.0,450.0,world_point.y));
    base=mix(base,soil*vec3(0.16,0.27,0.17),woodland*0.9)*0.32;
    vec3 nx=texture(rock_normal,p.yz).rgb*2.0-1.0;
    vec3 ny=texture(rock_normal,p.xz).rgb*2.0-1.0;
    vec3 nz=texture(rock_normal,p.xy).rgb*2.0-1.0;
    nx=vec3(nx.z*sign(world_normal.x),nx.x,nx.y);
    ny=vec3(ny.x,ny.z*sign(world_normal.y),ny.y);
    nz=vec3(nz.x,nz.y,nz.z*sign(world_normal.z));
    vec3 detail_normal=normalize(nx*weights.x+ny*weights.y+nz*weights.z);
    NORMAL=normalize((VIEW_MATRIX*vec4(normalize(mix(world_normal,detail_normal,0.28)),0.0)).xyz);
    float snow=smoothstep(480.0,680.0,world_point.y)*smoothstep(0.45,0.85,world_normal.y);
    float haze=1.0-exp(-length(VERTEX)*0.0007);
    ALBEDO=mix(base,vec3(0.43,0.48,0.52),snow*0.75)*(1.0-haze);
    EMISSION=haze_color.rgb*haze;
    ROUGHNESS=clamp(texture(rock_rough,p.xz).r*0.35+0.60,0.7,0.99);
}
