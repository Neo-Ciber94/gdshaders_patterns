shader_type canvas_item;

group_uniforms Colors;
uniform vec4 color_1: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_2: source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Intensity;
uniform sampler2D intensity_texture;
uniform vec2 intenstity_falloff = vec2(0.5, 0.0);

group_uniforms Movement;
uniform float tiles: hint_range(0, 100, 1) = 10;
uniform float speed: hint_range(0.0, 10.0, 0.1) = 2.0;
uniform vec2 offset = vec2(1.0, 0.0);

float sdCircle(vec2 p, float r){
    return length(p) - r;
}

void fragment() {
    vec2 uv = UV;

    float delta_x = fwidth(UV.x);
    float delta_y = fwidth(UV.y);
    float aspect_ratio = delta_y / delta_x;

    uv -= vec2(0.5);
    uv.x *= aspect_ratio;

    vec2 grid = uv * tiles;
	vec2 uv_offset = offset * TIME * speed;
	vec2 fract_uv = fract(grid + uv_offset) - 0.5;

	const float wave_speed = 2.0;
	const float wave_freq = 0.5;

	float t = TIME * wave_speed;
	float wave = (sin(t * wave_freq) + 1.0) * 0.5;

	float intensity = texture(intensity_texture, UV).r;
	float intensity_offset = (UV.x * intenstity_falloff.x) + (UV.y * intenstity_falloff.y);
	float r = intensity + intensity_offset * intensity;

	float dist = sdCircle(fract_uv, r);
	float d = step(dist, 0.0);
	vec3 c = vec3(d);

	COLOR = d <= 0.0 ? color_1: color_2;
}
