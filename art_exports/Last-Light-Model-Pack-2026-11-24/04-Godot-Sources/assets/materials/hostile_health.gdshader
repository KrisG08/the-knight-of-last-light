shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled, fog_disabled;
uniform float fraction : hint_range(0.0, 1.0) = 1.0;
void vertex() {
    // Keep the whole meter facing the camera without rotating its owner.
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}
void fragment() {
    bool inside = UV.x > 0.014 && UV.x < 0.986 && UV.y > 0.15 && UV.y < 0.85;
    float amount = (UV.x - 0.014) / 0.972;
    vec3 red = mix(vec3(0.48, 0.025, 0.035), vec3(0.88, 0.075, 0.09), UV.y);
    ALBEDO = inside ? (amount < fraction ? red : vec3(0.065, 0.025, 0.03)) : vec3(0.025, 0.018, 0.02);
}
