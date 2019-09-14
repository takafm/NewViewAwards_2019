Shader "ShaderSamplePack-01/PolygonDestruction"
{
	Properties
	{
		[KeywordEnum(Camera, Property)]
		_Method("Destruction Method", Float) = 0	
		[KeywordEnum(Inside, Outside)]
		_Condition("Destruction Condition", Float) = 0

		[HDR] _Color("Color", Color) = (1, 1, 1, 1)
		_Smoothness("Smootheness", Range(0.0, 1.0)) = 0.5
		_MainTex("Texture", 2D) = "white"{}
		[Normal]
		_NormalTex("Normal Texture", 2D) = "bump"{}

		_PositionFactor("Position Factor", Range(0.0, 2.0)) = 2.0
		_RotationFactor("Rotation Factor", Range(0.0, 20.0)) = 10.0
		_ScaleFactor("Scale Factor", Range(0.0, 1.0)) = 1.0
		_StartDistance("Start Distance", Float) = 1.2

		// for debug
		_DestructionFactor("Destruction Factor", Range(0.0, 1.0)) = 0.0
	}

	CGINCLUDE

	#include "UnityCG.cginc"
	#include "UnityLightingCommon.cginc"
	#define PI 3.1415926525

	fixed _DestructionFactor;
	fixed _PositionFactor;
	fixed _RotationFactor;
	fixed _ScaleFactor;
	fixed _StartDistance;
	fixed4 _Color;
	fixed _Smoothness;

	sampler2D _MainTex;
	fixed4 _MainTex_ST;
	sampler2D _NormalTex;
	fixed4 _NormalTex_ST;

	static const fixed3 _Ambient = fixed3(0.25, 0.25, 0.25);
	static const fixed _Shininess = 800.0;

	struct appdata_t
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
		float4 tangent : TANGENT;
	};

	struct v2g
	{
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 uv : TEXCOORD0;
		float4 tangent : TANGENT;
		float4 light : COLOR1;
		half3 lightDir : TEXCOORD1;
		half3 viewDir : TEXCOORD2;
	};

	struct g2f
	{
		float4 vertex : SV_POSITION;
		fixed4 color : COLOR;
		float2 uv : TEXCOORD0;
		float3 normal : TEXCOORD3;
		float4 light : COLOR1;
		half3 lightDir : TEXCOORD1;
		half3 viewDir : TEXCOORD2;
	};

	float4x4 InvTangentMatrix(float3 tangent, float3 bionormal, float3 normal)
	{
		float4x4 mat = float4x4(float4(tangent.x, tangent.y, tangent.z, 0.0),
								float4(bionormal.x, bionormal.y, bionormal.z, 0.0),
								float4(normal.x, normal.y, normal.z, 0.0),
								float4(0, 0, 0, 1));
		return transpose(mat);
	}

	inline float rand(float2 seed)
	{
		return frac(sin(dot(seed.xy, float2(12.9898, 78.233))) * 43758.5453);
	}

	float3 rotate(float3 p, float3 rotation)
	{
		float3 a = normalize(rotation);
		float angle = length(rotation);
		if (abs(angle) < 0.001) return p;
		float s = sin(angle);
		float c = cos(angle);
		float r = 1.0 - c;
		float3x3 m = float3x3(
			a.x * a.x * r + c,
			a.y * a.x * r + a.z * s,
			a.z * a.x * r - a.y * s,
			a.x * a.y * r - a.z * s,
			a.y * a.y * r + c,
			a.z * a.y * r + a.x * s,
			a.x * a.z * r + a.y * s,
			a.y * a.z * r - a.x * s,
			a.z * a.z * r + c
		);
		return mul(m, p);
	}
	
	v2g vert(appdata_t v)
	{
		v2g o;

		o.vertex = v.vertex;
		o.normal = v.normal;
		o.uv = v.uv.xy;
		o.tangent = v.tangent;

		float3 nor = normalize(v.normal);
		float3 tan = normalize(v.tangent);
		float3 binor = cross(nor, tan);

		// *****************************************************//
		// Declares 3x3 matrix 'rotation', filled with tangent space basis	
		// #define TANGENT_SPACE_ROTATION \
    	// float3 binormal = cross( v.normal, v.tangent.xyz ) * v.tangent.w; \
    	// float3x3 rotation = float3x3( v.tangent.xyz, binormal, v.normal )
		// *****************************************************//
		TANGENT_SPACE_ROTATION;
		o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
		o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

		o.light = mul(mul(unity_ObjectToWorld, _WorldSpaceLightPos0), InvTangentMatrix(tan, binor, nor));
		return o;
	}
	
	[maxvertexcount(3)]
	void geom(triangle v2g input[3], inout TriangleStream<g2f> stream)
	{
		// *****************************************************//
		// Calculate destruction value by distance with camera

		float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
		float3 vec1 = input[1].vertex - input[0].vertex;
		float3 vec2 = input[2].vertex - input[0].vertex;
		float3 normal = normalize(cross(vec1, vec2));

#ifdef _METHOD_PROPERTY
			// for debug
			fixed destruction = _DestructionFactor;
#else
			float4 worldPos = mul(unity_ObjectToWorld, float4(center, 1.0));
			float3 dist = length(_WorldSpaceCameraPos - worldPos);
			
			// If the distance to the camera is smaller 
#ifdef _CONDITION_INSIDE
			fixed destruction = clamp(_StartDistance - dist, 0.0, 1.0);
			
			// If the distance to the camera is bigger 
#else
			fixed destruction = clamp(dist - _StartDistance, 0.0, 1.0);
#endif

#endif

		// *****************************************************//

		fixed random = rand(center.xy) - 0.5;
		fixed3 random3 = random.xxx;

		[unroll]
		for(int i = 0; i < 3; i++)
		{
			v2g v = input[i];
			g2f o;

			// Scale
			v.vertex.xyz = (v.vertex.xyz - center) * (1.0 - destruction * _ScaleFactor) + center;
			// Rotation
			v.vertex.xyz = rotate(v.vertex.xyz - center, random3 * destruction * _RotationFactor) + center;
			// Diffusion
			v.vertex.xyz += normal * destruction * _PositionFactor * random3;
	
			o.vertex = UnityObjectToClipPos(v.vertex);

			o.color = fixed4(1, 1, 1, 1);
			o.uv = TRANSFORM_TEX(v.uv, _MainTex);

			o.lightDir = v.lightDir;
			o.viewDir = v.viewDir;

			half3 worldNormal = UnityObjectToWorldNormal(v.normal);
			o.normal = worldNormal;
			o.light = v.light;

			stream.Append(o);
		}
		stream.RestartStrip();
	}

	fixed4 frag (g2f i) : SV_Target
	{
		fixed4 albedo = tex2D(_MainTex, i.uv);

		// Bump Mapping
		i.lightDir = normalize(i.lightDir);
		i.viewDir = normalize(i.viewDir);
	
		float3 normal = float4(UnpackNormal(tex2D(_NormalTex, i.uv)), 1);
		
		// Diffuse
		half3 diffuse = max(0, dot(normal, i.lightDir)) * 0.5 + 0.5;

		// Specular
		half3 halfVector = max(0, dot(normal, normalize(i.lightDir + i.viewDir)));
		half3 specular = saturate(pow(halfVector, _Shininess * pow(_Smoothness, 4.0)) * _Smoothness);

		fixed4 color;
		color.rgb =  albedo.rgb * _Color * _LightColor0 * diffuse + _LightColor0 * specular;
		color.rgb += glstate_lightmodel_ambient;

		color.a = i.color.a;

		return color;
	}

	ENDCG

	SubShader
	{
		Tags 
		{ 
			"RenderType"="Opaque"
		}

		Pass
		{
			CGPROGRAM
	
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#pragma multi_compile _METHOD_PROPERTY _METHOD_CAMERA
			#pragma multi_compile _CONDITION_INSIDE _CONDITION_OUTSIDE
			#pragma target 5.0
			
			ENDCG
		}
	}

	FallBack "Diffuse"
}
