#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 uv [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = in.position;
    out.uv = in.uv;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]], 
                              texture2d<float> tex [[texture(0)]], 
                              sampler texSampler [[sampler(0)]]) {
    // Sample the texture at the given UV coordinates
    float4 color = tex.sample(texSampler, in.uv);
    return color;
}
