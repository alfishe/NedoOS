        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"  

STACK=0x4000;0x61a8
GAMESTACK=0x4000;0xFFFF
L_FDFD=0xfdfd
L_FE00=0xfe00

scrbase=0x4000+4
sprmaxwid=32
sprmaxhgt=32
scrwid=128;160 ;double pixels
scrhgt=176;192;200
INTSTACK=0x3f00
tempsp=0x3f06 ;6 bytes for prspr

;screenYtable=0x8b00

USEINT=1
EGA=1

        org PROGSTART
begin
        jp begin2 ;/prsprqwid (sprites in file are made so that they return here)
begin2
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,3+0x80 ;6912+[8noturbo]+keep
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
	ld de,res_path
	OS_CHDIR

        call setpgsscr40008000_buf
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x7fff
        ld (hl),l;0
        ldir

        call setpgsscr40008000
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x7fff
        ld (hl),l;0
        ldir

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

        ld e,3+0x80 ;6912+[noturbo]+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
        ld de,standardpal
        OS_SETPAL
        YIELD
        endif

        if 1==1
        ld a,(user_scr0_high) ;ok
        SETPG32KLOW
        ld hl,0x4000
        ld de,0x4000+0x4000
        ld bc,0x4000
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
        ld l,0
	LD	BC,#0000
showtiles0
	LD	A,l;(HL)
	INC	HL
	CALL	DrawTile
	INC	C
	INC	C
	LD	A,#20
	CP	C
	JR	NZ,showtiles0
	INC	B
	INC	B
	LD	A,#16
	CP	B
	JR	Z,$;CopyScreenToBufferScreen
	LD	DE,48;#000E
	ADD	HL,DE
	LD	C,#00
	JR	showtiles0
        endif

        if 1==0
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x1800
        ld (hl),-1;l;0
        ldir
        ld bc,0x2ff
        ld (hl),7
        ldir
        ld hl,0x4000
        ld de,0xc000
        ld bc,0x1800
        ldir

        ld a,24
        ld (spritehgt),a
        
        di
        xor a
        ld ix,therosprites
        call showspritespp
        ld a,32
        ld ix,talien1sprites
        call showspritespp
        ld a,64
        ld ix,talien2sprites
        call showspritespp
        ei
        endif

        YIELDGETKEYLOOP
        
        ;jr $
        jp GO

        if 1==0
showspritespp
        ld (spritey),a
        ld (ix+5),0 ;phase
        xor a
showsprites0
        push af
        ld (spriteX),a
        call L_6C53
        pop af
        inc (ix+5)
        add a,3
        cp 9*3
        jr nz,showsprites0
        ret
        endif

        include "pal.ast" ;pal
standardpal
        STANDARDPAL
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
WaitKeyCheckQuit
        call WaitKey
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
imer_addr=$+1
        call reter
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
        push ix
       push af
        ld d,c
        ld e,b
        call setpgsscr40008000
	;LD	DE,(curprintyx)
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
	LD	DE,Font-256;L_BE02
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
        if 1==0
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
        endif
        call setpgsmain40008000
        pop ix
        pop hl
        pop de
        pop bc
        ret
       
        if 1==0
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
	LD	DE,Font-256;L_BE02
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
        if 1==1
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
        endif
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
        endif

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

setpgsscr40008000_buf
        call getuser_scr_low
        SETPG16K
        call getuser_scr_high
        SETPG32KLOW
        ret

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

primgega_buf
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
        push bc
        call setpgsscr40008000_buf
        jr primgega_go

primgega
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
        push bc
        call setpgsscr40008000
primgega_go
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

copyimgega_curtodefault
;d=hgt,e=wid (/8)
;hl=scr
        call getuser_scr_low_cur
        SETPG16K ;set "from" page in 4000
        call getuser_scr_low
        SETPG32KHIGH ;set "to" page in c000
        call copyimgegalayer
        call getuser_scr_high_cur
        SETPG16K ;set "from" page in 4000
        call getuser_scr_high
copyimgegaq
        SETPG32KHIGH ;set "to" page in c000
        call copyimgegalayer
        call setpgcodec000
        jp setpgsmain40008000

copyimgega_defaulttocur
;d=hgt,e=wid (/8)
;hl=scr
        call getuser_scr_low
        SETPG16K ;set "from" page in 4000
        call getuser_scr_low_cur
        SETPG32KHIGH ;set "to" page in c000
        call copyimgegalayer
        call getuser_scr_high
        SETPG16K ;set "from" page in 4000
        call getuser_scr_high_cur
        jr copyimgegaq ;set "to" page in c000, copy

copyimgegalayer
        push hl
        ld hx,e ;wid/8
copyimgega0
        push de
        push hl
        ld b,d ;hgt
        ld de,40-0x8000
copyimgegacolumn0
        ld a,(hl)
        set 5,h
        ld c,(hl)
        set 7,h
        ld (hl),c
        res 5,h
        ld (hl),a
        add hl,de
        djnz copyimgegacolumn0
        pop hl
        pop de
        inc hl
        dec hx
        jr nz,copyimgega0
        pop hl
        ret

clsega
        call setpgsscr40008000
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x7fff
        ld (hl),l;0
        ldir
        jp setpgsmain40008000

        if EGA
RestoreSpriteEGA
        push ix
	;LD	A,(spritey)
        ld a,(ix+14) ;y2
        cp -16
        jr c,$+3
         xor a
        cp (scrhgt-16)/2
        jr c,$+4
         ld a,(scrhgt-16)/2
        ld l,a ;y
	;LD	A,(spriteX)
        ld a,(ix+13) ;X
         add a,4 ;x
         cp 40
         jr c,$+4
         ld a,40
        ld h,0
        ld b,h
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
         ;add hl,hl
         ;add hl,hl
         add hl,hl
        add a,l
        ld l,a
        ld a,h
        adc a,0x40
        ld h,a
        ld de,0x1003 ;hgt,wid/8
        call copyimgega_defaulttocur
        pop ix
        ret
        endif

        if EGA
DrawTileEGA
;a=tile
;bc=YX
        push bc
        push de
        push hl
        push ix
        ld e,b
        ld d,c
        call DrawTile_A_XYDE
        jr DrawTileEGA_go
DrawTileEGA_twoscr
;a=tile
;bc=YX
        push bc
        push de
        push hl
        push ix
        ld e,b
        ld d,c
        call DrawTile_A_XYDE
        push bc
        push de
        push hl
        call primgega_buf
        pop hl
        pop de
        pop bc
DrawTileEGA_go
        call primgega
        pop ix
        pop hl
        pop de
        pop bc
        ret
;DrawTile_A_X2Y2DE
	;sla	D
	;sla	E
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
        ret
        endif

       if EGA
DrawSpriteEGA
        push bc
        push de
        push hl
        push ix
        push iy
        
	LD	A,(IX+#05) ;phase
	INC	A
	LD	iy,#0000
	LD	BC,412;#0060 ;sprite size
L_6D43_	ADD	iy,BC
	DEC	A
	JR	NZ,L_6D43_
	LD	C,(IX+#0B) ;
	LD	B,(IX+#0C) ;sprites base
	ADD	iy,BC

	LD	A,(spriteX) ;x?
         ld (ix+13),a ;X
        add a,a
        add a,a
        ;add a,a
        ld d,a
	LD	A,(spritey) ;y
         ld (ix+14),a ;y2
        add a,a
        ;add a,8
        ld e,a

;DrawSprite_Akeep_DExy
	;LD	(cursprite),A
;DrawSprite_A_DExy
;A=sprnum
;DE=xy
        ;push bc
        ;push de
        ;push iy
        ;add a,a
        ;ld l,a
        ;ld h,0xc0
        ;call setpggfxc000
        ;ld a,(hl)
        ;ld ly,a
        ;inc l
        ;ld a,(hl)
        ;ld hy,a
        call setpgsscr40008000
        ld c,e ;y
        ld a,d ;x
        ;srl a
        add a,sprmaxwid-1
        ld e,a
;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        cp scrwid+sprmaxwid-1
        call c,prspr
        call setpgcodec000
        call setpgsmain40008000
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        ret
       endif

        include "prspr.asm"

       if 1==0;EGA
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
       endif

       if 1==0;EGA
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

       if 1==0;EGA
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

res_path
        db "montana2",0
bmpfilename
        db "montana2.bmp",0
        include "../../_sdk/file.asm"

        include "sprites.ast"
        include "tiles.ast"
        display "xxx=",$
killablescraddr
        ds 3
timer
        db 0

        ds 0x3f00-$
        ds 0x4000-$
        incbin "montana2.scr"

        if USEINT
        if EGA
        ds 0x8000-$
        else
        ds 0x6000-$
        endif
        else
        ds 0x6000-$;0x61C1+3-$
        endif
        include "MJ2.ASM"
end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	savebin "montana2.com",begin,end-begin
	LABELSLIST "../../../us/user.l"
