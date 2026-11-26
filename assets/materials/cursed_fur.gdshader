shader_type spatial;
render_mode cull_disabled;
uniform sampler2D fur_texture : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D fur_normal : hint_normal;
uniform bool has_normal = false;
void fragment() {
    vec4 fur=texture(fur_texture,UV);
    if(fur.a<0.4) { discard; }
    float grey=dot(fur.rgb,vec3(0.2126,0.7152,0.0722));
    ALBEDO=mix(vec3(grey),fur.rgb,0.12)*vec3(0.42,0.43,0.4);
    ROUGHNESS=0.92;
    if(has_normal) { NORMAL_MAP=texture(fur_normal,UV).rgb; }
}
