# build the HAL demo for native and for riscv64

CC       ?= gcc
RV_CC    ?= riscv64-linux-gnu-gcc
CFLAGS    = -O2 -Wall

.PHONY: all native riscv test clean

all: native riscv

native: demo-native
demo-native: demo.c simd.h simd_x86.h simd_scalar.h
	$(CC) $(CFLAGS) demo.c -o demo-native

riscv: demo-riscv
demo-riscv: demo.c simd.h simd_riscv.h simd_scalar.h
	$(RV_CC) $(CFLAGS) demo.c -o demo-riscv

# run both and diff their output to make sure backends agree on results
test: all
	./demo-native > out-native.txt
	qemu-riscv64-static -L /usr/riscv64-linux-gnu ./demo-riscv > out-riscv.txt
	@echo "--- native ---"; head -2 out-native.txt
	@echo "--- riscv  ---"; head -2 out-riscv.txt
	@echo "--- diff (only header line should differ) ---"
	diff out-native.txt out-riscv.txt || true

clean:
	rm -f demo-native demo-riscv out-native.txt out-riscv.txt
