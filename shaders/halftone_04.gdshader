shader_type canvas_item;

uniform vec4 bg_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 fg_color: source_color = vec4(1.0);

uniform float tiles: hint_range(0.0, 500.0, 0.1) = 20.0;
uniform float radius: hint_range(0.0, 1.0, 0.01) = 0.25;

uniform sampler2D intensity_texture;
uniform float intensity_edge: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float intensity_blend: hint_range(0.0, 1.0, 0.01) = 0.25;

uniform vec2 speed = vec2(0.05);

float sdCircle(vec2 p, float r){
    return length(p) - r;
}

void fragment() {	
	vec2 uv = UV;
	vec2 delta = fwidth(uv); 
	float aspect_ratio = delta.y / delta.x;
	
	uv -= vec2(0.5);
	uv.x *= aspect_ratio; 

	vec2 circ_uv = vec2(length(UV), 0.0);

	vec2 grid = uv * tiles;
    vec2 cell = floor(grid);
	vec2 fract_uv = fract(grid) - vec2(0.5);
	
  	vec2 cell_uv = (cell + 0.5) / tiles;
    float intensity = texture(intensity_texture, UV).r;
	
	float r = radius * intensity;
	float dist = sdCircle(fract_uv, r);
	
	const float aa_amount = 10.0;
	float aa = fwidth(dist);
	float d = smoothstep(-aa_amount, aa_amount, dist / delta.y);
	vec4 color = mix(fg_color, bg_color, d);	
	COLOR = color;
}


