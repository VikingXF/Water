#ifdef GL_ES
	#ifdef SIMPLE
	precision mediump float;
	#else
	precision highp float;
	#endif
#else
#define highp
#define mediump
#define lowp
#endif

#ifndef SIMPLE
//#ifndef MEDIUM
#define LIGHTMAP
//#endif // MEDIUM
#define REFLECTION
#endif // SIMPLE
#ifdef FOAM
#ifndef SIMPLE
#define USE_FOAM
#endif // SIMPLE
#endif // FOAM

attribute vec4 a_pos;
attribute vec2 a_uv0;
attribute vec4 a_color;
// r = foam
// g = wave
// b = wind
// a = depth

varying vec4 v_wave;
varying highp vec2 v_bumpUv1;
#ifdef USE_FOAM
varying highp vec2 v_foamUv;
varying float v_foamPower;
#endif
varying vec3 v_darkColor;
varying vec3 v_lightColor;
varying float v_reflectionPower;

#ifdef LIGHTMAP
varying highp vec2 v_worldPos;
#endif

uniform   mat4 u_mvp;

uniform highp float u_time;
uniform mediump float u_1DivLevelWidth;
uniform mediump float u_1DivLevelHeight;
uniform mediump float WAVE_HEIGHT;
uniform mediump float WAVE_MOVEMENT;

uniform mediump vec3 SHORE_DARK;
uniform mediump vec3 SHORE_LIGHT;
uniform mediump vec3 SEA_DARK;
uniform mediump vec3 SEA_LIGHT;

uniform mediump vec3 u_lightPos;

//varying float v_testValue;

void main()
{
	vec4 pos = a_pos;
	
	// Calculate new vertex position with wave
	float animTime = a_uv0.y + u_time;
	
	//float scaleFactor = 1.0 - (cos(u_time * 0.2) * 0.5 + 0.5) * 0.1;
	//animTime += sin((a_pos.x + a_pos.y * sin((u_time + a_pos.x) * 0.01)) * 0.4 * scaleFactor + u_time * 0.2) * 0.5 + 0.5;

	highp float wave = cos(animTime);
	float waveHeightFactor = (wave + 1.0) * 0.5;
	pos.y += WAVE_MOVEMENT * waveHeightFactor * a_color.g * a_color.b;
	pos.z += wave * WAVE_HEIGHT * a_color.b;
	gl_Position = u_mvp * pos;
	
	// Water alpha
	float maxValue = 0.55;//0.5;
	v_wave.x = 1.0 - (a_color.a - maxValue) * (1.0 / maxValue);
	v_wave.x = v_wave.x * v_wave.x;
	v_wave.x = v_wave.x * 0.8 + 0.2;
	v_wave.x -= wave * a_color.b * 0.1;
	v_wave.x = min(1.0, v_wave.x);

	// UV coordinates
	vec2 texcoordMap = vec2(a_pos.x * u_1DivLevelWidth, a_pos.y * u_1DivLevelHeight) * 4.0;
	v_bumpUv1.xy = texcoordMap + vec2(0.0, u_time * 0.005) * 1.5;			// bump uv
#ifdef USE_FOAM
	v_foamUv = (texcoordMap + vec2(u_time * 0.005)) * 5.5;
#endif
	
	vec3 lightDir = normalize(vec3(-1.0, 1.0, 0.0));
	vec3 lightVec = normalize(u_lightPos - pos.xyz);
	v_wave.z = (1.0 - abs(dot(lightDir, lightVec)));
	v_wave.z = v_wave.z * 0.2 + (v_wave.z * v_wave.z) * 0.8;
	v_wave.z = clamp(v_wave.z + 1.1 - (length(u_lightPos - pos.xyz) * 0.008), 0.0, 1.0);
	v_wave.w = (1.0 + (1.0 - v_wave.z * 0.5) * 7.0);

#ifdef LIGHTMAP
	v_worldPos = vec2(pos.x * u_1DivLevelWidth, pos.y * u_1DivLevelHeight);
#endif

	// Blend factor for normal maps
    v_wave.y = (cos((a_pos.x + u_time) * a_pos.y * 0.003 + u_time) + 1.0) * 0.5;

	// Calculate colors
	float blendFactor = 1.0 - min(1.0, a_color.a * 1.6);
	
	float tx = a_pos.x * u_1DivLevelWidth - 0.5;
	float ty = a_pos.y * u_1DivLevelHeight - 0.5;
	
	float tmp = (tx * tx + ty * ty) / (0.75 * 0.75);
	float blendFactorMul = step(1.0, tmp);
	tmp = pow(tmp, 3.0);
	// Can't be above 1.0, so no clamp needed
	float blendFactor2 = max(blendFactor - (1.0 - tmp) * 0.5, 0.0);
	blendFactor = mix(blendFactor2, blendFactor, blendFactorMul);

	v_darkColor = mix(SHORE_DARK, SEA_DARK, blendFactor);
	v_lightColor = mix(SHORE_LIGHT, SEA_LIGHT, blendFactor);

	v_reflectionPower = ((1.0 - a_color.a) + blendFactor) * 0.5;//blendFactor;
	// Put to log2 here because there's pow(x,y)*z in the fragment shader calculated as exp2(log2(x) * y + log2(z)), where this is is the log2(z)
	v_reflectionPower = log2(v_reflectionPower);
}
