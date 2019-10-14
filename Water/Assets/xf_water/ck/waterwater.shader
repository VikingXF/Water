Shader "Unlit/waterwater"
{
	Properties
	{
		normal0 ("normal0", 2D) = "white" {}
		foam ("foam", 2D) = "white" {}
		lightmap ("lightmap", 2D) = "white" {}
		
		u_1DivLevelWidth("u_1DivLevelWidth",float)=1.0
		u_1DivLevelHeight("u_1DivLevelHeight",float)=1.0
		WAVE_HEIGHT("WAVE_HEIGHT",float)=1.0
		WAVE_MOVEMENT("WAVE_MOVEMENT",float)=1.0
		SHORE_DARK("SHORE_DARK",vector) = (1,1,1,1)
		SHORE_LIGHT("SHORE_LIGHT",vector) = (1,1,1,1)
		SEA_DARK("SEA_DARK",vector) = (1,1,1,1)
		SEA_LIGHT("SEA_LIGHT",vector) = (1,1,1,1)
		u_lightPos("u_lightPos",vector) = (1,1,1,1)
		u_mvp("u_mvp",vector) = (1,1,1,1)
		
		u_reflectionFactor("u_reflectionFactor",float)=1.0				
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 200
		
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
				float4 a_pos : POSITION;
				float2 a_uv0 : TEXCOORD0;
				float4 a_color : COLOR;
			};

			struct v2f
			{
				//float2 uv : TEXCOORD0;
				//UNITY_FOG_COORDS(1)
				//float4 vertex : SV_POSITION;
				
				float4 v_wave: TEXCOORD0;
				float2 v_bumpUv1: TEXCOORD1;
				float2 v_foamUv: TEXCOORD2;
				float  v_foamPower: TEXCOORD3;
				float3 v_darkColor: TEXCOORD4;
				float3 v_lightColor: TEXCOORD5;
				float  v_reflectionPower: TEXCOORD6;
				float2 v_worldPos: TEXCOORD7;
				
			};
			
			float4 u_mvp;
			float u_1DivLevelWidth;
			float u_1DivLevelHeight;
			float WAVE_HEIGHT;
			float WAVE_MOVEMENT;
			float3 SHORE_DARK;
			float3 SHORE_LIGHT;
			float3 SEA_DARK;
			float3 SEA_LIGHT;
			float3 u_lightPos;
			
			sampler2D normal0,foam,lightmap;
			float u_reflectionFactor;
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 pos = v.a_pos;
				// 用波计算新的顶点位置
				float animTime = v.a_uv0.y + _Time.x;
				//float scaleFactor = 1.0 - (cos(_Time.x * 0.2) * 0.5 + 0.5) * 0.1;
				//animTime += sin((v.a_pos.x + v.a_pos.y * sin((_Time.x + v.a_pos.x) * 0.01)) * 0.4 * scaleFactor + _Time.x * 0.2) * 0.5 + 0.5;
				float wave = cos(animTime);
				float waveHeightFactor = (wave + 1.0) * 0.5;
				pos.y += WAVE_MOVEMENT * waveHeightFactor * v.a_color.g * v.a_color.b;
				pos.z += wave * WAVE_HEIGHT * v.a_color.b;
				v.a_pos = u_mvp * pos;
				
				// Water alpha
				float maxValue = 0.55;//0.5;
				o.v_wave.x = 1.0 - (v.a_color.a - maxValue) * (1.0 / maxValue);
				o.v_wave.x = o.v_wave.x * o.v_wave.x;
				o.v_wave.x = o.v_wave.x * 0.8 + 0.2;
				o.v_wave.x -= wave * v.a_color.b * 0.1;
				o.v_wave.x = min(1.0, o.v_wave.x);
				
				// UV coordinates
				float2 texcoordMap = float2(v.a_pos.x * u_1DivLevelWidth, v.a_pos.y * u_1DivLevelHeight) * 4.0;
				o.v_bumpUv1.xy = texcoordMap + float2(0.0, _Time.x * 0.005) * 1.5;			// bump uv

				o.v_foamUv = (texcoordMap + float2(_Time.x * 0.005,0.0)) * 5.5;

	
				float3 lightDir = normalize(float3(-1.0, 1.0, 0.0));
				float3 lightVec = normalize(u_lightPos - pos.xyz);
				o.v_wave.z = (1.0 - abs(dot(lightDir, lightVec)));
				o.v_wave.z = o.v_wave.z * 0.2 + (o.v_wave.z * o.v_wave.z) * 0.8;
				o.v_wave.z = clamp(o.v_wave.z + 1.1 - (length(u_lightPos - pos.xyz) * 0.008), 0.0, 1.0);
				o.v_wave.w = (1.0 + (1.0 - o.v_wave.z * 0.5) * 7.0);


				o.v_worldPos = float2(pos.x * u_1DivLevelWidth, pos.y * u_1DivLevelHeight);


				// Blend factor for normal maps
				o.v_wave.y = (cos((v.a_pos.x + _Time.x) * v.a_pos.y * 0.003 + _Time.x) + 1.0) * 0.5;

				// Calculate colors
				float blendFactor = 1.0 - min(1.0, v.a_color.a * 1.6);
	
				float tx = v.a_pos.x * u_1DivLevelWidth - 0.5;
				float ty = v.a_pos.y * u_1DivLevelHeight - 0.5;
	
				float tmp = (tx * tx + ty * ty) / (0.75 * 0.75);
				float blendFactorMul = step(1.0, tmp);
				tmp = pow(tmp, 3.0);
				// Can't be above 1.0, so no clamp needed
				float blendFactor2 = max(blendFactor - (1.0 - tmp) * 0.5, 0.0);
				blendFactor = lerp(blendFactor2, blendFactor, blendFactorMul);

				o.v_darkColor = lerp(SHORE_DARK, SEA_DARK, blendFactor);
				o.v_lightColor = lerp(SHORE_LIGHT, SEA_LIGHT, blendFactor);

				o.v_reflectionPower = ((1.0 - v.a_color.a) + blendFactor) * 0.5;//blendFactor;
				// Put to log2 here because there's pow(x,y)*z in the fragment shader calculated as exp2(log2(x) * y + log2(z)), where this is is the log2(z)
				o.v_reflectionPower = log2(o.v_reflectionPower);
												
				//o.vertex = UnityObjectToClipPos(v.v.a_pos);
				//o.uv = TRANSFORM_TEX(v.a_uv0, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				//fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				
				float4 normalMapValue = tex2D(normal0, i.v_bumpUv1.xy);
				fixed4 col = float4(lerp(i.v_lightColor, i.v_darkColor, (normalMapValue.x * i.v_wave.y) + (normalMapValue.y * (1.0 - i.v_wave.y))), i.v_wave.x)	
				+ exp2(log2(((normalMapValue.z * i.v_wave.y) + (normalMapValue.w * (1.0 - i.v_wave.y))) * i.v_wave.z) * i.v_wave.w + i.v_reflectionPower) * u_reflectionFactor;		
				float3 lightmapValue = tex2D(lightmap, i.v_worldPos).rga * float3(tex2D(foam, i.v_foamUv).r * 1.5, 1.3, 1.0);
				col = lerp(col, float4(0.92, 0.92, 0.92, lightmapValue.x), min(0.92, lightmapValue.x)) * lightmapValue.yyyz;									
				return col;
			}
			ENDCG
		}
	}
}
