shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform float blur_amount : hint_range(0.0, 10.0, 0.1) = 0.0;

void fragment()
{
	vec4 col = COLOR;
	vec3 col_screen = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount * col.a).rgb;

	vec3 albedo = mix(col_screen, col.rgb, col.a);
	COLOR = vec4(albedo, 1.0);
}