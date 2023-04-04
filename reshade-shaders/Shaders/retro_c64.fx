//
// retro_c64.fx (C64 Visual Style Simulator for ReShade)
// https://github.com/coderand/reshade-retro
// Created by Dmitry Andreev - and'2023
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// Version 0.0.1
//

#include "ReShadeUI.fxh"

uniform float c64_low_clarity < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Low Edges";
	ui_min = 0.0; ui_max = 2.0;
> = 1.3;

uniform float c64_med_clarity < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Medium Edges";
	ui_min = 0.0; ui_max = 2.0;
> = 1.3;

uniform float c64_brighness < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Brighness";
	ui_min = 0.0; ui_max = 4.0;
> = 1.3;

uniform float c64_vibrance < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Vibrance";
	ui_min = 0.0; ui_max = 1.0;
> = 0.5;

uniform float c64_highlights < __UNIFORM_SLIDER_FLOAT1

	ui_label = "Highlights";
	ui_min = 0.0; ui_max = 2.0;
> = 1.0;

uniform float c64_shadows < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Shadows";
	ui_min = 0.0; ui_max = 1.0;
> = 0.3;

uniform float c64_saturation < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Saturation";
	ui_min = 0.0; ui_max = 2.0;
> = 1.0;

uniform float c64_incontrast < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Contrast";
	ui_min = 0.0; ui_max = 1.0;
> = 0.4;

uniform float3 c64_tone < __UNIFORM_COLOR_FLOAT3
	ui_label = "Tone";
> = float3(1, 0.87, 1);

uniform int c64_dither_type
<
	ui_type = "combo";
	ui_label = "Dither Type";
	ui_items = 
	"None\0"
	"Pattern 2x2\0"
	"Pattern 4x4\0";
> = 2;

uniform float c64_dither_amount < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Dither Amount";
	ui_min = 0.0; ui_max = 2.0;
> = 1.0;

uniform float c64_scanlines < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Display Scanlines";
	ui_min = 0.0; ui_max = 1.0;
> = 1.0;

uniform float c64_softness < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Display Softness";
	ui_min = 0.0; ui_max = 1.0;
> = 0.4;

uniform float c64_bloom < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Display Bloom";
	ui_min = 0.0; ui_max = 1.0;
> = 0.5;

uniform float c64_contrast < __UNIFORM_SLIDER_FLOAT1
	ui_label = "Display Contrast";
	ui_min = 0.0; ui_max = 1.0;
> = 0.9;

//uniform bool c64_scanlines
//<
//	ui_label = "Scanlines";
//> = 1;

#include "ReShade.fxh"

texture downTex < pooled = true; >
{
	Width = BUFFER_WIDTH / 4;
	Height = BUFFER_HEIGHT / 2;
	Format = RGBA8;
};

texture down2Tex < pooled = true; >
{
	Width = BUFFER_WIDTH / 16;
	Height = BUFFER_HEIGHT / 8;
	Format = RGBA8;
};

texture down3Tex < pooled = true; >
{
	Width = BUFFER_WIDTH / 64;
	Height = BUFFER_HEIGHT / 32;
	Format = RGBA8;
};

texture retroTex < pooled = true; >
{
	Width = BUFFER_WIDTH / 4;
	Height = BUFFER_HEIGHT / 2;
	Format = RGBA8;
};

sampler LinearBackSampler
{
	Texture = ReShade::BackBufferTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Linear; MinFilter = Linear; MagFilter = Linear;
};

sampler downSampler
{
	Texture = downTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = Point; MinFilter = Point; MagFilter = Point;
};

sampler downLinearSampler
{
	Texture = downTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = None; MinFilter = Linear; MagFilter = Linear;
};

sampler down2LinearSampler
{
	Texture = down2Tex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = None; MinFilter = Linear; MagFilter = Linear;
};

sampler down3LinearSampler
{
	Texture = down3Tex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = None; MinFilter = Linear; MagFilter = Linear;
};

sampler retroPointSampler
{
	Texture = retroTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = None; MinFilter = Point; MagFilter = Point;
};

sampler retroLinearSampler
{
	Texture = retroTex;
	AddressU = Clamp; AddressV = Clamp;
	MipFilter = None; MinFilter = Linear; MagFilter = Linear;
};


float3 DownsamplePS(float4 position : SV_Position, float2 tc : TEXCOORD) : SV_Target
{
	float3 color = (
		tex2D(LinearBackSampler, tc + float2(-1, 0) * BUFFER_PIXEL_SIZE).rgb +
		tex2D(LinearBackSampler, tc + float2(+1, 0) * BUFFER_PIXEL_SIZE).rgb +
		tex2D(LinearBackSampler, tc + float2(-1, 0.5) * BUFFER_PIXEL_SIZE).rgb +
		tex2D(LinearBackSampler, tc + float2(+1, 0.5) * BUFFER_PIXEL_SIZE).rgb
		) * 0.25;

	return color;
}

float3 xdown(sampler2D tex, float2 tc, float2 s)
{
	float3 c = 0;

	c += tex2D(tex, tc + s*float2(-2,-2)).rgb;
	c += tex2D(tex, tc + s*float2(-1,-2)).rgb;
	c += tex2D(tex, tc + s*float2( 0,-2)).rgb;
	c += tex2D(tex, tc + s*float2(+1,-2)).rgb;
	c += tex2D(tex, tc + s*float2(+2,-2)).rgb;

	c += tex2D(tex, tc + s*float2(-2,-1)).rgb;
	c += tex2D(tex, tc + s*float2(-1,-1)).rgb;
	c += tex2D(tex, tc + s*float2( 0,-1)).rgb;
	c += tex2D(tex, tc + s*float2(+1,-1)).rgb;
	c += tex2D(tex, tc + s*float2(+2,-1)).rgb;

	c += tex2D(tex, tc + s*float2(-2, 0)).rgb;
	c += tex2D(tex, tc + s*float2(-1, 0)).rgb;
	c += tex2D(tex, tc + s*float2( 0, 0)).rgb;
	c += tex2D(tex, tc + s*float2(+1, 0)).rgb;
	c += tex2D(tex, tc + s*float2(+2, 0)).rgb;

	c += tex2D(tex, tc + s*float2(-2, 1)).rgb;
	c += tex2D(tex, tc + s*float2(-1, 1)).rgb;
	c += tex2D(tex, tc + s*float2( 0, 1)).rgb;
	c += tex2D(tex, tc + s*float2(+1, 1)).rgb;
	c += tex2D(tex, tc + s*float2(+2, 1)).rgb;

	c += tex2D(tex, tc + s*float2(-2, 2)).rgb;
	c += tex2D(tex, tc + s*float2(-1, 2)).rgb;
	c += tex2D(tex, tc + s*float2( 0, 2)).rgb;
	c += tex2D(tex, tc + s*float2(+1, 2)).rgb;
	c += tex2D(tex, tc + s*float2(+2, 2)).rgb;

	c /= 25.0;

	return c;
}

float3 Downsample2PS(float4 position : SV_Position, float2 tc : TEXCOORD) : SV_Target
{
	float2 s = BUFFER_PIXEL_SIZE * float2(4, 2) * 1.6;
	float3 c = xdown(downLinearSampler, tc, s);
	return c;
}

float3 Downsample3PS(float4 position : SV_Position, float2 tc : TEXCOORD) : SV_Target
{
	float2 s = BUFFER_PIXEL_SIZE * float2(4, 2) * 1.3 * 5.0;
	float3 c = xdown(down2LinearSampler, tc, s);
	return c;
}


float3 RetroPS(float4 position : SV_Position, float2 tc : TEXCOORD) : SV_Target
{
	float3 clr = tex2D(downSampler, tc).rgb;

	float3 dwn = tex2D(down2LinearSampler, tc).rgb;
	float3 avg = tex2D(down3LinearSampler, tc).rgb;
	float3 oavg = avg;

	clr = (clr - dwn) * c64_med_clarity + dwn;
	clr = (clr - avg) * c64_low_clarity + avg;
	clr = saturate(clr);

	clr *= clr;
	avg *= avg;
	clr *= c64_brighness;
	clr = clr / (0.5 + avg + clr);
	clr = sqrt(clr);

	float lm = dot(clr, 1.0 / 3.0);
	clr = lerp(clr, lm, lm * 1.2 * c64_highlights);

	lm = saturate(dot(clr, 1.0 / 3.0));
	clr = lerp(clr, lerp(pow(clr, 0.5), clr, pow(lm, 0.25)), c64_shadows);

	clr = saturate(lerp(clr, (clr - dot(clr, 1.0/3.0)) * 1.5 * c64_saturation + dot(clr, 1.0/3.0), pow(1.0 - dot(clr, 1.0/3.0), 1.0)));

	//clr.g = pow(clr.g, 0.87);
	clr.r = pow(clr.r, c64_tone.r);
	clr.g = pow(clr.g, c64_tone.g);
	clr.b = pow(clr.b, c64_tone.b);

	const int colorCount = 16;
	float3 palette[16];
	palette[0]  = float3(255, 255, 255) / 255.0;
	palette[1]  = float3(  0,   0,   0) / 255.0;
	palette[2]  = float3(203, 126, 117) / 255.0;
	palette[3]  = float3(201, 212, 135) / 255.0;
	palette[4]  = float3(173, 173, 173) / 255.0;
	palette[5]  = float3(161, 104,  60) / 255.0;
	palette[6]  = float3(160,  87, 163) / 255.0;
	palette[7]  = float3(159,  78,  68) / 255.0;
	palette[8]  = float3(154, 226, 155) / 255.0;
	palette[9]  = float3(137, 137, 137) / 255.0;
	palette[10] = float3(136, 126, 203) / 255.0;
	palette[11] = float3(109,  84,  18) / 255.0;
	palette[12] = float3(106, 191, 198) / 255.0;
	palette[13] = float3( 98,  98,  98) / 255.0;
	palette[14] = float3( 92, 171,  94) / 255.0;
	palette[15] = float3( 80,  69, 155) / 255.0;

	float luma = dot(clr.rgb, float3(0.212656, 0.715158, 0.072186));
	float max_color = max(clr.r, max(clr.g, clr.b));
	float min_color = min(clr.r, min(clr.g, clr.b));
	float color_saturation = max_color - min_color;
	float coeffVibrance = c64_vibrance;

	clr = lerp(luma, clr, 1.0 + (coeffVibrance * (1.0 - (sign(coeffVibrance) * color_saturation))));
	clr = lerp(clr, smoothstep(0, 1, clr), c64_incontrast);

	//clr = floor(clr * 12.0 + 0.5) / 12.0;

	float gpos = 0;

	if (c64_dither_type == 1)
	{
		// 2x2 dither
		float2 gp = floor(frac((position.xy + 0.5) * 0.5) * 2.0);
		if (gp.x == 0 && gp.y == 0) gpos = 0;
		if (gp.x == 1 && gp.y == 1) gpos = 1;
		if (gp.x == 0 && gp.y == 1) gpos = 2;
		if (gp.x == 1 && gp.y == 0) gpos = 3;
		gpos /= 3.0;
	}
	else if (c64_dither_type == 2)
	{
		// 4x4 dither
		// 0 8 3 B
		// C 4 F 7
		// 2 A 1 9
		// E 6 D 5
		float2 gp = floor(frac((position.xy + 0.5) * 0.25) * 4.0);

		if (gp.x == 0 && gp.y == 0) gpos = 0;
		if (gp.x == 1 && gp.y == 0) gpos = 8;
		if (gp.x == 2 && gp.y == 0) gpos = 3;
		if (gp.x == 3 && gp.y == 0) gpos = 11;

		if (gp.x == 0 && gp.y == 1) gpos = 12;
		if (gp.x == 1 && gp.y == 1) gpos = 4;
		if (gp.x == 2 && gp.y == 1) gpos = 15;
		if (gp.x == 3 && gp.y == 1) gpos = 7;

		if (gp.x == 0 && gp.y == 2) gpos = 2;
		if (gp.x == 1 && gp.y == 2) gpos = 10;
		if (gp.x == 2 && gp.y == 2) gpos = 1;
		if (gp.x == 3 && gp.y == 2) gpos = 9;
	
		if (gp.x == 0 && gp.y == 3) gpos = 14;
		if (gp.x == 1 && gp.y == 3) gpos = 6;
		if (gp.x == 2 && gp.y == 3) gpos = 13;
		if (gp.x == 3 && gp.y == 3) gpos = 5;

		gpos /= 15.0;
	}

	//

	if (c64_dither_type != 0)
	{
		clr += (gpos + 0.4) * 0.15 * c64_dither_amount;
	}

	float3 min_clr = palette[0];
	float min_dist = 1e30;

	for (int i = 0; i < colorCount; i++)
	{
		float3 diff = clr * clr - palette[i] * palette[i];
		float dist = dot(diff, diff);

		if (dist <= min_dist)
		{
			min_dist = dist;
			min_clr = palette[i];
		}
	}

	clr = min_clr;

	return clr;
}


float3 MainPS(float4 pos : SV_Position, float2 tc : TEXCOORD) : SV_Target
{
	float3 retroPoint = tex2D(retroPointSampler, tc + 0*float2(0.5, 0.5) * BUFFER_PIXEL_SIZE).rgb;
	float3 retroLinear= tex2D(retroLinearSampler, tc + 0*float2(0.5, 0.5) * BUFFER_PIXEL_SIZE).rgb;

	float3 clr;

	clr = lerp(retroPoint, retroLinear, c64_softness);
	clr = clr * clr;

	// Apply scanlines

	float f = 0.5 + 0.5 * sin((pos.y + 0.0) * 3.1415);
	float f2= 0.5 + 0.5 * sin((pos.x + 0.0) * 3.1415 * 0.5);

	f = lerp(1.0, f, c64_scanlines);
	f2= lerp(1.0, f2, c64_scanlines);

	clr *= 0.4 + 0.6 * f;
	clr *= 0.95 + 0.05 * f2;

	clr += pow(tex2D(down2LinearSampler, tc).rgb, 2.0) * 0.1 * c64_bloom;
	clr += pow(tex2D(down3LinearSampler, tc).rgb, 2.0) * 0.4 * c64_bloom;
	clr = sqrt(clr);

	clr = lerp(clr, smoothstep(0, 1, clr), c64_contrast) * lerp(1.0, 1.33, c64_contrast);

	float luma = dot(clr.rgb, float3(0.33, 0.33, 0.33));
	clr = (clr - luma) * 0.8 + luma;

	//clr = tex2D(down2LinearSampler, tc).rgb;
	//clr = tex2D(down3LinearSampler, tc).rgb;
	//clr = retroPoint;

	return clr;
}

technique RetroC64
{
	pass DownsamplePass
	{
		VertexShader = PostProcessVS;
		PixelShader = DownsamplePS;
		RenderTarget = downTex;
	}

	pass DownsamplePass2
	{
		VertexShader = PostProcessVS;
		PixelShader = Downsample2PS;
		RenderTarget = down2Tex;
	}

	pass DownsamplePass3
	{
		VertexShader = PostProcessVS;
		PixelShader = Downsample3PS;
		RenderTarget = down3Tex;
	}

	pass RetroPass
	{
		VertexShader = PostProcessVS;
		PixelShader = RetroPS;
		RenderTarget = retroTex;
	}

	pass Main
	{
		VertexShader = PostProcessVS;
		PixelShader = MainPS;
	}
}
