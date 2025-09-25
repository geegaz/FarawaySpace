shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, repeat_disable, filter_nearest;

uniform float blur_amount : hint_range(0.0, 5.0, 0.1) = 0.0;

void fragment()
{
	vec3 screen_col = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount).rgb;
	vec3 col = mix(screen_col, COLOR.rgb, COLOR.a);
	
	COLOR = vec4(col, 1.0);
}