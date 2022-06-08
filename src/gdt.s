.global setupGdt
//make sure the linker puts this with the code
.section .text
setupGdt:
    lgdt [GDT_REG]
    mov %eax, %cr0
    or  %eax, 0x1
    mov %cr0, %eax
    ret
.section .gdt
GDT_START:
GDT_NULL:
    .quad 0x0
//copied from https://github.com/falconnine9/Talon/blob/main/boot/gdt.asm
GDT_SEG_KCODE:
    .hword 0xFFFF
    .hword 0
    .word 0
    .word 0x9A
    .word 0xCF
    .word 0

GDT_SEG_KDATA:
    .hword 0xFFFF
    .hword 0
    .word 0
    .word 0x92
    .word 0xCF
    .word 0

GDT_SEG_TSS:
    .hword 0x68
    .hword 0
    .word 0
    .word 0x81
    .word 0x40
    .word 0

GDT_END:

GDT_REG:
    .hword GDT_END - GDT_START - 1
    .int GDT_START
