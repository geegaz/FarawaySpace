// NOTE: Shader automatically converted from Godot Engine 3.5.3.stable's SpatialMaterial.

shader_type spatial;
render_mode unshaded, async_visible, blend_mix;

uniform vec4 color : source_color;
uniform float proximity_fade_distance = 5.0;
uniform float distance_fade_min = 0.0;
uniform float distance_fade_max = 10.0;
uniform float shadow_power : hint_range(0.1, 10.0, 0.01) = 2.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
}




void fragment() {
	ALBEDO = color.rgb;
	
	float dist = clamp(1.0 - (distance(UV, vec2(0.5)) * 2.0), 0.0, 1.0);
	float alpha = pow(dist, shadow_power);
	
	ALPHA = color.a * alpha;
	
	float depth_tex = textureLod(DEPTH_TEXTURE,SCREEN_UV,0.0).r;
	vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV*2.0-1.0,depth_tex*2.0-1.0,1.0);
	world_pos.xyz/=world_pos.w;
	ALPHA *= clamp(1.0-smoothstep(world_pos.z+proximity_fade_distance,world_pos.z,VERTEX.z),0.0,1.0);
	
	ALPHA *= clamp(smoothstep(distance_fade_min,distance_fade_max,-VERTEX.z),0.0,1.0);
}
