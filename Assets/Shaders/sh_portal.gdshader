shader_type spatial;
render_mode unshaded, cull_front, world_vertex_coords;

uniform samplerCube cubemap : hint_albedo;

varying vec3 view_dir;
varying vec3 world_normal;

// https://uce-cg.di.uminho.pt/wp-content/uploads/Cube-Mapping-and-GLSL.pdf

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
	view_dir = (VERTEX - camera_pos);
	world_normal = NORMAL;
}

void fragment()
{
	float f = fresnel(VIEW, NORMAL, 2.0);
	float fade = smoothstep(0.0, 0.8, f);
	
	vec4 col = texture(cubemap, view_dir, 1.0);
	EMISSION = col.rgb;
	ALBEDO = col.rgb;
	ALPHA = fade;
}