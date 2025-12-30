shader_type canvas_item;

group_uniforms Colors;
uniform vec4 color_1: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_2: source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Values;
uniform sampler2D intensity_mask: repeat_enable;
uniform float tiles: hint_range(0.0, 200.0, 0.1) = 50.0;
uniform float radius: hint_range(0.0, 10.0, 0.01) = 0.5;
uniform float speed: hint_range(0.0, 10.0, 0.01) = 5.0;

float sdCircle(vec2 p, float r){
    return length(p) - r;
}

// Hash function to generate pseudo-random values per cell
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
    vec2 uv = UV;

    float delta_x = fwidth(UV.x);
    float delta_y = fwidth(UV.y);
    float aspect_ratio = delta_y / delta_x;

    uv -= vec2(0.5);
    uv.x *= aspect_ratio;

    vec2 grid = uv * tiles;
	vec2 cell = floor(grid);
	vec2 local_uv = cell / tiles;

    vec2 cell_center = (cell + vec2(0.5)) / tiles;
    vec2 mask_uv = cell_center;
    mask_uv.x /= aspect_ratio;
    mask_uv += vec2(0.5);

	vec2 local_pos = fract(grid) - vec2(0.5);
	float intensity = texture(intensity_mask, mask_uv).r;

    float t = TIME * speed;
	//float offset = uv.x + uv.y;
	float offset = uv.x + uv.y;

    float pulse = ((sin(t + offset) + 1.0) * 0.5);

	float r = radius * intensity * pulse;
	float dist = sdCircle(local_pos, r);
	//float x = step(dist, 0.0);
	vec4 target_color = vec4(1.0);

	if (dist >= 0.0) {
		target_color = color_1;
	} else {
		target_color = color_2;
	}

	//float mask_value = texture(intensity_mask, UV).r;
//
	//if (mask_value >= 0.6) {
		//target_color = color_2;
	//}

	COLOR = target_color;

}
