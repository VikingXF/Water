#ifndef COMMON_OCEAN_TOOLKIT
#define COMMON_OCEAN_TOOLKIT
#include "UnityCG.cginc"
#include "UnityGlobalIllumination.cginc"

uniform sampler2D _CameraDepthNormalsTexture;

uniform float ot_OceanPosition;

uniform float4 ot_WaveScales;
uniform float4 ot_WaveLengths;
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
    // sine = 0.0; // To disable waves
    float4 cosine = cos((locations + ot_WaveOffsets) * ot_WaveConstants);

    float sum = dot(ot_WaveScales, pow(sine, ot_WaveExponents));
    float tangentSum = dot(axesX * ot_WaveDerivativeConstants, pow(sine, ot_WaveExponents - 0.99) * cosine);
    float bitangentSum = dot(axesY * ot_WaveDerivativeConstants, pow(sine, ot_WaveExponents - 0.99) * cosine);

    float3 tangent = float3(1.0, tangentSum, 0.0);
    float3 bitangent = float3(0.0, bitangentSum, 1.0);

    height = ot_OceanPosition + sum;
    normal = normalize(cross(bitangent, tangent));
}

// From UnityCG.cginc: "Linear01Depth - Z buffer to linear 0..1 depth (0 at eye, 1 at far plane)"
// "return Linear01Depth(tex2D(_CameraDepthTexture, uv).x);"

inline void sampleDepthNormal(float2 uv, out float depth, out float3 viewNormal)
{
    DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, viewNormal);
}

inline float sampleDepth(float2 uv)
{
    float depth;
    float3 viewNormal;
    DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, uv), depth, viewNormal);
    return depth;
}

inline float sampleDepthLOD(float4 uv)
{
    float depth;
    float3 viewNormal;
    DecodeDepthNormal(tex2Dlod(_CameraDepthNormalsTexture, uv), depth, viewNormal);
    return depth;
}

//inline float3 sampleSky(float3 dir)
//{
//    UnityGIInput data;
//    UNITY_INITIALIZE_OUTPUT(UnityGIInput, data); // data.worldPos = float3(0.0, 0.0, 0.0)
//    data.boxMin[0] = unity_SpecCube0_BoxMin;
//    data.boxMax[0] = unity_SpecCube0_BoxMax;
//    data.probePosition[0] = unity_SpecCube0_ProbePosition;
//    data.probeHDR[0] = unity_SpecCube0_HDR;
//    data.boxMin[1] = unity_SpecCube1_BoxMin;
//    data.boxMax[1] = unity_SpecCube1_BoxMax;
//    data.probePosition[1] = unity_SpecCube1_ProbePosition;
//    data.probeHDR[1] = unity_SpecCube1_HDR;

//    Unity_GlossyEnvironmentData g;
//    UNITY_INITIALIZE_OUTPUT(Unity_GlossyEnvironmentData, g); // g.roughness = 0.0
//    g.reflUVW = dir;

//    return UnityGI_IndirectSpecular(data, 1.0, float3(0.0, 0.0, 0.0), g);
//    //return Unity_GlossyEnvironment(UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, dir, -1.0);
//}

inline float distanceSquared(float2 a, float2 b)
{
    float2 delta = b - a;

    return dot(delta, delta);
}

// Heavily inspired by "Efficient GPU Screen-Space Ray Tracing" by Morgan McGuire and Michael Mara
bool raytrace2d(const float3 worldStart, const float3 worldDir, float worldDistance,
                const float4x4 view, float4x4 proj,
                const float samples, const float stride, const float zThickness,
                out float2 hitCoord, out float hitZ)
{
    // Set output
    hitCoord = float2(-1.0, -1.0);
    hitZ = -1.0;

    // Move to view-space
    float3 view0 = mul(view, float4(worldStart, 1.0)).xyz;
    float3 viewDir = normalize(mul(view, float4(worldDir, 0.0)).xyz);

    // Clip ray to near plane
    float viewNearPlane = -_ProjectionParams.y;
    float rayLength = view0.z + viewDir.z * worldDistance > viewNearPlane ? (viewNearPlane - view0.z) / viewDir.z : worldDistance;

    float3 view1 = view0 + viewDir * rayLength;

    // Move to NDC-space
    float4 ray0 = mul(proj, float4(view0, 1.0));
    float4 ray1 = mul(proj, float4(view1, 1.0));

    float k0 = 1.0 / ray0.w;
    float k1 = 1.0 / ray1.w;

    float3 Qk0 = view0 * k0;
    float3 Qk1 = view1 * k1;

    // Screen points
    float2 screen0 = ComputeScreenPos(ray0 * k0).xy;
    float2 screen1 = ComputeScreenPos(ray1 * k1).xy;

    if (distanceSquared(screen0, screen1) <= 0.001)
    {
        screen1 += float2(1.0, 1.0) / _ScreenParams.xy;
    }

    // How far do we need to step along the ray in order to move 1 pixel along the lowest slope?
    float2 absDelta = abs(screen1 - screen0);

    float stepOnePixel = absDelta.x > absDelta.y ? 1.0 / (absDelta.x * _ScreenParams.x) : 1.0 / (absDelta.y * _ScreenParams.y);
    float step = stepOnePixel * stride;

    // Calculate deltas
    float kStep = (k1 - k0) * step;
    float3 QkStep = (Qk1 - Qk0) * step;
    float2 PStep = (screen1 - screen0) * step;

    // When talking about Z from now on, positive values go into the screen
    float prevMaxRayZ = -view0.z; // (-view0.z equals ray0.w in perspective transform)

    float scalar = 0.0;
    float k = k0;
    float3 Qk = Qk0;
    float2 P = screen0;

    // Step along the ray and make sure that we don't use too many samples or walk too far
    for (float i = 0.0; i < samples && scalar <= 1.0; i++)
    {
        // Calculate Z at next half-pixel
        float3 Q = (Qk + QkStep * 0.5) / (k + kStep * 0.5);

        float minRayZ = prevMaxRayZ;
        float maxRayZ = -Q.z;
        prevMaxRayZ = maxRayZ;

        // Handle rays travelling towards the camera
        if (maxRayZ < minRayZ)
        {
            float t = minRayZ;
            minRayZ = maxRayZ;
            maxRayZ = t;
        }

        // Get Z-buffer depth at this pixel
        float depth = sampleDepthLOD(float4(P, 0.0, 0.0)) * _ProjectionParams.z; // multiply by far plane

        // Previous implementation just to be safe, the following worked well:
        // depth = LinearEyeDepth(tex2Dlod(_CameraDepthTexture, float4(P, 0.0, 0.0)).x);

        float minSampleZ = depth;
        float maxSampleZ = minSampleZ + zThickness;

        // Do we intersect geometry at this pixel?
        if (maxRayZ > minSampleZ && minRayZ < maxSampleZ)
        {
            hitCoord = P;
            hitZ = minSampleZ;
            break;
        }

        // Snap to next pixel
        scalar += step;
        k += kStep;
        Qk += QkStep;
        P += PStep;
    }

    return hitZ >= 0.0;
}

#endif