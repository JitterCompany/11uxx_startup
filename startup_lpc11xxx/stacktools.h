#ifndef STACKTOOLS_H
#define STACKTOOLS_H

#include <stdint.h>
#include <stdbool.h>

bool stack_valid(void);
uint32_t stack_total_size(void);
uint32_t stack_unused_size(void);

#endif
