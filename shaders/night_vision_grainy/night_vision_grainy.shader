shader_type canvas_item;

uniform float fade_in_delay = 1.0;
uniform float noise_amount = 1.0;

// https://www.shadertoy.com/view/Xsl3zf
float hash(float n)
{
	return fract(sin(n) * 43758.5453123);
}

void fragment()
{
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
	
	vec2 p = FRAGCOORD.xy / i_resolution;
	
	vec2 u = p * 2. - 1.;
	vec2 n = u * vec2(i_resolution.x / i_resolution.y, 1.0);
	vec3 c = texture(SCREEN_TEXTURE, p).xyz;
	
	c += sin(hash(TIME)) * 0.01;
	c += hash((hash(n.x) + n.y) * TIME) * (0.5 * noise_amount);
	c *= smoothstep(length(n * n * n * vec2(0.075, 0.4)), 1.0, 0.4);
	c *= smoothstep(0.001, 3.5 * fade_in_delay, TIME) * 1.5;
	
	c = dot(c, vec3(0.2126, 0.7152, 0.0722)) * vec3(0.2, 1.5 - hash(TIME) * 0.1, 0.4);
	
	COLOR = vec4(c, 1.0);
}