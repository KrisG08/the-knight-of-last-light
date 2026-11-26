shader_type spatial;
uniform sampler2D soil_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D stone_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D soil_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 paths[24];
uniform int path_count = 0;
uniform float path_width = 1.6;
uniform int biome = 0;
uniform bool ascent_stairs = false;
uniform vec4 curse_tint : source_color = vec4(1.0);
varying vec3 world_position;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
    vec2 i=floor(p); vec2 f=fract(p); f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1)),f.x),f.y);
}
void vertex() { world_position=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz; }
void fragment() {
    vec2 p=world_position.xz;
    if (ascent_stairs && abs(p.x)<6.0 && ((p.y< -5.0 && p.y> -17.0) || (p.y< -23.0 && p.y> -35.0) || (p.y< -41.0 && p.y> -53.0))) { discard; }
    float distance_to_path=1000.0;
    for (int i=0;i<24;i++) {
        if(i>=path_count) { break; }
        vec2 a=paths[i].xy; vec2 line=paths[i].zw-a;
        float t=clamp(dot(p-a,line)/max(dot(line,line),0.001),0.0,1.0);
        distance_to_path=min(distance_to_path,length(p-a-line*t));
    }
    float patches=noise(p*0.23)*0.7+noise(p*1.1)*0.3;
    float verge=smoothstep(path_width-0.4,path_width+1.2,distance_to_path+(patches-0.5)*1.2);
    vec3 soil=texture(soil_color,p*0.28).rgb;
    vec3 stone=texture(stone_color,p*0.24).rgb;
    vec3 base;
    if(biome==0) {
        base=mix(soil*vec3(0.62,0.52,0.40),soil*vec3(0.31,0.47,0.28),verge);
        base*=0.82+patches*0.34;
    } else if(biome==1) {
        base=mix(stone*vec3(0.51,0.51,0.49),soil*vec3(0.48,0.51,0.55),verge);
    } else {
        vec2 slab=vec2(p.x*0.7+mod(floor(p.y*0.5),2.0)*0.5,p.y*0.5);
        vec2 seam=min(fract(slab),1.0-fract(slab));
        float grout=1.0-smoothstep(0.008,0.026,min(seam.x,seam.y));
        base=stone*mix(vec3(0.50,0.52,0.53),vec3(0.30,0.34,0.30),verge*patches*0.7);
        base=mix(base,vec3(0.055,0.065,0.07),grout*0.65);
    }
    ALBEDO=base*curse_tint.rgb;
    ROUGHNESS=mix(0.81,0.97,patches);
    NORMAL_MAP=texture(soil_normal,p*0.28).rgb;
    NORMAL_MAP_DEPTH=biome==2?0.18:0.55;
}
