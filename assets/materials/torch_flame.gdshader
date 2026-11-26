shader_type spatial;
render_mode unshaded, cull_disabled;
void vertex() {
    // Elevation can be baked into vertices; use UV height so sway stays local.
    float tip=clamp(1.0-UV.y,0.0,1.0);
    float weight=tip*tip;
    VERTEX.x+=sin(TIME*9.0+UV.y*6.0)*weight*0.04;
    VERTEX.z+=cos(TIME*7.0+UV.y*5.0)*weight*0.03;
}
void fragment() {
    ALBEDO=vec3(1.0,0.62,0.16);
    EMISSION=vec3(1.0,0.35,0.04)*2.0;
}
