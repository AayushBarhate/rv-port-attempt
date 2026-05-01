#!/bin/bash
# build-riscv-make.sh: cross compile a plain Makefile project for riscv64
#
# usage: build-riscv-make.sh <source-dir> [make targets ...]
#
# It exports CC, CXX, FC, AR, RANLIB pointing at the riscv64 cross tools and
# then runs make. Most plain Makefiles that respect these variables will
# pick them up.
#
# example:
#   ./build-riscv-make.sh /path/to/CalculiX/ccx_2.23/src

set -e

if [ $# -lt 1 ]; then
    echo "usage: $0 <source-dir> [make targets ...]"
    exit 1
fi

SRC=$(realpath "$1")
shift

if [ ! -f "$SRC/Makefile" ]; then
    echo "error: $SRC has no Makefile"
    exit 1
fi

export CC=riscv64-linux-gnu-gcc
export CXX=riscv64-linux-gnu-g++
export FC=riscv64-linux-gnu-gfortran
export F77=riscv64-linux-gnu-gfortran
export AR=riscv64-linux-gnu-ar
export RANLIB=riscv64-linux-gnu-ranlib
export LD=riscv64-linux-gnu-ld

echo "=== building in $SRC ==="
echo "CC=$CC"
echo "FC=$FC"
cd "$SRC"
make -j$(nproc) "$@"
echo "=== done ==="
