shader_type canvas_item;
uniform float animation_clock=0.0;
uniform sampler2D clouds : repeat_enable, filter_linear;
float soft_noise(vec2 p){return (sin(p.x*3.7+p.y*1.2)+sin(p.x*1.1-p.y*2.9)+sin(p.x*0.6+p.y*4.1))*0.1667+0.5;}
vec3 cloud_sample(vec2 uv){
    uv.x=fract(uv.x);
    float wrap=smoothstep(0.0,0.04,uv.x)*(1.0-smoothstep(0.96,1.0,uv.x));
    return mix(texture(clouds,vec2(fract(uv.x+0.5),uv.y)).rgb,texture(clouds,uv).rgb,wrap);
}
void fragment(){
    float phase=animation_clock*6.28318530718/12.0;
    vec2 uv=UV;
    vec4 art=texture(TEXTURE,uv);
    // Two crossfaded advection phases hide the reset without reversing the wind.
    float flow=fract(animation_clock/12.0);
    float second_flow=fract(flow+0.5);
    float weight=1.0-abs(flow*2.0-1.0);
    weight=smoothstep(0.0,1.0,weight);
    vec2 cloud_uv=UV*vec2(0.85,1.4)+vec2(0.0,0.02);
    vec3 first_cloud=cloud_sample(cloud_uv-vec2(flow*0.18,0.0));
    vec3 second_cloud=cloud_sample(cloud_uv-vec2(second_flow*0.18,0.0));
    float sky=(1.0-smoothstep(0.20,0.34,UV.y))*(1.0-smoothstep(0.70,0.90,UV.x));
    vec3 weather=mix(second_cloud,first_cloud,weight)*0.72;
    art.rgb=mix(art.rgb,weather,sky*0.88);
    float fog=soft_noise(vec2(UV.x*7.0+sin(phase)*0.6,UV.y*13.0+cos(phase)*0.4));
    fog*=smoothstep(0.49,0.68,UV.y)*(1.0-smoothstep(0.88,1.0,UV.y))*smoothstep(0.22,0.4,UV.x);
    art.rgb=mix(art.rgb,vec3(0.29,0.38,0.41),fog*0.06);
    float warm=smoothstep(0.04,0.13,art.r-art.b)*smoothstep(0.15,0.4,art.r);
    art.rgb*=1.0+warm*(sin(phase*5.0)*0.025+sin(phase*12.0)*0.012);
    COLOR=art;
}
