﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "ShaderDev/04Line" 
{
	Properties 
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTexture("Main Texture", 2D) = "white"
		_Start("Start", Float) = 0
		_End("End", Float) = 1
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
		uniform float _Start;
		uniform float _End;

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

		float drawLine(float2 uv, float start, float end) 
		{
			if(uv.x >= start && uv.x <= end) 
			{
				return 1;
			}
			return 0;
		}

		float drawLineFast(float2 uv, float start, float end)
		{
			return step(start, uv.x) * step(uv.x, end);
		}

		float4 frag(vertexOutput i) : COLOR
		{
			float4 texColor = tex2D(_MainTexture, i.texCoord);
			float4 color = _Color * texColor;
			color.a = drawLineFast(i.texCoord, _Start, _End);
			return color;
		}

		ENDCG
		}
	}
}