Shader "Custom/NoiseDisplacement"
{
    Properties
    {
        _TimeFactor("Time", Range(0, 1)) = 0
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            uniform float _TimeFactor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                // Add displacement based on noise
                float3 noise = frac(sin(v.vertex.xyz * _Time * _TimeFactor) * 43758.5453123);
                o.vertex.xyz += noise * 0.1;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET
            {
                // Create the fire gradient
                fixed4 gradient = (1.0, 0.5, 0.1, 1.0) * (1.0 - frac(i.vertex.y * 0.1))
                                + (1.0, 0.0, 0.5, 1.0) * frac(i.vertex.y * 0.1);

                return gradient;
            }
            ENDCG
        }
    }
}
