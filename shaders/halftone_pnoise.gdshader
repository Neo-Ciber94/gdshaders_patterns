shader_type canvas_item;

group_uniforms Colors;
uniform vec4 bg_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 fg_color: source_color = vec4(1.0);

group_uniforms Tiles;
uniform float tiles: hint_range(0.0, 500.0, 0.1) = 20.0;
uniform float radius: hint_range(0.0, 1.0, 0.01) = 0.25;
uniform float blend: hint_range(0.0, 10.0, 0.1) = 2.0;

group_uniforms Noise;
uniform int noise_seed = 0;
uniform float noise_size: hint_range(0.0, 100.0, 0.1) = 4.0;
uniform float noise_speed: hint_range(0.0, 100.0, 0.1) = 1.0;
uniform int noise_interpolation: hint_enum("None", "Smoothstep", "Cubic", "Quintic") = 2;

group_uniforms Antialising;
uniform float antialising_amount: hint_range(0.0, 100.0, 0.1) = 10.0;

float sdCircle(vec2 p, float r){
    return length(p) - r;
}

// https://github.com/SuboptimalEng/shader-tutorials/blob/main/05-perlin-noise/shader.frag
vec2 randomGradient(vec2 p) {
  p = p + float(noise_seed);
  float x = dot(p, vec2(123.4, 234.5));
  float y = dot(p, vec2(234.5, 345.6));
  vec2 gradient = vec2(x, y);
  gradient = sin(gradient);
  gradient = gradient * 43758.5453;

  // update noise function with time
  gradient = sin(gradient + TIME * noise_speed);
  return gradient;
}

vec2 cubic(vec2 p) {
  return p * p * (3.0 - p * 2.0);
}

vec2 quintic(vec2 p) {
  return p * p * p * (10.0 + p * (-15.0 + p * 6.0));
}

float pnoise(in vec2 uv) {
  vec2 gridId = floor(uv);
  vec2 gridUv = fract(uv);

  // start by finding the coords of grid corners
  vec2 bl = gridId + vec2(0.0, 0.0);
  vec2 br = gridId + vec2(1.0, 0.0);
  vec2 tl = gridId + vec2(0.0, 1.0);
  vec2 tr = gridId + vec2(1.0, 1.0);

  // find random gradient for each grid corner
  vec2 gradBl = randomGradient(bl);
  vec2 gradBr = randomGradient(br);
  vec2 gradTl = randomGradient(tl);
  vec2 gradTr = randomGradient(tr);

  // find distance from current pixel to each grid corner
  vec2 distFromPixelToBl = gridUv - vec2(0.0, 0.0);
  vec2 distFromPixelToBr = gridUv - vec2(1.0, 0.0);
  vec2 distFromPixelToTl = gridUv - vec2(0.0, 1.0);
  vec2 distFromPixelToTr = gridUv - vec2(1.0, 1.0);

  // calculate the dot products of gradients + distances
  float dotBl = dot(gradBl, distFromPixelToBl);
  float dotBr = dot(gradBr, distFromPixelToBr);
  float dotTl = dot(gradTl, distFromPixelToTl);
  float dotTr = dot(gradTr, distFromPixelToTr);

  // smooth out gridUvs
  switch (noise_interpolation) {
	case 1:
		gridUv = smoothstep(0.0, 1.0, gridUv);
	case 2:
		gridUv = cubic(gridUv);
	case 3:
		gridUv = quintic(gridUv);
	default:
		break;
	}

  // perform linear interpolation between 4 dot products
  float b = mix(dotBl, dotBr, gridUv.x);
  float t = mix(dotTl, dotTr, gridUv.x);
  float perlin = mix(b, t, gridUv.y);

  // return perlin noise
  return perlin;
}

void fragment() {	
	vec2 uv = UV;
	vec2 delta = fwidth(uv); 
	float aspect_ratio = delta.y / delta.x;
	
	uv -= vec2(0.5);
	uv.x *= aspect_ratio; 

	vec2 grid = uv * tiles;
    vec2 cell = floor(grid);
	vec2 fract_uv = fract(grid) - vec2(0.5);
  	vec2 cell_uv = (cell + 0.5) / tiles;
	
	// smooth the uv to avoid hard edges
	cell_uv = smoothstep(vec2(-blend), vec2(blend), cell_uv);
	
    float intensity = pnoise(cell_uv * noise_size);
	
	float r = radius * 0.5 + radius * intensity;
	float dist = sdCircle(fract_uv, r);
	
	float aa = fwidth(dist);
	float d = smoothstep(-antialising_amount, antialising_amount, dist / delta.y);
	vec4 color = mix(fg_color, bg_color, d);
	
	COLOR = color;
	//COLOR = vec4(cell_uv.x, cell_uv.y, 0.0, 1.0);
}


