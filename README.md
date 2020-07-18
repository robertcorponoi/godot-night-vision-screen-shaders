<h1 align="center">Godot Night Vision Screen Shaders</h1>

<p align="center">A demo repository for an article on night vision screen shaders ported from Shadertoy.<p>

The contents of this README are the same as the article on my [website](https://robertcorponoi.com/shadertoy-to-godot-night-vision-screen-shaders/). If you came from the website, you can just download or clone the repo and import the project in Godot to see the screen shaders in action.

## Introduction

In this guide we're going to take some interesting night vision shaders from Shadertoy and port them over to Godot to use as screen shaders, so we can have a cool effect for our 3D scene.

Shaders are not my specialty (yet) so I won't be able to describe every shader in detail but what I can describe is differences between the original and ported versions so that it can maybe help you port over shaders yourself in the future. Each example will begin with the original shader followed by the Godot shader in order to be as concise as possible.

If you would like to see the final results, you can download or clone this repo and import it in Godot to see the screen shaders in action.

**Note:** These shaders probably use various licenses, so I recommend asking the author for permission on Shadertoy if the license is unknown or just use them as a baseline to create your own shaders.

## Table of Contents

If you would like to skip to a specific shader, use the navigation menu below:

- [Creating a Screen Shader](#creating-a-screen-shader)
- [Shader 1: Grainy Night Vision](#shader-1---grainy-night-vision)
- [Shader 2: Grainy Night Vision Alt](#shader-2---grainy-night-vision-alt)
- [Shader 3: Blur Night Vision](#shader-3---blur-night-vision)
- [Shader 4: Scanlines Night Vision](#shader-4---scanlines-night-vision)
- [Shader 5: Pixelated Night Vision](#shader-5---pixelated-night-vision)

## Creating a Screen Shader

Before we get into the shaders, let's see how we can create a screen shader in 3D. First, we need to start out with a 3D scene so create a new scene and set the root node to be a spatial.

After this, we want to set up a little scene so we can actually see something through the night vision shader so just add a couple CSG spheres or shapes and add a Camera that's pointed towards them.

Here is the scene I've set up below:

![Scene Setup](../../images/jul/godot-night-vision-screen-shaders/scene-setup.png)

Now for the screen shader part, let's say that your current scene heirarchy looks like so:

![Initial Scene Tree](../../images/jul/godot-night-vision-screen-shaders/initial-scene-tree.png)

We want to add a `ColorRect` node below the below the Camera node and then while the `ColorRect` node is selected, go to the top toolbar and select `Layout -> Full Rect` and it'll make the `ColorRect` take up the whole screen.

Lastly, while the `ColorRect` node is selected, go to the inspector and change the material to a new shader material, click into the new shader material, and under `Shader` you click `New Shader` and finally click into that to bring up the Shader editor. After you write the shader I highly recommend saving both the shader and the material into their own resources so you don't have to create a new material and shader every time.

![Screen Shader Material Setup](../../images/jul/godot-night-vision-screen-shaders/screen-shader-setup.png)

Now that the shader editor is open you can use any of the shaders below and when you run your scene you'll be able to see your 3D scene but with a night vision filter in front of the camera.

## Shader 1: Grainy Night Vision

This first shader is going to consist of a grainy night vision effect with a bit of tunneling around the edges. The original code for this shader can be found on [Shadertoy](https://www.shadertoy.com/view/Xsl3zf).

**Shadertoy Shader**

```glsl
// by Nikos Papadopoulos, 4rknova / 2013
// WTFPL

float hash(in float n) { return fract(sin(n)*43758.5453123); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
	
	vec2 u = p * 2. - 1.;
	vec2 n = u * vec2(iResolution.x / iResolution.y, 1.0);
	vec3 c = texture(iChannel0, p).xyz;
    
    
	// flicker, grain, vignette, fade in
	c += sin(hash(iTime)) * 0.01;
	c += hash((hash(n.x) + n.y) * iTime) * 0.5;
	c *= smoothstep(length(n * n * n * vec2(0.075, 0.4)), 1.0, 0.4);
    c *= smoothstep(0.001, 3.5, iTime) * 1.5;
	
	c = dot(c, vec3(0.2126, 0.7152, 0.0722)) 
	  * vec3(0.2, 1.5 - hash(iTime) * 0.1,0.4);
	
	fragColor = vec4(c,1.0);
}
```

**Godot Shader**

```glsl
// For Godot we have to specify the shader type. Since this shader goes on a ColorRect node, it's 2D and all 2D shaders are of type `canvas_item`.
shader_type canvas_item;

// I wanted to extend the original shader a bit by offering 2 params that could be customized via in the inspector or code.

// The amount of time that it takes to fade in from black to the night vision. A value lower than 1 will result in faster fade in times and a value higher than 1 will result in longer fade in times.
uniform float fade_in_delay = 1.0;
// The amount of grain applied to the night vision.
uniform float noise_amount = 1.0;

// Only difference here is that we don't need to specify `in` in the parameter.
float hash(float n)
{
	return fract(sin(n) * 43758.5453123);
}

// `mainImage` is always `fragment` in Godot and it takes no arguments.
void fragment()
{
    // Shadertoy has an `iResolution` global variable but we don't have access to that in Godot. The Godot docs recommend either using the following definition below or passing it in manually.
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
	
    // `fragCoord` is `FRAGCOORD` in Godot.
	vec2 p = FRAGCOORD.xy / i_resolution;
	
	vec2 u = p * 2. - 1.;
	vec2 n = u * vec2(i_resolution.x / i_resolution.y, 1.0);
    // Instead of `iChannel0` we have `TEXTURE` and `SCREEN_TEXTURE` available to us and since we want this to be a screen shader we use `SCREEN_TEXTURE`.
	vec3 c = texture(SCREEN_TEXTURE, p).xyz;
	
    // Instead of `iTime` we use the global `TIME`.
	c += sin(hash(TIME)) * 0.01;
	c += hash((hash(n.x) + n.y) * TIME) * (0.5 * noise_amount);
	c *= smoothstep(length(n * n * n * vec2(0.075, 0.4)), 1.0, 0.4);
	c *= smoothstep(0.001, 3.5 * fade_in_delay, TIME) * 1.5;
	
	c = dot(c, vec3(0.2126, 0.7152, 0.0722)) * vec3(0.2, 1.5 - hash(TIME) * 0.1, 0.4);
	
    // `fragColor` is `COLOR` in Godot.
	COLOR = vec4(c, 1.0);
}
```

So I've highlighted the differences but I'll go over them again quickly. Every shader in Godot needs to have a `shader_type` and since this is a screen shader and will be used on a `ColorRect` node, it's the same type as all 2D shaders, `canvas_item`.

Below that I've added a couple uniforms so that the fade-in time and noise amount can be adjusted in the inspector or by code. The rest comes down to constants such as `iResolution`, `fragCoord`, `time`, and `fragColor`. `iResolution` is a global in Shadertoy that we have to define and according to the Godot docs we can define it as `1.0 / SCREEN_PIXEL_SIZE` or we can pass it in, so we just use the first method. The other globals match up to other globals in Godot such as `fragCoord` is `FRAGCOORD`, `time` is `TIME`, and `fragColor` is `COLOR`.

An image of the effect can be seen below and a short gif of it can be found on Gyfcat [here](https://gfycat.com/willingwhitebantamrooster)
![Grainy Night Vision](../../images/jul/shadertoy-to-godot-night-vision/night-vision-grainy.png)

## Shader 2: Grainy Night Vision Alt

This next shader is similar to the first one but with a different grain and look. The original code for this shader can be found on [Shadertoy](https://www.shadertoy.com/view/3lcXzl).

**Note:** This shader has a slight amount of screen flickering so if you're sensitive to it you should set it to zero and definitely be cautious about setting the value too high as it can be intense.

**Shadertoy Shader**

```glsl
#define NOISE 0.2
#define FLICKER 0.02
#define LUMINANCE 0.8

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    //scene color
    vec4 color = texture(iChannel0,uv)*vec4(0.5,0.9,0.52,1.0);
    //vigenette
    float d = length(uv-0.5);
    float c = 1.3 - d;
    float vignette = smoothstep(0.5,1.0,c);
    //Luminance
    color = LUMINANCE*color;
    //simple noise effect
	float noise  = NOISE*fract(sin(dot(uv,vec2(10.0, 80.0)+(iTime) ))*10000.0);
    //apply noise
    color += noise/(vignette*2.2);
    //apply vignette
    color *= vignette*1.5;
    //Screen flicker
    color += FLICKER*cos(sin(iTime*120.0));
    //Final output
    fragColor = vec4(color);
}
```

**Godot Shader**

```glsl
// For Godot we have to specify the shader type. Since this shader goes on a ColorRect node, it's 2D and all 2D shaders are of type `canvas_item`.
shader_type canvas_item;

// The original shader contains these variables below with `#define` but since we don't have access to that we just declare them as uniforms instead.

// The amount of grain to apply to the night vision.
uniform float noise = 0.2;
// The amount that the screen should flicker.
uniform float flicker = 0.02;
// Affects how bright the night vision effect is.
uniform float luminance = 0.5;

// `mainImage` is always `fragment` in Godot and it takes no arguments.
void fragment() {
    // Shadertoy has an `iResolution` global variable but we don't have access to that in Godot. The Godot docs recommend either using the following definition below or passing it in manually.
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;

	// Normalized pixel coordinates (from 0 to 1)
    // `fragCoord` is `FRAGCOORD` in Godot.
	vec2 uv = FRAGCOORD.xy / i_resolution.xy;

	// scene color
    // Instead of `iChannel0` we have `TEXTURE` and `SCREEN_TEXTURE` available to us and since we want this to be a screen shader we use `SCREEN_TEXTURE`.
	vec4 color = texture(SCREEN_TEXTURE, uv) * vec4(0.5, 0.9, 0.52, 1.0);

	// vigenette
	float d = length(uv - 0.5);
	float c = 1.0;
	// float c = 1.3 - d;
	float vignette = smoothstep(0.5, 1.0, c);

	// Luminance
	color = luminance * color;

	// simple noise effect
    // Instead of `iTime` we use the global `TIME`.
	float noise_2 = noise * fract(sin(dot(uv, vec2(10.0, 80.0) + (TIME))) * 10000.0);

	// apply noise
	color += noise_2 / (vignette * 2.2);

	// apply vignette
	color *= vignette * 1.5;

	// Screen flicker
	color += flicker * cos(sin(TIME * 120.0));

	// Final output
    // `fragColor` is `COLOR` in Godot.
	COLOR = vec4(color);
}
```

An image of the effect can be seen below and a short gif of it can be found on Gyfcat [here](https://gfycat.com/tintedfittingimpala)
![Grainy Night Vision Alt](../../images/jul/shadertoy-to-godot-night-vision/night-vision-grainy-alt.png)

## Shader 3: Blur Night Vision

This next shader includes a blurred line that goes down the screen to simulate an effect whose name I can't really pinpoint. The original code for this shader can be found on [Shadertoy](https://www.shadertoy.com/view/Xsf3RN).

You're going to notice a big chunk missing in the ported code and that's because Godot doesn't yet have support for structs in shaders so we can't use the circles in the effect.

**Shadertoy Shader**

```glsl
//utility
float remap(float value, float inputMin, float inputMax, float outputMin, float outputMax)
{
    return (value - inputMin) * ((outputMax - outputMin) / (inputMax - inputMin)) + outputMin;
}
float rand(vec2 n, float time)
{
  return 0.5 + 0.5 * 
     fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453 + time);
}

struct Circle
{
	vec2 center;
	float radius;
};
	
vec4 circle_mask_color(Circle circle, vec2 position)
{
	float d = distance(circle.center, position);
	if(d > circle.radius)
	{
		return vec4(0.0, 0.0, 0.0, 1.0);
	}
	
	float distanceFromCircle = circle.radius - d;
	float intencity = smoothstep(
								    0.0, 1.0, 
								    clamp(
									    remap(distanceFromCircle, 0.0, 0.1, 0.0, 1.0),
									    0.0,
									    1.0
								    )
								);
	return vec4(intencity, intencity, intencity, 1.0);
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
	
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	float wide = iResolution.x / iResolution.y;
	float high = 1.0;
	
	vec2 position = vec2(uv.x * wide, uv.y);
	
	Circle circle_a = Circle(vec2(0.5, 0.5), 0.5);
	Circle circle_b = Circle(vec2(wide - 0.5, 0.5), 0.5);
	vec4 mask_a = circle_mask_color(circle_a, position);
	vec4 mask_b = circle_mask_color(circle_b, position);
	vec4 mask = mask_blend(mask_a, mask_b);
	
	float greenness = 0.4;
	vec4 coloring = vec4(1.0 - greenness, 1.0, 1.0 - greenness, 1.0);
	
	float noise = rand(uv * vec2(0.1, 1.0), iTime * 5.0);
	float noiseColor = 1.0 - (1.0 - noise) * 0.3;
	vec4 noising = vec4(noiseColor, noiseColor, noiseColor, 1.0);
	
	float warpLine = fract(-iTime * 0.5);
	
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
	if(abs(uv.y - fract(-iTime * 19.0)) < 0.0005)
	{
		lineNoise = vec4(0.5, 0.5, 0.5, 1.0);
	}
	
	vec4 base = texture(iChannel0, uv + vec2(offset * 0.02, 0.0));
	fragColor = base * mask * coloring * noising * lineNoise;

}
```

**Godot Shader**

```glsl
// For Godot we have to specify the shader type. Since this shader goes on a ColorRect node, it's 2D and all 2D shaders are of type `canvas_item`.
shader_type canvas_item;

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

// `mainImage` is always `fragment` in Godot and it takes no arguments.
void fragment()
{
    // Shadertoy has an `iResolution` global variable but we don't have access to that in Godot. The Godot docs recommend either using the following definition below or passing it in manually.
	vec2 iResolution = (1.0 / SCREEN_PIXEL_SIZE);
	
    // `fragCoord` is `FRAGCOORD` in Godot.
	vec2 uv = FRAGCOORD.xy / iResolution.xy;
	
	float wide = iResolution.x / iResolution.y;
	float high = 1.0;
	
	vec2 position = vec2(uv.x * wide, uv.y);
	
	float greenness = 0.4;
	vec4 coloring = vec4(1.0 - greenness, 1.0, 1.0 - greenness, 1.0);
	
    // Instead of `iTime` we use the global `TIME`.
	float noise = rand(uv * vec2(0.1, 1.0), TIME * 5.0);
	float noiseColor = 1.0 - (1.0 - noise) * 0.3;
	vec4 noising = vec4(noiseColor, noiseColor, noiseColor, 1.0);
	
	float warpLine = fract(-TIME * 0.5);
	
	float warpLen = 0.1;
	float warpArg01 = remap(clamp((position.y - warpLine) - warpLen * 0.5, 0.0, warpLen), 0.0, warpLen, 0.0, 1.0);
	float offset = sin(warpArg01 * 10.0)  * f1(warpArg01);
	
	vec4 lineNoise = vec4(1.0, 1.0, 1.0, 1.0);
	if(abs(uv.y - fract(-TIME * 19.0)) < 0.0005)
	{
		lineNoise = vec4(0.5, 0.5, 0.5, 1.0);
	}
	
    // Instead of `iChannel0` we have `TEXTURE` and `SCREEN_TEXTURE` available to us and since we want this to be a screen shader we use `SCREEN_TEXTURE`.
	vec4 base = texture(SCREEN_TEXTURE, uv + vec2(offset * 0.02, 0.0));
	COLOR = base * coloring * noising * lineNoise;
}
```

As mentioned above in this port we had to scrap the two circles like looked like binoculars because structs don't yet exist in Godot. The rest is pretty much the same as the others where its just globals that are named differently.

An image of the effect can be seen below and a short gif of it can be found on Gyfcat [here](https://gfycat.com/afraidpleasedfanworms)
![Blur Line Night Vision](../../images/jul/shadertoy-to-godot-night-vision/night-vision-blur-line.png)

## Shader 4: Scanlines Night Vision

This shader differs from the one before it by offering a crisp night vision effect with horizontal lines going across the screen. The original code for this shader can be found on [Shadertoy](https://www.shadertoy.com/view/XlsGzs).

**Shadertoy Shader**

```glsl
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 color;
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float distanceFromCenter = length( uv - vec2(0.5,0.5) );
    
    float vignetteAmount;
    
    float lum;
    
    vignetteAmount = 1.0 - distanceFromCenter;
    vignetteAmount = smoothstep(0.1, 1.0, vignetteAmount);
    
    color = texture( iChannel0, uv);
    
    // luminance hack, responses to red channel most
    lum = dot(color.rgb, vec3( 0.85, 0.30, 0.10) );
    
    color.rgb = vec3(0.0, lum, 0.0);
    
    // scanlines
    color += 0.1*sin(uv.y*iResolution.y*2.0);
    
    // screen flicker
    color += 0.005 * sin(iTime*16.0);
    
    // vignetting
    color *=  vignetteAmount*1.0;
    
	fragColor = color;
}
```

**Godot Shader**

```glsl
// For Godot we have to specify the shader type. Since this shader goes on a ColorRect node, it's 2D and all 2D shaders are of type `canvas_item`.
shader_type canvas_item;

// `mainImage` is always `fragment` in Godot and it takes no arguments.
void fragment()
{
    // Shadertoy has an `iResolution` global variable but we don't have access to that in Godot. The Godot docs recommend either using the following definition below or passing it in manually.
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec4 color;
	
    // `fragCoord` is `FRAGCOORD` in Godot.
	vec2 uv = FRAGCOORD.xy / i_resolution.xy;
	
	float distanceFromCenter = length(uv - vec2(0.5,0.5));
	
	float vignetteAmount;
	float lum;
	
	vignetteAmount = 0.6;
	vignetteAmount = smoothstep(0.1, 1.0, vignetteAmount);
	
    // Instead of `iChannel0` we have `TEXTURE` and `SCREEN_TEXTURE` available to us and since we want this to be a screen shader we use `SCREEN_TEXTURE`.
	color = texture(SCREEN_TEXTURE, uv);
	
	// luminance hack, responses to red channel most
	lum = dot(color.rgb, vec3(0.85, 0.30, 0.10));
	
	color.rgb = vec3(0.0, lum, 0.0);
	
	// scanlines
	color += 0.1 * sin(uv.y * i_resolution.y * 2.0);
	
	// screen flicker
    // Instead of `iTime` we use the global `TIME`.
	color += 0.005 * sin(TIME * 16.0);
	
	// vignetting
	color *=  vignetteAmount * 1.0;
	
    // `fragColor` is `COLOR` in Godot.
	COLOR = color;
}
```

This one is pretty simple and nothing new to go over. Just like with the others we have the same shader type since they're all going to be on a 2D node and most of the changes are just different names which are nicely documented in the official Godot documentation.

An image of the effect can be seen below and a short gif of it can be found on Gyfcat [here](https://gfycat.com/shamefulhauntingjavalina)
![Scanlines Night Vision](../../images/jul/shadertoy-to-godot-night-vision/night-vision-scanlines.png)

## Shader 5: Pixelated Night Vision

This last shader is going to a slightly different effect and I have to admit it looks better on Shadertoy but I bet someone could use this as a base to create a nice pixelated night vision shader in Godot. The original code for this shader can be found on [Shadertoy](https://www.shadertoy.com/view/4sGXWh)
    
```glsl
// For Godot we have to specify the shader type. Since this shader goes on a ColorRect node, it's 2D and all 2D shaders are of type `canvas_item`.
shader_type canvas_item;

// In Shadertoy there's a global for frame number which we don't have access to in Godot so we pass that in from code.
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

// `mainImage` is always `fragment` in Godot and it takes no arguments.
void fragment()
{
    // Shadertoy has an `iResolution` global variable but we don't have access to that in Godot. The Godot docs recommend either using the following definition below or passing it in manually.
	vec2 i_resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec4 fc = FRAGCOORD;
	float shift = 2.0;
	float size = 5.0;
	
	// Filtered
	// RGB Split and Pixelate
    // Instead of `iChannel0` we have `TEXTURE` and `SCREEN_TEXTURE` available to us and since we want this to be a screen shader we use `SCREEN_TEXTURE`.
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
    // `fragColor` is `COLOR` in Godot.
	COLOR = output_color;
}
```

This shader is a bit different as it wants to be passed the frame number the game is on to create a seed from it. I'm sure you could bypass this by just passing in `TIME` instead but I wanted to preserve the original code as much as possible while porting it over to be used as a shader in Godot.

An image of the effect can be seen below and a short gif of it can be found on Gyfcat [here](https://gfycat.com/goodnaturedconfusedfirebelliedtoad)
![Pixelated Night Vision](../../images/jul/shadertoy-to-godot-night-vision/night-vision-pixelated.png)

## Conclusion

I know that it has been mostly code but I hope that you see that porting over shaders from Shadertoy to Godot really isn't very difficult and even easier with the official documentation on it [here](https://docs.godotengine.org/en/stable/tutorials/shading/migrating_to_godot_shader_language.html).
