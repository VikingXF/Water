Shader "Unlit/xf_SeaWave"
{
	Properties
	{
		_WaterTex ("WaterTex", 2D) = "white" {}
		_NoiseTex ("NoiseTex", 2D) = "white" {}
		_GTex("GTex", 2D) = "white" {}
		_WaveTex ("WaveTex", 2D) = "black" {} //浪花
		_WaveRange ("WaveRange", float) = 0.3 
		_NoiseRange ("NoiseRange", float) = 6.43
		_WaveDelta ("WaveDelta", float) = 2.43
		_WaveSpeed ("WaveSpeed", float) = -12.64 //浪花运动速度
		_WaterSpeed ("WaterSpeed", float) = 0.74  //水波速度
		_BumpTex ("BumpTex", 2D) = "bump" {}  //水的法线
		_Refract ("Refract", float) = 0.07 //折射强度或者法线强度
		_Range ("Range", vector) = (0.13, 1.53, 0.37, 0.78)
		_LightColor("LightColor",Color)=(1,1,1,1)//光源颜色
		_LightVector("LightVector(xyz for lightDir,w for power)",vector)=(.5,.5,.5,100)//光源方向
		
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
			#pragma multi_compile DEPTH_ON DEPTH_OFF
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv_WaterTex : TEXCOORD0;
				float2 uv_NoiseTex : TEXCOORD3;
				//UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				half4 screenPos:TEXCOORD2;
				half3 viewDir:TEXCOORD4;
				half3 normal:TEXCOORD5;
			};

			sampler2D _WaterTex,_BumpTex,_NoiseTex,_GTex,_WaveTex;
			sampler2D _GrabTexture;
			float4 _WaterTex_ST,_NoiseTex_ST;
			half _WaterSpeed;
			half _WaveRange;
			half _WaveSpeed;
			half _NoiseRange;
			half _WaveDelta;
			fixed _Refract;
			float4 _Range;
			
			fixed4 _LightColor;
			half4 _LightVector;
			
			float4 _WaterTex_TexelSize;
			
			sampler2D _CameraDepthTexture;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv_WaterTex = TRANSFORM_TEX(v.uv, _WaterTex);
				o.uv_NoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.screenPos = ComputeScreenPos(o.vertex);
				//COMPUTE_EYEDEPTH(o.screenPos.z);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{			
			fixed4 water = (tex2D(_WaterTex, i.uv_WaterTex + float2(_WaterSpeed*_Time.x,0))+tex2D(_WaterTex, float2(1-i.uv_WaterTex.y,i.uv_WaterTex.x) + float2(_WaterSpeed*_Time.x,0)))/2;
			float4 offsetColor = (tex2D(_BumpTex, i.uv_WaterTex + float2(_WaterSpeed*_Time.x,0))+tex2D(_BumpTex, float2(1-i.uv_WaterTex.y,i.uv_WaterTex.x) + float2(_WaterSpeed*_Time.x,0)))/2;
			half2 offset = UnpackNormal(offsetColor).xy * _Refract;
			
			//计算法线
            //half3 nor = UnpackNormal((tex2D(_BumpMap,fract(i.uv.xy)) + tex2D(_BumpMap,fract(i.uv.zw * 1.2)))*0.5);  
            //nor= normalize(i.normal + nor.xyz *half3(1,1,0)* _BumpPower);  

           	//计算高光
			half3 halfVector = normalize(_LightVector.xyz + i.viewDir);
			float diffFactor = max(0, dot(offset, i.normal)) * 0.8 + 0.2;			
			float spec = pow(diffFactor,_LightVector.w);
			 
			
			
			//计算深度
			half deltaDepth = LinearEyeDepth(tex2Dproj (_CameraDepthTexture, i.screenPos).r) - i.screenPos.z;
			
			fixed4 noiseColor = tex2D(_NoiseTex, i.uv_NoiseTex);
			
			float2 Grabuv = i.screenPos.xy/i.screenPos.w;
			half4 Transitionig = tex2D(_GrabTexture, Grabuv+offset);
			fixed4 waterColor = tex2D(_GTex, float2(min(_Range.y, deltaDepth)/_Range.y,1));
			
			fixed4 waveColor = tex2D(_WaveTex, float2(1-min(_Range.z, deltaDepth)/_Range.z+_WaveRange*sin(_Time.x*_WaveSpeed+noiseColor.r*_NoiseRange),1)+offset);
			waveColor.rgb *= (1-(sin(_Time.x*_WaveSpeed+noiseColor.r*_NoiseRange)+1)/2)*noiseColor.r;
			fixed4 waveColor2 = tex2D(_WaveTex, float2(1-min(_Range.z, deltaDepth)/_Range.z+_WaveRange*sin(_Time.x*_WaveSpeed+_WaveDelta+noiseColor.r*_NoiseRange),1)+offset);
			waveColor2.rgb *= (1-(sin(_Time.x*_WaveSpeed+_WaveDelta+noiseColor.r*_NoiseRange)+1)/2)*noiseColor.r;
			
			half water_A = 1-min(_Range.z, deltaDepth)/_Range.z;
			half water_B = min(_Range.w, deltaDepth)/_Range.w;
			float4 bumpColor = (tex2D(_BumpTex, i.uv_WaterTex+offset + float2(_WaterSpeed*_Time.x,0))+tex2D(_BumpTex, float2(1-i.uv_WaterTex.y,i.uv_WaterTex.x)+offset + float2(_WaterSpeed*_Time.x,0)))/2;

			//o.Normal = UnpackNormal(bumpColor).xyz;
			fixed4 col;
			col.rgb = Transitionig.rgb * (1 - water_B) + waterColor.rgb * water_B;
			col.rgb = col.rgb * (1 - water.a*water_A) + water.rgb * water.a*water_A;
			col.rgb += (waveColor.rgb+waveColor2.rgb) * water_A; 
			col.rgb += _LightColor*spec;  
			col.a = min(_Range.x, deltaDepth)/_Range.x;
				
		    // apply fog
			//UNITY_APPLY_FOG(i.fogCoord, col);
			return col;
			}
			ENDCG
		}
	}
}
