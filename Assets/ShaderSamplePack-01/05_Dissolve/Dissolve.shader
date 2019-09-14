Shader "ShaderSamplePack-01/Dissolve"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [HDR] _DissolveColor ("Dissolve Color", Color) = (1,0,0,1)
        _DissolveTex ("Dissolve Texture", 2D) = "white" {}
        _DissolveRampTex ("Dissolve Ramp Texture", 2D) = "white" {}
        _DissolveWidth ("Dissolve Width", Range(0, 1.0)) = 0.01
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Threshold ("Threshold", Range(-1,1)) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" } 
        Cull Off

        CGPROGRAM
        #pragma surface surf Standard addshadow 
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _DissolveTex;
        sampler2D _DissolveRampTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_DissolveTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        fixed4 _DissolveColor;
        float _Threshold;
        float _DissolveWidth;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            fixed4 mask = tex2D (_DissolveTex, IN.uv_DissolveTex);
            float k = mask.r - _Threshold;
            clip(k);

            o.Albedo = c.rgb;

            if(k < _DissolveWidth)
            {
                o.Emission = tex2D(_DissolveRampTex, float2(k * (1 / _DissolveWidth), 0)) * _DissolveColor;
            }
            
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }

        ENDCG
    }

    Fallback "Diffuse"
}
