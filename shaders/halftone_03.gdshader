shader_type canvas_item;

group_uniforms Colors;
uniform vec4 bg_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 fg_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Intensity;
uniform sampler2D intensity_texture: repeat_enable;
uniform vec2 intenstity_falloff = vec2(0.0, 0.0);

group_uniforms Movement;
uniform float rotation_degrees: hint_range(0.0, 360, 0.1) = 0.0;
uniform float tiles: hint_range(0, 100, 1) = 10;
uniform float speed: hint_range(0.0, 10.0, 0.1) = 2.0;
uniform vec2 offset = vec2(1.0, 0.0);

group_uniforms Wave;
uniform float wave_intensity: hint_range(0.0, 1.0, 0.1) = 0.0;
uniform float wave_speed: hint_range(0.0, 10.0, 0.01) = 2.0;
uniform float wave_freq: hint_range(0.0, 10.0, 0.01) = 0.5;

group_uniforms Antialising;
uniform float antialising_amount: hint_range(0.0, 100.0, 0.1) = 20.0;

float sdCircle(vec2 p, float r){
    return length(p) - r;
}

mat2 rotate2d(float _angle){
	return mat2(
		vec2(cos(_angle),-sin(_angle)),
		vec2(sin(_angle),cos(_angle))
	);
}

void fragment() {
    vec2 uv = UV;

	vec2 delta = fwidth(uv);
    float aspect_ratio = delta.y / delta.x;

    uv -= vec2(0.5);
    uv.x *= aspect_ratio;
	uv *= rotate2d(radians(rotation_degrees));

    vec2 grid = uv * tiles;
	vec2 uv_offset = offset * TIME * speed;
	vec2 fract_uv = fract(grid + uv_offset) - 0.5;
	vec2 cell = floor(grid);
  	vec2 cell_uv = (cell + 0.5) / tiles;

	float t = TIME * wave_speed;
	float wave = (sin(t * wave_freq) + 1.0) * 0.5;
	float w = wave_intensity <= 0.0 ? 1.0: wave * wave_intensity;

	float intensity = texture(intensity_texture, UV).r;
	float intensity_offset = (UV.x * intenstity_falloff.x) + (UV.y * intenstity_falloff.y);
	float r = intensity + intensity_offset * intensity * w;

	float dist = sdCircle(fract_uv, r);
	//float d = step(dist, 0.0);
	//vec3 c = vec3(d);

	// Antialising
	float aa = fwidth(dist);
	float d = smoothstep(-antialising_amount, antialising_amount, dist / delta.y);
	vec4 color = mix(fg_color, bg_color, d);
	COLOR = color;
}
