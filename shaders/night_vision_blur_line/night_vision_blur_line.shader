shader_type canvas_item;

// https://www.shadertoy.com/view/Xsf3RN
float remap(float value, float inputMin, float inputMax, float outputMin, float outputMax)
{
	return (value - inputMin) * ((outputMax - outputMin) / (inputMax - inputMin)) + outputMin;
}

float rand(vec2 n, float time)
{
	return 0.5 + 0.5 * fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453 + time);
}

vec4 mask_blend(vec4 a, vec4 b)
{
	vec4 one = vec4(1.0, 1.0, 1.0, 1.0);
	return one - (one - a) * (one - b);
}

float f1(float x)
{
	return -4.0 * pow(x - 0.5, 2.0) + 1.0;
}

void fragment()
{
	vec2 iResolution = (1.0 / SCREEN_PIXEL_SIZE);
	
	vec2 uv = FRAGCOORD.xy / iResolution.xy;
	
	float wide = iResolution.x / iResolution.y;
	float high = 1.0;
	
	vec2 position = vec2(uv.x * wide, uv.y);
	
	float greenness = 0.4;
	vec4 coloring = vec4(1.0 - greenness, 1.0, 1.0 - greenness, 1.0);
	
	float noise = rand(uv * vec2(0.1, 1.0), TIME * 5.0);
	float noiseColor = 1.0 - (1.0 - noise) * 0.3;
	vec4 noising = vec4(noiseColor, noiseColor, noiseColor, 1.0);
	
	float warpLine = fract(-TIME * 0.5);
	
	/** debug
	if(abs(uv.y - warpLine) < 0.003)
	{
		fragColor = vec4(1.0, 1.0, 1.0, 1.0);
		return;
	}
    */
	
	float warpLen = 0.1;
	float warpArg01 = remap(clamp((position.y - warpLine) - warpLen * 0.5, 0.0, warpLen), 0.0, warpLen, 0.0, 1.0);
	float offset = sin(warpArg01 * 10.0)  * f1(warpArg01);
	
	vec4 lineNoise = vec4(1.0, 1.0, 1.0, 1.0);
	if(abs(uv.y - fract(-TIME * 19.0)) < 0.0005)
	{
		lineNoise = vec4(0.5, 0.5, 0.5, 1.0);
	}
	
	vec4 base = texture(SCREEN_TEXTURE, uv + vec2(offset * 0.02, 0.0));
	COLOR = base * coloring * noising * lineNoise;
}