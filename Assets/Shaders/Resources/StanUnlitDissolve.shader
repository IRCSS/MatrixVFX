Shader "Unlit/StanUnlitDissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            
            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };
            
            struct v2f
            {
                float2 uv        : TEXCOORD0;
                float4 vertex    : SV_POSITION;
                float3 worldPos  : TEXCOORD1;
                float4 screenPos : TEXCOORD2;
            };
            
            
            sampler2D _MainTex;
            float4    _MainTex_ST;
            
            float     _Global_Transition_value;
            float3    _Global_Effect_center;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex    = UnityObjectToClipPos(v.vertex);
                o.uv        = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos  = mul(unity_ObjectToWorld, v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                return o;
            }
#include "Transition.cginc"

             fixed4 frag (v2f i) : SV_Target
             {
                 // sample the texture
                 fixed4 col       = tex2D(_MainTex, i.uv);
                 float2 screenPos = i.screenPos.xy / i.screenPos.w;
                 if (split_from_midle(screenPos.x, _Global_Transition_value, 1.0f) == 1.0f) discard;
                 return col;
             }
             ENDCG
        }
    } Fallback "VertexLit"
}
