shader_type canvas_item;

uniform float tiles: hint_range(0.0, 500.0, 0.1) = 20.0;
uniform float radius: hint_range(0.0, 1.0, 0.01) = 0.25;

uniform sampler2D intensity_texture: repeat_enable;
uniform float intensity_edge: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float intensity_blend: hint_range(0.0, 1.0, 0.01) = 0.25;

uniform vec2 speed = vec2(0.05);

float sdCircle(vec2 p, float r){
    return length(p) - r;
}

vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat)
{
	vec2 dir = uv - center;
	float r = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(r * zoom, angle * repeat), 1.0);
}

void fragment() {	
	vec2 uv = UV;
	vec2 delta = fwidth(uv); 
	float aspect_ratio = delta.y / delta.x;
	
	uv -= vec2(0.5);
	uv.x *= aspect_ratio; 

	vec2 offset = vec2(TIME * speed);
	// uv += offset;
	//uv += vec2(length((UV - vec2(0.5))), 0.0) * TIME * 0.001;
	//uv *= polar_coordinates(uv + vec2(TIME * 0.25), vec2(0.5), 0.5, 3.0);

	vec2 grid = uv * tiles;
    vec2 cell = floor(grid);
	vec2 fract_uv = fract(grid) - vec2(0.5);
	
  	vec2 cell_uv = (cell + 0.5) / tiles;
    float intensity = texture(intensity_texture, cell_uv).r;

	float i = smoothstep(
		intensity_edge - intensity_blend, 
		intensity_edge + intensity_blend, 
		intensity
	); 
	
	float r = radius * i * (UV.x * intensity);
	float dist = sdCircle(fract_uv, r);
	
	float d = step(dist, 0.0);
	COLOR = vec4(vec3(d), 1.0);
}


