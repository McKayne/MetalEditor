
#ifndef UPANDRUNNING3D_SHARED_H
#define UPANDRUNNING3D_SHARED_H

#include <simd/simd.h>

typedef struct
{
    simd::float4x4 modelViewProjectionMatrix;
    simd::float4x4 modelViewMatrix;
    simd::float3x3 normalMatrix;
} Uniforms;

#endif
