shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear;

group_uniforms Color;
uniform vec4 c1: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 c2: source_color = vec4(0.0, 0.0, 0.0, 1.0);

group_uniforms Shape;
uniform int shape_type: hint_enum("Circle", "Triangle", "Pentagon", "Hexagon", "Hexagram") = 0;
uniform vec2 offset = vec2(10.0, 0.0);
uniform float radius: hint_range(0.0, 5.0, 0.01)  = 0.9;
uniform float speed: hint_range(0.0, 10.0, 0.01) = 3.0;
uniform float amount: hint_range(0.0, 100.0, 0.1) = 10;
uniform float radius_variation: hint_range(0.0, 10.0, 0.01) = 0.25;

float sdCircle( vec2 p, float r )
{
    return length(p) - r;
}

float sdEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;
    if( p.x+k*p.y>0.0 ) p = vec2(p.x-k*p.y,-k*p.x-p.y)/2.0;
    p.x -= clamp( p.x, -2.0*r, 0.0 );
    return -length(p)*sign(p.y);
}

float sdPentagon( in vec2 p, in float r )
{
    const vec3 k = vec3(0.809016994,0.587785252,0.726542528);
    p.x = abs(p.x);
    p -= 2.0*min(dot(vec2(-k.x,k.y),p),0.0)*vec2(-k.x,k.y);
    p -= 2.0*min(dot(vec2( k.x,k.y),p),0.0)*vec2( k.x,k.y);
    p -= vec2(clamp(p.x,-r*k.z,r*k.z),r);    
    return length(p)*sign(p.y);
}

float sdHexagon( in vec2 p, in float r )
{
    const vec3 k = vec3(-0.866025404,0.5,0.577350269);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= vec2(clamp(p.x, -k.z*r, k.z*r), r);
    return length(p)*sign(p.y);
}

float sdHexagram( in vec2 p, in float r )
{
    const vec4 k = vec4(-0.5,0.8660254038,0.5773502692,1.7320508076);
    p = abs(p);
    p -= 2.0*min(dot(k.xy,p),0.0)*k.xy;
    p -= 2.0*min(dot(k.yx,p),0.0)*k.yx;
    p -= vec2(clamp(p.x,r*k.z,r*k.w),r);
    return length(p)*sign(p.y);
}

float draw_shape(vec2 p, float r) {
	switch (shape_type) {
		case 0:
			return sdCircle(p, r);
		case 1:
			return sdEquilateralTriangle(p, r);
		case 2:
			return sdPentagon(p, r);
		case 3:
			return sdHexagon(p, r);
		case 4:
			return sdHexagram(p, r);
		default:
			return sdCircle(p, r);
	}
}

void fragment() {
	// COMMENT to use SCREEN_UV instead
	//vec2 texture_size = vec2(textureSize(SCREEN_TEXTURE, 0));
	//float aspect_ratio = texture_size.x / texture_size.y;
	//vec2 uv = SCREEN_UV;
	
	vec2 uv = UV;
	float delta_x = fwidth(UV.x);
	float delta_y = fwidth(UV.y);
	float aspect_ratio = delta_y / delta_x;
	
	vec2 p = uv - vec2(0.5);

    p.x *= aspect_ratio;
	
	vec2 fact_uv = fract(p * amount) - 0.5;

	float x_offset = uv.x * offset.x;
	float y_offset = uv.y * offset.y;
	float wav_offset = x_offset + y_offset;
	float wave = (sin(TIME * speed + wav_offset) + 1.0) * radius_variation;
	float r = wave * radius;
	//float r = wave + radius; 

	float x = r;
	float dist = draw_shape(fact_uv, x);
	vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
	//float c = step(dist, 0.0);
	
	if (dist >= 0.0) {
		color = c1;
	} else {
		color = c2;
	}
	
	COLOR = color;
}
