#include <stdio.h>
#include <stdint.h>

#define ETAT_SL     ((volatile uint32_t*) 0x00000080)
#define START_SL     ((volatile uint32_t*) 0x00000060)

int main(void)
{
    *START_SL = 1;   // écriture dans l'adresse 0x60
	while(1){
		int etat = *ETAT_SL;
		printf("%d", etat);
	}
    return 0;
}