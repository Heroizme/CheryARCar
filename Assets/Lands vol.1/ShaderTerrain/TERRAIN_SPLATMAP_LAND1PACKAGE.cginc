// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

#ifndef TERRAIN_SPLATMAP_LAND1PACKAGE_CGINC_INCLUDED
#define TERRAIN_SPLATMAP_LAND1PACKAGE_CGINC_INCLUDED

struct Input
{

    float2 uv_NormalGenerale;
    float2 uv_NormalSecondaria;
    float2 uv_MainTexNorm;
    float3 worldPos;
    float2 uv_TestColor;
    float2 uv_TexOverlay;
   


	float2 uv_Splat0 : TEXCOORD0;
	float2 uv_Splat1 : TEXCOORD1;
	float2 uv_Splat2 : TEXCOORD2;
	float2 uv_Splat3 : TEXCOORD3;
	float2 tc_Control : TEXCOORD4;	// Not prefixing '_Contorl' with 'uv' allows a tighter packing of interpolators, which is necessary to support directional lightmap.
	UNITY_FOG_COORDS(5)
	INTERNAL_DATA
};

sampler2D _NormalGenerale;
sampler2D _NormalSecondaria;
sampler2D _MainTexNorm;
sampler2D _TestColor;
sampler2D _TexOverlay;
//sampler2D _TexOverlay2;
    float _ChangePoint;
    float _PowerNormalGenerale;
    float _PowerNormalSecondaria;
    float _PowerNormalVicina;
    float4 _CentrePoint;  
    float _BlendThreshold;

sampler2D _Control;
float4 _Control_ST;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;

#ifdef _TERRAIN_NORMAL_MAP
	sampler2D _Normal0, _Normal1, _Normal2, _Normal3;
#endif

void SplatmapVert(inout appdata_full v, out Input data)
{
	UNITY_INITIALIZE_OUTPUT(Input, data);
	data.tc_Control = TRANSFORM_TEX(v.texcoord, _Control);	// Need to manually transform uv here, as we choose not to use 'uv' prefix for this texcoord.
	float4 pos = UnityObjectToClipPos (v.vertex);
	UNITY_TRANSFER_FOG(data, pos);
	
#ifdef _TERRAIN_NORMAL_MAP
	v.tangent.xyz = cross(v.normal, float3(0,0,1));
	v.tangent.w = -1;
#endif
}

#ifdef TERRAIN_STANDARD_SHADER
void SplatmapMix(Input IN, half4 defaultAlpha, out half4 splat_control, out half weight, out fixed4 mixedDiffuse, inout fixed3 mixedNormal)
#else
void SplatmapMix(Input IN, out half4 splat_control, out half weight, out fixed4 mixedDiffuse, inout fixed3 mixedNormal)
#endif
{
	splat_control = tex2D(_Control, IN.tc_Control);
	weight = dot(splat_control, half4(1,1,1,1));

	#ifndef UNITY_PASS_DEFERRED
		// Normalize weights before lighting and restore weights in applyWeights function so that the overal
		// lighting result can be correctly weighted.
		// In G-Buffer pass we don't need to do it if Additive blending is enabled.
		// TODO: Normal blending in G-buffer pass...
		splat_control /= (weight + 1e-3f); // avoid NaNs in splat_control
	#endif

	#if !defined(SHADER_API_MOBILE) && defined(TERRAIN_SPLAT_ADDPASS)
		clip(weight - 0.0039 /*1/255*/);
	#endif

	mixedDiffuse = 0.0f;
	
	#ifdef TERRAIN_STANDARD_SHADER
		mixedDiffuse += splat_control.r * tex2D(_Splat0, IN.uv_Splat0) * half4(1.0, 1.0, 1.0, defaultAlpha.r);
		mixedDiffuse += splat_control.g * tex2D(_Splat1, IN.uv_Splat1) * half4(1.0, 1.0, 1.0, defaultAlpha.g) ;
		mixedDiffuse += splat_control.b * tex2D(_Splat2, IN.uv_Splat2) * half4(1.0, 1.0, 1.0, defaultAlpha.b);
		mixedDiffuse += splat_control.a * tex2D(_Splat3, IN.uv_Splat3) * half4(1.0, 1.0, 1.0, defaultAlpha.a);
	#else
		mixedDiffuse += splat_control.r * tex2D(_Splat0, IN.uv_Splat0);
		mixedDiffuse += splat_control.g * tex2D(_Splat1, IN.uv_Splat1);
		mixedDiffuse += splat_control.b * tex2D(_Splat2, IN.uv_Splat2);
		mixedDiffuse += splat_control.a * tex2D(_Splat3, IN.uv_Splat3);
		
		
	    
	    

	#endif

	#ifdef _TERRAIN_NORMAL_MAP
		fixed4 nrm = 0.0f;
//		nrm += splat_control.r * tex2D(_Normal0, IN.uv_Splat0);
//		nrm += splat_control.g * tex2D(_Normal1, IN.uv_Splat1);
//		nrm += splat_control.b * tex2D(_Normal2, IN.uv_Splat2);
//		nrm += splat_control.a * tex2D(_Normal3, IN.uv_Splat3);
		///////////////////////////////////////////////////////////////////////////////////////
					fixed4 colorMap = tex2D (_TestColor, IN.uv_TestColor);
			fixed4 overlayMap = tex2D (_TexOverlay, IN.uv_TexOverlay);
			float3 normNear = UnpackNormal(tex2D(_MainTexNorm,IN.uv_MainTexNorm));
			normNear *= _PowerNormalVicina;
			
			float3 normalMapGenerale = UnpackNormal(tex2D(_NormalGenerale,IN.uv_NormalGenerale));
			normalMapGenerale *= _PowerNormalGenerale;
			
			
			float3 normalMapSecondaria = UnpackNormal(tex2D(_NormalSecondaria,IN.uv_NormalSecondaria));
			normalMapSecondaria *= _PowerNormalSecondaria;
			
			float startBlending = _ChangePoint - _BlendThreshold;
            float endBlending = _ChangePoint + _BlendThreshold;
             
             float curDistance = distance(_CentrePoint.xyz, IN.worldPos);
             float changeFactor = saturate((curDistance - startBlending) / (_BlendThreshold * 2));
             //Blend Normal
             float3 normSommate = lerp(normalMapGenerale, normalMapSecondaria,0.5f);
           //  float3 norm = lerp(normNear, normalMapGenerale, changeFactor);
             float3 norm = lerp(normNear, normSommate, changeFactor);
             //Blend Diffuse Texture
             fixed4 diffuseSommate = colorMap + overlayMap;//lerp (colorMap,overlayMap,0.5f);
             fixed4 BlendDiffuse = lerp(mixedDiffuse, diffuseSommate, changeFactor);

            // mixedDiffuse = BlendDiffuse;
            // nrm = lerp(norm, nrm,0.5f);
		///////////////////////////////////////////////////////////////////////////////////////
		mixedNormal = UnpackNormal(nrm);
		mixedNormal = lerp (mixedNormal,norm,0.5f);
		//mixedNormal = norm;
	#endif
}

void SplatmapApplyWeight(inout fixed4 color, fixed weight)
{
	color.rgb *= weight;
	color.a = 1.0f;
}

void SplatmapApplyFog(inout fixed4 color, Input IN)
{
	#ifdef TERRAIN_SPLAT_ADDPASS
		UNITY_APPLY_FOG_COLOR(IN.fogCoord, color, fixed4(0,0,0,0));
	#else
		UNITY_APPLY_FOG(IN.fogCoord, color);
	#endif
}

#endif
