   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.3 - 22 May 2025
   3                     ; Generator (Limited) V4.6.6 - 07 Jan 2026
  48                     ; 13 void I2C_Scan_BusInit(void)
  48                     ; 14 {
  50                     	switch	.text
  51  0000               _I2C_Scan_BusInit:
  55                     ; 15     GPIO_Init(GPIOB, (GPIO_PIN_4 | GPIO_PIN_5), GPIO_MODE_OUT_OD_HIZ_FAST);
  57  0000 4bb0          	push	#176
  58  0002 4b30          	push	#48
  59  0004 ae5005        	ldw	x,#20485
  60  0007 cd0000        	call	_GPIO_Init
  62  000a 85            	popw	x
  63                     ; 17     CLK_PeripheralClockConfig(CLK_PERIPHERAL_I2C, ENABLE);
  65  000b ae0001        	ldw	x,#1
  66  000e cd0000        	call	_CLK_PeripheralClockConfig
  68                     ; 18     I2C_DeInit();
  70  0011 cd0000        	call	_I2C_DeInit
  72                     ; 19     I2C_Init((uint32_t)100000, (uint16_t)0x00, I2C_DUTYCYCLE_2,
  72                     ; 20              I2C_ACK_CURR, I2C_ADDMODE_7BIT, (uint8_t)16);
  74  0014 4b10          	push	#16
  75  0016 4b00          	push	#0
  76  0018 4b01          	push	#1
  77  001a 4b00          	push	#0
  78  001c 5f            	clrw	x
  79  001d 89            	pushw	x
  80  001e ae86a0        	ldw	x,#34464
  81  0021 89            	pushw	x
  82  0022 ae0001        	ldw	x,#1
  83  0025 89            	pushw	x
  84  0026 cd0000        	call	_I2C_Init
  86  0029 5b0a          	addw	sp,#10
  87                     ; 21     I2C_Cmd(ENABLE);
  89  002b a601          	ld	a,#1
  90  002d cd0000        	call	_I2C_Cmd
  92                     ; 22 }
  95  0030 81            	ret
 154                     ; 28 static uint8_t I2C_Scan_ProbeAddress(uint8_t address7bit)
 154                     ; 29 {
 155                     	switch	.text
 156  0031               L12_I2C_Scan_ProbeAddress:
 158  0031 88            	push	a
 159  0032 5203          	subw	sp,#3
 160       00000003      OFST:	set	3
 163                     ; 33     found = 0;
 165  0034 0f01          	clr	(OFST-2,sp)
 167                     ; 35     I2C_GenerateSTART(ENABLE);
 169  0036 a601          	ld	a,#1
 170  0038 cd0000        	call	_I2C_GenerateSTART
 172                     ; 36     timeout = I2C_SCAN_TIMEOUT;
 174  003b ae1388        	ldw	x,#5000
 175  003e 1f02          	ldw	(OFST-1,sp),x
 178  0040 2011          	jra	L55
 179  0042               L15:
 180                     ; 39         if (--timeout == 0)
 182  0042 1e02          	ldw	x,(OFST-1,sp)
 183  0044 1d0001        	subw	x,#1
 184  0047 1f02          	ldw	(OFST-1,sp),x
 186  0049 2608          	jrne	L55
 187                     ; 41             I2C_GenerateSTOP(ENABLE);
 189  004b a601          	ld	a,#1
 190  004d cd0000        	call	_I2C_GenerateSTOP
 192                     ; 42             return 0;
 194  0050 4f            	clr	a
 196  0051 2048          	jra	L01
 197  0053               L55:
 198                     ; 37     while (!I2C_CheckEvent(I2C_EVENT_MASTER_MODE_SELECT))
 200  0053 ae0301        	ldw	x,#769
 201  0056 cd0000        	call	_I2C_CheckEvent
 203  0059 4d            	tnz	a
 204  005a 27e6          	jreq	L15
 205                     ; 46     I2C_Send7bitAddress((uint8_t)(address7bit << 1), I2C_DIRECTION_TX);
 207  005c 7b04          	ld	a,(OFST+1,sp)
 208  005e 48            	sll	a
 209  005f 5f            	clrw	x
 210  0060 95            	ld	xh,a
 211  0061 cd0000        	call	_I2C_Send7bitAddress
 213                     ; 48     timeout = I2C_SCAN_TIMEOUT;
 215  0064 ae1388        	ldw	x,#5000
 216  0067 1f02          	ldw	(OFST-1,sp),x
 218  0069               L36:
 219                     ; 51         if (I2C_CheckEvent(I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
 221  0069 ae0782        	ldw	x,#1922
 222  006c cd0000        	call	_I2C_CheckEvent
 224  006f 4d            	tnz	a
 225  0070 2706          	jreq	L17
 226                     ; 53             found = 1;
 228  0072 a601          	ld	a,#1
 229  0074 6b01          	ld	(OFST-2,sp),a
 231                     ; 54             break;
 233  0076 201c          	jra	L76
 234  0078               L17:
 235                     ; 56         if (I2C_GetFlagStatus(I2C_FLAG_ACKNOWLEDGEFAILURE))
 237  0078 ae0204        	ldw	x,#516
 238  007b cd0000        	call	_I2C_GetFlagStatus
 240  007e 4d            	tnz	a
 241  007f 2708          	jreq	L37
 242                     ; 58             I2C_ClearFlag(I2C_FLAG_ACKNOWLEDGEFAILURE);
 244  0081 ae0204        	ldw	x,#516
 245  0084 cd0000        	call	_I2C_ClearFlag
 247                     ; 59             break;
 249  0087 200b          	jra	L76
 250  0089               L37:
 251                     ; 61         timeout--;
 253  0089 1e02          	ldw	x,(OFST-1,sp)
 254  008b 1d0001        	subw	x,#1
 255  008e 1f02          	ldw	(OFST-1,sp),x
 257                     ; 49     while (timeout != 0)
 257                     ; 50     {
 257                     ; 51         if (I2C_CheckEvent(I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
 257                     ; 52         {
 257                     ; 53             found = 1;
 257                     ; 54             break;
 257                     ; 55         }
 257                     ; 56         if (I2C_GetFlagStatus(I2C_FLAG_ACKNOWLEDGEFAILURE))
 257                     ; 57         {
 257                     ; 58             I2C_ClearFlag(I2C_FLAG_ACKNOWLEDGEFAILURE);
 257                     ; 59             break;
 257                     ; 60         }
 257                     ; 61         timeout--;
 259  0090 1e02          	ldw	x,(OFST-1,sp)
 260  0092 26d5          	jrne	L36
 261  0094               L76:
 262                     ; 64     I2C_GenerateSTOP(ENABLE);
 264  0094 a601          	ld	a,#1
 265  0096 cd0000        	call	_I2C_GenerateSTOP
 267                     ; 66     return found;
 269  0099 7b01          	ld	a,(OFST-2,sp)
 271  009b               L01:
 273  009b 5b04          	addw	sp,#4
 274  009d 81            	ret
 338                     ; 69 uint8_t I2C_Scan_FindDevices(uint8_t *foundAddresses, uint8_t maxAddresses)
 338                     ; 70 {
 339                     	switch	.text
 340  009e               _I2C_Scan_FindDevices:
 342  009e 89            	pushw	x
 343  009f 89            	pushw	x
 344       00000002      OFST:	set	2
 347                     ; 74     count = 0;
 349  00a0 0f01          	clr	(OFST-1,sp)
 351                     ; 75     for (address = 0x08; address <= 0x77; address++)
 353  00a2 a608          	ld	a,#8
 354  00a4 6b02          	ld	(OFST+0,sp),a
 356  00a6               L721:
 357                     ; 77         if (I2C_Scan_ProbeAddress(address))
 359  00a6 7b02          	ld	a,(OFST+0,sp)
 360  00a8 ad87          	call	L12_I2C_Scan_ProbeAddress
 362  00aa 4d            	tnz	a
 363  00ab 2712          	jreq	L531
 364                     ; 79             if (count < maxAddresses)
 366  00ad 7b01          	ld	a,(OFST-1,sp)
 367  00af 1107          	cp	a,(OFST+5,sp)
 368  00b1 240a          	jruge	L731
 369                     ; 81                 foundAddresses[count] = address;
 371  00b3 7b01          	ld	a,(OFST-1,sp)
 372  00b5 5f            	clrw	x
 373  00b6 97            	ld	xl,a
 374  00b7 72fb03        	addw	x,(OFST+1,sp)
 375  00ba 7b02          	ld	a,(OFST+0,sp)
 376  00bc f7            	ld	(x),a
 377  00bd               L731:
 378                     ; 83             count++;
 380  00bd 0c01          	inc	(OFST-1,sp)
 382  00bf               L531:
 383                     ; 75     for (address = 0x08; address <= 0x77; address++)
 385  00bf 0c02          	inc	(OFST+0,sp)
 389  00c1 7b02          	ld	a,(OFST+0,sp)
 390  00c3 a178          	cp	a,#120
 391  00c5 25df          	jrult	L721
 392                     ; 87     return count;
 394  00c7 7b01          	ld	a,(OFST-1,sp)
 397  00c9 5b04          	addw	sp,#4
 398  00cb 81            	ret
 455                     ; 90 void I2C_Scan_WriteByte(uint8_t address7bit, uint8_t data)
 455                     ; 91 {
 456                     	switch	.text
 457  00cc               _I2C_Scan_WriteByte:
 459  00cc 89            	pushw	x
 460  00cd 89            	pushw	x
 461       00000002      OFST:	set	2
 464                     ; 94     I2C_GenerateSTART(ENABLE);
 466  00ce a601          	ld	a,#1
 467  00d0 cd0000        	call	_I2C_GenerateSTART
 469                     ; 95     timeout = I2C_SCAN_TIMEOUT;
 471  00d3 ae1388        	ldw	x,#5000
 472  00d6 1f01          	ldw	(OFST-1,sp),x
 475  00d8 2009          	jra	L371
 476  00da               L761:
 477                     ; 98         if (--timeout == 0)
 479  00da 1e01          	ldw	x,(OFST-1,sp)
 480  00dc 1d0001        	subw	x,#1
 481  00df 1f01          	ldw	(OFST-1,sp),x
 483  00e1 2726          	jreq	L61
 484                     ; 100             return;
 486  00e3               L371:
 487                     ; 96     while (!I2C_CheckEvent(I2C_EVENT_MASTER_MODE_SELECT))
 489  00e3 ae0301        	ldw	x,#769
 490  00e6 cd0000        	call	_I2C_CheckEvent
 492  00e9 4d            	tnz	a
 493  00ea 27ee          	jreq	L761
 494                     ; 104     I2C_Send7bitAddress((uint8_t)(address7bit << 1), I2C_DIRECTION_TX);
 496  00ec 7b03          	ld	a,(OFST+1,sp)
 497  00ee 48            	sll	a
 498  00ef 5f            	clrw	x
 499  00f0 95            	ld	xh,a
 500  00f1 cd0000        	call	_I2C_Send7bitAddress
 502                     ; 105     timeout = I2C_SCAN_TIMEOUT;
 504  00f4 ae1388        	ldw	x,#5000
 505  00f7 1f01          	ldw	(OFST-1,sp),x
 508  00f9 2011          	jra	L502
 509  00fb               L102:
 510                     ; 108         if (--timeout == 0)
 512  00fb 1e01          	ldw	x,(OFST-1,sp)
 513  00fd 1d0001        	subw	x,#1
 514  0100 1f01          	ldw	(OFST-1,sp),x
 516  0102 2608          	jrne	L502
 517                     ; 110             I2C_GenerateSTOP(ENABLE);
 519  0104 a601          	ld	a,#1
 520  0106 cd0000        	call	_I2C_GenerateSTOP
 522                     ; 111             return;
 523  0109               L61:
 526  0109 5b04          	addw	sp,#4
 527  010b 81            	ret
 528  010c               L502:
 529                     ; 106     while (!I2C_CheckEvent(I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED))
 531  010c ae0782        	ldw	x,#1922
 532  010f cd0000        	call	_I2C_CheckEvent
 534  0112 4d            	tnz	a
 535  0113 27e6          	jreq	L102
 536                     ; 115     I2C_SendData(data);
 538  0115 7b04          	ld	a,(OFST+2,sp)
 539  0117 cd0000        	call	_I2C_SendData
 541                     ; 116     timeout = I2C_SCAN_TIMEOUT;
 543  011a ae1388        	ldw	x,#5000
 544  011d 1f01          	ldw	(OFST-1,sp),x
 547  011f 2010          	jra	L712
 548  0121               L312:
 549                     ; 119         if (--timeout == 0)
 551  0121 1e01          	ldw	x,(OFST-1,sp)
 552  0123 1d0001        	subw	x,#1
 553  0126 1f01          	ldw	(OFST-1,sp),x
 555  0128 2607          	jrne	L712
 556                     ; 121             I2C_GenerateSTOP(ENABLE);
 558  012a a601          	ld	a,#1
 559  012c cd0000        	call	_I2C_GenerateSTOP
 561                     ; 122             return;
 563  012f 20d8          	jra	L61
 564  0131               L712:
 565                     ; 117     while (!I2C_CheckEvent(I2C_EVENT_MASTER_BYTE_TRANSMITTED))
 567  0131 ae0784        	ldw	x,#1924
 568  0134 cd0000        	call	_I2C_CheckEvent
 570  0137 4d            	tnz	a
 571  0138 27e7          	jreq	L312
 572                     ; 126     I2C_GenerateSTOP(ENABLE);
 574  013a a601          	ld	a,#1
 575  013c cd0000        	call	_I2C_GenerateSTOP
 577                     ; 127 }
 579  013f 20c8          	jra	L61
 592                     	xdef	_I2C_Scan_WriteByte
 593                     	xdef	_I2C_Scan_FindDevices
 594                     	xdef	_I2C_Scan_BusInit
 595                     	xref	_I2C_ClearFlag
 596                     	xref	_I2C_GetFlagStatus
 597                     	xref	_I2C_CheckEvent
 598                     	xref	_I2C_SendData
 599                     	xref	_I2C_Send7bitAddress
 600                     	xref	_I2C_GenerateSTOP
 601                     	xref	_I2C_GenerateSTART
 602                     	xref	_I2C_Cmd
 603                     	xref	_I2C_Init
 604                     	xref	_I2C_DeInit
 605                     	xref	_GPIO_Init
 606                     	xref	_CLK_PeripheralClockConfig
 625                     	end
