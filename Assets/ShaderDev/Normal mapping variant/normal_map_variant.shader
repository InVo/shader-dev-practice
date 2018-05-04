// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderDev/12NormalMapVariant" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTexture("Main Texture", 2D) = "white" {}
		_NormalMap("Normal map", 2D) = "white" {}
		[Toggle(ENABLE_NORMAL_MAPPING)] _UseNormalMap("Use Normal map",  Float) = 0
	}

	SubShader 
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
		Pass 
		{

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag

		uniform float4 _Color;
		uniform sampler2D _MainTexture;
		uniform float4 _MainTexture_ST;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;

#pragma shader_feature ENABLE_NORMAL_MAPPING

		struct vertexInput 
		{
			float4 vertex : POSITION;
			float4 normal: NORMAL;
			float4 texCoord: TEXCOORD0;
#if ENABLE_NORMAL_MAPPING
			float4 tangent: TANGENT;
#endif
		};

		struct vertexOutput
		{
			float4 pos : SV_POSITION;
			float4 texCoord: TEXCOORD0;
			float3 normalWorld: TEXCOORD1;
#if ENABLE_NORMAL_MAPPING
			float4 normalTexCoord: TEXCOORD4;
			float3 tangentWorld: TEXCOORD2;
			float3 binormal: TEXCOORD3;
#endif
		};

		vertexOutput vert(vertexInput v)
		{
			vertexOutput o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.texCoord.xy = v.texCoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
			o.normalWorld = normalize(mul(v.normal, unity_WorldToObject)); // notice inverse unity_ObjectToWorld here!!
#if ENABLE_NORMAL_MAPPING
			o.normalTexCoord.xy = v.texCoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.tangentWorld = normalize(mul(v.tangent, unity_ObjectToWorld));
			o.binormal = normalize((cross(o.normalWorld, o.tangentWorld) * v.tangent.w)); // wHy multiply?
#endif
			return o;
		}

#if ENABLE_NORMAL_MAPPING
		float3 normalFromColor(float4 color)
		{
		#if defined(UNITY_NO_DXT5nm)
			return color.rgb * 2 - 1;
		#else
			//R => A
			//G => y
			//B ignored
			//
			float3 normalVal = float3(color.a * 2.0 - 1.0,
									color.g * 2.0 - 1.0,
									0.0);
			float z = sqrt(1 - dot(normalVal.xy, normalVal.xy));
			normalVal.z = z;
			return normalVal;
		#endif
		}
#endif

		float4 frag(vertexOutput i) : COLOR
		{
#if ENABLE_NORMAL_MAPPING
			// Color of pixel read from tangent space normal map
			fixed4 normalColAtPixel = tex2D(_NormalMap, i.normalTexCoord);

			// Normal value in tangent space converted from color value
			float3 normalAtPixel = normalFromColor(normalColAtPixel);

			//Compose TBN matrix
			float3x3 tbnWorld = float3x3(i.tangentWorld,
									     i.normalWorld,
									     i.binormal);
			float3 normalAtPixelWorld = normalize(mul(tbnWorld, normalAtPixel));

			return (normalAtPixelWorld, 1);
#else
			//float4 texColor = tex2D(_MainTexture, i.texCoord);
			//float4 color = _Color * texColor;
			//return color;
			return (i.normalWorld, 1);
#endif
		}

		ENDCG
		}
	}
}