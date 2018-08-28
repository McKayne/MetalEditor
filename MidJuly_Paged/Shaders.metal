
#include <metal_stdlib>
#include <metal_matrix>
#include "Shared.h"

using namespace metal;

struct Light
{
    float3 direction;
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
};

constant Light light = {
    .direction = { 0.13, 0.72, 0.68 },
    .ambientColor = { 0.05, 0.05, 0.05 },
    .diffuseColor = { 0.9, 0.9, 0.9 },
    .specularColor = { 1, 1, 1 }
};

struct Material
{
    float3 ambientColor;
    float3 diffuseColor;
    float3 specularColor;
    float specularPower;
};

constant Material material = {
    .ambientColor = { 0.9, 0.1, 0 },
    .diffuseColor = { 0.9, 0.1, 0 },
    .specularColor = { 1, 1, 1 },
    .specularPower = 100
};

struct Vertex
{
    float4 position [[attribute(0)]];
    float4 normal [[attribute(1)]];
    float4 customColor [[attribute(2)]];
};

struct ProjectedVertex
{
    float4 position [[position]];
    float3 eye;
    float3 normal;
    float3 customColor;
};

vertex ProjectedVertex vertex_main(Vertex vert [[stage_in]],
                                   constant Uniforms &uniforms [[buffer(1)]]) {
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * vert.position;
    outVert.eye =  -(uniforms.modelViewMatrix * vert.position).xyz;
    outVert.normal = uniforms.normalMatrix * vert.normal.xyz;
    
    outVert.customColor.x = vert.customColor.x;
    outVert.customColor.y = vert.customColor.y;
    outVert.customColor.z = vert.customColor.z;
    
    return outVert;
}

fragment float4 fragment_main(ProjectedVertex vert [[stage_in]],
                              constant Uniforms &uniforms [[buffer(0)]]) {
    
    Material customMaterial = {
        .ambientColor = { 0.9, 0.1, 0 },
        .diffuseColor = { 0, 0, 0.9 },
        .specularColor = { 1, 1, 1 },
        .specularPower = 100
    };
    
    //return float4(vert.customColor.x, vert.customColor.y, vert.customColor.z, 1);
    
    float3 ambientTerm = light.ambientColor * customMaterial.ambientColor;
    
    float3 normal = normalize(vert.normal);
    float diffuseIntensity = saturate(dot(normal, light.direction));
    float3 diffuseTerm = light.diffuseColor * vert.customColor * diffuseIntensity;
    
    float3 specularTerm(0);
    if (diffuseIntensity > 0)
    {
        float3 eyeDirection = normalize(vert.eye);
        float3 halfway = normalize(light.direction + eyeDirection);
        float specularFactor = pow(saturate(dot(normal, halfway)), customMaterial.specularPower);
        specularTerm = light.specularColor * customMaterial.specularColor * specularFactor;
    }
    
    return float4(ambientTerm + diffuseTerm + specularTerm, 1);
}
