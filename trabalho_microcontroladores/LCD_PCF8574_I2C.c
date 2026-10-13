/* LCD_PCF8574_I2C.c
 *
 * Ver LCD_PCF8574_I2C.h para o mapeamento de pinos do backpack PCF8574.
 *
 * O barramento I2C usa os pinos dedicados PB4 (SCL) / PB5 (SDA) do STM8S,
 * configurados como saida open-drain (o proprio periferico I2C controla o
 * nivel logico dos dois fios).
 *
 * Cada escrita no LCD em modo 4 bits e composta por dois nibbles (alto e
 * baixo), cada um enviado ao PCF8574 por I2C e "travado" no LCD com um pulso
 * no pino EN. Isso significa 2 transacoes I2C por nibble (EN=1 e EN=0), ou
 * seja, 4 transacoes por comando/caractere.
 */

#include "LCD_PCF8574_I2C.h"
#include "stm8s_gpio.h"
#include "stm8s_i2c.h"
#include "stm8s_clk.h"
#include "delay.h"

/* Comandos HD44780 usados na inicializacao */
#define LCD_CMD_CLEAR_DISPLAY    ((uint8_t)0x01)
#define LCD_CMD_RETURN_HOME      ((uint8_t)0x02)
#define LCD_CMD_ENTRY_MODE_SET   ((uint8_t)0x06)  /* incrementa cursor, sem shift */
#define LCD_CMD_DISPLAY_OFF      ((uint8_t)0x08)
#define LCD_CMD_DISPLAY_ON       ((uint8_t)0x0C)  /* display on, cursor off, blink off */
#define LCD_CMD_FUNCTION_SET_4B  ((uint8_t)0x28)  /* 4 bits, 2 linhas, fonte 5x8 */
#define LCD_CMD_SET_DDRAM_ADDR   ((uint8_t)0x80)

/* Numero maximo de tentativas de polling antes de desistir de uma transacao
   I2C (evita travar o firmware caso o modulo nao responda/esteja desconectado). */
#define LCD_I2C_TIMEOUT          ((uint16_t)10000)

static uint8_t s_backlight = LCD_PIN_BL;

static void LCD_I2C_WriteByte(uint8_t data)
{
    uint16_t timeout;

    I2C_GenerateSTART(ENABLE);
    timeout = LCD_I2C_TIMEOUT;
    while (!I2C_CheckEvent(I2C_EVENT_MASTER_MODE_SELECT))
    {
        if (--timeout == 0)
        {
            return;
        }
    }

    I2C_Send7bitAddress((uint8_t)(LCD_I2C_ADDRESS << 1), I2C_DIRECTION_TX);
    timeout = LCD_I2C_TIMEOUT;
    while (!I2C_CheckEvent(I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
    {
        if (--timeout == 0)
        {
            I2C_GenerateSTOP(ENABLE);
            return;
        }
    }

    I2C_SendData(data);
    timeout = LCD_I2C_TIMEOUT;
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

/* Gera o pulso de EN exigido pelo HD44780 para "travar" um nibble ja
   presente nas linhas D4-D7 do expansor. */
static void LCD_PulseEnable(uint8_t data)
{
    LCD_I2C_WriteByte((uint8_t)(data | LCD_PIN_EN));
    delayUs(1);
    LCD_I2C_WriteByte((uint8_t)(data & (uint8_t)(~LCD_PIN_EN)));
    delayUs(50);
}

/* Envia um nibble (deve estar posicionado nos 4 bits mais significativos,
   ou seja, alinhado com D4-D7) junto com o estado de RS e do backlight. */
static void LCD_WriteNibble(uint8_t nibble, uint8_t rs)
{
    uint8_t data;

    data = (uint8_t)((nibble & 0xF0) | s_backlight);
    if (rs)
    {
        data |= LCD_PIN_RS;
    }

    LCD_PulseEnable(data);
}

static void LCD_SendByte(uint8_t value, uint8_t rs)
{
    LCD_WriteNibble(value, rs);
    LCD_WriteNibble((uint8_t)(value << 4), rs);
}

void LCD_Command(uint8_t command)
{
    LCD_SendByte(command, 0);
}

void LCD_WriteChar(char data)
{
    LCD_SendByte((uint8_t)data, 1);
}

void LCD_WriteString(const char *str)
{
    while (*str != '\0')
    {
        LCD_WriteChar(*str);
        str++;
    }
}

void LCD_Clear(void)
{
    LCD_Command(LCD_CMD_CLEAR_DISPLAY);
    delayMs(2);
}

void LCD_Home(void)
{
    LCD_Command(LCD_CMD_RETURN_HOME);
    delayMs(2);
}

void LCD_SetCursor(uint8_t col, uint8_t row)
{
    static const uint8_t rowOffset[LCD_ROWS] = {0x00, 0x40};

    if (row >= LCD_ROWS)
    {
        row = (uint8_t)(LCD_ROWS - 1);
    }
    if (col >= LCD_COLS)
    {
        col = (uint8_t)(LCD_COLS - 1);
    }

    LCD_Command((uint8_t)(LCD_CMD_SET_DDRAM_ADDR | (rowOffset[row] + col)));
}

void LCD_Backlight(uint8_t state)
{
    s_backlight = state ? LCD_PIN_BL : (uint8_t)0x00;
    LCD_I2C_WriteByte(s_backlight);
}

void LCD_Init(void)
{
    /* PB4 = SCL, PB5 = SDA: pinos dedicados do I2C1, controlados em
       open-drain pelo proprio periferico (os resistores de pull-up ficam
       no modulo PCF8574, ver R3/R4 no esquematico). */
    GPIO_Init(GPIOB, (GPIO_PIN_4 | GPIO_PIN_5), GPIO_MODE_OUT_OD_HIZ_FAST);

    CLK_PeripheralClockConfig(CLK_PERIPHERAL_I2C, ENABLE);
    I2C_DeInit();
    /* 100 kHz (I2C standard mode) com clock de entrada de 16 MHz - ver
       CLK_HSIPrescalerConfig(CLK_PRESCALER_HSIDIV1) em main.c */
    I2C_Init((uint32_t)100000, (uint16_t)0x00, I2C_DUTYCYCLE_2,
             I2C_ACK_CURR, I2C_ADDMODE_7BIT, (uint8_t)16);
    I2C_Cmd(ENABLE);

    /* Aguarda a estabilizacao da alimentacao do LCD (> 15 ms apos Vdd >= 4.5V) */
    delayMs(50);

    /* Sequencia de inicializacao "by instruction" do HD44780 para forcar o
       controlador a entrar em modo 4 bits, independentemente do estado
       anterior do display (ver datasheet HD44780, secao de inicializacao). */
    LCD_WriteNibble(0x30, 0);
    delayMs(5);
    LCD_WriteNibble(0x30, 0);
    delayUs(150);
    LCD_WriteNibble(0x30, 0);
    delayUs(150);
    LCD_WriteNibble(0x20, 0); /* agora sim seleciona a interface de 4 bits */
    delayUs(150);

    LCD_Command(LCD_CMD_FUNCTION_SET_4B);
    LCD_Command(LCD_CMD_DISPLAY_OFF);
    LCD_Command(LCD_CMD_CLEAR_DISPLAY);
    delayMs(2);
    LCD_Command(LCD_CMD_ENTRY_MODE_SET);
    LCD_Command(LCD_CMD_DISPLAY_ON);
}
