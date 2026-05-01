/* small test, does y = a*x + b on a float array using the simd shim.
 * builds for both x86 and riscv64 from the same source. */

#include <stdio.h>
#include "simd.h"

#define N 16

int main(void) {
    float x[N], y[N];
    for (int i = 0; i < N; i++) x[i] = (float)i;

    simd_v4f a = simd_set1(2.5f);
    simd_v4f b = simd_set1(1.0f);

    /* process 4 floats at a time */
    for (int i = 0; i < N; i += 4) {
        simd_v4f vx = simd_loadu(&x[i]);
        simd_v4f vy = simd_add(simd_mul(a, vx), b);
        simd_storeu(&y[i], vy);
    }

    printf("backend: %s\n", SIMD_BACKEND);
    for (int i = 0; i < N; i++) {
        printf("  y[%2d] = 2.5 * %.1f + 1.0 = %.2f\n", i, x[i], y[i]);
    }
    return 0;
}
