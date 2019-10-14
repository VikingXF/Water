Shader "Ocean Toolkit/Ocean Shader"
{
    Properties
    {
        ot_NormalMap0 ("Normal Map 0", 2D) = "blue" {}
        ot_NormalMap1 ("Normal Map 1", 2D) = "blue" {}
        ot_FoamMap ("Foam Map", 2D) = "white" {}

        ot_AbsorptionCoeffs ("Absorption Coeffs", Vector) = (3.0, 20.0, 50.0, 1.0)
        ot_DetailFalloffStart ("Detail Falloff Start", float) = 60.0
        ot_DetailFalloffDistance ("Detail Falloff Distance", float) = 40.0
        ot_DetailFalloffNormalGoal ("Detail Falloff Normal Goal", float) = 0.2
        ot_AlphaFalloff ("Alpha Falloff", float) = 1.0
        ot_FoamFalloff ("Foam Falloff", float) = 2.0
        ot_FoamStrength ("Foam Strength", float) = 1.2
        ot_FoamAmbient ("Foam Ambient", float) = 0.3
        ot_ReflStrength ("Reflection Strength", float) = 0.9
        ot_RefrStrength ("Refraction Strength", float) = 1.0
        ot_RefrColor ("Refraction Color", Color) = (1.0, 0.0, 0.0, 1.0)
        ot_RefrNormalOffset ("Refraction Normal Offset", float) = 0.05
        ot_RefrNormalOffsetRamp ("Refraction Normal Offset Ramp", float) = 2.0
        ot_FresnelPow ("Fresnel Pow", float) = 4.0
        ot_SunColor ("Sun Color", Color) = (1.0, 0.95, 0.6)
        ot_SunPow ("Sun Power", float) = 100.0
        ot_DeepWaterColorUnlit ("Deep Water Color", Color) = (0.045, 0.15, 0.3, 1.0)
        ot_DeepWaterAmbientBoost ("Deep Water Ambient Boost", float) = 0.3
        ot_DeepWaterIntensityZenith ("Deep Water Intensity Zenith", float) = 1.0
        ot_DeepWaterIntensityHorizon ("Deep Water Intensity Horizon", float) = 0.4
        ot_DeepWaterIntensityDark ("Deep Water Intensity Dark", float) = 0.1
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent+100"
            "ForceNoShadowCasting"="True"
            "IgnoreProjector"="True"
        }

        GrabPass { "_Refraction" }

        Pass
        {
            //ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #pragma shader_feature OT_REFL_OFF OT_REFL_SKY_ONLY OT_REFL_SSR
            #pragma shader_feature OT_REFR_OFF OT_REFR_COLOR OT_REFR_NORMAL_OFFSET
            #include "CommonOceanToolkit.cginc"

            // Currently set by script, not material
            uniform float3  ot_LightDir;
            uniform float3  ot_DeepWaterColor;

            uniform float4x4    ot_Proj;
            uniform float4x4    ot_InvView;
            uniform float3      ot_ViewCorner0;
            uniform float3      ot_ViewCorner1;
            uniform float3      ot_ViewCorner2;
            uniform float3      ot_ViewCorner3;

            // Currently set by material
            uniform sampler2D   _Refraction;
            uniform float4      _Refraction_TexelSize;

            uniform sampler2D ot_NormalMap0;
            uniform sampler2D ot_NormalMap1;
            uniform sampler2D ot_FoamMap;

            uniform float4 ot_NormalMap0_ST;
            uniform float4 ot_NormalMap1_ST;
            uniform float4 ot_FoamMap_ST;

            uniform float4  ot_AbsorptionCoeffs;
            uniform float   ot_DetailFalloffStart;
            uniform float   ot_DetailFalloffDistance;
            uniform float   ot_DetailFalloffNormalGoal;
            uniform float   ot_AlphaFalloff;
            uniform float   ot_FoamFalloff;
            uniform float   ot_FoamStrength;
            uniform float   ot_FoamAmbient;

            uniform float   ot_ReflStrength;
            uniform float   ot_RefrStrength;
            uniform float4  ot_RefrColor;
            uniform float   ot_RefrNormalOffset;
            uniform float   ot_RefrNormalOffsetRamp;
            uniform float   ot_FresnelPow;
            uniform float3  ot_SunColor;
            uniform float   ot_SunPow;
            uniform float3  ot_DeepWaterColorUnlit;
            uniform float   ot_DeepWaterAmbientBoost;
            uniform float   ot_DeepWaterIntensityZenith;
            uniform float   ot_DeepWaterIntensityHorizon;
            uniform float   ot_DeepWaterIntensityDark;

            struct VertOutput
            {
                float4 position : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };

            VertOutput vert(appdata_base input)
            {
                VertOutput output;

                float4 projCorner0 = mul(ot_Proj, float4(ot_ViewCorner0, 1.0));
                float4 projCorner1 = mul(ot_Proj, float4(ot_ViewCorner1, 1.0));
                float4 projCorner2 = mul(ot_Proj, float4(ot_ViewCorner2, 1.0));
                float4 projCorner3 = mul(ot_Proj, float4(ot_ViewCorner3, 1.0));

                float k0 = 1.0 / projCorner0.w;
                float k1 = 1.0 / projCorner1.w;
                float k2 = 1.0 / projCorner2.w;
                float k3 = 1.0 / projCorner3.w;

                float3 Qk0 = ot_ViewCorner0 * k0;
                float3 Qk1 = ot_ViewCorner1 * k1;
                float3 Qk2 = ot_ViewCorner2 * k2;
                float3 Qk3 = ot_ViewCorner3 * k3;

                float3 left = lerp(Qk0, Qk3, input.vertex.y);
                float3 right = lerp(Qk1, Qk2, input.vertex.y);
                float leftK = lerp(k0, k3, input.vertex.y);
                float rightK = lerp(k1, k2, input.vertex.y);
                float3 viewVertex = lerp(left, right, input.vertex.x) / lerp(leftK, rightK, input.vertex.x);
                float3 worldVertex = mul(ot_InvView, float4(viewVertex, 1.0)).xyz;

                // Use world vertex
                float height;
                float3 worldNormal;
                waveHeight(worldVertex, height, worldNormal);

                worldVertex.y = height;

                float4 projVertex = mul(UNITY_MATRIX_VP, float4(worldVertex, 1.0));

                output.position = projVertex;
                output.screenPos = ComputeScreenPos(projVertex);
                output.worldPos = worldVertex;
                output.worldNormal = worldNormal;

                return output;
            }

            inline float3 calcReflDir(float3 viewDir, float3 normal)
            {
                // We should re-normalize reflDir after the saturation, but
                // let's optimize for the common case and not do it
                float3 reflDir = reflect(viewDir, normal);
                reflDir.y = saturate(reflDir.y);
                return reflDir;
            }

            float4 frag(VertOutput input) : SV_Target
            {
                float screenZ = input.screenPos.w;

                // Get rough normal from wave function
                float3 normal = input.worldNormal;

                // Get fine normal from normal maps
                float2 normalUv0 = TRANSFORM_TEX(input.worldPos.xz, ot_NormalMap0);
                float3 fineNormal0 = UnpackNormal(tex2D(ot_NormalMap0, normalUv0)).xzy;
                float2 normalUv1 = TRANSFORM_TEX(input.worldPos.xz, ot_NormalMap1);
                float3 fineNormal1 = UnpackNormal(tex2D(ot_NormalMap1, normalUv1)).xzy;
                float3 fineNormal = fineNormal0 + fineNormal1;
                // DEBUG: return float4(fineNormal.xzy * 0.5 + 0.5, 1.0);

                // Fade normal towards the horizon
                float detailFalloff = saturate((screenZ - ot_DetailFalloffStart) / ot_DetailFalloffDistance);
                fineNormal = normalize(lerp(fineNormal, float3(0.0, 2.0, 0.0), saturate(detailFalloff - ot_DetailFalloffNormalGoal)));
                normal = normalize(lerp(normal, float3(0.0, 1.0, 0.0), detailFalloff));

                // Transform fine normal to world space
                float3 tangent = cross(normal, float3(0.0, 0.0, 1.0));
                float3 bitangent = cross(tangent, normal);
                normal = tangent * fineNormal.x + normal * fineNormal.y + bitangent * fineNormal.z;

                float3 viewDir = normalize(input.worldPos - _WorldSpaceCameraPos.xyz);
                float3 reflDir = calcReflDir(viewDir, normal);

                // ---
                // Sun
                // ---
                float3 sun = pow(saturate(dot(reflDir, ot_LightDir)), ot_SunPow) * ot_SunColor;

                // ----------
                // Reflection
                // ----------
                float3 refl = float3(0.0, 1.0, 1.0);

                #if defined(OT_REFL_SKY_ONLY)
                //refl = sampleSky(reflDir);
                #endif

                #if defined(OT_REFL_SSR)
                float2 hitCoord;
                float hitZ;

                if (raytrace2d(input.worldPos, reflDir, 50.0, UNITY_MATRIX_V, UNITY_MATRIX_P, 64.0, 4.0, 1.0, hitCoord, hitZ))
                {
                    #if defined(UNITY_UV_STARTS_AT_TOP)
                    if (_Refraction_TexelSize.y < 0.0 && _ProjectionParams.x >= 0.0)
                    {
                        hitCoord.y = 1.0 - hitCoord.y;
                    }
                    #endif

                    refl = tex2Dlod(_Refraction, float4(hitCoord, 0.0, 0.0)).xyz;
                    sun *= 0.0;
                }
                else
                {
                    refl = sampleSky(reflDir);
                }
                #endif

                // ----------
                // Refraction
                // ----------
                float3 refr = float3(0.0, 1.0, 1.0);

                float2 uv = input.screenPos.xy / input.screenPos.w;
                float depthBelowSurface = sampleDepth(uv) * _ProjectionParams.z - screenZ;
                float refrDepthBelowSurface = depthBelowSurface;

                #if defined(OT_REFR_COLOR)
                refr = ot_RefrColor.xyz;
                #endif

                #if defined(OT_REFR_NORMAL_OFFSET)
                // Sample refraction first using offset proportional to the center reference depth. This makes the
                // surface transition "inside" objects smooth.
                float2 refrUv = uv + normal.xz * ot_RefrNormalOffset * saturate(depthBelowSurface / ot_RefrNormalOffsetRamp);
                refrDepthBelowSurface = sampleDepth(refrUv) * _ProjectionParams.z - screenZ;

                // Now, sample refraction using offset proportional to the refracted depth. This makes the
                // surface transition "outside" objects smooth.
                refrUv = uv + normal.xz * ot_RefrNormalOffset * saturate(refrDepthBelowSurface / ot_RefrNormalOffsetRamp);
                refrDepthBelowSurface = sampleDepth(refrUv) * _ProjectionParams.z - screenZ;

                // This procedure removes artifacts close to the surface, the downside is that we
                // need to sample the depth twice for refraction.

                // Is the refracted sample on geometry above the surface?
                if (refrDepthBelowSurface < 0.0)
                {
                    refrUv = uv;
                    refrDepthBelowSurface = depthBelowSurface;
                }

                #if defined(UNITY_UV_STARTS_AT_TOP)
                if (_Refraction_TexelSize.y < 0.0 && _ProjectionParams.x >= 0.0)
                {
                    refrUv.y = 1.0 - refrUv.y;
                }
                #endif

                refr = tex2D(_Refraction, refrUv).xyz;
                #endif

                // Absorb light relative to depth
                float viewDotNormal = saturate(dot(-viewDir, normal));
                float3 deepWaterColor = ot_DeepWaterColor * (1.0 + pow(viewDotNormal, 2.0) * ot_DeepWaterAmbientBoost);

                refr = lerp(refr, deepWaterColor, saturate(refrDepthBelowSurface.xxx / ot_AbsorptionCoeffs.xyz));

                // ----
                // Foam
                // ----

                // Depth-based
                // Wave-tops, pre-computed depth in the future?
                float foamShade = saturate(ot_FoamAmbient + dot(normal, ot_LightDir));
                float foamMask = 1.0 - pow(saturate(refrDepthBelowSurface / ot_FoamFalloff), 4.0);
                float2 foamUv = TRANSFORM_TEX(input.worldPos.xz, ot_FoamMap);
                float foam = foamMask * ot_FoamStrength * foamShade * tex2D(ot_FoamMap, foamUv).w;

                // ------------------
                // Combine everything
                // ------------------
                float fresnel = 0.0;

                #if defined(OT_REFL_OFF)
                fresnel = 0.0;
                #else
                #if defined(OT_REFR_OFF)
                fresnel = 1.0;
                #else
                fresnel = pow(1.0 - viewDotNormal, ot_FresnelPow);
                #endif
                #endif

                float3 color = (1.0 - foam) * (fresnel * ot_ReflStrength * refl + (1.0 - fresnel) * ot_RefrStrength * refr + sun) + foam.xxx;
                float alpha = saturate(depthBelowSurface / ot_AlphaFalloff);
                return float4(color, alpha);
            }
            ENDCG
        }
    }

    CustomEditor "OceanToolkit.OceanShaderEditor"
}