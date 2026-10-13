#include "delay.h"

/* Funcoes de atraso por software (busy-wait).
   Calibradas empiricamente para o clock de 16 MHz (HSI, CLK_PRESCALER_HSIDIV1),
   compiladas sem otimizacao do compilador (config Debug do projeto).
   Nao sao precisas: dependem do nivel de otimizacao do compilador Cosmic.
   Para atrasos precisos, utilize um timer da SPL (ex.: TIM4). 
	 - Calibração realizada usando-se osciloscopio.
	 */

void delayUs(uint16_t us)
{
    while (us--)
    {
        _asm("nop");
        _asm("nop");
        _asm("nop");
    }
}

void delayMs(uint16_t ms)
{
    while (ms--)
    {
        delayUs(1000);
    }
}
