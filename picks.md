# Picks

I went through the spreadsheet of codes and picked 3 to try first, one
easy, one medium, one hard. Idea is to get a quick win first and then
move to bigger ones once the build setup is figured out.

## GetDP (easy)

- https://gitlab.onelab.info/getdp/getdp
- C++ with some Fortran
- CMake build
- GPL

CMake already supports cross compilation, and GetDP has built-in
fallback solvers (Sparskit, Arpack) so I can build a minimal version
without PETSc. PETSc is a big project on its own and would be a
separate problem to solve. The CMakeLists has options like
`ENABLE_PETSC` and `ENABLE_ARPACK` that can be turned off, so I can
start small.

Plan: build with `cmake -DDEFAULT=0` first to get the bare minimum
running on qemu, then turn features on one by one.

## OOFEM (medium)

- https://github.com/oofem/oofem
- C++ mostly, some C
- CMake
- LGPL

Active project, last push was a few weeks ago. Bigger than GetDP but
still plain CMake. Headless solver, so no OpenGL or Qt mess. Has
Python bindings but they are optional.

Plan: same idea as GetDP, build the core solver only first. Once that
works, run the regression tests on qemu. If those pass that is already
useful.

## CalculiX (hard)

- http://www.dhondt.de/ (ccx solver only, not the cgx graphical part)
- Fortran mostly, some C
- Plain Makefile
- GPL

Mostly Fortran, which is good because it tests the gfortran-riscv64
toolchain which is the part most likely to have rough edges. I checked
the source, no `-march`, no SSE, no AVX. The code is portable. The
issue will be the dependencies (SPOOLES, ARPACK) which need building
for RISC-V first.

Plain Makefile, so cross compile flags have to be handled by hand.
Useful exercise because a lot of older scientific code is in this same
shape.

Plan: build SPOOLES and ARPACK for riscv64 first, then ccx itself.
Skip cgx since it needs OpenGL.

## Why these three

Each one tests a different thing.

GetDP: does the modern CMake path go through smoothly.

OOFEM: does a big C++ project with thousands of files actually finish
compiling without weird template errors or running out of memory on
the cross compiler.

CalculiX: does the Fortran toolchain hold up, and can a plain Makefile
project be cross-compiled without source patches.

If all three build, the same scripts and patches should cover a good
chunk of the rest of the spreadsheet.
