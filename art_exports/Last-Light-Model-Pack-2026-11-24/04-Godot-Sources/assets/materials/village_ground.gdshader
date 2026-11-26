shader_type spatial;
uniform sampler2D cobble_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D cobble_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D cobble_rough : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 curse_tint : source_color = vec4(1.0);
varying vec3 world_position;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1.0,0.0)),f.x),mix(hash(i+vec2(0.0,1.0)),hash(i+vec2(1.0)),f.x),f.y);
}
void vertex() { world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
    vec2 p=world_position.xz;
    float street=min(abs(p.x)/4.0,min(abs(abs(p.x)-20.0)/2.8,abs(p.y+7.0)/3.5));
    float square=length((p-vec2(0.0,-7.0))/vec2(10.0,8.0));
    float wear=min(street,square);
    float patches=noise(p*0.28)*0.65+noise(p*1.1)*0.35;
    float soil=smoothstep(0.55,1.6,wear+(patches-0.5)*0.8);
    vec3 stones=texture(cobble_color,p*0.32).rgb*vec3(0.47,0.49,0.51);
    vec3 earth=texture(soil_color,p*0.3).rgb*vec3(0.33,0.36,0.29);
    ALBEDO=mix(stones,earth,soil)*curse_tint.rgb;
    ROUGHNESS=mix(texture(cobble_rough,p*0.32).r,0.96,soil);
    NORMAL_MAP=mix(texture(cobble_normal,p*0.32).rgb,vec3(0.5,0.5,1.0),soil);
    NORMAL_MAP_DEPTH=0.7;
}
