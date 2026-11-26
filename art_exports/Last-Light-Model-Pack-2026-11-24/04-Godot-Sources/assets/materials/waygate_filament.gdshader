shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_draw_never;
uniform float openness=1.0;
void vertex(){
    float a=TIME*0.18*openness;
    vec2 p=VERTEX.xy-vec2(0.0,2.35);
    VERTEX.xy=mat2(vec2(cos(a),sin(a)),vec2(-sin(a),cos(a)))*p+vec2(0.0,2.35);
    VERTEX.z+=sin(TIME*0.7+UV.y*9.0)*0.025;
}
void fragment(){
    float edge=pow(max(0.0,1.0-abs(UV.x*2.0-1.0)),2.0);
    float fade=smoothstep(0.0,0.12,UV.y)*(1.0-smoothstep(0.76,1.0,UV.y));
    float flow=0.5+0.5*sin(UV.y*28.0-TIME*1.4);
    ALBEDO=mix(vec3(0.32,0.04,0.70),vec3(0.88,0.55,1.0),edge);
    EMISSION=ALBEDO*1.6;
    ALPHA=edge*fade*(0.2+flow*0.4)*openness;
}
