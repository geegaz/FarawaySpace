shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 modulate: hint_color = vec4(1.0);

void fragment()
{
	ALBEDO = COLOR.rgb * modulate.rgb;
	ALPHA = COLOR.a * modulate.a;
}
