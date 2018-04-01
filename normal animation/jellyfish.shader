// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderDev/10NormalAnimation" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTexture("Main Texture", 2D) = "white"
		_Speed("Speed", Float) = 1
		_Frequency("Frequency", Float) = 1
		_Amplitude("Amplitude", Float) = 0.5
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
			uniform float _Amplitude;
			uniform float _Speed;
			uniform float _Frequency;

			struct vertexInput 
			{
				float4 vertex : POSITION;
				float4 texCoord: TEXCOORD0;
				float4 normal : NORMAL;
			};

			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 texCoord: TEXCOORD0;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				o.texCoord.xy = v.texCoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
				v.vertex +=  _Amplitude * sin((v.normal - _Time.w * _Speed) * _Frequency) * v.normal;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				// multiplying by o.texCoord.y to hold anchor points (where flag is attached to stick)
				o.pos.x += _Amplitude * sin(_Frequency * (_Speed * _Time.w - v.texCoord.y));
				return o;
			}

			float4 frag(vertexOutput i) : COLOR
			{
				float4 texColor = tex2D(_MainTexture, i.texCoord);
				float4 color = _Color * texColor;
				return color;
			}

			ENDCG
		}
	}
}