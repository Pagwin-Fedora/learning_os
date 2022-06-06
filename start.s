/// clarifying kernel_main exists outside this file
.extern kernel_main

///start point
.global start

/// grub magic
.set MB_MAGIC , 0x1badb002          // This is a 'magic' constant that GRUB will use to detect our kernel's location.
.set MB_FLAGS , (1 << 0) | (1 << 1) // This tells GRUB to 1: load modules on page boundaries and 2: provide a memory map (this is useful later in development)
// Finally, we calculate a checksum that includes all the previous values
.set MB_CHECKSUM , (0 - (MB_MAGIC + MB_FLAGS))

///multiboot header
.section .multiboot
	.align 4 // Make sure the following data is aligned on a multiple of 4 bytes
	// Use the previously calculated constants in executable code
	.long MB_MAGIC
	.long MB_FLAGS
	// Use the checksum we calculated earlier
	.long MB_CHECKSUM

/// putting a bunch of zeroes here so we have space for a stack that C can use
.section .bss
	// Our C code will need a stack to run. Here, we allocate 4096 bytes (or 4 Kilobytes) for our stack.
	// We can expand this later if we want a larger stack. For now, it will be perfectly adequate.
	.align 16
	stack_bottom:
		.skip 4096 // Reserve a 4096-byte (4K) stack
	stack_top:

/// The actual assembly to load the kernel
.section .text
	// Here is the 'start' label we mentioned before. This is the first code that gets run in our kernel.
	start:
		// First thing's first: we want to set up an environment that's ready to run C code.
		// C is very relaxed in its requirements: All we need to do is to set up the stack.
		// Please note that on x86, the stack grows DOWNWARD. This is why we start at the top.
		mov $stack_top, %esp // Set the stack pointer to the top of the stack
 
		// Now we have a C-worthy (haha!) environment ready to run the rest of our kernel.
		// At this point, we can call our main C function.
		call kernel_main
 
		// If, by some mysterious circumstances, the kernel's C code ever returns, all we want to do is to hang the CPU
		hang:
			cli      // Disable CPU interrupts
			hlt      // Halt the CPU
			jmp hang // If that didn't work, loop around and try again.
