// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/FireShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseSpread ("Noise Spread", Range(0.01, 1.0)) = 0.1
        _FireColor ("Fire Color", Color) = (1.0, 0.5, 0.0)
        _TimeFactor ("Time Factor", Range(0.00001, 1.0)) = 0.1
        _Displacement ("Displacement", Range(0.01, 3.0)) = 0.01
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 200
        PASS
        {
        CGPROGRAM
        // #pragma surface surf Standard fullforwardshadows
        #include "UnityCG.cginc"
        #pragma vertex vert
        #pragma fragment frag

        struct Input
        {
            float2 uv_MainTex: TEXCOORD0;
            float3 worldPos: POSITION;
            float3 worldNormal: NORMAL;
        };

        struct VertexOutput
        {
            float4 pos : SV_POSITION;
            float3 normal : NORMAL;
            float3 worldPos : TEXCOORD0;
            float2 uv : TEXCOORD1;
        };

        sampler2D _MainTex;

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed3 _FireColor;
        float _NoiseSpread;
        float _TimeFactor;
        float _Displacement;

        // Noise function
        float noise(float x)
        {
            return frac(sin(x) * 43758.5453);
        }

        // void surf(Input IN, inout SurfaceOutputStandard o)
        // {
        //     // Sample the texture at the interpolated UV coordinates
        //     fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
        //
        //     // Generate a fire-like color by using the world position and the fire color property
        //     float3 fireColor = _FireColor + (IN.worldPos.y * 0.1);
        //
        //     // Use the noise function to add some flickering
        //     float3 noisea = float3(noise(IN.worldPos.x + _Time * _TimeFactor),
        //                           noise(IN.worldPos.y + _Time * _TimeFactor),
        //                           noise(IN.worldPos.z + _Time * _TimeFactor));
        //     fireColor += noisea * _NoiseSpread;
        //
        //     // Combine the fire color with the texture color
        //     o.Albedo = c.rgb * fireColor;
        //     o.Metallic = _Metallic;
        //     o.Smoothness = _Glossiness;
        //     o.Alpha = c.a;
        // }

        // Vertex function
        VertexOutput vert(Input IN)
        {
            VertexOutput o;
            
            // Sample the noise function at the world position
            float3 noisea = float3(noise(IN.worldPos.x + _Time * _TimeFactor),
                                   noise(IN.worldPos.y + _Time * _TimeFactor),
                                   noise(IN.worldPos.z + _Time * _TimeFactor));
            // Displace the vertex position based on the noise value and the displacement factor
            o.pos = UnityObjectToClipPos(IN.worldPos + (noisea * _Displacement));

            // Calculate the world position and UV coordinates for the fragment function
            o.worldPos = mul(unity_ObjectToWorld, IN.worldPos);
            o.uv = IN.uv_MainTex;
            o.normal = mul(unity_ObjectToWorld, IN.worldNormal);
            return o;
        }

        // Fragment function
        fixed3 frag(VertexOutput i) : SV_Target
        {
            // Sample the texture at the world position and UV coordinates
            fixed4 c = tex2D(_MainTex, i.uv) * _Color;

            // Generate a fire-like color by using the world position and the fire color property
            float3 fireColor = _FireColor + (i.worldPos.y * 0.1);

            // Use the noise function to add some flickering
            float3 noisea = float3(noise(i.worldPos.x + _Time * _TimeFactor), noise(i.worldPos.y + _Time * _TimeFactor),
                                  noise(i.worldPos.z + _Time * _TimeFactor));
            fireColor += noisea * _NoiseSpread;

            // Combine the fire color with the texture color
            // o.Albedo = c.rgb * fireColor;
            // o.Metallic = _Metallic;
            // o.Smoothness = _Glossiness;
            // o.Alpha = c.a;
            return c.rgb * fireColor;
        }
        ENDCG
    }
}
}