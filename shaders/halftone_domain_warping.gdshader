shader_type canvas_item;

uniform vec4 bg_color: source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 fg_color: source_color = vec4(1.0);

uniform float tiles: hint_range(0.0, 500.0, 0.1) = 20.0;
uniform float radius: hint_range(0.0, 1.0, 0.01) = 0.25;


uniform float intensity_edge: hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float intensity_blend: hint_range(0.0, 1.0, 0.01) = 0.25;

uniform vec2 speed = vec2(0.05);

float sdCircle(vec2 p, float r){
    return length(p) - r;
}

float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

const int NUM_OCTAVES = 8;
const float H = 5.0;

// https://iquilezles.org/articles/fbm/
float fbm1(in vec2 x)
{    
    float t = 0.0;
    for( int i=0; i< NUM_OCTAVES; i++ )
    {
        float f = pow( 2.0, float(i) );
        float a = pow(f, -H);
        t += a*noise(f*x);
    }
    return t;
}

float fbm2( in vec2 x)
{    
    float G = exp2(-H);
    float f = 1.0;
    float a = 1.0;
    float t = 0.0;
    for( int i=0; i< NUM_OCTAVES; i++ )
    {
        t += a*noise(f*x);
        f *= 2.0;
        a *= G;
    }
    return t;
}

float pattern_1( in vec2 p )
{
    return fbm2( p );
}

float pattern_2( in vec2 p, vec2 q, vec2 r )
{
    q.x = fbm2( p + vec2(0.0,0.0) );
    q.y = fbm2( p + vec2(5.2,1.3) );

    r.x = fbm2( p + 4.0*q + vec2(1.7,9.2) );
    r.y = fbm2( p + 4.0*q + vec2(8.3,2.8) );

    return fbm2( p + 4.0*r );
}

vec2 warp_field(vec2 p, float t)
{
    vec2 q = vec2(
        fbm2(p + vec2(0.0, 4.0) + 0.7*t),
        fbm2(p + vec2(3.5, 2.0) - 0.4*t)
    );

    vec2 r = vec2(
        fbm2(p + 4.0*q + vec2(4.1, 3.3) + 0.3*t),
        fbm2(p + 4.0*q + vec2(2.2, 1.7) - 0.2*t)
    );

    return 0.35 * q + 0.18 * r;
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
	
    float t = TIME * 1.25;
    vec2 base = UV * 4.0;              // base sampling scale
   	vec2 w = warp_field(base, t);      // warped offset
    float intensity = fbm2(base + w);  // final ripple field ✨
	
	float r = radius * intensity;
	float dist = sdCircle(fract_uv, r);
	
	const float aa_amount = 10.0;
	float aa = fwidth(dist);
	float d = smoothstep(-aa_amount, aa_amount, dist / delta.y);
	vec4 color = mix(fg_color, bg_color, d);	
	COLOR = color;
}


