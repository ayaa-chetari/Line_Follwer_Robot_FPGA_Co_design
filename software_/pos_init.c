#include <stdio.h>
#include <stdint.h>

#define START_SL     ((volatile uint32_t*) 0x00000060)

int main(void)
{
    *START_SL = 1;   // écriture dans l'adresse 0x60
    return 0;
}