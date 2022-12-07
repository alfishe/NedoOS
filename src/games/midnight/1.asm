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
THESTACK=0x3d00
INTSTACK=0x3c00
tempsp=0x3c06 ;6 bytes for prspr
;UVSCROLL_SCRWID=320 ;8*(TILEMAPWID-2)
;UVSCROLL_SCRHGT=192 ;(делится на 16!!!) ;8*(TILEMAPHGT-2) ;чтобы выводить всегда 12 метатайлов (3 блока по 8) по высоте

CODE            EQU $7BE0

;*****************************************************************************
;** SPECTRUM MIDNIGHT RESISTANCE ALL IN ONE SOURCE                          **
;*****************************************************************************

                ;OCMD "#SP 7BE0"
                ;OCMD "K0"

;*****************************************************************************

MUSICALSO       EQU 0

                IF MUSICALSO=1
STARTLEV        EQU 0
                ENDIF

                IF MUSICALSO=0
STARTLEV        EQU 1
AUTO            EQU 1 ; ORIG = EQU 0
                ENDIF

                ;IF STARTLEV=1
		;org #4000
                ;insert "midnight.scr"
                ;ENDIF

                IF MUSICALSO=0

STARTLIVES      EQU 6-1

INFLIF          EQU 0             ;255
INFAMM          EQU 0             ;255
WEPSEL          EQU 0             ;255
SPACETOKILL     EQU 0             ;255

;*****************************************************************************
;** MEMORY MAP                                                              **
;*****************************************************************************

BACKSCR         EQU $5B00               ; REAL COPYS
BACKATR         EQU BACKSCR+($100*16)
BACKEND         EQU BACKATR+($20*16)
BACKLEN         EQU BACKEND-BACKSCR

BACKSCR2        EQU BACKEND             ; BACK SCREEN (COPY TO BACKSCR)
BACKATR2        EQU BACKSCR2+($D0*16)
BACKEND2        EQU BACKATR2+($1A*16)
BACKLEN2        EQU BACKEND2-BACKSCR2

MENUSTART       EQU $7000               ; MENU ROUTINES + CHEAT MODE ROUTINE
;THESTACK        EQU $7BE0
;CODE            EQU $7BE0

MIRPAGE         EQU $FD00               ; FD00 - FDFF
INTPAGE         EQU $FE00               ; FE00 - FF00
PAGE0           EQU $FF01               ; FF01 - FFF0
INTJP           EQU $FFF4               ; FFF4 - FFFF

MUSRESETSOUND   EQU $E000
MUSDOMUSIC      EQU $E003
MUSINITTUNE     EQU $E006

;***************************************
;** EQUATES                           **
;***************************************

;PRHEX8          EQU 5
;PRHEX16         EQU 6
PRKEY           EQU 7
PRCLS           EQU 12
PRFONT          EQU 14
PRMULTY         EQU 15
PRINK           EQU 16
PRSIZE          EQU 17
PRGAMECLS       EQU 18
PRPAUSE         EQU 19
PRINK2          EQU 20
PRAT            EQU 22
PREOF           EQU 255

KEYB            EQU 0
KEMP            EQU 1
FACE            EQU 2
CURS            EQU 3
CONT            EQU FACE

POKE            EQU $80                   ; POKE ADDRESS, VALUE (MAP DATA)

HIGHTUNE        EQU 9

;***************************************

NOBUL           EQU 32
BULX            EQU 0
BULY            EQU 1
BULP            EQU 2
BULT            EQU 3
BULLEN          EQU 4

NOEXP           EQU 8
EXPX            EQU 0
EXPY            EQU 1
EXPP            EQU 2
EXPLEN          EQU 3

NOFLAMES        EQU 10

NOBAD           EQU 12
XPOS            EQU 0
YPOS            EQU 1
TYPE            EQU 2
PHASE           EQU 3
ACTION          EQU 4
COUNT           EQU 5
TEMP            EQU 6
BADLEN          EQU 7

JUMPBIT         EQU 0
KEYBIT          EQU 1

JUMP            EQU 1
KEY             EQU 2

FIN             EQU 255

                ENDIF

;screenYtable=0x8b00

EGA=1
        ;slot 3
	;page 0
        org PROGSTART
begin
        jp begin2 ;/prsprqwid (sprites in file are made so that they return here)
begin2
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,0+0x80 ;EGA+keep
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
        ;OS_NEWPAGE
        ;ld a,e
        ld (tpgs+0),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+1),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+3),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+4),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+6),a
        OS_NEWPAGE
        ld a,e
        ld (tpgs+7),a

        OS_NEWPAGE
        ld a,e
        ld (pgmain4000),a

        if 1==1
	ld de,res_path
	OS_CHDIR

        call setpgsscr40008000

        ld de,emptypal
        OS_SETPAL
        ld de,filename0 ;имя файла
        ld hl,0x4000 ;куда грузим
        call loadfile_in_hl ;загрузили один экранный файл в одну страницу
        ld de,filename1 ;имя файла
        ld hl,0x8000 ;куда грузим
        call loadfile_in_hl ;загрузили другой экранный файл в другую страницу
        ld hl,0x4000+8000 ;там в картинке палитра (по байту на цвет)
        ld de,pal
        ld b,16
copypal0
        ld a,(hl)
        inc hl
        ld (de),a
        inc de
        ld (de),a
        inc de
        djnz copypal0 ;скопировали палитру в pal (по 2 байта на цвет)
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
        endif

	ld de,res_path
	OS_CHDIR
        ld de,muzfilename
        call openstream_file
        ld a,7
        call setpg
        ld de,music
        ld hl,music_sz
        call readstream_file
        call closestream_file
        
        ld hl,levelfilenames
loadlevels0
        ld a,(hl) ;pg
        inc hl
        cp -1
        jr z,loadlevels0q
        call setpg
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        push de ;addr
        ex de,hl
        call openstream_file
        pop de
        ld hl,0x2000
        call readstream_file
        call closestream_file
        pop hl
        xor a
        ld b,a
        ld c,a
        cpir ;hl=after #0
        jr loadlevels0
loadlevels0q

        if 1==1
        ld a,(user_scr0_high) ;ok
        SETPG16K
        ;ld a,(pggfx)
        ;SETPG32KLOW
        call setpggfxc000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir
        ;ld a,(user_scr0_high)
        ;SETPG16K
        ;ld a,(pgcode8000)
        ;SETPG32KLOW
        call setpgcodec000
        endif
        ;ld a,(user_scr0_high) ;ok
        ;SETPG16K
        
        call swapimer

        if EGA
        ld hl,prsprqwid
        ld (0x0101),hl ;sprites in file are made so that they return in 0x0100
        endif

        YIELDGETKEYLOOP
        
        xor a
        call setpg
        ;call CheatMenu
        jp START

setpg
        push bc
        and 7
         ;cp 2
         ;jr z,$
         ;cp 5
         ;jr z,$
        ;ld ($+4),a
        ;ld a,(tpgs)
         ld c,a
         ld b,tpgs/256
         ld a,(bc)
        SETPGC000
        pop bc
        ret

        align 256
tpgs
        ds 256

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
ReadKeysCheckQuit
        call CheckBreak
        jp c,READKEYS ;ret c
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
        im 1
        call killmuz ;because we played music not by OS
	QUIT

killmuz
        ld a,0xfe
        call shut1ay
        ld a,0xff
shut1ay
        ld bc,0xfffd
        out (c),a
        ld de,0x0e00
shutay0
        dec d
        ld b,0xff
        out (c),d
        ld b,0xbf
        out (c),e
        jr nz,shutay0
        ret

redattr_killable2b
        dw 0

;L_5B00 ;= #5b00
;        db 0

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
         ld a,(curpg16k) ;ok
         push af
         ld a,(curpg32klow) ;ok
         push af
         call setpgsmain40008000
	;DI
;curscrnum_int=$+1
;        ld e,0
;        OS_SETSCREEN
        call INTS
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
         pop af
         SETPG32KLOW
         pop af
         SETPG16K
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

copypage
;hl=from
;de=to
;bc=size
;hx=frompg
;lx=topg
        push bc
        ld a,hx ;frompg
        and 7
        ld ($+4),a
        ld a,(tpgs)
        SETPG16K
        ld a,lx ;to
        and 7
        ld ($+4),a
        ld a,(tpgs)
        SETPG32KLOW
        pop bc
        res 7,h
        res 6,d
        ldir
        jp setpgsmain40008000

setpgsmain40008000
pgmain4000=$+1
        ld a,0
        ld a,(user_scr0_high) ;ok
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

        if 1==0;EGA
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

;------------------
; Keyboard scanning
;------------------
; from keyboard and s-inkey$
; returns 1 or 2 keys in DE, most significant shift first if any
; key values 0-39 else 255

;; KEY-SCAN
L028E   LD      L,$2F           ; initial key value
                                ; valid values are obtained by subtracting
                                ; eight five times.
        LD      DE,$FFFF        ; a buffer for 2 keys.

        LD      BC,$FEFE        ; the commencing port address
                                ; B holds 11111110 initially and is also
                                ; used to count the 8 half-rows
;; KEY-LINE
L0296   IN      A,(C)           ; read the port to A - bits will be reset
                                ; if a key is pressed else set.
        CPL                     ; complement - pressed key-bits are now set
        AND     $1F             ; apply 00011111 mask to pick up the
                                ; relevant set bits.

        JR      Z,L02AB         ; forward to KEY-DONE if zero and therefore
                                ; no keys pressed in row at all.

        LD      H,A             ; transfer row bits to H
        LD      A,L             ; load the initial key value to A

;; KEY-3KEYS
L029F   INC     D               ; now test the key buffer
        RET     NZ              ; if we have collected 2 keys already
                                ; then too many so quit.

;; KEY-BITS
L02A1   SUB     $08             ; subtract 8 from the key value
                                ; cycling through key values (top = $27)
                                ; e.g. 2F>   27>1F>17>0F>07
                                ;      2E>   26>1E>16>0E>06
        SRL     H               ; shift key bits right into carry.
        JR      NC,L02A1        ; back to KEY-BITS if not pressed
                                ; but if pressed we have a value (0-39d)

        LD      D,E             ; transfer a possible previous key to D
        LD      E,A             ; transfer the new key to E
        JR      NZ,L029F        ; back to KEY-3KEYS if there were more
                                ; set bits - H was not yet zero.

;; KEY-DONE
L02AB   DEC     L               ; cycles 2F>2E>2D>2C>2B>2A>29>28 for
                                ; each half-row.
        RLC     B               ; form next port address e.g. FEFE > FDFE
        JR      C,L0296         ; back to KEY-LINE if still more rows to do.

        LD      A,D             ; now test if D is still FF ?
        INC     A               ; if it is zero we have at most 1 key
                                ; range now $01-$28  (1-40d)
        RET     Z               ; return if one key or no key.

        CP      $28             ; is it capsshift (was $27) ?
        RET     Z               ; return if so.

        CP      $19             ; is it symbol shift (was $18) ?
        RET     Z               ; return also

        LD      A,E             ; now test E
        LD      E,D             ; but first switch
        LD      D,A             ; the two keys.
        CP      $18             ; is it symbol shift ?
        RET                     ; return (with zero set if it was).
                                ; but with symbol shift now in D

loadfile_in_hl
;de=имя файла
;hl=куда грузим (0xc000)
        ;SETPG32KHIGH ;включили страницу A в 0xc000
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld hl,0x4000 ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	ret;jp setpgmainc000 ;включили страницу программы в c000, как было


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
        db "midnight",0
filename0
        db "0midnigh.bmx",0
filename1
        db "1midnigh.bmx",0

;bmpfilename
        ;db "solkey.bmp",0
muzfilename
        db "music.o",0
levelfilenames
        db 1
        dw 0xc000
        db "level2.o",0
        db 1
        dw 0xe000
        db "level1.o",0
        db 3
        dw 0xc000
        db "level3.o",0
        db 3
        dw 0xe000
        db "level4.o",0
        db 4
        dw 0xc000
        db "level5.o",0
        db 4
        dw 0xe000
        db "level6.o",0
        db 6
        dw 0xc000
        db "level7.o",0
        db 6
        dw 0xe000
        db "level8.o",0
        db 7
        dw 0xc000
        db "level9.o",0
        db -1

        include "../../_sdk/file.asm"

        ds 0x3d00-$
        incbin "font88"
        ds 0x4000-$
        incbin "midnight.scr"
        ;incbin "slabage/sprdata.bin"
;tilegfx=$+0x8000
        ;incbin "slabage/tiles.bin"
;panelgfx=$+0x8000
        ;incbin "slabage/panel.bin"

        ds MENUSTART-$
	include "Mirror.a80"

        ds CODE-$;0x5b00-$
        include "Game.a80"

	org LEVELDATA
        ;ds LEVELDATA-$
level1
	include "Level_01.a80"
level1_sz=$-level1
	include "Page1_FF00.a80"

        ds MIRPAGE-$
;****************************************************************************
;** MIRROR PAGE                                                            **
;****************************************************************************

                IF MUSICALSO=0

                ;ORG MIRPAGE

                DB #00,#80,#40,#C0,#20,#A0,#60,#E0,#10,#90,#50,#D0,#30,#B0,#70,#F0
                DB #08,#88,#48,#C8,#28,#A8,#68,#E8,#18,#98,#58,#D8,#38,#B8,#78,#F8
                DB #04,#84,#44,#C4,#24,#A4,#64,#E4,#14,#94,#54,#D4,#34,#B4,#74,#F4
                DB #0C,#8C,#4C,#CC,#2C,#AC,#6C,#EC,#1C,#9C,#5C,#DC,#3C,#BC,#7C,#FC
                DB #02,#82,#42,#C2,#22,#A2,#62,#E2,#12,#92,#52,#D2,#32,#B2,#72,#F2
                DB #0A,#8A,#4A,#CA,#2A,#AA,#6A,#EA,#1A,#9A,#5A,#DA,#3A,#BA,#7A,#FA
                DB #06,#86,#46,#C6,#26,#A6,#66,#E6,#16,#96,#56,#D6,#36,#B6,#76,#F6
                DB #0E,#8E,#4E,#CE,#2E,#AE,#6E,#EE,#1E,#9E,#5E,#DE,#3E,#BE,#7E,#FE
                DB #01,#81,#41,#C1,#21,#A1,#61,#E1,#11,#91,#51,#D1,#31,#B1,#71,#F1
                DB #09,#89,#49,#C9,#29,#A9,#69,#E9,#19,#99,#59,#D9,#39,#B9,#79,#F9
                DB #05,#85,#45,#C5,#25,#A5,#65,#E5,#15,#95,#55,#D5,#35,#B5,#75,#F5
                DB #0D,#8D,#4D,#CD,#2D,#AD,#6D,#ED,#1D,#9D,#5D,#DD,#3D,#BD,#7D,#FD
                DB #03,#83,#43,#C3,#23,#A3,#63,#E3,#13,#93,#53,#D3,#33,#B3,#73,#F3
                DB #0B,#8B,#4B,#CB,#2B,#AB,#6B,#EB,#1B,#9B,#5B,#DB,#3B,#BB,#7B,#FB
                DB #07,#87,#47,#C7,#27,#A7,#67,#E7,#17,#97,#57,#D7,#37,#B7,#77,#F7
                DB #0F,#8F,#4F,#CF,#2F,#AF,#6F,#EF,#1F,#9F,#5F,#DF,#3F,#BF,#7F,#FF
                
                ENDIF

;***************************************
;** PAGE 0 DATA                       **
;***************************************

                ;ORG PAGE0
                ds PAGE0-$

YBOUNCE         DB #FF,#00,#01,#00

INFLIVES        DB INFLIF
INFAMMO         DB INFAMM
WEPSELECT       DB WEPSEL
SPACEBARCHEAT   DB SPACETOKILL

SCORETEXT       DB PRAT,21,20,PRSIZE
                INC D:NOP
                DB PRINK,$45,PRINK2,$47
SCORE           DB "00000000",PRSIZE,0,PREOF

PD              EQU 8
XADDS           DB 0+00,0+PD,0+PD,0+PD,0+00,0-PD,0-PD,0-PD
YADDS           DB 0-PD,0-PD,0+00,0+PD,0+PD,0+PD,0+00,0-PD

V               EQU 4
W               EQU V*2
XADS            DB 00,+V,+W,+W,+W,+W,+W,+V,00,-V,-W,-W,-W,-W,-W,-V
YADS            DB -W,-W,-W,-V,00,+V,+W,+W,+W,+W,+W,+V,00,-V,-W,-W

JADDS           DB #00,#08,#00,#00,#00,#00,#00,#00
                DB #F8,#00,#08,#00,#08,#00,#08,#00

DAMAGETAB       DB 01,01,03,02,00,06,03,03
                DB 01,02,06,04,00,06,03,03
                DB 02,01

NORET           EQU 0
LOSELIFE        EQU 1
NXTLEV          EQU 2
;BREAK           EQU 3

RETMODE         DB NORET

RETMODES        DW GAMEOVER
                DW NEXTLEVEL
;                DW TESTLOADLEV1

BADDAT          DS NOBAD*BADLEN,0

FLAMEDIR        DS NOFLAMES,2
FLAMEXYS        DS NOFLAMES*2,0

PAGEEND

end
	;page 0
	savebin "midnight.com",begin,end-begin
	savebin "midnight/level1.o",level1,level1_sz

        slot 3
	page 1
	org #C000
level2
	include "Level_02.a80"
level2_sz=$-level2
	;org #E000
	;include "Level_01.a80"

	page 3
	org #C000
level3
	include "Level_03.a80"
level3_sz=$-level3
	org #E000
level4
	include "Level_04.a80"
level4_sz=$-level4

	page 4
	org #C000
level5
	include "Level_05.a80"
level5_sz=$-level5
	org #E000
level6
	include "Level_06.a80"
level6_sz=$-level6

	page 6
	org #C000
level7
	include "Level_07.a80"
level7_sz=$-level7
	org #E000
level8
	include "Level_08.a80"
level8_sz=$-level8

	page 7
	org #C000
level9
	include "Level_09.a80"
level9_sz=$-level9
	org #E000
music
	include "Music.a80"
music_sz=$-music

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	page 1
	savebin "midnight/level2.o",level2,level2_sz
	page 3
	savebin "midnight/level3.o",level3,level3_sz
	savebin "midnight/level4.o",level4,level4_sz
	page 4
	savebin "midnight/level5.o",level5,level5_sz
	savebin "midnight/level6.o",level6,level6_sz
	page 6
	savebin "midnight/level7.o",level7,level7_sz
	savebin "midnight/level8.o",level8,level8_sz
	page 7
	savebin "midnight/level9.o",level9,level9_sz
	savebin "midnight/music.o",music,music_sz
	LABELSLIST "../../../us/user.l"
