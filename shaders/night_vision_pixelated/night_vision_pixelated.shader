shader_type canvas_item;

// https://www.shadertoy.com/view/4sGXWh
uniform int frame_number = 0;

float get_red(sampler2D sampler, vec2 uv)
{
	return texture(sampler, uv).r;
}
float get_green(sampler2D sampler, vec2 uv)
{
	return texture(sampler, uv).g;
}
float get_blue(sampler2D sampler, vec2 uv)
{
	return texture(sampler, uv).b;
}

float random_f()
{
	float seed = float(frame_number);
	for (int i = 0; i < 5; i++) {
		seed = mod(seed * 16807.0, 2147483647.0);
		return seed / 2147483647.0;
	}
}

void fragment()
{
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec4 fc = FRAGCOORD;
	float shift = 2.0;
	float size = 5.0;
	// Original
	// fragColor = texture(iChannel0, fragCoord / iResolution.xy);
	
	// Filtered
	// RGB Split and Pixelate
	vec4 output_color = texture(SCREEN_TEXTURE, fc.xy/i_resolution.xy);
	
	bool top = fc.y <= shift - 1.;
	bool left = fc.x <= shift - 1.;
	bool right = fc.x >= i_resolution.x - shift + 1.;
	bool bottom = fc.y >= i_resolution.y - shift + 1.;
	if (top) {
		output_color.r *= get_red(SCREEN_TEXTURE, (vec2(fc.x, fc.y + shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
	}
	else if (left) {
		output_color.r = get_red(SCREEN_TEXTURE, (vec2(fc.x, fc.y + shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
		output_color.g = get_green(SCREEN_TEXTURE, (vec2(fc.x + shift, fc.y - shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
	}
	else if (right) {
		output_color.r = get_red(SCREEN_TEXTURE, (vec2(fc.x, fc.y + shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
		output_color.b = get_blue(SCREEN_TEXTURE, (vec2(fc.x - shift, fc.y - shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
	}
	else if (bottom) {
		output_color.g = get_green(SCREEN_TEXTURE, (vec2(fc.x + shift, fc.y - shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
		output_color.b = get_blue(SCREEN_TEXTURE, (vec2(fc.x - shift, fc.y - shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
	}
	else {
		output_color.r = get_red(SCREEN_TEXTURE, (vec2(fc.x, fc.y + shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
		output_color.g = get_green(SCREEN_TEXTURE, (vec2(fc.x + shift, fc.y - shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
		output_color.b = get_blue(SCREEN_TEXTURE, (vec2(fc.x - shift, fc.y - shift) - vec2(mod(fc.x, size), mod(fc.y, size))) / i_resolution.xy);
	}
	
	// Night Vision
	output_color = vec4(output_color.r * 0.1, (output_color.g * output_color.g * output_color.g) * 0.9, output_color.b * 0.1, 1.0);
	
	// Brightness Correction
	output_color.g = pow(output_color.g, 1.1 / 3.0);
	
	// Scan Lines
	if (floor(mod(fc.y, 5.0)) == 0.0) {
		output_color *= 0.625;
	}
	else if (floor(mod(fc.y, 5.0)) == 2.0) {
		output_color *= 0.75;
	}
	else if (floor(mod(fc.y, 5.0)) == 0.0) {
		output_color *= 0.875;
	}
	
	// Vignette
	vec2 center_position = (fc.xy / i_resolution.xy) - vec2(0.5);
	float len = length(center_position);
	float vignette = smoothstep(0.8, 0.125, len);    
	output_color.rgb = mix(output_color.rgb, output_color.rgb * vignette, 0.5);
	
	// Finished!
	COLOR = output_color;
}