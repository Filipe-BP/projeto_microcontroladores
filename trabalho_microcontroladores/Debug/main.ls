   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.3 - 22 May 2025
   3                     ; Generator (Limited) V4.6.6 - 07 Jan 2026
  64                     ; 11 static void FormatCounter(uint16_t value, char *buffer)
  64                     ; 12 {
  66                     	switch	.text
  67  0000               L3_FormatCounter:
  69  0000 89            	pushw	x
  70       00000000      OFST:	set	0
  73                     ; 13      buffer[0] = (char)('0' + (value / 1000U) % 10U);
  75  0001 90ae03e8      	ldw	y,#1000
  76  0005 65            	divw	x,y
  77  0006 a60a          	ld	a,#10
  78  0008 62            	div	x,a
  79  0009 5f            	clrw	x
  80  000a 97            	ld	xl,a
  81  000b 1c0030        	addw	x,#48
  82  000e 9f            	ld	a,xl
  83  000f 1e05          	ldw	x,(OFST+5,sp)
  84  0011 f7            	ld	(x),a
  85                     ; 14      buffer[1] = (char)('0' + (value / 100U) % 10U);
  87  0012 1e01          	ldw	x,(OFST+1,sp)
  88  0014 a664          	ld	a,#100
  89  0016 62            	div	x,a
  90  0017 a60a          	ld	a,#10
  91  0019 62            	div	x,a
  92  001a 5f            	clrw	x
  93  001b 97            	ld	xl,a
  94  001c 1c0030        	addw	x,#48
  95  001f 9f            	ld	a,xl
  96  0020 1e05          	ldw	x,(OFST+5,sp)
  97  0022 e701          	ld	(1,x),a
  98                     ; 15      buffer[2] = (char)('0' + (value / 10U) % 10U);
 100  0024 1e01          	ldw	x,(OFST+1,sp)
 101  0026 a60a          	ld	a,#10
 102  0028 62            	div	x,a
 103  0029 a60a          	ld	a,#10
 104  002b 62            	div	x,a
 105  002c 5f            	clrw	x
 106  002d 97            	ld	xl,a
 107  002e 1c0030        	addw	x,#48
 108  0031 9f            	ld	a,xl
 109  0032 1e05          	ldw	x,(OFST+5,sp)
 110  0034 e702          	ld	(2,x),a
 111                     ; 16      buffer[3] = (char)('0' + value % 10U);
 113  0036 1e01          	ldw	x,(OFST+1,sp)
 114  0038 a60a          	ld	a,#10
 115  003a 62            	div	x,a
 116  003b 5f            	clrw	x
 117  003c 97            	ld	xl,a
 118  003d 1c0030        	addw	x,#48
 119  0040 9f            	ld	a,xl
 120  0041 1e05          	ldw	x,(OFST+5,sp)
 121  0043 e703          	ld	(3,x),a
 122                     ; 17      buffer[4] = '\0';
 124  0045 1e05          	ldw	x,(OFST+5,sp)
 125  0047 6f04          	clr	(4,x)
 126                     ; 18 }
 129  0049 85            	popw	x
 130  004a 81            	ret
 181                     ; 20 void main(void)
 181                     ; 21 {
 182                     	switch	.text
 183  004b               _main:
 185  004b 5207          	subw	sp,#7
 186       00000007      OFST:	set	7
 189                     ; 25   CLK_DeInit();
 191  004d cd0000        	call	_CLK_DeInit
 193                     ; 26   CLK_HSIPrescalerConfig(CLK_PRESCALER_HSIDIV1);
 195  0050 4f            	clr	a
 196  0051 cd0000        	call	_CLK_HSIPrescalerConfig
 198                     ; 28   LCD_Init();
 200  0054 cd0000        	call	_LCD_Init
 202                     ; 29   LCD_SetCursor(0, 0);
 204  0057 5f            	clrw	x
 205  0058 cd0000        	call	_LCD_SetCursor
 207                     ; 30   LCD_WriteString("LCD 16x2 I2C");
 209  005b ae000b        	ldw	x,#L75
 210  005e cd0000        	call	_LCD_WriteString
 212                     ; 31   LCD_SetCursor(0, 1);
 214  0061 ae0001        	ldw	x,#1
 215  0064 cd0000        	call	_LCD_SetCursor
 217                     ; 32   LCD_WriteString("Contador: ");
 219  0067 ae0000        	ldw	x,#L16
 220  006a cd0000        	call	_LCD_WriteString
 222                     ; 34   seconds = 0;
 224  006d 5f            	clrw	x
 225  006e 1f06          	ldw	(OFST-1,sp),x
 227  0070               L36:
 228                     ; 37     FormatCounter(seconds, counterText);
 230  0070 96            	ldw	x,sp
 231  0071 1c0001        	addw	x,#OFST-6
 232  0074 89            	pushw	x
 233  0075 1e08          	ldw	x,(OFST+1,sp)
 234  0077 ad87          	call	L3_FormatCounter
 236  0079 85            	popw	x
 237                     ; 38     LCD_SetCursor(10, 1);
 239  007a ae0a01        	ldw	x,#2561
 240  007d cd0000        	call	_LCD_SetCursor
 242                     ; 39     LCD_WriteString(counterText);
 244  0080 96            	ldw	x,sp
 245  0081 1c0001        	addw	x,#OFST-6
 246  0084 cd0000        	call	_LCD_WriteString
 248                     ; 40     delayMs(1000);
 250  0087 ae03e8        	ldw	x,#1000
 251  008a cd0000        	call	_delayMs
 253                     ; 41     seconds++;
 255  008d 1e06          	ldw	x,(OFST-1,sp)
 256  008f 1c0001        	addw	x,#1
 257  0092 1f06          	ldw	(OFST-1,sp),x
 259                     ; 42     if(seconds > 9999) seconds = 0;
 261  0094 1e06          	ldw	x,(OFST-1,sp)
 262  0096 a32710        	cpw	x,#10000
 263  0099 25d5          	jrult	L36
 266  009b 5f            	clrw	x
 267  009c 1f06          	ldw	(OFST-1,sp),x
 269  009e 20d0          	jra	L36
 282                     	xdef	_main
 283                     	xref	_LCD_SetCursor
 284                     	xref	_LCD_WriteString
 285                     	xref	_LCD_Init
 286                     	xref	_delayMs
 287                     	xref	_CLK_HSIPrescalerConfig
 288                     	xref	_CLK_DeInit
 289                     .const:	section	.text
 290  0000               L16:
 291  0000 436f6e746164  	dc.b	"Contador: ",0
 292  000b               L75:
 293  000b 4c4344203136  	dc.b	"LCD 16x2 I2C",0
 313                     	end
