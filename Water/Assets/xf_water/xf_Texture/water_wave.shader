Shader "Babybus/Water/water_wave"
{
	Properties
	{
		_WaterColor("水颜色",Color) = (0,.25,.4,1)//水颜色
		
		_FarColor("反射颜色",Color)=(.2,1,1,.3)//反射颜色
		_BumpMap("法线贴图", 2D) = "white" {}//法线贴图
		_BumpPower("法线强度",Range(0,3))=.6//法线强度
		_WaveOffset("WaveOffset(xy&zw)",vector)=(.1,.2,-.2,-.1)//波纹流动方向
		
		_LightColor("光源颜色",Color)=(1,1,1,1)//光源颜色
		_LightVector("光源方向(xyz for lightDir,w for power)",vector)=(.5,.5,.5,100)//光源方向
		
		_WAVE_movement("WAVE_movement",Range(0,3))=.6
		_WAVE_height("WAVE_height",Range(0,1))=.6		
		
		_NoiseTex("浪躁波", 2D) = "white" {} //浪躁波
		_WaveTex("浪周期",2D)="white" {}//浪周期贴图
		_EdgeTex("浪贴图",2D)="white" {}//浪贴图
		_WaveSpeed("浪速度",Range(0,10))=1//浪速度		
		_EdgeColor("浪颜色",Color)=(0,1,1,0)//浪颜色
		_NoiseRange ("躁波强度", Range(0,10)) = 1//浪躁波强度
		_EdgeRange("边缘范围",Range(0.1,10))=.4//边缘混合范围
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue" = "Transparent" }
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile DEPTH_ON DEPTH_OFF
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD1;
				half3 normal : NORMAL;				
			};

			struct v2f
			{
				half4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				half3 viewDir:TEXCOORD2;
				half4 screenPos:TEXCOORD3;
				float4 vertex : SV_POSITION;
				half3 normal : TEXCOORD5;
				half2 uv_noise : TEXCOORD4;
				
			};

			fixed4 _WaterColor;
			fixed4 _FarColor;
			sampler2D _BumpMap;
			half4 _BumpMap_ST;
			half _BumpPower;
			
			half4 _WaveOffset;
			
			half4 _LightVector;								
			fixed4 _LightColor;						
			
			half _WAVE_movement,_WAVE_height;
			
			
			sampler2D_float _CameraDepthTexture;
			
			//浪花
			sampler2D _NoiseTex,_WaveTex,_EdgeTex;
			half4 _NoiseTex_ST;
			half _WaveSpeed;
			half _NoiseRange;
			half _EdgeRange;	
			fixed4 _EdgeColor;
			
			
			v2f vert (appdata v)
			{
				v2f o;
							
				//float4 wPos = mul(unity_ObjectToWorld,v.vertex);
				o.uv.xy = TRANSFORM_TEX (v.texcoord , _BumpMap)+ _WaveOffset.xy * _Time.y;
				o.uv.zw = TRANSFORM_TEX (v.texcoord , _BumpMap)+_WaveOffset.zw * _Time.y;				
				o.uv_noise = TRANSFORM_TEX (v.texcoord , _NoiseTex);
				fixed4 _NoiseTexV = tex2Dlod(_NoiseTex, float4(o.uv_noise,0,0));
				//用波计算新的顶点位置
				half animTime = o.uv.y + _Time.y;
				half wave = cos(animTime);
				half waveHeightFactor = (wave + 1.0) * 0.5;
				v.vertex.y += _WAVE_height * waveHeightFactor * _NoiseTexV.g * _NoiseTexV.b;
				v.vertex.y *= _WAVE_movement;
				//v.vertex.z += wave * _WAVE_height * _NoiseTexV.g;				
				o.vertex = UnityObjectToClipPos(v.vertex);			
				o.normal = UnityObjectToWorldNormal(v.normal);				
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.screenPos.z);
				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : COLOR
			{
				//水颜色
				fixed4 col=_WaterColor;
				
				//计算法线
				half3 nor = UnpackNormal((tex2D(_BumpMap,frac(i.uv.xy)) + tex2D(_BumpMap,frac(i.uv.zw * 1.2)))*0.5);  
				nor= normalize(i.normal + nor.xyz *half3(1,1,0)* _BumpPower);
				
				//计算高光
				half Highlights = max(0,dot(nor,normalize(normalize(_LightVector.xyz)+normalize(i.viewDir))));  
				Highlights = pow(Highlights,_LightVector.w); 
			
				//计算菲涅耳反射
				half fresnel=1-saturate(dot(nor,normalize(i.viewDir))); 
				//col.rgb = col.rgb +_RimColor * pow (fresnel, _RimPower); 
				col=lerp(col,_FarColor,fresnel); 							
			
				//计算水边缘以及浪花
				
				half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));  
				depth = saturate((depth-i.screenPos.z)*_EdgeRange);  
				depth = pow(depth,0.5);
				fixed noise = tex2D(_NoiseTex,i.uv_noise).r;
				fixed wave=tex2D(_WaveTex,frac(half2(_Time.y*_WaveSpeed+ depth + noise * _NoiseRange,0.5))).r;
				fixed edge = saturate((tex2D(_EdgeTex,i.uv.xy*5).r+tex2D(_EdgeTex,i.uv.zw *2).r)*0.5) * wave*10;
				col.rgb +=_EdgeColor * edge *(1-depth);  
				col.a = lerp(0,col.a,depth);			
				col.rgb += _LightColor*Highlights;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);				
				return col;
			}
			ENDCG
		}
	}
}
