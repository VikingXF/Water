// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Shader created with Shader Forge v1.32 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.32;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:0,bdst:1,dpts:2,wrdp:True,dith:0,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:False,qofs:0,qpre:1,rntp:1,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False;n:type:ShaderForge.SFN_Final,id:3138,x:32719,y:32712,varname:node_3138,prsc:2|emission-2012-RGB,voffset-5500-OUT;n:type:ShaderForge.SFN_Tex2d,id:2012,x:31782,y:32595,ptovrint:False,ptlb:_Maintexture,ptin:__Maintexture,varname:__Maintexture,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,ntxv:0,isnm:False;n:type:ShaderForge.SFN_Time,id:8682,x:30683,y:33082,varname:node_8682,prsc:2;n:type:ShaderForge.SFN_Slider,id:4016,x:31439,y:33179,ptovrint:False,ptlb:_WAVE_movement,ptin:__WAVE_movement,varname:__WAVE_movement,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_Slider,id:7166,x:31503,y:33527,ptovrint:False,ptlb:_WAVE_height,ptin:__WAVE_height,varname:__WAVE_height,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0,max:1;n:type:ShaderForge.SFN_TexCoord,id:9794,x:30683,y:32921,varname:node_9794,prsc:2,uv:0;n:type:ShaderForge.SFN_Add,id:8160,x:30908,y:32969,varname:node_8160,prsc:2|A-9794-V,B-8682-T;n:type:ShaderForge.SFN_Cos,id:5611,x:31079,y:32969,varname:node_5611,prsc:2|IN-8160-OUT;n:type:ShaderForge.SFN_Add,id:6712,x:31283,y:32972,varname:node_6712,prsc:2|A-5611-OUT,B-9353-OUT;n:type:ShaderForge.SFN_Vector1,id:9353,x:31079,y:33156,varname:node_9353,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:7366,x:31466,y:32972,varname:node_7366,prsc:2|A-6712-OUT,B-9992-OUT;n:type:ShaderForge.SFN_Vector1,id:9992,x:31262,y:33121,varname:node_9992,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:7739,x:32069,y:32935,varname:node_7739,prsc:2|A-7366-OUT,B-4016-OUT,C-2012-G,D-2012-B;n:type:ShaderForge.SFN_Append,id:5500,x:32280,y:33092,varname:node_5500,prsc:2|A-6146-OUT,B-7739-OUT;n:type:ShaderForge.SFN_Multiply,id:6146,x:32011,y:33354,varname:node_6146,prsc:2|A-7166-OUT,B-5611-OUT,C-2012-B;n:type:ShaderForge.SFN_Color,id:8356,x:31360,y:32634,ptovrint:False,ptlb:node_8356,ptin:_node_8356,varname:_node_8356,prsc:2,glob:False,taghide:False,taghdr:True,tagprd:False,tagnsco:False,tagnrm:False,c1:0.5,c2:0.5,c3:0.5,c4:1;proporder:2012-4016-7166;pass:END;sub:END;*/

Shader "Shader Forge/shadercs" {
    Properties {
        __Maintexture ("_Maintexture", 2D) = "white" {}
        __WAVE_movement ("_WAVE_movement", Range(0, 1)) = 0
        __WAVE_height ("_WAVE_height", Range(0, 1)) = 0
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D __Maintexture; uniform float4 __Maintexture_ST;
            uniform float __WAVE_movement;
            uniform float __WAVE_height;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                float4 node_8682 = _Time + _TimeEditor;
                float node_5611 = cos((o.uv0.g+node_8682.g));
                float4 __Maintexture_var = tex2Dlod(__Maintexture,float4(TRANSFORM_TEX(o.uv0, __Maintexture),0.0,0));
                v.vertex.xyz += float3(float2((__WAVE_height*node_5611*__Maintexture_var.b),(((node_5611+1.0)*0.5)*__WAVE_movement*__Maintexture_var.g*__Maintexture_var.b)),0.0);
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
////// Emissive:
                float4 __Maintexture_var = tex2D(__Maintexture,TRANSFORM_TEX(i.uv0, __Maintexture));
                float3 emissive = __Maintexture_var.rgb;
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform float4 _TimeEditor;
            uniform sampler2D __Maintexture; uniform float4 __Maintexture_ST;
            uniform float __WAVE_movement;
            uniform float __WAVE_height;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
                float2 uv0 : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                float4 node_8682 = _Time + _TimeEditor;
                float node_5611 = cos((o.uv0.g+node_8682.g));
                float4 __Maintexture_var = tex2Dlod(__Maintexture,float4(TRANSFORM_TEX(o.uv0, __Maintexture),0.0,0));
                v.vertex.xyz += float3(float2((__WAVE_height*node_5611*__Maintexture_var.b),(((node_5611+1.0)*0.5)*__WAVE_movement*__Maintexture_var.g*__Maintexture_var.b)),0.0);
                o.pos = UnityObjectToClipPos(v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
