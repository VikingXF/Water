// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Babybus/Water/sufacewater"
{
	Properties
	{
		
		_MainTex ("纹理贴图", 2D) = "white" {}
		_RampTex("过渡贴图", 2D) = "white" {}
		_WaterColor("深水颜色",Color) = (0,.25,.4,1)//深水颜色
		_WaveOffset("WaveOffset(xy&zw)",vector)=(.1,.2,-.2,-.1)//波纹流动方向
		_shallowWater("浅水颜色",Color) = (0,.25,.4,1)//浅水颜色
		_EdgeRange("边缘范围",Range(0.1,10))=.4//边缘混合范围
		_Range ("Range", float) = 0.3		
	}
	SubShader
	{
			Tags{ "Queue" = "AlphaTest-505" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				half4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				half4 screenPos:TEXCOORD2;
				half4 uv2: TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST,_RampTex_ST;
			sampler2D _RampTex;
			fixed4 _WaterColor,_shallowWater;
			half _EdgeRange;
			half4 _WaveOffset;	
			fixed _Range;
			
			sampler2D_float _CameraDepthTexture;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _MainTex)+ _WaveOffset.zw * _Time.y;
				o.uv2.xy = TRANSFORM_TEX(v.uv, _RampTex);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			//计算深度
				half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));  
				depth = saturate((depth-i.screenPos.z)*_EdgeRange);  
				depth = pow(depth,2);
			
			
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv.xy+ _WaveOffset.xy * _Time.y)*0.4+tex2D(_MainTex, i.uv.zw*0.7)*0.2;
				fixed4 col2 =tex2D(_RampTex, i.uv2.xy);
				col.rgb +=_WaterColor;
				col.rgb *=col2*1.5;
				half water_A = 1-min(_Range, depth)/_Range;
				col = lerp(water_A+_shallowWater,col,depth);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
