shader_type spatial;
render_mode cull_front;

uniform samplerCube cubemap : hint_albedo;

varying vec3 view_dir;

float fresnel(vec3 view, vec3 normal, float power)
{
	float fresnel = dot(view, normal);
	fresnel = clamp(fresnel, 0.0, 1.0);
	fresnel = pow(fresnel, power);
	return fresnel;
}

void vertex()
{
	vec3 camera_pos = (CAMERA_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 world_pos = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
	view_dir = normalize(world_pos - camera_pos);
}

void fragment()
{
	float fade = smoothstep(0.0, 0.8, fresnel(VIEW, NORMAL, 2.0));
	
	vec4 col = texture(cubemap, view_dir, 1.0);
	EMISSION = col.rgb;
	ALBEDO = col.rgb;
	ALPHA = fade;
}