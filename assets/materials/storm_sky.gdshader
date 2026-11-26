shader_type sky;
uniform float eclipse_amount : hint_range(0.0,1.0) = 1.0;
uniform float night_strength : hint_range(0.0,1.0) = 0.0;
uniform float violet_night : hint_range(0.0,1.0) = 0.0;
uniform vec4 horizon_color : source_color = vec4(0.20,0.27,0.33,1.0);
uniform sampler2D cloud_panorama : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D moon_texture : source_color, filter_linear_mipmap, repeat_disable;
void sky() {
 vec3 direction=normalize(EYEDIR);
 vec2 uv=vec2(fract(atan(direction.x,-direction.z)/6.2831853+0.5+TIME*0.00008),acos(clamp(direction.y,-1.0,1.0))/3.14159265);
 vec3 photo=texture(cloud_panorama,uv).rgb;
 // Fade across the panorama wrap to prevent a visible vertical seam.
 float wrap=smoothstep(0.0,0.04,uv.x)*(1.0-smoothstep(0.96,1.0,uv.x));
 vec3 opposite=texture(cloud_panorama,vec2(fract(uv.x+0.5),uv.y)).rgb;
 photo=mix(opposite,photo,wrap);
 float height_fade=smoothstep(0.0,0.18,direction.y);
 vec3 base=mix(horizon_color.rgb,photo*mix(0.24,0.18,night_strength),height_fade);
 float cloud_light=dot(photo,vec3(0.299,0.587,0.114));
 vec3 violet_clouds=cloud_light*vec3(0.20,0.095,0.30);
 base=mix(base,mix(horizon_color.rgb,violet_clouds,height_fade),violet_night);
 base=mix(base,horizon_color.rgb*0.58,smoothstep(0.0,0.45,-direction.y));
 float cover=smoothstep(0.012,0.09,dot(photo,vec3(0.299,0.587,0.114)))*height_fade;
 vec3 moon_direction=normalize(vec3(-0.23,0.49,-0.9));
 float cloud_rim=pow(max(dot(direction,moon_direction),0.0),22.0)*cloud_light*violet_night;
 base+=vec3(0.018,0.006,0.03)*cloud_rim;
 vec3 right=normalize(cross(moon_direction,vec3(0,1,0)));
 vec3 up=normalize(cross(right,moon_direction));
 float facing=dot(direction,moon_direction);
 vec2 lunar=vec2(dot(direction,right),-dot(direction,up))/max(facing,0.001);
 float radius=mix(0.055,0.09,violet_night);
 float distance=length(lunar);
 float halo=exp(-distance*30.0)*0.022;
 base+=vec3(0.55,0.65,0.78)*halo*(1.0-cover*0.7);
 if(facing>0.0 && distance<radius) {
  vec4 moon=texture(moon_texture,lunar/(radius*2.0)+0.5);
  float limb=1.0-smoothstep(radius*0.94,radius,distance);
  vec3 lunar_light=moon.rgb*mix(vec3(0.85,0.94,1.03),vec3(0.72,0.84,0.84),eclipse_amount*0.25);
  lunar_light=mix(lunar_light,moon.rgb*vec3(0.51,0.33,0.65),violet_night);
  base=mix(base,lunar_light,moon.a*limb*(1.0-cover*0.58));
 }
 COLOR=base;
}
