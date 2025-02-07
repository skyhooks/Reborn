  Shader "Reborn/Ghost" {
    Properties {
      _MainTex ("Texture", 2D) = "white" {}
      _BumpMap ("Bumpmap", 2D) = "bump" {}
      _RimColor ("Rim Color", Color) = (1.0,0.56,0.0,1.0)
      _RimPower ("Rim Power", Range(0.2,2.0)) = 0.5
      _Brightness ("Brightness",Range(0.0,3.0)) = 3.0
    }
    SubShader {
      Tags { "RenderType" = "Transparent" "Queue"="Transparent" "IgnoreProjector"="True"}
      
    // extra pass that renders to depth buffer only
     Pass {
        ZWrite On
        ColorMask 0
       }
          
      CGPROGRAM
      #pragma surface surf Lambert alpha noambient nolightmap nodirlightmap  novertexlights
      struct Input {
          float2 uv_MainTex;
          float2 uv_BumpMap;
          float3 viewDir;
      };
      sampler2D _MainTex;
      sampler2D _BumpMap;
      float4 _RimColor;
      float _RimPower;
      float _Brightness;

      void surf (Input IN, inout SurfaceOutput o) {
      	half4 basecol = tex2D (_MainTex, IN.uv_MainTex);
     		half3 graycol = dot(basecol.rgb,float3(0.3,0.59,0.11));
          o.Albedo = graycol;
          o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
          half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
          o.Emission = _RimColor.rgb * pow (rim, _RimPower) * _Brightness;
          o.Alpha = (o.Emission.r+o.Emission.g+o.Emission.b) / 3.0;
      }
      ENDCG
    } 
    Fallback "Diffuse"
  }