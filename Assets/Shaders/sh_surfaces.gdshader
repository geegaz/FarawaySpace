shader_type spatial;
render_mode blend_mix, cull_back, depth_draw_opaque;

uniform vec4 albedo : source_color = vec4(1.0);
uniform vec4 emission : source_color = vec4(1.0);
uniform float emission_amount : hint_range(0.0, 10.0) = 0.0;

void fragment() {
	ALBEDO = albedo.rgb;
	EMISSION = emission.rgb * emission_amount;
}