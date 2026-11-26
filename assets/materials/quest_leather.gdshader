shader_type spatial;
render_mode cull_disabled;
uniform vec4 leather_color : source_color=vec4(0.34,0.19,0.09,1.0);
varying vec3 rest_position;
void vertex(){rest_position=VERTEX;}
void fragment(){
    vec3 p=rest_position;
    float grain=sin(p.x*277.0+sin(p.y*173.0))*sin(p.y*293.0+p.z*181.0);
    float wear=0.5+0.25*sin(p.x*13.0+p.y*9.0)+0.18*sin(p.z*19.0-p.y*7.0);
    float edge=pow(abs(NORMAL.z),4.0);
    ALBEDO=leather_color.rgb*(0.72+wear*0.35+grain*0.035+edge*0.06);
    ROUGHNESS=clamp(0.77+grain*0.05-wear*0.06,0.64,0.88);
    SPECULAR=0.28;
}
