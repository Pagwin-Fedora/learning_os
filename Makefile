SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
JOB_COUNT = 2
run: os
os: $(SELF_DIR)/kernel.c $(SELF_DIR)/start.s $(SELF_DIR)/linker.ld

tools: binutils gcc-tool
gcc-tool:
	$(SELF_DIR)gcc/configure --target=${TARGET} --prefix="${PREFIX}" --disable-nls --disable-werror --without-headers --enable-languages=c,c++
	make -j$(JOB_COUNT)
	make install
binutils-tool:
	$(SELF_DIR)binutils-gdb/configure --target=${TARGET} --prefix="${PREFIX}" --with-sysroot --disable-nls --disable-werror
	make -j$(JOB_COUNT)
	make install
