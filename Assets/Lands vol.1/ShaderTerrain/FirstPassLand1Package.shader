Shader "Nature/Terrain/Land1Package/DiffuseCustom" {
	Properties {
		[HideInInspector] _Control ("Control (RGBA)", 2D) = "red" {}
		[HideInInspector] _Splat3 ("Layer 3 (A)", 2D) = "white" {}
		[HideInInspector] _Splat2 ("Layer 2 (B)", 2D) = "white" {}
		[HideInInspector] _Splat1 ("Layer 1 (G)", 2D) = "white" {}
		[HideInInspector] _Splat0 ("Layer 0 (R)", 2D) = "white" {}
		[HideInInspector] _Normal3 ("Normal 3 (A)", 2D) = "bump" {}
		[HideInInspector] _Normal2 ("Normal 2 (B)", 2D) = "bump" {}
		[HideInInspector] _Normal1 ("Normal 1 (G)", 2D) = "bump" {}
		[HideInInspector] _Normal0 ("Normal 0 (R)", 2D) = "bump" {}
		
		_TexOverlay ("Overlay (RGBA)", 2D) = "white" {}
		_TestColor ("Additional Overlay (RGB)", 2D) = "white" {}
				
		_NormalGenerale ("Normal Map Far", 2D) = "bump" {}
		_PowerNormalGenerale("Power Normal Map Far", Float) = 1
		
		_NormalSecondaria ("Normal Map Additional", 2D) = "bump" {}
		_PowerNormalSecondaria("Power Normal Map Additional", Float) = 1
		
		
		_MainTexNorm ("Normal Map Near", 2D) = "bump" {}
		_PowerNormalVicina("Power Normal Map Near", Float) = 1
		
		
		_ChangePoint ("Distance", Float) = 1000
       [HideInInspector]  _CentrePoint ("Centre", Vector) = (0, 0, 0, 0)
        _BlendThreshold ("Distance Blend ", Float) = 20
		// used in fallback on old cards & base map
		[HideInInspector] _MainTex ("BaseMap (RGB)", 2D) = "white" {}
		[HideInInspector] _Color ("Main Color", Color) = (1,1,1,1)
	}
	

	CGINCLUDE
		#pragma surface surf Lambert vertex:SplatmapVert finalcolor:myfinal exclude_path:prepass exclude_path:deferred
		#pragma multi_compile_fog
		#include "TERRAIN_SPLATMAP_LAND1PACKAGE.cginc"
				
           

		
		
		void surf(Input IN, inout SurfaceOutput o)
		{
			half4 splat_control;
			half weight;
			fixed4 mixedDiffuse;
			
			fixed4 colorMap = tex2D (_TestColor, IN.uv_TestColor);
			fixed4 overlayMap = tex2D (_TexOverlay, IN.uv_TexOverlay);
			//fixed4 overlayMap2 = tex2D (_TexOverlay2, IN.uv_TexOverlay2);
		
			SplatmapMix(IN, splat_control, weight, mixedDiffuse, o.Normal);		
			float startBlending = _ChangePoint - _BlendThreshold;
            float endBlending = _ChangePoint + _BlendThreshold;
             
             float curDistance = distance(_CentrePoint.xyz, IN.worldPos);
             float changeFactor = saturate((curDistance - startBlending) / (_BlendThreshold * 2));			
              fixed4 diffuseSommate = colorMap + overlayMap;// + overlayMap2;//lerp (colorMap,overlayMap,0.5f);
             fixed4 BlendDiffuse = lerp(mixedDiffuse, diffuseSommate, changeFactor);
             //BlendDiffuse += 	overlayMap2;									                                        
            o.Albedo = BlendDiffuse.rgb;
			o.Alpha = weight; 
		
			
		}

		void myfinal(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			SplatmapApplyWeight(color, o.Alpha);
			SplatmapApplyFog(color, IN);
		}




	ENDCG
//		SubShader {
//        Pass {
//            // Apply base texture
//            SetTexture [_NormalGenerale] {
//                combine texture
//            }
//            // Blend in the alpha texture using the lerp operator
//            SetTexture [_MainTexNorm] {
//             combine previous * texture
//               // combine texture lerp (texture) previous
//            }
//        }
//    }//Fine subshader
	Category {
		Tags {
			"SplatCount" = "4"
			"Queue" = "Geometry-99"
			"RenderType" = "Opaque"
		}
		// TODO: Seems like "#pragma target 3.0 _TERRAIN_NORMAL_MAP" can't fallback correctly on less capable devices?
		// Use two sub-shaders to simulate different features for different targets and still fallback correctly.
		

		
		
		
		SubShader { // for sm3.0+ targets
			CGPROGRAM
				#pragma target 4.0
				#pragma multi_compile __ _TERRAIN_NORMAL_MAP
			ENDCG
		}
		SubShader { // for sm2.0 targets
			CGPROGRAM
			#pragma target 4.0
			ENDCG
		}
		
	}

	Dependency "AddPassShader" = "Hidden/TerrainEngine/Splatmap/Diffuse-AddPass"
	Dependency "BaseMapShader" = "Diffuse"
	Dependency "Details0"      = "Hidden/TerrainEngine/Details/Vertexlit"
	Dependency "Details1"      = "Hidden/TerrainEngine/Details/WavingDoublePass"
	Dependency "Details2"      = "Hidden/TerrainEngine/Details/BillboardWavingDoublePass"
	Dependency "Tree0"         = "Hidden/TerrainEngine/BillboardTree"

	Fallback "Diffuse"
}
