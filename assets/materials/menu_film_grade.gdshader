shader_type canvas_item;
// Lift readable moonlit detail while preserving the darkest blacks and alpha.
uniform float grade_amount : hint_range(0.0,1.0) = 1.0;
uniform float animation_clock=0.0;
float ribbon(vec2 uv,vec2 center,vec2 radius,float phase){
    vec2 p=(uv-center)/radius;
    float angle=atan(p.y,p.x);
    float curl=1.0+0.07*sin(angle*4.0-phase*3.0)+0.025*sin(angle*11.0+phase*2.0);
    float distance_to_ribbon=abs(length(p)-curl);
    float tail=pow(max(0.0,0.5+0.5*cos(angle-phase*2.0)),5.0);
    float smoke=0.65+0.20*sin(angle*13.0-phase*5.0)+0.15*sin(angle*23.0+phase*3.0);
    float filament=exp(-pow(distance_to_ribbon*22.0,2.0))*smoke;
    float halo=exp(-pow(distance_to_ribbon*5.0,2.0))*0.65*smoke;
    return (filament+halo)*tail;
}
void fragment(){
    vec4 frame=texture(TEXTURE,UV);
    vec3 lifted=min(pow(max(frame.rgb,vec3(0.0)),vec3(0.90))*1.12,vec3(1.0));
    float luminance=dot(frame.rgb,vec3(0.2126,0.7152,0.0722));
    frame.rgb=mix(frame.rgb,lifted,grade_amount*smoothstep(0.008,0.08,luminance));
    float phase=animation_clock*6.28318530718/12.0;
    // Firelight from the left catches existing folds, stone and metal detail.
    vec2 warm_distance=(UV-vec2(0.40,0.72))/vec2(0.30,0.38);
    float warm=exp(-dot(warm_distance,warm_distance)*1.5)*smoothstep(0.012,0.18,luminance);
    frame.rgb+=warm*vec3(0.19,0.11,0.025)*(1.0+0.035*sin(phase*5.0));
    // Broken, tapered filaments orbit at two heights instead of a flat magic circle.
    float energy=ribbon(UV,vec2(0.66,0.47),vec2(0.125,0.075),phase);
    energy+=ribbon(UV,vec2(0.66,0.52),vec2(0.12,0.045),-phase+2.1)*0.65;
    vec2 plume=(UV-vec2(0.635,0.39))/vec2(0.045,0.10);
    float axis=0.22*sin(plume.y*4.0-phase*2.0);
    energy+=exp(-pow((plume.x-axis)*1.7,2.0)-plume.y*plume.y*1.8)*0.22;
    vec3 glow=clamp(energy*vec3(0.55,0.17,0.95),vec3(0.0),vec3(0.9));
    frame.rgb=1.0-(1.0-frame.rgb)*(1.0-glow);
    COLOR=frame;
}
