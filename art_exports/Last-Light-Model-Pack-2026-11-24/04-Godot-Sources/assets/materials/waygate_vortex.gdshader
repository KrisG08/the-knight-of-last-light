shader_type spatial;
render_mode unshaded, cull_disabled;
uniform float gate_seed=0.0;
uniform float openness : hint_range(0.0,1.0)=1.0;
uniform float aspect=1.6;
// Continuous low-frequency turbulence avoids precision/grid seams on Mobile.
float mist(vec2 p){return 0.5+0.20*sin(p.x*2.3+sin(p.y*1.7))+0.16*sin(p.y*2.7-p.x*0.8)+0.10*sin(p.x*5.0+p.y*3.2);}
void fragment(){
    vec2 p=(UV-vec2(0.5,0.53))*vec2(2.0,aspect*2.0);
    float r=length(p); float a=atan(p.y,p.x);
    float t=TIME*(0.23+openness*0.15)+gate_seed;
    float clouds=mist(p*3.2+vec2(t*0.3,-t*0.5));
    float bend=a+log(r+0.08)*3.6-t*1.1+clouds*0.6;
    float wave=max(0.0,sin(bend*3.0));
    float strands=pow(wave,18.0);
    float filigree=pow(max(0.0,sin(bend*6.0-r*4.0+t)),24.0)*0.18;
    float depth=exp(-r*2.4);
    float veil=exp(-pow((r-0.62)*2.3,2.0));
    vec3 color=mix(vec3(0.0008,0.0005,0.003),vec3(0.025,0.004,0.055),clouds*veil);
    vec3 energy=mix(vec3(0.20,0.035,0.44),vec3(0.78,0.46,1.0),strands);
    float radiance=(strands+filigree+pow(wave,4.0)*0.18)*veil*(0.12+openness*0.88);
    color+=energy*radiance;
    color+=vec3(0.45,0.16,0.68)*pow(depth,5.0)*openness;
    // Gently swirling fog fills the arch above/below the central vortex.
    color+=vec3(0.025,0.003,0.055)*clouds*0.35;
    ALBEDO=color;
    EMISSION=color*(0.35+openness*0.65);
    ROUGHNESS=0.6;
}
