
/*
 _WaterMap贴图RGBA值说明：
 r = foam
 g = wave
 b = wind
 a = depth
*/

Shader "Unlit/xf_water"
{
	Properties
	{
		_WaterColor("WaterColor",Color) = (0,.25,.4,1)//水颜色
		_WaterMap("WaterMap", 2D) = "white" {}
		_lightmap("lightmap", 2D) = "white" {}
		_WAVE_movement("WAVE_movement",Range(0,1))=.6
		_WAVE_height("WAVE_height",Range(0,1))=.6
		_u_1DivLevelWidth("u_1DivLevelWidth",Range(0,1))=.6
		_u_1DivLevelHeight("u_1DivLevelHeight",Range(0,1))=.6
		_u_lightPos("u_lightPos",vector) = (1,1,1,1)
		_SHORE_DARK("SHORE_DARK",vector) = (1,1,1,1)
		_SHORE_LIGHT("SHORE_LIGHT",vector) = (1,1,1,1)
		_SEA_DARK("SEA_DARK",vector) = (1,1,1,1)
		_SEA_LIGHT("SEA_LIGHT",vector) = (1,1,1,1)
		_u_reflectionFactor("u_reflectionFactor",Range(0,1))=.6
		
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
				//UNITY_FOG_COORDS(1)
				float2 v_worldPos : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 v_wave : TEXCOORD2;
				float2 v_bumpUv1:TEXCOORD3;
				float2 v_foamUv : TEXCOORD4;
				float3 v_lightColor : TEXCOORD5;
				float3 v_darkColor : TEXCOORD6;
				
			};

			float4 _WaterColor;
			sampler2D _WaterMap,_lightmap;
			float4 _WaterMap_ST;
			float _WAVE_movement;
			float _WAVE_height;
			float _u_1DivLevelWidth;
			float _u_1DivLevelHeight;
			float4 v_wave;
			float4 _u_lightPos;
			float4 _SHORE_DARK;
			float4 _SHORE_LIGHT;
			float4 _SEA_DARK;
			float4 _SEA_LIGHT;
			float _u_reflectionFactor;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _WaterMap);
				fixed4 _Watercol = tex2D(_WaterMap, o.uv);
				//用波计算新的顶点位置
				float animTime = v.uv.y + _Time.y;
				float wave = cos(animTime);
				float waveHeightFactor = (wave + 1.0) * 0.5;
				v.vertex.y += _WAVE_movement * waveHeightFactor * _Watercol.g * _Watercol.b;
				v.vertex.z += wave * _WAVE_height * _Watercol.b;
				
				// Water alpha
				float maxValue = 0.55;//0.5;
				v_wave.x = 1.0 - (_Watercol.a - maxValue) * (1.0 / maxValue);
				v_wave.x = v_wave.x * v_wave.x;
				v_wave.x = v_wave.x * 0.8 + 0.2;
				v_wave.x -= wave * _Watercol.b * 0.1;
				v_wave.x = min(1.0, v_wave.x);
				
				// UV coordinates
				float2 texcoordMap = float2(v.vertex.x * _u_1DivLevelWidth, v.vertex.y * _u_1DivLevelHeight) * 4.0;
				float2 v_bumpUv1 = texcoordMap + float2(0.0, _Time.y * 0.005) * 1.5;
				
				float2 v_foamUv = (texcoordMap + float2(0.0,_Time.y * 0.005)) * 5.5;
	
	
				float3 lightDir = normalize(float3(-1.0, 1.0, 0.0));
				float3 lightVec = normalize(_u_lightPos - v.vertex.xyz);
				v_wave.z = (1.0 - abs(dot(lightDir, lightVec)));
				v_wave.z = v_wave.z * 0.2 + (v_wave.z * v_wave.z) * 0.8;
				v_wave.z = clamp(v_wave.z + 1.1 - (length(_u_lightPos - v.vertex.xyz) * 0.008), 0.0, 1.0);
				v_wave.w = (1.0 + (1.0 - v_wave.z * 0.5) * 7.0);
				
				float2 v_worldPos = mul(unity_ObjectToWorld,v.vertex).xy;
				v_worldPos = float2(v.vertex.x * _u_1DivLevelWidth, v.vertex.y * _u_1DivLevelHeight);
				
				// Blend factor for normal maps
				v_wave.y = (cos((v.vertex.x + _Time.y) * v.vertex.y * 0.003 + _Time.y) + 1.0) * 0.5;
				
				// Calculate colors
				float blendFactor = 1.0 - min(1.0, _Watercol.a * 1.6);
	
				float tx = v.vertex.x * _u_1DivLevelWidth - 0.5;
				float ty = v.vertex.y * _u_1DivLevelHeight - 0.5;
	
				float tmp = (tx * tx + ty * ty) / (0.75 * 0.75);
				float blendFactorMul = step(1.0, tmp);
				tmp = pow(tmp, 3.0);
				
				// Can't be above 1.0, so no clamp needed
				float blendFactor2 = max(blendFactor - (1.0 - tmp) * 0.5, 0.0);
				blendFactor = lerp(blendFactor2, blendFactor, blendFactorMul);

				float3 v_darkColor = lerp(_SHORE_DARK, _SEA_DARK, blendFactor);
				float3 v_lightColor = lerp(_SHORE_LIGHT, _SEA_LIGHT, blendFactor);

				float v_reflectionPower = ((1.0 - _Watercol.a) + blendFactor) * 0.5;
				
				v_reflectionPower = log2(v_reflectionPower);
				
				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//水颜色
				//fixed4 col=_WaterColor;
				
				fixed4 normalMapValue = tex2D(_WaterMap, i.v_bumpUv1.xy);
				float4 col = float4(lerp(i.v_lightColor, i.v_darkColor, (normalMapValue.x * i.v_wave.y) + (normalMapValue.y * (1.0 - i.v_wave.y))), i.v_wave.x)
				+ exp2(log2(((normalMapValue.z * i.v_wave.y) + (normalMapValue.w * (1.0 - i.v_wave.y))) * i.v_wave.z) * i.v_wave.w ) * _u_reflectionFactor;
				float3 lightmapValue = tex2D(_lightmap, i.v_worldPos).rga * float3(tex2D(_WaterMap, i.v_foamUv).r * 1.5, 1.3, 1.0);
				col = lerp(col, float4(0.92, 0.92, 0.92, lightmapValue.x), min(0.92, lightmapValue.x)) * lightmapValue.yyyz;
				
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
