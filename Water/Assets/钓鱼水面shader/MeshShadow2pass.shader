// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/MeshShadow2pass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {} 
		_ShadowDir ("ShadowDir", Vector) = (0,0,0,0) //阴影方向
		_ShadowCol("Shadow Color" , Color) = (0,0,0,0)//阴影颜色
		_ShadowFalloff("Shadow Falloff" , Range(0.01,1)) = 1//阴影衰减
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
		Pass
		{
			
			 Name "Shadow"
            Stencil
            {
                Ref 0
                Comp equal
                Pass incrWrap
                Fail keep
                ZFail keep
            }
			 //透明混合模式
            Blend SrcAlpha OneMinusSrcAlpha

            //关闭深度写入
            ZWrite off

            //深度稍微偏移防止阴影与自己穿插
            Offset 1 , 0
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;	
			};

			struct v2f
			{
				float4 color : COLOR;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _ShadowDir,_ShadowCol;
			float _ShadowFalloff;
			
			float3 ShadowProjectPos(in float4 vertDir)
			{
				float3 shadowPos;
				//得到顶点的世界空间坐标
				float3 wPos = mul(unity_ObjectToWorld,vertDir).xyz;	
				//阴影方向归一化
				float3 ShadowDir = normalize(_ShadowDir.xyz);
				//阴影的世界空间坐标
				shadowPos.y = _ShadowDir.w;
                shadowPos.xz = wPos.xz - ShadowDir.xz * (wPos.y/ShadowDir.y);
				//低于地面的部分不计算阴影
				shadowPos = lerp( shadowPos , wPos,step(wPos.y - _ShadowDir.w , 0));
                return shadowPos;
			}
			
			v2f vert (appdata v)
			{
				v2f o;
				//得到阴影的世界空间坐标
				float3 shadowPos = ShadowProjectPos(v.vertex);
				//转换到裁切空间
				o.vertex = UnityWorldToClipPos(shadowPos);
				 //得到中心点世界坐标
				float3 center =float3( unity_ObjectToWorld[0].w , _ShadowDir.w , unity_ObjectToWorld[2].w);
				//计算阴影衰减
				float falloff = saturate( 1-distance(shadowPos , center) * _ShadowFalloff);
				//阴影颜色
				
				o.color = _ShadowCol; 
				o.color.a = falloff;				
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{	
			
				UNITY_APPLY_FOG(i.fogCoord, i.color);			
				return i.color;
			}
			ENDCG
		}
	}
	fallback "Diffuse"
}
