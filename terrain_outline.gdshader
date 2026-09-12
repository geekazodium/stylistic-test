shader_type spatial;

render_mode cull_front, skip_vertex_transform;
uniform sampler2D height_map;
uniform float noise_scale;
uniform float finite_diff = 0.01;
uniform float terrain_scale = .02;
uniform float thickness = .01;
uniform float thickness_pow = 1.5;

uniform float far_dist = 150;
uniform float near_dist = 10;

uniform float height_fade_limit = 10;

varying float height;

float get_displace(vec2 pos){
	return texture(height_map, pos * terrain_scale).x;
}

void vertex() {
	vec3 pos = VERTEX.xyz + NODE_POSITION_WORLD;
	vec3 left_point = pos + vec3(finite_diff,0,0);
	vec3 far_point = pos + vec3(0,0,finite_diff);
	
	height = get_displace(pos.xz) * noise_scale;
	
	pos.y = height;
	left_point.y += get_displace(left_point.xz) * noise_scale;
	far_point.y += get_displace(far_point.xz) * noise_scale;
	vec3 left = normalize(left_point - pos);
	vec3 far = normalize(far_point - pos);
	vec3 norm = -cross(left, far);
	
	float d = length(pos - CAMERA_POSITION_WORLD);
	
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(norm, 0.0)).xyz);
	VERTEX = NORMAL * thickness * pow(d, thickness_pow) + (MODELVIEW_MATRIX * vec4(pos - NODE_POSITION_WORLD, 1.0)).xyz;
}

void fragment() {
	float depth = -VERTEX.z;
	ALBEDO = vec3(0);
	float distance_fade = min(smoothstep(0,near_dist,depth), smoothstep(far_dist + 30., far_dist, depth));
	float height_fade = smoothstep(0, height_fade_limit, height);
	ALPHA = min(distance_fade, height_fade);
}
