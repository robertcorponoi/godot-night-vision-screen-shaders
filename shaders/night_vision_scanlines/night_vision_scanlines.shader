shader_type canvas_item;

// https://www.shadertoy.com/view/XlsGzs
void fragment()
{
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec4 color;
	
	vec2 uv = FRAGCOORD.xy / i_resolution.xy;
	
	float distanceFromCenter = length(uv - vec2(0.5,0.5));
	
	float vignetteAmount;
	float lum;
	
	vignetteAmount = 0.6;
	vignetteAmount = smoothstep(0.1, 1.0, vignetteAmount);
	
	color = texture(SCREEN_TEXTURE, uv);
	
	// luminance hack, responses to red channel most
	lum = dot(color.rgb, vec3(0.85, 0.30, 0.10));
	
	color.rgb = vec3(0.0, lum, 0.0);
	
	// scanlines
	color += 0.1 * sin(uv.y * i_resolution.y * 2.0);
	
	// screen flicker
	color += 0.005 * sin(TIME * 16.0);
	
	// vignetting
	color *=  vignetteAmount * 1.0;
	
	COLOR = color;
}