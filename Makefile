SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SRC_DIR = $(SELF_DIR)src
JOB_COUNT = 2
KERNEL = learning_kernel.elf
OS_IMG = os.iso

run: $(OS_IMG)
	qemu-system-i386 -boot c $(OS_IMG)
run-debug: $(OS_IMG) check_multiboot
	qemu-system-i386 -boot c -s -S $(OS_IMG)
check_multiboot: $(KERNEL)
	grub-file --is-x86-multiboot $(KERNEL)
$(OS_IMG): $(KERNEL) $(SELF_DIR)isoroot/boot/grub/grub.cfg
	cp $(KERNEL) $(SELF_DIR)isoroot/boot
	grub-mkrescue $(SELF_DIR)isoroot -o $(OS_IMG)
$(KERNEL): kernel.o start.o gdt.o $(SELF_DIR)linker.ld
	i686-elf-gcc -ffreestanding -nostdlib -g -T $(SELF_DIR)linker.ld start.o kernel.o gdt.o -o $(KERNEL) -lgcc
start.o: $(SRC_DIR)/start.s
	i686-elf-gcc -ffreestanding -g -c $(SRC_DIR)/start.s -o start.o
gdt.o: $(SRC_DIR)/gdt.s
	i686-elf-gcc -ffreestanding -g -c $(SRC_DIR)/gdt.s -o gdt.o
kernel.o: $(SRC_DIR)/kernel.c
	i686-elf-gcc -std=gnu99 -ffreestanding -g -c $(SRC_DIR)/kernel.c -o kernel.o
gcc-tool: binutils-tool
	$(SELF_DIR)gcc/configure --target=${TARGET} --prefix="${PREFIX}" --disable-nls --without-headers --enable-languages=c,c++,ada
	make all-gcc -j$(JOB_COUNT)
	make all-target-libgcc -j$(job_count)
	make install-gcc
	make install-target-libgcc
binutils-tool:
	$(SELF_DIR)binutils-gdb/configure --target=${TARGET} --prefix="${PREFIX}" --with-sysroot --disable-nls --disable-werror
	make -j$(JOB_COUNT)
	make install
