Shader "Shader Graphs/look_through_fuckind_z_buffer"
{
    Properties
    {
        [NoScaleOffset] _Main("Main", 2D) = "white" {}
        _Tint("Tint", Color) = (0, 0, 0, 0)
        _player_position("player_position", Vector) = (0.5, 0.5, 0, 0)
        _Size("Size", Float) = 1
        _smoothness("smoothness", Range(0, 1)) = 0.5
        _opacity("opacity", Range(0, 1)) = 1
        [HideInInspector]_BUILTIN_QueueOffset("Float", Float) = 0
        [HideInInspector]_BUILTIN_QueueControl("Float", Float) = -1
    }
        SubShader
        {
            Tags
            {
                // RenderPipeline: <None>
                "RenderType" = "Transparent"
                "BuiltInMaterialType" = "Lit"
                "Queue" = "Transparent"
            // DisableBatching: <None>
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = "BuiltInLitSubTarget"
        }
        Pass
        {
            Name "BuiltIn Forward"
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            // Render State
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite On
            ColorMask RGB

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 3.0
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            #define BUILTIN_TARGET_API 1
            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
            #endif
            #ifdef _BUILTIN_ALPHATEST_ON
            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
            #endif
            #ifdef _BUILTIN_AlphaClip
            #define _AlphaClip _BUILTIN_AlphaClip
            #endif
            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
            #endif


            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

            // Includes
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float4 texCoord0;
                #if defined(LIGHTMAP_ON)
                 float2 lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                 float3 sh;
                #endif
                 float4 fogFactorAndVertexLight;
                 float4 shadowCoord;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float3 TangentSpaceNormal;
                 float2 NDCPosition;
                 float2 PixelPosition;
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                #if defined(LIGHTMAP_ON)
                 float2 lightmapUV : INTERP0;
                #endif
                #if !defined(LIGHTMAP_ON)
                 float3 sh : INTERP1;
                #endif
                 float4 tangentWS : INTERP2;
                 float4 texCoord0 : INTERP3;
                 float4 fogFactorAndVertexLight : INTERP4;
                 float4 shadowCoord : INTERP5;
                 float3 positionWS : INTERP6;
                 float3 normalWS : INTERP7;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.sh;
                #endif
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                output.shadowCoord.xyzw = input.shadowCoord;
                output.positionWS.xyz = input.positionWS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if defined(LIGHTMAP_ON)
                output.lightmapUV = input.lightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.sh;
                #endif
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                output.shadowCoord = input.shadowCoord.xyzw;
                output.positionWS = input.positionWS.xyz;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }


            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Main_TexelSize;
            float4 _Tint;
            float2 _player_position;
            float _Size;
            float _smoothness;
            float _opacity;
            CBUFFER_END


                // Object and Global properties
                SAMPLER(SamplerState_Linear_Repeat);
                TEXTURE2D(_Main);
                SAMPLER(sampler_Main);

                // -- Property used by ScenePickingPass
                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif

                // -- Properties used by SceneSelectionPass
                #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
                #endif

                // Graph Includes
                // GraphIncludes: <None>

                // Graph Functions

                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                {
                    Out = A * B;
                }

                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }

                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }

                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }

                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }

                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A - B;
                }

                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }

                void Unity_Multiply_float_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }

                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }

                void Unity_Length_float2(float2 In, out float Out)
                {
                    Out = length(In);
                }

                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }

                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }

                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }

                // Custom interpolators pre vertex
                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };

                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }

                // Custom interpolators, pre surface
                #ifdef FEATURES_GRAPH_VERTEX
                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                {
                return output;
                }
                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                #endif

                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    UnityTexture2D _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main);
                    float4 _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.tex, _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.samplerstate, _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_R_4_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.r;
                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_G_5_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.g;
                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_B_6_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.b;
                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_A_7_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.a;
                    float4 _Property_d45859c46c4c4ba69c23757dfed2e3c0_Out_0_Vector4 = _Tint;
                    float4 _Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4;
                    Unity_Multiply_float4_float4(_SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4, _Property_d45859c46c4c4ba69c23757dfed2e3c0_Out_0_Vector4, _Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4);
                    float _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float = _smoothness;
                    float4 _ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                    float2 _Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2 = _player_position;
                    float2 _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2;
                    Unity_Remap_float2(_Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2);
                    float2 _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2;
                    Unity_Add_float2((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2, _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2);
                    float2 _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2;
                    Unity_TilingAndOffset_float((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), float2 (1, 1), _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2, _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2);
                    float2 _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2;
                    Unity_Multiply_float2_float2(_TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2, float2(2, 2), _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2);
                    float2 _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2;
                    Unity_Subtract_float2(_Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2, float2(1, 1), _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2);
                    float _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float;
                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float);
                    float _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float = _Size;
                    float _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float;
                    Unity_Multiply_float_float(_Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float, _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float);
                    float2 _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2 = float2(_Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float);
                    float2 _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2;
                    Unity_Divide_float2(_Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2, _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2, _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2);
                    float _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float;
                    Unity_Length_float2(_Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2, _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float);
                    float _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float;
                    Unity_OneMinus_float(_Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float, _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float);
                    float _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float;
                    Unity_Saturate_float(_OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float);
                    float _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float;
                    Unity_Smoothstep_float(0, _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float, _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float);
                    float _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float = _opacity;
                    float _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float;
                    Unity_Multiply_float_float(_Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float, _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float, _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float);
                    float _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                    Unity_OneMinus_float(_Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float, _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float);
                    surface.BaseColor = (_Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4.xyz);
                    surface.NormalTS = IN.TangentSpaceNormal;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = 0;
                    surface.Smoothness = 0.5;
                    surface.Occlusion = 1;
                    surface.Alpha = _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                    return surface;
                }

                // --------------------------------------------------
                // Build Graph Inputs

                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                    output.ObjectSpaceNormal = input.normalOS;
                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                    output.ObjectSpacePosition = input.positionOS;

                    return output;
                }
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                    #if UNITY_UV_STARTS_AT_TOP
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #else
                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                    #endif

                    output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
                    output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                    output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                        return output;
                }

                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                {
                    result.vertex = float4(attributes.positionOS, 1);
                    result.tangent = attributes.tangentOS;
                    result.normal = attributes.normalOS;
                    result.texcoord = attributes.uv0;
                    result.texcoord1 = attributes.uv1;
                    result.vertex = float4(vertexDescription.Position, 1);
                    result.normal = vertexDescription.Normal;
                    result.tangent = float4(vertexDescription.Tangent, 0);
                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                }

                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                {
                    result.pos = varyings.positionCS;
                    result.worldPos = varyings.positionWS;
                    result.worldNormal = varyings.normalWS;
                    // World Tangent isn't an available input on v2f_surf

                    result._ShadowCoord = varyings.shadowCoord;

                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                    #if UNITY_SHOULD_SAMPLE_SH
                    #if !defined(LIGHTMAP_ON)
                    result.sh = varyings.sh;
                    #endif
                    #endif
                    #if defined(LIGHTMAP_ON)
                    result.lmap.xy = varyings.lightmapUV;
                    #endif
                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                    #endif

                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                }

                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                {
                    result.positionCS = surfVertex.pos;
                    result.positionWS = surfVertex.worldPos;
                    result.normalWS = surfVertex.worldNormal;
                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                    // World Tangent isn't an available input on v2f_surf
                    result.shadowCoord = surfVertex._ShadowCoord;

                    #if UNITY_ANY_INSTANCING_ENABLED
                    #endif
                    #if UNITY_SHOULD_SAMPLE_SH
                    #if !defined(LIGHTMAP_ON)
                    result.sh = surfVertex.sh;
                    #endif
                    #endif
                    #if defined(LIGHTMAP_ON)
                    result.lightmapUV = surfVertex.lmap.xy;
                    #endif
                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                    #endif

                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                }

                // --------------------------------------------------
                // Main

                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

                ENDHLSL
                }
                Pass
                {
                    Name "BuiltIn ForwardAdd"
                    Tags
                    {
                        "LightMode" = "ForwardAdd"
                    }

                    // Render State
                    Blend SrcAlpha One
                    ZWrite Off
                    ColorMask RGB

                    // Debug
                    // <None>

                    // --------------------------------------------------
                    // Pass

                    HLSLPROGRAM

                    // Pragmas
                    #pragma target 3.0
                    #pragma multi_compile_instancing
                    #pragma multi_compile_fog
                    #pragma multi_compile_fwdadd_fullshadows
                    #pragma vertex vert
                    #pragma fragment frag

                    // Keywords
                    #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                    #pragma multi_compile _ LIGHTMAP_ON
                    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                    #pragma multi_compile _ _SHADOWS_SOFT
                    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                    #pragma multi_compile _ SHADOWS_SHADOWMASK
                    // GraphKeywords: <None>

                    // Defines
                    #define _NORMALMAP 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define ATTRIBUTES_NEED_TEXCOORD0
                    #define ATTRIBUTES_NEED_TEXCOORD1
                    #define VARYINGS_NEED_POSITION_WS
                    #define VARYINGS_NEED_NORMAL_WS
                    #define VARYINGS_NEED_TANGENT_WS
                    #define VARYINGS_NEED_TEXCOORD0
                    #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                    #define FEATURES_GRAPH_VERTEX
                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                    #define SHADERPASS SHADERPASS_FORWARD_ADD
                    #define BUILTIN_TARGET_API 1
                    #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                    #endif
                    #ifdef _BUILTIN_ALPHATEST_ON
                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                    #endif
                    #ifdef _BUILTIN_AlphaClip
                    #define _AlphaClip _BUILTIN_AlphaClip
                    #endif
                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                    #endif


                    // custom interpolator pre-include
                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                    // Includes
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                    // --------------------------------------------------
                    // Structs and Packing

                    // custom interpolators pre packing
                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                    struct Attributes
                    {
                         float3 positionOS : POSITION;
                         float3 normalOS : NORMAL;
                         float4 tangentOS : TANGENT;
                         float4 uv0 : TEXCOORD0;
                         float4 uv1 : TEXCOORD1;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : INSTANCEID_SEMANTIC;
                        #endif
                    };
                    struct Varyings
                    {
                         float4 positionCS : SV_POSITION;
                         float3 positionWS;
                         float3 normalWS;
                         float4 tangentWS;
                         float4 texCoord0;
                        #if defined(LIGHTMAP_ON)
                         float2 lightmapUV;
                        #endif
                        #if !defined(LIGHTMAP_ON)
                         float3 sh;
                        #endif
                         float4 fogFactorAndVertexLight;
                         float4 shadowCoord;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };
                    struct SurfaceDescriptionInputs
                    {
                         float3 TangentSpaceNormal;
                         float2 NDCPosition;
                         float2 PixelPosition;
                         float4 uv0;
                    };
                    struct VertexDescriptionInputs
                    {
                         float3 ObjectSpaceNormal;
                         float3 ObjectSpaceTangent;
                         float3 ObjectSpacePosition;
                    };
                    struct PackedVaryings
                    {
                         float4 positionCS : SV_POSITION;
                        #if defined(LIGHTMAP_ON)
                         float2 lightmapUV : INTERP0;
                        #endif
                        #if !defined(LIGHTMAP_ON)
                         float3 sh : INTERP1;
                        #endif
                         float4 tangentWS : INTERP2;
                         float4 texCoord0 : INTERP3;
                         float4 fogFactorAndVertexLight : INTERP4;
                         float4 shadowCoord : INTERP5;
                         float3 positionWS : INTERP6;
                         float3 normalWS : INTERP7;
                        #if UNITY_ANY_INSTANCING_ENABLED
                         uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };

                    PackedVaryings PackVaryings(Varyings input)
                    {
                        PackedVaryings output;
                        ZERO_INITIALIZE(PackedVaryings, output);
                        output.positionCS = input.positionCS;
                        #if defined(LIGHTMAP_ON)
                        output.lightmapUV = input.lightmapUV;
                        #endif
                        #if !defined(LIGHTMAP_ON)
                        output.sh = input.sh;
                        #endif
                        output.tangentWS.xyzw = input.tangentWS;
                        output.texCoord0.xyzw = input.texCoord0;
                        output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                        output.shadowCoord.xyzw = input.shadowCoord;
                        output.positionWS.xyz = input.positionWS;
                        output.normalWS.xyz = input.normalWS;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }

                    Varyings UnpackVaryings(PackedVaryings input)
                    {
                        Varyings output;
                        output.positionCS = input.positionCS;
                        #if defined(LIGHTMAP_ON)
                        output.lightmapUV = input.lightmapUV;
                        #endif
                        #if !defined(LIGHTMAP_ON)
                        output.sh = input.sh;
                        #endif
                        output.tangentWS = input.tangentWS.xyzw;
                        output.texCoord0 = input.texCoord0.xyzw;
                        output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                        output.shadowCoord = input.shadowCoord.xyzw;
                        output.positionWS = input.positionWS.xyz;
                        output.normalWS = input.normalWS.xyz;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }


                    // --------------------------------------------------
                    // Graph

                    // Graph Properties
                    CBUFFER_START(UnityPerMaterial)
                    float4 _Main_TexelSize;
                    float4 _Tint;
                    float2 _player_position;
                    float _Size;
                    float _smoothness;
                    float _opacity;
                    CBUFFER_END


                        // Object and Global properties
                        SAMPLER(SamplerState_Linear_Repeat);
                        TEXTURE2D(_Main);
                        SAMPLER(sampler_Main);

                        // -- Property used by ScenePickingPass
                        #ifdef SCENEPICKINGPASS
                        float4 _SelectionID;
                        #endif

                        // -- Properties used by SceneSelectionPass
                        #ifdef SCENESELECTIONPASS
                        int _ObjectId;
                        int _PassValue;
                        #endif

                        // Graph Includes
                        // GraphIncludes: <None>

                        // Graph Functions

                        void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                        {
                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                        }

                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A + B;
                        }

                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                        {
                            Out = UV * Tiling + Offset;
                        }

                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A - B;
                        }

                        void Unity_Divide_float(float A, float B, out float Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Multiply_float_float(float A, float B, out float Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Length_float2(float2 In, out float Out)
                        {
                            Out = length(In);
                        }

                        void Unity_OneMinus_float(float In, out float Out)
                        {
                            Out = 1 - In;
                        }

                        void Unity_Saturate_float(float In, out float Out)
                        {
                            Out = saturate(In);
                        }

                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                        {
                            Out = smoothstep(Edge1, Edge2, In);
                        }

                        // Custom interpolators pre vertex
                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                        // Graph Vertex
                        struct VertexDescription
                        {
                            float3 Position;
                            float3 Normal;
                            float3 Tangent;
                        };

                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                        {
                            VertexDescription description = (VertexDescription)0;
                            description.Position = IN.ObjectSpacePosition;
                            description.Normal = IN.ObjectSpaceNormal;
                            description.Tangent = IN.ObjectSpaceTangent;
                            return description;
                        }

                        // Custom interpolators, pre surface
                        #ifdef FEATURES_GRAPH_VERTEX
                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                        {
                        return output;
                        }
                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                        #endif

                        // Graph Pixel
                        struct SurfaceDescription
                        {
                            float3 BaseColor;
                            float3 NormalTS;
                            float3 Emission;
                            float Metallic;
                            float Smoothness;
                            float Occlusion;
                            float Alpha;
                        };

                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                        {
                            SurfaceDescription surface = (SurfaceDescription)0;
                            UnityTexture2D _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main);
                            float4 _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.tex, _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.samplerstate, _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                            float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_R_4_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.r;
                            float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_G_5_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.g;
                            float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_B_6_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.b;
                            float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_A_7_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.a;
                            float4 _Property_d45859c46c4c4ba69c23757dfed2e3c0_Out_0_Vector4 = _Tint;
                            float4 _Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4;
                            Unity_Multiply_float4_float4(_SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4, _Property_d45859c46c4c4ba69c23757dfed2e3c0_Out_0_Vector4, _Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4);
                            float _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float = _smoothness;
                            float4 _ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                            float2 _Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2 = _player_position;
                            float2 _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2;
                            Unity_Remap_float2(_Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2);
                            float2 _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2;
                            Unity_Add_float2((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2, _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2);
                            float2 _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2;
                            Unity_TilingAndOffset_float((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), float2 (1, 1), _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2, _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2);
                            float2 _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2;
                            Unity_Multiply_float2_float2(_TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2, float2(2, 2), _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2);
                            float2 _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2;
                            Unity_Subtract_float2(_Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2, float2(1, 1), _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2);
                            float _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float;
                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float);
                            float _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float = _Size;
                            float _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float;
                            Unity_Multiply_float_float(_Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float, _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float);
                            float2 _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2 = float2(_Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float);
                            float2 _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2;
                            Unity_Divide_float2(_Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2, _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2, _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2);
                            float _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float;
                            Unity_Length_float2(_Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2, _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float);
                            float _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float;
                            Unity_OneMinus_float(_Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float, _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float);
                            float _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float;
                            Unity_Saturate_float(_OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float);
                            float _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float;
                            Unity_Smoothstep_float(0, _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float, _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float);
                            float _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float = _opacity;
                            float _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float;
                            Unity_Multiply_float_float(_Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float, _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float, _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float);
                            float _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                            Unity_OneMinus_float(_Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float, _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float);
                            surface.BaseColor = (_Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4.xyz);
                            surface.NormalTS = IN.TangentSpaceNormal;
                            surface.Emission = float3(0, 0, 0);
                            surface.Metallic = 0;
                            surface.Smoothness = 0.5;
                            surface.Occlusion = 1;
                            surface.Alpha = _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                            return surface;
                        }

                        // --------------------------------------------------
                        // Build Graph Inputs

                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                        {
                            VertexDescriptionInputs output;
                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                            output.ObjectSpaceNormal = input.normalOS;
                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                            output.ObjectSpacePosition = input.positionOS;

                            return output;
                        }
                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                        {
                            SurfaceDescriptionInputs output;
                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                            #if UNITY_UV_STARTS_AT_TOP
                            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                            #else
                            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                            #endif

                            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
                            output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                            output.uv0 = input.texCoord0;
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                        #else
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                        #endif
                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                return output;
                        }

                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                        {
                            result.vertex = float4(attributes.positionOS, 1);
                            result.tangent = attributes.tangentOS;
                            result.normal = attributes.normalOS;
                            result.texcoord = attributes.uv0;
                            result.texcoord1 = attributes.uv1;
                            result.vertex = float4(vertexDescription.Position, 1);
                            result.normal = vertexDescription.Normal;
                            result.tangent = float4(vertexDescription.Tangent, 0);
                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                        }

                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                        {
                            result.pos = varyings.positionCS;
                            result.worldPos = varyings.positionWS;
                            result.worldNormal = varyings.normalWS;
                            // World Tangent isn't an available input on v2f_surf

                            result._ShadowCoord = varyings.shadowCoord;

                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                            #if UNITY_SHOULD_SAMPLE_SH
                            #if !defined(LIGHTMAP_ON)
                            result.sh = varyings.sh;
                            #endif
                            #endif
                            #if defined(LIGHTMAP_ON)
                            result.lmap.xy = varyings.lightmapUV;
                            #endif
                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                            #endif

                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                        }

                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                        {
                            result.positionCS = surfVertex.pos;
                            result.positionWS = surfVertex.worldPos;
                            result.normalWS = surfVertex.worldNormal;
                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                            // World Tangent isn't an available input on v2f_surf
                            result.shadowCoord = surfVertex._ShadowCoord;

                            #if UNITY_ANY_INSTANCING_ENABLED
                            #endif
                            #if UNITY_SHOULD_SAMPLE_SH
                            #if !defined(LIGHTMAP_ON)
                            result.sh = surfVertex.sh;
                            #endif
                            #endif
                            #if defined(LIGHTMAP_ON)
                            result.lightmapUV = surfVertex.lmap.xy;
                            #endif
                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                            #endif

                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                        }

                        // --------------------------------------------------
                        // Main

                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRForwardAddPass.hlsl"

                        ENDHLSL
                        }
                        Pass
                        {
                            Name "BuiltIn Deferred"
                            Tags
                            {
                                "LightMode" = "Deferred"
                            }

                            // Render State
                            Cull Back
                            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                            ZTest LEqual
                            ZWrite Off
                            ColorMask RGB

                            // Debug
                            // <None>

                            // --------------------------------------------------
                            // Pass

                            HLSLPROGRAM

                            // Pragmas
                            #pragma target 4.5
                            #pragma multi_compile_instancing
                            #pragma exclude_renderers nomrt
                            #pragma multi_compile_prepassfinal
                            #pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
                            #pragma vertex vert
                            #pragma fragment frag

                            // Keywords
                            #pragma multi_compile _ LIGHTMAP_ON
                            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
                            #pragma multi_compile _ _SHADOWS_SOFT
                            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                            #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                            // GraphKeywords: <None>

                            // Defines
                            #define _NORMALMAP 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define ATTRIBUTES_NEED_TEXCOORD0
                            #define ATTRIBUTES_NEED_TEXCOORD1
                            #define VARYINGS_NEED_POSITION_WS
                            #define VARYINGS_NEED_NORMAL_WS
                            #define VARYINGS_NEED_TANGENT_WS
                            #define VARYINGS_NEED_TEXCOORD0
                            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                            #define FEATURES_GRAPH_VERTEX
                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                            #define SHADERPASS SHADERPASS_DEFERRED
                            #define BUILTIN_TARGET_API 1
                            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                            #endif
                            #ifdef _BUILTIN_ALPHATEST_ON
                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                            #endif
                            #ifdef _BUILTIN_AlphaClip
                            #define _AlphaClip _BUILTIN_AlphaClip
                            #endif
                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                            #endif


                            // custom interpolator pre-include
                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                            // Includes
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                            // --------------------------------------------------
                            // Structs and Packing

                            // custom interpolators pre packing
                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                            struct Attributes
                            {
                                 float3 positionOS : POSITION;
                                 float3 normalOS : NORMAL;
                                 float4 tangentOS : TANGENT;
                                 float4 uv0 : TEXCOORD0;
                                 float4 uv1 : TEXCOORD1;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : INSTANCEID_SEMANTIC;
                                #endif
                            };
                            struct Varyings
                            {
                                 float4 positionCS : SV_POSITION;
                                 float3 positionWS;
                                 float3 normalWS;
                                 float4 tangentWS;
                                 float4 texCoord0;
                                #if defined(LIGHTMAP_ON)
                                 float2 lightmapUV;
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                 float3 sh;
                                #endif
                                 float4 fogFactorAndVertexLight;
                                 float4 shadowCoord;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };
                            struct SurfaceDescriptionInputs
                            {
                                 float3 TangentSpaceNormal;
                                 float2 NDCPosition;
                                 float2 PixelPosition;
                                 float4 uv0;
                            };
                            struct VertexDescriptionInputs
                            {
                                 float3 ObjectSpaceNormal;
                                 float3 ObjectSpaceTangent;
                                 float3 ObjectSpacePosition;
                            };
                            struct PackedVaryings
                            {
                                 float4 positionCS : SV_POSITION;
                                #if defined(LIGHTMAP_ON)
                                 float2 lightmapUV : INTERP0;
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                 float3 sh : INTERP1;
                                #endif
                                 float4 tangentWS : INTERP2;
                                 float4 texCoord0 : INTERP3;
                                 float4 fogFactorAndVertexLight : INTERP4;
                                 float4 shadowCoord : INTERP5;
                                 float3 positionWS : INTERP6;
                                 float3 normalWS : INTERP7;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };

                            PackedVaryings PackVaryings(Varyings input)
                            {
                                PackedVaryings output;
                                ZERO_INITIALIZE(PackedVaryings, output);
                                output.positionCS = input.positionCS;
                                #if defined(LIGHTMAP_ON)
                                output.lightmapUV = input.lightmapUV;
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                output.sh = input.sh;
                                #endif
                                output.tangentWS.xyzw = input.tangentWS;
                                output.texCoord0.xyzw = input.texCoord0;
                                output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                                output.shadowCoord.xyzw = input.shadowCoord;
                                output.positionWS.xyz = input.positionWS;
                                output.normalWS.xyz = input.normalWS;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }

                            Varyings UnpackVaryings(PackedVaryings input)
                            {
                                Varyings output;
                                output.positionCS = input.positionCS;
                                #if defined(LIGHTMAP_ON)
                                output.lightmapUV = input.lightmapUV;
                                #endif
                                #if !defined(LIGHTMAP_ON)
                                output.sh = input.sh;
                                #endif
                                output.tangentWS = input.tangentWS.xyzw;
                                output.texCoord0 = input.texCoord0.xyzw;
                                output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                                output.shadowCoord = input.shadowCoord.xyzw;
                                output.positionWS = input.positionWS.xyz;
                                output.normalWS = input.normalWS.xyz;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }


                            // --------------------------------------------------
                            // Graph

                            // Graph Properties
                            CBUFFER_START(UnityPerMaterial)
                            float4 _Main_TexelSize;
                            float4 _Tint;
                            float2 _player_position;
                            float _Size;
                            float _smoothness;
                            float _opacity;
                            CBUFFER_END


                                // Object and Global properties
                                SAMPLER(SamplerState_Linear_Repeat);
                                TEXTURE2D(_Main);
                                SAMPLER(sampler_Main);

                                // -- Property used by ScenePickingPass
                                #ifdef SCENEPICKINGPASS
                                float4 _SelectionID;
                                #endif

                                // -- Properties used by SceneSelectionPass
                                #ifdef SCENESELECTIONPASS
                                int _ObjectId;
                                int _PassValue;
                                #endif

                                // Graph Includes
                                // GraphIncludes: <None>

                                // Graph Functions

                                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                {
                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                }

                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A + B;
                                }

                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                {
                                    Out = UV * Tiling + Offset;
                                }

                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A - B;
                                }

                                void Unity_Divide_float(float A, float B, out float Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Length_float2(float2 In, out float Out)
                                {
                                    Out = length(In);
                                }

                                void Unity_OneMinus_float(float In, out float Out)
                                {
                                    Out = 1 - In;
                                }

                                void Unity_Saturate_float(float In, out float Out)
                                {
                                    Out = saturate(In);
                                }

                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                {
                                    Out = smoothstep(Edge1, Edge2, In);
                                }

                                // Custom interpolators pre vertex
                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                // Graph Vertex
                                struct VertexDescription
                                {
                                    float3 Position;
                                    float3 Normal;
                                    float3 Tangent;
                                };

                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                {
                                    VertexDescription description = (VertexDescription)0;
                                    description.Position = IN.ObjectSpacePosition;
                                    description.Normal = IN.ObjectSpaceNormal;
                                    description.Tangent = IN.ObjectSpaceTangent;
                                    return description;
                                }

                                // Custom interpolators, pre surface
                                #ifdef FEATURES_GRAPH_VERTEX
                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                {
                                return output;
                                }
                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                #endif

                                // Graph Pixel
                                struct SurfaceDescription
                                {
                                    float3 BaseColor;
                                    float3 NormalTS;
                                    float3 Emission;
                                    float Metallic;
                                    float Smoothness;
                                    float Occlusion;
                                    float Alpha;
                                };

                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                {
                                    SurfaceDescription surface = (SurfaceDescription)0;
                                    UnityTexture2D _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main);
                                    float4 _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.tex, _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.samplerstate, _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_R_4_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.r;
                                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_G_5_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.g;
                                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_B_6_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.b;
                                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_A_7_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.a;
                                    float4 _Property_d45859c46c4c4ba69c23757dfed2e3c0_Out_0_Vector4 = _Tint;
                                    float4 _Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4;
                                    Unity_Multiply_float4_float4(_SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4, _Property_d45859c46c4c4ba69c23757dfed2e3c0_Out_0_Vector4, _Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4);
                                    float _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float = _smoothness;
                                    float4 _ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                                    float2 _Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2 = _player_position;
                                    float2 _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2;
                                    Unity_Remap_float2(_Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2);
                                    float2 _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2;
                                    Unity_Add_float2((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2, _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2);
                                    float2 _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2;
                                    Unity_TilingAndOffset_float((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), float2 (1, 1), _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2, _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2);
                                    float2 _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2;
                                    Unity_Multiply_float2_float2(_TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2, float2(2, 2), _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2);
                                    float2 _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2;
                                    Unity_Subtract_float2(_Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2, float2(1, 1), _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2);
                                    float _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float;
                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float);
                                    float _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float = _Size;
                                    float _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float;
                                    Unity_Multiply_float_float(_Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float, _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float);
                                    float2 _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2 = float2(_Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float);
                                    float2 _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2;
                                    Unity_Divide_float2(_Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2, _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2, _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2);
                                    float _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float;
                                    Unity_Length_float2(_Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2, _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float);
                                    float _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float;
                                    Unity_OneMinus_float(_Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float, _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float);
                                    float _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float;
                                    Unity_Saturate_float(_OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float);
                                    float _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float;
                                    Unity_Smoothstep_float(0, _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float, _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float);
                                    float _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float = _opacity;
                                    float _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float;
                                    Unity_Multiply_float_float(_Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float, _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float, _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float);
                                    float _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                    Unity_OneMinus_float(_Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float, _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float);
                                    surface.BaseColor = (_Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4.xyz);
                                    surface.NormalTS = IN.TangentSpaceNormal;
                                    surface.Emission = float3(0, 0, 0);
                                    surface.Metallic = 0;
                                    surface.Smoothness = 0.5;
                                    surface.Occlusion = 1;
                                    surface.Alpha = _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                    return surface;
                                }

                                // --------------------------------------------------
                                // Build Graph Inputs

                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                {
                                    VertexDescriptionInputs output;
                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                    output.ObjectSpaceNormal = input.normalOS;
                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                    output.ObjectSpacePosition = input.positionOS;

                                    return output;
                                }
                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                {
                                    SurfaceDescriptionInputs output;
                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);



                                    #if UNITY_UV_STARTS_AT_TOP
                                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                    #else
                                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                    #endif

                                    output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
                                    output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                                    output.uv0 = input.texCoord0;
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                #else
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                #endif
                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                        return output;
                                }

                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                {
                                    result.vertex = float4(attributes.positionOS, 1);
                                    result.tangent = attributes.tangentOS;
                                    result.normal = attributes.normalOS;
                                    result.texcoord = attributes.uv0;
                                    result.texcoord1 = attributes.uv1;
                                    result.vertex = float4(vertexDescription.Position, 1);
                                    result.normal = vertexDescription.Normal;
                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                }

                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                {
                                    result.pos = varyings.positionCS;
                                    result.worldPos = varyings.positionWS;
                                    result.worldNormal = varyings.normalWS;
                                    // World Tangent isn't an available input on v2f_surf

                                    result._ShadowCoord = varyings.shadowCoord;

                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                    #if UNITY_SHOULD_SAMPLE_SH
                                    #if !defined(LIGHTMAP_ON)
                                    result.sh = varyings.sh;
                                    #endif
                                    #endif
                                    #if defined(LIGHTMAP_ON)
                                    result.lmap.xy = varyings.lightmapUV;
                                    #endif
                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                    #endif

                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                }

                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                {
                                    result.positionCS = surfVertex.pos;
                                    result.positionWS = surfVertex.worldPos;
                                    result.normalWS = surfVertex.worldNormal;
                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                    // World Tangent isn't an available input on v2f_surf
                                    result.shadowCoord = surfVertex._ShadowCoord;

                                    #if UNITY_ANY_INSTANCING_ENABLED
                                    #endif
                                    #if UNITY_SHOULD_SAMPLE_SH
                                    #if !defined(LIGHTMAP_ON)
                                    result.sh = surfVertex.sh;
                                    #endif
                                    #endif
                                    #if defined(LIGHTMAP_ON)
                                    result.lightmapUV = surfVertex.lmap.xy;
                                    #endif
                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                    #endif

                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                }

                                // --------------------------------------------------
                                // Main

                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/PBRDeferredPass.hlsl"

                                ENDHLSL
                                }
                                Pass
                                {
                                    Name "ShadowCaster"
                                    Tags
                                    {
                                        "LightMode" = "ShadowCaster"
                                    }

                                    // Render State
                                    Cull Back
                                    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                    ZTest LEqual
                                    ZWrite On
                                    ColorMask 0

                                    // Debug
                                    // <None>

                                    // --------------------------------------------------
                                    // Pass

                                    HLSLPROGRAM

                                    // Pragmas
                                    #pragma target 3.0
                                    #pragma multi_compile_shadowcaster
                                    #pragma vertex vert
                                    #pragma fragment frag

                                    // Keywords
                                    #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
                                    // GraphKeywords: <None>

                                    // Defines
                                    #define _NORMALMAP 1
                                    #define _NORMAL_DROPOFF_TS 1
                                    #define ATTRIBUTES_NEED_NORMAL
                                    #define ATTRIBUTES_NEED_TANGENT
                                    #define FEATURES_GRAPH_VERTEX
                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                    #define SHADERPASS SHADERPASS_SHADOWCASTER
                                    #define BUILTIN_TARGET_API 1
                                    #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                    #endif
                                    #ifdef _BUILTIN_ALPHATEST_ON
                                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                    #endif
                                    #ifdef _BUILTIN_AlphaClip
                                    #define _AlphaClip _BUILTIN_AlphaClip
                                    #endif
                                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                    #endif


                                    // custom interpolator pre-include
                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                    // Includes
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                    // --------------------------------------------------
                                    // Structs and Packing

                                    // custom interpolators pre packing
                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                    struct Attributes
                                    {
                                         float3 positionOS : POSITION;
                                         float3 normalOS : NORMAL;
                                         float4 tangentOS : TANGENT;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : INSTANCEID_SEMANTIC;
                                        #endif
                                    };
                                    struct Varyings
                                    {
                                         float4 positionCS : SV_POSITION;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                        #endif
                                    };
                                    struct SurfaceDescriptionInputs
                                    {
                                         float2 NDCPosition;
                                         float2 PixelPosition;
                                    };
                                    struct VertexDescriptionInputs
                                    {
                                         float3 ObjectSpaceNormal;
                                         float3 ObjectSpaceTangent;
                                         float3 ObjectSpacePosition;
                                    };
                                    struct PackedVaryings
                                    {
                                         float4 positionCS : SV_POSITION;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                        #endif
                                    };

                                    PackedVaryings PackVaryings(Varyings input)
                                    {
                                        PackedVaryings output;
                                        ZERO_INITIALIZE(PackedVaryings, output);
                                        output.positionCS = input.positionCS;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        output.instanceID = input.instanceID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        output.cullFace = input.cullFace;
                                        #endif
                                        return output;
                                    }

                                    Varyings UnpackVaryings(PackedVaryings input)
                                    {
                                        Varyings output;
                                        output.positionCS = input.positionCS;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        output.instanceID = input.instanceID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        output.cullFace = input.cullFace;
                                        #endif
                                        return output;
                                    }


                                    // --------------------------------------------------
                                    // Graph

                                    // Graph Properties
                                    CBUFFER_START(UnityPerMaterial)
                                    float4 _Main_TexelSize;
                                    float4 _Tint;
                                    float2 _player_position;
                                    float _Size;
                                    float _smoothness;
                                    float _opacity;
                                    CBUFFER_END


                                        // Object and Global properties
                                        SAMPLER(SamplerState_Linear_Repeat);
                                        TEXTURE2D(_Main);
                                        SAMPLER(sampler_Main);

                                        // -- Property used by ScenePickingPass
                                        #ifdef SCENEPICKINGPASS
                                        float4 _SelectionID;
                                        #endif

                                        // -- Properties used by SceneSelectionPass
                                        #ifdef SCENESELECTIONPASS
                                        int _ObjectId;
                                        int _PassValue;
                                        #endif

                                        // Graph Includes
                                        // GraphIncludes: <None>

                                        // Graph Functions

                                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                        {
                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                        }

                                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A + B;
                                        }

                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                        {
                                            Out = UV * Tiling + Offset;
                                        }

                                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A - B;
                                        }

                                        void Unity_Divide_float(float A, float B, out float Out)
                                        {
                                            Out = A / B;
                                        }

                                        void Unity_Multiply_float_float(float A, float B, out float Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A / B;
                                        }

                                        void Unity_Length_float2(float2 In, out float Out)
                                        {
                                            Out = length(In);
                                        }

                                        void Unity_OneMinus_float(float In, out float Out)
                                        {
                                            Out = 1 - In;
                                        }

                                        void Unity_Saturate_float(float In, out float Out)
                                        {
                                            Out = saturate(In);
                                        }

                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                        {
                                            Out = smoothstep(Edge1, Edge2, In);
                                        }

                                        // Custom interpolators pre vertex
                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                        // Graph Vertex
                                        struct VertexDescription
                                        {
                                            float3 Position;
                                            float3 Normal;
                                            float3 Tangent;
                                        };

                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                        {
                                            VertexDescription description = (VertexDescription)0;
                                            description.Position = IN.ObjectSpacePosition;
                                            description.Normal = IN.ObjectSpaceNormal;
                                            description.Tangent = IN.ObjectSpaceTangent;
                                            return description;
                                        }

                                        // Custom interpolators, pre surface
                                        #ifdef FEATURES_GRAPH_VERTEX
                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                        {
                                        return output;
                                        }
                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                        #endif

                                        // Graph Pixel
                                        struct SurfaceDescription
                                        {
                                            float Alpha;
                                        };

                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                        {
                                            SurfaceDescription surface = (SurfaceDescription)0;
                                            float _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float = _smoothness;
                                            float4 _ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                                            float2 _Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2 = _player_position;
                                            float2 _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2;
                                            Unity_Remap_float2(_Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2);
                                            float2 _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2;
                                            Unity_Add_float2((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2, _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2);
                                            float2 _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2;
                                            Unity_TilingAndOffset_float((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), float2 (1, 1), _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2, _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2);
                                            float2 _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2;
                                            Unity_Multiply_float2_float2(_TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2, float2(2, 2), _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2);
                                            float2 _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2;
                                            Unity_Subtract_float2(_Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2, float2(1, 1), _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2);
                                            float _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float;
                                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float);
                                            float _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float = _Size;
                                            float _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float;
                                            Unity_Multiply_float_float(_Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float, _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float);
                                            float2 _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2 = float2(_Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float);
                                            float2 _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2;
                                            Unity_Divide_float2(_Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2, _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2, _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2);
                                            float _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float;
                                            Unity_Length_float2(_Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2, _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float);
                                            float _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float;
                                            Unity_OneMinus_float(_Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float, _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float);
                                            float _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float;
                                            Unity_Saturate_float(_OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float);
                                            float _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float;
                                            Unity_Smoothstep_float(0, _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float, _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float);
                                            float _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float = _opacity;
                                            float _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float;
                                            Unity_Multiply_float_float(_Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float, _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float, _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float);
                                            float _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                            Unity_OneMinus_float(_Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float, _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float);
                                            surface.Alpha = _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                            return surface;
                                        }

                                        // --------------------------------------------------
                                        // Build Graph Inputs

                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                        {
                                            VertexDescriptionInputs output;
                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                            output.ObjectSpaceNormal = input.normalOS;
                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                            output.ObjectSpacePosition = input.positionOS;

                                            return output;
                                        }
                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                        {
                                            SurfaceDescriptionInputs output;
                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);








                                            #if UNITY_UV_STARTS_AT_TOP
                                            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                            #else
                                            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                            #endif

                                            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
                                            output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                        #else
                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                        #endif
                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                return output;
                                        }

                                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                        {
                                            result.vertex = float4(attributes.positionOS, 1);
                                            result.tangent = attributes.tangentOS;
                                            result.normal = attributes.normalOS;
                                            result.vertex = float4(vertexDescription.Position, 1);
                                            result.normal = vertexDescription.Normal;
                                            result.tangent = float4(vertexDescription.Tangent, 0);
                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            #endif
                                        }

                                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                        {
                                            result.pos = varyings.positionCS;
                                            // World Tangent isn't an available input on v2f_surf


                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            #endif
                                            #if UNITY_SHOULD_SAMPLE_SH
                                            #if !defined(LIGHTMAP_ON)
                                            #endif
                                            #endif
                                            #if defined(LIGHTMAP_ON)
                                            #endif
                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                            #endif

                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                        }

                                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                        {
                                            result.positionCS = surfVertex.pos;
                                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                            // World Tangent isn't an available input on v2f_surf

                                            #if UNITY_ANY_INSTANCING_ENABLED
                                            #endif
                                            #if UNITY_SHOULD_SAMPLE_SH
                                            #if !defined(LIGHTMAP_ON)
                                            #endif
                                            #endif
                                            #if defined(LIGHTMAP_ON)
                                            #endif
                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                            #endif

                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                        }

                                        // --------------------------------------------------
                                        // Main

                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                                        ENDHLSL
                                        }
                                        Pass
                                        {
                                            Name "Meta"
                                            Tags
                                            {
                                                "LightMode" = "Meta"
                                            }

                                            // Render State
                                            Cull Off

                                            // Debug
                                            // <None>

                                            // --------------------------------------------------
                                            // Pass

                                            HLSLPROGRAM

                                            // Pragmas
                                            #pragma target 3.0
                                            #pragma vertex vert
                                            #pragma fragment frag

                                            // Keywords
                                            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                                            // GraphKeywords: <None>

                                            // Defines
                                            #define _NORMALMAP 1
                                            #define _NORMAL_DROPOFF_TS 1
                                            #define ATTRIBUTES_NEED_NORMAL
                                            #define ATTRIBUTES_NEED_TANGENT
                                            #define ATTRIBUTES_NEED_TEXCOORD0
                                            #define ATTRIBUTES_NEED_TEXCOORD1
                                            #define ATTRIBUTES_NEED_TEXCOORD2
                                            #define VARYINGS_NEED_TEXCOORD0
                                            #define FEATURES_GRAPH_VERTEX
                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                            #define SHADERPASS SHADERPASS_META
                                            #define BUILTIN_TARGET_API 1
                                            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                            #endif
                                            #ifdef _BUILTIN_ALPHATEST_ON
                                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                            #endif
                                            #ifdef _BUILTIN_AlphaClip
                                            #define _AlphaClip _BUILTIN_AlphaClip
                                            #endif
                                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                            #endif


                                            // custom interpolator pre-include
                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                            // Includes
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                            // --------------------------------------------------
                                            // Structs and Packing

                                            // custom interpolators pre packing
                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                            struct Attributes
                                            {
                                                 float3 positionOS : POSITION;
                                                 float3 normalOS : NORMAL;
                                                 float4 tangentOS : TANGENT;
                                                 float4 uv0 : TEXCOORD0;
                                                 float4 uv1 : TEXCOORD1;
                                                 float4 uv2 : TEXCOORD2;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                #endif
                                            };
                                            struct Varyings
                                            {
                                                 float4 positionCS : SV_POSITION;
                                                 float4 texCoord0;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                #endif
                                            };
                                            struct SurfaceDescriptionInputs
                                            {
                                                 float2 NDCPosition;
                                                 float2 PixelPosition;
                                                 float4 uv0;
                                            };
                                            struct VertexDescriptionInputs
                                            {
                                                 float3 ObjectSpaceNormal;
                                                 float3 ObjectSpaceTangent;
                                                 float3 ObjectSpacePosition;
                                            };
                                            struct PackedVaryings
                                            {
                                                 float4 positionCS : SV_POSITION;
                                                 float4 texCoord0 : INTERP0;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                #endif
                                            };

                                            PackedVaryings PackVaryings(Varyings input)
                                            {
                                                PackedVaryings output;
                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                output.positionCS = input.positionCS;
                                                output.texCoord0.xyzw = input.texCoord0;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                output.instanceID = input.instanceID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                output.cullFace = input.cullFace;
                                                #endif
                                                return output;
                                            }

                                            Varyings UnpackVaryings(PackedVaryings input)
                                            {
                                                Varyings output;
                                                output.positionCS = input.positionCS;
                                                output.texCoord0 = input.texCoord0.xyzw;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                output.instanceID = input.instanceID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                output.cullFace = input.cullFace;
                                                #endif
                                                return output;
                                            }


                                            // --------------------------------------------------
                                            // Graph

                                            // Graph Properties
                                            CBUFFER_START(UnityPerMaterial)
                                            float4 _Main_TexelSize;
                                            float4 _Tint;
                                            float2 _player_position;
                                            float _Size;
                                            float _smoothness;
                                            float _opacity;
                                            CBUFFER_END


                                                // Object and Global properties
                                                SAMPLER(SamplerState_Linear_Repeat);
                                                TEXTURE2D(_Main);
                                                SAMPLER(sampler_Main);

                                                // -- Property used by ScenePickingPass
                                                #ifdef SCENEPICKINGPASS
                                                float4 _SelectionID;
                                                #endif

                                                // -- Properties used by SceneSelectionPass
                                                #ifdef SCENESELECTIONPASS
                                                int _ObjectId;
                                                int _PassValue;
                                                #endif

                                                // Graph Includes
                                                // GraphIncludes: <None>

                                                // Graph Functions

                                                void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                {
                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                }

                                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A + B;
                                                }

                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                {
                                                    Out = UV * Tiling + Offset;
                                                }

                                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A - B;
                                                }

                                                void Unity_Divide_float(float A, float B, out float Out)
                                                {
                                                    Out = A / B;
                                                }

                                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A / B;
                                                }

                                                void Unity_Length_float2(float2 In, out float Out)
                                                {
                                                    Out = length(In);
                                                }

                                                void Unity_OneMinus_float(float In, out float Out)
                                                {
                                                    Out = 1 - In;
                                                }

                                                void Unity_Saturate_float(float In, out float Out)
                                                {
                                                    Out = saturate(In);
                                                }

                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                {
                                                    Out = smoothstep(Edge1, Edge2, In);
                                                }

                                                // Custom interpolators pre vertex
                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                // Graph Vertex
                                                struct VertexDescription
                                                {
                                                    float3 Position;
                                                    float3 Normal;
                                                    float3 Tangent;
                                                };

                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                {
                                                    VertexDescription description = (VertexDescription)0;
                                                    description.Position = IN.ObjectSpacePosition;
                                                    description.Normal = IN.ObjectSpaceNormal;
                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                    return description;
                                                }

                                                // Custom interpolators, pre surface
                                                #ifdef FEATURES_GRAPH_VERTEX
                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                {
                                                return output;
                                                }
                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                #endif

                                                // Graph Pixel
                                                struct SurfaceDescription
                                                {
                                                    float3 BaseColor;
                                                    float3 Emission;
                                                    float Alpha;
                                                };

                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                {
                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                    UnityTexture2D _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D = UnityBuildTexture2DStructNoScale(_Main);
                                                    float4 _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4 = SAMPLE_TEXTURE2D(_Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.tex, _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.samplerstate, _Property_af6a9c78b2e34d92b828d01d57d4d07e_Out_0_Texture2D.GetTransformedUV(IN.uv0.xy));
                                                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_R_4_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.r;
                                                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_G_5_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.g;
                                                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_B_6_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.b;
                                                    float _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_A_7_Float = _SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4.a;
                                                    float4 _Property_d45859c46c4c4ba69c23757dfed2e3c0_Out_0_Vector4 = _Tint;
                                                    float4 _Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4;
                                                    Unity_Multiply_float4_float4(_SampleTexture2D_525c2f69da274f4eb2a1ecd1e8502065_RGBA_0_Vector4, _Property_d45859c46c4c4ba69c23757dfed2e3c0_Out_0_Vector4, _Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4);
                                                    float _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float = _smoothness;
                                                    float4 _ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                                                    float2 _Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2 = _player_position;
                                                    float2 _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2;
                                                    Unity_Remap_float2(_Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2);
                                                    float2 _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2;
                                                    Unity_Add_float2((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2, _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2);
                                                    float2 _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2;
                                                    Unity_TilingAndOffset_float((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), float2 (1, 1), _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2, _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2);
                                                    float2 _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2;
                                                    Unity_Multiply_float2_float2(_TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2, float2(2, 2), _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2);
                                                    float2 _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2;
                                                    Unity_Subtract_float2(_Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2, float2(1, 1), _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2);
                                                    float _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float;
                                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float);
                                                    float _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float = _Size;
                                                    float _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float;
                                                    Unity_Multiply_float_float(_Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float, _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float);
                                                    float2 _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2 = float2(_Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float);
                                                    float2 _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2;
                                                    Unity_Divide_float2(_Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2, _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2, _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2);
                                                    float _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float;
                                                    Unity_Length_float2(_Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2, _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float);
                                                    float _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float;
                                                    Unity_OneMinus_float(_Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float, _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float);
                                                    float _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float;
                                                    Unity_Saturate_float(_OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float);
                                                    float _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float;
                                                    Unity_Smoothstep_float(0, _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float, _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float);
                                                    float _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float = _opacity;
                                                    float _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float;
                                                    Unity_Multiply_float_float(_Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float, _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float, _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float);
                                                    float _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                                    Unity_OneMinus_float(_Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float, _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float);
                                                    surface.BaseColor = (_Multiply_603a7377116b4136bb5126949c3e4e6c_Out_2_Vector4.xyz);
                                                    surface.Emission = float3(0, 0, 0);
                                                    surface.Alpha = _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                                    return surface;
                                                }

                                                // --------------------------------------------------
                                                // Build Graph Inputs

                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                {
                                                    VertexDescriptionInputs output;
                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                    output.ObjectSpaceNormal = input.normalOS;
                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                    output.ObjectSpacePosition = input.positionOS;

                                                    return output;
                                                }
                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                {
                                                    SurfaceDescriptionInputs output;
                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);








                                                    #if UNITY_UV_STARTS_AT_TOP
                                                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                    #else
                                                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                    #endif

                                                    output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
                                                    output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                                                    output.uv0 = input.texCoord0;
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                #else
                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                #endif
                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                        return output;
                                                }

                                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                {
                                                    result.vertex = float4(attributes.positionOS, 1);
                                                    result.tangent = attributes.tangentOS;
                                                    result.normal = attributes.normalOS;
                                                    result.texcoord = attributes.uv0;
                                                    result.texcoord1 = attributes.uv1;
                                                    result.texcoord2 = attributes.uv2;
                                                    result.vertex = float4(vertexDescription.Position, 1);
                                                    result.normal = vertexDescription.Normal;
                                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    #endif
                                                }

                                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                {
                                                    result.pos = varyings.positionCS;
                                                    // World Tangent isn't an available input on v2f_surf


                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    #endif
                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                    #if !defined(LIGHTMAP_ON)
                                                    #endif
                                                    #endif
                                                    #if defined(LIGHTMAP_ON)
                                                    #endif
                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                    #endif

                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                }

                                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                {
                                                    result.positionCS = surfVertex.pos;
                                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                    // World Tangent isn't an available input on v2f_surf

                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                    #endif
                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                    #if !defined(LIGHTMAP_ON)
                                                    #endif
                                                    #endif
                                                    #if defined(LIGHTMAP_ON)
                                                    #endif
                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                    #endif

                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                }

                                                // --------------------------------------------------
                                                // Main

                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                                ENDHLSL
                                                }
                                                Pass
                                                {
                                                    Name "SceneSelectionPass"
                                                    Tags
                                                    {
                                                        "LightMode" = "SceneSelectionPass"
                                                    }

                                                    // Render State
                                                    Cull Off

                                                    // Debug
                                                    // <None>

                                                    // --------------------------------------------------
                                                    // Pass

                                                    HLSLPROGRAM

                                                    // Pragmas
                                                    #pragma target 3.0
                                                    #pragma multi_compile_instancing
                                                    #pragma vertex vert
                                                    #pragma fragment frag

                                                    // Keywords
                                                    // PassKeywords: <None>
                                                    // GraphKeywords: <None>

                                                    // Defines
                                                    #define _NORMALMAP 1
                                                    #define _NORMAL_DROPOFF_TS 1
                                                    #define ATTRIBUTES_NEED_NORMAL
                                                    #define ATTRIBUTES_NEED_TANGENT
                                                    #define FEATURES_GRAPH_VERTEX
                                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                    #define SHADERPASS SceneSelectionPass
                                                    #define BUILTIN_TARGET_API 1
                                                    #define SCENESELECTIONPASS 1
                                                    #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                    #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                    #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                    #endif
                                                    #ifdef _BUILTIN_ALPHATEST_ON
                                                    #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                    #endif
                                                    #ifdef _BUILTIN_AlphaClip
                                                    #define _AlphaClip _BUILTIN_AlphaClip
                                                    #endif
                                                    #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                    #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                    #endif


                                                    // custom interpolator pre-include
                                                    /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                    // Includes
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                    #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                    // --------------------------------------------------
                                                    // Structs and Packing

                                                    // custom interpolators pre packing
                                                    /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                    struct Attributes
                                                    {
                                                         float3 positionOS : POSITION;
                                                         float3 normalOS : NORMAL;
                                                         float4 tangentOS : TANGENT;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : INSTANCEID_SEMANTIC;
                                                        #endif
                                                    };
                                                    struct Varyings
                                                    {
                                                         float4 positionCS : SV_POSITION;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                        #endif
                                                    };
                                                    struct SurfaceDescriptionInputs
                                                    {
                                                         float2 NDCPosition;
                                                         float2 PixelPosition;
                                                    };
                                                    struct VertexDescriptionInputs
                                                    {
                                                         float3 ObjectSpaceNormal;
                                                         float3 ObjectSpaceTangent;
                                                         float3 ObjectSpacePosition;
                                                    };
                                                    struct PackedVaryings
                                                    {
                                                         float4 positionCS : SV_POSITION;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                         uint instanceID : CUSTOM_INSTANCE_ID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                        #endif
                                                    };

                                                    PackedVaryings PackVaryings(Varyings input)
                                                    {
                                                        PackedVaryings output;
                                                        ZERO_INITIALIZE(PackedVaryings, output);
                                                        output.positionCS = input.positionCS;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                        output.instanceID = input.instanceID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        output.cullFace = input.cullFace;
                                                        #endif
                                                        return output;
                                                    }

                                                    Varyings UnpackVaryings(PackedVaryings input)
                                                    {
                                                        Varyings output;
                                                        output.positionCS = input.positionCS;
                                                        #if UNITY_ANY_INSTANCING_ENABLED
                                                        output.instanceID = input.instanceID;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                        #endif
                                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                        #endif
                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        output.cullFace = input.cullFace;
                                                        #endif
                                                        return output;
                                                    }


                                                    // --------------------------------------------------
                                                    // Graph

                                                    // Graph Properties
                                                    CBUFFER_START(UnityPerMaterial)
                                                    float4 _Main_TexelSize;
                                                    float4 _Tint;
                                                    float2 _player_position;
                                                    float _Size;
                                                    float _smoothness;
                                                    float _opacity;
                                                    CBUFFER_END


                                                        // Object and Global properties
                                                        SAMPLER(SamplerState_Linear_Repeat);
                                                        TEXTURE2D(_Main);
                                                        SAMPLER(sampler_Main);

                                                        // -- Property used by ScenePickingPass
                                                        #ifdef SCENEPICKINGPASS
                                                        float4 _SelectionID;
                                                        #endif

                                                        // -- Properties used by SceneSelectionPass
                                                        #ifdef SCENESELECTIONPASS
                                                        int _ObjectId;
                                                        int _PassValue;
                                                        #endif

                                                        // Graph Includes
                                                        // GraphIncludes: <None>

                                                        // Graph Functions

                                                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                        {
                                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                        }

                                                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A + B;
                                                        }

                                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                        {
                                                            Out = UV * Tiling + Offset;
                                                        }

                                                        void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A - B;
                                                        }

                                                        void Unity_Divide_float(float A, float B, out float Out)
                                                        {
                                                            Out = A / B;
                                                        }

                                                        void Unity_Multiply_float_float(float A, float B, out float Out)
                                                        {
                                                            Out = A * B;
                                                        }

                                                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                        {
                                                            Out = A / B;
                                                        }

                                                        void Unity_Length_float2(float2 In, out float Out)
                                                        {
                                                            Out = length(In);
                                                        }

                                                        void Unity_OneMinus_float(float In, out float Out)
                                                        {
                                                            Out = 1 - In;
                                                        }

                                                        void Unity_Saturate_float(float In, out float Out)
                                                        {
                                                            Out = saturate(In);
                                                        }

                                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                        {
                                                            Out = smoothstep(Edge1, Edge2, In);
                                                        }

                                                        // Custom interpolators pre vertex
                                                        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                        // Graph Vertex
                                                        struct VertexDescription
                                                        {
                                                            float3 Position;
                                                            float3 Normal;
                                                            float3 Tangent;
                                                        };

                                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                        {
                                                            VertexDescription description = (VertexDescription)0;
                                                            description.Position = IN.ObjectSpacePosition;
                                                            description.Normal = IN.ObjectSpaceNormal;
                                                            description.Tangent = IN.ObjectSpaceTangent;
                                                            return description;
                                                        }

                                                        // Custom interpolators, pre surface
                                                        #ifdef FEATURES_GRAPH_VERTEX
                                                        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                        {
                                                        return output;
                                                        }
                                                        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                        #endif

                                                        // Graph Pixel
                                                        struct SurfaceDescription
                                                        {
                                                            float Alpha;
                                                        };

                                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                        {
                                                            SurfaceDescription surface = (SurfaceDescription)0;
                                                            float _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float = _smoothness;
                                                            float4 _ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                                                            float2 _Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2 = _player_position;
                                                            float2 _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2;
                                                            Unity_Remap_float2(_Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2);
                                                            float2 _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2;
                                                            Unity_Add_float2((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2, _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2);
                                                            float2 _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2;
                                                            Unity_TilingAndOffset_float((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), float2 (1, 1), _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2, _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2);
                                                            float2 _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2;
                                                            Unity_Multiply_float2_float2(_TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2, float2(2, 2), _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2);
                                                            float2 _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2;
                                                            Unity_Subtract_float2(_Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2, float2(1, 1), _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2);
                                                            float _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float;
                                                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float);
                                                            float _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float = _Size;
                                                            float _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float;
                                                            Unity_Multiply_float_float(_Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float, _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float);
                                                            float2 _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2 = float2(_Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float);
                                                            float2 _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2;
                                                            Unity_Divide_float2(_Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2, _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2, _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2);
                                                            float _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float;
                                                            Unity_Length_float2(_Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2, _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float);
                                                            float _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float;
                                                            Unity_OneMinus_float(_Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float, _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float);
                                                            float _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float;
                                                            Unity_Saturate_float(_OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float);
                                                            float _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float;
                                                            Unity_Smoothstep_float(0, _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float, _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float);
                                                            float _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float = _opacity;
                                                            float _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float;
                                                            Unity_Multiply_float_float(_Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float, _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float, _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float);
                                                            float _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                                            Unity_OneMinus_float(_Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float, _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float);
                                                            surface.Alpha = _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                                            return surface;
                                                        }

                                                        // --------------------------------------------------
                                                        // Build Graph Inputs

                                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                        {
                                                            VertexDescriptionInputs output;
                                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                            output.ObjectSpaceNormal = input.normalOS;
                                                            output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                            output.ObjectSpacePosition = input.positionOS;

                                                            return output;
                                                        }
                                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                        {
                                                            SurfaceDescriptionInputs output;
                                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);








                                                            #if UNITY_UV_STARTS_AT_TOP
                                                            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                            #else
                                                            output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                            #endif

                                                            output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
                                                            output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                        #else
                                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                        #endif
                                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                return output;
                                                        }

                                                        void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                        {
                                                            result.vertex = float4(attributes.positionOS, 1);
                                                            result.tangent = attributes.tangentOS;
                                                            result.normal = attributes.normalOS;
                                                            result.vertex = float4(vertexDescription.Position, 1);
                                                            result.normal = vertexDescription.Normal;
                                                            result.tangent = float4(vertexDescription.Tangent, 0);
                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            #endif
                                                        }

                                                        void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                        {
                                                            result.pos = varyings.positionCS;
                                                            // World Tangent isn't an available input on v2f_surf


                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            #endif
                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                            #if !defined(LIGHTMAP_ON)
                                                            #endif
                                                            #endif
                                                            #if defined(LIGHTMAP_ON)
                                                            #endif
                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                            #endif

                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                        }

                                                        void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                        {
                                                            result.positionCS = surfVertex.pos;
                                                            // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                            // World Tangent isn't an available input on v2f_surf

                                                            #if UNITY_ANY_INSTANCING_ENABLED
                                                            #endif
                                                            #if UNITY_SHOULD_SAMPLE_SH
                                                            #if !defined(LIGHTMAP_ON)
                                                            #endif
                                                            #endif
                                                            #if defined(LIGHTMAP_ON)
                                                            #endif
                                                            #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                            #endif

                                                            DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                        }

                                                        // --------------------------------------------------
                                                        // Main

                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                        #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                        ENDHLSL
                                                        }
                                                        Pass
                                                        {
                                                            Name "ScenePickingPass"
                                                            Tags
                                                            {
                                                                "LightMode" = "Picking"
                                                            }

                                                            // Render State
                                                            Cull Back

                                                            // Debug
                                                            // <None>

                                                            // --------------------------------------------------
                                                            // Pass

                                                            HLSLPROGRAM

                                                            // Pragmas
                                                            #pragma target 3.0
                                                            #pragma multi_compile_instancing
                                                            #pragma vertex vert
                                                            #pragma fragment frag

                                                            // Keywords
                                                            // PassKeywords: <None>
                                                            // GraphKeywords: <None>

                                                            // Defines
                                                            #define _NORMALMAP 1
                                                            #define _NORMAL_DROPOFF_TS 1
                                                            #define ATTRIBUTES_NEED_NORMAL
                                                            #define ATTRIBUTES_NEED_TANGENT
                                                            #define FEATURES_GRAPH_VERTEX
                                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                                            #define SHADERPASS ScenePickingPass
                                                            #define BUILTIN_TARGET_API 1
                                                            #define SCENEPICKINGPASS 1
                                                            #define _BUILTIN_SURFACE_TYPE_TRANSPARENT 1
                                                            #ifdef _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                            #define _SURFACE_TYPE_TRANSPARENT _BUILTIN_SURFACE_TYPE_TRANSPARENT
                                                            #endif
                                                            #ifdef _BUILTIN_ALPHATEST_ON
                                                            #define _ALPHATEST_ON _BUILTIN_ALPHATEST_ON
                                                            #endif
                                                            #ifdef _BUILTIN_AlphaClip
                                                            #define _AlphaClip _BUILTIN_AlphaClip
                                                            #endif
                                                            #ifdef _BUILTIN_ALPHAPREMULTIPLY_ON
                                                            #define _ALPHAPREMULTIPLY_ON _BUILTIN_ALPHAPREMULTIPLY_ON
                                                            #endif


                                                            // custom interpolator pre-include
                                                            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */

                                                            // Includes
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Shim/Shims.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Core.hlsl"
                                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/Lighting.hlsl"
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/LegacySurfaceVertex.hlsl"
                                                            #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                                            // --------------------------------------------------
                                                            // Structs and Packing

                                                            // custom interpolators pre packing
                                                            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

                                                            struct Attributes
                                                            {
                                                                 float3 positionOS : POSITION;
                                                                 float3 normalOS : NORMAL;
                                                                 float4 tangentOS : TANGENT;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : INSTANCEID_SEMANTIC;
                                                                #endif
                                                            };
                                                            struct Varyings
                                                            {
                                                                 float4 positionCS : SV_POSITION;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                #endif
                                                            };
                                                            struct SurfaceDescriptionInputs
                                                            {
                                                                 float2 NDCPosition;
                                                                 float2 PixelPosition;
                                                            };
                                                            struct VertexDescriptionInputs
                                                            {
                                                                 float3 ObjectSpaceNormal;
                                                                 float3 ObjectSpaceTangent;
                                                                 float3 ObjectSpacePosition;
                                                            };
                                                            struct PackedVaryings
                                                            {
                                                                 float4 positionCS : SV_POSITION;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                 uint instanceID : CUSTOM_INSTANCE_ID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                                #endif
                                                            };

                                                            PackedVaryings PackVaryings(Varyings input)
                                                            {
                                                                PackedVaryings output;
                                                                ZERO_INITIALIZE(PackedVaryings, output);
                                                                output.positionCS = input.positionCS;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                output.instanceID = input.instanceID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                output.cullFace = input.cullFace;
                                                                #endif
                                                                return output;
                                                            }

                                                            Varyings UnpackVaryings(PackedVaryings input)
                                                            {
                                                                Varyings output;
                                                                output.positionCS = input.positionCS;
                                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                                output.instanceID = input.instanceID;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                                #endif
                                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                                #endif
                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                output.cullFace = input.cullFace;
                                                                #endif
                                                                return output;
                                                            }


                                                            // --------------------------------------------------
                                                            // Graph

                                                            // Graph Properties
                                                            CBUFFER_START(UnityPerMaterial)
                                                            float4 _Main_TexelSize;
                                                            float4 _Tint;
                                                            float2 _player_position;
                                                            float _Size;
                                                            float _smoothness;
                                                            float _opacity;
                                                            CBUFFER_END


                                                                // Object and Global properties
                                                                SAMPLER(SamplerState_Linear_Repeat);
                                                                TEXTURE2D(_Main);
                                                                SAMPLER(sampler_Main);

                                                                // -- Property used by ScenePickingPass
                                                                #ifdef SCENEPICKINGPASS
                                                                float4 _SelectionID;
                                                                #endif

                                                                // -- Properties used by SceneSelectionPass
                                                                #ifdef SCENESELECTIONPASS
                                                                int _ObjectId;
                                                                int _PassValue;
                                                                #endif

                                                                // Graph Includes
                                                                // GraphIncludes: <None>

                                                                // Graph Functions

                                                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                                {
                                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                                }

                                                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                                {
                                                                    Out = A + B;
                                                                }

                                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                                {
                                                                    Out = UV * Tiling + Offset;
                                                                }

                                                                void Unity_Multiply_float2_float2(float2 A, float2 B, out float2 Out)
                                                                {
                                                                    Out = A * B;
                                                                }

                                                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                                {
                                                                    Out = A - B;
                                                                }

                                                                void Unity_Divide_float(float A, float B, out float Out)
                                                                {
                                                                    Out = A / B;
                                                                }

                                                                void Unity_Multiply_float_float(float A, float B, out float Out)
                                                                {
                                                                    Out = A * B;
                                                                }

                                                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                                {
                                                                    Out = A / B;
                                                                }

                                                                void Unity_Length_float2(float2 In, out float Out)
                                                                {
                                                                    Out = length(In);
                                                                }

                                                                void Unity_OneMinus_float(float In, out float Out)
                                                                {
                                                                    Out = 1 - In;
                                                                }

                                                                void Unity_Saturate_float(float In, out float Out)
                                                                {
                                                                    Out = saturate(In);
                                                                }

                                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                                {
                                                                    Out = smoothstep(Edge1, Edge2, In);
                                                                }

                                                                // Custom interpolators pre vertex
                                                                /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

                                                                // Graph Vertex
                                                                struct VertexDescription
                                                                {
                                                                    float3 Position;
                                                                    float3 Normal;
                                                                    float3 Tangent;
                                                                };

                                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                                {
                                                                    VertexDescription description = (VertexDescription)0;
                                                                    description.Position = IN.ObjectSpacePosition;
                                                                    description.Normal = IN.ObjectSpaceNormal;
                                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                                    return description;
                                                                }

                                                                // Custom interpolators, pre surface
                                                                #ifdef FEATURES_GRAPH_VERTEX
                                                                Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
                                                                {
                                                                return output;
                                                                }
                                                                #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
                                                                #endif

                                                                // Graph Pixel
                                                                struct SurfaceDescription
                                                                {
                                                                    float Alpha;
                                                                };

                                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                                {
                                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                                    float _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float = _smoothness;
                                                                    float4 _ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4 = float4(IN.NDCPosition.xy, 0, 0);
                                                                    float2 _Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2 = _player_position;
                                                                    float2 _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2;
                                                                    Unity_Remap_float2(_Property_687533042d054c4987962a64a956d0d5_Out_0_Vector2, float2 (0, 1), float2 (0.5, -1.5), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2);
                                                                    float2 _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2;
                                                                    Unity_Add_float2((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), _Remap_c0d48b4570a047d58555be7f4e20b696_Out_3_Vector2, _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2);
                                                                    float2 _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2;
                                                                    Unity_TilingAndOffset_float((_ScreenPosition_7e4626e0896741cc9596338b55769f94_Out_0_Vector4.xy), float2 (1, 1), _Add_18486a7a0b90457c8ee02037945936c9_Out_2_Vector2, _TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2);
                                                                    float2 _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2;
                                                                    Unity_Multiply_float2_float2(_TilingAndOffset_5e48582059064355b48fc850950a915d_Out_3_Vector2, float2(2, 2), _Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2);
                                                                    float2 _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2;
                                                                    Unity_Subtract_float2(_Multiply_63c1d8c3bbdc407eb2a3b7349d629d74_Out_2_Vector2, float2(1, 1), _Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2);
                                                                    float _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float;
                                                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float);
                                                                    float _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float = _Size;
                                                                    float _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float;
                                                                    Unity_Multiply_float_float(_Divide_64f1ad9fd7fc40d4af49cbf40ad3ac13_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float, _Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float);
                                                                    float2 _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2 = float2(_Multiply_aa72d7769d2a40289dd38c2c08ce6170_Out_2_Float, _Property_6b8d73655121422eb0fd6ce529a6d965_Out_0_Float);
                                                                    float2 _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2;
                                                                    Unity_Divide_float2(_Subtract_144422f9a0f6468eab7b16949d4367d3_Out_2_Vector2, _Vector2_13ebf12ac4e84a8dab00570ee66d6980_Out_0_Vector2, _Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2);
                                                                    float _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float;
                                                                    Unity_Length_float2(_Divide_47f49f12beeb4153a4d0dabc53827603_Out_2_Vector2, _Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float);
                                                                    float _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float;
                                                                    Unity_OneMinus_float(_Length_7334200fea904e43bc73056b8c81ac74_Out_1_Float, _OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float);
                                                                    float _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float;
                                                                    Unity_Saturate_float(_OneMinus_931918863f734009b239090ab83ba8db_Out_1_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float);
                                                                    float _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float;
                                                                    Unity_Smoothstep_float(0, _Property_246c47de82224556b8a9ea144f91ff82_Out_0_Float, _Saturate_d02204dba05a446ca8744493891c06c6_Out_1_Float, _Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float);
                                                                    float _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float = _opacity;
                                                                    float _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float;
                                                                    Unity_Multiply_float_float(_Smoothstep_0e665eabde35499c9c296fc8a030f208_Out_3_Float, _Property_eaf3dbf83cc045dca2a5fe58a6af65f5_Out_0_Float, _Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float);
                                                                    float _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                                                    Unity_OneMinus_float(_Multiply_ebcc548e5f4c4338bd14ab4038f18e78_Out_2_Float, _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float);
                                                                    surface.Alpha = _OneMinus_cc9fd48687fc420ea9ba95821c5f5bb8_Out_1_Float;
                                                                    return surface;
                                                                }

                                                                // --------------------------------------------------
                                                                // Build Graph Inputs

                                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                                {
                                                                    VertexDescriptionInputs output;
                                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                                    output.ObjectSpaceNormal = input.normalOS;
                                                                    output.ObjectSpaceTangent = input.tangentOS.xyz;
                                                                    output.ObjectSpacePosition = input.positionOS;

                                                                    return output;
                                                                }
                                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                                {
                                                                    SurfaceDescriptionInputs output;
                                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);








                                                                    #if UNITY_UV_STARTS_AT_TOP
                                                                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x < 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                                    #else
                                                                    output.PixelPosition = float2(input.positionCS.x, (_ProjectionParams.x > 0) ? (_ScreenParams.y - input.positionCS.y) : input.positionCS.y);
                                                                    #endif

                                                                    output.NDCPosition = output.PixelPosition.xy / _ScreenParams.xy;
                                                                    output.NDCPosition.y = 1.0f - output.NDCPosition.y;

                                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                                #else
                                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                                #endif
                                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                                        return output;
                                                                }

                                                                void BuildAppDataFull(Attributes attributes, VertexDescription vertexDescription, inout appdata_full result)
                                                                {
                                                                    result.vertex = float4(attributes.positionOS, 1);
                                                                    result.tangent = attributes.tangentOS;
                                                                    result.normal = attributes.normalOS;
                                                                    result.vertex = float4(vertexDescription.Position, 1);
                                                                    result.normal = vertexDescription.Normal;
                                                                    result.tangent = float4(vertexDescription.Tangent, 0);
                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    #endif
                                                                }

                                                                void VaryingsToSurfaceVertex(Varyings varyings, inout v2f_surf result)
                                                                {
                                                                    result.pos = varyings.positionCS;
                                                                    // World Tangent isn't an available input on v2f_surf


                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    #endif
                                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    #endif
                                                                    #endif
                                                                    #if defined(LIGHTMAP_ON)
                                                                    #endif
                                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        result.fogCoord = varyings.fogFactorAndVertexLight.x;
                                                                        COPY_TO_LIGHT_COORDS(result, varyings.fogFactorAndVertexLight.yzw);
                                                                    #endif

                                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(varyings, result);
                                                                }

                                                                void SurfaceVertexToVaryings(v2f_surf surfVertex, inout Varyings result)
                                                                {
                                                                    result.positionCS = surfVertex.pos;
                                                                    // viewDirectionWS is never filled out in the legacy pass' function. Always use the value computed by SRP
                                                                    // World Tangent isn't an available input on v2f_surf

                                                                    #if UNITY_ANY_INSTANCING_ENABLED
                                                                    #endif
                                                                    #if UNITY_SHOULD_SAMPLE_SH
                                                                    #if !defined(LIGHTMAP_ON)
                                                                    #endif
                                                                    #endif
                                                                    #if defined(LIGHTMAP_ON)
                                                                    #endif
                                                                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                                                                        result.fogFactorAndVertexLight.x = surfVertex.fogCoord;
                                                                        COPY_FROM_LIGHT_COORDS(result.fogFactorAndVertexLight.yzw, surfVertex);
                                                                    #endif

                                                                    DEFAULT_UNITY_TRANSFER_VERTEX_OUTPUT_STEREO(surfVertex, result);
                                                                }

                                                                // --------------------------------------------------
                                                                // Main

                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                                #include "Packages/com.unity.shadergraph/Editor/Generation/Targets/BuiltIn/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                                                                ENDHLSL
                                                                }
        }
            CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
                                                                    CustomEditorForRenderPipeline "UnityEditor.Rendering.BuiltIn.ShaderGraph.BuiltInLitGUI" ""
                                                                    FallBack "Hidden/Shader Graph/FallbackError"
}