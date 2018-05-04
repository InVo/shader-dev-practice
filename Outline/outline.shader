Shader "Custom/Outline"
{
	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
		_NormalMap("Normal Map", 2D) = "white" {}
		_OutlineWidth("Outline width", Float) = 1.0
		_MainColor("Main Color", Color) = (1,1,1,1)
		_OutlineColor("Outline Color", Color) = (1,1,1,1)
		[KeywordEnum(Yes, No, DontKnow)] _Feature("Feature", Float) =  0
	}


	SubShader
	{
		Tags{"IgnoreProjector"="True" "Queue"="Transparent" "RenderType"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform float _OutlineWidth;
			uniform float4 _OutlineColor;

			struct vertexInput 
			{
				float4 pos: POSITION;
				float4 normal: NORMAL;
				float4 tangent: TANGENT;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				v.pos.xyz *= 1 + _OutlineWidth;
				o.pos = UnityObjectToClipPos(v.pos);
				return o;
			}

			fixed4 frag(vertexOutput i): COLOR
			{
				return _OutlineColor;
			}

			ENDCG
		}

		Pass 
		{
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
		
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform sampler2D _NormalMap;
			uniform float4 _NormalMap_ST;
		
			struct vertexInput 
			{
				float4 pos: POSITION;
				float4 normal: NORMAL;
				float4 tangent: TANGENT;
				float4 texCoord: TEXCOORD0;
			};
		
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texCoord: TEXCOORD0;
			};
		
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.pos = UnityObjectToClipPos(v.pos);
				o.texCoord.xy = v.texCoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				return o;
			}
		
			fixed4 frag(vertexOutput i) : COLOR
			{
#pragma shader_feature _FEATURE_YES _FEATURE_NO
#if _FEATURE_YES
				fixed4 color = tex2D(_MainTex, i.texCoord);
				return color;
#endif
#if _FEATURE_NO
				return (1,1,1,1);
#endif
			}
		
			ENDCG
		}
	}
}
