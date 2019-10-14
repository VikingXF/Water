Shader "Babybus/Water/fishing water"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_WaterColor("深水颜色",Color) = (0,.25,.4,1)//深水颜色
		_shallowWater("浅水颜色",Color) = (0,.25,.4,1)//浅水颜色
		_EdgeRange("边缘范围",Range(0.1,10))=.4//边缘混合范围
		_WaveOffset("WaveOffset(xy&zw)",vector)=(.1,.2,-.2,-.1)//波纹流动方向		
		_Range ("Range", float) = 0.3				
		_LightVector("过度方向(xyz for Dir,w for power)",vector)=(.5,.5,.5,100)//过度方向
		
		_LightDir("光源方向2(xyz for lightDir,w for power)",vector)=(.5,.5,.5,100)//光源方向
		
		_HighlightsTex ("HighlightsTex", 2D) = "white" {}
		_Specular ("Specular", float) = 1.86

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Geometry"}
		LOD 100
		//Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			#pragma target 3.0
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half3 normal : NORMAL;			
			};

			struct v2f
			{
				half4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				half3 viewDir:TEXCOORD2;
				half4 screenPos:TEXCOORD3;
				half3 normal : TEXCOORD4;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _WaterColor,_shallowWater;
			half _EdgeRange;
			half4 _WaveOffset;			
			sampler2D_float _CameraDepthTexture;

			fixed _Range;
			half4 _LightVector;	
			
			half _Specular;
			half4 _LightDir;
			sampler2D _HighlightsTex;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex)+ _WaveOffset.xy * _Time.y;
				o.uv.zw = TRANSFORM_TEX(v.uv, _MainTex)+_WaveOffset.zw * _Time.y;
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				//计算光照
				half3 norma = UnpackNormal(tex2D(_HighlightsTex,frac(i.uv.zw * 2)));  
				half3 halfVector = normalize(_LightDir + i.viewDir);
				float diffFactor = max(0, dot(_LightDir, norma)) * 0.8 + 0.2;
				float nh = max(0, dot(halfVector, norma));
				float spec = pow(nh, _Specular) * _LightDir.w;

				
				//计算过度
				half3 norm = normalize(tex2D(_MainTex,frac(i.uv.zw * 2))*half3(0,1,0));
				half Hig = max(0,dot(norm,normalize(normalize(_LightVector.xyz)+normalize(i.viewDir))));				
				Hig = pow(Hig,_LightVector.w); 
				
				//计算深度
				half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));  
				depth = saturate((depth-i.screenPos.z)*_EdgeRange);  
				//depth = pow(depth,2);
				
				
				fixed4 Texcol = tex2D(_MainTex, i.uv.xy);														
				half water_A = 1-min(_Range, depth)/_Range;										
				fixed4 col = lerp(water_A+_shallowWater,(Texcol*depth+_WaterColor),depth);							
				col.rgb += Hig+spec;
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
	
}
