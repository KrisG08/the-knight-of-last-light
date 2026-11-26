shader_type canvas_item;
// Animate the existing crater relief, using the menu's pausable clock.
uniform float animation_clock = 0.0;
uniform sampler2D cloud_map : repeat_enable, filter_linear;
uniform vec2 gaze_direction = vec2(-0.35, 0.94);
varying vec4 face_tint;

void vertex() {
	face_tint = COLOR;
}

float ellipse(vec2 uv, vec2 center, vec2 radius) {
	vec2 p = (uv - center) / radius;
	return exp(-dot(p, p) * 2.0);
}

void fragment() {
	float t = animation_clock;
	float breath = 0.5 - 0.5 * cos(t * 0.64);
	// A slow uneven blink and a smaller squint, rather than a flashing face.
	float blink = pow(max(0.0, cos(t * 0.73 - 1.0)), 24.0);
	float left_open = 0.78 + 0.16 * sin(t * 0.62) - blink * 0.48;
	float right_open = 0.78 + 0.16 * sin(t * 0.62 + 0.45) - blink * 0.43;
	vec2 uv = UV;
	vec2 left_eye = vec2(0.325, 0.425);
	vec2 right_eye = vec2(0.667, 0.423);
	float left_region = ellipse(UV, left_eye, vec2(0.17, 0.10));
	float right_region = ellipse(UV, right_eye, vec2(0.17, 0.10));
	uv.y += (UV.y - left_eye.y) * (1.0 / left_open - 1.0) * left_region;
	uv.y += (UV.y - right_eye.y) * (1.0 / right_open - 1.0) * right_region;
	// The upper lip follows the carved frown; the lower jaw slowly separates.
	float mouth_x = (UV.x - 0.50) / 0.255;
	float mouth_ends = 1.0 - smoothstep(0.70, 1.0, abs(mouth_x));
	float lip = 0.680 + 0.096 * mouth_x * mouth_x;
	float aperture = (0.006 + 0.026 * breath) * mouth_ends;
	float lip_distance = UV.y - lip;
	float jaw_region = ellipse(UV, vec2(0.50, 0.745), vec2(0.30, 0.17));
	uv.y -= aperture * smoothstep(-0.012, 0.035, lip_distance) * jaw_region;
	vec4 stone = texture(TEXTURE, clamp(uv, vec2(0.001), vec2(0.999)));
	// Deep eye sockets retain the lunar texture instead of painted black circles.
	float socket = ellipse(UV, left_eye, vec2(0.115, 0.049 * left_open));
	socket += ellipse(UV, right_eye, vec2(0.115, 0.049 * right_open));
	stone.rgb *= 1.0 - min(socket, 1.0) * 0.42;
	vec2 gaze = gaze_direction * vec2(0.024, 0.021);
	gaze += vec2(0.0025 * sin(t * 0.41), 0.0015 * sin(t * 0.57));
	gaze.y *= min(left_open, right_open);
	float pupil = ellipse(UV, left_eye + gaze, vec2(0.008, 0.016 * left_open));
	pupil += ellipse(UV, right_eye + gaze, vec2(0.008, 0.016 * right_open));
	float ember = ellipse(UV, left_eye + gaze, vec2(0.032, 0.026 * left_open));
	ember += ellipse(UV, right_eye + gaze, vec2(0.032, 0.026 * right_open));
	stone.rgb += vec3(0.40, 0.075, 0.46) * ember * 0.42;
	stone.rgb = mix(stone.rgb, vec3(0.88, 0.38, 0.72), min(pupil, 1.0) * 0.85);
	float mouth = (1.0 - smoothstep(aperture * 0.55, aperture + 0.003, abs(lip_distance))) * mouth_ends;
	stone.rgb = mix(stone.rgb, vec3(0.018, 0.009, 0.025), mouth * 0.94);
	// Uneven stone fangs emerge with the jaw; relief detail remains on their edge.
	float tooth_index = floor((UV.x - 0.245) * 25.0);
	float tooth_cell = fract((UV.x - 0.245) * 25.0);
	float tooth_variation = fract(sin(tooth_index * 12.9898) * 43758.5453);
	float tooth_tip = pow(max(0.0, 1.0 - abs(tooth_cell * 2.0 - 1.0)), 0.75);
	float tooth_length = (0.006 + tooth_tip * (0.010 + 0.014 * tooth_variation)) * breath;
	float tooth_top = lip - aperture * 0.65;
	float teeth = smoothstep(tooth_top - 0.002, tooth_top, UV.y);
	teeth *= 1.0 - smoothstep(tooth_top + tooth_length - 0.002, tooth_top + tooth_length, UV.y);
	teeth *= mouth * mouth_ends * smoothstep(0.15, 0.60, breath);
	vec3 tooth_stone = texture(TEXTURE, vec2(uv.x, lip - 0.025)).rgb * vec3(0.66, 0.65, 0.71);
	tooth_stone *= 0.73 + tooth_variation * 0.27;
	stone.rgb = mix(stone.rgb, tooth_stone, teeth * 0.90);
	// Match the dim blue sky: broad directional shade, aerial haze and clouds
	// revealing the actual movie through the face instead of a hard pasted disc.
	vec2 sphere_xy = (UV - vec2(0.5)) / 0.49;
	float sphere_radius = length(sphere_xy);
	vec3 sphere_normal = normalize(vec3(sphere_xy, sqrt(max(0.001, 1.0 - dot(sphere_xy, sphere_xy)))));
	float key_light = dot(sphere_normal, normalize(vec3(-0.55, -0.48, 0.78)));
	float shade = mix(0.38, 1.12, smoothstep(-0.12, 0.90, key_light));
	vec2 sky_uv = SCREEN_UV * vec2(1.35, 0.65) + vec2(t * 0.004, 0.13);
	float cloud = dot(texture(cloud_map, sky_uv).rgb, vec3(0.2126, 0.7152, 0.0722));
	float veil = smoothstep(0.16, 0.56, cloud);
	vec3 night_stone = stone.rgb * vec3(0.65, 0.79, 0.98) * shade;
	night_stone = mix(night_stone, vec3(0.075, 0.105, 0.145), 0.12 + veil * 0.15);
	night_stone += pupil * vec3(0.16, 0.04, 0.20) * (1.0 - veil * 0.4);
	stone.rgb = night_stone;
	stone.a *= (1.0 - smoothstep(0.87, 1.0, sphere_radius)) * (0.95 - veil * 0.22);
	COLOR = stone * face_tint;
}
