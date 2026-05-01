/* riscv64 backend. RVV would be the right thing here but it is an
 * optional extension and toolchain support is uneven, so this is a
 * scalar fallback for now. The compiler usually unrolls it fine. */
#ifndef SIMD_RISCV_H
#define SIMD_RISCV_H

#include <string.h>

typedef struct { float v[4]; } simd_v4f;

static inline simd_v4f simd_loadu(const float *p) {
    simd_v4f r;
    memcpy(r.v, p, sizeof r.v);
    return r;
}
static inline void simd_storeu(float *p, simd_v4f v) {
    memcpy(p, v.v, sizeof v.v);
}
static inline simd_v4f simd_add(simd_v4f a, simd_v4f b) {
    simd_v4f r;
    r.v[0] = a.v[0] + b.v[0];
    r.v[1] = a.v[1] + b.v[1];
    r.v[2] = a.v[2] + b.v[2];
    r.v[3] = a.v[3] + b.v[3];
    return r;
}
static inline simd_v4f simd_mul(simd_v4f a, simd_v4f b) {
    simd_v4f r;
    r.v[0] = a.v[0] * b.v[0];
    r.v[1] = a.v[1] * b.v[1];
    r.v[2] = a.v[2] * b.v[2];
    r.v[3] = a.v[3] * b.v[3];
    return r;
}
static inline simd_v4f simd_set1(float x) {
    simd_v4f r = { { x, x, x, x } };
    return r;
}

#define SIMD_BACKEND "riscv_scalar"

#endif
