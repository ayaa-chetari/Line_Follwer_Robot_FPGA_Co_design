#include <stdio.h>
#include <stdint.h>

#define POS_LIGNE ((volatile uint32_t*) 0x00000070)

int main()
{
    uint32_t reg;
    int8_t valeur;

    while (1)
    {
        reg = *POS_LIGNE;

        valeur = (int8_t)(reg << 4) >> 4;

        printf("Position ligne : %d\n", valeur);
    }

    return 0;
}