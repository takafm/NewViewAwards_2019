Shader "ShaderSamplePack-01/ColorGradient"
{
    Properties
    {
        _TopColor ("Top Color", Color) = (1,1,1,1)
        _BottomColor ("Bottom Color", Color) = (0,0,0,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Top ("Top", float) = 3
        _Bottom ("Bottom", float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _TopColor;
        fixed4 _BottomColor;
        fixed _Top;
        fixed _Bottom;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 topColor = tex2D (_MainTex, IN.uv_MainTex) * _TopColor;
            fixed4 bottomColor = tex2D (_MainTex, IN.uv_MainTex) * _BottomColor;
            float k = clamp((IN.worldPos.y - _Bottom) / (_Top - _Bottom), 0, 1);

            fixed4 color =  lerp(bottomColor, topColor, k);
            o.Albedo = color.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = color.a;
        }
        ENDCG
    }
    
    FallBack "Diffuse"
}
