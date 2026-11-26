shader_type spatial;
render_mode cull_disabled;
uniform vec4 cloth_color : source_color = vec4(0.23,0.25,0.24,1.0);
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 cell=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(hash(cell),hash(cell+vec2(1,0)),f.x),mix(hash(cell+vec2(0,1)),hash(cell+vec2(1)),f.x),f.y);
}
void fragment() {
    float weave=sin(UV.x*850.0)*sin(UV.y*620.0);
    weave*=1.0-smoothstep(0.3,1.2,max(fwidth(UV.x)*850.0,fwidth(UV.y)*620.0));
    float stain=noise(UV*vec2(12.0,9.0));
    float edging=smoothstep(0.0,0.025,UV.x)*smoothstep(0.0,0.025,1.0-UV.x);
    ALBEDO=cloth_color.rgb*(0.88+weave*0.035+stain*0.12)*mix(1.12,1.0,edging);
    ROUGHNESS=0.94;
    SPECULAR=0.18;
}
