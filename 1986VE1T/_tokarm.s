;startup
TRUE	= 0xff
FALSE	= 0

TRDBUF	= 0x60000000
STKBUF	= 0x20002000

DOSBUF	= 0x20000000
FCB1	= 0x20000100

LED_DRXTX  = 0x400c0000
LED_DSETTX = 0x400c0010
LED_DCLRTX = 0x400c0014

;для Keil надо константу для DCD определять выше DCD
;	IF :LNOT: :DEF: _STRLEN
_STRLEN	= 80
;	ENDIF
;	IF :LNOT: :DEF: _STRMAX
_STRMAX	= (_STRLEN-1)
;	ENDIF 

;	IF :LNOT: :DEF: DOSBUFfreesectors
;DOSBUFfreesectorsHSB	= (DOSBUF+0x00e6)
;	ENDIF
;	IF :LNOT: :DEF: DOSBUFfiles
;DOSBUFfiles	= (DOSBUF+0x00e4)
;	ENDIF
;	IF :LNOT: :DEF: DOSBUFfreesector
;DOSBUFfreesector	= (DOSBUF+0x00e1)
;	ENDIF 
;	IF :LNOT: :DEF: DOSBUFEND
DOSBUFEND	= (DOSBUF+0x0100)
;	ENDIF 

;	AREA    RESET, CODE, READWRITE ;READONLY
;	THUMB
        ;org 0x20100000
        org 0x600f0000

	LDR R0,__STKBUF__
	MOV SP,R0
	MOVS R7,#0xff
	MOVS R0,#0x00
	MOV R8,R0
	LDR R1,__fnbuf__
	LDR R0,__migalka__fn
	STR R1,[R0]
	BL migalka
	B $;{PC}

	ALIGN 4
__fnbuf__
	DCD fnbuf__
__migalka__fn
	DCD migalka__fn
__STKBUF__
	DCD STKBUF

	include "../_sdk/libarm.i"

	;AREA    LIB, CODE, READWRITE

	include "../_sdk/ioarm.i"
	include "../_sdk/read.asm"
	include "migalka.asm"
	include "../_sdk/str.asm"
	include "../_sdk/io.asm"

	;AREA    HEAP, DATA, READWRITE

	include "../_sdk/io.var"
	include "../_sdk/read.var"
	include "../_sdk/fmttg.var"
	include "../_sdk/str.var"
	include "migalka.var"
fnbuf__
	DCB "str.i"
	DCB 0

	END
