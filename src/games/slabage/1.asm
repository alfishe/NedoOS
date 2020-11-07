        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"  

STACK=0x4000;0x61a8
GAMESTACK=0x4000;0xFFFF
L_FDFD=0xfdfd
L_FE00=0xfe00

scrbase=0x4000+4
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrhgt=192;200
INTSTACK=0x3f00
tempsp=0x3f06 ;6 bytes for prspr
;UVSCROLL_SCRWID=320 ;8*(TILEMAPWID-2)
;UVSCROLL_SCRHGT=192 ;(делится на 16!!!) ;8*(TILEMAPHGT-2) ;чтобы выводить всегда 12 метатайлов (3 блока по 8) по высоте

EGA=1

        org PROGSTART
begin
        jp begin2 ;/prsprqwid (sprites in file are made so that they return here)
begin2
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,3+0x80 ;6912+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

	;ld e,1
	;OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	;ld e,0
	;OS_SETSCREEN
        ;ld e,0 ;color byte
        ;OS_CLS

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ld a,e
        ld (pggfx),a
        ld a,h
        ld (pgcode8000),a
        ld a,l
        ld (pgcodec000),a 
        ;jr $

        OS_NEWPAGE
        ld a,e
        ld (pgmain4000),a

        if 1==0
        ld a,(user_scr0_high) ;ok
        SETPG32KLOW
        ld hl,0x6000
        ld de,0x6000+0x4000
        ld bc,0x2000
        ldir
        ;ld a,(user_scr0_high)
        SETPG16K
        ld a,(pgcode8000)
        SETPG32KLOW
        endif
        ld a,(user_scr0_high) ;ok
        SETPG16K
        
        call swapimer

        if EGA
        ld hl,prsprqwid
        ld (0x0101),hl ;sprites in file are made so that they return in 0x0100
        endif
        
        if 1==0
        ld e,0+0x80 ;EGA+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        
        call setpggfxc000

        ;call setpgsscr40008000

        call clsega
        ld bc,0x1880 ;b=hgt,c=wid (/2)
        ld de,panelgfx ;de=gfx
        ld hl,0x4000+((192-24)*40)+4 ;hl=scr
        call primgega

	xor a
	ld d,a
	ld e,a
prtiles0
	push af
	push de
	call DrawTile_A_X2Y2DE
        ;call DrawSprite_A_DExy
	pop de
        ld a,d
        add a,1;16
	ld d,a ;x
        cp 16
	jr nz,prtilesny
         ld d,0
         ld a,e
         add a,1;16
	 ld e,a ;y
prtilesny
	pop af
	inc a
	cp 192
	jr nz,prtiles0

	xor a
	ld d,a
	ld e,a
prsprites0
	push af
	push de
	;call DrawTile_A_X2Y2DE
        call DrawSprite_A_DExy
	pop de
        ld a,d
        add a,16
	ld d,a ;x
	jr nz,prspritesny
         ld d,0
         ld a,e
         add a,16
	 ld e,a ;y
prspritesny
	pop af
	inc a
	cp 13
	jr nz,prsprites0

        ;call setpgsmain40008000
        call setpgcodec000
        
        jr $
        endif
        jp GO

        include "pal.ast" ;slabpal
standardpal
        STANDARDPAL
emptypal
        ds 32,0xff

jphl
        jp (hl)

quiter
	if 1==0
        halt
pgmuznum=$+1
        ld a,0
        SETPG32KHIGH
	  ld hl,muz
	  OS_SETMUSIC 
        halt
	endif
        call swapimer
	QUIT

L_5B00 ;= #5b00
        db 0

setpggfxc000
pggfx=$+1
        ld a,0
        SETPG32KHIGH
        ret
setpgcodec000
pgcodec000=$+1
        ld a,0
        SETPG32KHIGH
        ret

swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int ;заменится на код из 0x0038
        jp 0x0038+3    

reter
        ret

tstarttime       DB       #00,#00,#00
curgametimer       DB       #00,#00,#00
stoptimer       DB       #00
curtimerlow       DB       #00
;
on_int
;restore stack with de
        EX DE,HL
	EX (SP),HL ;de="hl", stack contains "de"
	LD (on_int_jp),HL
	LD (on_int_sp),SP
	LD SP,INTSTACK
        push af
        push bc
        push de ;"hl"
        exx
        ex af,af' ;'
        push af
        push bc
        push de
        push hl
        push ix
        push iy
	;DI
;curscrnum_int=$+1
;        ld e,0
;        OS_SETSCREEN
	call oldimer ;ei
         GET_KEY
         jr nz,Imer_nofocus
         ;ld a,(user_scr0_high) ;ok
         ;SETPG16K ;TODO redraw screen when retake focus???
Imer_nofocus
	LD	A,(stoptimer)
	OR	A
	CALL	Z,DecTimer
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af' ;'
        exx
        pop hl
        pop bc
        pop af        
on_int_sp=$+1
	ld sp,0
        pop de
	ei
on_int_jp=$+1
	jp 0
;
        if 1==0
       DB       #21,#31,#BD,#35,#F0,#36,#19,#CD       ;!1=5p6.M
       DB       #67,#BD,#CD,#9E,#BD,#C9,#21,#2F       ;g=M.=I!/
       DB       #BD,#06,#03,#3E,#0A,#34,#BE,#C0       ;=..>.4>@
       DB       #36,#00,#2B,#10,#F8,#C9       ;6.+.xI
        endif
;
DecTimer
       ld a,0xfe
       in a,(0xfe)
       and 8
       jr nz,nocheat
       ld a,0xc9
       ld (DecTimer),a
nocheat
	LD	HL,curtimerlow
	DEC	(HL)
	RET	P
	LD	(HL),#19
	CALL	L_BD89
	LD	A,(stoptimer)
	OR	A
	CALL	Z,PrintGameTimer
	RET
;
L_BD89	LD	HL,curgametimer+2
	DEC	(HL)
	RET	P
	LD	(HL),#09
	DEC	HL
	DEC	(HL)
	RET	P
	LD	(HL),#09
	DEC	HL
	DEC	(HL)
	RET	P
	LD	HL,stoptimer
	LD	(HL),#FF
	RET
;
PrintGameTimer
	LD	HL,curgametimer
	LD	B,#03
	LD	DE,L_BDB8
L_BDA6	LD	A,(HL)
	ADD	A,#30
	LD	(DE),A
	INC	HL
	INC	DE
	DJNZ	L_BDA6
	LD	HL,L_BDB5
       if EGA
	CALL	PrintStringHL_EGA
       else
	CALL	PrintStringHL
       endif
	RET
;
L_BDB5       DB       #16,#16,#0F
L_BDB8       DM       "000"
       DB       #00
;
PrintNKeys
	LD	A,(curnkeys)
	ADD	A,#30
	LD	(L_BDCE),A
	LD	HL,L_BDCB
       if EGA
	CALL	PrintStringHL_EGA
       else
	CALL	PrintStringHL
       endif
	RET
;
L_BDCB       DB       #16,#16,#15
L_BDCE       DM       "0"
       DB       #00
;
RIGHTPIX=0x38;0xb8;%10111000
LEFTPIX=0x07;0x47;%01000111
        macro FONTBYTE
        ld a,(de)
        ld c,a
        xor a
        rl c
        jr nc,$+4
         or LEFTPIX
        rl c
        jr nc,$+4
         or RIGHTPIX
        ld (hl),a
        ld a,h
        add a,0x40
        ld h,a
        xor a
        rl c
        jr nc,$+4
         or LEFTPIX
        rl c
        jr nc,$+4
         or RIGHTPIX
        ld (hl),a
        ld a,h
        add a,0x20-0x40
        ld h,a
        xor a
        rl c
        jr nc,$+4
         or LEFTPIX
        rl c
        jr nc,$+4
         or RIGHTPIX
        ld (hl),a
        ld a,h
        add a,0x40
        ld h,a
        xor a
        rl c
        jr nc,$+4
         or LEFTPIX
        rl c
        jr nc,$+4
         or RIGHTPIX
        ld (hl),a
        endm

PrintCharA_EGA
        push bc
        push de
        push hl
       push af
        call setpgsscr40008000
	LD	DE,(curprintyx)
        sla e
        sla e
        sla e
        ld a,d ;x
         add a,4
        ld l,e ;y
        ld h,0
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
        add a,l
        ld l,a
        ld a,h
        adc a,0x40
        ld h,a
       pop af
	PUSH	HL
	LD	DE,font-256;L_BE02
	LD	H,#00
	LD	L,A
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	LD	hx,#08

PrintCharA_EGA0
        FONTBYTE
        ld bc,40-0x6000
        add hl,bc
	INC	DE
        dec hx
	jr nz,PrintCharA_EGA0
        
	LD	DE,(curprintyx)
	INC	D
	LD	A,D
	CP	#20
	JR	NZ,PrintCharA_EGAq
	INC	E
	LD	D,#00
	LD	A,E
	CP	#18
	JR	NZ,PrintCharA_EGAq
	LD	E,#00
PrintCharA_EGAq
	LD	(curprintyx),DE
        call setpgsmain40008000
        pop hl
        pop de
        pop bc
        ret
       
PrintCharA
	PUSH	DE
	PUSH	HL
	PUSH	BC
	PUSH	AF
	LD	DE,(curprintyx)
	LD	A,E
	AND	#18
	OR	#40
	LD	H,A
	LD	A,E
	AND	#07
	OR	A
	RRA
	RRA
	RRA
	RRA
	ADD	A,D
	LD	L,A
	POP	AF
	PUSH	HL
	LD	DE,font-256;L_BE02
	LD	H,#00
	LD	L,A
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	LD	B,#08
L_C6EB	LD	A,(DE)
	LD	(HL),A
	INC	H
	INC	DE
	DJNZ	L_C6EB
	LD	DE,(curprintyx)
	INC	D
	LD	A,D
	CP	#20
	JR	NZ,L_C705
	INC	E
	LD	D,#00
	LD	A,E
	CP	#18
	JR	NZ,L_C705
	LD	E,#00
L_C705	LD	(curprintyx),DE
	POP	BC
	POP	HL
	POP	DE
	RET
;
curprintyx       DW       #0000
;
PrintStringHL
	LD	A,(HL)
	OR	A
	RET	Z
	CP	#16
	JR	Z,L_C71C
	CALL	PrintCharA
	INC	HL
	JR	PrintStringHL
L_C71C	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(curprintyx),DE
	JR	PrintStringHL
;
PrintStringHL_EGA
	LD	A,(HL)
	OR	A
	RET	Z
	CP	#16
	JR	Z,L_C71C_EGA
	CALL	PrintCharA_EGA
	INC	HL
	JR	PrintStringHL_EGA
L_C71C_EGA
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(curprintyx),DE
	JR	PrintStringHL_EGA

font
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#18,#3C,#18,#00,#18,#18,#00       ;..<.....
       DB       #00,#36,#36,#6C,#00,#00,#00,#00       ;.66l....
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#1C,#38,#00,#00,#00,#00,#00       ;..8.....
       DB       #00,#0E,#1C,#1C,#1C,#1C,#0E,#00       ;........
       DB       #00,#70,#38,#38,#38,#38,#70,#00       ;.p8888p.
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#18,#18,#30       ;.......0
       DB       #00,#00,#00,#3C,#3C,#00,#00,#00       ;...<<...
       DB       #00,#00,#00,#00,#00,#18,#18,#00       ;........
       DB       #00,#06,#0E,#1C,#38,#70,#60,#00       ;....8p`.
       DB       #00,#3C,#72,#76,#7A,#72,#3C,#00       ;.<rvzr<.
       DB       #00,#1C,#3C,#1C,#1C,#1C,#7E,#00       ;..<...~.
       DB       #00,#7C,#0E,#0E,#3C,#70,#7E,#00       ;.|..<p~.
       DB       #00,#7C,#0E,#3C,#0E,#0E,#7C,#00       ;.|.<..|.
       DB       #00,#4E,#4E,#4E,#3E,#0E,#0E,#00       ;.NNN>...
       DB       #00,#7C,#60,#7C,#0E,#0E,#7C,#00       ;.|`|..|.
       DB       #00,#3C,#70,#7C,#72,#72,#3C,#00       ;.<p|rr<.
       DB       #00,#7E,#06,#0E,#1C,#18,#18,#00       ;.~......
       DB       #00,#3C,#72,#3C,#72,#72,#3C,#00       ;.<r<rr<.
       DB       #00,#3C,#4E,#4E,#3E,#0E,#3C,#00       ;.<NN>.<.
       DB       #00,#18,#18,#00,#00,#18,#18,#00       ;........
       DB       #00,#18,#18,#00,#00,#18,#18,#30       ;.......0
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #7C,#0E,#0E,#0E,#1C,#00,#18,#00       ;|.......
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#3C,#72,#72,#7E,#72,#72,#00       ;.<rr~rr.
       DB       #00,#7C,#72,#7C,#72,#72,#7C,#00       ;.|r|rr|.
       DB       #00,#3E,#70,#70,#70,#70,#3E,#00       ;.>pppp>.
       DB       #00,#7C,#72,#72,#72,#72,#7C,#00       ;.|rrrr|.
       DB       #00,#3E,#70,#7C,#70,#70,#3E,#00       ;.>p|pp>.
       DB       #00,#3E,#70,#7C,#70,#70,#70,#00       ;.>p|ppp.
       DB       #00,#3E,#70,#70,#76,#72,#3C,#00       ;.>ppvr<.
       DB       #00,#72,#72,#7E,#72,#72,#72,#00       ;.rr~rrr.
       DB       #00,#7F,#1C,#1C,#1C,#1C,#7F,#00       ;........
       DB       #00,#0E,#0E,#0E,#4E,#4E,#3C,#00       ;....NN<.
       DB       #00,#72,#72,#7C,#72,#72,#72,#00       ;.rr|rrr.
       DB       #00,#70,#70,#70,#70,#70,#3E,#00       ;.ppppp>.
       DB       #00,#3E,#75,#75,#75,#75,#75,#00       ;.>uuuuu.
       DB       #00,#7C,#72,#72,#72,#72,#72,#00       ;.|rrrrr.
       DB       #00,#3C,#72,#72,#72,#72,#3C,#00       ;.<rrrr<.
       DB       #00,#7C,#72,#72,#7C,#70,#70,#00       ;.|rr|pp.
       DB       #00,#3C,#72,#72,#72,#7A,#3C,#08       ;.<rrrz<.
       DB       #00,#7C,#72,#72,#7C,#72,#72,#00       ;.|rr|rr.
       DB       #00,#3C,#70,#3C,#0E,#0E,#7C,#00       ;.<p<..|.
       DB       #00,#7F,#1C,#1C,#1C,#1C,#1C,#00       ;........
       DB       #00,#72,#72,#72,#72,#72,#3C,#00       ;.rrrrr<.
       DB       #00,#72,#72,#72,#72,#34,#18,#00       ;.rrrr4..
       DB       #00,#71,#71,#75,#75,#75,#3E,#00       ;.qquuu>.
       DB       #00,#72,#72,#3C,#72,#72,#72,#00       ;.rr<rrr.
       DB       #00,#4E,#4E,#4E,#3E,#0E,#3C,#00       ;.NNN>.<.
       DB       #00,#7E,#0E,#1C,#38,#70,#7E,#00       ;.~..8p~.
       DB       #00,#1E,#1C,#1C,#1C,#1C,#1E,#00       ;........
       DB       #00,#60,#70,#38,#1C,#0E,#06,#00       ;.`p8....
       DB       #00,#78,#38,#38,#38,#38,#78,#00       ;.x8888x.
       DB       #00,#08,#1C,#3E,#5D,#1C,#1C,#00       ;...>]...
       DB       #00,#78,#38,#3C,#3A,#3A,#3C,#00       ;.x8<::<.
       DB       #00,#76,#79,#79,#79,#79,#76,#00       ;.vyyyyv.
       DB       #00,#3C,#72,#72,#7E,#72,#72,#00       ;.<rr~rr.
       DB       #00,#7C,#70,#7C,#72,#72,#7C,#00       ;.|p|rr|.
       DB       #00,#4E,#4E,#4E,#4E,#4E,#3E,#02       ;.NNNNN>.
       DB       #00,#1E,#2E,#2E,#2E,#2E,#7E,#42       ;......~B
       DB       #00,#3E,#70,#7C,#70,#70,#3E,#00       ;.>p|pp>.
       DB       #00,#3E,#5D,#5D,#3E,#1C,#1C,#00       ;.>]]>...
       DB       #00,#3E,#70,#70,#70,#70,#70,#00       ;.>ppppp.
       DB       #00,#72,#72,#3C,#72,#72,#72,#00       ;.rr<rrr.
       DB       #00,#72,#72,#76,#7A,#72,#72,#00       ;.rrvzrr.
       DB       #08,#72,#72,#76,#7A,#72,#72,#00       ;.rrvzrr.
       DB       #00,#72,#72,#7C,#72,#72,#72,#00       ;.rr|rrr.
       DB       #00,#3E,#4E,#4E,#4E,#4E,#4E,#00       ;.>NNNNN.
       DB       #00,#71,#7B,#75,#71,#71,#71,#00       ;.q{uqqq.
       DB       #00,#72,#72,#7E,#72,#72,#72,#00       ;.rr~rrr.
       DB       #00,#3C,#72,#72,#72,#72,#3C,#00       ;.<rrrr<.
       DB       #00,#7E,#4E,#4E,#4E,#4E,#4E,#00       ;.~NNNNN.
       DB       #00,#3E,#4E,#4E,#3E,#4E,#4E,#00       ;.>NN>NN.
       DB       #00,#7C,#72,#72,#7C,#70,#70,#00       ;.|rr|pp.
       DB       #00,#3E,#70,#70,#70,#70,#3E,#00       ;.>pppp>.
       DB       #00,#7F,#1C,#1C,#1C,#1C,#1C,#00       ;........
       DB       #00,#4E,#4E,#4E,#3E,#0E,#3C,#00       ;.NNN>.<.
       DB       #00,#5D,#5D,#3E,#5D,#5D,#5D,#00       ;.]]>]]].
       DB       #00,#7C,#72,#7C,#72,#72,#7C,#00       ;.|r|rr|.
       DB       #00,#70,#70,#7C,#72,#72,#7C,#00       ;.pp|rr|.
       DB       #00,#72,#72,#7C,#72,#72,#7C,#00       ;.rr|rr|.
       DB       #00,#7C,#0E,#3C,#0E,#0E,#7C,#00       ;.|.<..|.
       DB       #00,#75,#75,#75,#75,#75,#3E,#00       ;.uuuuu>.
       DB       #00,#7C,#0E,#3E,#0E,#0E,#7C,#00       ;.|.>..|.
       DB       #00,#75,#75,#75,#75,#75,#3F,#01       ;.uuuuu?.
       DB       #00,#4E,#4E,#4E,#3E,#0E,#0E,#00       ;.NNN>...
       DB       #00,#00,#3E,#70,#70,#3E,#00,#00       ;..>pp>..


L_61AB
;L=?
;E=?
;ix=sprwid8
	LD	H,#00
	LD	D,#00
	LD	(L_6258),HL
	LD	(L_625E),HL
	LD	(L_6264),DE
	LD	(cursprwid),IX ;sprwid8
	LD	(L_625C),BC
	LD	(cursprdataaddr),IY
L_61C5	PUSH	BC
	LD	HL,L_6258
	LD	A,(HL)
	SUB	#08
	JR	NC,L_61D4
	LD	BC,#4000
	LD	A,(HL)
	JR	L_61E4
L_61D4	LD	A,(HL)
	SUB	#10
	JR	NC,L_61E1
	LD	BC,#4800
	LD	A,(HL)
	SUB	#08
	JR	L_61E4
;
L_61E1	LD	BC,#5000
L_61E4	LD	IX,(L_6264)
	ADD	IX,BC
	LD	HL,#0000
	LD	E,A
	LD	D,#00
	LD	B,#20
L_61F2	ADD	HL,DE
	DJNZ	L_61F2
	EX	DE,HL
	ADD	IX,DE
	LD	(L_625A),IX
	LD	B,#08
L_61FE	PUSH	BC
	CALL	DrawImgLine
	INC	H
	LD	(L_625A),HL
	POP	BC
	DJNZ	L_61FE
	LD	HL,(L_6258)
	INC	HL
	LD	(L_6258),HL
	POP	BC
	DJNZ	L_61C5
	LD	DE,(L_625E)
	LD	HL,#0000
	LD	B,#20
L_621C	ADD	HL,DE
	DJNZ	L_621C
	LD	DE,#5800
	ADD	HL,DE
	LD	DE,(L_6264)
	ADD	HL,DE
	LD	(L_625A),HL
	LD	BC,(L_625C)
L_622F	PUSH	BC
	CALL	DrawImgLine
	LD	BC,#0020
	ADD	HL,BC
	LD	(L_625A),HL
	POP	BC
	DJNZ	L_622F
	LD	IY,L_5B00;L_5C3A ;???
	RET

DrawImgLine
	LD	DE,(L_625A)
	PUSH	DE
	LD	HL,(cursprdataaddr)
	LD	BC,(cursprwid)
	LDIR
	LD	(cursprdataaddr),HL
	POP	HL
	LD	(L_625A),HL
	RET
;
L_6258       DW       #0000
L_625A       DW       #0000
L_625C       DW       #0000
L_625E       DW       #0000
cursprdataaddr       DW       #0000
cursprwid       DW       #0000
L_6264       DW       #0000
;
       ;DB       #00,#21,#00,#40,#11,#01,#40,#01       ;.!.@..@.
       ;DB       #00,#00,#ED,#B0,#00,#67,#62       ;..m0.gb
;
DepackBigDragon
	CALL	reter;#007C
	DEC	SP
	DEC	SP
	POP	IY
	LD	BC,#0016
	ADD	IY,BC
	LD	L,#0E
	LD	E,#08
	LD	B,#04
	LD	IX,#0006 ;sprwid8
	JP	L_FF32 ;jp 61ab
;
       DB       #FF,#FF,#00,#FF,#FF,#FF,#FF,#FE       ;.......~
       DB       #00,#7F,#FF,#FF,#FF,#FE,#00,#1F       ;.....~..
       DB       #FF,#FF,#FF,#FC,#3C,#03,#FF,#FF       ;...|<...
       DB       #FF,#F8,#5E,#00,#FF,#FF,#FF,#F0       ;.x^....p
       DB       #6E,#00,#1F,#FF,#FF,#C0,#2E,#00       ;n....@..
       DB       #0F,#FF,#FF,#80,#6F,#00,#01,#FF       ;....o...
       DB       #FF,#18,#DF,#00,#00,#FF,#FE,#2F       ;.._...~/
       DB       #FF,#80,#00,#FF,#FE,#3F,#FF,#80       ;....~?..
       DB       #00,#7F,#FC,#3F,#FF,#C1,#FF,#7F       ;..|?.A..
       DB       #F8,#3F,#3F,#8F,#EC,#3F,#F0,#00       ;x??.l?p.
       DB       #7E,#7F,#F0,#1F,#E0,#1F,#FD,#FF       ;~.p.`.}.
       DB       #A0,#07,#C0,#00,#FD,#FF,#C0,#01       ; .@.}.@.
       DB       #00,#00,#7B,#FE,#80,#00,#00,#00       ;..{~....
       DB       #7B,#FF,#00,#00,#00,#00,#3B,#FD       ;{.....;}
       DB       #00,#00,#00,#00,#3D,#FE,#00,#00       ;....=~..
       DB       #00,#00,#3F,#FE,#00,#00,#00,#00       ;..?~....
       DB       #3F,#FD,#00,#00,#00,#00,#3F,#FD       ;?}....?}
       DB       #80,#00,#00,#00,#7F,#FF,#C0,#00       ;......@.
       DB       #00,#00,#7F,#FF,#E0,#00,#00,#00       ;....`...
       DB       #43,#FF,#F0,#00,#00,#00,#3D,#FE       ;C.p...=~
       DB       #3C,#00,#00,#00,#7E,#FD,#DF,#00       ;<...~}_.
       DB       #00,#00,#7E,#FD,#EF,#C0,#00,#00       ;..~}o@..
       DB       #FE,#FB,#EF,#F8,#00,#00,#FE,#FB       ;~{ox..~{
       DB       #EF,#FF,#00,#00,#00,#00,#00,#00       ;o.......
       DB       #42,#42,#47,#42,#42,#42,#42,#47       ;BBGBBBBG
       DB       #47,#47,#47,#42,#47,#47,#47,#47       ;GGGBGGGG
       DB       #47,#47,#47,#47,#47,#47,#47,#47       ;GGGGGGGG
;
DepackSmallDragon	CALL	reter;#007C
	DEC	SP
	DEC	SP
	POP	IY
	LD	BC,#0016
	ADD	IY,BC
	LD	L,#0E
	LD	E,#08
	LD	B,#04
	LD	IX,#0006 ;sprwid8
	JP	L_FF32 ;jp 61ab
;
       DB       #FF,#FF,#00,#FF,#FF,#FF,#FF,#FE       ;.......~
       DB       #00,#7F,#FF,#FF,#FF,#FE,#00,#1F       ;.....~..
       DB       #FF,#FF,#FF,#FC,#00,#03,#FF,#FF       ;...|....
       DB       #FF,#F8,#00,#00,#FF,#FF,#FF,#F0       ;.x.....p
       DB       #00,#00,#1F,#FF,#FF,#C0,#00,#00       ;.....@..
       DB       #0F,#FF,#FF,#80,#00,#00,#01,#FF       ;........
       DB       #FF,#00,#00,#00,#00,#FF,#FE,#00       ;......~.
       DB       #00,#00,#00,#FF,#FE,#00,#00,#00       ;....~...
       DB       #00,#7F,#FC,#00,#00,#00,#00,#7F       ;..|.....
       DB       #F8,#00,#00,#00,#00,#3F,#F0,#00       ;x....?p.
       DB       #00,#00,#00,#1F,#E0,#00,#00,#00       ;....`...
       DB       #00,#07,#C0,#00,#00,#00,#00,#01       ;..@.....
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #3E,#00,#00,#00,#00,#00,#7F,#00       ;>.......
       DB       #00,#00,#00,#00,#3F,#00,#00,#00       ;....?...
       DB       #00,#00,#1F,#00,#00,#00,#00,#00       ;........
       DB       #3F,#00,#00,#00,#00,#00,#7F,#00       ;?.......
       DB       #00,#00,#00,#00,#7F,#80,#00,#00       ;........
       DB       #00,#00,#1F,#80,#00,#00,#00,#00       ;........
       DB       #3F,#80,#00,#00,#00,#00,#7F,#C0       ;?......@
       DB       #00,#00,#00,#00,#4F,#C0,#00,#00       ;....O@..
       DB       #00,#00,#37,#E0,#00,#00,#00,#00       ;..7`....
       DB       #7B,#F0,#00,#00,#00,#00,#7B,#FC       ;{p....{|
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #42,#42,#42,#42,#42,#42,#42,#42       ;BBBBBBBB
       DB       #42,#42,#42,#42,#42,#42,#47,#47       ;BBBBBBGG
       DB       #42,#42,#42,#42,#47,#47,#42,#42       ;BBBBGGBB
;
DepackAuthorsScreen
	halt;DI
	CALL	reter;#0052
	DEC	SP
	DEC	SP
	POP	BC
	LD	HL,#0097
	ADD	HL,BC
       ;ld hl,authorsscreen
	EX	DE,HL
	LD	HL,#0066
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#007B
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#0089
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#00BE
	ADD	HL,BC
	LD	DE,#4000
	PUSH	DE
	EXX
	EX	AF,AF' ;'
	LD	A,#03
	OR	A
	LD	B,#08
	LD	C,B
	POP	HL
	EX	AF,AF' ;'
	EXX
L_648B	LD	A,(HL)
	BIT	7,A
	JR	NZ,L_64CA
	AND	#07
	LD	C,A
	LD	A,(HL)
	RRCA
	RRCA
	RRCA
	AND	#0F
	ADD	A,#03
	LD	B,A
	INC	HL
	LD	A,E
	SUB	(HL)
	INC	HL
	PUSH	HL
	LD	L,A
	LD	A,D
	SBC	A,C
	LD	H,A
L_64A5	PUSH	HL
	LD	A,H
	AND	#58
	CP	#58
	JR	Z,L_64BF
	LD	C,A
	LD	A,L
	AND	#07
	OR	C
	LD	C,A
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H
	AND	#1F
	LD	H,A
	LD	A,L
	AND	#E0
	OR	H
	LD	L,A
	LD	H,C
L_64BF	LD	A,(HL)
	CALL	L_74A6 ;???
	POP	HL
	INC	HL
	DJNZ	L_64A5
	POP	HL
	JR	L_648B
;
L_64CA	AND	#7F
	JR	Z,L_64EB
	INC	HL
	BIT	6,A
	JR	NZ,L_64DD
	LD	B,A
L_64D4	LD	A,(HL)
	CALL	L_74A6 ;???
	INC	HL
	DJNZ	L_64D4
	JR	L_648B
;
L_64DD	AND	#3F
	ADD	A,#03
	LD	B,A
	LD	A,(HL)
L_64E3	CALL	L_74A6 ;???
	DJNZ	L_64E3
	INC	HL
	JR	L_648B
;
L_64EB	EXX
	LD	HL,#2758
	EXX
	EI
	RET
;
authorsscreen
       DB       #13,#D9,#77,#08,#28,#19,#24,#10       ;.Yw.(.$.
       DB       #1B,#11,#20,#F8,#19,#0D,#20,#12       ;.. x.. .
       DB       #11,#01,#FF,#19,#C6,#08,#30,#08       ;....F.0.
       DB       #11,#E0,#07,#19,#3D,#18,#01,#23       ;.`..=..#
       DB       #0E,#08,#06,#08,#08,#D9,#C9,#FF       ;.....YI.
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#E9,#00,#88,#FF,#80       ;...i....
       DB       #BB,#AA,#AB,#BA,#80,#8B,#F5,#00       ;;*+:..u.
       DB       #88,#FF,#00,#B9,#A1,#29,#B8,#00       ;...9!)8.
       DB       #81,#F5,#00,#88,#FF,#00,#5D,#55       ;.u....]U
       DB       #D5,#5D,#00,#DC,#F5,#00,#88,#FF       ;U].\u...
       DB       #01,#DD,#55,#55,#DD,#01,#9D,#FF       ;.]UU]...
       DB       #00,#FC,#00,#86,#3C,#72,#72,#7E       ;.|..<rr~
       DB       #72,#72,#EF,#00,#81,#7E,#C2,#4E       ;rro..~BN
       DB       #88,#00,#00,#7C,#72,#7C,#72,#72       ;...|r|rr
       DB       #7C,#EF,#00,#08,#36,#85,#70,#70       ;|o..6.pp
       DB       #00,#00,#7F,#C2,#1C,#EF,#00,#00       ;...B.o..
       DB       #B8,#83,#72,#72,#3C,#28,#08,#EF       ;8.rr<(.o
       DB       #00,#81,#3E,#C2,#70,#38,#88,#ED       ;..>Bp8.m
       DB       #00,#28,#C0,#00,#FD,#79,#00,#E0       ;.(@.}y.`
       DB       #00,#79,#78,#EB,#00,#83,#71,#7B       ;.yxk..q{
       DB       #75,#C0,#71,#84,#00,#00,#18,#18       ;u@q.....
       DB       #08,#04,#EF,#00,#28,#40,#F5,#00       ;..o.(@u.
       DB       #7A,#38,#FF,#00,#FF,#00,#FF,#00       ;z8......
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#D2,#00,#81,#8A,#07,#C5       ;..R....E
       DB       #8C,#BB,#A2,#A3,#BA,#80,#AB,#92       ;.;"#:.+.
       DB       #AA,#AB,#80,#80,#FF,#CE,#00,#85       ;*+...N..
       DB       #7D,#7D,#00,#7F,#7F,#C3,#00,#83       ;}}...C..
       DB       #01,#02,#07,#C1,#04,#83,#05,#06       ;...A....
       DB       #07,#C7,#00,#84,#80,#80,#00,#00       ;.G......
       DB       #C0,#A2,#88,#BB,#00,#B9,#A9,#B1       ;@".;.9)1
       DB       #A9,#00,#00,#78,#40,#83,#EF,#EF       ;)..x@.oo
       DB       #00,#00,#43,#C1,#00,#84,#FF,#83       ;..CA....
       DB       #85,#F9,#C0,#89,#84,#FF,#0A,#0C       ;.y@.....
       DB       #F8,#C7,#00,#8F,#55,#9C,#95,#00       ;xG..U...
       DB       #15,#15,#1D,#85,#00,#C0,#40,#C0       ;.....@@@
       DB       #5C,#00,#00,#78,#80,#85,#7B,#7B       ;\..x..{{
       DB       #00,#FE,#FE,#C5,#00,#C0,#01,#CC       ;.~~E.@.L
       DB       #00,#88,#91,#91,#DD,#01,#D9,#55       ;....].YU
       DB       #55,#D9,#C4,#01,#78,#C0,#85,#F6       ;UYD.x@.v
       DB       #F6,#08,#FE,#F6,#C5,#00,#84,#C0       ;v.~vE..@
       DB       #80,#40,#20,#FF,#00,#FF,#00,#C8       ;.@ ....H
       DB       #00,#82,#3E,#70,#07,#87,#07,#88       ;..>p....
       DB       #81,#0E,#0F,#88,#81,#0E,#CF,#00       ;......O.
       DB       #37,#28,#81,#70,#1F,#E8,#68,#28       ;7(.p.hh(
       DB       #2E,#C8,#84,#3C,#72,#76,#7A,#7F       ;.H.<rvz.
       DB       #88,#82,#00,#00,#2F,#E8,#10,#68       ;..../h.h
       DB       #83,#3E,#00,#00,#68,#28,#07,#80       ;.>..h(..
       DB       #07,#CA,#87,#00,#00,#3C,#4E,#4E       ;.J...<NN
       DB       #3E,#0E,#7F,#C8,#81,#00,#2F,#28       ;>..H../(
       DB       #81,#3E,#C2,#4E,#82,#00,#00,#68       ;.>BN...h
       DB       #28,#83,#3C,#72,#72,#17,#48,#85       ;(.<rr.H.
       DB       #7C,#60,#7C,#0E,#0E,#7F,#88,#89       ;|`|.....
       DB       #00,#3E,#5D,#5D,#3E,#1C,#1C,#00       ;.>]]>...
       DB       #00,#07,#70,#81,#72,#08,#A0,#68       ;..p.r. h
       DB       #28,#81,#7F,#C2,#1C,#83,#00,#00       ;(..B....
       DB       #70,#C1,#38,#07,#D0,#CD,#00,#81       ;pA8.PM..
       DB       #72,#08,#D8,#07,#A8,#00,#7F,#10       ;r.X.(...
       DB       #A0,#68,#28,#10,#40,#22,#A1,#D1       ; h(.@"!Q
       DB       #00,#01,#35,#10,#E0,#11,#48,#01       ;..5.`.H.
       DB       #00,#CD,#00,#28,#18,#82,#1C,#3C       ;.M.(...<
       DB       #01,#81,#81,#7E,#CF,#00,#39,#60       ;...~O.9`
       DB       #18,#C0,#10,#88,#79,#A8,#81,#00       ;.@..y(..
       DB       #79,#40,#CB,#00,#81,#7C,#08,#88       ;y@K..|..
       DB       #01,#C0,#86,#7E,#06,#0E,#1C,#18       ;.@.~....
       DB       #18,#C7,#00,#83,#3C,#70,#3C,#11       ;.G..<p<.
       DB       #38,#78,#80,#D3,#00,#68,#80,#29       ;8x.S.h.)
       DB       #40,#83,#00,#00,#3C,#79,#FE,#C8       ;@...<y~H
       DB       #00,#2A,#28,#82,#00,#00,#58,#28       ;.*(...X(
       DB       #31,#C0,#84,#0E,#0E,#3C,#70,#79       ;1@...<py
       DB       #00,#C6,#00,#7A,#00,#C3,#00,#78       ;.F.z.C.x
       DB       #C0,#D3,#00,#32,#80,#0A,#C8,#7A       ;@S.2..Hz
       DB       #A8,#C0,#00,#78,#C0,#C9,#00,#29       ;(@.x@I.)
       DB       #C8,#82,#00,#00,#78,#E8,#C1,#00       ;H...xhA.
       DB       #82,#7C,#0E,#19,#48,#D5,#00,#2A       ;.|..HU.*
       DB       #00,#7A,#E8,#C3,#00,#7A,#C0,#CB       ;.zhC.z@K
       DB       #00,#7A,#E8,#EB,#00,#13,#A7,#11       ;.zhk..'.
       DB       #80,#F3,#00,#81,#1E,#C1,#2E,#82       ;.s...A..
       DB       #7E,#42,#F6,#00,#2C,#08,#FF,#00       ;~Bv.,...
       DB       #FF,#00,#F2,#00,#C4,#07,#F6,#00       ;..r.D.v.
       DB       #94,#FF,#B5,#EA,#F5,#EA,#D5,#FE       ;..5jujU~
       DB       #15,#1A,#14,#1A,#1D,#1A,#15,#1A       ;........
       DB       #15,#1A,#15,#1E,#1F,#E9,#00,#88       ;.....i..
       DB       #FF,#41,#08,#41,#A1,#41,#FB,#40       ;.A.A!A{@
       DB       #06,#A9,#08,#04,#C0,#40,#82,#C0       ;.)..@@.@
       DB       #C0,#E8,#00,#D3,#07,#E7,#00,#C0       ;@h.S.g.@
       DB       #F8,#81,#E8,#00,#04,#88,#FF,#F5       ;x.h....u
       DB       #FA,#FD,#EA,#FD,#FB,#FF,#C2,#F8       ;z}j}{.Bx
       DB       #81,#D8,#47,#49,#DD,#00,#84,#1F       ;.XGI]...
       DB       #10,#10,#18,#C0,#10,#88,#F0,#54       ;...@..pT
       DB       #80,#50,#A0,#10,#A8,#F0,#C1,#10       ;.P .(pA.
       DB       #83,#14,#10,#1E,#E7,#00,#81,#E0       ;....g..`
       DB       #C5,#20,#81,#00,#C8,#20,#81,#E0       ;E ..H .`
       DB       #E8,#00,#87,#FF,#FD,#FE,#FD,#F6       ;h...}~}v
       DB       #FF,#FF,#C3,#FE,#86,#FB,#FE,#FF       ;..C~.{~.
       DB       #FE,#FF,#FD,#7F,#EE,#D8,#00,#88       ;~.}.nX..
       DB       #FE,#D0,#A8,#50,#88,#50,#E4,#10       ;~P(P.Pd.
       DB       #C1,#08,#88,#14,#F0,#A8,#50,#A8       ;A...p(P(
       DB       #44,#A9,#FE,#EA,#00,#83,#80,#40       ;D)~j...@
       DB       #40,#48,#C3,#83,#40,#40,#80,#FF       ;@HC.@@..
       DB       #00,#E7,#00,#81,#03,#0A,#C0,#81       ;.g....@.
       DB       #03,#F7,#00,#81,#E3,#0B,#00,#81       ;.w..c...
       DB       #E3,#F7,#00,#81,#C7,#C1,#27,#81       ;cw..GA'.
       DB       #C7,#C7,#00,#0E,#8E,#7C,#90,#D7       ;GG...|.W
       DB       #00,#85,#C4,#24,#24,#C3,#00,#00       ;..D$$C..
       DB       #C0,#2F,#28,#C2,#72,#7E,#F0,#D6       ;@/(Br~pV
       DB       #00,#C2,#E7,#00,#80,#2F,#28,#2E       ;.Bg../(.
       DB       #F8,#E5,#00,#88,#C7,#21,#21,#C1       ;xe..G!!A
       DB       #21,#27,#00,#00,#78,#40,#E3,#00       ;!'..x@c.
       DB       #81,#F3,#C1,#C7,#83,#F3,#00,#00       ;.sAG.s..
       DB       #2E,#28,#17,#38,#81,#7F,#E7,#00       ;.(.8..g.
       DB       #84,#E7,#07,#07,#67,#49,#40,#3F       ;.g..gI@?
       DB       #50,#E3,#00,#83,#27,#21,#E1,#C0       ;Pc..'!a@
       DB       #21,#F7,#00,#81,#F0,#C2,#C0,#FF       ;!w..pB@.
       DB       #00,#FD,#00,#82,#7F,#7F,#C1,#60       ;.}....A`
       DB       #81,#7F,#09,#3A,#18,#06,#E4,#00       ;...:..d.
       DB       #84,#7F,#63,#60,#78,#00,#3A,#82       ;..c`x.:.
       DB       #00,#FF,#13,#F5,#18,#06,#18,#0C       ;...u....
       DB       #E3,#00,#83,#3F,#31,#31,#00,#03       ;c..?11..
       DB       #85,#31,#00,#E7,#E7,#66,#0C,#8E       ;.1.ggf..
       DB       #81,#E0,#08,#86,#81,#E0,#7C,#80       ;.`...`|.
       DB       #D6,#00,#8A,#98,#98,#9C,#9A,#99       ;V.......
       DB       #98,#98,#00,#FF,#FF,#C7,#06,#82       ;.....G..
       DB       #0F,#0F,#E7,#00,#83,#CF,#CC,#CC       ;..g..OLL
       DB       #00,#03,#85,#CC,#00,#FE,#FE,#06       ;...L.~~.
       DB       #F2,#00,#81,#E7,#00,#AF,#09,#00       ;r..g./..
       DB       #29,#40,#C3,#60,#E7,#00,#81,#F9       ;)@C`g..y
       DB       #12,#00,#82,#C1,#00,#79,#3A,#E3       ;...A.y:c
       DB       #00,#81,#F9,#C2,#61,#82,#F9,#00       ;..yBa.y.
       DB       #01,#40,#C0,#66,#81,#E7,#00,#8F       ;.@@f.g..
       DB       #84,#60,#66,#67,#67,#E7,#00,#82       ;.`fggg..
       DB       #FC,#8C,#C0,#80,#83,#8C,#FC,#00       ;|.@...|.
       DB       #79,#C0,#EB,#00,#19,#40,#01,#46       ;y@k..@.F
       DB       #01,#87,#83,#FE,#FE,#00,#DD,#42       ;...~~.]B
       DB       #FF,#47,#FF,#47,#FF,#47,#C1,#4F       ;.G.G.GAO
       DB       #D3,#46,#38,#20,#D9,#47,#08,#40       ;SF8 YG.@
       DB       #D3,#45,#FF,#47,#09,#62,#C1,#79       ;SE.G.bAy
       DB       #D3,#46,#19,#80,#C1,#78,#D9,#47       ;SF..AxYG
       DB       #08,#20,#D3,#45,#FF,#47,#FF,#47       ;. SE.G.G
       DB       #F9,#47,#21,#63,#01,#7D,#C9,#44       ;yG!c.}ID
       DB       #21,#B7,#78,#20,#28,#20,#31,#ED       ;!7x ( 1m
       DB       #78,#40,#58,#20,#80,#00,#00,#00       ;x@X ....
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00       ;......
;
DepackSplashScreen
	halt;DI
	LD	HL,L_6A39
	LD	DE,#4000
	PUSH	DE
	EXX
	EX	AF,AF' ;'
	LD	A,#03
	OR	A
	LD	B,#08
	LD	C,B
	POP	HL
	EX	AF,AF' ;'
	EXX
L_69AB	LD	A,(HL)
	BIT	7,A
	JR	NZ,L_69EA
	AND	#07
	LD	C,A
	LD	A,(HL)
	RRCA
	RRCA
	RRCA
	AND	#0F
	ADD	A,#03
	LD	B,A
	INC	HL
	LD	A,E
	SUB	(HL)
	INC	HL
	PUSH	HL
	LD	L,A
	LD	A,D
	SBC	A,C
	LD	H,A
L_69C5	PUSH	HL
	LD	A,H
	AND	#58
	CP	#58
	JR	Z,L_69DF
	LD	C,A
	LD	A,L
	AND	#07
	OR	C
	LD	C,A
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H
	AND	#1F
	LD	H,A
	LD	A,L
	AND	#E0
	OR	H
	LD	L,A
	LD	H,C
L_69DF	LD	A,(HL)
	CALL	L_6A12
	POP	HL
	INC	HL
	DJNZ	L_69C5
	POP	HL
	JR	L_69AB
;
L_69EA	AND	#7F
	JR	Z,L_6A0B
	INC	HL
	BIT	6,A
	JR	NZ,L_69FD
	LD	B,A
L_69F4	LD	A,(HL)
	CALL	L_6A12
	INC	HL
	DJNZ	L_69F4
	JR	L_69AB
;
L_69FD	AND	#3F
	ADD	A,#03
	LD	B,A
	LD	A,(HL)
L_6A03	CALL	L_6A12
	DJNZ	L_6A03
	INC	HL
	JR	L_69AB
;
L_6A0B	EXX
	LD	HL,#2758
	EXX
	EI
	RET
;
L_6A12	INC	DE
	EXX
	LD	(HL),A
	EX	AF,AF' ;'
	JR	Z,L_6A31
	INC	H
	DJNZ	L_6A36
	LD	DE,0xF820
	ADD	HL,DE
	DEC	C
	JR	NZ,L_6A34
	LD	DE,0xFF01
	ADD	HL,DE
	ADD	A,#08
	JR	NC,L_6A32
	LD	DE,#07E0
	ADD	HL,DE
	DEC	A
	JR	L_6A32
;
L_6A31	INC	HL
L_6A32	LD	C,#08
L_6A34	LD	B,#08
L_6A36	EX	AF,AF' ;'
	EXX
	RET
;
L_6A39
       DB       #8B,#FF,#80,#AA,#9F,#BF,#9F,#BC       ;...*.?.<
       DB       #9D,#BD,#9D,#BD,#08,#04,#84,#9D       ;.=.=....
       DB       #BD,#9C,#BD,#00,#10,#82,#80,#FF       ;=.=.....
       DB       #C5,#00,#18,#20,#38,#10,#CD,#00       ;E.. 8.M.
       DB       #83,#FF,#00,#AA,#C0,#FF,#00,#07       ;...*@...
       DB       #30,#10,#81,#55,#60,#10,#58,#20       ;0..U`.X 
       DB       #70,#40,#82,#01,#A9,#C0,#FD,#81       ;p@..)@}.
       DB       #01,#38,#70,#82,#01,#55,#00,#10       ;.8p..U..
       DB       #81,#3D,#38,#90,#82,#1D,#BD,#50       ;.=8...=P
       DB       #20,#FD,#00,#93,#57,#6B,#7D,#3F       ; }..Wk}?
       DB       #78,#38,#5F,#3D,#7E,#7D,#28,#58       ;x8_=~}(X
       DB       #30,#68,#70,#78,#FF,#81,#A9,#38       ;0hpx..)8
       DB       #FC,#39,#06,#79,#10,#21,#11,#84       ;|9.y.!..
       DB       #F5,#BE,#DF,#AF,#00,#06,#83,#FB       ;u>_/...{
       DB       #F7,#7E,#E3,#00,#69,#10,#90,#7E       ;w~c.i..~
       DB       #F6,#7A,#FC,#1A,#1C,#FE,#EC,#5E       ;vz|..~l^
       DB       #BE,#1A,#16,#0E,#16,#0E,#1E,#DD       ;>......]
       DB       #00,#19,#10,#39,#20,#86,#6B,#77       ;...9 .kw
       DB       #7B,#7F,#78,#50,#00,#B9,#87,#70       ;{.xP.9.p
       DB       #38,#58,#2F,#7E,#3D,#7A,#ED,#00       ;8X/~=zm.
       DB       #83,#AB,#F7,#EF,#01,#DC,#8A,#1F       ;.+wo.\..
       DB       #1D,#1E,#1D,#00,#00,#EB,#F5,#FE       ;.....ku~
       DB       #BF,#7A,#00,#0A,#00,#42,#10,#12       ;?z...B..
       DB       #1A,#81,#81,#32,#10,#90,#FE,#BE       ;...2..~>
       DB       #DE,#AA,#00,#00,#D6,#EE,#F6,#7E       ;^*..Vnv~
       DB       #1C,#1E,#FC,#FA,#F4,#FE,#7A,#00       ;..|zt~z.
       DB       #5A,#00,#6A,#38,#90,#7A,#7D,#7E       ;Z.j8.z}~
       DB       #2F,#58,#38,#7D,#7E,#7F,#7E,#28       ;/X8}~.~(
       DB       #58,#3F,#7F,#3D,#6A,#1A,#00,#81       ;X?.=j...
       DB       #1D,#39,#83,#82,#3D,#5D,#58,#10       ;.9..=]X.
       DB       #12,#99,#38,#80,#8A,#BF,#FF,#FE       ;..8..?.~
       DB       #F5,#00,#00,#7C,#EC,#DC,#AC,#00       ;u..|l\,.
       DB       #C0,#10,#CC,#EB,#00,#84,#EA,#F6       ;@.Lk..jv
       DB       #EE,#FE,#48,#CC,#7B,#00,#61,#00       ;n~HL{.a.
       DB       #5B,#10,#81,#02,#7B,#00,#0B,#00       ;[...{...
       DB       #86,#01,#FB,#09,#0B,#09,#0B,#08       ;..{.....
       DB       #04,#82,#F9,#03,#6B,#00,#53,#10       ;..y.k.S.
       DB       #85,#F3,#00,#00,#03,#3D,#4B,#4C       ;.s...=KL
       DB       #83,#F0,#10,#90,#CA,#D0,#83,#DF       ;.p..JP._
       DB       #C1,#D5,#79,#10,#1B,#20,#8C,#01       ;AUy.. ..
       DB       #1F,#00,#03,#FF,#3F,#15,#EB,#51       ;....?.kQ
       DB       #03,#00,#37,#33,#8F,#84,#FA,#23       ;..73..z#
       DB       #22,#22,#30,#9B,#38,#17,#6B,#AF       ;""0.8.k/
       DB       #90,#01,#00,#5D,#2A,#57,#BE,#75       ;...]*W>u
       DB       #AB,#FF,#E9,#17,#FE,#F5,#E8,#40       ;+.i.~uh@
       DB       #F0,#33,#CF,#84,#20,#60,#A0,#20       ;p3O. `  
       DB       #13,#EC,#87,#15,#FE,#0F,#1D,#F6       ;.l..~..v
       DB       #00,#03,#D4,#00,#8D,#F4,#00,#00       ;..T..t..
       DB       #FB,#FE,#B8,#75,#FA,#D7,#A0,#FC       ;{~8uzW |
       DB       #00,#68,#00,#36,#64,#0F,#8E,#02       ;.h.6d...
       DB       #00,#2B,#57,#BF,#FF,#94,#7F,#9D       ;.+W?....
       DB       #EB,#14,#00,#00,#1A,#D3,#00,#86       ;k....S..
       DB       #E8,#00,#00,#5F,#80,#F8,#74,#48       ;h.._.xtH
       DB       #92,#07,#1A,#3F,#7F,#7F,#FF,#FF       ;...?....
       DB       #CB,#FC,#87,#FD,#EA,#BF,#5E,#FF       ;K|.}j?^.
       DB       #FF,#07,#38,#D7,#00,#81,#C0,#D0       ;..8W..@P
       DB       #00,#90,#C0,#B0,#58,#EC,#F4,#DE       ;..@0Xlt^
       DB       #FE,#EB,#55,#AF,#7F,#83,#FF,#1E       ;~kU/....
       DB       #CF,#F1,#7B,#52,#1C,#CB,#82,#03       ;Oq{R.K..
       DB       #73,#C0,#F3,#C3,#FF,#83,#7F,#3C       ;s@sC...<
       DB       #13,#C6,#0F,#10,#1B,#8D,#00,#00       ;.F......
       DB       #2F,#94,#EA,#DF,#FF,#8A,#FF,#50       ;/.j_...P
       DB       #FE,#00,#C0,#71,#E3,#15,#0B,#81       ;~.@qc...
       DB       #0F,#C1,#CF,#82,#FF,#FD,#10,#41       ;.AO..}.A
       DB       #85,#E0,#1D,#F7,#FE,#DF,#C0,#9F       ;.`.w~_@.
       DB       #08,#4E,#0D,#28,#81,#D0,#11,#C9       ;.N.(.P.I
       DB       #84,#C0,#BD,#00,#E0,#41,#70,#5D       ;.@=.`Ap]
       DB       #31,#98,#3C,#18,#34,#38,#35,#E2       ;1.<.485b
       DB       #54,#BE,#FD,#EE,#FF,#FF,#80,#22       ;T>}n..."
       DB       #57,#BA,#ED,#FA,#F6,#FA,#AC,#3A       ;W:mzvz,:
       DB       #30,#39,#02,#CC,#59,#A8,#89,#03       ;09.LY(..
       DB       #07,#0F,#1F,#3F,#7F,#FF,#FC,#03       ;...?..|.
       DB       #CA,#1F,#C1,#3F,#C5,#7F,#81,#7D       ;J.A?E..}
       DB       #C0,#78,#00,#0C,#C4,#FF,#29,#E0       ;@x..D.)`
       DB       #8E,#02,#07,#0E,#1D,#3F,#7D,#FA       ;.....?}z
       DB       #FD,#FE,#F5,#DB,#F5,#EA,#DD,#05       ;}~u[uj].
       DB       #91,#84,#F7,#FF,#FF,#FD,#C0,#F8       ;..w..}@x
       DB       #DD,#FF,#2D,#E8,#94,#80,#40,#A0       ;].-h..@ 
       DB       #50,#88,#40,#A2,#11,#A4,#50,#A8       ;P.@".$P(
       DB       #41,#A8,#14,#FB,#00,#45,#EA,#BD       ;A(.{.Ej=
       DB       #FF,#00,#AC,#38,#3F,#78,#4D,#C0       ;..,8?xM@
       DB       #FE,#38,#40,#38,#48,#AD,#20,#10       ;~8@8H- .
       DB       #00,#04,#A2,#77,#00,#A8,#10,#A8       ;.."w.(.(
       DB       #D0,#F8,#D0,#E8,#70,#E8,#C0,#E8       ;PxPhph@h
       DB       #F0,#E8,#B4,#F8,#F4,#E8,#F4,#FE       ;ph4xtht~
       DB       #F4,#FA,#FC,#F6,#FC,#FA,#FC,#FA       ;tz|v|z|z
       DB       #FC,#F8,#EC,#FA,#FC,#FE,#75,#3A       ;|xlz|~u:
       DB       #37,#3E,#FD,#33,#8C,#19,#31,#01       ;7>}3..1.
       DB       #37,#81,#7D,#D2,#00,#C1,#3C,#81       ;7.}R.A<.
       DB       #FC,#20,#F3,#86,#01,#FE,#FF,#FB       ;| s..~.{
       DB       #FF,#EF,#C0,#67,#84,#7F,#7F,#3F       ;.o@g...?
       DB       #BF,#30,#C0,#8C,#00,#00,#0D,#00       ;?0@.....
       DB       #07,#FE,#15,#FB,#57,#08,#00,#1B       ;.~.{W...
       DB       #D0,#00,#81,#F0,#C1,#F3,#83,#FF       ;P..pAs..
       DB       #FA,#DD,#00,#3B,#87,#FF,#07,#F8       ;z].;...x
       DB       #5F,#A2,#F5,#DE,#11,#CD,#81,#BE       ;_"u^.M.>
       DB       #29,#AE,#8F,#6E,#01,#07,#FF,#5E       ;)..n...^
       DB       #F5,#BF,#7B,#FF,#01,#7F,#1C,#FF       ;u?{.....
       DB       #02,#1F,#7E,#EF,#97,#C0,#CE,#CF       ;..~o.@NO
       DB       #CB,#CD,#F8,#75,#AA,#45,#EB,#BD       ;KMxu*Ek=
       DB       #FA,#3C,#C8,#B0,#50,#E0,#50,#A0       ;z<H0P`P 
       DB       #50,#80,#50,#B0,#22,#5D,#90,#00       ;P.P0"]..
       DB       #B8,#1F,#FA,#55,#AB,#7F,#A2,#FF       ;8.zU+.".
       DB       #FA,#D5,#A3,#FF,#FD,#9A,#FF,#7D       ;zU#.}..}
       DB       #98,#34,#3D,#81,#07,#D0,#00,#03       ;.4=..P..
       DB       #1C,#90,#00,#C0,#FD,#F7,#A8,#1F       ;...@}w(.
       DB       #7D,#BF,#5B,#F5,#AB,#57,#FC,#80       ;}?[u+W|.
       DB       #00,#64,#7F,#71,#02,#54,#8A,#2F       ;.d.q.T./
       DB       #00,#01,#0E,#B5,#0B,#FE,#01,#00       ;...5.~..
       DB       #46,#2F,#A0,#85,#77,#54,#7F,#55       ;F/ .wT.U
       DB       #57,#1A,#C5,#89,#C0,#00,#5C,#FB       ;W.E.@.\{
       DB       #1E,#FC,#FF,#50,#BE,#7B,#27,#0C       ;.|.P>{'.
       DB       #B8,#91,#03,#B5,#03,#1C,#E7,#3A       ;8..5..g:
       DB       #D5,#AB,#5F,#FE,#6F,#FC,#17,#ED       ;U+_~o|.m
       DB       #56,#00,#08,#57,#D3,#81,#73,#C0       ;V..WS.s@
       DB       #84,#81,#73,#00,#4F,#89,#84,#B7       ;..s.O..7
       DB       #94,#74,#00,#00,#83,#84,#87,#08       ;.t......
       DB       #0E,#85,#E3,#94,#E7,#94,#E3,#08       ;..c.g.c.
       DB       #1C,#86,#E7,#84,#84,#00,#00,#4E       ;..g....N
       DB       #C0,#90,#85,#4E,#00,#00,#FA,#22       ;@..N..z"
       DB       #14,#73,#20,#07,#2F,#F8,#81,#39       ;.s ./x.9
       DB       #C0,#A4,#92,#39,#00,#00,#19,#A5       ;@$.9...%
       DB       #3D,#A5,#A5,#00,#00,#A2,#22,#22       ;=%%.."""
       DB       #14,#88,#00,#00,#A0,#C0,#21,#84       ;.... @!.
       DB       #9C,#00,#00,#38,#C1,#A5,#83,#00       ;...8A%..
       DB       #00,#80,#C0,#40,#8F,#81,#00,#00       ;..@@....
       DB       #5C,#52,#D2,#52,#5C,#00,#00,#4C       ;\RRR\..L
       DB       #52,#DE,#52,#52,#C7,#00,#81,#DC       ;R^RRG..\
       DB       #C0,#92,#8D,#D2,#00,#00,#C9,#29       ;@..R..I)
       DB       #2F,#C9,#09,#00,#00,#74,#84,#E4       ;/I...t.d
       DB       #08,#8E,#81,#C9,#C0,#29,#86,#C6       ;...I@).F
       DB       #00,#00,#CF,#22,#E2,#0C,#E5,#8B       ;..O"b.e.
       DB       #46,#C9,#47,#41,#EE,#00,#00,#06       ;FIGAn...
       DB       #09,#0F,#09,#00,#23,#85,#E4,#94       ;....#.d.
       DB       #97,#94,#94,#C7,#00,#88,#70,#84       ;...G..p.
       DB       #B0,#94,#70,#00,#00,#73,#C0,#24       ;0.p..s@$
       DB       #00,#C7,#8F,#1C,#20,#18,#04,#B8       ;.G.. ..8
       DB       #00,#00,#39,#42,#32,#0A,#71,#00       ;..9B2.q.
       DB       #00,#B9,#C0,#12,#00,#9C,#84,#33       ;.9@....3
       DB       #48,#39,#08,#00,#E3,#81,#73,#C0       ;H9..c.s@
       DB       #4A,#87,#4B,#00,#00,#9C,#A0,#18       ;J.K... .
       DB       #84,#00,#23,#2F,#D8,#85,#1C,#21       ;..#/X..!
       DB       #39,#21,#21,#00,#16,#83,#21,#18       ;9!!...!.
       DB       #05,#00,#39,#81,#1C,#00,#32,#87       ;..9...2.
       DB       #1C,#00,#00,#91,#51,#51,#4A,#00       ;....QQJ.
       DB       #F9,#81,#C0,#03,#CE,#8F,#C1,#00       ;y.@.N.A.
       DB       #00,#81,#41,#81,#41,#89,#10,#00       ;..A.A...
       DB       #81,#42,#43,#42,#82,#07,#43,#C1       ;.BCB..CA
       DB       #04,#C7,#00,#98,#CE,#29,#E9,#29       ;.G..N)i)
       DB       #29,#00,#00,#0E,#09,#0E,#09,#0E       ;).......
       DB       #00,#00,#73,#84,#E3,#80,#77,#00       ;..s.c.w.
       DB       #00,#03,#04,#07,#08,#24,#96,#EF       ;.....$.o
       DB       #02,#C2,#22,#C2,#00,#00,#C7,#28       ;.B"B..G(
       DB       #2E,#28,#C7,#00,#00,#CC,#12,#9E       ;.(G..L..
       DB       #12,#12,#00,#00,#30,#C0,#48,#81       ;....0@H.
       DB       #30,#3F,#FE,#8B,#33,#48,#78,#48       ;0?~.3HxH
       DB       #48,#00,#00,#3A,#42,#72,#42,#01       ;H..:BrB.
       DB       #47,#00,#B2,#81,#92,#01,#4E,#81       ;G.2...N.
       DB       #20,#C0,#A1,#01,#40,#88,#98,#25       ; @!.@..%
       DB       #3C,#24,#25,#00,#00,#39,#00,#79       ;<$%..9.y
       DB       #01,#63,#81,#E3,#18,#F9,#81,#39       ;.c.c.y.9
       DB       #C0,#25,#45,#2B,#81,#EE,#01,#C0       ;@%E+.n.@
       DB       #84,#8E,#00,#00,#0C,#00,#EB,#87       ;......k.
       DB       #CC,#00,#00,#DC,#12,#D2,#52,#01       ;L..\.RR.
       DB       #4E,#8B,#E9,#09,#C6,#09,#E9,#00       ;N.i.F.i.
       DB       #00,#E0,#00,#C0,#20,#05,#3B,#88       ;.`.@ .;.
       DB       #D1,#1B,#95,#11,#D1,#00,#00,#3E       ;Q...Q..>
       DB       #C1,#88,#87,#00,#00,#2E,#29,#29       ;A.....))
       DB       #2E,#C8,#41,#40,#C0,#80,#01,#40       ;.HA@@..@
       DB       #85,#93,#94,#93,#90,#67,#13,#4F       ;.....g.O
       DB       #03,#51,#86,#00,#33,#4A,#7A,#4A       ;.Q..3JzJ
       DB       #4A,#37,#CA,#84,#71,#4A,#73,#4A       ;J7J.qJsJ
       DB       #01,#4E,#81,#E7,#00,#B9,#81,#E7       ;.N.g.9.g
       DB       #68,#1C,#85,#00,#3B,#40,#30,#08       ;h...;@0.
       DB       #01,#80,#85,#99,#25,#25,#A4,#18       ;....%%$.
       DB       #37,#FC,#81,#9C,#C0,#52,#01,#EB       ;7|..@R.k
       DB       #C4,#00,#84,#DC,#12,#9C,#12,#01       ;D..\....
       DB       #E3,#83,#03,#04,#03,#0B,#04,#81       ;c.......
       DB       #8C,#00,#1C,#81,#4C,#3F,#BE,#87       ;....L?>.
       DB       #E6,#89,#8F,#89,#89,#00,#00,#C0       ;f......@
       DB       #10,#82,#A0,#40,#37,#D4,#85,#E0       ;.. @7T.`
       DB       #90,#E0,#90,#90,#6F,#E2,#84,#BE       ;.`..ob.>
       DB       #08,#08,#88,#02,#BC,#00,#C6,#81       ;....<.F.
       DB       #50,#46,#87,#81,#38,#18,#80,#81       ;PF..8...
       DB       #32,#00,#B2,#81,#49,#DB,#00,#8C       ;2.2.I[..
       DB       #63,#94,#F3,#90,#97,#00,#00,#19       ;c.s.....
       DB       #25,#3D,#25,#24,#77,#30,#85,#0E       ;%=%$w0..
       DB       #10,#1C,#10,#CE,#DB,#00,#04,#6A       ;...N[..j
       DB       #09,#1C,#84,#07,#08,#0E,#08,#01       ;........
       DB       #07,#67,#72,#83,#93,#94,#67,#4A       ;.gr...gJ
       DB       #96,#D8,#00,#83,#49,#4A,#33,#78       ;.X..IJ3x
       DB       #AA,#82,#00,#39,#1B,#2B,#E0,#00       ;*..9.+`.
       DB       #85,#D2,#12,#8E,#02,#DC,#CE,#00       ;.R...\N.
       DB       #85,#CE,#29,#2E,#29,#C9,#FF,#00       ;.N).)I..
       DB       #FF,#00,#F3,#00,#84,#01,#39,#79       ;..s...9y
       DB       #79,#2E,#E8,#85,#3F,#1F,#0F,#07       ;y.h.?...
       DB       #02,#C9,#01,#C5,#03,#C7,#07,#07       ;.I.E.G..
       DB       #C6,#85,#07,#07,#03,#03,#01,#2F       ;F....../
       DB       #6E,#88,#07,#E7,#E7,#E6,#FD,#6A       ;n..ggf}j
       DB       #FF,#FE,#06,#FC,#06,#9F,#84,#FF       ;.~.|....
       DB       #FC,#C3,#3F,#07,#B1,#81,#FB,#00       ;|C?.1.{.
       DB       #10,#9A,#E6,#E4,#E6,#FD,#FE,#FB       ;..fdf}~{
       DB       #FE,#FD,#EE,#FD,#BB,#35,#3E,#3C       ;~}n};5><
       DB       #FE,#FD,#FA,#EC,#FE,#FC,#F8,#FC       ;~}zl~|x|
       DB       #DA,#FC,#EE,#F5,#26,#DD,#86,#F9       ;Z|nu&].y
       DB       #79,#79,#3F,#3F,#1F,#07,#D4,#9A       ;yy??..T.
       DB       #DF,#5F,#1F,#5F,#9F,#5F,#DB,#53       ;__._._[S
       DB       #93,#D3,#9F,#DF,#1F,#5E,#9F,#DF       ;.S._.^._
       DB       #9F,#1F,#9F,#5F,#9D,#3F,#BF,#3F       ;..._.???
       DB       #BF,#3F,#C0,#BF,#82,#3F,#7E,#2F       ;??@?.?~/
       DB       #85,#81,#FE,#10,#61,#9A,#FF,#FF       ;..~.a...
       DB       #FB,#E9,#F5,#E1,#F3,#EB,#BB,#EB       ;{iuask;k
       DB       #F3,#EB,#D7,#E7,#D7,#77,#D7,#A7       ;skWgWwW'
       DB       #57,#8F,#CF,#6F,#CF,#AF,#CF,#AF       ;W.OoO/O/
       DB       #00,#44,#00,#3A,#81,#DF,#00,#40       ;.D.:._.@
       DB       #00,#4E,#81,#DF,#08,#0E,#08,#0C       ;.N._....
       DB       #18,#10,#00,#52,#10,#18,#10,#0C       ;...R....
       DB       #67,#A0,#81,#BF,#07,#F7,#2F,#5F       ;g .?.w/_
       DB       #87,#F1,#CA,#95,#2F,#58,#27,#9F       ;.qJ./X'.
       DB       #17,#6B,#83,#FD,#FB,#FB,#C2,#F7       ;.k.}{{Bw
       DB       #C8,#EE,#86,#EC,#DC,#DC,#DD,#DC       ;Hn.l\\]\
       DB       #DC,#D6,#FF,#85,#C0,#2A,#55,#BF       ;\V..@*U?
       DB       #E0,#10,#3D,#9D,#E0,#9F,#7F,#FF       ;`.=.`...
       DB       #F0,#C0,#84,#8A,#05,#2B,#56,#2F       ;p@...+V/
       DB       #07,#2F,#5F,#B7,#5F,#3F,#5F,#BF       ;./_7_?_?
       DB       #6F,#3F,#7B,#BB,#7F,#BB,#7B,#FB       ;o?{;.;{{
       DB       #7B,#1F,#E3,#81,#DF,#C0,#8F,#60       ;{.c._@.`
       DB       #8A,#85,#01,#AE,#FF,#FF,#E7,#17       ;......g.
       DB       #73,#8E,#07,#F9,#FE,#FF,#0F,#A3       ;s..y~..#
       DB       #55,#BD,#7E,#DE,#FA,#BA,#FB,#BF       ;U=~^z:{?
       DB       #C0,#BB,#81,#BF,#10,#06,#C2,#BB       ;@;.?..B;
       DB       #01,#5D,#83,#FC,#FE,#F7,#09,#0E       ;.].|~w..
       DB       #0F,#4F,#81,#FD,#C0,#F8,#20,#BD       ;.O.}@x =
       DB       #89,#FF,#FF,#1F,#E3,#FC,#FF,#BF       ;....c|.?
       DB       #C7,#FD,#01,#2A,#86,#FB,#FF,#7F       ;G}.*.{..
       DB       #BF,#DF,#DF,#C2,#EF,#C8,#77,#81       ;?__BoHw.
       DB       #B7,#10,#44,#09,#5B,#11,#0F,#87       ;7.D.[...
       DB       #AF,#4D,#8C,#CC,#AC,#CF,#AF,#11       ;/M.L,O/.
       DB       #47,#96,#E7,#D7,#EB,#F3,#AB,#D3       ;G.gWks+S
       DB       #FB,#D3,#6B,#B3,#E3,#B3,#6B,#F3       ;{Sk3c3ks
       DB       #EB,#53,#BB,#D3,#EB,#53,#EB,#C3       ;kS;SkSkC
       DB       #01,#65,#85,#D3,#EB,#FB,#EB,#73       ;.e.Sk{ks
       DB       #01,#6D,#85,#F3,#DB,#F3,#AB,#F3       ;.m.s[s+s
       DB       #08,#12,#94,#6B,#9D,#9F,#95,#FE       ;...k...~
       DB       #FD,#BA,#F1,#FB,#F6,#AA,#F4,#EC       ;}:q{v*tl
       DB       #C0,#E9,#D1,#E9,#73,#E3,#D3,#00       ;@iQiscS.
       DB       #16,#83,#33,#2B,#3B,#00,#2C,#81       ;..3+;.,.
       DB       #C0,#10,#32,#01,#9D,#94,#E9,#F5       ;@.2...iu
       DB       #F9,#F5,#E9,#F5,#D9,#F1,#F9,#F4       ;yuiuYqyt
       DB       #FA,#FC,#FA,#FC,#FA,#EC,#FA,#FE       ;z|z|zlz~
       DB       #FA,#FD,#02,#0D,#89,#FC,#FA,#FD       ;z}...|z}
       DB       #FA,#60,#A0,#40,#C0,#80,#0C,#EC       ;z` @@..l
       DB       #14,#70,#C0,#E7,#31,#91,#8D,#FB       ;.p@g1..{
       DB       #FF,#3F,#C2,#FC,#FE,#FD,#76,#3F       ;.?B|~}v?
       DB       #3E,#3D,#FE,#FF,#02,#3D,#85,#FC       ;>=~..=.|
       DB       #FE,#FF,#FB,#EF,#02,#61,#10,#EA       ;~.{o.a.j
       DB       #02,#A5,#12,#0C,#81,#BF,#CB,#00       ;.%...?K.
       DB       #91,#80,#9C,#9E,#9A,#FC,#AA,#5E       ;.....|*^
       DB       #EA,#F4,#FA,#F0,#6A,#F4,#A8,#70       ;jtzpjt(p
       DB       #A0,#40,#0D,#48,#05,#5A,#81,#00       ; @.H.Z..
       DB       #10,#08,#94,#40,#80,#40,#80,#40       ;...@.@.@
       DB       #00,#40,#A0,#C0,#A0,#40,#A0,#E0       ;.@ @ @ `
       DB       #A0,#C0,#E0,#40,#A0,#D0,#E0,#FF       ; @`@ P`.
       DB       #00,#FF,#00,#C4,#00,#12,#80,#93       ;...D....
       DB       #FF,#F7,#FF,#7D,#BA,#75,#BA,#55       ;.w.}:u:U
       DB       #AA,#D7,#AE,#55,#AA,#45,#AA,#51       ;*W.U*E*Q
       DB       #8A,#45,#8A,#0D,#66,#81,#10,#D1       ;.E..f..Q
       DB       #00,#83,#01,#03,#0F,#C9,#00,#81       ;.....I..
       DB       #F0,#18,#41,#92,#FF,#FF,#BA,#5D       ;p.A...:]
       DB       #BA,#55,#AB,#5D,#AA,#55,#AA,#15       ;:U+]*U*.
       DB       #AA,#45,#A2,#48,#00,#01,#25,#D1       ;*E"H..%Q
       DB       #13,#C4,#8E,#02,#03,#06,#05,#0E       ;.D......
       DB       #0D,#1B,#17,#2B,#37,#6F,#DF,#BF       ;...+7o_?
       DB       #FF,#58,#FF,#03,#B6,#81,#7F,#03       ;.X..6...
       DB       #8C,#85,#5F,#AA,#55,#BA,#D5,#10       ;.._*U:U.
       DB       #3E,#93,#55,#88,#54,#00,#00,#0F       ;>.U.T...
       DB       #35,#6A,#D7,#AF,#DF,#AF,#DF,#BF       ;5jW/_/_?
       DB       #7F,#BF,#7F,#BF,#7F,#08,#22,#0B       ;.?.?..".
       DB       #DD,#81,#FE,#C1,#FD,#29,#B8,#C4       ;].~A})8D
       DB       #00,#22,#79,#8D,#FF,#DF,#7D,#FA       ;."y.._}z
       DB       #FD,#AA,#55,#AB,#D5,#A2,#55,#2A       ;}*U+U"U*
       DB       #85,#07,#BE,#87,#70,#F8,#FC,#FC       ;..>.px||
       DB       #F8,#F0,#F0,#00,#06,#83,#FC,#FC       ;xpp...||
       DB       #E0,#10,#07,#87,#84,#78,#D4,#EA       ;`....xTj
       DB       #F6,#FA,#FC,#69,#7D,#10,#C1,#87       ;vz|i}.A.
       DB       #FE,#FF,#F7,#BF,#5F,#BA,#5F,#01       ;~.w?_:_.
       DB       #02,#86,#55,#AA,#55,#82,#55,#0A       ;..U*U.U.
       DB       #0D,#CE,#46,#68,#DA,#00,#2A,#3A       ;.NFhZ.*:
       DB       #84,#5F,#BF,#55,#EA,#08,#40,#01       ;._?Uj.@.
       DB       #00,#84,#AA,#54,#20,#04,#E5,#00       ;..*T .e.
       DB       #81,#0F,#11,#00,#87,#FF,#EF,#FF       ;......o.
       DB       #7F,#AE,#5D,#EA,#00,#C2,#86,#2A       ;..]j.B.*
       DB       #55,#AA,#41,#82,#00,#08,#3F,#79       ;U*A...?y
       DB       #7F,#D0,#00,#0C,#4C,#81,#BF,#0B       ;.P..L.?.
       DB       #87,#86,#EF,#D5,#AA,#7D,#FA,#57       ;..oU*}zW
       DB       #08,#40,#84,#A8,#54,#A0,#02,#E6       ;.@.(T .f
       DB       #00,#1A,#F5,#0C,#0E,#86,#7F,#BA       ;..u....:
       DB       #7D,#AA,#55,#A2,#01,#02,#00,#82       ;}*U"....
       DB       #81,#04,#78,#FD,#D3,#00,#00,#BE       ;..x}S..>
       DB       #0D,#4A,#01,#C2,#87,#AB,#77,#AF       ;.J.B.+w/
       DB       #55,#AA,#D5,#AA,#08,#82,#85,#51       ;U*U*...Q
       DB       #82,#45,#0A,#00,#79,#3F,#D1,#00       ;.E..y?Q.
       DB       #29,#BE,#83,#F6,#7D,#EA,#00,#BC       ;)>.v}j.<
       DB       #82,#FA,#74,#11,#82,#85,#15,#AA       ;.zt....*
       DB       #41,#00,#00,#07,#EE,#E0,#00,#15       ;A...n`..
       DB       #CA,#05,#FA,#81,#FB,#02,#7A,#82       ;J.z.{.z.
       DB       #EA,#75,#09,#BE,#87,#AA,#55,#0A       ;ju.>.*U.
       DB       #15,#82,#00,#00,#79,#BE,#D1,#00       ;....y>Q.
       DB       #81,#03,#1A,#7E,#85,#EF,#FE,#BB       ;...~.o~;
       DB       #55,#BE,#00,#FE,#09,#7E,#85,#A0       ;U>.~.~. 
       DB       #54,#A0,#44,#00,#62,#64,#D6,#00       ;T D.bdV.
       DB       #82,#FF,#DF,#20,#80,#85,#AE,#5F       ;.._ ..._
       DB       #BE,#D7,#AA,#08,#80,#87,#15,#22       ;>W*...."
       DB       #55,#A8,#00,#00,#40,#2E,#9D,#DC       ;U(..@..\
       DB       #00,#26,#09,#02,#FE,#82,#57,#EE       ;.&..~.Wn
       DB       #0B,#7A,#86,#55,#AA,#05,#8A,#44       ;.z.U*..D
       DB       #00,#7B,#78,#D5,#00,#23,#7D,#83       ;.{xU.#}.
       DB       #EA,#57,#BE,#02,#FA,#03,#7C,#82       ;jW>.z.|.
       DB       #01,#A2,#1B,#BA,#E4,#00,#0B,#57       ;.".:d..W
       DB       #81,#FE,#01,#FA,#85,#AE,#57,#AA       ;.~.z..W*
       DB       #5D,#AB,#03,#BA,#81,#A8,#03,#FE       ;]+.:.(.~
       DB       #81,#00,#7B,#F6,#D6,#00,#07,#70       ;..{vV..p
       DB       #8B,#F6,#FC,#FC,#FE,#DF,#FF,#57       ;.v||~_.W
       DB       #AA,#F5,#AB,#55,#0B,#3E,#82,#88       ;*u+U.>..
       DB       #10,#02,#7B,#7B,#3A,#CC,#00,#C3       ;..{{:L.C
       DB       #0F,#87,#0E,#0F,#0A,#01,#1E,#1F       ;........
       DB       #03,#C0,#00,#84,#E0,#FF,#DF,#75       ;.@..`._u
       DB       #00,#84,#85,#15,#AA,#54,#A8,#04       ;....*T(.
       DB       #79,#3A,#7D,#2E,#81,#D9,#0D,#DB       ;y:}..Y.[
       DB       #89,#71,#F9,#D5,#8B,#5B,#03,#F8       ;.qyU.[.x
       DB       #5F,#0A,#05,#C8,#83,#C0,#AE,#5D       ;_..H.@.]
       DB       #01,#00,#85,#15,#AA,#51,#80,#00       ;....*Q..
       DB       #7A,#FB,#7D,#6E,#8F,#FF,#FF,#FE       ;z{}n...~
       DB       #FF,#FD,#FF,#FE,#FF       ;.}.~.
L_74A6       DB       #DE,#F5,#AE,#04,#F0,#BF,#15,#0D       ;^u..p?..
       DB       #C4,#81,#57,#04,#FA,#82,#14,#A0       ;D.W.z.. 
       DB       #7C,#F2,#D2,#00,#27,#CC,#17,#D6       ;|rR.'L.V
       DB       #83,#00,#FF,#5F,#01,#ED,#85,#AE       ;..._.m..
       DB       #55,#28,#41,#80,#7D,#30,#D4,#00       ;U(A.}0T.
       DB       #07,#C4,#07,#C6,#08,#06,#C0,#DD       ;.D.F..@]
       DB       #83,#00,#FF,#55,#06,#44,#EA,#00       ;...U.Dj.
       DB       #8D,#FF,#7B,#FF,#7B,#FB,#FB,#BB       ;..{.{{{;
       DB       #FB,#FB,#BF,#FB,#BB,#BB,#10,#40       ;{{?{;;.@
       DB       #EB,#00,#0F,#C9,#37,#CE,#83,#00       ;k..I7N..
       DB       #FF,#57,#ED,#00,#0F,#C5,#81,#BA       ;.Wm..E.:
       DB       #18,#40,#82,#BA,#B9,#06,#43,#ED       ;.@.:9.Cm
       DB       #00,#82,#D3,#E3,#07,#E8,#8A,#EB       ;..Sc.h.k
       DB       #73,#AB,#53,#A3,#13,#AA,#00,#D5       ;s+S#.*.U
       DB       #FF,#07,#8A,#86,#01,#14,#0A,#05       ;........
       DB       #08,#05,#03,#B8,#7C,#BA,#D0,#00       ;...8|:P.
       DB       #8F,#FF,#FE,#FD,#FE,#FF,#FA,#FF       ;..~}~.z.
       DB       #FE,#EF,#BA,#57,#E0,#0A,#7F,#F8       ;~o:W`..x
       DB       #07,#C9,#05,#36,#81,#51,#13,#FE       ;.I.6.Q.~
       DB       #83,#50,#02,#05,#7A,#82,#37,#B0       ;.P..z.70
       DB       #0D,#18,#85,#01,#02,#45,#3F,#BF       ;.....E??
       DB       #C0,#3F,#89,#BF,#3B,#BE,#55,#9E       ;@?.?;>U.
       DB       #40,#15,#BF,#F0,#0E,#D5,#88,#AE       ;@.?p.U..
       DB       #5D,#EB,#55,#AB,#57,#8A,#55,#07       ;]kU+W.U.
       DB       #00,#87,#51,#A2,#51,#08,#85,#0A       ;..Q"Q...
       DB       #05,#06,#EA,#07,#E7,#14,#86,#0B       ;..j.g...
       DB       #CD,#81,#01,#05,#93,#84,#01,#00       ;M.......
       DB       #25,#0A,#00,#1E,#8F,#AA,#15,#50       ;%....*.P
       DB       #E0,#D0,#80,#D0,#60,#D0,#A0,#50       ;`P.P`P P
       DB       #80,#58,#F8,#C0,#C0,#00,#81,#03       ;.Xx@@...
       DB       #05,#3E,#89,#AF,#55,#EB,#D6,#AB       ;.>./UkV+
       DB       #55,#AE,#75,#AE,#0E,#06,#92,#51       ;U.u....Q
       DB       #AA,#57,#2A,#55,#0A,#14,#0A,#55       ;*W*U...U
       DB       #02,#15,#2A,#17,#2A,#55,#22,#11       ;..*.*U".
       DB       #2A,#00,#9E,#87,#8B,#55,#AA,#5D       ;*....U*]
       DB       #AA,#7D,#BA,#06,#E2,#C5,#00,#87       ;*}:.bE..
       DB       #E0,#FF,#7F,#7F,#3F,#1E,#3F,#27       ;`...?.?'
       DB       #43,#06,#C6,#88,#5F,#BF,#7B,#BF       ;C.F._?{?
       DB       #55,#AA,#57,#FA,#0F,#48,#82,#7D       ;U*Wz.H.}
       DB       #BA,#03,#94,#16,#52,#83,#55,#FA       ;:...R.Uz
       DB       #D5,#06,#5A,#88,#57,#AE,#57,#AF       ;U.Z.W.W/
       DB       #57,#EA,#55,#BE,#04,#E6,#C7,#00       ;WjU>.fG.
       DB       #81,#F8,#CC,#FF,#05,#0B,#0E,#4D       ;.xL....M
       DB       #07,#32,#81,#BB,#0E,#55,#84,#5F       ;.2.;.U._
       DB       #AB,#57,#EF,#0F,#48,#86,#5D,#BF       ;+Wo.H.]?
       DB       #5F,#FF,#7F,#EF,#07,#25,#17,#6E       ;_..o.%.n
       DB       #81,#BF,#CC,#47,#C0,#45,#82,#46       ;.?LG@E.F
       DB       #46,#00,#05,#82,#42,#42,#C3,#45       ;F...BBCE
       DB       #81,#40,#78,#20,#08,#19,#C0,#42       ;.@x ..@B
       DB       #20,#0A,#78,#40,#18,#1F,#28,#41       ; .x@..(A
       DB       #CD,#47,#40,#36,#78,#40,#10,#80       ;MG@6x@..
       DB       #58,#8E,#78,#7D,#40,#73,#10,#AE       ;X.x}@s..
       DB       #C7,#46,#78,#20,#58,#20,#10,#2C       ;GFx X .,
       DB       #60,#F0,#78,#20,#59,#10,#CE,#44       ;`px Y.ND
       DB       #61,#31,#78,#20,#78,#20,#78,#40       ;a1x x x@
       DB       #78,#40,#78,#60,#78,#60,#78,#80       ;x@x`x`x.
       DB       #78,#80,#78,#A0,#78,#C0,#78,#C0       ;x.x x@x@
       DB       #78,#E0,#2A,#18,#CF,#42,#78,#1E       ;x`*.OBx.
       DB       #FB,#42,#78,#64,#68,#6E,#D9,#42       ;{BxdhnYB
       DB       #78,#A4,#78,#AE,#D9,#42,#80       ;x$x.YB.
;
DepackInputLevelCodeScreen
	halt;DI
	CALL	reter;#0052
	DEC	SP
	DEC	SP
	POP	BC
	LD	HL,#0097
	ADD	HL,BC
	EX	DE,HL
	LD	HL,#0066
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#007B
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#0089
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#00BE
	ADD	HL,BC
	LD	DE,#4000
	PUSH	DE
	EXX
	EX	AF,AF' ;'
	LD	A,#03
	OR	A
	LD	B,#08
	LD	C,B
	POP	HL
	EX	AF,AF' ;'
	EXX
L_76B9	LD	A,(HL)
	BIT	7,A
	JR	NZ,L_76F8
	AND	#07
	LD	C,A
	LD	A,(HL)
	RRCA
	RRCA
	RRCA
	AND	#0F
	ADD	A,#03
	LD	B,A
	INC	HL
	LD	A,E
	SUB	(HL)
	INC	HL
	PUSH	HL
	LD	L,A
	LD	A,D
	SBC	A,C
	LD	H,A
L_76D3	PUSH	HL
	LD	A,H
	AND	#58
	CP	#58
	JR	Z,L_76ED
	LD	C,A
	LD	A,L
	AND	#07
	OR	C
	LD	C,A
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H
	AND	#1F
	LD	H,A
	LD	A,L
	AND	#E0
	OR	H
	LD	L,A
	LD	H,C
L_76ED	LD	A,(HL)
	CALL	L_74A6
	POP	HL
	INC	HL
	DJNZ	L_76D3
	POP	HL
	JR	L_76B9
;
L_76F8	AND	#7F
	JR	Z,L_7719
	INC	HL
	BIT	6,A
	JR	NZ,L_770B
	LD	B,A
L_7702	LD	A,(HL)
	CALL	L_74A6
	INC	HL
	DJNZ	L_7702
	JR	L_76B9
;
L_770B	AND	#3F
	ADD	A,#03
	LD	B,A
	LD	A,(HL)
L_7711	CALL	L_74A6
	DJNZ	L_7711
	INC	HL
	JR	L_76B9
;
L_7719	EXX
	LD	HL,#2758
	EXX
	EI
	RET
;
       DB       #13,#D9,#77,#08,#28,#19,#24,#10       ;.Yw.(.$.
       DB       #1B,#11,#20,#F8,#19,#0D,#20,#12       ;.. x.. .
       DB       #11,#01,#FF,#19,#C6,#08,#30,#08       ;....F.0.
       DB       #11,#E0,#07,#19,#3D,#18,#01,#23       ;.`..=..#
       DB       #0E,#08,#06,#08,#08,#D9,#C9,#FF       ;.....YI.
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#E6,#00,#83,#01,#02       ;...f....
       DB       #05,#F8,#00,#85,#15,#2A,#55,#AB       ;.x...*U+
       DB       #77,#F7,#00,#86,#AA,#55,#AB,#7F       ;ww..*U+.
       DB       #FF,#FF,#F7,#00,#83,#80,#50,#EA       ;..w...Pj
       DB       #C0,#FF,#FA,#00,#83,#80,#C0,#E0       ;@.z...@`
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#EC,#00,#82,#01,#00,#07       ;..l.....
       DB       #A6,#90,#02,#05,#0A,#05,#0A,#17       ;&.......
       DB       #0A,#15,#2B,#15,#2B,#15,#2B,#17       ;..+.+.+.
       DB       #2B,#15,#C7,#00,#B6,#0A,#05,#0B       ;+.G.6...
       DB       #15,#0B,#16,#2B,#1F,#2B,#17,#2A       ;...+.+.*
       DB       #16,#2E,#16,#2F,#17,#2F,#1F,#2F       ;.../././
       DB       #17,#2B,#17,#2F,#57,#2F,#57,#2B       ;.+./W/W+
       DB       #5F,#AB,#55,#AB,#57,#AA,#55,#AA       ;_+U+W*U*
       DB       #5D,#AA,#57,#BC,#F1,#EA,#55,#CB       ;]*W<qjUK
       DB       #97,#AB,#97,#2F,#5F,#2F,#5F,#3F       ;.+./_/_?
       DB       #5F,#3F,#7F,#C7,#00,#86,#BF,#7F       ;_?.G..?.
       DB       #FF,#C3,#00,#7E,#00,#04,#88,#00       ;.C.~....
       DB       #06,#0F,#0F,#06,#00,#00,#C3,#C6       ;......CF
       DB       #FF,#84,#F9,#F8,#FC,#FE,#07,#61       ;..yx|~.a
       DB       #89,#7F,#AF,#57,#AB,#FD,#07,#51       ;../W+}.Q
       DB       #AA,#7D,#C9,#FF,#C7,#00,#10,#2F       ;*}I.G../
       DB       #81,#7E,#10,#05,#C0,#7E,#CA,#FF       ;.~..@~J.
       DB       #81,#3C,#C0,#00,#38,#4F,#89,#7E       ;.<@.8O.~
       DB       #7E,#BC,#BD,#BC,#D9,#DA,#D9,#DA       ;~<=<YZYZ
       DB       #00,#04,#81,#DB,#C7,#00,#07,#C3       ;...[G..C
       DB       #78,#80,#10,#84,#84,#9F,#1F,#3F       ;x......?
       DB       #7F,#28,#8D,#87,#E0,#8A,#55,#AB       ;.(..`.U+
       DB       #5F,#BF,#5F,#00,#AD,#18,#13,#C7       ;_?_.-..G
       DB       #00,#82,#F0,#F0,#C0,#F8,#81,#78       ;..pp@x.x
       DB       #C1,#FC,#C1,#7C,#C6,#FC,#C3,#FE       ;A|A|F|C~
       DB       #30,#CC,#85,#3F,#8F,#57,#EB,#FB       ;0L.?.Wk{
       DB       #C0,#FD,#C5,#FE,#CF,#00,#8A,#FE       ;@}E~O..~
       DB       #80,#80,#94,#8A,#94,#8E,#96,#8E       ;........
       DB       #96,#08,#04,#8A,#8E,#96,#0E,#97       ;........
       DB       #8F,#97,#0F,#57,#00,#2F,#C0,#80       ;...W./@.
       DB       #84,#C0,#C0,#E0,#E0,#C0,#F0,#C1       ;.@@``@pA
       DB       #F8,#28,#60,#C7,#00,#87,#FF,#80       ;x(`G....
       DB       #80,#95,#8A,#97,#8F,#30,#38,#81       ;.....08.
       DB       #8E,#00,#38,#85,#8F,#97,#80,#FF       ;..8.....
       DB       #00,#19,#28,#41,#6A,#D3,#00,#01       ;..(AjS..
       DB       #4B,#82,#55,#AA,#49,#51,#81,#55       ;K.U*IQ.U
       DB       #11,#60,#28,#40,#41,#6A,#D3,#00       ;.`(@AjS.
       DB       #78,#40,#78,#40,#D9,#00,#78,#80       ;x@x@Y.x.
       DB       #78,#80,#D9,#00,#78,#C0,#78,#C0       ;x.Y.x@x@
       DB       #D9,#00,#8B,#FF,#01,#01,#55,#A9       ;Y.....U)
       DB       #FD,#FD,#7D,#3D,#7D,#3D,#08,#04       ;}}}=}=..
       DB       #00,#08,#C1,#FD,#81,#01,#79,#00       ;..A}..y.
       DB       #DC,#00,#81,#7F,#00,#48,#81,#29       ;\....H.)
       DB       #C9,#7D,#C2,#FD,#00,#48,#FF,#00       ;I}B}.H..
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#CD,#00       ;......M.
       DB       #86,#7C,#72,#7C,#72,#72,#7C,#F7       ;.|r|rr|w
       DB       #00,#78,#40,#EB,#00,#86,#3E,#70       ;.x@k..>p
       DB       #7C,#70,#70,#3E,#F7,#00,#81,#1E       ;|pp>w...
       DB       #C1,#2E,#82,#7E,#42,#F6,#00,#86       ;A..~Bv..
       DB       #72,#72,#76,#7A,#72,#72,#F7,#00       ;rrvzrrw.
       DB       #81,#7F,#C2,#1C,#F7,#00,#79,#00       ;..B.w.y.
       DB       #FF,#00,#E9,#00,#01,#FD,#C0,#72       ;..i..}@r
       DB       #F7,#00,#81,#3C,#C1,#72,#81,#3C       ;w..<Ar.<
       DB       #F7,#00,#79,#C0,#FF,#00,#E9,#00       ;w.y@..i.
       DB       #C0,#4E,#82,#3E,#0E,#78,#C0,#E6       ;@N.>.x@f
       DB       #00,#0B,#3E,#82,#70,#70,#F7,#00       ;..>.ppw.
       DB       #79,#40,#EB,#00,#7B,#C0,#EB,#00       ;y@k.{@k.
       DB       #83,#72,#72,#7E,#7A,#00,#E8,#00       ;.rr~z.h.
       DB       #81,#3E,#01,#40,#82,#4E,#4E,#FF       ;.>.@.NN.
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#D8,#00,#FF       ;.....X..
       DB       #42,#FF,#42,#FF,#42,#E1,#42,#C2       ;B.B.BaBB
       DB       #47,#D8,#42,#18,#20,#C3,#47,#D1       ;GXB. CGQ
       DB       #42,#84,#47,#45,#47,#45,#00,#04       ;B.GEGE..
       DB       #C1,#46,#82,#47,#45,#D0,#42,#10       ;AF.GEPB.
       DB       #60,#81,#45,#18,#40,#78,#20,#20       ;`.E.@x  
       DB       #59,#C5,#45,#79,#77,#C4,#47,#D6       ;YEEywDGV
       DB       #42,#78,#20,#78,#DF,#78,#E1,#FF       ;Bx x_xa.
       DB       #42,#FF,#42,#FF,#42,#FF,#42,#D6       ;B.B.B.BV
       DB       #42,#80       ;B.
;
DepackControlInformationScreen
	halt;DI
	CALL	reter;#0052
	DEC	SP
	DEC	SP
	POP	BC
	LD	HL,#0097
	ADD	HL,BC
	EX	DE,HL
	LD	HL,#0066
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#007B
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#0089
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#00BE
	ADD	HL,BC
	LD	DE,#4000
	PUSH	DE
	EXX
	EX	AF,AF' ;'
	LD	A,#03
	OR	A
	LD	B,#08
	LD	C,B
	POP	HL
	EX	AF,AF' ;'
	EXX
L_7A26	LD	A,(HL)
	BIT	7,A
	JR	NZ,L_7A65
	AND	#07
	LD	C,A
	LD	A,(HL)
	RRCA
	RRCA
	RRCA
	AND	#0F
	ADD	A,#03
	LD	B,A
	INC	HL
	LD	A,E
	SUB	(HL)
	INC	HL
	PUSH	HL
	LD	L,A
	LD	A,D
	SBC	A,C
	LD	H,A
L_7A40	PUSH	HL
	LD	A,H
	AND	#58
	CP	#58
	JR	Z,L_7A5A
	LD	C,A
	LD	A,L
	AND	#07
	OR	C
	LD	C,A
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H
	AND	#1F
	LD	H,A
	LD	A,L
	AND	#E0
	OR	H
	LD	L,A
	LD	H,C
L_7A5A	LD	A,(HL)
	CALL	L_74A6
	POP	HL
	INC	HL
	DJNZ	L_7A40
	POP	HL
	JR	L_7A26
;
L_7A65	AND	#7F
	JR	Z,L_7A86
	INC	HL
	BIT	6,A
	JR	NZ,L_7A78
	LD	B,A
L_7A6F	LD	A,(HL)
	CALL	L_74A6
	INC	HL
	DJNZ	L_7A6F
	JR	L_7A26
;
L_7A78	AND	#3F
	ADD	A,#03
	LD	B,A
	LD	A,(HL)
L_7A7E	CALL	L_74A6
	DJNZ	L_7A7E
	INC	HL
	JR	L_7A26
;
L_7A86	EXX
	LD	HL,#2758
	EXX
	EI
	RET
;
       DB       #13,#D9,#77,#08,#28,#19,#24,#10       ;.Yw.(.$.
       DB       #1B,#11,#20,#F8,#19,#0D,#20,#12       ;.. x.. .
       DB       #11,#01,#FF,#19,#C6,#08,#30,#08       ;....F.0.
       DB       #11,#E0,#07,#19,#3D,#18,#01,#23       ;.`..=..#
       DB       #0E,#08,#06,#08,#08,#D9,#C9,#FE       ;.....YI~
       DB       #00,#86,#72,#72,#76,#7A,#72,#72       ;..rrvzrr
       DB       #F7,#00,#81,#3E,#C2,#70,#F7,#00       ;w..>Bpw.
       DB       #84,#7C,#72,#72,#7C,#78,#40,#DF       ;.|rr|x@_
       DB       #00,#8C,#01,#03,#05,#09,#11,#21       ;.......!
       DB       #45,#00,#3C,#72,#72,#7E,#78,#C0       ;E.<rr~x@
       DB       #D7,#00,#86,#01,#02,#04,#08,#10       ;W.......
       DB       #3F,#EF,#00,#08,#38,#8E,#11,#22       ;?o..8.."
       DB       #45,#8B,#17,#2F,#55,#AB,#05,#E3       ;E../U+.c
       DB       #25,#23,#25,#23,#00,#04,#83,#20       ;%#%#... 
       DB       #3F,#00,#C0,#4E,#83,#3E,#0E,#3C       ;?.@N.>.<
       DB       #DD,#00,#88,#40,#A0,#10,#28,#54       ;]..@ .(T
       DB       #BA,#7D,#FE,#C3,#FF,#C6,#FE,#84       ;:}~C.F~.
       DB       #00,#FF,#00,#7E,#C2,#4E,#E4,#00       ;...~BNd.
       DB       #89,#80,#40,#A0,#D0,#E8,#F4,#FA       ;..@ Phtz
       DB       #01,#FF,#C6,#80,#79,#40,#E1,#00       ;..F.y@a.
       DB       #8A,#80,#00,#00,#20,#30,#28,#24       ;.... 0($
       DB       #22,#21,#28,#79,#40,#EA,#00,#08       ;"!(y@j..
       DB       #80,#09,#C2,#F7,#00,#81,#3E,#79       ;..Bw..>y
       DB       #00,#EA,#00,#00,#40,#00,#43,#E5       ;.j..@.Ce
       DB       #00,#85,#3C,#70,#3C,#0E,#0E,#10       ;..<p<...
       DB       #AE,#02,#77,#C0,#72,#0A,#C0,#02       ;..w@r.@.
       DB       #7F,#81,#3E,#E5,#00,#81,#7F,#C1       ;..>e...A
       DB       #1C,#81,#7F,#1A,#F8,#18,#38,#10       ;....x.8.
       DB       #12,#81,#1C,#E5,#00,#08,#74,#1B       ;...e..t.
       DB       #6E,#81,#3E,#C2,#75,#23,#40,#78       ;n.>Bu#@x
       DB       #80,#D4,#00,#38,#2E,#2B,#38,#79       ;.T.8.+8y
       DB       #00,#D9,#00,#13,#AD,#10,#EE,#39       ;.Y..-.n9
       DB       #0A,#E9,#00,#3B,#6E,#28,#F8,#03       ;.i.;n(x.
       DB       #80,#82,#72,#72,#7B,#00,#D4,#00       ;..rr{.T.
       DB       #39,#40,#28,#38,#81,#1E,#C1,#2E       ;9@(8..A.
       DB       #82,#7E,#42,#E4,#00,#0C,#2E,#1C       ;.~Bd....
       DB       #AE,#29,#4A,#13,#FF,#7C,#C0,#E6       ;.)J..|@f
       DB       #00,#78,#C0,#D9,#00,#C0,#0E,#82       ;.x@Y.@..
       DB       #4E,#4E,#13,#EE,#28,#0A,#7B,#00       ;NN.n(.{.
       DB       #D9,#00,#39,#2E,#29,#38,#7D,#00       ;Y.9.)8}.
       DB       #D9,#00,#3C,#6E,#2C,#78,#7A,#C0       ;Y.<n,xz@
       DB       #D9,#00,#3B,#00,#2B,#0A,#83,#71       ;Y.;.+..q
       DB       #7B,#75,#C0,#71,#E5,#00,#3A,#EE       ;{u@qe.:n
       DB       #2A,#F8,#7B,#40,#D9,#00,#3B,#40       ;*x{@Y.;@
       DB       #2B,#4A,#79,#C0,#D9,#00,#3B,#2E       ;+Jy@Y.;.
       DB       #2B,#38,#7A,#00,#D9,#00,#2B,#F6       ;+8z.Y.+v
       DB       #3C,#00,#7A,#C0,#EB,#00,#82,#18       ;<.z@k...
       DB       #18,#08,#04,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#F1,#00,#2F,#18,#87,#57,#2F       ;.q./..W/
       DB       #17,#0B,#05,#02,#01,#ED,#00,#82       ;.....m..
       DB       #89,#15,#07,#18,#81,#75,#C5,#FF       ;.....uE.
       DB       #89,#FC,#7D,#BD,#5D,#2D,#15,#09       ;.|}=]-..
       DB       #05,#03,#78,#48,#D5,#00,#85,#FF       ;..xHU...
       DB       #00,#00,#AA,#54,#47,#50,#C6,#00       ;..*TGPF.
       DB       #84,#3F,#10,#08,#04,#78,#90,#CE       ;.?...x.N
       DB       #00,#88,#BF,#A0,#A0,#A2,#A5,#A3       ;..?  "%#
       DB       #A5,#A3,#08,#04,#86,#A5,#A0,#BF       ;%#...% ?
       DB       #00,#3F,#20,#27,#DC,#8A,#E3,#05       ;.? '\.c.
       DB       #AB,#55,#2F,#17,#8B,#45,#22,#11       ;+U/..E".
       DB       #78,#48,#78,#80,#37,#D0,#82,#FF       ;xHx.7P..
       DB       #00,#37,#DE,#27,#ED,#87,#7D,#BA       ;.7^'m.}:
       DB       #54,#28,#10,#A0,#40,#D4,#00,#00       ;T(. @T..
       DB       #80,#82,#A5,#AA,#C5,#AF,#00,#80       ;..%*E/..
       DB       #37,#DA,#88,#FF,#01,#FA,#F4,#E8       ;7Z...zth
       DB       #D0,#A0,#40,#07,#AC,#D8,#00,#86       ;P @.,X..
       DB       #24,#EA,#05,#0A,#57,#AB,#29,#40       ;$j..W+)@
       DB       #8C,#0F,#EF,#2F,#2E,#2D,#2A,#24       ;..o/.-*$
       DB       #28,#30,#20,#00,#00,#78,#38,#D1       ;(0 ..x8Q
       DB       #00,#8B,#40,#20,#10,#88,#44,#A2       ;..@ ..D"
       DB       #D1,#E8,#F4,#FA,#FD,#78,#6F,#E7       ;Qhtz}xog
       DB       #00,#81,#80,#78,#A7,#FF,#00,#E4       ;...x'..d
       DB       #00,#3B,#D4,#C1,#00,#3F,#E2,#7F       ;.;TA.?b.
       DB       #5A,#D3,#00,#07,#42,#05,#57,#C5       ;ZS..B.WE
       DB       #00,#3D,#90,#3E,#EC,#DB,#00,#58       ;.=.>l[.X
       DB       #28,#3F,#22,#7D,#DA,#D3,#00,#5E       ;(?"}ZS.^
       DB       #42,#3F,#E2,#7F,#A2,#D3,#00,#84       ;B?b."S..
       DB       #72,#72,#76,#7A,#3F,#02,#7E,#10       ;rrvz?.~.
       DB       #DD,#00,#C2,#75,#46,#42,#81,#3C       ;].BuFB.<
       DB       #27,#CE,#78,#80,#D3,#00,#82,#72       ;'Nx.S..r
       DB       #72,#58,#80,#2D,#A2,#7F,#9A,#E1       ;rX.-"..a
       DB       #00,#3E,#90,#3E,#2C,#DB,#00,#0F       ;.>.>,[..
       DB       #C2,#83,#7A,#3C,#08,#C4,#00,#3F       ;B.z<.D.?
       DB       #10,#17,#1A,#7F,#5A,#D2,#00,#83       ;....ZR..
       DB       #18,#18,#30,#C4,#00,#3E,#90,#3E       ;..0D.>.>
       DB       #EC,#DB,#00,#7A,#00,#7E,#D0,#DD       ;l[.z.~P]
       DB       #00,#38,#80,#C7,#00,#7F,#DA,#D3       ;.8.G..ZS
       DB       #00,#5E,#C2,#4A,#76,#29,#CA,#DF       ;.^BJv)J_
       DB       #00,#39,#00,#3F,#D0,#5A,#98,#D7       ;.9.?PZ.W
       DB       #00,#81,#7C,#52,#E8,#83,#5D,#5D       ;..|Rh.]]
       DB       #3E,#C0,#5D,#C1,#00,#17,#6C,#7A       ;>@]A..lz
       DB       #C0,#D2,#00,#49,#80,#2A,#CE,#07       ;@R.I.*N.
       DB       #97,#7F,#DA,#D0,#00,#81,#3E,#12       ;..ZP..>.
       DB       #C1,#C5,#00,#3A,#40,#7F,#DA,#E1       ;AE.:@.Za
       DB       #00,#3B,#F6,#81,#1E,#C1,#2E,#82       ;.;v..A..
       DB       #7E,#42,#FF,#00,#FF,#00,#FF,#00       ;~B......
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00       ;........
       DB       #FF,#00,#FF,#00,#D9,#00,#DD,#42       ;....Y.]B
       DB       #FF,#47,#FF,#47,#28,#84,#CF,#44       ;.G.G(.OD
       DB       #78,#20,#78,#20,#38,#C2,#CF,#45       ;x x 8BOE
       DB       #58,#DE,#CF,#46,#78,#20,#78,#20       ;X^OFx x 
       DB       #39,#22,#11,#4C,#CA,#43,#78,#20       ;9".LJCx 
       DB       #29,#70,#78,#20,#58,#20,#18,#48       ;)px X .H
       DB       #FF,#47,#FF,#47,#FF,#47,#FF,#47       ;.G.G.G.G
       DB       #FF,#47,#D5,#47,#80       ;.GUG.
;
L_7DFA
	halt;DI
	CALL	reter;#0052
	DEC	SP
	DEC	SP
	POP	BC
	LD	HL,#0097
	ADD	HL,BC
	EX	DE,HL
	LD	HL,#0066
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#007B
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#0089
	ADD	HL,BC
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	HL,#00BE
	ADD	HL,BC
	LD	DE,#4000
	PUSH	DE
	EXX
	EX	AF,AF' ;'
	LD	A,#03
	OR	A
	LD	B,#08
	LD	C,B
	POP	HL
	EX	AF,AF' ;'
	EXX
L_7E2E	LD	A,(HL)
	BIT	7,A
	JR	NZ,L_7E6D
	AND	#07
	LD	C,A
	LD	A,(HL)
	RRCA
	RRCA
	RRCA
	AND	#0F
	ADD	A,#03
	LD	B,A
	INC	HL
	LD	A,E
	SUB	(HL)
	INC	HL
	PUSH	HL
	LD	L,A
	LD	A,D
	SBC	A,C
	LD	H,A
L_7E48	PUSH	HL
	LD	A,H
	AND	#58
	CP	#58
	JR	Z,L_7E62
	LD	C,A
	LD	A,L
	AND	#07
	OR	C
	LD	C,A
	ADD	HL,HL
	ADD	HL,HL
	LD	A,H
	AND	#1F
	LD	H,A
	LD	A,L
	AND	#E0
	OR	H
	LD	L,A
	LD	H,C
L_7E62	LD	A,(HL)
	CALL	L_74A6
	POP	HL
	INC	HL
	DJNZ	L_7E48
	POP	HL
	JR	L_7E2E
;
L_7E6D	AND	#7F
	JR	Z,L_7E8E
	INC	HL
	BIT	6,A
	JR	NZ,L_7E80
	LD	B,A
L_7E77	LD	A,(HL)
	CALL	L_74A6
	INC	HL
	DJNZ	L_7E77
	JR	L_7E2E
;
L_7E80	AND	#3F
	ADD	A,#03
	LD	B,A
	LD	A,(HL)
L_7E86	CALL	L_74A6
	DJNZ	L_7E86
	INC	HL
	JR	L_7E2E
;
L_7E8E	EXX
	LD	HL,#2758
	EXX
	EI
	RET
;
       DB       #13,#D9,#77,#08,#28,#19,#24,#10       ;.Yw.(.$.
       DB       #1B,#11,#20,#F8,#19,#0D,#20,#12       ;.. x.. .
       DB       #11,#01,#FF,#19,#C6,#08,#30,#08       ;....F.0.
       DB       #11,#E0,#07,#19,#3D,#18,#01,#23       ;.`..=..#
       DB       #0E,#08,#06,#08,#08,#D9,#C9,#FF       ;.....YI.
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#DD       ;.......]
       DB       #00,#89,#FF,#80,#80,#95,#8A,#97       ;........
       DB       #8F,#97,#8F,#08,#04,#00,#08,#ED       ;.......m
       DB       #00,#85,#FE,#00,#00,#54,#AA,#C8       ;..~..T*H
       DB       #FE,#DC,#00,#28,#6F,#84,#8E,#96       ;~\.(o...
       DB       #8E,#96,#08,#04,#00,#08,#40,#7D       ;......@}
       DB       #00,#87,#DC,#00,#85,#FF,#00,#00       ;..\.....
       DB       #55,#AA,#C0,#FF,#82,#00,#00,#C0       ;U*@....@
       DB       #4E,#85,#3E,#0E,#3C,#00,#00,#08       ;N.>.<...
       DB       #0E,#82,#FF,#FF,#78,#80,#D3,#00       ;....x.S.
       DB       #38,#40,#86,#7C,#72,#72,#7C,#70       ;8@.|rr|p
       DB       #70,#28,#40,#82,#00,#00,#00,#0F       ;p(@.....
       DB       #C0,#72,#DD,#00,#38,#80,#81,#3C       ;@r].8..<
       DB       #C1,#72,#30,#80,#38,#10,#DB,#00       ;Ar0.8.[.
       DB       #48,#80,#08,#82,#38,#80,#81,#1E       ;H...8...
       DB       #C1,#2E,#82,#7E,#42,#DC,#00,#39       ;A..~B\.9
       DB       #00,#82,#3E,#70,#00,#BF,#81,#3E       ;..>p.?.>
       DB       #38,#C0,#E3,#00,#39,#40,#83,#72       ;8@c.9@.r
       DB       #72,#7E,#10,#F0,#78,#40,#D9,#00       ;r~.px@Y.
       DB       #39,#80,#82,#70,#70,#58,#C0,#E3       ;9..ppX@c
       DB       #00,#39,#C0,#2C,#A9,#78,#C0,#D9       ;.9@,)x@Y
       DB       #00,#78,#40,#79,#00,#D9,#00,#78       ;.x@y.Y.x
       DB       #80,#1A,#40,#84,#3F,#7F,#3F,#7F       ;..@.?.?.
       DB       #08,#04,#81,#3F,#DC,#00,#85,#FF       ;...?\...
       DB       #01,#01,#55,#A9,#C0,#FD,#84,#3D       ;..U)@}.=
       DB       #7D,#3D,#7D,#08,#04,#83,#3D,#7D       ;}=}...=}
       DB       #BD,#CB,#FD,#ED,#00,#81,#7F,#02       ;=K}m....
       DB       #D1,#81,#2A,#C8,#7F,#ED,#00,#28       ;Q.*H.m.(
       DB       #91,#78,#80,#FF,#00,#FF,#00,#FF       ;.x......
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#D5,#00,#57,#4D,#82,#97,#80       ;.U.WM...
       DB       #7E,#19,#DC,#00,#37,#CB,#1F,#17       ;~.\.7K..
       DB       #7E,#59,#DC,#00,#1F,#CE,#00,#78       ;~Y\..N.x
       DB       #78,#40,#E2,#00,#18,#79,#81,#00       ;x@b..y..
       DB       #78,#40,#E5,#00,#17,#D0,#81,#00       ;x@e..P..
       DB       #78,#80,#E5,#00,#78,#40,#EB,#00       ;x.e.x@k.
       DB       #78,#80,#EB,#00,#78,#C0,#EB,#00       ;x.k.x@k.
       DB       #79,#00,#EB,#00,#79,#40,#EB,#00       ;y.k.y@k.
;L_7FFE       EQU       $-7
       DB       #79,#80,#EB,#00,#79,#C0,#EA,#00       ;y.k.y@j.
       DB       #82,#7F,#BF,#7A,#40,#E9,#00,#1F       ;..?z@i..
       DB       #CE,#81,#01,#7A,#C0,#E4,#00,#37       ;N..z@d.7
       DB       #CB,#7B,#40,#E2,#00,#CB,#FD,#00       ;K{@b.K}.
       DB       #88,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF       ;........
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#DE       ;.......^
       DB       #00,#FF,#45,#E5,#45,#C9,#47,#D1       ;..EeEIGQ
       DB       #45,#78,#20,#60,#40,#C7,#46,#78       ;Ex `@GFx
       DB       #40,#78,#60,#78,#80,#30,#41,#78       ;@x`x.0Ax
       DB       #80,#78,#A0,#FF,#45,#FF,#45,#FF       ;.x .E.E.
       DB       #45,#FF,#45,#FF,#45,#FF,#45,#FF       ;E.E.E.E.
       DB       #45,#D7,#45,#80       ;EWE.

setpgsmain40008000
pgmain4000=$+1
        ld a,0
        SETPG16K
pgcode8000=$+1
        ld a,0
        SETPG32KLOW
        ret

setpgsscr40008000;_current
        call getuser_scr_low_cur
        SETPG16K
        call getuser_scr_high_cur
        SETPG32KLOW
        ret

        if 1==0
setpgsscr40008000
        call getuser_scr_low
        SETPG16K
        call getuser_scr_high
        SETPG32KLOW
        ret
        endif

getuser_scr_low
getuser_scr_low_patch=$+1
getuser_scr_low_patchN=0xff&(user_scr0_low^user_scr1_low)
        ld a,(user_scr1_low) ;ok
        ret

getuser_scr_high
getuser_scr_high_patch=$+1
getuser_scr_high_patchN=0xff&(user_scr0_high^user_scr1_high)
        ld a,(user_scr1_high) ;ok
        ret

getuser_scr_low_cur
getuser_scr_low_cur_patch=$+1
getuser_scr_low_cur_patchN=0xff&(user_scr0_low^user_scr1_low)
        ld a,(user_scr0_low) ;ok
        ret

getuser_scr_high_cur
getuser_scr_high_cur_patch=$+1
getuser_scr_high_cur_patchN=0xff&(user_scr0_high^user_scr1_high)
        ld a,(user_scr0_high) ;ok
        ret

changescrpg_current
        ld hl,getuser_scr_low_patch
        ld a,(hl)
        xor getuser_scr_low_patchN
        ld (hl),a
        ld hl,getuser_scr_high_patch
        ld a,(hl)
        xor getuser_scr_high_patchN
        ld (hl),a
        ld hl,getuser_scr_low_cur_patch
        ld a,(hl)
        xor getuser_scr_low_cur_patchN
        ld (hl),a
        ld hl,getuser_scr_high_cur_patch
        ld a,(hl)
        xor getuser_scr_high_cur_patchN
        ld (hl),a

        ld a,1
curscrnum=$+1
        xor 0
        ld ($-1),a
        ret
        
        if 1==0
changescrpg
        call changescrpg_current
        ld (curscrnum_int),a
        ret
        endif

primgega
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
        push bc
        call setpgsscr40008000
        call setpggfxc000
        pop bc
primgega0
        push bc
        ld hx,b
        push hl
        ld bc,40
primgegacolumn0
        ld a,(de)
        inc de
        ld (hl),a
        add hl,bc
        dec hx
        jr nz,primgegacolumn0
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,primgegacolumn0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
primgegacolumn0q
        pop bc
        dec c
        jr nz,primgega0
        call setpgcodec000
        jp setpgsmain40008000

clsega
        call setpgsscr40008000
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x7fff
        ld (hl),l;0
        ldir
        jp setpgsmain40008000

        if EGA
DrawTile_A_X2Y2DE
	sla	D
	sla	E
DrawTile_A_XYDE
	LD	H,a
	LD	L,0
        srl h
        rr l
	LD	bc,tilegfx
	ADD	HL,bc
        ex de,hl
;hl=xy
        ld a,h ;x
         add a,4
        ;ld l,l ;y
        ld h,0
        ld b,h
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
         add hl,hl
         add hl,hl
         add hl,hl
        add a,l
        ld l,a
        ld a,h
        adc a,0x40
        ld h,a
        ld bc,0x1008 ;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
        jp primgega
        endif

       if EGA
DrawSprite_Akeep_DExy
	LD	(cursprite),A
DrawSprite_A_DExy
;A=sprnum
;DE=xy
        push bc
        push de
        push iy
        add a,a
        ld l,a
        ld h,0xc0
        call setpggfxc000
        ld a,(hl)
        ld ly,a
        inc l
        ld a,(hl)
        ld hy,a
        call setpgsscr40008000
        ld c,e ;y
        ld a,d ;x
        srl a
        add a,sprmaxwid-1
        ld e,a
;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        call prspr
        pop iy
        call setpgcodec000
        call setpgsmain40008000
        pop de
        pop bc
        ret
       endif

        include "prspr.asm"

        if EGA
gettilebuf
       ds 128
        endif
       if EGA
GetTileToHL_DEXY
;hl=addr
;e=Y
;d=X
        push bc
        push de
        sla d
        sla d
        sla d
        sla e
        sla e
        sla e        
        ld bc,0x1008 ;b=hgt,c=wid (/2)
        jr GetBuf2CxB_DExy_ToHL
       if 1==0
       ld b,12*8
gettilefake0
       ld a,r
       ld (hl),a
       inc hl
       djnz gettilefake0
       pop de
       pop bc
       ret
       endif
GetBuf24x16_DExy
;e=y
;d=x
        push bc
        push de
        ld bc,0x100c ;b=hgt,c=wid (/2)
        ld hl,rebuf24x16
GetBuf2CxB_DExy_ToHL
        push hl ;gfx
        ld a,d ;x
        srl a
        srl a
        srl a
         add a,4
        ld l,e ;y
        ld h,0
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
        add a,l
        ld l,a
        ld a,h
        adc a,0x40
        ld h,a
        pop de ;gfx
;de=gfx
;hl=scr
        push bc
        call setpgsscr40008000
        pop bc
getimgega0
        push bc
        ld hx,b
        push hl
        ld bc,40
getimgegacolumn0
        ld a,(hl)
        ld (de),a
        inc de
        add hl,bc
        dec hx
        jr nz,getimgegacolumn0
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,getimgegacolumn0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
getimgegacolumn0q
        pop bc
        dec c
        jr nz,getimgega0
        call setpgsmain40008000
        pop de
        pop bc
        ret

ReBuf24x16_DExy
;e=y
;d=x (width 16 if multiple of 8)
        push bc
        push de
        ld bc,0x1008 ;b=hgt,c=wid (/2)
        ld a,d
        and 7
        jr z,$+4
         ld c,0x0c
        ld a,d ;x
        srl a
        srl a
        srl a
         add a,4
        ld l,e ;y
        ld h,0
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
        add a,l
        ld l,a
        ld a,h
        adc a,0x40
        ld h,a
        ld de,rebuf24x16
;de=gfx
;hl=scr
        call primgega
        pop de
        pop bc
        ret

buf24x16
        ds 12*16
buf24x16_2
        ds 12*16
gettilebuf2
        ds 8*16
rebuf24x16
        ds 12*16
       endif

       if EGA
DrawSprite16x16_HL_DExy
;hl=gfx
;e=y
;d=x (pixel perfect!)
        push bc
        push de
        ex de,hl
        ld b,0
        ld a,h ;x
        srl a
        ;ld l,l ;y
        ld c,l
        srl a ;x bit 0
        ;ld h,0x40/32/2
        ;jr nc,$+4 ;x bit 0
        ; ld h,0x80/32/2
         ld h,b;0
         rl h
         inc h ;0x40/32/2 или 0x80/32/2
        srl a ;x bit 1
         rl h
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40+scrbase
         if scrbase&0xff
         add a,scrbase&0xff
         endif
;a=x/4
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a ;hl=scr
;de=gfx
;hl=scr
        ld bc,0x1008 ;b=hgt,c=wid (/2)
        call primgega
        pop de
        pop bc
        ret
       endif

       if EGA
ClearTile_DExy
        ;ret
;E=y
;D=x (width 24 if not multiple of 8)
        push bc
        push de
        ld bc,0x1008 ;b=hgt,c=wid (/2)
        ld a,d ;x
        and 7
        jr z,$+4
         ld c,0x0c ;wid (/2)
        ld a,d
        srl a
        srl a
        srl a
         add a,4
        ld l,e ;y
        ld h,0
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
        add a,l
        ld l,a
        ld a,h
        adc a,0x40
        ld h,a
        ld de,zeros24x16
;de=gfx
;hl=scr
        call primgega
        pop de
        pop bc
        ret
zeros24x16
        ds 12*16
       endif

       if EGA 
GetCurTileTobuf24x16
	CALL	countcurtileaddr
	LD	H,(hl)
	LD	L,0
        srl h
        rr l
	LD	bc,tilegfx
	ADD	HL,bc       
	LD DE,buf24x16
        ld bc,8*16
        ldir
        ret
       endif

        if EGA
Clear2Bytes_ADyx
;A=y
;D=x
        push bc
        ld l,a ;y
        ld a,d ;x
        srl a
        srl a
        srl a
         add a,4
        ld h,0
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
        add a,l
        ld l,a
        ld a,h
        adc a,0x40
        ld h,a
        call setpgsscr40008000
        ld (hl),d;0
        set 5,h
        ld (hl),d;0
        set 7,h
        res 6,h
        ld (hl),d;0
        res 5,h
        ld (hl),d;0
        inc hl
        ld (hl),d;0
        set 5,h
        ld (hl),d;0
        res 7,h
        set 6,h
        ld (hl),d;0
        res 5,h
        ld (hl),d;0
        call setpgsmain40008000
        pop bc
        ret
        endif

        ds 0x3f00-$
        ds 0x4000-$
        incbin "slabage/sprdata.bin"
tilegfx=$+0x8000
        incbin "slabage/tiles.bin"
panelgfx=$+0x8000
        incbin "slabage/panel.bin"

        ds 0x8000-$
        include "SB.ASM"
end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	savebin "slabage.com",begin,end-begin
	LABELSLIST "../../../us/user.l"
