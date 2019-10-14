Shader "Custom/Wave"
{
    Properties
    {
		_TintColor ("Tint Color", Color) = (1,1,1,1)
        _Tex ("Tex", 2D) = "white" {}
        _SpeedX ("SpeedX", Float) = 1.0
		_SpeedZ ("SpeedZ", Float) = 1.0
		_Wave("wave(XY波长ZW波高)",vector) = (1,1,1,1)

    }
    SubShader
    {
			Pass
			{
				Tags { "RenderType" = "Opaque" }

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD0;
                };

				fixed4 _TintColor;
                sampler2D _Tex;
                float4 _Tex_ST;
                float _SpeedX,_SpeedZ;

				float4 _Wave;
				v2f vert(appdata i)
				{
                    v2f o;
					
					i.vertex.y += sin(_Time.y * _SpeedX + i.vertex.x*_Wave.x) * _Wave.z;
					i.vertex.y += sin(_Time.y * _SpeedZ + i.vertex.z*_Wave.y) * _Wave.w;
                    o.vertex = UnityObjectToClipPos(i.vertex);
                    
                    o.uv = TRANSFORM_TEX(i.uv, _Tex);
                    return o;
				}

				fixed4 frag(v2f i) : SV_TARGET
				{
					return tex2D(_Tex, i.uv) * _TintColor;
				}

				ENDCG
			}
    }
	FallBack "Diffuse"
}
