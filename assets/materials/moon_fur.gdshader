shader_type spatial;
render_mode cull_disabled;
uniform sampler2D fur_texture : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D fur_normal : hint_normal;
uniform bool has_normal = false;
uniform bool skull_mark = false;
varying vec3 part_position;
void vertex() { part_position=VERTEX; }
void fragment() {
    vec4 fur=texture(fur_texture,UV);
    if(fur.a<0.4) { discard; }
    float grey=dot(fur.rgb,vec3(0.2126,0.7152,0.0722));
    ALBEDO=mix(vec3(grey),fur.rgb,0.05)*vec3(0.32,0.35,0.33);
    if(skull_mark) {
        float brow=1.0-smoothstep(-0.12,0.015,part_position.z);
        brow*=1.0-smoothstep(0.065,0.13,abs(part_position.x));
        ALBEDO=mix(ALBEDO,vec3(grey)*vec3(0.95,0.85,0.66),brow*0.9);
    }
    ROUGHNESS=0.94;
    if(has_normal) { NORMAL_MAP=texture(fur_normal,UV).rgb; }
}
