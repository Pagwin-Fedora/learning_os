#include <stddef.h>
typedef enum gate_type{TASK = 0x5, INT16 = 0x6, TRAP16 = 0x7, INT32 = 0xE, TRAP32 = 0xF} gate_type;
typedef uint8_t ring_level;

uint64_t genDescriptor(uint32_t, uint16_t, gate_type, ring_level);
