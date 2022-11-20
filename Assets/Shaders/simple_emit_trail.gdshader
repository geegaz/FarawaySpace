shader_type spatial;
render_mode skip_vertex_transform, cull_disabled;
render_mode blend_add, depth_draw_opaque, unshaded;

uniform float line_width = 0.1;
uniform sampler2D width_curve : hint_albedo;
uniform bool tangent_facing = false;
void line_process(float width, inout vec3 vertex, vec3 dir_to_cam, vec2 uv,
					inout vec3 normal, inout vec3 tangent){
	vec3 dir_to_next_point = normal;
	vec3 perp = tangent;
	if (!tangent_facing) {
		perp = normalize(cross(dir_to_cam,dir_to_next_point));
	}
	
	float curve_multiplier = textureLod(width_curve, vec2(uv.x, 0.0), 0.0).r;
	float side = sign(float(uv.y > 0.5)-0.5);
	vertex += (perp*side) * width * curve_multiplier;
	
	tangent = perp;
	normal = cross(perp,dir_to_next_point);
}

void vertex(){
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX,1.0)).xyz;
	NORMAL = mat3(MODELVIEW_MATRIX) * NORMAL;
	TANGENT = mat3(MODELVIEW_MATRIX) * TANGENT;
	
	line_process(line_width,VERTEX,normalize(VERTEX),UV,NORMAL,TANGENT);
	
	BINORMAL = cross(TANGENT,NORMAL);
	
	float line_length = UV2.x;
	UV.x = 1.0-UV.x;
	UV2 = UV;
	UV2.x *= line_length;
}

uniform sampler2D albedo_tex : hint_albedo;
uniform bool tex_stretch = true;
uniform vec2 tex_scale = vec2(1.0,1.0);

uniform vec4 color : hint_color = vec4(vec3(1.0),1.0);
void fragment() {
	if (!FRONT_FACING) { NORMAL = -NORMAL; }
	
	vec2 base_uv = UV2;
	if (tex_stretch) {
		base_uv = UV;
	}
	base_uv *= tex_scale;
	
	float alpha_tex = texture(albedo_tex, base_uv).a;
	ALBEDO = color.rgb * COLOR.rgb;
	ALPHA = color.a * alpha_tex * COLOR.a;
}