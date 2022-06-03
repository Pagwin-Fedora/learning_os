SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
JOB_COUNT = 2
KERNEL = learning_kernel.elf
OS_IMG = os.iso

run: $(OS_IMAGE)
	qemu-system-i386 -kernel $(KERNEL) -machine type=pc-i440fx-3.1

$(OS_IMG): $(KERNEL) $(SELF_DIR)isoroot/boot/grub/grub.cfg
	cp $(KERNEL) $(SELF_DIR)isoroot/boot
	grub-mkrescue isoroot -o $(OS_IMG)
$(KERNEL): $(SELF_DIR)kernel.c $(SELF_DIR)start.s $(SELF_DIR)linker.ld
	i686-elf-gcc -std=gnu99 -ffreestanding -g -c start.s -o start.o
	i686-elf-gcc -std=gnu99 -ffreestanding -g -c kernel.c -o kernel.o
	i686-elf-gcc -ffreestanding -nostdlib -g -T linker.ld start.o kernel.o -o $(KERNEL) -lgcc
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
