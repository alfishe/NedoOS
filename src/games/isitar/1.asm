        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm" 
;0x0100..0x3eff - subroutines
;0x3f00..0x3fff - stack
;0x4000..0x7fff - VRAM
;0x8000..0xbfff - game/paged for screen
;0xc000..0xffff - scratchpad RAM/paged for screen

INTSTACK=0x0100;0x3f00 
VDPSTACK=INTSTACK-64
STACK=0x4000;=INTSTACK-64

SPRITESON=1;0

        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,0+128 ;EGA +keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

	ld e,0
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ld a,e
        ld (pgcode4000),a
        ld a,h
        ld (pgcode8000),a
        ld a,l
        ld (pgcodec000),a

        OS_NEWPAGE
        ld a,e
        ld (pgtiles),a

        ld de,pal
        OS_SETPAL

        call swapimer

        jp GO

pal
;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
                   ;bg=1  ;зел  ;салат  ;син  ;небо  ;крас  ;ярко-голуб
        dw 0xffff,0xfefe,0xcfcf,0x4f4f,0xdede,0xcccc,0xfdfd,0xcece
        dw 0xbdbd,0xacac,0x2d2d,0x2c2c,0xefef,0x4e4e,0xecec,0x0c0c
           ;флаг  ;роз   ;древко ;лим  ;тзел  ;???    ;road
;oldtimer
;        dw 0
quiter
        halt
        ;ld a,(pgmuznum)
        ;SETPG32KHIGH
        ;call muz
        call shutay
        call swapimer
	QUIT


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

on_int
;restore stack with de
	ld (on_int_hl),hl
	ld (on_int_sp),sp
	pop hl
	ld (on_int_sp2),sp
	ld (on_int_jp),hl
	
	ld sp,INTSTACK
	
	push af
	push bc
	push de
	
;imer_curscreen_value=$+1
         ;ld a,0
         ;ld bc,0x7ffd
         ;out (c),a

	ex de,hl;ld hl,0
on_int_sp=$+1
	ld (0),hl ;восстановили запоротый стек
        
        push ix
        push iy
        ex af,af' ;'
        exx
        push af
        push bc
        push de
        push hl
;curpalette=$+1
        ;ld de,wolfpal
        ;OS_SETPAL

curscrnum_int=$+1
        ld e,0
        OS_SETSCREEN
        
;pgmuznum=$+1
;        ld a,0
;        SETPG32KHIGH
        
         call oldimer
        
        GET_KEY
        ld (curkey),a

        ld a,(curpg32klow) ;ok
        push af
        ld a,(curpg32khigh) ;ok
        push af
        call setpgcode8000c000
        call MUZHOOK ;muzplay
        pop af
        SETPG32KHIGH
        pop af
        SETPG32KLOW
;pgc000=$+1
;        ld a,0
;        SETPG32KHIGH
        
        pop hl
        pop de
        pop bc
        pop af
        exx
        ex af,af' ;'
        pop iy
        pop ix
        
	;ld hl,(timer)
	;inc hl
	;ld (timer),hl

	pop de
	pop bc
	pop af
	
on_int_hl=$+1
	ld hl,0
on_int_sp2=$+1
	ld sp,0
        ei
on_int_jp=$+1
	jp 0

setpgtiles4000
pgtiles=$+1
        ld a,0
        SETPG16K
        ret

setpgtiles8000
        ld a,(pgtiles)
        SETPG32KLOW
        ret

setpgcode4000
pgcode4000=$+1
        ld a,0
        SETPG16K
        ret

setpgcode8000c000
pgcode8000=$+1
        ld a,0
        SETPG32KLOW
pgcodec000=$+1
        ld a,0
        SETPG32KHIGH
        ret
 
MUZHOOK;#FD9F ;$FD9F is one of the interrupt service routine hooks (HTIMI) and it's called every 50/60 times per second by the BIOS.
        ret
        ret
        ret

gentiles
        ;jr $
        pop hl
        ld (gentilesjp),hl
        ld (gentilessp),sp
        ld sp,VDPSTACK
        ;call setpgtiles4000

        ld hl,wasfont
        ld de,0x4100
        ld bc,8*('Z'+1-' ')
        ldir

        ld l,0
gentiles0
        ld h,0x20
        ld d,0x40/8
        ld a,l
        add a,a
        rl d
        add a,a
        rl d
        add a,a
        rl d
        ld e,a
        dup 8
        ld a,(de)
         ld (hl),-1;0
         rla
         rr (hl)
         rla
         rr (hl)
        set 3,h
         ld (hl),-1;0
         rla
         rr (hl)
         rla
         rr (hl)
        res 3,h
        set 4,h
         ld (hl),-1;0
         rla
         rr (hl)
         rla
         rr (hl)
        set 3,h
         ld (hl),-1;0
         rla
         rr (hl)
         rla
         rr (hl)        
        res 3,h
        res 4,h
        inc e
        inc h
        edup
        
        ld h,0x20
gentiles0atr0
        ld d,0x60/8
        ld a,l
        add a,a
        rl d
        add a,a
        rl d
        add a,a
        rl d
        xor h
        and 0xf8
        xor h
        ld e,a
        ld a,(de) ;IiiiPppp
        rra
        rra
        rra
        rra
        call geninkbyte
        ld c,a
        ld a,(de)
        call geninkbyte
        ld b,a
        ;ld bc,0b0000000011111111
;c=ink (IIiiiiii)
;b=paper (PPpppppp)
        ld a,(hl)
        rla
        sbc a,a
        ld e,a ;RRRRRRRR
        ld a,(hl)
        rla
        rla
        sbc a,a ;LLLLLLLL
        xor e
        and 0b01000111
        xor e
        ld d,a
;a=%RLRRRLLL        
        and c ;ink (IIiiiiii)
        ld e,a
        ld a,d
        cpl
        and b ;paper (PPpppppp)
        or e
        ld (hl),a
        inc h
        bit 6,h
        jr z,gentiles0atr0
        
        inc l
        jp nz,gentiles0

        ;call setpgcode4000
;gen sprites
;The Sprite Pattern Table occupies 2 KB of VRAM from 3800H to 3FFFH. It contains two hundred and fifty-six 8x8 pixel patterns, numbered from 0 to 255.
;AC
;BD
;8 bytes block A
;8 bytes block B
;8 bytes block C
;8 bytes block D
;pattern 0..3 = pattern 0, pattern 4..7 = pattern 1...
;(decoded to 128 bytes per pattern in pgtiles)
        call setpgtiles8000

        ld hl,0x4000+0x3800;0x1800
        ld de,0x8000

        ld b,2*64 ;halfsprites
genspr0
        push bc
        ld c,4
genspr0subcolumns
        push hl
        ld b,16
genspr00
        xor a ;ld a,0xff
        rlc (hl)
        jr nc,$+4
        xor 0b01000111 ;don't keep left pixel
        rlc (hl)
        jr nc,$+4
        xor 0b10111000 ;don't keep right pixel
        ld (de),a
        inc hl
        inc de
        djnz genspr00
        pop hl
        dec c
        jr nz,genspr0subcolumns
        ld bc,16
        add hl,bc ;next column (halfsprite)
        pop bc
        djnz genspr0
        
        call setpgcode8000c000
gentilessp=$+1
        ld sp,0
gentilesjp=$+1
        jp 0

geninkbyte
;a=????Iiii
;out: a=IIiiiiii
        ld b,a
        rla
        rla
        rla
        xor b
        and 0b01111000
        xor b ;?Iiiiiii
        rla   ;Iiiiiii?
        rlca  ;iiiiii?I
        rra   ;Iiiiiii? (CY=I)
        rra
        ret

        MACRO SPRCOLUMN
       dup 15
        ld a,(de)
        xor (hl) ;and (hl)
        ld (hl),a;0xaa
        inc e
        add hl,bc ;40
       edup
        ld a,(de)
        xor (hl) ;and (hl)
        ld (hl),a;0xaa
        inc e
        endm

	macro NEXTCOLUMN
	bit 6,h
	set 6,h
	jr z,$+2+4+2+2+1
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,$+3
	inc hl
	endm

;The Name Table occupies 768 bytes of VRAM from 1800H to 1AFFH (!!!3800!!!), the same as in 32x24 Text Mode. The table is initialized with the character code sequence 0 to 255 repeated three times and is then left untouched, in this mode it is the Character Pattern Table which is modified during normal operation.

;The Character Pattern Table occupies 6 KB of VRAM from 0000H to 17FFH. While its structure is the same as in the text modes it does not contain a character set but is initialized to all 0 pixels. The first 2 KB of the Character Pattern Table is addressed by the character codes from the first third of the Name Table, the second 2 KB by the central third of the Name Table and the last 2 KB by the final third of the Name Table. Because of the sequential pattern in the Name Table the entire Character Pattern Table is read out linearly during a video frame.

emulVDP
        pop hl
        ld (emulVDPjp),hl
        ld (emulVDPsp),sp
        ld sp,VDPSTACK

        push bc
        push de
        push hl
curkey=$+1
        ld a,0
        cp key_esc
        jp z,quiter
        ;ld a,(user_scr0_low) ;ok
        ;SETPG32KLOW
        ;ld a,(user_scr0_high) ;ok
        ;SETPG32KHIGH
        call setpgsscr8000c000
;TODO draw only changed tiles
        ld de,0x4000+0x1800 ;tilemap
        ld hl,0x8000+4 ;screen
        ;ld hx,0x40 ;tile gfx base
        ld b,24
emulVDPtiles0
        push bc
        ld a,24
        sub b
        rra
        rra
        rra
        and 3
        add a,0x40/8
        ld hx,a ;tile gfx base
        push hl
        ld b,32
emulVDPtiles1
        ld a,(de) ;tile
        push bc
        push de
        push hl
        
        ld bc,40
        
        ld e,a
        
        push hl
        
        ld d,0x20
        push hl
        dup 7
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
        edup
        ld a,(de)
        ld (hl),a
        pop hl
        
        set 6,h
        
        ld d,0x28
        dup 7
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
        edup
        ld a,(de)
        ld (hl),a
        
        pop hl
        set 5,h
        
        ld d,0x30
        push hl
        dup 7
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
        edup
        ld a,(de)
        ld (hl),a
        pop hl
        
        set 6,h
        
        ld d,0x38
        dup 7
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
        edup
        ld a,(de)
        ld (hl),a
        
        pop hl
        pop de
        pop bc
        inc de
        inc hl
        dec b
        jp nz,emulVDPtiles1
        pop hl
        ld bc,40*8
        add hl,bc
        pop bc
        dec b
        jp nz,emulVDPtiles0
        
        if SPRITESON
;The Sprite Attribute Table occupies 128 bytes of VRAM from 1B00H to 1B7FH /3b00/. The table contains thirty-two four byte blocks, one for each sprite. The first block controls sprite 0 (the "top" sprite), the ;second controls sprite 1 and so on to sprite 31. The format of each block is as below:

;   Vertical Position	Byte 0
;   Horizontal Position	Byte 1
;   Pattern Number	Byte 2
;   EC 	0	0	0 	Colour Code(bits 3..0)	Byte 3
;In Byte 3, the Early Clock bit is normally 0 but will shift the sprite thirty-two pixels to the left when set to 1. This is so that sprites can slide in from the left of the screen, there being no spare coordinates in the horizontal direction.    

;The Sprite Pattern Table occupies 2 KB of VRAM from 3800H to 3FFFH /1800/. It contains two hundred and fifty-six 8x8 pixel patterns, numbered from 0 to 255.
;AC
;BD
;8 bytes block A
;8 bytes block B
;8 bytes block C
;8 bytes block D
;for 16x16 sprites: pattern 0..3 = pattern 0, pattern 4..7 = pattern 1...
        ld hl,0x4000+0x3B7F
emulVDPsprites0
        ld a,(hl) ;d3..0=colour code, d7=early clock (x-=32)
        dec l
        ld d,(hl) ;pattern number
        dec l
        ld c,(hl) ;x
        dec l
        ld b,(hl) ;y
        or a
        jp z,emulVDPsprites0_skip ;colour 0
          inc b
        ld a,b
        cp 0xd1+1 ;???
        jp nc,emulVDPsprites0_skip
         srl c
         srl c
         srl c
         ld a,c
         add a,4
         ld c,a
         ;srl b
         ;srl b
         ;srl b
         ld a,b
         cp 24 *8
         jp nc,emulVDPsprites0_skip
        push hl
;bc=yx
        ld a,c ;x
        ld l,b ;y
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
         ;add hl,hl
        add a,l
        ld l,a
        ld a,h
        adc a,0x80
        ld h,a

        call setpgtiles4000

        ld bc,40
;d=pattern number
        ld e,0
         srl d
         srl d ;pattern 0..3 = pattern 0, pattern 4..7 = pattern 1...
        srl d
        rr e
        set 6,d ;ld d,0x40;+0x38 ;sprites
        dup 8-1
        push hl
        SPRCOLUMN
        pop hl
        NEXTCOLUMN
        edup
        SPRCOLUMN
        
        call setpgcode4000
        
        pop hl
emulVDPsprites0_skip
        dec l
        jp p,emulVDPsprites0
        
        endif

        call changescrpg
        
        call setpgcode8000c000
        pop hl
        pop de
        pop bc
        
emulVDPsp=$+1
        ld sp,0
emulVDPjp=$+1
        jp 0
 
pause
        push af
        push bc
        push de
        push hl
        exx
        ex af,af' ;'
        push af
        push bc
        push de
        push hl
        push ix
        push iy
        YIELD
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af' ;'
        exx
        pop hl
        pop de
        pop bc
        pop af
        ret

        if 1==0
muztest
        ei
        halt
        call L_9266 ;music player
        jr muztest
        endif

gentilemap
        ld hl,0x5800
        ld (hl),l
        inc l
        jr nz,$-2
        inc h
        ld (hl),l
        inc l
        jr nz,$-2
        inc h
        ld (hl),l
        inc l
        jr nz,$-2
        ret

L0020
;DCOMPR
;Address  : #0020
;Function : Compares HL with DE
;Input    : HL, DE
;Output   : Z-flag set if HL and DE are equal. C-flag set if HL is less than DE.
;Registers: AF
        push hl
        or a
        sbc hl,de
        pop hl
        ret

L003D
;???
;INIFNK
;Address  : #003E
;Function : Initialises the contents of the function keys
;Registers: All
        ret

L0041
;DISSCR
;Address  : #0041
;Function : inhibits the screen display
;Registers: AF, BC
        ret

L0044
;ENASCR
;Address  : #0044
;Function : displays the screen
;Registers: AF, BC
        ret

L0047        
;WRTVDP
;Address  : #0047
;Function : write data in the VDP-register
;Input    : B  - data to write
;           C  - number of the register
;Registers: AF, BC
;can spoil bc
;TODO
        ret

L004A
;RDVRM
;Address  : #004A
;Function : Reads the content of VRAM
;Input    : HL - address read
;Output   : A  - value which was read
;Registers: AF
        push hl
        set 6,h
        ld a,(hl)
        pop hl
        ret

L004D
;WRTVRM
;Address  : #004D
;Function : Writes data in VRAM
;Input    : HL - address write (0..3fff)
;           A  - value write
;Registers: AF
        push hl
        set 6,h
        ld (hl),a
        pop hl
        ret
        
L0056
;FILVRM
;Address  : #0056
;Function : fill VRAM with value
;Input    : A  - data byte
;           BC - length of the area to be written
;           HL - start address
;Registers: AF, BC
        push bc
        push hl
        set 6,h
FILVRM0
        ld (hl),a
        cpi
        jp pe,FILVRM0
        pop hl
        pop bc ;unneeded?
        ret

L0059
;LDIRMV
;Address  : #0059
;Function : Block transfer to memory from VRAM
;Input    : BC - blocklength
;           DE - Start address of memory
;           HL - Start address of VRAM
;Registers: All
        push bc
        push de
        push hl
        set 6,h
        ldir
        pop hl
        pop de
        pop bc ;unneeded?
        ret

L005C        
;LDIRVM
;Address  : #005C
;Function : Block transfer to VRAM from memory
;Input    : BC - blocklength
;           DE - Start address of VRAM
;           HL - Start address of memory
;Registers: All
        push bc
        push de
        push hl
        set 6,d
        ldir
        pop hl
        pop de
        pop bc ;unneeded?
        ret

L005F
;CHGMOD
;Address  : #005F
;Function : Switches to given screenmode
;Input    : A  - screen mode
;Registers: All
        ret

L0062
;CHGCLR
;Address  : #0062
;Function : Changes the screencolors
;Input    : Foregroundcolor in FORCLR
;           Backgroundcolor in BAKCLR
;           Bordercolor in BDRCLR
;Registers: All
        ret ;TODO
     
L0090
;GICINI
;Address  : #0090
;Function : Initialises PSG and sets initial value for the PLAY statement
;Registers: All
shutay
        push bc
        push de
        ld de,0xe00
shutay0
        dec d
        ld bc,0xfffd
        out (c),d
        ld b,0xbf
        out (c),e
        jr nz,shutay0
        pop de
        pop bc
        ret
        
L0093
;WRTPSG
;Address  : #0093
;Function : Writes data to PSG-register
;Input    : A  - PSG register number
;           E  - data write
        push bc
        ld bc,0xfffd
        out (c),a
        ld b,0xbf
        out (c),e
        pop bc
        ret
        
L0096
;RDPSG
;Address  : #0096
;Function : Reads value from PSG-register
;Input    : A  - PSG-register read
;Output   : A  - value read
        push bc
        ld bc,0xfffd
        out (c),a
        in a,(c)
        pop bc
        ret

L00D5
;GTSTCK
;Address  : #00D5
;Function : Returns the joystick status
;Input    : A  - Joystick number to test (0 = cursors, 1 = port 1, 2 = port 2)
;Output   : A  - Direction (1 up, 3 right, 5 down, 7 left, 8 up-left)
;Registers: All
        or a
        jr nz,GTSTCK2
       ld a,0xf7
       in a,(0xfe)
       bit 4,a
        ld a,0xef
        in a,(0xfe)
       jr nz,$+4
       res 1,a
        rra
        and 0x0f
        ld hl,tstick
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        ld a,(hl)
        ret
tstick
;sinclair joystick 6789
        ;db 0,0,0,0
        ;db 0,6,8,7
        ;db 0,4,2,3
        ;db 0,5,1,0
;cursor joystick 6785
        db 0,0,0,0
        db 0,4,6,5
        db 0,2,8,1
        db 0,3,7,0
GTSTCK2
        xor a
        ret

L00D8
;GTTRIG
;Address  : #00D8
;Function : Returns current trigger status
;Input    : A  - trigger button to test
;           0 = spacebar
;           1 = port 1, button A
;           2 = port 2, button A
;           3 = port 1, button B
;           4 = port 2, button B
;Output   : A  - #00 trigger button not pressed
;                #FF trigger button pressed
;Registers: AF
        or a
        jr nz,GTTRIG2
        ld a,0x7f
        in a,(0xfe)
        cpl
        rra
        jr c,GTTRIGOK
        ld a,0xef
        in a,(0xfe)
        cpl
        rra
GTTRIGOK
        sbc a,a
        ret
GTTRIG2
        xor a
        ret

L0141
;SNSMAT
;Address  : #0141
;Function : Returns the value of the specified line from the keyboard matrix
;Input    : A  - for the specified line
;Output   : A  - for data (the bit corresponding to the pressed key will be 0)
;Registers: AF
        cp 5
        jr z,SNSMAT_5
        cp 2
        jr z,SNSMAT_2
       if 1==0
        push bc
        ld a,0x7f
        in a,(0xfe)
        rrca
        rrca
        rrca
        and 0xe0
        ld c,a
        ld a,0xfe
        in a,(0xfe)
        and 0x1f
        or c
        pop bc
       else
;7:matrix RET,SELECT,BS,STOP,TAB,ESC,F5,F4 (SELECT,ESC needed)
        ld a,(curkey)
        cp key_enter
        ld a,0xff-64 ;SELECT
        ret z
        ld a,(curkey)
        cp key_esc
        jr nz,SNSMAT_no
        ld a,0xff-4 ;ESC
       endif
        ret
SNSMAT_2
;matrix BA /.,`' (A needed)
        ld a,0xfd
        in a,(0xfe)
        rrca
        rrca
        or 0xbf ;'A'
        ret
SNSMAT_5
;matrix ZYXWVUTS (Z,X needed)
        ld a,0xfe
        in a,(0xfe)
        rra
        rra ;'Z'
        bit 0,a ;'X'
        ld a,0xff
        rra ;'Z'
        ret nz
        res 5,a ;'X'
        ret
SNSMAT_no
        ld a,0xff
        ret
        
L0156
;KILBUF
;Address  : #0156
;Function : Clear keyboard buffer
;Registers: HL
        ret

setpgsscr8000c000
        call getuser_scr_low
        SETPG32KLOW
        call getuser_scr_high
        SETPG32KHIGH
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

changescrpg
        ld hl,getuser_scr_low_patch
        ld a,(hl)
        xor getuser_scr_low_patchN
        ld (hl),a
        ld hl,getuser_scr_high_patch
        ld a,(hl)
        xor getuser_scr_high_patchN
        ld (hl),a
        ld a,(curscrnum_int)
        xor 1
        ld (curscrnum_int),a
        ret

wasfont
        incbin "cga.bin"

        display $
        ds 0x2000-$

        include "ISITAR.ASM"

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	savebin "isitar.com",begin,end-begin
	LABELSLIST "../../../us/user.l"
