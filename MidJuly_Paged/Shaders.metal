
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
    
    //outVert.eye =  -(uniforms.modelViewMatrix * vert.position).xyz;
    //float4 lightPosition = {0, -10, 1, 1};
    //outVert.eye =  -(uniforms.modelViewMatrix * lightPosition).xyz;
    outVert.eye =  {0, -100, 1};
    
    outVert.normal = uniforms.normalMatrix * vert.normal.xyz;
    
    outVert.customColor.x = vert.customColor.x;
    outVert.customColor.y = vert.customColor.y;
    outVert.customColor.z = vert.customColor.z;
    
    return outVert;
}

float4 lightAt(ProjectedVertex vert, float3 eye) {
    Material customMaterial = {
        .ambientColor = { 0.9, 0.1, 0 },
        .diffuseColor = { 0, 0, 0.9 },
        .specularColor = { 1, 1, 1 },
        .specularPower = 100
    };
    
    float3 ambientTerm, normal, diffuseTerm, specularTerm(0), eyeDirection, halfway;
    float diffuseIntensity, specularFactor;
    
    vert.eye =  eye;
    ambientTerm = light.ambientColor * customMaterial.ambientColor;
    
    normal = normalize(vert.normal);
    diffuseIntensity = saturate(dot(normal, light.direction));
    diffuseTerm = light.diffuseColor * vert.customColor * diffuseIntensity;
    
    //float3 specularTerm(0);
    if (diffuseIntensity > 0) {
        eyeDirection = normalize(vert.eye);
        halfway = normalize(light.direction + eyeDirection);
        specularFactor = pow(saturate(dot(normal, halfway)), customMaterial.specularPower);
        specularTerm = light.specularColor * customMaterial.specularColor * specularFactor;
    }
    
    return float4(ambientTerm + diffuseTerm + specularTerm, 1);
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
    
    float3 ambientTerm, normal, diffuseTerm, specularTerm(0), eyeDirection, halfway;
    float diffuseIntensity, specularFactor;
    
    vert.eye =  {0, -100, 1};
    ambientTerm = light.ambientColor * customMaterial.ambientColor;
    
    normal = normalize(vert.normal);
    diffuseIntensity = saturate(dot(normal, light.direction));
    diffuseTerm = light.diffuseColor * vert.customColor * diffuseIntensity;
    
    //float3 specularTerm(0);
    if (diffuseIntensity > 0) {
        eyeDirection = normalize(vert.eye);
        halfway = normalize(light.direction + eyeDirection);
        specularFactor = pow(saturate(dot(normal, halfway)), customMaterial.specularPower);
        specularTerm = light.specularColor * customMaterial.specularColor * specularFactor;
    }
    
    float4 lightA = float4(ambientTerm + diffuseTerm + specularTerm, 1);
    
    vert.eye =  {0, 0, 1};
    ambientTerm = light.ambientColor * customMaterial.ambientColor;
    
    normal = normalize(vert.normal);
    diffuseIntensity = saturate(dot(normal, light.direction));
    diffuseTerm = light.diffuseColor * vert.customColor * diffuseIntensity;
    
    //float3 specularTerm(0);
    if (diffuseIntensity > 0) {
        eyeDirection = normalize(vert.eye);
        halfway = normalize(light.direction + eyeDirection);
        specularFactor = pow(saturate(dot(normal, halfway)), customMaterial.specularPower);
        specularTerm = light.specularColor * customMaterial.specularColor * specularFactor;
    }
    
    float4 lightB = float4(ambientTerm + diffuseTerm + specularTerm, 1);
    
    lightB = lightAt(vert, float3{0, 0, 1});
    
    float4 lightC = lightAt(vert, float3{-10, -10, 1});
    
    return lightA + lightB + lightC;
}
