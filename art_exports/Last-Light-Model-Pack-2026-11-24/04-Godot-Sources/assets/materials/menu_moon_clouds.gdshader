shader_type canvas_item;
// A foreground bank extends beyond the lunar disc and occludes the face.
uniform float animation_clock = 0.0;

float hash(vec2 cell) {
	return fract(sin(dot(cell, vec2(127.1, 311.7))) * 43758.5453);
}
float noise(vec2 point) {
	vec2 cell = floor(point);
	vec2 f = fract(point);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(cell), hash(cell + vec2(1.0, 0.0)), f.x),
		mix(hash(cell + vec2(0.0, 1.0)), hash(cell + vec2(1.0)), f.x), f.y);
}
float cloud_field(vec2 point) {
	return noise(point) * 0.55 + noise(point * 2.07 + vec2(7.3, 3.1)) * 0.28
		+ noise(point * 4.13 + vec2(2.4, 9.2)) * 0.17;
}
void fragment() {
	float t = animation_clock;
	vec2 wind = vec2(t * 0.12, t * 0.004);
	vec2 field_uv = UV * vec2(7.0, 4.2) - wind;
	float field = cloud_field(field_uv);
	float roll = noise(vec2(UV.x * 4.0 - t * 0.04, 1.7));
	float band_y = UV.y - 0.48 - (roll - 0.5) * 0.38;
	float body = exp(-band_y * band_y * 65.0);
	float wisps = exp(-pow((UV.y - 0.70 - (field - 0.5) * 0.28) * 9.0, 2.0));
	float density = smoothstep(0.40, 0.74, field) * body;
	density += wisps * smoothstep(0.46, 0.72, field) * 0.35;
	float edge = smoothstep(0.0, 0.15, UV.x) * (1.0 - smoothstep(0.85, 1.0, UV.x));
	edge *= smoothstep(0.0, 0.18, UV.y) * (1.0 - smoothstep(0.82, 1.0, UV.y));
	vec3 cloud_color = mix(vec3(0.055, 0.078, 0.105), vec3(0.14, 0.18, 0.23), field);
	COLOR = vec4(cloud_color, min(density * 1.10, 0.82) * edge);
}
