shader_type canvas_item;
// Use glyph geometry, not font-atlas UVs, to sweep across connected words.
uniform float animation_clock = 0.0;
uniform vec2 title_extent = vec2(600.0, 150.0);
varying vec2 glyph_position;
void vertex() {
	glyph_position = VERTEX;
}
void fragment() {
	vec2 local = glyph_position / max(title_extent, vec2(1.0));
	float cycle = mod(animation_clock, 8.0);
	float center = mix(-0.35, 1.35, clamp(cycle / 3.6, 0.0, 1.0));
	float sweep = exp(-pow((local.x + local.y * 0.18 - center) / 0.055, 2.0));
	float silver_edge = exp(-pow((local.x + local.y * 0.18 - center + 0.065) / 0.16, 2.0));
	float breath = 0.5 + 0.5 * sin(animation_clock * 0.70 + local.y * 2.4);
	vec4 ink = COLOR;
	float fill = smoothstep(0.16, 0.55, dot(ink.rgb, vec3(0.2126, 0.7152, 0.0722)));
	ink.rgb *= mix(1.0, 0.82 + breath * 0.10, fill);
	ink.rgb = mix(ink.rgb, vec3(0.98, 0.86, 1.0), fill * (0.08 + breath * 0.06));
	ink.rgb = mix(ink.rgb, vec3(1.0), sweep * 0.92 * fill);
	ink.rgb += vec3(0.12, 0.045, 0.18) * silver_edge * fill;
	COLOR = ink;
}
