//
//  shader.metal
//  MetalShaderSceneKit
//
//  Created by M.Ike on 2016/07/04.
//  Copyright © 2016年 M.Ike. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>


// 頂点属性
struct VertexInput {
    float3 position [[ attribute(SCNVertexSemanticPosition) ]];
    float2 texcoord [[ attribute(SCNVertexSemanticTexcoord0) ]];
};

// モデルデータ
struct NodeBuffer {
    float4x4 modelViewProjectionTransform;
};

// 変数
struct CustomBuffer {
    float4 color;
};

struct VertexOut {
    float4 position [[position]];
    float2 texcoord;
    float4 color;
};


vertex VertexOut textureVertex(VertexInput in [[ stage_in ]],
                               constant SCNSceneBuffer& scn_frame [[ buffer(0) ]],
                               constant NodeBuffer& scn_node [[ buffer(1) ]],
                               constant CustomBuffer& custom [[ buffer(2) ]]) {
    VertexOut out;
    out.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0);
    out.texcoord = in.texcoord;
    out.color = custom.color;
    return out;
}

fragment half4 textureFragment(VertexOut in [[ stage_in ]],
                               texture2d<float> texture [[ texture(0) ]]) {
    constexpr sampler defaultSampler;
    float4 color;
    color = texture.sample(defaultSampler, in.texcoord) + in.color;
    return half4(color);
}
