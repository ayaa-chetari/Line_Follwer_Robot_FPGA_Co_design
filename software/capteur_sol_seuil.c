#include <stdio.h>
#include <stdint.h>

#define NIVEAU_BASE      0x00000040
#define VECT_CAPT_BASE   0x00000050
#define DATA_READY_BASE  0x00000020

#define REG32(addr) (*(volatile uint32_t *)(addr))

int main(void)
{
    uint32_t niveau = 104;
    uint32_t ready;
    uint32_t vect_capt;
    volatile int i;

    printf("Test capteurs_sol_seuil\n");

    /* Ecriture du seuil */
    REG32(NIVEAU_BASE) = niveau;

    while (1)
    {
        ready = REG32(DATA_READY_BASE) & 0x01;

        if (ready)
        {
            vect_capt = REG32(VECT_CAPT_BASE) & 0x7F;

            printf("niveau = %lu | vect_capt = 0x%02lX\n",
                   (unsigned long)niveau,
                   (unsigned long)vect_capt);
        }

        for (i = 0; i < 500000; i++);
    }

    return 0;
}