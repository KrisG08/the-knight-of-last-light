shader_type spatial;
render_mode cull_back;
uniform sampler2D reference_color : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D metal_detail : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool creature = false;
uniform bool enemy_surface=false;
uniform vec4 variant_tint : source_color = vec4(1.0);
uniform sampler2D bark_detail : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 part_origin=vec3(0.0);
uniform bool grip_enabled=false;
uniform mat3 grip_upper=mat3(1.0);
uniform mat3 grip_fore=mat3(1.0);
uniform vec3 grip_rest_elbow=vec3(0.0,-0.45,0.0);
uniform vec3 grip_elbow=vec3(0.0,-0.45,0.0);
varying vec3 rest_position;
varying float surface_roughness;
varying float confidence;
varying float cavity;
void vertex() {
    rest_position=VERTEX+part_origin;
    if(grip_enabled){
        float weight=smoothstep(0.72,1.30,VERTEX.y/min(grip_rest_elbow.y,-0.01));
        VERTEX=mix(grip_upper*VERTEX,grip_elbow+grip_fore*(VERTEX-grip_rest_elbow),weight);
        NORMAL=normalize(mix(grip_upper*NORMAL,grip_fore*NORMAL,weight));
    }
    // Authored rest-space UVs and material masks survive skinning.
    surface_roughness = UV2.x;
    confidence = floor(UV2.y/32.0)/31.0;
    cavity = mod(UV2.y,32.0)/31.0;
}
void fragment() {
    vec3 reference = texture(reference_color,UV).rgb;
    float luma = dot(reference,vec3(0.299,0.587,0.114));
    float chroma = max(reference.r,max(reference.g,reference.b))-min(reference.r,min(reference.g,reference.b));
    float background = smoothstep(0.28,0.52,luma)*(1.0-smoothstep(0.025,0.09,chroma));
    float metal = COLOR.a;
    vec3 grain = texture(metal_detail,UV*7.0).rgb;
    float wear = dot(grain,vec3(0.333));
    // Low-confidence projection uses authored material color. Rear heads never sample faces.
    vec3 rear = COLOR.rgb*(0.78+wear*0.55);
    if(creature){
        float bark=dot(texture(bark_detail,rest_position.xz*2.5+rest_position.y*vec2(0.17,0.5)).rgb,vec3(0.333));
        rear=COLOR.rgb*(0.60+bark*0.80);
    }
    ALBEDO = mix(rear,reference,confidence*(1.0-background)*0.92);
    ALBEDO *= variant_tint.rgb;
    if(creature){
        // Projected horn colors can be flat even at high confidence.
        float bark=dot(texture(bark_detail,rest_position.xz*2.5+rest_position.y*vec2(0.17,0.5)).rgb,vec3(0.333));
        ALBEDO *= mix(vec3(0.56,0.45,0.34),vec3(1.12),bark);
    }
    AO = cavity;
    AO_LIGHT_AFFECT = 0.35;
    METALLIC = metal*(enemy_surface?0.50:0.72);
    ROUGHNESS = clamp(surface_roughness+(wear-0.45)*0.08,creature?0.72:(enemy_surface?0.42:0.28),0.94);
    SPECULAR = 0.38;
}
