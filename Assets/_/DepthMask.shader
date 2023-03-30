Shader "DDD/DepthMask" {
    SubShader{
        Tags { "Queue" = "Geometry-10" "RenderType" = "Opaque" }

        Pass {
            Cull Off
            ZTest LEqual
            ZWrite On
            Lighting Off
            ColorMask 0
        }
    }
}
