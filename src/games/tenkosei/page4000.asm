        	ORG 0x4000
page4000begin:
_immed_big_core:
        ld a,1
        ld (setpalflag),a
        call store8000c000
        halt

        ld a,(load_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000
        ld hl,0x8000
        ld de,0xc000
        ld bc,8000
        ldir

        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0x8000
        ld de,0xc000
        ld bc,8000
        ldir

        ld a,(load_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000
        ld hl,0xa000
        ld de,0xe000
        ld bc,8000
        ldir

        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0xa000
        ld de,0xe000
        ld bc,8000
        ldir

        jp restore8000c000
;------------------------------------------------------------------
; 240x148
;mode 0x32
;---
_immed:
;        ld a,1
;        ld (setpalflag),a
        call store8000c000


        halt
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0x8005
        ld b,148
        call copy_immed_line

        halt
        ld hl,0xa005
        ld b,148
        call copy_immed_line


        ld a,1
        ld (setpalflag),a

        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        halt
        ld hl,0x8005
        ld b,148
        call copy_immed_line

        ld hl,0xa005
        ld b,148
        call copy_immed_line

        jp restore8000c000

;pg8000 sourc
;pgc000 dest scr
;hl laddr
;b - num vert lines
copy_immed_line:
.lp:
        push bc
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        call _ldi_30
        ld bc,10
        add hl,bc
        pop bc
        djnz .lp
        ret

;------------------------------------------------------------------
_memory2_output_core:
        ld hl,mempal
        ld de,pal
        ld bc,32
        ldir            ;copy palette for image in membuf
_memory2_output_nopal_core:
        ld a,(mem_buf3)
        ld (src_buf1),a
        ld a,(mem_buf4)
        ld (src_buf2),a
        jp _mb_output

_memory_output_core:
        ld a,(mem_buf1)
        ld (src_buf1),a
        ld a,(mem_buf2)
        ld (src_buf2),a

        ld hl,mempal
        ld de,pal
        ld bc,32
        ldir            ;copy palette for image in membuf
        jr _mb_output


_buffer_output_core
        ld a,(load_buf1)
        ld (src_buf1),a
        ld a,(load_buf2)
        ld (src_buf2),a
_mb_output:
        ld a,(outtyp)
        jp _immed
;///////////////////////////////////////////

palette_precalc_sub:
                ld hl,pal
                ld de,pal_rgb

                ld b,16
mkpalATM3RGB
                push bc
                ld a,(hl)
                inc hl
                push hl
                ld h,(hl)
                ld l,a
                push de

                call calchexcolor ;hl=color (DDp palette) ;out: ;b=B, d=R, e=G

                ld a,e ;G
                add a,a
                add a,a
                add a,a
                add a,a
                or d ;R
                pop de
                ld c,a ;GR
                ld a,b
                add a,a
                add a,a
                add a,a
                add a,a
                ld (de),a ;B0
                inc de
                ld a,c
                ld (de),a ;GR
                inc de
                pop hl
                inc hl
                pop bc
                djnz mkpalATM3RGB
                ret

calchexcolor ;hl=color (DDp palette) ;out: ;b=B, d=R, e=G
;keep c!!!
;DDp palette: %grbG11RB(low),%grbG11RB(high)
;high B, high b, low B, low b
                ld b,0;0xff
                ld de,0;0xffff
                ld a,h
               cpl
                rra
                rl b ;B high
                rra
                rl d ;R high
                rra
                rra
                rra
                rl e ;G high
                rra
                rl b ;b high
                rra
                rl d ;r high
                rra
                rl e ;g high
                ld a,l
               cpl
                rra
                rl b ;B low
                rra
                rl d ;R low
                rra
                rra
                rra
                rl e ;G low
                rra
                rl b ;b low
                rra
                rl d ;r low
                rra
                rl e ;g low
;b=B
;d=R
;e=G
        ret


;===================
recolour
;hl=palfrom (RGB)
;de=palto (DDp)
;lx=brightness=0..15
        di
        ld (recoloursp),sp
        ld sp,hl
       ld h,tbright/256 ;once
        ld hx,16
bripalATM3
         ;ld a,(hl) ;B0
         ;inc hl
         ;push hl
         ;ld b,(hl) ;GR
       pop bc
       ld a,c
         ;ld h,tbright/256
;de=palto
;h=tbright/256
;lx=brightness
;a,b = B0,GR
         add a,lx
        ld l,a
        ld c,(hl) ;B colour component with brightness
        ld a,b
        and 0xf0
         add a,lx
        ld l,a
        ld a,b
        ld b,(hl) ;G colour component with brightness
        add a,a
        add a,a
        add a,a
        add a,a
         add a,lx
        ld l,a
        ld l,(hl) ;R colour component with brightness

       ld a,b ;G
       rlca ;g??G???? ;G10
       xor l ;R
       and 0b10010000;0b01000010 ;R10
       xor l;gr?G??R?
       rlca ;r?G??R?g
       xor c ;B
       and 0b10100101;0b01000010 ;B10
       xor c;rbG??RBg
       rrca ;grbG??RB
        or 0b00001100 ;unused bits
        ld (de),a ;low %grbG11RB
        inc de ;TODO ld (),a

       ld a,b ;G
       rlca ;?g??G??? ;G32
       xor l ;R
       and 0b01001000;0b00100001 ;R32
       xor l;?gr?G??R
       rlca ;gr?G??R?
       xor c ;B
       and 0b11010010;0b00100001 ;B32
       xor c;grbG??RB
        or 0b00001100 ;unused bits
        ld (de),a ;high %grbG11RB
        inc de ;TODO ld (),a

         ;pop hl
         ;inc hl
         dec hx
         jp nz,bripalATM3 ;TODO dup..edup
recoloursp=$+1
        ld sp,0
        ei
        ret
;===================
  ;#DD #2C      INC  IXL           #FD #2C       INC  IYL
 ; #DD #2D      DEC  IXL



fade_to_sub:
        ld (fade_tocolor),a
        ld (fade_to_op),hl

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;

        call palette_precalc_sub

        ld lx,8
fade0
        dec lx
fade_to_op: equ $-2
        ld hl,pal_rgb
        ld de,pal
        call recolour
        push ix

	ld a,1
	ld (setpalflag),a

	halt
	halt
	halt
        pop ix
        ld a,lx
        cp 0
fade_tocolor: equ $-1
        jr nz,fade0
	halt
	halt
	halt
        ret

fade_from_sub:
        ld (fade_fromcolor),a
        ld (fade_from_op),hl


        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;


        call palette_precalc_sub

        ld lx,15
fade_fromcolor: equ $-1


fadew1:
        dec lx
fade_from_op: equ $-2
        ld hl,pal_rgb
        ld de,pal
        call recolour
        push ix

	ld a,1
	ld (setpalflag),a

	halt
	halt
	halt
        pop ix
        ld a,lx
        cp 8
        jr nz,fadew1
	halt
	halt
	halt

        ld hl,temppal
        ld bc,32
        ld de,pal
        ldir
	ld a,1
	ld (setpalflag),a
        halt
        ret

        align 256
tbright
;brightness levels (black 0..7 less than original, 8 equal, 9..15 to white)
;0, 1/12, 1/8, 3/16, 2/8, 3/8, 4/8, 6/8, 1
_lev=0
        dup 16 ;colour component level
_antilev=15-_lev
        BRIGHTBYTE _lev*0
        BRIGHTBYTE _lev/12
        BRIGHTBYTE _lev*1/8
        BRIGHTBYTE _lev*3/16
        BRIGHTBYTE _lev*2/8
        BRIGHTBYTE _lev*3/8
        BRIGHTBYTE _lev*4/8
        BRIGHTBYTE _lev*6/8

        BRIGHTBYTE _lev

        BRIGHTBYTE 15-(_antilev*6/8)
        BRIGHTBYTE 15-(_antilev*4/8)
        BRIGHTBYTE 15-(_antilev*3/8)
        BRIGHTBYTE 15-(_antilev*2/8)
        BRIGHTBYTE 15-(_antilev*3/16)
        BRIGHTBYTE 15-(_antilev*1/8)
        BRIGHTBYTE 15

_lev=_lev+1
        edup


        include "ayfxplay.asm"
sfxdata     
        incbin "sfx.afb"        

page4000end: