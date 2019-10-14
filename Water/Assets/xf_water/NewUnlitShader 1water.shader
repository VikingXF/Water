Shader "Unlit/NewUnlitShader 1water"
{
	Properties
	{
		_WaterMap ("Texture", 2D) = "white" {}
		_WAVE_movement("WAVE_movement",Range(0,1))=.6
		_WAVE_height("WAVE_height",Range(0,1))=.6
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _WaterMap;
			float4 _WaterMap_ST;
			float _WAVE_movement,_WAVE_height;
			v2f vert (appdata v)
			{
				v2f o;
				
				o.uv = TRANSFORM_TEX(v.uv, _WaterMap);
				fixed4 _Watercol = tex2Dlod(_WaterMap, float4(o.uv,0,0));
				//用波计算新的顶点位置
				float animTime = o.uv.y + _Time.x;
				float wave = cos(animTime);
				float waveHeightFactor = (wave + 1.0) * 0.5;
				v.vertex.y += _WAVE_movement * waveHeightFactor * _Watercol.g * _Watercol.b;
				v.vertex.z += wave * _WAVE_height * _Watercol.b;							
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_WaterMap, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
