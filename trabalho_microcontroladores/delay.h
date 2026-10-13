#ifndef __DELAY_H
#define __DELAY_H

#include "stm8s.h"

/* Atrasos por software calibrados para clock de 16 MHz (HSI, CLK_PRESCALER_HSIDIV1).
   Se o clock do sistema for alterado, os valores de calibracao em delay.c
   devem ser ajustados. 
	 - Calibração realizada usando-se osciloscopio.
	 */

void delayUs(uint16_t us);
void delayMs(uint16_t ms);

#endif /* __DELAY_H */
