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

			uint      _screen_width;
			uint      _screen_height;

			sampler2D _white_noise;
			sampler2D _font_texture;
			// -----------------------------------

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv     = v.uv;

				return o;
			}

			//---------------------------------------------------------
			
			float text(float2 coord)
			{
				float2 uv    = frac (coord.xy/ 16.);                // Geting the fract part of the block, this is the uv map for the blocl
				float2 block = floor(coord.xy/ 16.);                // Getting the id for the block. The first blocl is (0,0) to its right (1,0), and above it (0,1) 
				       uv    = uv * 0.7 + .1;                       // Zooming a bit in each block to have larger ltters
					  
                float2 rand  = tex2D(_white_noise,                  // This texture contains animated white noise. The white noise is animated in compute shaders
					           block.xy/float2(512.,512.)).xy;      // 512 is the white noise texture width. This division ensures that each block samples exactly one pixel of the noise texture
				
				       rand  = floor(rand*16.);                     // Each random value is used for the block to sample one of the 16 columns of the font texture. This rand offset is what picks the letter, the animated white noise is what changes it
				       uv   += rand;                                // The random texture has a different value und the xy channels. This ensures that randomly one member of the texture is picked 

					   uv   *= 0.0625;                              // So far the uv value is between 0-16. To sample the font texture we need to normalize this to 0-1. hence a divid by 16
					   uv.x  = -uv.x;
			    return tex2D(_font_texture, uv).r;
			}
			//---------------------------------------------------------

			float3 rain(float2 fragCoord)
			{
				fragCoord.x  = floor(fragCoord.x/ 16.);             // This is the exact replica of the calculation in text function for getting the cell ids. Here we want the id for the columns 

				float offset = sin (fragCoord.x*15.);               // Each drop of rain needs to start at a different point. The column id  plus a sin is used to generate a different offset for each columm
				float speed  = cos (fragCoord.x*3.)*.15 + .35;      // Same as above, but for speed. Since we dont want the columns travelling up, we are adding the 0.7. Since the cos *0.3 goes between -0.3 and 0.3 the 0.7 ensures that the speed goes between 0.4 mad 1.0. This is also control parameters for min and max speed
				float y      = frac((fragCoord.y / _screen_height)  // This maps the screen again so that top is 1 and button is 0. The addition with time and frac would cause an entire bar moving from button to top
					                + _Time.y * speed + offset);    // the speed and offset would cause the columns to move down at different speeds. Which causes the rain drop effect

				return float3(.1, 1., .35) / (y*20.);               // adjusting the retun color based on the columns calculations. 
			}

			//---------------------------------------------------------
#define scale 0.6
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = float4(0.,0.,0.,1.);
			       col.xyz = text(i.uv * float2(_screen_width, _screen_height)*scale)*rain(i.uv * float2(_screen_width, _screen_height)*scale);
				return col;
			}
			ENDCG
		}
	}
}
