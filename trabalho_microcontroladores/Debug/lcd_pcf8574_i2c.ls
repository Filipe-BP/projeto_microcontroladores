   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.3 - 22 May 2025
   3                     ; Generator (Limited) V4.6.6 - 07 Jan 2026
  15                     	bsct
  16  0000               L3_s_backlight:
  17  0000 08            	dc.b	8
  71                     ; 36 static void LCD_I2C_WriteByte(uint8_t data)
  71                     ; 37 {
  73                     	switch	.text
  74  0000               L5_LCD_I2C_WriteByte:
  76  0000 88            	push	a
  77  0001 89            	pushw	x
  78       00000002      OFST:	set	2
  81                     ; 40     I2C_GenerateSTART(ENABLE);
  83  0002 a601          	ld	a,#1
  84  0004 cd0000        	call	_I2C_GenerateSTART
  86                     ; 41     timeout = LCD_I2C_TIMEOUT;
  88  0007 ae2710        	ldw	x,#10000
  89  000a 1f01          	ldw	(OFST-1,sp),x
  92  000c 2009          	jra	L34
  93  000e               L73:
  94                     ; 44         if (--timeout == 0)
  96  000e 1e01          	ldw	x,(OFST-1,sp)
  97  0010 1d0001        	subw	x,#1
  98  0013 1f01          	ldw	(OFST-1,sp),x
 100  0015 2724          	jreq	L6
 101                     ; 46             return;
 103  0017               L34:
 104                     ; 42     while (!I2C_CheckEvent(I2C_EVENT_MASTER_MODE_SELECT))
 106  0017 ae0301        	ldw	x,#769
 107  001a cd0000        	call	_I2C_CheckEvent
 109  001d 4d            	tnz	a
 110  001e 27ee          	jreq	L73
 111                     ; 50     I2C_Send7bitAddress((uint8_t)(LCD_I2C_ADDRESS << 1), I2C_DIRECTION_TX);
 113  0020 ae4e00        	ldw	x,#19968
 114  0023 cd0000        	call	_I2C_Send7bitAddress
 116                     ; 51     timeout = LCD_I2C_TIMEOUT;
 118  0026 ae2710        	ldw	x,#10000
 119  0029 1f01          	ldw	(OFST-1,sp),x
 122  002b 2011          	jra	L55
 123  002d               L15:
 124                     ; 54         if (--timeout == 0)
 126  002d 1e01          	ldw	x,(OFST-1,sp)
 127  002f 1d0001        	subw	x,#1
 128  0032 1f01          	ldw	(OFST-1,sp),x
 130  0034 2608          	jrne	L55
 131                     ; 56             I2C_GenerateSTOP(ENABLE);
 133  0036 a601          	ld	a,#1
 134  0038 cd0000        	call	_I2C_GenerateSTOP
 136                     ; 57             return;
 137  003b               L6:
 140  003b 5b03          	addw	sp,#3
 141  003d 81            	ret
 142  003e               L55:
 143                     ; 52     while (!I2C_CheckEvent(I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
 145  003e ae0782        	ldw	x,#1922
 146  0041 cd0000        	call	_I2C_CheckEvent
 148  0044 4d            	tnz	a
 149  0045 27e6          	jreq	L15
 150                     ; 61     I2C_SendData(data);
 152  0047 7b03          	ld	a,(OFST+1,sp)
 153  0049 cd0000        	call	_I2C_SendData
 155                     ; 62     timeout = LCD_I2C_TIMEOUT;
 157  004c ae2710        	ldw	x,#10000
 158  004f 1f01          	ldw	(OFST-1,sp),x
 161  0051 2010          	jra	L76
 162  0053               L36:
 163                     ; 65         if (--timeout == 0)
 165  0053 1e01          	ldw	x,(OFST-1,sp)
 166  0055 1d0001        	subw	x,#1
 167  0058 1f01          	ldw	(OFST-1,sp),x
 169  005a 2607          	jrne	L76
 170                     ; 67             I2C_GenerateSTOP(ENABLE);
 172  005c a601          	ld	a,#1
 173  005e cd0000        	call	_I2C_GenerateSTOP
 175                     ; 68             return;
 177  0061 20d8          	jra	L6
 178  0063               L76:
 179                     ; 63     while (!I2C_CheckEvent(I2C_EVENT_MASTER_BYTE_TRANSMITTED))
 181  0063 ae0784        	ldw	x,#1924
 182  0066 cd0000        	call	_I2C_CheckEvent
 184  0069 4d            	tnz	a
 185  006a 27e7          	jreq	L36
 186                     ; 72     I2C_GenerateSTOP(ENABLE);
 188  006c a601          	ld	a,#1
 189  006e cd0000        	call	_I2C_GenerateSTOP
 191                     ; 73 }
 193  0071 20c8          	jra	L6
 229                     ; 77 static void LCD_PulseEnable(uint8_t data)
 229                     ; 78 {
 230                     	switch	.text
 231  0073               L57_LCD_PulseEnable:
 233  0073 88            	push	a
 234       00000000      OFST:	set	0
 237                     ; 79     LCD_I2C_WriteByte((uint8_t)(data | LCD_PIN_EN));
 239  0074 aa04          	or	a,#4
 240  0076 ad88          	call	L5_LCD_I2C_WriteByte
 242                     ; 80     delayUs(1);
 244  0078 ae0001        	ldw	x,#1
 245  007b cd0000        	call	_delayUs
 247                     ; 81     LCD_I2C_WriteByte((uint8_t)(data & (uint8_t)(~LCD_PIN_EN)));
 249  007e 7b01          	ld	a,(OFST+1,sp)
 250  0080 a4fb          	and	a,#251
 251  0082 cd0000        	call	L5_LCD_I2C_WriteByte
 253                     ; 82     delayUs(50);
 255  0085 ae0032        	ldw	x,#50
 256  0088 cd0000        	call	_delayUs
 258                     ; 83 }
 261  008b 84            	pop	a
 262  008c 81            	ret
 316                     ; 87 static void LCD_WriteNibble(uint8_t nibble, uint8_t rs)
 316                     ; 88 {
 317                     	switch	.text
 318  008d               L511_LCD_WriteNibble:
 320  008d 89            	pushw	x
 321  008e 88            	push	a
 322       00000001      OFST:	set	1
 325                     ; 91     data = (uint8_t)((nibble & 0xF0) | s_backlight);
 327  008f 9e            	ld	a,xh
 328  0090 a4f0          	and	a,#240
 329  0092 ba00          	or	a,L3_s_backlight
 330  0094 6b01          	ld	(OFST+0,sp),a
 332                     ; 92     if (rs)
 334  0096 0d03          	tnz	(OFST+2,sp)
 335  0098 2706          	jreq	L541
 336                     ; 94         data |= LCD_PIN_RS;
 338  009a 7b01          	ld	a,(OFST+0,sp)
 339  009c aa01          	or	a,#1
 340  009e 6b01          	ld	(OFST+0,sp),a
 342  00a0               L541:
 343                     ; 97     LCD_PulseEnable(data);
 345  00a0 7b01          	ld	a,(OFST+0,sp)
 346  00a2 adcf          	call	L57_LCD_PulseEnable
 348                     ; 98 }
 351  00a4 5b03          	addw	sp,#3
 352  00a6 81            	ret
 396                     ; 100 static void LCD_SendByte(uint8_t value, uint8_t rs)
 396                     ; 101 {
 397                     	switch	.text
 398  00a7               L741_LCD_SendByte:
 400  00a7 89            	pushw	x
 401       00000000      OFST:	set	0
 404                     ; 102     LCD_WriteNibble(value, rs);
 406  00a8 9f            	ld	a,xl
 407  00a9 97            	ld	xl,a
 408  00aa 7b01          	ld	a,(OFST+1,sp)
 409  00ac 95            	ld	xh,a
 410  00ad adde          	call	L511_LCD_WriteNibble
 412                     ; 103     LCD_WriteNibble((uint8_t)(value << 4), rs);
 414  00af 7b02          	ld	a,(OFST+2,sp)
 415  00b1 97            	ld	xl,a
 416  00b2 7b01          	ld	a,(OFST+1,sp)
 417  00b4 4e            	swap	a
 418  00b5 a4f0          	and	a,#240
 419  00b7 95            	ld	xh,a
 420  00b8 add3          	call	L511_LCD_WriteNibble
 422                     ; 104 }
 425  00ba 85            	popw	x
 426  00bb 81            	ret
 461                     ; 106 void LCD_Command(uint8_t command)
 461                     ; 107 {
 462                     	switch	.text
 463  00bc               _LCD_Command:
 467                     ; 108     LCD_SendByte(command, 0);
 469  00bc 5f            	clrw	x
 470  00bd 95            	ld	xh,a
 471  00be ade7          	call	L741_LCD_SendByte
 473                     ; 109 }
 476  00c0 81            	ret
 511                     ; 111 void LCD_WriteChar(char data)
 511                     ; 112 {
 512                     	switch	.text
 513  00c1               _LCD_WriteChar:
 517                     ; 113     LCD_SendByte((uint8_t)data, 1);
 519  00c1 ae0001        	ldw	x,#1
 520  00c4 95            	ld	xh,a
 521  00c5 ade0          	call	L741_LCD_SendByte
 523                     ; 114 }
 526  00c7 81            	ret
 562                     ; 116 void LCD_WriteString(const char *str)
 562                     ; 117 {
 563                     	switch	.text
 564  00c8               _LCD_WriteString:
 566  00c8 89            	pushw	x
 567       00000000      OFST:	set	0
 570  00c9 200c          	jra	L742
 571  00cb               L542:
 572                     ; 120         LCD_WriteChar(*str);
 574  00cb 1e01          	ldw	x,(OFST+1,sp)
 575  00cd f6            	ld	a,(x)
 576  00ce adf1          	call	_LCD_WriteChar
 578                     ; 121         str++;
 580  00d0 1e01          	ldw	x,(OFST+1,sp)
 581  00d2 1c0001        	addw	x,#1
 582  00d5 1f01          	ldw	(OFST+1,sp),x
 583  00d7               L742:
 584                     ; 118     while (*str != '\0')
 586  00d7 1e01          	ldw	x,(OFST+1,sp)
 587  00d9 7d            	tnz	(x)
 588  00da 26ef          	jrne	L542
 589                     ; 123 }
 592  00dc 85            	popw	x
 593  00dd 81            	ret
 618                     ; 125 void LCD_Clear(void)
 618                     ; 126 {
 619                     	switch	.text
 620  00de               _LCD_Clear:
 624                     ; 127     LCD_Command(LCD_CMD_CLEAR_DISPLAY);
 626  00de a601          	ld	a,#1
 627  00e0 adda          	call	_LCD_Command
 629                     ; 128     delayMs(2);
 631  00e2 ae0002        	ldw	x,#2
 632  00e5 cd0000        	call	_delayMs
 634                     ; 129 }
 637  00e8 81            	ret
 662                     ; 131 void LCD_Home(void)
 662                     ; 132 {
 663                     	switch	.text
 664  00e9               _LCD_Home:
 668                     ; 133     LCD_Command(LCD_CMD_RETURN_HOME);
 670  00e9 a602          	ld	a,#2
 671  00eb adcf          	call	_LCD_Command
 673                     ; 134     delayMs(2);
 675  00ed ae0002        	ldw	x,#2
 676  00f0 cd0000        	call	_delayMs
 678                     ; 135 }
 681  00f3 81            	ret
 684                     .const:	section	.text
 685  0000               L372_rowOffset:
 686  0000 00            	dc.b	0
 687  0001 40            	dc.b	64
 739                     ; 137 void LCD_SetCursor(uint8_t col, uint8_t row)
 739                     ; 138 {
 740                     	switch	.text
 741  00f4               _LCD_SetCursor:
 743  00f4 89            	pushw	x
 744       00000000      OFST:	set	0
 747                     ; 141     if (row >= LCD_ROWS)
 749  00f5 9f            	ld	a,xl
 750  00f6 a102          	cp	a,#2
 751  00f8 2504          	jrult	L323
 752                     ; 143         row = (uint8_t)(LCD_ROWS - 1);
 754  00fa a601          	ld	a,#1
 755  00fc 6b02          	ld	(OFST+2,sp),a
 756  00fe               L323:
 757                     ; 145     if (col >= LCD_COLS)
 759  00fe 7b01          	ld	a,(OFST+1,sp)
 760  0100 a110          	cp	a,#16
 761  0102 2504          	jrult	L523
 762                     ; 147         col = (uint8_t)(LCD_COLS - 1);
 764  0104 a60f          	ld	a,#15
 765  0106 6b01          	ld	(OFST+1,sp),a
 766  0108               L523:
 767                     ; 150     LCD_Command((uint8_t)(LCD_CMD_SET_DDRAM_ADDR | (rowOffset[row] + col)));
 769  0108 7b02          	ld	a,(OFST+2,sp)
 770  010a 5f            	clrw	x
 771  010b 97            	ld	xl,a
 772  010c d60000        	ld	a,(L372_rowOffset,x)
 773  010f 1b01          	add	a,(OFST+1,sp)
 774  0111 aa80          	or	a,#128
 775  0113 ada7          	call	_LCD_Command
 777                     ; 151 }
 780  0115 85            	popw	x
 781  0116 81            	ret
 817                     ; 153 void LCD_Backlight(uint8_t state)
 817                     ; 154 {
 818                     	switch	.text
 819  0117               _LCD_Backlight:
 823                     ; 155     s_backlight = state ? LCD_PIN_BL : (uint8_t)0x00;
 825  0117 4d            	tnz	a
 826  0118 2704          	jreq	L43
 827  011a a608          	ld	a,#8
 828  011c 2001          	jra	L63
 829  011e               L43:
 830  011e 4f            	clr	a
 831  011f               L63:
 832  011f b700          	ld	L3_s_backlight,a
 833                     ; 156     LCD_I2C_WriteByte(s_backlight);
 835  0121 b600          	ld	a,L3_s_backlight
 836  0123 cd0000        	call	L5_LCD_I2C_WriteByte
 838                     ; 157 }
 841  0126 81            	ret
 873                     ; 159 void LCD_Init(void)
 873                     ; 160 {
 874                     	switch	.text
 875  0127               _LCD_Init:
 879                     ; 164     GPIO_Init(GPIOB, (GPIO_PIN_4 | GPIO_PIN_5), GPIO_MODE_OUT_OD_HIZ_FAST);
 881  0127 4bb0          	push	#176
 882  0129 4b30          	push	#48
 883  012b ae5005        	ldw	x,#20485
 884  012e cd0000        	call	_GPIO_Init
 886  0131 85            	popw	x
 887                     ; 166     CLK_PeripheralClockConfig(CLK_PERIPHERAL_I2C, ENABLE);
 889  0132 ae0001        	ldw	x,#1
 890  0135 cd0000        	call	_CLK_PeripheralClockConfig
 892                     ; 167     I2C_DeInit();
 894  0138 cd0000        	call	_I2C_DeInit
 896                     ; 170     I2C_Init((uint32_t)100000, (uint16_t)0x00, I2C_DUTYCYCLE_2,
 896                     ; 171              I2C_ACK_CURR, I2C_ADDMODE_7BIT, (uint8_t)16);
 898  013b 4b10          	push	#16
 899  013d 4b00          	push	#0
 900  013f 4b01          	push	#1
 901  0141 4b00          	push	#0
 902  0143 5f            	clrw	x
 903  0144 89            	pushw	x
 904  0145 ae86a0        	ldw	x,#34464
 905  0148 89            	pushw	x
 906  0149 ae0001        	ldw	x,#1
 907  014c 89            	pushw	x
 908  014d cd0000        	call	_I2C_Init
 910  0150 5b0a          	addw	sp,#10
 911                     ; 172     I2C_Cmd(ENABLE);
 913  0152 a601          	ld	a,#1
 914  0154 cd0000        	call	_I2C_Cmd
 916                     ; 175     delayMs(50);
 918  0157 ae0032        	ldw	x,#50
 919  015a cd0000        	call	_delayMs
 921                     ; 180     LCD_WriteNibble(0x30, 0);
 923  015d ae3000        	ldw	x,#12288
 924  0160 cd008d        	call	L511_LCD_WriteNibble
 926                     ; 181     delayMs(5);
 928  0163 ae0005        	ldw	x,#5
 929  0166 cd0000        	call	_delayMs
 931                     ; 182     LCD_WriteNibble(0x30, 0);
 933  0169 ae3000        	ldw	x,#12288
 934  016c cd008d        	call	L511_LCD_WriteNibble
 936                     ; 183     delayUs(150);
 938  016f ae0096        	ldw	x,#150
 939  0172 cd0000        	call	_delayUs
 941                     ; 184     LCD_WriteNibble(0x30, 0);
 943  0175 ae3000        	ldw	x,#12288
 944  0178 cd008d        	call	L511_LCD_WriteNibble
 946                     ; 185     delayUs(150);
 948  017b ae0096        	ldw	x,#150
 949  017e cd0000        	call	_delayUs
 951                     ; 186     LCD_WriteNibble(0x20, 0); /* agora sim seleciona a interface de 4 bits */
 953  0181 ae2000        	ldw	x,#8192
 954  0184 cd008d        	call	L511_LCD_WriteNibble
 956                     ; 187     delayUs(150);
 958  0187 ae0096        	ldw	x,#150
 959  018a cd0000        	call	_delayUs
 961                     ; 189     LCD_Command(LCD_CMD_FUNCTION_SET_4B);
 963  018d a628          	ld	a,#40
 964  018f cd00bc        	call	_LCD_Command
 966                     ; 190     LCD_Command(LCD_CMD_DISPLAY_OFF);
 968  0192 a608          	ld	a,#8
 969  0194 cd00bc        	call	_LCD_Command
 971                     ; 191     LCD_Command(LCD_CMD_CLEAR_DISPLAY);
 973  0197 a601          	ld	a,#1
 974  0199 cd00bc        	call	_LCD_Command
 976                     ; 192     delayMs(2);
 978  019c ae0002        	ldw	x,#2
 979  019f cd0000        	call	_delayMs
 981                     ; 193     LCD_Command(LCD_CMD_ENTRY_MODE_SET);
 983  01a2 a606          	ld	a,#6
 984  01a4 cd00bc        	call	_LCD_Command
 986                     ; 194     LCD_Command(LCD_CMD_DISPLAY_ON);
 988  01a7 a60c          	ld	a,#12
 989  01a9 cd00bc        	call	_LCD_Command
 991                     ; 195 }
 994  01ac 81            	ret
1018                     	xref	_delayMs
1019                     	xref	_delayUs
1020                     	xdef	_LCD_Backlight
1021                     	xdef	_LCD_SetCursor
1022                     	xdef	_LCD_Home
1023                     	xdef	_LCD_Clear
1024                     	xdef	_LCD_WriteString
1025                     	xdef	_LCD_WriteChar
1026                     	xdef	_LCD_Command
1027                     	xdef	_LCD_Init
1028                     	xref	_I2C_CheckEvent
1029                     	xref	_I2C_SendData
1030                     	xref	_I2C_Send7bitAddress
1031                     	xref	_I2C_GenerateSTOP
1032                     	xref	_I2C_GenerateSTART
1033                     	xref	_I2C_Cmd
1034                     	xref	_I2C_Init
1035                     	xref	_I2C_DeInit
1036                     	xref	_GPIO_Init
1037                     	xref	_CLK_PeripheralClockConfig
1056                     	end
