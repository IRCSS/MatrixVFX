Shader "Unlit/ScreenSpaceMatrixEffect"
{
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
				float2 uv     : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			uint      _session_rand_seed;
			sampler2D _font_texture;
			
			// -----------------------------------

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv     = v.uv;

				return o;
			}

			// --------------------------------------------------

			// The below macro is used to get a random number which varies across different generations. 

            #define rnd(seed, constant)  wang_rnd(seed +triple32(_session_rand_seed) * constant) 

			uint triple32(uint x)
			{
				x ^= x >> 17;
				x *= 0xed5ad4bbU;
				x ^= x >> 11;
				x *= 0xac4c1b51U;
				x ^= x >> 15;
				x *= 0x31848babU;
				x ^= x >> 14;
				return x;
			}

			float wang_rnd(uint seed)
			{
				uint rndint = triple32(seed);
				return ((float)rndint) / float(0xFFFFFFFF);                                                       // 0xFFFFFFFF is max unsigned integer in hexa decimal
			}
			//---------------------------------------------------------
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_font_texture, i.uv);
			float rand = rnd(int(i.uv.x*1204. + 1024.*(i.uv.y*1024.)), 21);
			col.xyz = float3(rand, rand, rand);
				return col;
			}
			ENDCG
		}
	}
}
