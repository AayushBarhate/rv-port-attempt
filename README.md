# rv-port-attempt

My attempt at the RISC-V porting problem. Took some HPC codes, cross
compiled them for riscv64, ran them on qemu, and packaged the binaries
as .deb. Also wrote a small SIMD shim because some of these codes have
x86 intrinsics that wont work on RISC-V as is.

Two of three codes build end to end and solve real problems. Third one
is partial, explained below.

Note: I used AI for help while doing this, mostly for writing the
wrapper scripts and the SIMD shim, and for catching mistakes in the
cmake flags. The builds, the qemu runs, and the .debs are real and
reproducible from the source.

## What is in here

```
README.md
picks.md                 the 3 codes I picked and why
build_log.md             notes from the first build
riscv64-toolchain.cmake  CMake toolchain file
scripts/
  build-riscv.sh         CMake project to riscv64 binary
  build-riscv-make.sh    same idea for plain Makefile projects
  package-deb.sh         wrap a riscv64 binary into a .deb
hal/
  simd.h                 SIMD interface
  simd_x86.h             SSE2 backend
  simd_riscv.h           riscv64 backend, scalar for now
  simd_scalar.h          fallback for any other arch
  demo.c
  Makefile
packages/
  getdp_4.0.0_riscv64.deb
  oofem_2.6.0_riscv64.deb
```

## Setup

On Ubuntu:

```
sudo apt install gcc-riscv64-linux-gnu g++-riscv64-linux-gnu \
                 gfortran-riscv64-linux-gnu qemu-user-static \
                 cmake make build-essential
```

That is all. No toolchain to build by hand.

## Build script

```
./scripts/build-riscv.sh <project-dir> [extra cmake -D flags ...]
```

It just calls cmake with the toolchain file (`riscv64-toolchain.cmake`)
which sets `riscv64-linux-gnu-gcc`, `-g++` and `-gfortran` as the
compilers. It also tells cmake to use `qemu-riscv64-static` as the
emulator so cmake's `try_run` checks during configure work without a
real RISC-V machine.

For GetDP I ran:

```
./scripts/build-riscv.sh /path/to/getdp \
    -DDEFAULT=0 -DENABLE_FORTRAN=1 -DENABLE_SPARSKIT=1 \
    -DENABLE_PETSC=0 -DENABLE_BLAS_LAPACK=0
```

`build-riscv-make.sh` is the same idea but for plain Makefile
projects. It just exports `CC`, `CXX`, `FC`, `AR`, `RANLIB`, `LD`. Most
older scientific Makefiles respect these. CalculiX does not, it
hard-codes `CC` and `FC`, so they have to be passed on the make
command line. See `build_log.md`.

## .deb script

```
./scripts/package-deb.sh <name> <version> <riscv64-binary>
```

Builds a Debian package with `Architecture: riscv64` set, so it will
only install on a riscv64 system. I used it on the GetDP and OOFEM
binaries.

## Results

GetDP: full build, .deb shipped, magnetostatics example solves on
qemu. Sparskit converged in 8 iterations, residual 8.3e-13. Notes
in `build_log.md`.

OOFEM: full build, .deb shipped, regression test
`tm/qquad01.in` passes (Newton-Raphson converged to 1e-15, 0 errors,
0 warnings).

CalculiX: partial. 988 of 990 source files cross compiled to riscv64
objects, but the final link wants the SPOOLES static library which I
have not built for riscv64 yet. The CalculiX source itself is portable
(no `__x86_64__` ifdefs, no SSE/AVX, no `-march`). So the work left
here is on SPOOLES, not on CalculiX.

## SIMD shim

`hal/` has a small example of the kind of shim that lets the same
source compile for x86 and riscv64. Codes that use SSE/AVX intrinsics
directly will not work on RISC-V. Hiding the arch behind a small
interface makes the migration mostly mechanical.

To run the test:

```
cd hal
make test
```

This builds `demo.c` for x86 with SSE2, builds it again for riscv64
with the scalar backend, runs the riscv binary on qemu, and diffs the
two outputs. Only the "backend:" header line differs, the numbers are
identical.

The riscv backend is scalar for now. Replacing it with RVV intrinsics
is a TODO.
