shader_type spatial;

render_mode unshaded, 
	skip_vertex_transform, 
	cull_disabled, 
	depth_draw_never,
	depth_test_disabled;

uniform vec2 pixel_counts = vec2(1980,1080); 

uniform vec2 blur_offset = vec2(0,1);

uniform sampler2D color: hint_screen_texture;

void vertex() {
	POSITION = vec4(UV.xy * 2. - 1.,0,1);
	UV = UV;
	// Called for every vertex the material is visible on.
}

//void outline(){
	//
//}

void fragment() {
	ALBEDO = texture(color, SCREEN_UV).xyz / 3.;
	ALBEDO += texture(color, UV + blur_offset / pixel_counts).xyz / 3.;
	ALBEDO += texture(color, UV - blur_offset / pixel_counts).xyz / 3.;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
