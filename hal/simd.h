/* Small SIMD shim. The same code calls simd_add etc. and the right
 * backend is picked at compile time. For now: SSE2 on x86, scalar on
 * riscv64. RVV intrinsics is a TODO. */

#ifndef SIMD_H
#define SIMD_H

#if defined(__x86_64__) || defined(_M_X64)
    #include "simd_x86.h"
#elif defined(__riscv) && (__riscv_xlen == 64)
    #include "simd_riscv.h"
#else
    #include "simd_scalar.h"
#endif

#endif
