Shader "Unlit/TriPlanarMatrix"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		LOD 100
	    Blend One One              //1st change here
		Cull Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex   vert
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

			sampler2D _MainTex;
			float4    _MainTex_ST;
			// -----------------------------------
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv     = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			sampler2D global_white_noise;
			sampler2D global_font_texture;
			uint      global_colored;
		    //---------------------------------------------------------
			
			float text(float2 coord)
			{
				float2 uv    = frac (coord.xy/ 16.);                // Geting the fract part of the block, this is the uv map for the blocl
				float2 block = floor(coord.xy/ 16.);                // Getting the id for the block. The first blocl is (0,0) to its right (1,0), and above it (0,1) 
				       uv    = uv * 0.7 + .1;                       // Zooming a bit in each block to have larger ltters
					  
                float2 rand  = tex2D(global_white_noise,            // This texture contains animated white noise. The white noise is animated in compute shaders
					           block.xy/float2(512.,512.)).xy;      // 512 is the white noise texture width. This division ensures that each block samples exactly one pixel of the noise texture
				
				       rand  = floor(rand*16.);                     // Each random value is used for the block to sample one of the 16 columns of the font texture. This rand offset is what picks the letter, the animated white noise is what changes it
				       uv   += rand;                                // The random texture has a different value und the xy channels. This ensures that randomly one member of the texture is picked 

					   uv   *= 0.0625;                              // So far the uv value is between 0-16. To sample the font texture we need to normalize this to 0-1. hence a divid by 16
					   uv.x  = -uv.x;
			    return tex2D(global_font_texture, uv).r;
			}

			//---------------------------------------------------------
#define dropLength 512
			float3 rain(float2 fragCoord)
			{
				fragCoord.x  = floor(fragCoord.x/ 16.);             // This is the exact replica of the calculation in text function for getting the cell ids. Here we want the id for the columns 

				float offset = sin (fragCoord.x*15.);               // Each drop of rain needs to start at a different point. The column id  plus a sin is used to generate a different offset for each columm
				float speed  = cos (fragCoord.x*3.)*.15 + .35;      // Same as above, but for speed. Since we dont want the columns travelling up, we are adding the 0.7. Since the cos *0.3 goes between -0.3 and 0.3 the 0.7 ensures that the speed goes between 0.4 mad 1.0. This is also control parameters for min and max speed
				float y      = frac((fragCoord.y / dropLength)      // This maps the screen again so that top is 1 and button is 0. The addition with time and frac would cause an entire bar moving from button to top
					                + _Time.y * speed + offset);    // the speed and offset would cause the columns to move down at different speeds. Which causes the rain drop effect

				return float3(.1, 1., .35) / (y*20.);               // adjusting the retun color based on the columns calculations. 
			}

           //---------------------------------------------------------

			uint _session_rand_seed; // required by the RandomLi Include
#include "RandomLib.cginc"
#include "LabColorspace.cginc"
			float3 rain_colored(float2 fragCoord)
			{
				fragCoord.x  = floor(fragCoord.x/ 16.);               // This is the exact replica of the calculation in text function for getting the cell ids. Here we want the id for the columns 

				float offset = rnd (fragCoord.x*521., 612);           // Each drop of rain needs to start at a different point. The column id  plus a sin is used to generate a different offset for each columm
				float speed  = rnd (fragCoord.x*612., 951)*.15 + .35; // Same as above, but for speed. Since we dont want the columns travelling up, we are adding the 0.7. Since the cos *0.3 goes between -0.3 and 0.3 the 0.7 ensures that the speed goes between 0.4 mad 1.0. This is also control parameters for min and max speed
				      speed *= 0.4;
				float y      = frac((fragCoord.y / dropLength)        // This maps the screen again so that top is 1 and button is 0. The addition with time and frac would cause an entire bar moving from button to top
					                + _Time.y * speed + offset);      // the speed and offset would cause the columns to move down at different speeds. Which causes the rain drop effect
				

				int    randomSeed = (fragCoord.x +
					                floor((fragCoord.y / dropLength) + _Time.y * speed + offset))
									*51.;
				float3 col = float3(rnd(randomSeed, 21),
					                frac(rnd(randomSeed, 712)+0.8), 
					                frac(rnd(randomSeed, 61)+0.2));
				       col = lab2rgb(col);
				return col / (y*20.);                                 // adjusting the retun color based on the columns calculations. 
			}

			//---------------------------------------------------------
#define scale 4.6

			// -----------------------------------
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col      = float4(0.,0.,0.,1.);
			    float3 rain_col = rain(i.uv * float2(dropLength, dropLength)*scale);
				if(global_colored == 1)
				       rain_col = rain_colored(i.uv * float2(dropLength, dropLength)*scale);
				       col.xyz  = text(i.uv * float2(dropLength, dropLength)*scale)*rain_col;
				return col;
			}
			ENDCG
		}
	}
}
