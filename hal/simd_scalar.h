/* portable scalar fallback for any other architecture */
#ifndef SIMD_SCALAR_H
#define SIMD_SCALAR_H

#include <string.h>

typedef struct { float v[4]; } simd_v4f;

static inline simd_v4f simd_loadu(const float *p) {
    simd_v4f r; memcpy(r.v, p, sizeof r.v); return r;
}
static inline void simd_storeu(float *p, simd_v4f v) {
    memcpy(p, v.v, sizeof v.v);
}
static inline simd_v4f simd_add(simd_v4f a, simd_v4f b) {
    simd_v4f r;
    for (int i = 0; i < 4; i++) r.v[i] = a.v[i] + b.v[i];
    return r;
}
static inline simd_v4f simd_mul(simd_v4f a, simd_v4f b) {
    simd_v4f r;
    for (int i = 0; i < 4; i++) r.v[i] = a.v[i] * b.v[i];
    return r;
}
static inline simd_v4f simd_set1(float x) {
    simd_v4f r = { { x, x, x, x } };
    return r;
}

#define SIMD_BACKEND "scalar"

#endif
