// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderDev/06Circle" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTexture("Main Texture", 2D) = "white"
		_Center("Center", Vector) = (0.5, 0.5, 0, 0)
		_Radius("Radius",Float) = 0.5
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
		uniform float4 _Center;
		uniform float _Radius;

		struct vertexInput 
		{
			float4 vertex : POSITION;
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
			o.pos = UnityObjectToClipPos(v.vertex);
			o.texCoord.xy = v.texCoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
			return o;
		}

		float drawCircle(float2 uv) 
		{
			float2 vec = uv - _Center.xy;
			float l = dot(vec, vec);
			return step(l, _Radius * _Radius);
		}

		float4 frag(vertexOutput i) : COLOR
		{
			float4 texColor = tex2D(_MainTexture, i.texCoord);
			float4 color = _Color * texColor;
			color.a = drawCircle(i.texCoord);
			return color;
		}

		ENDCG
		}
	}
}