#include <stddef.h>
void scroll(uint8_t num);
void term_init(void);
void term_putc(char);
void memcpy(char* dest, char* src, size_t size);
void term_print(const char*);
void term_hex_disp(long);
void term_bin_disp(long);
