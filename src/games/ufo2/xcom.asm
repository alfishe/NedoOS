        DEVICE ZXSPECTRUM1024
        include "../../_sdk/sys_h.asm"

        SLOT 0
        page 63 ;иначе по умолчанию в 0x0000 pg7
        SLOT 3 

IMVEC=#4100
IM2=0

PROTECT=0
CHEATS=1
NOENEMY=0;1

;*L-
;*Z80
;*O
;*M-
;*D-
;D$	MAC ;debug
	;DI
	;HALT
	;ENDM

        include "macro.asm"

        PAGE 8
        org 0xc000
        ds 0x0400 ;чтобы в одной странице ровно 5 рядов спрайтов
        include "sprites1.ast"
	savebin "ufo2/ufospr1.dat",0xc000,$-0xc000
        display "endsprites=",$
        PAGE 9
        org 0xc000
        include "sprites2.ast"
	savebin "ufo2/ufospr2.dat",0xc000,$-0xc000
        display "endsprites2=",$
        ;PAGE 10
        ;org 0xc000
        ;include "sprites3.ast"
	;savebin "ufo2/ufospr3.dat",0xc000,$-0xc000
        ;display "endsprites3=",$
        ;PAGE 11
        ;org 0xc000
        ;include "sprites4.ast"
	;savebin "ufo2/ufospr4.dat",0xc000,$-0xc000
        ;display "endsprites4=",$
        ;PAGE 12
        ;org 0xc000
        ;include "sprites5.ast"
	;savebin "ufo2/ufospr5.dat",0xc000,$-0xc000
        ;display "endsprites5=",$
        PAGE 13
        org 0xc000
        include "xm0.ast"
        include "xm11a.ast"
	savebin "ufo2/ufoxm11a.dat",0xc000,$-0xc000
        PAGE 14
        org 0xc000
        include "xm11b.ast"
        ;include "sprites1.ast"
	savebin "ufo2/ufoxm11b.dat",0xc000,$-0xc000

;*F	XPAGE
;содержимое страниц
;СТРАНИЦЫ: c #C000
;0: #C000:
;1: #C000:T(256<),TWCMPR(256),WORDS,MENUS,PEDIA,NAMES
;2: *main*
;3: #C000:xSprites,xSHIP,xUFO
;4: #C000:xHERO(12k=8*16*96),#F000:xDIE(768),#F300:xBOOM(768),#F600
;5: *main*
;6: *swap*
;7: #C000:SCR,#D800:ATR,#DB00:
;*P4 ***********Страница 4***********
        PAGE 4
	ORG #C000
begin4
;*B ..\data\xhero.dat
        incbin "data/xhero.dat"
xSHIP
;*B ..\ZX_DISC\XM0.LPC
        ;incbin "ZX_DISC/XM0.LPC"
        incbin "ZX_DISC/xm0.mlz"
	ds #FFFE-$;DEFR
end4
;*P3 ***********Cтраница 3***********
        PAGE 3
	ORG #C000
begin3
xEARTH
;*B ..\data\xsprites.dat
        incbin "data/xsprites.dat"
xWEAPON	EQU xEARTH+2880
xBUTTON EQU xEARTH+3840
xWBUTTN EQU xBUTTON+128
xBBUTTN EQU xWBUTTN+96
xSIGN	EQU xEARTH+4192
xPARAM	EQU xEARTH+5056
xKEY	EQU xEARTH+5536
xPLUS	EQU xKEY+576
xLABEL	EQU xEARTH+6304
xMAP	EQU xEARTH+7136
xMARKER
;*B ..\ZX_DISC\xmarker.dat
        incbin "ZX_DISC/xmarker.dat"
xUFO	
;*B ..\ZX_DISC\XM1.LPC
        ;incbin "ZX_DISC/XM1.LPC"
        incbin "ZX_DISC/xm1.mlz"
xL0
;*B ..\ZX_DISC\XL0.LPC
        ;incbin "ZX_DISC/XL0.LPC"
        incbin "ZX_DISC/XL0.mlz"
xL1
;*B ..\ZX_DISC\XL1.LPC
        ;incbin "ZX_DISC/XL1.LPC"
        incbin "ZX_DISC/XL1.mlz"
end3
;*P1 ***********Cтраница 1***********
        PAGE 1
	ORG #C000
begin1
T
;*B ..\data\x256.dat
        incbin "data/x256.dat"
TWCMPR
;*B ..\data\xcompres.dat
        incbin "data/xcompres.dat"
WORDS
;*B ..\data\xword.dat
        incbin "data/xword.dat"
MENUS
;*B ..\data\xmenu.dat
        incbin "data/xmenu.dat"
PEDIA
;*B ..\data\xfopedia.dat
        incbin "data/xfopedia.dat"
NAMES
;*B ..\data\xname.dat
        incbin "data/xname.dat"
	;DEFR #FFFE-$
        ds #FFFE-$
end1
;*P7 ***********Cтраница 7***********
        PAGE 7
	ORG #C000
begin7
;*B ..\IMAGES\XHIST.SCR
        incbin "images/XHIST.SCR"
	DEFS 1024,0
	db " No room for STS 4.x!  Please reload..."
;сюда процедурой SWPBAT с адреса SwpMEM #E600 кладётся кусок памяти из SwpADR #7580 длиной #1A00 (при этом DSCR=#9000)
        
end7
;*P0
        PAGE 0       

        org PROGSTART
begin
        include "loader.asm"
        
	ORG #4000+16
beginmain
	;ENT $
JP_ST	JP xSTART ;вх.
	ds #4040-$ ;DEFR
;Interupt entry
INTRP
       if 1
        push af
        ld a,(SEED)
        inc a
        ld (SEED),a
        jr nz,INTR2
        ld a,(SEED+1)
        inc a
        ld (SEED+1),a
INTR2
        pop af
        ei
        ret
       else
	PUSH HL
	LD HL,SEED
	INC (HL)
	JR NZ,INTR2
	INC HL
	INC (HL)
INTR2	POP HL
	EI
	RETI
       endif
;SEED	DEFW 1 ;счётчик
NRFT	DEFB 1 ;для XIO
;Interupt table
;==================================обслуживание клавиатуры
PRSROW	IN	A,(C)
	CPL
	AND	#1F
	RET

;TMO	LD	A,(KEYJOY)
;	OR	A
;	JR	NZ,TMOJOY
;	LD	C,#FE
;	LD	B,C
;TMOO	CALL	PRSROW
;	JR	NZ,TMOOK
;	RLC	B
;	JR	TMOO
;TMOOK	LD	C,A
;	RET
;TMOJOY	CALL	CONTR
;	OR	A
;	JR	Z,TMOJOY
;	RET

PRSKEY	PUSH	BC
	LD	C,#FE
	CALL	PRSROW
	POP	BC
	AND	C
	RET

        display "CONTR=",$
CONTR	PUSHs;$
	LD	A,(KEYJOY)
	OR	A
	JR	Z,CO1
	LD	C,#1F
	CALL	PRSROW
	XOR	#1F
CO2	LD	(CONTRB),A
	LD 	A,(PMOUSE)
	OR	A
	CALL	NZ,MOUSE
	POPs;$
	LD 	A,(CONTRB)
	RET
CO1	LD	HL,(KEYS)
	LD	E,0
	LD	D,5
CO3	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	CALL	PRSKEY
	JR	Z,CO4
	SET	5,E
CO4	RRC	E
	DEC	D
	INC	HL
	JR	NZ,CO3
	LD	A,E
	JR	CO2

DELAY	EI
	HALT
	DI
	DEC A
	JR NZ,DELAY
	RET Z

;*************Параметры настройки игры**
C_ONOF	DEFB	0;0-вкл/1-выкл
KEYN	DEFB	0
KEYS	DEFW	KBR
KEYJOY	DEFB	0 ;(1-K.-stick)
PMOUSE	DEFB    0 ;(1-K.-mouse)

CFGLEN	EQU	$-C_ONOF
;***************************************
CONTRB	DEFB	0
KBR	DEFW	#DF01,#DF02,#FD01,#FB01,#7F07
KBR2	DEFW	#7F04,#7F08,#FE02,#FD01,#7F03
INT2	DEFW	#EF08,#EF10,#EF04,#EF02,#EF01
KUR	DEFW	#EF04,#F710,#EF10,#EF08,#EF01 ;;;

RND	PUSH	HL
	LD	HL,(RNA)
	INC	HL
;;;	LD	A,R
;;;	ADD	A,H
	LD	A,H ;;;
	AND	#1F
	LD	H,A
	LD	A,(RNB)
	RRCA
	XOR	(HL)
	ADD 	A,L
	LD	(RNA),HL
	LD	(RNB),A
	POP	HL
	RET

	;DEFR #4100-$,#40
	ds IMVEC-$,#40
	DEFS 257,#40

xSTART	DI
	LD SP,#4030
	CALL START1 ;нач.уст.защиты
	LD A,2
	OUT (254),A
	;ост после защиты
	CALL MU_ENT
	XOR A
	OUT (254),A
	CALL JP_ST
start	DI
	LD SP,#4040
       if IM2
	LD A,#41
	LD I,A
	IM 2
       else
       call swapimer
       endif
	CALL START2 ;нач.уст
	CALL BACK
       ;call SWPBAT
	LD IX,MUST
	CALL MENUC
	CALL MU_ENT
	CALL NO_3D
       if 1
       ld a,1
       ld (T_INTR),a ;тип истребителя
       ld a,1
       ld (AQU),a ;число акванавтов
       ld (AQNAVT),a ;имя
       xor a
       ld (AQNAVT+6),a ;wound
       ld a,7
       ld (AQNAVT+1),a ;ранг
       endif
       if 0
       ld a,1
       ld (T_UFO),a
       ld (AQU),a ;число акванавтов
       ld (AQNAVT),a ;имя
       ld a,7
       ld (AQNAVT+1),a ;ранг
       call BATTLE
       endif
       ;call BATTL1
	CALL MLOOP	;---начало
;	CALL XEARTH  ;--удали
;	CALL COPYAT  ;
;	LD A,0       ;
;	LD (T_INTR),A;
;	LD A,4       ;
;	LD (TARoff),A;
;	LD (NRECR),A ;
;	LD (AQU),A   ;
;	CALL RECRUT  ;
;	CALL MLOOP

MUST	DEFW #202,#3412
MU_ENT	LD A,#BF ;ждать ENTER
	IN A,(#FE)
	RRA
	JR C,MU_ENT
	RET NC
NO_3D	RRCA ;откл 3D боя
	RRCA
	RRCA
	LD HL,xHAC2
	RET C
	INC (HL)
	RET
;Main procedures
;*F	XMAIN
;**** HЛО-2. Дьяволы бездны ****
;*M-
;*D-
	DEFB 0
SYSINI	DEFB 28 ;systxt 28
MONINI	DEFB 1 ;1/0 в ScrBU нет/есть текст
xHACK	DEFB #7;F;если 7f, то видимое поле []
;*F xLID
        include "xlid.asm"
;*F xGamedat
        include "xgamedat.asm"
FONT
;*B ..\data\xfont.dat
        incbin "data/xfont.dat"
CRC3	DEFB 11
;*L+
TAB100	ds 98;DEFR 98
	DEFB #15,#88 ;таблица плохих секторов
;*L-
;*F xlib
        ;include "xlib.asm"
;CRC2	DEFW 0;[] -crc2
xHAC2	DEFB #D5;D6;если D6, то нет боя []
;*F xlie
        include "xlie.asm"
;--------swap-область
;*L+
;*F XLIN
        include "xlin.asm"
;*F xliM
        include "xlim.asm"
;*F XLIK
        include "xlik.asm"
;*L+
;*D-
	;DEFR #8F3F-$
	ds #8F3F-$
	db " Область для размещения стека "
	DEFS #9000-$,#CC
;*L-
;*F xLI1 ;нач. уст
        include "xli1.asm"
	ORG $
end



LESHA	DISP #B000
;*F xLESHA
        include "xlesha.asm"
	ent;ENDD
endLESHA

;*P0 *********** Страница 0 ***********
        PAGE 0
	ORG #C000
begin0
;блок для упаковки BLK2?
ASMBL1	DISP #AB00
;*F xlix
        include "xlix.asm"
	ent;ENDD
	ORG $
;блок для упаковки BLK3?
ASMBL2	DISP SwpADR
;*F XLIC
        include "xlic.asm"
;*L+
	DEFB $/256,$&0xff ;xlic
;*L-
	ent;ENDD
	ORG $
;блок для упаковки BLK4?
ASMBL3	DISP SwpADR
;*F XLIF
        include "xlif.asm"
;*F XIOD
        include "xiod.asm"
;*L+
	DEFB $/256,$&0xff ;xliF+xioD
;*L-
	ent;ENDD
end0

        savebin "blk1.bin",LESHA,endLESHA-LESHA
        savebin "blk2.bin",ASMBL1,ASMBL2-ASMBL1
        savebin "blk3.bin",ASMBL2,ASMBL3-ASMBL2
        savebin "blk4.bin",ASMBL3,end0-ASMBL3

        page 0
	savebin "ufo2/ufo2main.dat",beginmain,end-beginmain
        page 1
	savebin "ufo2/ufo21.dat",begin1,end1-begin1
        page 3
	savebin "ufo2/ufo23.dat",begin3,end3-begin3
        page 4
	savebin "ufo2/ufo24.dat",begin4,end4-begin4
        ;page 6
	;savebin "ufo2/ufo26.dat",begin6,end6-begin6
        page 7
	savebin "ufo2/ufo27.dat",begin7,end7-begin7
	
	LABELSLIST "../../../us/user.l"
