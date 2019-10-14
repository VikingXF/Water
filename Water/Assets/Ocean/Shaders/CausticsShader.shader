// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ocean Toolkit/Caustics Shader"
{
    Properties
    {
        [HideInInspector] _MainTex ("Base", 2D) = "white" {}
        ot_Pattern0 ("Pattern 0", 2D) = "white" {}
        ot_Pattern1 ("Pattern 1", 2D) = "white" {}
        ot_Strength ("Strength", float) = 1.0
        ot_StartAtDepth ("Start At Depth", float) = 0.25
        ot_RampDepth ("Ramp Depth", float) = 1.0
    }

    SubShader
    {
        Pass
        {
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #include "CommonOceanToolkit.cginc"

            uniform sampler2D   _MainTex;
            uniform float4      _MainTex_TexelSize;

            uniform sampler2D   ot_Pattern0;
            uniform sampler2D   ot_Pattern1;
            uniform float4      ot_Pattern0_ST;
            uniform float4      ot_Pattern1_ST;

            uniform float ot_Strength;
            uniform float ot_StartAtDepth;
            uniform float ot_RampDepth;

            uniform float3      ot_ViewSpaceUpDir;
            uniform float       ot_ZenithScalar;
            uniform float4x4    ot_InvViewProj;

            struct VertexOutput
            {
                float4 position : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float4 worldFarPos : TEXCOORD1;
            };

            VertexOutput vert(appdata_base input)
            {
                VertexOutput output;

                float4 projVertex = UnityObjectToClipPos(input.vertex);
                float4 screenPos = ComputeScreenPos(projVertex);

                output.position = projVertex;
                output.screenPos = screenPos;
                output.worldFarPos = mul(ot_InvViewProj, float4((screenPos.xy / screenPos.w) * 2.0 - 1.0, 1.0, 1.0));
                output.worldFarPos /= output.worldFarPos.w;

                return output;
            }

            float4 frag(VertexOutput input) : SV_Target
            {
                float2 uv = input.screenPos.xy / input.screenPos.w;

                float depth;
                float3 normal;
                sampleDepthNormal(uv, depth, normal);

                float3 pos = _WorldSpaceCameraPos.xyz + (input.worldFarPos.xyz - _WorldSpaceCameraPos.xyz) * depth;
                
                float4 pattern0 = tex2D(ot_Pattern0, TRANSFORM_TEX(pos.xz, ot_Pattern0));
                float4 pattern1 = tex2D(ot_Pattern1, TRANSFORM_TEX(pos.xz, ot_Pattern1));
                float3 caustics = (pattern0.xyz * pattern0.w + pattern1.xyz * pattern1.w) * 0.5;

                float shade = saturate(0.2 + dot(normal, ot_ViewSpaceUpDir)) * ot_ZenithScalar;

                // The wave function should be used to calculate the depth but doing this for every pixel
                // is very slow, so we just assume height 0.
                float depthBelowSurface = ot_OceanPosition - pos.y - ot_StartAtDepth;

                caustics *= shade * saturate(depthBelowSurface / ot_RampDepth) * ot_Strength;

                #if defined(UNITY_UV_STARTS_AT_TOP)
                if (_MainTex_TexelSize.y < 0.0)
                {
                    uv.y = 1.0 - uv.y;
                }
                #endif

                float4 color = tex2D(_MainTex, uv);
                return float4(color.xyz + caustics, color.w);
            }
            ENDCG
        }
    }
}