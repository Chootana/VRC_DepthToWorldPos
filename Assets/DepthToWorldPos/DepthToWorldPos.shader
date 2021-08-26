Shader "DepthToWorldPos"
{
    Properties
    {
        _BlendRatio("Alpha Blend Ratio", Range(0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"}
        
        LOD 100
        Ztest Always
        ZWrite Off 
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 projCoord : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _GrabTex;
            sampler2D _CameraDepthTexture;

            float _BlendRatio;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = float4(1-2*v.uv.x,2*v.uv.y-1,0,1);
                float3 localViewDir = mul(unity_CameraInvProjection, float4(o.vertex.x, -o.vertex.y, 0, 1)).xyz;
                o.viewDir = mul(transpose(UNITY_MATRIX_V), localViewDir);
                o.projCoord = UNITY_PROJ_COORD(ComputeGrabScreenPos(o.vertex));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                float3 camPos = _WorldSpaceCameraPos;
                float3 camDir = unity_CameraToWorld._m02_m12_m22;
                float3 viewDir = normalize(i.viewDir);

                float depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, i.projCoord))/dot(camDir, viewDir);

                float3 worldPos = camPos + viewDir * depth;
                float3 lineDebugColor = pow(abs(cos(worldPos.xyz * UNITY_PI * 4)), 20);
                
                float4 col = float4(lineDebugColor, _BlendRatio);

                return col;

            }
            ENDCG
        }
    }
}
