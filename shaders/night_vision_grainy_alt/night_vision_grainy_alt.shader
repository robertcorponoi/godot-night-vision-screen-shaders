shader_type canvas_item;

// https://www.shadertoy.com/view/3lcXzl
uniform float noise = 0.2;
uniform float flicker = 0.02;
uniform float luminance = 0.5;

void fragment() {
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
	//Normalized pixel coordinates (from 0 to 1)
	vec2 uv = FRAGCOORD.xy / i_resolution.xy;
	//scene color
	vec4 color = texture(SCREEN_TEXTURE, uv) * vec4(0.5, 0.9, 0.52, 1.0);
	//vigenette
	float d = length(uv - 0.5);
	float c = 1.0;
	// float c = 1.3 - d;
	float vignette = smoothstep(0.5, 1.0, c);
	//Luminance
	color = luminance * color;
	//simple noise effect
	float noise_2 = noise * fract(sin(dot(uv, vec2(10.0, 80.0) + (TIME))) * 10000.0);
	//apply noise
	color += noise_2 / (vignette * 2.2);
	//apply vignette
	color *= vignette * 1.5;
	//Screen flicker
	color += flicker * cos(sin(TIME * 120.0));
	//Final output
	COLOR = vec4(color);
}