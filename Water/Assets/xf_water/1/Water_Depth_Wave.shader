// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "QQ/Water_Depth_Wave" {  
    Properties {          
    _WaterColor("海水颜色",Color) = (0,.25,.4,1)  
    _FarColor("海面颜色",Color)=(.2,1,1,.3)  
    [NoScaleOffset]_BumpMap("法线贴图", 2D) = "white" {}  
    _BumpPower("法线强度",Range(-1,1))=.6  
    _EdgeColor("边缘颜色",Color)=(0,1,1,0)  
    [NoScaleOffset]_WaveTex("海浪贴图",2D)="white" {}  
    _WaveSpeed("海浪速度",Range(0,10))=4  
    [NoScaleOffset]_EdgeTex("边缘贴图",2D)="white" {}  
    _EdgeRange("边缘融合",Range(0.1,1))=.4  
    _WaveSize("贴图尺寸",Range(0.01,1))=.25  
    _WaveOffset("xy,zw为偏移",vector)=(.1,.2,-.2,-.1)  
    _LightColor("灯光颜色",Color)=(1,1,1,1)  
    _LightVector("xyz为灯光角度,w为衰减",vector)=(.5,.5,.5,100)  
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
            #pragma multi_compile DEPTH_OFF DEPTH_ON  
            #pragma target 3.0  
            #include "UnityCG.cginc"  
  
        fixed4 _WaterColor;  
        fixed4 _FarColor;  
        fixed4 _LightColor;  
        sampler2D _BumpMap;  
        float _WaveSize;  
        float4 _WaveOffset;  
        float4 _LightVector;  
        float _BumpPower;  
        #ifdef DEPTH_ON  
        fixed4 _EdgeColor;  
        sampler2D _WaveTex;  
        float _WaveSpeed;  
        sampler2D _EdgeTex;  
        float _EdgeRange;  
        sampler2D_float _CameraDepthTexture;  
        #endif  
        struct a2v {  
            float4 vertex:POSITION;  
            half3 normal : NORMAL;  
        };  
        struct v2f  
        {  
            float4 pos : POSITION;  
            UNITY_FOG_COORDS(0)  
            half3 normal:TEXCOORD1;  
            float4 screenPos:TEXCOORD2;  
            fixed3 viewDir:TEXCOORD3;  
            fixed2 uv[2] : TEXCOORD4;  
        };  
        v2f vert(a2v v)  
        {  
            v2f o;  
            o.pos = UnityObjectToClipPos(v.vertex);  
            float4 wPos=mul(unity_ObjectToWorld,v.vertex);  
            o.uv[0]=wPos.xz*_WaveSize+_WaveOffset.xy*_Time.y;  
            o.uv[1]=wPos.xz*_WaveSize+_WaveOffset.zw*_Time.y;  
            o.normal=UnityObjectToWorldNormal(v.normal);  
            o.viewDir= WorldSpaceViewDir(v.vertex);  
            o.screenPos = ComputeScreenPos(o.pos);  
            COMPUTE_EYEDEPTH(o.screenPos.z);  
            return o;  
        }  
        fixed4 frag(v2f i):COLOR {  
            fixed4 col=_WaterColor;  
            half3 nor = UnpackNormal((tex2D(_BumpMap,i.uv[0])+tex2D(_BumpMap,i.uv[1]))*.5f);  
            nor= normalize(i.normal + nor.xzy *half3(1,0,1)* _BumpPower);  
            half spec =max(0,dot(nor,normalize(normalize(_LightVector.xyz)+normalize(i.viewDir))));  
            spec = pow(spec,_LightVector.w);  
            half fresnel=dot(nor,normalize(i.viewDir));  
            fresnel=saturate(dot(nor*fresnel,normalize(i.viewDir)));  
            #ifdef DEPTH_ON  
            half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));  
            depth=saturate((depth-i.screenPos.z)*_EdgeRange);  
            fixed4 edge = (tex2D(_EdgeTex,i.uv[0])+tex2D(_EdgeTex,i.uv[1]));  
            col =lerp(edge*_EdgeColor,col,depth);  
            float time=_Time.x*_WaveSpeed;  
            float wave=tex2D(_WaveTex,float2(time+depth,1)).a;  
            col+=_EdgeColor*saturate(saturate(wave)-depth)*edge.a;  
            #endif  
            col.rgb=lerp(col,_FarColor,_FarColor.a-fresnel);  
            col.rgb+=_LightColor.rgb*spec*_LightColor.a;  
            return col;  
        }  
        ENDCG  
    }  
    }  
    FallBack OFF  
}