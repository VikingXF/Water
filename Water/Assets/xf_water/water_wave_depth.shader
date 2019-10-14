// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

/*


基于深度图以及法线贴图的海水Shader
根据深度在与其他物体的交界处逐渐透明，并产生冲击岸边的海浪
不能接收实时光
*/
Shader "Babybus/Water/water_wave_depth"
{

	Properties {		
    _WaterColor("WaterColor",Color) = (0,.25,.4,1)//海水颜色
    _FarColor("FarColor",Color)=(.2,1,1,.3)//反射颜色
    _BumpMap("BumpMap", 2D) = "white" {}//法线贴图
    _BumpPower("BumpPower",Range(-1,1))=.6//法线强度
    _EdgeColor("EdgeColor",Color)=(0,1,1,0)//海浪颜色
    _EdgeTex("EdgeTex",2D)="white" {}//海浪贴图
    _WaveTex("WaveTex",2D)="white" {}//海浪周期贴图
    _WaveSpeed("WaveSpeed",Range(0,10))=1//海浪速度
    _NoiseTex("Noise", 2D) = "white" {} //海浪躁波
    _NoiseRange ("NoiseRange", Range(0,10)) = 1//海浪躁波强度
    _EdgeRange("EdgeRange",Range(0.1,10))=.4//边缘混合强度
    _WaveSize("WaveSize",Range(0.01,1))=.25//波纹大小
    _WaveOffset("WaveOffset(xy&zw)",vector)=(.1,.2,-.2,-.1)//波纹流动方向
    _LightColor("LightColor",Color)=(1,1,1,1)//光源颜色
    _LightVector("LightVector(xyz for lightDir,w for power)",vector)=(.5,.5,.5,100)//光源方向
	}
		SubShader{
				Tags{ 
                "RenderType" = "Opaque" 
                "Queue" = "Transparent"
                }
				Blend SrcAlpha OneMinusSrcAlpha
				LOD 200
		Pass{
		    CGPROGRAM
	        #pragma vertex vert
	        #pragma fragment frag
	        #pragma multi_compile_fog
            #pragma multi_compile DEPTH_ON DEPTH_OFF
            #pragma target 3.0
            #include "UnityCG.cginc"
			#pragma target 2.0
        fixed4 _WaterColor;
        fixed4 _FarColor;

    	sampler2D _BumpMap;
    	half _BumpPower;

    	half _WaveSize;
        half4 _WaveOffset;

        #ifdef DEPTH_ON
        fixed4 _EdgeColor;
        sampler2D _EdgeTex , _WaveTex , _NoiseTex;
        half4 _NoiseTex_ST;

        half _WaveSpeed;
        half _NoiseRange;
        half _EdgeRange;

        sampler2D_float _CameraDepthTexture;
        #endif

        fixed4 _LightColor;
        half4 _LightVector;

		struct a2v {
			float4 vertex:POSITION;
			float4 texcoord:TEXCOORD1;
			half3 normal : NORMAL;
		};
		struct v2f
		{
			half4 pos : POSITION;
			half3 normal:TEXCOORD1;
            half4 screenPos:TEXCOORD2;
            half3 viewDir:TEXCOORD3;
            half4 uv : TEXCOORD4;
            half2 uv_noise : TEXCOORD5;
             UNITY_FOG_COORDS(6)
		};

		//unity没有取余的函数，自己写一个
		half2 fract(half2 val)
		{
			return val - floor(val);
		}

		v2f vert(a2v v)
		{
			v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
            float4 wPos = mul(unity_ObjectToWorld,v.vertex);
            o.uv.xy = wPos.xz * _WaveSize + _WaveOffset.xy * _Time.y;
            o.uv.zw = wPos.xz * _WaveSize + _WaveOffset.zw * _Time.y;
            o.uv_noise = TRANSFORM_TEX (v.texcoord , _NoiseTex);
            o.normal = UnityObjectToWorldNormal(v.normal);
            o.viewDir = WorldSpaceViewDir(v.vertex);
            o.screenPos = ComputeScreenPos(o.pos);
            COMPUTE_EYEDEPTH(o.screenPos.z);
            UNITY_TRANSFER_FOG ( o , o.pos );
			return o;
		}


		fixed4 frag(v2f i):COLOR {

			//海水颜色
            fixed4 col=_WaterColor;

            //计算法线
            half3 nor = UnpackNormal((tex2D(_BumpMap,fract(i.uv.xy)) + tex2D(_BumpMap,fract(i.uv.zw * 1.2)))*0.5);  
            nor= normalize(i.normal + nor.xyz *half3(1,1,0)* _BumpPower);  

           	//计算高光
            half spec =max(0,dot(nor,normalize(normalize(_LightVector.xyz)+normalize(i.viewDir))));  
            spec = pow(spec,_LightVector.w); 

            //计算菲涅耳反射
            half fresnel=1-saturate(dot(nor,normalize(i.viewDir))); 
            col=lerp(col,_FarColor,fresnel); 

            //计算海水边缘以及海浪
            #ifdef DEPTH_ON  
            half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));  
            depth = saturate((depth-i.screenPos.z)*_EdgeRange);  
			//depth = pow(depth,0.5);
			fixed noise = tex2D(_NoiseTex,i.uv_noise).r;
           	fixed wave=tex2D(_WaveTex,fract(half2(_Time.y*_WaveSpeed+ depth + noise * _NoiseRange,0.5))).r;
            fixed edge = saturate((tex2D(_EdgeTex,i.uv.xy*5).r+tex2D(_EdgeTex,i.uv.zw *2).r)*0.5) * wave;
            col.rgb +=_EdgeColor * edge *(1-depth);  
            col.a = lerp(0,col.a,depth);
            #endif  

            col.rgb+= _LightColor*spec;  
            UNITY_APPLY_FOG(i.fogCoord, col);
            return col;  
}
		ENDCG
	}
	}
	FallBack OFF
}