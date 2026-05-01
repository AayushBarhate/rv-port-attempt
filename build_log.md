# Build log: GetDP on RISC-V

Notes from the first cross compile, kept while I was doing it.

Host: Ubuntu 24.04 on WSL2, x86-64.

Tools:

```
sudo apt install gcc-riscv64-linux-gnu g++-riscv64-linux-gnu \
                 gfortran-riscv64-linux-gnu qemu-user-static
```

All from the Ubuntu repos.

## Toolchain file

A small CMake toolchain file (`riscv64-toolchain.cmake`) that points
the C / C++ / Fortran compilers at the riscv64 cross tools and sets
`qemu-riscv64-static` as the cross compile emulator so CMake's
`try_run` checks work.

## Build

```
cd /path/to/getdp
mkdir build-rv && cd build-rv
cmake -DCMAKE_TOOLCHAIN_FILE=/abs/path/riscv64-toolchain.cmake \
      -DDEFAULT=0 -DENABLE_FORTRAN=1 -DENABLE_SPARSKIT=1 \
      -DENABLE_PETSC=0 -DENABLE_BLAS_LAPACK=0 -DENABLE_ARPACK=0 \
      -DENABLE_GMSH=0 -DENABLE_SLEPC=0 \
      -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)
```

`DEFAULT=0` turns every optional feature off. Then I turn back on only
what is needed to solve a problem: `FORTRAN=1` (Sparskit is Fortran)
and `SPARSKIT=1` (the built-in solver, no external dependency).
Everything else stays off.

## Result

```
build-rv/getdp
  ELF 64-bit LSB pie executable, UCB RISC-V, RVC, double-float ABI,
  dynamically linked, interpreter /lib/ld-linux-riscv64-lp64d.so.1
  size: 2.0M
```

## Run a real problem

Used the magnetostatics example shipped with GetDP
(`examples/magnet.pro`):

```
qemu-riscv64-static -L /usr/riscv64-linux-gnu \
    build-rv/getdp magnet.pro -solve Magnetostatics_phi -pos phi
```

Trimmed output:

```
Info : System 'A' : Real
Info : 8 Iterations / Residual: 8.2729e-13
Info : SaveSolution[A]
Info : PostOperation 'phi' 1/4   > 'phi.pos'
Info : PostOperation 'phi' 2/4   > 'hc.pos'
Info : PostOperation 'phi' 3/4   > 'b_phi.pos'
Info : PostOperation 'phi' 4/4   > 'b_phi.txt'
Info : Stopped (Wall = 1.378s, CPU = 1.410s, Mem = 17Mb)
```

Sparskit converged in 8 iterations to a residual of 8.3e-13. Wrote
four output files. Sample numbers from b_phi.txt:

```
... -0.06968 ...   -7.079e-17 -1.0338 0
... -0.06936 ...   -7.079e-17 -1.0338 0
```

Real magnetic field values, computed by a riscv64 binary running on
qemu.

## Notes

- The minimal-first approach works much better than fighting every
  external dependency at once. `DEFAULT=0` then enable as needed.
- Sparskit + the riscv64 gfortran from apt works fine. No patches
  needed.
- qemu-riscv64-static is fast enough for testing. Real hardware would
  be the next check.
