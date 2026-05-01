/* x86_64 backend using SSE2 (always available on x86_64) */
#ifndef SIMD_X86_H
#define SIMD_X86_H

#include <emmintrin.h>

typedef __m128 simd_v4f;

static inline simd_v4f simd_loadu(const float *p)  { return _mm_loadu_ps(p); }
static inline void     simd_storeu(float *p, simd_v4f v) { _mm_storeu_ps(p, v); }
static inline simd_v4f simd_add(simd_v4f a, simd_v4f b)  { return _mm_add_ps(a, b); }
static inline simd_v4f simd_mul(simd_v4f a, simd_v4f b)  { return _mm_mul_ps(a, b); }
static inline simd_v4f simd_set1(float x)                { return _mm_set1_ps(x); }

#define SIMD_BACKEND "x86_sse2"

#endif
