#include <stddef.h>
//to avoid calling asm directly
inline uint8_t inb(uint16_t);
inline void outb(uint16_t, uint8_t);
void NMI_enable(void);
void NMI_disable(void);
