SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
JOB_COUNT = 2
run: os
os: $(SELF_DIR)/kernel.c $(SELF_DIR)/start.s $(SELF_DIR)/linker.ld

gcc-tool:
	$(SELF_DIR)gcc/configure --target=${TARGET} --prefix="${PREFIX}" --disable-nls --without-headers --enable-languages=c,c++,ada
	make all-gcc -j$(JOB_COUNT)
	make all-target-libgcc -j$(job_count)
	make install-gcc
	make install-target-libgcc
binutils-tool:
	$(SELF_DIR)binutils-gdb/configure --target=${TARGET} --prefix="${PREFIX}" --with-sysroot --disable-nls --disable-werror
	make -j$(JOB_COUNT)
	make install
