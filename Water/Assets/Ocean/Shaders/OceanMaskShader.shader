// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Ocean Toolkit/Ocean Mask Shader"
{
    SubShader
    {
    	Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent+90"
            "ForceNoShadowCasting"="True"
            "IgnoreProjector"="True"
        }

        Pass
        {
            ZWrite On
            ColorMask 0

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #include "CommonOceanToolkit.cginc"

            struct VertexOutput
            {
                float4 position : SV_POSITION;
            };

            VertexOutput vert(appdata_base input)
            {
                VertexOutput output;

                output.position = UnityObjectToClipPos(input.vertex);

                return output;
            }

            float4 frag(VertexOutput input) : SV_Target
            {
                return float4(1.0, 0.0, 0.0, 1.0);
            }
            ENDCG
        }
    }
}