#!/bin/bash
# build-riscv.sh: cross compile a CMake project for riscv64
#
# usage: build-riscv.sh <project-dir> [extra cmake flags ...]
#
# example:
#   ./build-riscv.sh /path/to/getdp -DDEFAULT=0 -DENABLE_SPARSKIT=1 -DENABLE_FORTRAN=1

set -e

if [ $# -lt 1 ]; then
    echo "usage: $0 <project-dir> [extra cmake flags ...]"
    exit 1
fi

PROJECT=$(realpath "$1")
shift

if [ ! -f "$PROJECT/CMakeLists.txt" ]; then
    echo "error: $PROJECT does not have a CMakeLists.txt"
    exit 1
fi

# the toolchain file is next to this script
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
TOOLCHAIN="$SCRIPT_DIR/../riscv64-toolchain.cmake"

if [ ! -f "$TOOLCHAIN" ]; then
    echo "error: toolchain file not found at $TOOLCHAIN"
    exit 1
fi

# check tools
for t in riscv64-linux-gnu-gcc riscv64-linux-gnu-g++ qemu-riscv64-static cmake make; do
    if ! command -v $t > /dev/null; then
        echo "error: $t not found, please install"
        exit 1
    fi
done

BUILD="$PROJECT/build-rv"
echo "=== cleaning $BUILD ==="
rm -rf "$BUILD"
mkdir -p "$BUILD"
cd "$BUILD"

echo "=== configuring ==="
cmake -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
      -DCMAKE_BUILD_TYPE=Release \
      "$@" \
      ..

echo "=== building ==="
make -j$(nproc)

echo "=== done ==="
echo "build dir: $BUILD"

# find the produced binary, if any
BIN=$(find "$BUILD" -maxdepth 2 -type f -executable ! -name '*.so*' ! -name '*.a' 2>/dev/null | head -1)
if [ -n "$BIN" ]; then
    echo "binary: $BIN"
    file "$BIN"
fi
