/* LCD_PCF8574_I2C.h
 *
 * Driver para display LCD 16x2 (controlador compativel HD44780) acoplado a um
 * modulo "backpack" PCF8574 I2C, conforme o esquematico
 * PCF8574-I2C-Backpack-Module-for-LCD-1.png.
 *
 * O PCF8574 e um expansor de I/O de 8 bits acessado via I2C; o backpack usa
 * suas 8 saidas para pilotar o LCD em modo 4 bits, mais o backlight:
 *
 *   P0 -> LCD RS      P4 -> LCD D4
 *   P1 -> LCD R/W     P5 -> LCD D5
 *   P2 -> LCD EN      P6 -> LCD D6
 *   P3 -> Backlight   P7 -> LCD D7   (via transistor Q1)
 */

#ifndef __LCD_PCF8574_I2C_H
#define __LCD_PCF8574_I2C_H

#include "stm8s.h"

/* Endereco I2C de 7 bits do modulo. As entradas A0..A2 do PCF8574 sao
   puxadas para +VCC pelos resistores R5/R6/R7 (4k7) e so vao para GND
   quando o jumper correspondente (JP1/JP2/JP3) e colocado. Com os tres
   jumpers abertos (padrao de fabrica) A0=A1=A2=1, resultando no endereco
   0x27. Ajuste este valor caso os jumpers do modulo estejam fechados. */
#ifndef LCD_I2C_ADDRESS
#define LCD_I2C_ADDRESS   ((uint8_t)0x27)
#endif

/* Mapeamento dos bits do PCF8574 para os sinais do LCD (ver cabecalho acima) */
#define LCD_PIN_RS   ((uint8_t)0x01)
#define LCD_PIN_RW   ((uint8_t)0x02)
#define LCD_PIN_EN   ((uint8_t)0x04)
#define LCD_PIN_BL   ((uint8_t)0x08)
#define LCD_PIN_D4   ((uint8_t)0x10)
#define LCD_PIN_D5   ((uint8_t)0x20)
#define LCD_PIN_D6   ((uint8_t)0x40)
#define LCD_PIN_D7   ((uint8_t)0x80)

#define LCD_ROWS     ((uint8_t)2)
#define LCD_COLS     ((uint8_t)16)

/* Inicializa o I2C, o GPIO do barramento e o controlador HD44780 (modo 4 bits,
   2 linhas, fonte 5x8, display ligado, cursor/blink desligados, tela limpa). */
void LCD_Init(void);

/* Envia um byte de comando (RS = 0) ao controlador do LCD. */
void LCD_Command(uint8_t command);

/* Escreve um caractere (RS = 1) na posicao atual do cursor. */
void LCD_WriteChar(char data);

/* Escreve uma string terminada em '\0' na posicao atual do cursor. */
void LCD_WriteString(const char *str);

/* Limpa o display e retorna o cursor para a posicao (0,0). */
void LCD_Clear(void);

/* Retorna o cursor para a posicao (0,0) sem apagar o conteudo do display. */
void LCD_Home(void);

/* Posiciona o cursor na coluna/linha indicadas (0-based). */
void LCD_SetCursor(uint8_t col, uint8_t row);

/* Liga (state != 0) ou desliga (state == 0) o backlight do modulo. */
void LCD_Backlight(uint8_t state);

#endif /* __LCD_PCF8574_I2C_H */
