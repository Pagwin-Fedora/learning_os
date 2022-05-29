SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

run: os

os: $(SELF_DIR)/kernel.c $(SELF_DIR)/start.s $(SELF_DIR)/linker.ld

tools: binutils gcc
binutils:
	$(SELF_DIR)/gcc/configure --target=${TARGET} --prefix="${PREFIX}" --with-sysroot --disable-nls --disable-werror
	make -j3
	make install
gcc:
	$(SELF_DIR)/binutils-gdb/configure --target=${TARGET} --prefix="${PREFIX}" --with-sysroot --disable-nls --disable-werror
	make -j3
	make install
