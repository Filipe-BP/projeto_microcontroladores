/* I2C_Scan.h
 *
 * Utilitario de diagnostico do barramento I2C, independente da biblioteca
 * LCD_PCF8574_I2C. Serve para confirmar que o STM8 enxerga o modulo PCF8574
 * (ou qualquer outro escravo) no barramento antes de suspeitar de bugs no
 * driver do LCD em si (endereco errado, fiacao SDA/SCL trocada, falta de
 * GND comum, etc.).
 */

#ifndef __I2C_SCAN_H
#define __I2C_SCAN_H

#include "stm8s.h"

/* Configura o GPIO (PB4 = SCL, PB5 = SDA, open-drain) e o periferico I2C1
   a 100 kHz. Chame uma vez antes de usar as funcoes abaixo. */
void I2C_Scan_BusInit(void);

/* Varre os enderecos I2C de 7 bits utilizaveis (0x08 a 0x77 - fora da faixa
   reservada pelo protocolo) enviando um START + endereco para cada um e
   checando se algum escravo responde com ACK. Os enderecos encontrados sao
   gravados em foundAddresses (ate maxAddresses posicoes). Retorna a
   quantidade total de dispositivos encontrados. */
uint8_t I2C_Scan_FindDevices(uint8_t *foundAddresses, uint8_t maxAddresses);

/* Escreve um byte bruto (sem nenhuma logica de LCD) no dispositivo do
   endereco de 7 bits indicado. Usado para confirmar a comunicacao "na
   unha", por exemplo piscando o bit de backlight (0x08) do PCF8574. */
void I2C_Scan_WriteByte(uint8_t address7bit, uint8_t data);

#endif /* __I2C_SCAN_H */
