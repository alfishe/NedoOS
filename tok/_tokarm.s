;startup
TRUE	= 0xff
FALSE	= 0

TRDBUF	= 0x50000000
STKBUF	= 0x201001fe

DOSBUF	= 0x20100000
FCB1	= 0x20100200

;дл€ Keil надо константу дл€ DCD определ€ть выше DCD
;	IF :LNOT: :DEF: _STRLEN
_STRLEN	= 80
;	ENDIF
;	IF :LNOT: :DEF: _STRMAX
_STRMAX	= (_STRLEN-1)
;	ENDIF 

;	IF :LNOT: :DEF: DOSBUFfreesectors
DOSBUFfreesectors	= (DOSBUF+0x00e5)
;	ENDIF
;	IF :LNOT: :DEF: DOSBUFfiles
DOSBUFfiles	= (DOSBUF+0x00e4)
;	ENDIF
;	IF :LNOT: :DEF: DOSBUFfreesector
DOSBUFfreesector	= (DOSBUF+0x00e1)
;	ENDIF 
;	IF :LNOT: :DEF: DOSBUFEND
DOSBUFEND	= (DOSBUF+0x0100)
;	ENDIF 

;	AREA    RESET, CODE, READWRITE ;READONLY
;	THUMB
        org 0x20000000 ;на 1986¬≈1 отсюда нельз€ исполн€ть код

	LDR R0,__STKBUF__
	MOV SP,R0
	MOVS R7,#0xff
	MOVS R0,#0x00
	MOV R8,R0
	LDR R1,__fnbuf__
	LDR R0,__tokenize__fn
	STR R1,[R0]
	BL tokinit
	BL tokenize
	BL tokenize_end
	B $;{PC}

	ALIGN 4
__fnbuf__
	DCD fnbuf__
__tokenize__fn
	DCD tokenize__fn
__STKBUF__
	DCD STKBUF

_JPHL__
	BX R1

;R1 >> R2
;out: R1
_SHR__
_SHRB__
	PUSH {LR}
	ASRS R1,R2
	POP {PC}

;R1 << R2
;out: R1
_SHL__
	PUSH {LR}
	LSLS R1,R2
	POP {PC}

;R1 << R2
;out: R1
_SHLB__
	PUSH {LR}
	LSLS R1,R2
	ANDS R1,R7 ;0xff
	POP {PC}

	;AREA    LIB, CODE, READWRITE

;length 0 while reading means either absence of files of zero length file (any sector length)

readf
	EXPORT readf
	PUSH {LR}
	LDR R1,readf__A__ ;poi to FCB
	B fread1__ ;R1=data ;keeps R3
readfin
	EXPORT readfin
	PUSH {LR}
	LDR R0,readfin__fin__
	LDR R1,[R0] ;poi to FCB
	B fread1__ ;R1=data ;keeps R3
fread1pp__
	PUSH {LR}
fread1__
;returns R1=data
;keeps R3
	MOVS R6,R1 ;poi to FCB
	MOVS R0,#FCB__remain ;0xff = no data, 0xfe = 1 byte, ... 0x00 = 255 bytes
	ORRS R1,R0
	LDRB R2,[R1] ;remain
	ADDS R2,#1
	STRB R2,[R1] ;remain++
		;LDR R0,readf__A__ ;poi to FCB ;нельз€, т.к. readfin тоже тут
	MOVS R0,R6 ;poi to FCB
	ADDS R0,#0xff
	ADDS R0,#1 ;poi to databuf
	ADDS R2,R0 ;poi to data
	LDRB R0,[R1] ;remain
	CMP R0,#0
	BNE fread1OK__

	PUSH {R3}
	PUSH {R1}
		;LDR R1,readf__A__ ;poi to FCB ;нельз€, т.к. readfin тоже тут
	;ORRS R1,R7 ;0xff
	;SUBS R1,#0xff ;poi to FCB
	MOVS R1,R6 ;poi to FCB
	LDR R0,readf__readnewbuf__A__
	STR R1,[R0] ;FCB
	BL readnewbuf
	CMP R1,#0 ;no new buf
	BEQ fread1EOF__
	POP {R1}
	POP {R3}
;R1 = poi to remain
	LDRB R2,[R1] ;remain
	ORRS R1,R7 ;0xff
	ADDS R1,#1 ;poi to databuf
	ADDS R2,R1 ;poi to data
fread1OK__
	LDRB R1,[R2] ;result
	POP {PC}
;EOF - next block doesn't exist
fread1EOF__
	POP {R1}
	POP {R3}
       MOVS R1,#TRUE
       LDR R0,readf__waseof__
       STRB R1,[R0]
       MOVS R1,#'\n' ;EOF returns '\n'
;set vars as they were (next time EOF again)
	STRB R7,[R1] ;remain = 0xff
	POP {PC}

fread
	EXPORT fread
	PUSH {LR}
	LDR R1,fread__A__ ;poi to data
	LDR R3,fread__C__ ;count
fread0__
	PUSH {R3}
	LDR R3,fread__B__ ;size
fread00__
	PUSH {R1}
	LDR R1,fread__D__ ;poi to FCB
	BL fread1pp__ ;R1=data ;keeps bc
	MOVS R0,R1
	POP {R1}
	STRB R0,[R1]
       LDR R0,readf__waseof__
       LDRB R0,[R0]
       CMP R0,#FALSE
       BNE freadpopret__
	ADDS R1,#1
	SUBS R3,#1
	BNE fread00__
	POP {R3}
	SUBS R3,#1
	BNE fread0__
	POP {PC}
freadpopret__
	POP {R3}
	POP {PC}

	ALIGN 4
readf__A__
	EXPORT readf__A__
	DCD 0
fread__A__
	EXPORT fread__A__
	DCD 0
fread__B__
	EXPORT fread__B__
	DCD 0
fread__C__
	EXPORT fread__C__
	DCD 0
fread__D__
	EXPORT fread__D__
	DCD 0
readfin__fin__
	DCD _fin
readf__waseof__
	DCD _waseof
readf__readnewbuf__A__
	DCD readnewbuf__A__

writebyte
	EXPORT writebyte
	PUSH {LR}
	LDR R1,writebyte__A__ ;file
	LDR R0,writebyte__B__ ;data ;LDRB
	B fwrite1__
writefout
	EXPORT writefout
	PUSH {LR}
	LDR R0,writefout__fout__
	LDR R1,[R0] ;poi to FCB
	LDR R0,writefout__A__ ;data ;LDRB
	B fwrite1__
fwrite1pp__
	PUSH {LR}
fwrite1__
;R1 = poi to FCB
;R0=data
;keeps R3
	MOVS R6,R1 ;poi to FCB
	MOVS R5,#FCB__lastlen
	ORRS R1,R5
	LDRB R5,[R1]
	MOVS R2,R5 ;lastlen (LSB)
	ADDS R2,#1
	STRB R2,[R1] ;lastlen++
	ADDS R2,R6 ;poi to FCB
	ADDS R2,#0xff ;poi to data
	STRB R0,[R2]
	CMP R5,#0xff
	BNE fwrite1OK__
;end of buf
	ADDS R1,#1 ;lastlen (HSB)
	LDRB R2,[R1]
	ADDS R2,#1
	STRB R2,[R1] ;lastlen (HSB) ++
	PUSH {R3}
	ORRS R1,R7 ;0xff
	SUBS R1,#0xff ;poi to FCB
	LDR R0,fwrite__flush___A__
	STR R1,[R0] ;FCB
	BL flush_
	POP {R3}
fwrite1OK__
	POP {PC}

fwrite
	EXPORT fwrite
	PUSH {LR}
	LDR R1,fwrite__A__ ;poi to data
	LDR R3,fwrite__C__ ;count
fwrite0__
	PUSH {R3}
	LDR R3,fwrite__B__ ;size
fwrite00__
	LDRB R0,[R1]
	PUSH {R1}
	LDR R1,fwrite__D__ ;poi to FCB
	BL fwrite1pp__ ;R0=data ;keeps bc
	POP {R1}
	ADDS R1,#1
	SUBS R3,#1
	BNE fwrite00__
	POP {R3}
	SUBS R3,#1
	BNE fwrite0__
	POP {PC}

	ALIGN 4
writebyte__A__
	EXPORT writebyte__A__
	DCD 0
writebyte__B__
	EXPORT writebyte__B__
	DCD 0 ;DCB
fwrite__A__
	EXPORT fwrite__A__
	DCD 0
fwrite__B__
	EXPORT fwrite__B__
	DCD 0
fwrite__C__
	EXPORT fwrite__C__
	DCD 0
fwrite__D__
	EXPORT fwrite__D__
	DCD 0
writefout__A__
	EXPORT writefout__A__
	DCD 0 ;DCB
fwrite__flush___A__
	DCD flush___A__
writefout__fout__
	DCD _fout

;FUNC UINT readsectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
readsectors
	PUSH {LR}
	LDR R1,readsectors__A__ ;buf
	LDR R2,readsectors__B__ ;trsec
	LDR R3,readsectors__C__ ;count

	PUSH {R2,R3} ;trsec, count

	LSLS R6,R7,#8 ;LDR R6,=0xff00
	ANDS R6,R2 ;track<<8
	ASRS R6,R6,#4 ;track<<4
	ANDS R2,R7 ;sector
	ADDS R2,R6 ;(track<<4) + sector
	LSLS R2,R2,#8
	LDR R0,readsectors__TRDBUF__
	ADDS R2,R0
	LSLS R3,R3,#6
;R2=trdbufaddr
;R3=words count

wordsR2toR1__
	LDR R0,[R2]
	ADDS R2,#4
	STR R0,[R1]
	ADDS R1,#4
	SUBS R3,#1
	BNE wordsR2toR1__

	B readwritesectorsq__ ;return R1=next sector

;FUNC UINT writesectors FORWARD(PBYTE buf, UINT trsec, BYTE count);
writesectors
	PUSH {LR}
	LDR R1,writesectors__A__ ;buf
	LDR R2,writesectors__B__ ;trsec
	LDR R3,writesectors__C__ ;count
	;B {PC}

	PUSH {R2,R3} ;trsec, count

	LSLS R6,R7,#8 ;LDR R6,=0xff00
	ANDS R6,R2 ;track<<8
	ASRS R6,R6,#4 ;track<<4
	ANDS R2,R7 ;sector
	ADDS R2,R6 ;(track<<4) + sector
	LSLS R2,R2,#8
	LDR R0,readsectors__TRDBUF__
	ADDS R2,R0
	LSLS R3,R3,#6
;R2=trdbufaddr
;R3=words count

wordsR1toR2__
	LDR R0,[R1]
	ADDS R1,#4
	STR R0,[R2]
	ADDS R2,#4
	SUBS R3,#1
	BNE wordsR1toR2__

readwritesectorsq__
	POP {R3,R2} ;count, trsec

	LSLS R6,R7,#8 ;LDR R6,=0xff00
	ANDS R6,R2 ;track<<8
	ASRS R6,R6,#4 ;track<<4
	ANDS R2,R7 ;sector
	ADDS R2,R6 ;(track<<4) + sector
	ADDS R2,R3 ;+count

	LSLS R6,R7,#4 ;LDR R6,=0x0ff0
	ANDS R6,R2 ;track<<4
	LSLS R6,R6,#4 ;track<<8
	MOVS R1,#0x0f
	ANDS R1,R2 ;sector
	ADDS R1,R6 ;(track<<4) + sector
;return R1=next sector
	POP {PC}

	ALIGN 4
readsectors__A__
	DCD 0
readsectors__B__
	DCD 0
readsectors__C__
	DCD 0 ;DCB
writesectors__A__
	DCD 0
writesectors__B__
	DCD 0
writesectors__C__
	DCD 0 ;DCB
readsectors__TRDBUF__
	DCD TRDBUF

	include "../_sdk/read.asm"
	include "token.asm"
	include "tokenz80.asm"
	;include "../_sdk/lib.i"
	;include "../_sdk/io.i"
	include "../_sdk/str.asm"
	include "../_sdk/io.asm"

	;AREA    HEAP, DATA, READWRITE

	include "../_sdk/io.var"
	include "../_sdk/read.var"
	include "../_sdk/fmttg.var"
	include "../_sdk/str.var"
	include "token.var"
	include "tokenz80.var"
fnbuf__
	DCB "str.i"
	DCB 0

	END
