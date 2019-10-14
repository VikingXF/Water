Shader "Ocean Toolkit/Ocean Shader0"
{
    Properties
    {
        ot_NormalMap0 ("Normal Map 0", 2D) = "blue" {}
        ot_NormalMap1 ("Normal Map 1", 2D) = "blue" {}
  
        ot_RefrColor ("Refraction Color", Color) = (1.0, 0.0, 0.0, 1.0)
       
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

        //GrabPass { "_Refraction" }

        Pass
        {
            //ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
          
            #include "OceanToolkit.cginc"

            // Currently set by script, not material
 

            uniform float4x4    ot_Proj;
            uniform float4x4    ot_InvView;
            uniform float3      ot_ViewCorner0;
            uniform float3      ot_ViewCorner1;
            uniform float3      ot_ViewCorner2;
            uniform float3      ot_ViewCorner3;

			uniform float4  ot_RefrColor;


			

            struct VertOutput
            {
                float4 position : SV_POSITION;

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


                return output;
            }


            float4 frag(VertOutput input) : SV_Target
            {
                
                float4 color = ot_RefrColor;
               
                return color;
            }
            ENDCG
        }
    }

    CustomEditor "OceanToolkit.OceanShaderEditor"
}