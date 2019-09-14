Shader "ShaderSamplePack-01/Rimlighting" 
{
	Properties
	{
		_MainColor ("Main Color", Color) = (0, 0, 0, 1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0, 1)) = 0.5
		_Metallic ("Metallic", Range(0, 1)) = 0.0
		[HDR] _RimColor ("Rim Color", Color) = (0, 0, 1, 1)
		_RimStrength ("Rim Strength", Range(0, 10)) = 3 
		_Speed ("Speed", Float) = 1.0
	}

	SubShader 
	{
		Tags 
		{ 
			"RenderType"="Transparent"
			"Queue"="Transparent" 
		}

		// First pass
		pass
		{
			ZWrite On
			ColorMask 0
		}
		

		// Second pass
		CGPROGRAM

		#pragma surface surf Standard alpha fullforwardshadows 
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
			float3 viewDir;
			float3 worldNormal;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _MainColor;
		fixed4 _RimColor;
		fixed _RimStrength;
		fixed _Speed;

		void surf (Input IN, inout SurfaceOutputStandard o)
		{

			fixed4 color = tex2D (_MainTex, IN.uv_MainTex) * _MainColor;
			o.Albedo = color.rgb;
			o.Alpha = _MainColor.a;
			float rim = 1 - saturate(dot(IN.viewDir, IN.worldNormal));
			float t = (sin(_Time.y * +_Speed) + 1.0) * 0.5;
			o.Emission = _RimColor * pow(rim, _RimStrength) * lerp(0.5, 1.0, t);
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
	}	
	
	FallBack "Diffuse"
}
