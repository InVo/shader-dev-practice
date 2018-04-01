// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderDev/11NormalMap" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTexture("Main Texture", 2D) = "white" {}
		_NormalMap("Normal map", 2D) = "white" {}
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

		struct vertexInput 
		{
			float4 vertex : POSITION;
			float4 normal: NORMAL;
			float4 tangent: TANGENT;
			float4 texCoord: TEXCOORD0;
		};

		struct vertexOutput
		{
			float4 pos : SV_POSITION;
			float4 texCoord: TEXCOORD0;
			float4 normalTexCoord: TEXCOORD4;
			float4 normalWorld: TEXCOORD1;
			float4 tangentWorld: TEXCOORD2;
			float3 binormal: TEXCOORD3;
		};

		vertexOutput vert(vertexInput v)
		{
			vertexOutput o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.texCoord.xy = v.texCoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
			o.normalTexCoord.xy = v.texCoord.xy * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.normalWorld = normalize(mul(v.normal, unity_WorldToObject)); // notice inverse unity_ObjectToWorld here!!
			o.tangentWorld = normalize(mul(v.tangent, unity_ObjectToWorld));
			o.binormal = normalize((cross(o.normalWorld, o.tangentWorld) * v.tangent.w)); // wHy multiply?
			return o;
		}

		float4 frag(vertexOutput i) : COLOR
		{
			fixed3 normalColAtPixel = tex2D(_NormalMap, i.normalTexCoord);
			fixed3 normalAtPixel = normalFromColor(normalColAtPixel);

			float4 texColor = tex2D(_MainTexture, i.texCoord);
			float4 color = _Color * texColor;
			return color;
		}

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
			float z = sqrt(1 - normalVal.x * normalVal.x + normalVal.y * normalVal.y);
			normalVal.z = z;
			return normalVal;
		}

		ENDCG
		}
	}
}