
#ifndef UPANDRUNNING3D_TRANSFORMS_H
#define UPANDRUNNING3D_TRANSFORMS_H

#include <simd/simd.h>

// This function returns the identity matrix
simd::float4x4 Identity();

// This function constructs a symmetric perspective projection matrix.
// fovy is the vertical field of view, in radians
simd::float4x4 PerspectiveProjection(float aspect, float fovy, float near, float far);

// This function constructs a matrix that rotates points around the
// specified axis by the specified angle (in radians)
simd::float4x4 Rotation(simd::float3 axis, float angle);

#endif
