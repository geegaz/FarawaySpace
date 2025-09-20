shader_type spatial;
render_mode unshaded, world_vertex_coords;

uniform samplerCube cubemap : hint_albedo;
uniform float min_eta : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float max_eta : hint_range(0.0, 1.0, 0.01) = 0.9;
uniform float distorted_eta_start : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float fade_start : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float chromatic_dispersion_start : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float chromatic_dispersion_multiplier : hint_range(0.0, 10.0, 0.01) = 1.0;

varying vec3 camera_pos;
varying vec3 world_pos;
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
	camera_pos = (CAMERA_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	world_pos = VERTEX;
	world_normal = NORMAL;
}

void fragment()
{
	vec3 view_dir = normalize(world_pos - camera_pos);
	
	// Load-bearing fresnel
	float f = fresnel(VIEW, NORMAL, 2.0);
	
	float fade = smoothstep(0.0, fade_start, f);
	float chromatic_distorsion_amount = 1.0 - smoothstep(0.0, chromatic_dispersion_start, f);
	float distorted_eta = mix(min_eta, max_eta, smoothstep(0.0, distorted_eta_start, f));
	
	float chromatic_deform = 0.01 * chromatic_dispersion_multiplier * chromatic_distorsion_amount;
	
//	vec3 refracted = refract(view_dir, world_normal, eta); // Simple refract
	vec3 refracted_r = refract(view_dir, world_normal, distorted_eta - chromatic_deform);
	vec3 refracted_g = refract(view_dir, world_normal, distorted_eta);
	vec3 refracted_b = refract(view_dir, world_normal, distorted_eta + chromatic_deform);
	// Need to flip the X direction since the OpenGL cubemaps use left-handed coordinates
	refracted_r.x = -refracted_r.x;
	refracted_g.x = -refracted_g.x;
	refracted_b.x = -refracted_b.x;
	
	float col_r = texture(cubemap, refracted_r).r;
	float col_g = texture(cubemap, refracted_g).g;
	float col_b = texture(cubemap, refracted_b).b;
	ALBEDO = vec3(col_r, col_g, col_b);
	ALPHA = fade;
}
