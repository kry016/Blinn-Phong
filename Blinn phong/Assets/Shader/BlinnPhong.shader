// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/BlinnPhong"
{
    Properties
    {
        ColorMesh("Color", Color) = (1, 1, 1, 1)

        Brightness("Brightness", Float) = 10
        SpecColor("Specular Color", Color) = (1, 1, 1, 1) 
    }
    SubShader 
    {
        Tags { "RenderType" = "Opaque" } 
        LOD 200

        Pass 
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
                #pragma vertex vert 
                #pragma fragment frag 

                #include "UnityCG.cginc" 

                float4 _LightColor0;

                float4 ColorMesh; 
                float4 SpecColor; 
                float Brightness; 

                struct appdata 
                {
                    float4 vertex : POSITION; 
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f 
                {
                    float4 pos : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                    float4 posWorld : TEXCOORD1;
                };

                v2f vert(appdata v)
                {
                    v2f o;

                    o.posWorld = mul(unity_ObjectToWorld, v.vertex); 
                    o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); 
                    o.pos = UnityObjectToClipPos(v.vertex); 
                    o.uv = v.uv;

                    return o;
                }

                fixed4 frag(v2f i) : COLOR
                {
                    float3 normalDirection = normalize(i.normal);
                    float3 viewDirection = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
                    
                    float3 vert2LightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
                    float3 lightDirection = _WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w;

                    float3 ambientLighting = UNITY_LIGHTMODEL_AMBIENT.rgb * ColorMesh.rgb; 
                    float3 diffuseReflection = _LightColor0.rgb * ColorMesh.rgb * max(0.0, dot(normalDirection, lightDirection)); 

                    float3 specularReflection;
                    specularReflection = _LightColor0.rgb * SpecColor.rgb * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), Brightness);
                    float3 color = (ambientLighting + diffuseReflection)  + specularReflection; 
                    return float4(color, 1.0);
                }
            ENDCG
        }
    }
}
