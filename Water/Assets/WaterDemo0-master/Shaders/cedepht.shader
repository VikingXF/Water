// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/cedepht"
{
	Properties	
    {  
		_Color0("Water Color",Color) = (1,1,1,1)//水的颜色
        _Color1("Water Depth",Color) = (0,0,0,0)//水的深度的颜色
        _Alpha("Alpha",Range( 0,1))= 1//水面的正题透明度
        _ColorDepth("ColorDepth",Range( 0,1))= 0//水的深度
		
		_WaterTex ("WaterTex", 2D) = "white" {} //水贴图
		_NoiseTex ("NoiseTex", 2D) = "white" {}
		_GTex("GTex", 2D) = "white" {}
		_WaveTex ("WaveTex", 2D) = "black" {} //浪花
		_WaveRange ("WaveRange", float) = 0.3 
		_NoiseRange ("NoiseRange", float) = 6.43
		_WaveDelta ("WaveDelta", float) = 2.43
		_WaveSpeed ("WaveSpeed", float) = -12.64 //浪花运动速度
		_WaterSpeed ("WaterSpeed", float) = 0.74  //水波速度
		_WaterTex ("BumpTex", 2D) = "bump" {}  //水的法线
		_Refract ("Refract", float) = 0.07 //折射强度或者法线强度
		_Range ("Range", vector) = (0.13, 1.53, 0.37, 0.78)
		
		_LightColor("LightColor",Color)=(1,1,1,1)//光源颜色
		_LightVector("LightVector(xyz for lightDir,w for power)",vector)=(.5,.5,.5,100)//光源方向
		
    }
    SubShader
    {
        Tags {"Queue" = "Transparent"}

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha 
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct VertexOutput
            {
                float2 uv_WaterTex : TEXCOORD0;
				float2 uv_NoiseTex : TEXCOORD2;
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD1;
            };


            float4 _Color0;
            float4 _Color1;
            float _Alpha;//水的透明度
            float _ColorDepth;

            sampler2D _CameraDepthTexture;
            
			sampler2D _WaterTex,_NoiseTex,_GTex,_WaveTex;
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
			
            VertexOutput vert (appdata v)
            {
                VertexOutput o;
				o.uv_WaterTex = TRANSFORM_TEX(v.uv, _WaterTex);
				o.uv_NoiseTex = TRANSFORM_TEX(v.uv, _NoiseTex);
				
                o.pos = UnityObjectToClipPos(v.vertex);
                o.scrPos = ComputeScreenPos(o.pos);//将返回片段着色器的屏幕位置
                COMPUTE_EYEDEPTH(o.scrPos.z);//计算顶点摄像机空间的深度：距离裁剪平面的距离
                return o;
            }
            
            fixed4 frag (VertexOutput i) : COLOR
            {
                //计算当前像素深度
                float  depth= tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r;//UNITY_PROJ_COORD:深度值 [0,1]
                depth = LinearEyeDepth(depth);//深度根据相机的裁剪范围的值[0.3,1000],是将经过透视投影变换的深度值还原了
                depth -= i.scrPos.z;
				fixed4 noiseColor = tex2D(_NoiseTex, i.uv_NoiseTex);
				float4 WaterColor = (tex2D(_WaterTex, i.uv_WaterTex + float2(_WaterSpeed*_Time.x,0))+tex2D(_WaterTex, float2(1-i.uv_WaterTex.y,i.uv_WaterTex.x) + float2(_WaterSpeed*_Time.x,0)))/2*_Color0;				
				fixed4 GTexColor = tex2D(_GTex, float2(min(_Range.y, depth)/_Range.y,1));
				fixed4 waveColor = tex2D(_WaveTex, float2(1-min(_Range.z, depth)/_Range.z+_WaveRange*sin(_Time.x*_WaveSpeed+noiseColor.r*_NoiseRange),1));
				
				
                //计算水的透明度： 使用深度值
                float alpha = saturate( _Alpha*depth);

                //计算颜色深度：
                float colDepth = saturate(_ColorDepth*depth);
                colDepth = 1-colDepth;
                colDepth = lerp(colDepth, colDepth*colDepth*colDepth, 0.5);//调整深度，看个人喜好

                half3 col;
                col.rgb = lerp(WaterColor, waveColor, colDepth);

                return float4(col.rgb, alpha );  
            }
            ENDCG
        }
    }
}
