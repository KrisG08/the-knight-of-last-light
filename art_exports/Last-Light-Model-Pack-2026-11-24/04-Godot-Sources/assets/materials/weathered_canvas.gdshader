shader_type spatial;
render_mode cull_disabled;
uniform vec4 cloth_color : source_color = vec4(0.45,0.38,0.28,1.0);
uniform float flutter = 0.025;
float hash(vec2 p) {
    return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);
}
float dirt(vec2 p) {
    vec2 cell = floor(p);
    vec2 f = fract(p);
    f = f*f*(3.0-2.0*f);
    return mix(mix(hash(cell),hash(cell+vec2(1.0,0.0)),f.x),
               mix(hash(cell+vec2(0.0,1.0)),hash(cell+vec2(1.0)),f.x),f.y);
}
void vertex() {
    VERTEX.z += sin(TIME*1.2+VERTEX.x*2.8)*flutter*UV.y;
}
void fragment() {
    float weave = sin(UV.x*220.0)*sin(UV.y*180.0)*0.025;
    float stains = mix(0.72,1.0,dirt(UV*18.0));
    float hem = smoothstep(0.0,0.025,min(UV.x,1.0-UV.x));
    ALBEDO = cloth_color.rgb*(stains+weave)*mix(0.7,1.0,hem);
    ROUGHNESS = 0.96;
}
