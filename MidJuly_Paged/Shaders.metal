
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
    float4 texCoord [[attribute(3)]];
};

struct ProjectedVertex
{
    float4 position [[position]];
    float3 eye;
    float3 normal;
    float4 diffuseColor;
    float4 customColor;
    float2 texCoord;
};

vertex ProjectedVertex vertex_main(Vertex vert [[stage_in]],
                                   constant Uniforms &uniforms [[buffer(1)]], ushort vid [[vertex_id]]) {
    ProjectedVertex outVert;
    outVert.position = uniforms.modelViewProjectionMatrix * vert.position;
    
    outVert.eye =  -(uniforms.modelViewMatrix * vert.position).xyz;
    //float4 lightPosition = {0, -10, 1, 1};
    //outVert.eye =  -(uniforms.modelViewMatrix * lightPosition).xyz;
    //outVert.eye =  {0, -100, 1};
    
    outVert.normal = uniforms.normalMatrix * vert.normal.xyz;
    
    outVert.customColor.x = vert.customColor.x;
    outVert.customColor.y = vert.customColor.y;
    outVert.customColor.z = vert.customColor.z;
    outVert.customColor.w = vert.customColor.w;
    
    outVert.texCoord.x = vert.texCoord.y;
    outVert.texCoord.y = vert.texCoord.z;
    
    //outVert.diffuseColor = vert.customColor;
    
    return outVert;
}

float4 lightAt(ProjectedVertex vert, float3 eye) {
    Material customMaterial = {
        .ambientColor = { 0.9, 0.1, 0 },
        .diffuseColor = { 0, 0, 0.9 },
        .specularColor = { 1, 1, 1 },
        .specularPower = 100
    };
    
    float3 customColor;
    customColor.x = vert.customColor.x;
    customColor.y = vert.customColor.y;
    customColor.z = vert.customColor.z;
    
    float3 ambientTerm, normal, diffuseTerm, specularTerm(0), eyeDirection, halfway;
    float diffuseIntensity, specularFactor;
    
    vert.eye =  eye;
    ambientTerm = light.ambientColor * customMaterial.ambientColor;
    
    normal = normalize(vert.normal);
    diffuseIntensity = saturate(dot(normal, light.direction));
    diffuseTerm = light.diffuseColor * customColor * diffuseIntensity;
    
    //float3 specularTerm(0);
    if (diffuseIntensity > 0) {
        eyeDirection = normalize(vert.eye);
        halfway = normalize(light.direction + eyeDirection);
        specularFactor = pow(saturate(dot(normal, halfway)), customMaterial.specularPower);
        specularTerm = light.specularColor * customMaterial.specularColor * specularFactor;
    }
    
    return float4(ambientTerm + diffuseTerm + specularTerm, 1);
}

fragment float4 fragment_main(ProjectedVertex vert [[stage_in]], constant Uniforms &uniforms [[buffer(0)]], texture2d<float> tex2D [[texture(0)]], sampler sampler2D [[sampler(0)]]) {
    
    Material customMaterial = {
        .ambientColor = { 0.9, 0.1, 0 },
        .diffuseColor = { 0, 0, 0.9 },
        .specularColor = { 1, 1, 1 },
        .specularPower = 100
    };
    
    //if (vert.customColor.w < 0.5)
        //discard_fragment();
    
    //return tex2D.sample(sampler2D, vert.texCoord);
    
    
    float3 kLightDirection( 0.13, 0.72, 0.68 );//(0.2, -0.96, 0.2);
    
    float kMinDiffuseIntensity = 0.85;
    
    float kAlphaTestReferenceValue = 0.5;
    
    //vert.customColor.a = vert.customColor.w;
    
    float4 vertexColor = {vert.customColor.x, vert.customColor.y, vert.customColor.z, vert.customColor.w};//vert.customColor;
    float4 textureColor = {vert.customColor.x, vert.customColor.y, vert.customColor.z, vert.customColor.w};//vert.customColor;//texture.sample(texSampler, vert.texCoords);
     
    float diffuseIntensity = max(kMinDiffuseIntensity, dot(normalize(vert.normal.xyz), -kLightDirection));
    float4 color = diffuseIntensity * textureColor * vertexColor;
     
    //return float4(color.r, color.g, color.b, vertexColor.a);
    
    
    //return float4(vert.customColor.x, vert.customColor.y, vert.customColor.z, vert.customColor.w);
    
    float3 customColor;
    customColor.x = vert.customColor.x;
    customColor.y = vert.customColor.y;
    customColor.z = vert.customColor.z;
    
    float3 ambientTerm, normal, diffuseTerm, specularTerm(0), eyeDirection, halfway;
    //float diffuseIntensity, specularFactor;
    float specularFactor;
    
    //vert.eye =  {0, -100, 1};
    ambientTerm = light.ambientColor * customMaterial.ambientColor;
    
    normal = normalize(vert.normal);
    diffuseIntensity = saturate(dot(normal, light.direction));
    diffuseTerm = light.diffuseColor * customColor * diffuseIntensity;
    
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
    diffuseTerm = light.diffuseColor * customColor * diffuseIntensity;
    
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
    
    return lightA + lightC;// + lightC;
}
