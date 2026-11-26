shader_type canvas_item;
uniform float animation_clock=0.0;
uniform int layer_kind=0;

void fragment(){
    // Integer harmonics close exactly after twelve seconds.
    float phase=animation_clock*6.28318530718/12.0;
    float gust=sin(phase*2.0)+0.32*sin(phase*3.0+0.7);
    vec2 base_uv=layer_kind==0?(UV-0.5)*1.16+0.5:UV;
    vec2 sample_uv=base_uv;
    if(layer_kind==0){
        // Spatial mask includes transparent space around the moving silhouette.
        // A color mask would leave the hem pinned and tear the alpha edge.
        float edge=mix(0.75,0.47,smoothstep(0.35,0.95,base_uv.y));
        float cloth=(1.0-smoothstep(edge-0.13,edge+0.01,base_uv.x));
        cloth*=smoothstep(0.22,0.85,base_uv.y);
        float wave=sin(phase*2.0-base_uv.y*5.0);
        sample_uv.x+=cloth*(wave*0.080+sin(phase*5.0-base_uv.y*18.0)*0.016);
        sample_uv.y+=cloth*(cos(phase*2.0-base_uv.y*5.0)*0.035+sin(phase*4.0-base_uv.x*14.0)*0.008);
    }else{
        // The lower-left root stays pinned; fern, grass and branch tips flex separately.
        float tip=clamp(length(vec2(UV.x,1.0-UV.y))*1.15,0.0,1.0);
        tip=smoothstep(0.12,0.9,tip);
        sample_uv.x+=tip*(gust*0.035+sin(UV.x*31.0-phase*5.0)*0.009);
        sample_uv.y+=tip*sin(phase*2.0+UV.x*6.0)*0.019;
    }
    vec4 result=texture(TEXTURE,clamp(sample_uv,vec2(0.0),vec2(1.0)));
    if(any(lessThan(sample_uv,vec2(0.0)))||any(greaterThan(sample_uv,vec2(1.0)))){result=vec4(0.0);}
    if(layer_kind==0){
        float fold=(sample_uv.x-base_uv.x)*1.2;
        result.rgb*=1.0+fold;
    }
    result.rgb*=layer_kind==0?vec3(0.73,0.79,0.86):vec3(0.66,0.73,0.80);
    COLOR=result;
}
