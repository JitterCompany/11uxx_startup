#include <string.h>
#include "stacktools.h"

extern void _vStackTop(void);
extern void _pvHeapStart(void);

#ifndef STACK_CANARY
    #define STACK_CANARY 0x5A4B3C2D
#endif

bool stack_valid(void)
{
    return (*(uint32_t *)&_pvHeapStart == (uint32_t)STACK_CANARY);
}

uint32_t stack_unused_size(void)
{
    const uint32_t *ptr = (uint32_t*)&_pvHeapStart;
    unsigned int canary = STACK_CANARY;
    while(*ptr == canary++) {
        ptr++;
        if((void*)ptr >= (void*)&_vStackTop) {
            break;
        }
    }
    return (uint32_t) ((uintptr_t)ptr - (uintptr_t)&_pvHeapStart);
}

uint32_t stack_total_size(void)
{
    return (uint32_t) ((uintptr_t)&_vStackTop - (uintptr_t)&_pvHeapStart);
}
