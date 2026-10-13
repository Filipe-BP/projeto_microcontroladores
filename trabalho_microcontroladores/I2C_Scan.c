/* I2C_Scan.c - ver I2C_Scan.h */

#include "I2C_Scan.h"
#include "stm8s_gpio.h"
#include "stm8s_clk.h"
#include "stm8s_i2c.h"

/* Numero maximo de iteracoes de polling antes de desistir de uma etapa da
   transacao (START, endereco ou dado) - evita travar o firmware caso o
   barramento fique preso (SDA/SCL em curto, sem pull-up, etc.). */
#define I2C_SCAN_TIMEOUT   ((uint16_t)5000)

void I2C_Scan_BusInit(void)
{
    GPIO_Init(GPIOB, (GPIO_PIN_4 | GPIO_PIN_5), GPIO_MODE_OUT_OD_HIZ_FAST);

    CLK_PeripheralClockConfig(CLK_PERIPHERAL_I2C, ENABLE);
    I2C_DeInit();
    I2C_Init((uint32_t)100000, (uint16_t)0x00, I2C_DUTYCYCLE_2,
             I2C_ACK_CURR, I2C_ADDMODE_7BIT, (uint8_t)16);
    I2C_Cmd(ENABLE);
}

/* Envia START + endereco (sem nenhum byte de dado) e verifica se o
   escravo respondeu com ACK. Sempre termina com STOP.
   Retorna 1 se houve ACK (dispositivo presente), 0 caso contrario
   (NACK ou timeout de barramento). */
static uint8_t I2C_Scan_ProbeAddress(uint8_t address7bit)
{
    uint16_t timeout;
    uint8_t found;

    found = 0;

    I2C_GenerateSTART(ENABLE);
    timeout = I2C_SCAN_TIMEOUT;
    while (!I2C_CheckEvent(I2C_EVENT_MASTER_MODE_SELECT))
    {
        if (--timeout == 0)
        {
            I2C_GenerateSTOP(ENABLE);
            return 0;
        }
    }

    I2C_Send7bitAddress((uint8_t)(address7bit << 1), I2C_DIRECTION_TX);

    timeout = I2C_SCAN_TIMEOUT;
    while (timeout != 0)
    {
        if (I2C_CheckEvent(I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
        {
            found = 1;
            break;
        }
        if (I2C_GetFlagStatus(I2C_FLAG_ACKNOWLEDGEFAILURE))
        {
            I2C_ClearFlag(I2C_FLAG_ACKNOWLEDGEFAILURE);
            break;
        }
        timeout--;
    }

    I2C_GenerateSTOP(ENABLE);

    return found;
}

uint8_t I2C_Scan_FindDevices(uint8_t *foundAddresses, uint8_t maxAddresses)
{
    uint8_t address;
    uint8_t count;

    count = 0;
    for (address = 0x08; address <= 0x77; address++)
    {
        if (I2C_Scan_ProbeAddress(address))
        {
            if (count < maxAddresses)
            {
                foundAddresses[count] = address;
            }
            count++;
        }
    }

    return count;
}

void I2C_Scan_WriteByte(uint8_t address7bit, uint8_t data)
{
    uint16_t timeout;

    I2C_GenerateSTART(ENABLE);
    timeout = I2C_SCAN_TIMEOUT;
    while (!I2C_CheckEvent(I2C_EVENT_MASTER_MODE_SELECT))
    {
        if (--timeout == 0)
        {
            return;
        }
    }

    I2C_Send7bitAddress((uint8_t)(address7bit << 1), I2C_DIRECTION_TX);
    timeout = I2C_SCAN_TIMEOUT;
    while (!I2C_CheckEvent(I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
    {
        if (--timeout == 0)
        {
            I2C_GenerateSTOP(ENABLE);
            return;
        }
    }

    I2C_SendData(data);
    timeout = I2C_SCAN_TIMEOUT;
    while (!I2C_CheckEvent(I2C_EVENT_MASTER_BYTE_TRANSMITTED))
    {
        if (--timeout == 0)
        {
            I2C_GenerateSTOP(ENABLE);
            return;
        }
    }

    I2C_GenerateSTOP(ENABLE);
}
