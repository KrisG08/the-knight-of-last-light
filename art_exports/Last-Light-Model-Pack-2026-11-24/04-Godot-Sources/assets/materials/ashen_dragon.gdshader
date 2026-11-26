shader_type spatial;
render_mode cull_disabled;
uniform sampler2D scale_texture : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D scale_normal : hint_normal;
uniform bool has_texture = false;
uniform bool has_normal = false;
uniform vec4 source_tint : source_color = vec4(1.0);
void fragment() {
    vec4 scales=source_tint;
    if(has_texture) { scales*=texture(scale_texture,UV); }
    float grey=dot(scales.rgb,vec3(0.2126,0.7152,0.0722));
    ALBEDO=mix(vec3(grey),scales.rgb,0.06)*vec3(0.53,0.46,0.39);
    ROUGHNESS=0.88;
    SPECULAR=0.26;
    if(has_normal) { NORMAL_MAP=texture(scale_normal,UV).rgb; }
}
