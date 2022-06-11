#include "interrupt_gen.h"
//probably will be easier to have the final code written in asm but for now this is easier to write
uint64_t genDescriptor(uint32_t offset, uint16_t selector, gate_type gate, ring_level level){
    uint64_t ret = 0x0;
    //this bit may be wrong but it's supposed to put toegether the section comprising of the P, DPL, 0 and Gatetype
    uint8_t comb = 0x80 | ring_level << 4 | gate_type;
    //upper bits of offset put in place
    ret = ((uint64_t)(offset & 0xffffffff00000000)) << 32;
    //lower bits of offset put in place
    ret |= offset & 0x00000000ffffffff;
    //type conversion is to avoid dumb shit when putting the comb in place
    ret |= ((uint64_t) comb) << 48;
    return ret;
}
