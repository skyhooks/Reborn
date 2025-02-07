﻿// Upgrade NOTE: replaced '_Projector' with 'unity_Projector'
// Upgrade NOTE: replaced '_ProjectorClip' with 'unity_ProjectorClip'

Shader "Reborn/ProjectorAdditiveTint" {
	Properties {
		_Color ("Tint Color", Color) = (1,1,1,1)
		_Attenuation ("Falloff", Range(0.0, 1.0)) = 1.0
		_Emission("Emission", Range(0.0, 5.0)) = 1.0
		_MainTex ("Cookie", 2D) = "gray" {}
	}
	Subshader {
		Tags {"Queue"="Transparent"}
		Pass {
			ZWrite Off
			ColorMask RGB
			Blend SrcAlpha One // Additive blending
			Offset -1, -1

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			struct v2f {
				float4 uvShadow : TEXCOORD0;
				float4 pos : SV_POSITION;
			};
			
			float4x4 unity_Projector;
			float4x4 unity_ProjectorClip;
			
			v2f vert (float4 vertex : POSITION)
			{
				v2f o;
				o.pos = mul (UNITY_MATRIX_MVP, vertex);
				o.uvShadow = mul (unity_Projector, vertex);
				return o;
			}
			
			sampler2D _MainTex;
			fixed4 _Color;
			float _Attenuation;
			float _Emission;
			
			fixed4 frag (v2f i) : SV_Target
			{
				// Apply alpha mask
				fixed4 texCookie = tex2Dproj (_MainTex, UNITY_PROJ_COORD(i.uvShadow));
				fixed4 outColor = _Emission * _Color * texCookie.a;
				// Attenuation
				float depth = i.uvShadow.z; // [-1 (near), 1 (far)]
				return outColor * clamp(1.0 - abs(depth) + _Attenuation, 0.0, 1.0);
			}
			ENDCG
		}
	}
}