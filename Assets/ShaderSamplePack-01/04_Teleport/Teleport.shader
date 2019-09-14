Shader "ShaderSamplePack-01/Teleport"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseStrength ("Noise Strength", float) = 0.2
        [HDR] _HaloColor ("Halo Color", Color) = (0,0,1,1)
        _HaloStrength ("Halo Strength", float) = 0.1
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Clip ("Clip", float) = 1
        [Toggle(REVERSE_DIRECTION)]
        _ReverseDirection ("Reverse Direction", float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque"}

        CGPROGRAM
        #pragma surface surf Standard addshadow finalcolor:teleportColor
        #pragma target 3.0
        #pragma shader_feature REVERSE_DIRECTION

        sampler2D _MainTex;
        sampler2D _NoiseTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _Clip;
        fixed _NoiseStrength;
        fixed4 _HaloColor;
        fixed _HaloStrength;

        float teleportClipping(float3 worldPos, float2 uv)
        {
            float k = worldPos.y - _Clip;
            float noise = tex2D(_NoiseTex, uv).r;
            k += noise * _NoiseStrength;
            float s = step(abs(k), _HaloStrength);
            k = max(k, 0);
         
        #ifdef REVERSE_DIRECTION
            clip(0 - k);
        #else
            clip(k - 0.01);
        #endif

            return s;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            teleportClipping(IN.worldPos, IN.uv_NoiseTex);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }

        void teleportColor (Input IN, SurfaceOutputStandard o, inout fixed4 color)
        {
            float c = teleportClipping(IN.worldPos, IN.uv_NoiseTex);
            float noise = tex2D(_NoiseTex, IN.uv_NoiseTex).r;
            fixed4 finalcolor = lerp(color, _HaloColor + noise, c);
            color = finalcolor;
        }
        ENDCG
    }

    FallBack "Diffuse"
}
