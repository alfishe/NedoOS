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

screenYtable=0x8b00

EGA=1

        org PROGSTART
begin
        jp begin2 ;/prsprqwid (sprites in file are made so that they return here)
begin2
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,0 ;EGA
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

	ld de,res_path
	OS_CHDIR

        call setpgsscr40008000

        ld de,emptypal
        OS_SETPAL
        ld de,bmpfilename
        call openstream_file
        call readbmphead_pal
        call readbmpscr
        call closestream_file
        ld de,pal
        OS_SETPAL
        
        call setpgsmain40008000

        ;ld b,50
        ;halt
        ;djnz $-1
        YIELDGETKEYLOOP

        ld e,3+8+0x80 ;6912+noturbo+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
        ld de,standardpal
        OS_SETPAL
        YIELD

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
        
        endif
        ;jr $
        jp GO

        ;include "pal.ast" ;slabpal
standardpal
        STANDARDPAL
pal
        ds 32,0xff
emptypal
        ds 32,0xff

jphl
        jp (hl)

CheckBreak
        ld a,0xfe
        in a,(0xfe)
        rra
        ret c
        ld a,0x7f
        in a,(0xfe)
        rra
        ret
CheckQuit
        call CheckBreak
        ret c
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
         ld a,lx
         ld (curkempston),a
         ;ld a,(user_scr0_high) ;ok
         ;SETPG16K ;TODO redraw screen when retake focus???
Imer_nofocus
	;LD	A,(stoptimer)
	;OR	A
	;CALL	Z,DecTimer
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
;DrawSprite_Akeep_DExy
	;LD	(cursprite),A
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

readbmphead_pal
        ld de,bgpush_bmpbuf
        ld hl,14+2;54+(4*16)
;de=buf
;hl=size
        call readstream_file
        ld de,bgpush_bmpbuf
        ld hl,(bgpush_bmpbuf+14)
        dec hl
        dec hl
;de=buf
;hl=size
        call readstream_file
        ld de,bgpush_bmpbuf
        ld hl,+(4*16)
;de=buf
;hl=size
        call readstream_file

        ld hl,bgpush_bmpbuf;+54
        ld ix,pal
        ld b,16
recodepal0
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ld l,(hl) ;e=B, d=G, l=R
        call readfile_rgbtopal
        pop hl
        inc hl
        inc hl
        djnz recodepal0
        ret

        macro RECOLOR
        ld a,(de)
        inc de
        ld ($+4),a
        ld a,(trecolor)
        ld (hl),a
        endm
readbmpscr
        ld hl,0x4000+(199*40)
        ld b,200
readbmpscr0
        push bc
        push hl
        ld de,bgpush_bmpbuf
        ld hl,320/2
;de=buf
;hl=size
        push de
        call readstream_file
        pop de
        pop hl
        push hl
        ld b,40
readbmpscr00        
        RECOLOR
        ld a,h
        add a,0x40
        ld h,a
        RECOLOR
        ld a,h
        add a,0x20-0x40
        ld h,a
        RECOLOR
        ld a,h
        add a,0x40
        ld h,a
        RECOLOR
        ld a,h
        sub 0x60
        ld h,a
        inc hl
        djnz readbmpscr00
        pop hl
        ld bc,-40
        add hl,bc
        pop bc
        djnz readbmpscr0
        ret

readfile_rgbtopal
;e=B, d=G, l=R
        call calcRGBtopal_pp
        ld (ix+1),a
        call calcRGBtopal_pp
        ld (ix),a
        inc ix
        inc ix
        ret

calcRGBtopal_pp
;e=B, d=G, l=R
;DDp palette: %grbG11RB(low),%grbG11RB(high), ??oN????N
        xor a
        rl e  ;B
        rra
        rl l  ;R
        rra
        rrca
        rrca
        rl d  ;G
        rra
        rl e  ;b
        rra
        rl l  ;r
        rra
        rl d  ;g
        rra
        cpl
        ret 

        align 256
trecolor
;%00003210 => %.3...210
        dup 256
_3=$&8
_210=$&7
_3L=($>>4)&8
_210L=($>>4)&7
        db (_3L*0x08) + (_210L*0x01) + (_3*0x10) + (_210*0x08)
        edup

bgpush_bmpbuf
        ds 320

res_path
        db "solkey",0
bmpfilename
        db "solkey.bmp",0
        include "../../_sdk/file.asm"

        ds 0x3f00-$
        ds 0x4000-$
        ;incbin "slabage/sprdata.bin"
tilegfx=$+0x8000
        ;incbin "slabage/tiles.bin"
panelgfx=$+0x8000
        ;incbin "slabage/panel.bin"

        ds 0x9300-$
        include "SOLKEY.asm"
end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	savebin "solkey.com",begin,end-begin
	LABELSLIST "../../../us/user.l"
