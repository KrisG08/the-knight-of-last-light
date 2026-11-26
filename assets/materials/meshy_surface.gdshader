shader_type spatial;
render_mode cull_back;
uniform sampler2D reference_color : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D metal_detail : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool creature = false;
uniform bool enemy_surface=false;
uniform bool rear_ready=false;
uniform bool front_ready=false;
uniform sampler2D front_reference : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D front_coverage_uv : filter_nearest, repeat_disable;
uniform vec4 front_rect=vec4(0.0,0.0,1.0,1.0);
uniform vec2 front_x_bounds=vec2(-0.4,0.4);
uniform sampler2D rear_reference : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec4 rear_rect=vec4(0.0,0.0,1.0,1.0);
uniform vec2 rear_x_bounds=vec2(-0.4,0.4);
uniform float model_height=1.9;
uniform bool rear_has_alpha=false;
uniform vec4 variant_tint : source_color = vec4(1.0);
uniform sampler2D bark_detail : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 part_origin=vec3(0.0);
uniform bool grip_enabled=false;
uniform mat3 grip_upper=mat3(1.0);
uniform mat3 grip_fore=mat3(1.0);
uniform vec3 grip_rest_elbow=vec3(0.0,-0.45,0.0);
uniform vec3 grip_elbow=vec3(0.0,-0.45,0.0);
varying vec3 rest_position;
varying vec3 rest_normal;
varying float surface_roughness;
varying float confidence;
varying float cavity;
void vertex() {
    rest_position=VERTEX+part_origin;
    rest_normal=NORMAL;
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
    float front_weight=confidence*(1.0-background)*0.96;
    vec4 rear_sample=vec4(0.0);
    float rear_valid=0.0;
    if(rear_ready){
        front_weight*=smoothstep(0.12,0.55,dot(normalize(rest_normal),vec3(0.342,0.0,-0.94)));
        vec3 p=rest_position/model_height;
        vec2 coordinate=vec2((p.x-rear_x_bounds.x)/(rear_x_bounds.y-rear_x_bounds.x),1.0-p.y);
        rear_sample=texture(rear_reference,rear_rect.xy+coordinate*rear_rect.zw);
        float valid=rear_has_alpha?smoothstep(0.6,0.9,rear_sample.a):1.0;
        rear_valid=valid;
        float rear_weight=smoothstep(-0.05,0.55,normalize(rest_normal).z)*valid*0.97;
        rear=mix(rear,rear_sample.rgb,rear_weight);
    }
    if(front_ready){
        // The guide camera faces +Z: image-right is model-left. No diagonal UVs.
        vec3 p=rest_position/model_height;
        vec2 coordinate=vec2(1.0-(p.x-front_x_bounds.x)/(front_x_bounds.y-front_x_bounds.x),1.0-p.y);
        vec2 front_uv=front_rect.xy+coordinate*front_rect.zw;
        vec4 front_sample=texture(front_reference,front_uv);
        if(front_sample.a<0.95){
            // A coordinate field extends nearby garment paint over tiny pose
            // mismatches, without changing the generated source color image.
            vec4 lookup=texture(front_coverage_uv,front_uv);
            vec2 covered_uv=vec2(dot(lookup.rg,vec2(65280.0,255.0)),dot(lookup.ba,vec2(65280.0,255.0)))/65535.0;
            front_sample=texture(front_reference,covered_uv);
        }
        // Normalize paired coverage at grazing angles, avoiding bands of old
        // fallback pigment between the two image projections.
        float facing=smoothstep(-0.35,0.35,-normalize(rest_normal).z);
        float fw=facing*smoothstep(0.6,0.9,front_sample.a);
        float bw=(1.0-facing)*rear_valid;
        float coverage=fw+bw;
        reference=(front_sample.rgb*fw+rear_sample.rgb*bw)/max(coverage,0.0001);
        // Alpha rejects the background without discarding pale cloth or steel.
        front_weight=smoothstep(0.0,0.2,coverage)*0.98;
    }
    ALBEDO = mix(rear,reference,front_weight);
    ALBEDO *= variant_tint.rgb;
    if(creature){
        // Projected horn colors can be flat even at high confidence.
        float bark=dot(texture(bark_detail,rest_position.xz*2.5+rest_position.y*vec2(0.17,0.5)).rgb,vec3(0.333));
        // Preserve the source fur/bark hues rather than adding a second brown tint.
        ALBEDO *= 0.90+bark*0.20;
    }
    AO = cavity;
    AO_LIGHT_AFFECT = 0.35;
    METALLIC = metal*(enemy_surface?0.50:0.72);
    ROUGHNESS = clamp(surface_roughness+(wear-0.45)*0.08,creature?0.72:(enemy_surface?0.42:0.28),0.94);
    SPECULAR = 0.38;
}
