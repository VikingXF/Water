#ifdef GL_ES
precision mediump float;
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

uniform lowp sampler2D normal0;
#ifdef USE_FOAM
	uniform lowp sampler2D foam;
#endif

varying vec4 v_wave;
varying highp vec2 v_bumpUv1;
#ifdef USE_FOAM
varying highp vec2 v_foamUv;
#endif
varying vec3 v_darkColor;
varying vec3 v_lightColor;
varying float v_reflectionPower;

uniform float u_reflectionFactor;

#ifdef LIGHTMAP
uniform lowp sampler2D lightmap;
varying vec2 v_worldPos;
#endif

void main()
{
    vec4 normalMapValue = texture2D(normal0, v_bumpUv1.xy);
    gl_FragColor = vec4(mix(v_lightColor, v_darkColor, (normalMapValue.x * v_wave.y) + (normalMapValue.y * (1.0 - v_wave.y))), v_wave.x)
	#ifdef REFLECTION
	+ exp2(log2(((normalMapValue.z * v_wave.y) + (normalMapValue.w * (1.0 - v_wave.y))) * v_wave.z) * v_wave.w + v_reflectionPower) * u_reflectionFactor;
	#else
	;
	#endif
	#ifdef USE_FOAM
	vec3 lightmapValue = texture2D(lightmap, v_worldPos).rga * vec3(texture2D(foam, v_foamUv).r * 1.5, 1.3, 1.0);
	gl_FragColor = mix(gl_FragColor, vec4(0.92, 0.92, 0.92, lightmapValue.x), min(0.92, lightmapValue.x)) * lightmapValue.yyyz;
	#endif
}
