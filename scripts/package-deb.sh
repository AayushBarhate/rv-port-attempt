#!/bin/bash
# package-deb.sh: wrap a riscv64 binary into a minimal .deb
#
# usage: package-deb.sh <name> <version> <binary-path> [more binaries ...]
#
# example:
#   ./package-deb.sh getdp 4.0.0 builds/getdp/build-rv/getdp

set -e

if [ $# -lt 3 ]; then
    echo "usage: $0 <name> <version> <binary-path> [more binaries ...]"
    exit 1
fi

NAME=$1
VERSION=$2
shift 2

OUT_DIR=$(cd "$(dirname "$0")"/../packages && pwd)
WORK=$(mktemp -d)
trap "rm -rf $WORK" EXIT

# debian package layout:
#   DEBIAN/control
#   usr/bin/<binary>
mkdir -p "$WORK/DEBIAN" "$WORK/usr/bin"

for bin in "$@"; do
    if [ ! -x "$bin" ]; then
        echo "error: $bin is not executable"
        exit 1
    fi
    # check it really is riscv64 to avoid shipping the wrong arch by mistake
    if ! file "$bin" | grep -q "RISC-V"; then
        echo "warning: $bin does not look like a RISC-V binary"
        file "$bin"
    fi
    cp "$bin" "$WORK/usr/bin/"
done

cat > "$WORK/DEBIAN/control" <<EOF
Package: $NAME
Version: $VERSION
Architecture: riscv64
Maintainer: none <none@example.com>
Description: $NAME built for riscv64
 Cross compiled with riscv64-linux-gnu toolchain. Tested on qemu.
EOF

DEB="${OUT_DIR}/${NAME}_${VERSION}_riscv64.deb"
dpkg-deb --build "$WORK" "$DEB" > /dev/null

echo "package: $DEB"
echo
dpkg-deb -I "$DEB"
echo
echo "contents:"
dpkg-deb -c "$DEB"
