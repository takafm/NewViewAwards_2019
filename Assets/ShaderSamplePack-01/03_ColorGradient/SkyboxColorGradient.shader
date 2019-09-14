Shader "ShaderSamplePack-01/Skybox/ColorGradient"
{
    Properties
    {
        _TopColor ("Top Color", Color) = (1, 0, 0, 1)
        _BottomColor ("Bottom Color", Color) = (0, 0, 1, 0)
        _Strength ("Strength", float) = 1
    }

    SubShader
    {
        Tags 
        {
            "RenderType"="Background"
            "Queue"="Background"
            "PreviewType"="Skybox"
        }
        
        Pass
        {
            ZWrite Off
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            fixed4 _TopColor;
            fixed4 _BottomColor;
            fixed _Strength;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Step1
                // half p = i.uv.y * 0.5 + 0.5;
                // fixed4 col = fixed4(lerp(_TopColor.rgb, _BottomColor.rgb, p), 1);

                // Step2
                // half p = i.uv.y;
                // float p1 = pow(min(1.0f, 1.0f - p), _Strength);
                // fixed4 col = fixed4(lerp(_TopColor.rgb, _BottomColor.rgb, p1), 1);

                // Step3
                half p = i.uv.y;
                p = abs(p);
                float p1 = pow(1.0f - p, _Strength);
                fixed4 col = fixed4(lerp(_TopColor.rgb, _BottomColor.rgb, p1), 1);
                
                return col;
            }
            ENDCG
        }
    }
}
