;*Z80
;---Финальный мультик
        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"
;*L+
DSCR	EQU #4000
MUSIC	EQU 25200

_128=PROGSTART+3
swapimer=PROGSTART+6
ttexpgs=PROGSTART+0x100

        macro PUSHs
	PUSH DE
	PUSH BC
	PUSH HL
	ENDM

        macro POPs
	POP HL
	POP BC
	POP DE
	ENDM

        macro Ds
	DI
	HALT
	EI
	ENDM

	ORG #8000
begin
WHO	DEFB 0 ;победили люди(0)/кунги(1)

	;ENT $ ;вх #8000
FINAL	DI
         call swapimer ;NedoOS on
	IM 1
	LD IY,#1000
	;ld e,0
	;OS_SETSCREEN
        di
        ;jr $
        ld sp,0x4000
        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,d
        SETPG16K
        
	LD SP,#7FF0
	XOR A
	OUT (254),A
	LD HL,#5800
	LD DE,#5801
	LD (HL),A
	LD BC,767
	LDIR
	LD DE,#4000
	LD HL,WINF+2
	CALL DELPZ
	LD B,8 ;декомп флик
DPZ1	PUSH BC
	LD A,B
	DEC A
	CP 2
	JR Z,DPZ0
	CP 5
	JR Z,DPZ0
	CALL MEM
	LD HL,#C000
	CALL DELPZF
DPZ0	POP BC
	DJNZ DPZ1
	;
	LD A,(WHO)
	OR A
	PUSH AF
	LD HL,MUS_H+2
	LD BC,COL_HT
	LD DE,TEXT_H
	JR Z,WF1
	LD HL,MUS_K+2
	LD BC,COL_KT
	LD DE,TEXT_K
WF1	LD (TXTB),DE
	LD (TXT),DE
	PUSH BC
	LD DE,MUSIC
	CALL DELPZ
	CALL MUSIC
	POP HL
	EXX
	CALL PAINT
	CALL PRE_S
	CALL PRE_F
	POP AF
	CALL Z,WF_H
	CALL WF_K


COL_HT	DEFB #70,#50,#58,#78, #70, #68,#60,#68,#72
COL_KT	DEFB #68,#70,#58,#78, #68, #71,#38,#48,#6F
GETC	;взять цвет
	EXX
	LD A,(HL)
	INC HL
	EXX
	LD E,A
	JP ATRBAR

PAINT	LD HL,#0
	LD BC,#C20
	CALL GETC ;
	LD HL,#610
	LD BC,#120C
	CALL GETC ;
	LD HL,#C1C
	LD BC,#C04
	CALL GETC ;
	LD HL,#400
	LD BC,#1410
	CALL GETC ;
	LD HL,#407
	LD BC,#110
	CALL GETC ;
	LD HL,#501
	LD BC,#120E
	CALL GETC ;
	LD HL,#712
	LD BC,#0F0C
	CALL GETC ;
	LD HL,#100
	LD BC,#307
	CALL GETC
	LD HL,27
	LD BC,#205
	CALL GETC
	RET

TXTB	DEFW 880;ук на нач текста
TXT	DEFW 0;ук на тек текст
TXlin	DEFB 0;линия
pTEXT	;выв строчки текста
	LD HL,TXlin
	LD A,(HL)
	INC (HL)
	CP 16
	JR C,pPT
	CP 27
	RET C
	LD (HL),0
	LD HL,(TXT)
	LD DE,12
	ADD HL,DE
	LD A,(HL)
	CP 126
	JR C,pNT
	LD HL,(TXTB)
pNT	LD (TXT),HL
	RET
pPT	SRL A
	LD C,A
	LD HL,(TXT)
	LD B,12
	LD DE,#57B2
pPT0	PUSH HL
	PUSH BC
	LD A,(HL)
	ADD A,A
	LD BC,FFONT
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,BC
	POP BC
	PUSH BC
	LD B,0
	ADD HL,BC
	LD A,(HL)
	LD (DE),A
	POP BC
	POP HL
	INC E
	INC HL
	DJNZ pPT0
	RET


fINTRP	;обработка im1
	CALL pTEXT
	XOR A
	OUT (254),A
	EI
	HALT
	DI
	CALL MUSIC+6
        
         ld a,0x7f
         in a,(0xfe)
         rra
         jr c,noquit
         ld a,0xfe
         in a,(0xfe)
         rra
         jr c,noquit
        call shutay
        ei
        QUIT
shutay
	ld de,0xe00
shutay0
	dec d
	ld bc,0xfffd
	out (c),d
	ld b,0xbf
	out (c),e
	jr nz,shutay0
	ret
noquit
	LD (SPP+1),SP
	JP SCROL
SPP	LD SP,1
	RET

;-----W_GrLib--for intro---------------
ATRADR	DEFB #58

ACOORD	LD A,L ;коорд атр HL->HL
	RLA
	RLA
	RLA
	SRL H
	RRA
	SRL H
	RRA
	SRL H
	RRA
	LD L,A
	LD A,(ATRADR)
	ADD A,H
	LD H,A
	RET

ATRBAR	;HL - adr in scr; BC-size(yx) ;E-COLOR
	PUSHs
	CALL ACOORD
ATRBA0	LD D,L
	LD A,C
ATRBA1	LD (HL),E
	INC L
	DEC A
	JR NZ,ATRBA1
	LD A,D
	ADD A,32
	LD L,A
	JR NC,ATRBA2
	INC H
ATRBA2	DJNZ ATRBA0
	POPs
	RET

;-------------------------
;---МУЛЬТФИЛЬМ------------

;*************************
P_ANI	DEFB 0 ;нач страница аним (0,3,6)
DL_ANI	DEFB 4 ;задержка анимации
;*************************

FRAME	DEFB 0 ; (#кадра - 0..15)
FDELAY	DEFB 3 ;задержка

FRWRD	LD B,16 ; 16 кадров вперёд
frw0	PUSH BC
	LD A,16
	SUB B
	LD (FRAME),A
	CALL LDIRER
	POP BC
	DJNZ frw0
	RET

FRWR8	LD B,8 ; 16 кадров вперёд
frw8	PUSH BC
	LD A,8
	SUB B
	ADD A,C
	LD (FRAME),A
	CALL LDIRER
	POP BC
	DJNZ frw8
	RET

WF_K	;победа кунгов
	LD BC,450
WK0	PUSH BC
	CALL fINTRP
	POP BC
	DEC BC
	LD A,C
	OR B
	JR NZ,WK0
	LD A,3
	LD (DL_ANI),A
WK1	XOR A
	LD (P_ANI),A
	CALL FRWRD
	LD A,3
	LD (P_ANI),A
	CALL FRWRD
	LD A,6
	LD (P_ANI),A
	CALL FRWRD
	JR WK1

WF_H	;победа людей
	LD BC,1400
WH0	PUSH BC
	CALL fINTRP
	POP BC
	DEC BC
	LD A,C
	OR B
	JR NZ,WH0
	LD A,5
	LD (DL_ANI),A
	LD A,R
	LD (RNB),A
WH1	CALL RND
	CP 90
	PUSH AF
	CALL NC,FWK1
	POP AF
	CALL C,FWK2
	JR WH1

FWK1	XOR A
	LD (P_ANI),A
	CALL FRWRD
	LD A,3
	LD (P_ANI),A
	LD C,0
	JP FRWR8

FWK2	LD A,3
	LD (P_ANI),A
	LD C,8
	CALL FRWR8
	LD A,6
	LD (P_ANI),A
	JP FRWRD


LDIRER	;один кадр
	CALL fINTRP
	LD HL,FDELAY
	PUSH HL
	LD A,(HL)
	CP 2
	CALL Z,PREFLI
	POP HL
	DEC (HL)
	JR NZ,LDIRER
	LD A,(DL_ANI)
	LD (HL),A
	;
	LD (SPPF+1),SP
	JP OUTFLI
SPPF	LD SP,#1997
	RET

RNA	DEFW 1114
RNB	DEFB 23

RND	PUSH	HL
	LD	HL,(RNA)
	INC	HL
	LD	A,H
	AND	#1F
	LD	H,A
	LD	A,(RNB)
	RRCA
	XOR	(HL)
	ADD	A,L
	LD	(RNA),HL
	LD	(RNB),A
	POP	HL
	RET

;-------быстр скрол
P_str	LD SP,1
	POPs
	EXX
	POPs
	LD SP,1
	PUSHs
	EXX
	PUSHs
	JP SPP

SCROL	EQU #B600
lines	EQU 120
PRE_S	;подгот п/п скрола текста
	LD DE,SCROL
	LD A,lines
PP0	LD HL,P_str
	LD BC,20
	LDIR
	DEC A
	JR NZ,PP0
	LD C,3
	LDIR
	LD HL,SCROL+1
	LD DE,#41F2
	CALL PRE1
	LD HL,SCROL+11
	LD DE,#40FE
PRE1	LD B,lines
PRE0	PUSH BC
	LD (HL),E
	INC HL
	LD (HL),D
	LD BC,19
	ADD HL,BC
	INC D
	LD A,D
	AND 7
	JR NZ,PRE2
	LD A,E
	ADD A,32
	LD E,A
	JR C,PRE2
	LD A,D
	SUB 8
	LD D,A
PRE2	POP BC
	DJNZ PRE0
	RET

;-------быстр выв флика
P_strF	LD SP,1
	POPs
	EXX
	POPs
	POP AF
	LD SP,1
	PUSH AF
	PUSHs
	EXX
	PUSHs
	JP SPPF

OUTFLI	EQU #A900
lineF	EQU 144
PRE_F	;подгот п/п скрола текста
	LD DE,OUTFLI
	LD A,lineF
PPF0	LD HL,P_strF
	LD BC,22
	LDIR
	DEC A
	JR NZ,PPF0
	LD C,3
	LDIR
	LD HL,OUTFLI+12
	LD DE,#40AF
	LD B,lineF
PRF0	PUSH BC
	LD (HL),E
	INC HL
	LD (HL),D
	LD BC,21
	ADD HL,BC
	INC D
	LD A,D
	AND 7
	JR NZ,PRF2
	LD A,E
	ADD A,32
	LD E,A
	JR C,PRF2
	LD A,D
	SUB 8
	LD D,A
PRF2	POP BC
	DJNZ PRF0
	RET

PREFLI	LD A,(FRAME) ;перед каждым кадром (0-15)
	CP 8
	LD E,A
	JR C,LMP2
	SUB 8
	LD E,A
	LD C,1
	JR LMP3
LMP2	LD C,0
LMP3	LD A,(P_ANI)
	ADD A,C
         push bc
	CALL MEM
         pop bc
	LD A,E
	LD HL,#C000
	OR A
	JR Z,LMP4
	LD DE,2016
LMP5	ADD HL,DE
	DEC A
	JR NZ,LMP5
LMP4	EX DE,HL
	;
	LD HL,OUTFLI+1
	LD B,lineF
PFF0	PUSH BC
	LD (HL),E
	INC HL
	LD (HL),D
	LD BC,21
	ADD HL,BC
	LD C,14
	EX DE,HL
	ADD HL,BC
	EX DE,HL
	POP BC
	DJNZ PFF0
	RET


FFONT
        incbin "DATA/WFONT.FNT"

;Декомпрессор

DLPCB	db "FCUT"
        include "XDELPZ.asm"

DELPZF	LD DE,#FFFE
;Декомпрессор
;HL - ОТКУДА И КУДА, DE - ВЕРХНЯЯ ГРАНИЦА ОБЛАСТИ
DELPZX	PUSH HL
	LD C,(HL)
	INC HL
	LD B,(HL)
	ADD	HL,BC
	LDDR
	EX	DE,HL
	INC	HL
	POP	DE
	JP	DELPZ

        if 1==1
MEM=_128
        else
;TODO fix
MEM	OR	%10000
	PUSH BC
	LD	BC,#7FFD
	OUT	(C),A
	POP BC
	RET
        endif

OFFD	XOR	A
OFFD__	LD	DE,DSCR+#1AFE
	LD	HL,DSCR+#1AFF
	LD	BC,768
	LD	(HL),A
	LDDR
	RET

WA	RLCA
BA	ADD	A,L
	LD	L,A
	JR	NC,B1
	INC	H
B1	LD	A,(HL)
	RET

TEXT_H
        incbin "DATA/WVICTHUM.DAT"
TEXT_K
        incbin "DATA/WVICTorc.DAT"


MUS_K
        incbin "BOBOV/CROW_K.LPZ"
MUS_H
        incbin "BOBOV/CROW_H.LPZ"
WINF	;окно для флика
        incbin "INTRO/WINVICT.LPZ"
        display $
end

;*L+

;---------------------------------
;*P0;
;	 ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANIu_0.LPZ
;*P1;
;	 ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANIu_1.LPZ
;*P3;
;	 ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANIv_0.LPZ
;*P4;
;	 ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANIv_1.LPZ
;*P6;
;	 ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANIw_0.LPZ
;*P7;
;	 ORG #C000
;*B ..\INTRO\FLICK.LPZ\WANIw_1.LPZ
;*P0 ;==

	savebin "brfinal.dat",begin,end-begin
