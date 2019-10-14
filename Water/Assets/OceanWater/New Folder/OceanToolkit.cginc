#ifndef OCEAN_TOOLKIT
#define OCEAN_TOOLKIT
#include "UnityCG.cginc"

uniform float ot_OceanPosition;

uniform float4 ot_WaveScales;

uniform float4 ot_WaveExponents;
uniform float4 ot_WaveOffsets;
uniform float4 ot_WaveDirection01;
uniform float4 ot_WaveDirection23;
uniform float4 ot_WaveConstants;
uniform float4 ot_WaveDerivativeConstants;

inline void waveHeight(float3 pos, out float height, out float3 normal)
{
    float4 locations = float4(dot(ot_WaveDirection01.xy, pos.xz), dot(ot_WaveDirection01.zw, pos.xz), dot(ot_WaveDirection23.xy, pos.xz), dot(ot_WaveDirection23.zw, pos.xz));
    float4 axesX = float4(ot_WaveDirection01.x, ot_WaveDirection01.z, ot_WaveDirection23.x, ot_WaveDirection23.z);
    float4 axesY = float4(ot_WaveDirection01.y, ot_WaveDirection01.w, ot_WaveDirection23.y, ot_WaveDirection23.w);
    
    float4 sine = sin((locations + ot_WaveOffsets) * ot_WaveConstants) * 0.5 + 0.5;

    float4 cosine = cos((locations + ot_WaveOffsets) * ot_WaveConstants);

    float sum = dot(ot_WaveScales, pow(sine, ot_WaveExponents));
    float tangentSum = dot(axesX * ot_WaveDerivativeConstants, pow(sine, ot_WaveExponents - 0.99) * cosine);
    float bitangentSum = dot(axesY * ot_WaveDerivativeConstants, pow(sine, ot_WaveExponents - 0.99) * cosine);

    float3 tangent = float3(1.0, tangentSum, 0.0);
    float3 bitangent = float3(0.0, bitangentSum, 1.0);

    height = ot_OceanPosition + sum;
    normal = normalize(cross(bitangent, tangent));
}

#endif