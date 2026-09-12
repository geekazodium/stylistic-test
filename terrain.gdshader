shader_type spatial;

render_mode skip_vertex_transform, ambient_light_disabled;//, unshaded;
uniform sampler2D height_map;
uniform float noise_scale;
uniform float finite_diff = 0.01;
uniform float terrain_scale = .02;

uniform float far_dist = 150;
uniform float near_dist = 10;

uniform float height_fade_limit = 10;

uniform vec3 color: source_color;

//varying float gradient;
varying float opacity;
varying float height;

float get_displace(vec2 pos){
	return texture(height_map, pos * terrain_scale).x;
}

void vertex() {
	vec3 pos = VERTEX.xyz + NODE_POSITION_WORLD;
	vec3 left_point = pos + vec3(finite_diff,0,0);
	vec3 far_point = pos + vec3(0,0,finite_diff);
	pos.y = get_displace(pos.xz) * noise_scale;
	left_point.y += get_displace(left_point.xz) * noise_scale;
	far_point.y += get_displace(far_point.xz) * noise_scale;
	vec3 left = normalize(left_point - pos);
	vec3 far = normalize(far_point - pos);
	vec3 norm = -cross(left, far);
	NORMAL = normalize((MODELVIEW_MATRIX * vec4(norm, 0.0)).xyz);
	VERTEX = (MODELVIEW_MATRIX * vec4(pos - NODE_POSITION_WORLD, 1.0)).xyz;
	//gradient = dot(norm, vec3(0,1,0));
	height = pos.y;
}

void fragment() {
	float depth = -VERTEX.z;
	//ALBEDO = vec3(0);
	float distance_fade = min(smoothstep(0,near_dist,depth), smoothstep(far_dist + 30., far_dist, depth));
	float height_fade = smoothstep(0, height_fade_limit, height);
	opacity = clamp(min(distance_fade, height_fade),0,1);
	ALBEDO = vec3(color);
	//vec3 ndc = vec3(SCREEN_UV,DEPTH);
	//float gradient_t = dot(NORMAL, vec3(0,0,1));
	//float surface_horizontalness = abs(1. - gradient);
	//float h_surf_darken = clamp(
		//surface_horizontalness * gradient_t,
		//0.,
		//1.
	//);
	//h_surf_darken = smoothstep(0.,1.,h_surf_darken);
	//h_surf_darken *= smoothstep(0,20.,height);
	//ALBEDO = color * (1. - h_surf_darken);//NORMAL * .5 + .5;

}

void light(){
	if (LIGHT_IS_AREA) {
        // Area light GGX shading.
        //DIFFUSE_LIGHT += LIGHT_AREA_DIFFUSE_MULTIPLIER * ATTENUATION * LIGHT_COLOR;
        //SPECULAR_LIGHT += LIGHT_AREA_SPECULAR_MULTIPLIER * ATTENUATION * LIGHT_COLOR * SPECULAR_AMOUNT;
    } else {
         //Used for all other light types (directional, omni, spot).
		float align = clamp(dot(NORMAL, LIGHT), 0.0, 1.0);
        vec3 base_light = align * ATTENUATION * LIGHT_COLOR / PI;
		//DIFFUSE_LIGHT *= non_ambient;
		DIFFUSE_LIGHT += color * (1. - opacity);
		DIFFUSE_LIGHT += clamp(base_light, 0, .2) * opacity;
    }
}
