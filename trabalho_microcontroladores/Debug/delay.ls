   1                     ; C Compiler for STM8 (COSMIC Software)
   2                     ; Parser V4.13.3 - 22 May 2025
   3                     ; Generator (Limited) V4.6.6 - 07 Jan 2026
  55                     ; 11 void delayUs(uint16_t us)
  55                     ; 12 {
  57                     	switch	.text
  58  0000               _delayUs:
  60  0000 89            	pushw	x
  61       00000000      OFST:	set	0
  64  0001 2003          	jra	L13
  65  0003               L72:
  66                     ; 15         _asm("nop");
  69  0003 9d            nop
  71                     ; 16         _asm("nop");
  74  0004 9d            nop
  76                     ; 17         _asm("nop");
  79  0005 9d            nop
  81  0006               L13:
  82                     ; 13     while (us--)
  84  0006 1e01          	ldw	x,(OFST+1,sp)
  85  0008 1d0001        	subw	x,#1
  86  000b 1f01          	ldw	(OFST+1,sp),x
  87  000d 1c0001        	addw	x,#1
  88  0010 a30000        	cpw	x,#0
  89  0013 26ee          	jrne	L72
  90                     ; 19 }
  93  0015 85            	popw	x
  94  0016 81            	ret
 129                     ; 21 void delayMs(uint16_t ms)
 129                     ; 22 {
 130                     	switch	.text
 131  0017               _delayMs:
 133  0017 89            	pushw	x
 134       00000000      OFST:	set	0
 137  0018 2005          	jra	L55
 138  001a               L35:
 139                     ; 25         delayUs(1000);
 141  001a ae03e8        	ldw	x,#1000
 142  001d ade1          	call	_delayUs
 144  001f               L55:
 145                     ; 23     while (ms--)
 147  001f 1e01          	ldw	x,(OFST+1,sp)
 148  0021 1d0001        	subw	x,#1
 149  0024 1f01          	ldw	(OFST+1,sp),x
 150  0026 1c0001        	addw	x,#1
 151  0029 a30000        	cpw	x,#0
 152  002c 26ec          	jrne	L35
 153                     ; 27 }
 156  002e 85            	popw	x
 157  002f 81            	ret
 170                     	xdef	_delayMs
 171                     	xdef	_delayUs
 190                     	end
