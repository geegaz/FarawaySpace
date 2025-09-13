shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled, depth_draw_never;

void vertex() {
	POINT_SIZE = 10.0;
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}