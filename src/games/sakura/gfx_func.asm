clear_screen:
        ld e,0
        OS_CLS
        ret

setpal_proc
;       call makefadepixel
;       call makewhitepixel
;       call makefonttable
;       ld de,(fadecolor)
;       OS_SETBORDER
        ld de,pal
        OS_SETPAL
        xor a
        ld (setpalflag),a
        ret        


anim_wait:
        ret


print_hl
        ld a,(hl)
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        inc hl
        jp print_hl
        ret
;---------------------------------------
;for 320x200
_immed_big:
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


        halt
        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,0x8000
        ld de,0xc000
        ld bc,8000
        ldir

        halt
        ld a,(load_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0xa000
        ld de,0xe000
        ld bc,8000
        ldir


        halt
        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,0xa000
        ld de,0xe000
        ld bc,8000
        ldir

        jp restore8000c000
;-------------
;draw load buf over scr0 . color 0x08 is transparent
_immed_overlay_big:
        call store8000c000

        ld a,(load_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000        

        ld hl,0xc000
        ld de,0x8000
        ld bc,16384

        call _iob

        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000  

        ld hl,0xc000 ;dest
        ld de,0x8000 ;src
        ld bc,16384

        call _iob

        jp restore8000c000        
;------------------------------------------------------------------        
;copy image to screen by mask (9 color in palette is mask)
_iob_byte:
        ld a,(de)
        cp 0b11000000   ;double transparent bytes
        jr z,_iob_next_b
        push af
        and 0b10111000
        cp  0b10000000
        jr z,_iob_left_transparent
        pop  af
        push af
        and 0b01000111
        cp  0b01000000
        jr z,_iob_right_transparent
        pop af
        ld (hl),a; all solid. copy
_iob_next_b
        ret        

_iob
_iob_loop        
        call _iob_byte
        inc de
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,_iob_loop
        ret
_iob_left_transparent
        ld a,0b10111000 ;
        and (hl)
        ld (hl),a
        pop af
        and 0b01000111
        or (hl)
        ld (hl),a
        jr _iob_next_b
_iob_right_transparent
        ld a,0b01000111
        and (hl)
        ld (hl),a
        pop af
        and 0b10111000
        or (hl)
        ld (hl),a
        jr _iob_next_b        
;------------------------------------------------------------------        
;_immed  32  (50) моментально
;_sidas  36 54 от краёв к центру прямоугольником
;_jaluzi 37  55 по спирали от края к центру в два хода.
;_sidas  38  56 из центра во все стороны прямоугольником
;_cntsds 39 -57 от центра экрана влево и вправо одновременно.
;_dn_up  3A -58 от центра экрана вверх и вниз одновременно.
;_ud_nd  3B -59 проявление обратным растворением. 
;_jaluzi 3C -60 жалюзи. сверху вниз и снизу вверх одновременно через строку
;_lftrgt 3D - 61 слева направо. (ветер)
mask_mode db 0
_memory_output_mask:
        ld a,1
        jr _memory_output_o
_memory_output:
        xor a
_memory_output_o:        
        ld (mask_mode),a

        ld a,(mem_buf1)
        ld (src_buf1),a
        ld a,(mem_buf2)
        ld (src_buf2),a

        ld hl,mempal
        ld de,pal
        ld bc,32
        ldir            ;copy palette for image in membuf

        jr _mb_output
_2ndscreen_output:
        xor a
        ld (mask_mode),a
        ld a,(user_scr1_low)
        ld (src_buf1),a
        ld a,(user_scr1_high)
        ld (src_buf2),a 
        jr _mb_output
_buffer_output_mask:
        ld a,1
        jr _buffer_output_o
_buffer_output
        xor a
_buffer_output_o:        
        ld (mask_mode),a        
        ld a,(load_buf1)
        ld (src_buf1),a
        ld a,(load_buf2)
        ld (src_buf2),a
_mb_output:
        ld a,0
outtyp equ $-1
        cp 0x32
        jp z,_immed
        cp 0x36
        jp z,_sidas
        cp 0x37
        jp z,_jaluzi
        cp 0x38
        jp z,_sidas
        cp 0x39
        jp z,_cntsds
        cp 0x3a
        jp z,_dn_up
        cp 0x3b
        jp z,_ud_nd
        cp 0x3c
        jp z,_jaluzi
        cp 0x3d
        jp z,_lftrgt
        jp _jaluzi
;------------------------------------------------------------------        
; 256x160
;mode 0x32
_immed:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        halt
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0x8004
        ld b,160
_immed_v1:
        push bc
        push hl
        pop de
        set 6,d

        call _ldi_32
        ld bc,8
        add hl,bc
        pop bc 
        djnz _immed_v1



        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,0x8004
        ld b,160
_immed_v2:
        push bc
        push hl
        pop de
        set 6,d

        call _ldi_32
        ld bc,8
        add hl,bc
        pop bc 
        djnz _immed_v2

        halt
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0xa004
        ld b,160
_immed_v3:
        push bc
        push hl
        pop de
        set 6,d

        call _ldi_32
        ld bc,8
        add hl,bc
        pop bc 
        djnz _immed_v3

        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000        

        ld hl,0xa004
        ld b,160
_immed_v4:
        push bc
        push hl
        pop de
        set 6,d

        call _ldi_32
        ld bc,8
        add hl,bc
        pop bc 
        djnz _immed_v4
        jp restore8000c000

;------------------------------------------------------------------        
_ldi_32
        ld a,(mask_mode)
        and a
        jr nz,_ldi_32_iob
        dup 32
        ldi
        edup
        ret
_ldi_32_iob
        ex de,hl
        dup 32
        call _iob_byte
        inc hl
        inc de
        edup
        ex de,hl
        ret
;----
;hl-src de-dest b,counter
_down_cpy:
        ld a,(mask_mode)
        and a
        jr nz,_down_cpy_iob

        push bc
        ld a,(hl)
        ld (de),a
        call DHL
        ex de,hl
        call DHL
        ex de,hl
        pop bc
        djnz _down_cpy
        ret
_down_cpy_iob:
        push bc

        ex de,hl
        call _iob_byte
        ex de,hl

        call DHL
        ex de,hl
        call DHL
        ex de,hl
        pop bc
        djnz _down_cpy
        ret
;------------------------------------------------------------------        
; 256x160
;left to right
;mode  ????? ;0x3d
_lftrgt:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8004

        ld b,32
_lftrgt_loop        
        push bc

        push hl
        pop de
        set 6,D


        push hl
        push de

        halt
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld b,160
        call _down_cpy

        pop de
        pop hl
        push hl
        push de

        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld b,160
        call _down_cpy


        pop de
        pop hl

        set 5,H
        set 5,D

        push hl
        push de

        halt
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld b,160
        call _down_cpy

        pop de
        pop hl
        push hl
        push de

        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld b,160
        call _down_cpy

        pop de
        pop hl
        res 5,h
        inc hl


        pop bc
        dec b
        jp nz,_lftrgt_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 256x160
;left to right and right to left same time (interleave)
;mode  ???? 
_sidas:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8004
        ld (sidas_l),hl
        ld hl,0x8004+31
        ld (sidas_r),hl

        ld b,32
_sidas_loop        
        push bc


        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        halt

        ld hl,0
sidas_l equ $-2        
        push hl
        pop de
        set 6,D

        push hl
        push de

        ld b,160
        call _down_cpy

        pop de
        pop hl
        push hl

        set 5,H
        set 5,D

        ld b,160
        call _down_cpy

        pop  hl
        inc hl
        ld (sidas_l),hl


        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,0
sidas_r equ $-2        
        push hl
        pop de
        set 6,D

        set 5,H
        set 5,D

        push hl
        push de

        ld b,160
        call _down_cpy

        pop de
        pop hl
        push hl

        res 5,H
        res 5,D

        ld b,160
        call _down_cpy

        pop  hl
        dec hl
        ld (sidas_r),hl


        pop bc
        dec b
        jp nz,_sidas_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 256x160
;top to middle and bottom to middle same time
;mode ???
_ud_nd:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8004
        ld (_ud_nd_top),hl
        ld hl,0x8004+(159*40)
        ld (_ud_nd_btm),hl


        ld b,80 ;160/2
_ud_nd_loop:        
        halt
        push bc



        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_ud_nd_top: equ $-2

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_32

        ld hl,0
_ud_nd_btm: equ $-2

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_32

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_ud_nd_top)

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_32

        pop hl
        call DHL
        ld (_ud_nd_top),hl

        ld hl,(_ud_nd_btm)

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_32

        pop hl
        call UPHL
        ld (_ud_nd_btm),hl


        pop bc
        dec b
        jp nz,_ud_nd_loop

        jp restore8000c000
;------------------------------------------------------------------               
; 256x160
;from center up and down same time
;mode 0x3a
_dn_up:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8004+(80*40)
        ld (_dn_up_top),hl
        ld hl,0x8004+(79*40)
        ld (_dn_up_btm),hl


        ld b,80 ;160/2
_dn_up_loop:        
        halt
        push bc



        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_dn_up_top: equ $-2

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_32

        ld hl,0
_dn_up_btm: equ $-2

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_32

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_dn_up_top)

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_32

        pop hl
        call DHL
        ld (_dn_up_top),hl

        ld hl,(_dn_up_btm)

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_32

        pop hl
        call UPHL
        ld (_dn_up_btm),hl


        pop bc
        dec b
        jp nz,_dn_up_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 256x160
;jaluzi top to bottom and bottom to top same tome interleave
;mode 0x3c
_jaluzi:
        ld a,1
        ld (setpalflag),a
        call store8000c000



        ld hl,0x8004
        ld (_jaluzi_top),hl
        ld hl,0x8004+(159*40)
        ld (_jaluzi_btm),hl


        ld b,80 ;160/2
_jaluzi_loop:
        halt
        push bc

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_jaluzi_top: equ $-2

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_32

        ld hl,0
_jaluzi_btm: equ $-2

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_32

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_jaluzi_top)

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_32

        pop hl
        call DHL1
        ld (_jaluzi_top),hl

        ld hl,(_jaluzi_btm)

        push hl
        pop de        
        set 6,D

        push hl
        push de

        call _ldi_32

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_32

        pop hl
        call UPHL1
        ld (_jaluzi_btm),hl

        pop bc
        dec b
        jp nz,_jaluzi_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 256x160
;from center to sides left and right same time
;mode 0x39
_cntsds:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8004+15  ;to left
        ld (_cntsds_lft),hl

        ld hl,0x8004+16 ;to right
        ld (_cntsds_rgt),hl

        xor a
        ld (_cntsds_fsa),a


        ld b,64  ; 256 /2 /2
_cntsds_loop:
        halt
        push bc

        ld hl,_cntsds_loop_end
        push hl


        ld a,0
_cntsds_fsa: equ $-1
        and a
        jp z,_cntsds_f0
        cp 1
        jp z,_cntsds_f1
        cp 2
        jp z,_cntsds_f2
        cp 3
        jp z,_cntsds_f3


_cntsds_loop_end:
        ld a,(_cntsds_fsa)
        inc a
        and 3
        ld (_cntsds_fsa),a
        pop bc
        dec b
        jp nz,_cntsds_loop


        jp restore8000c000

;----
_cntsds_f0:
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,0
_cntsds_lft: equ $-2
        push hl
        pop de
        set 6,d

        set 5,h
        set 5,d

        ld b,160
        call _down_cpy

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0
_cntsds_rgt: equ $-2
        push hl
        pop de
        set 6,d

        ld b,160
        jp _down_cpy


;----
_cntsds_f2:
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_lft)
        push hl
        pop de
        set 6,d

        ld b,160
        call _down_cpy

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_rgt)
        push hl
        pop de
        set 6,d

        set 5,h
        set 5,d

        ld b,160
        jp _down_cpy


;----
_cntsds_f1:
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_lft)
        push hl
        pop de
        set 6,d

        set 5,h
        set 5,d

        ld b,160
        call _down_cpy

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt)
        push hl
        pop de
        set 6,d

        ld b,160
        jp _down_cpy
;----
_cntsds_f3:
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_lft)
        push hl
        push hl
        pop de
        set 6,d

        ld b,160
        call _down_cpy

        pop hl
        dec hl
        ld (_cntsds_lft),hl

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt)
        push hl
        push hl
        pop de
        set 6,d

        set 5,h
        set 5,d


        ld b,160
        call _down_cpy

        pop hl
        inc hl
        ld (_cntsds_rgt),hl
        ret
;------------------------------------------------------------------  
;in B - y C-x
;out   set coordinates for TYPE

_pradd
        LD (CORDS),BC
        SRL     C
        SBC     A
        AND %00100000
        LD      (M111),A

        PUSH HL
        LD H,#C0
        LD A,H
        OR 0
M111    EQU $-1
        LD H,A

        LD A,C
        ADD A,4
        LD L,A

        LD DE,320
pradd_l:        
        ADD HL,DE
        DJNZ pradd_l
        LD (COORDS),HL
        POP HL
        RET        
;---------------        
;in A - char to print
_type
        ld de,0
COORDS  equ $-2        
        ld h,0
        ld l,a
M10:
        ld bc,FONT
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,bc ;hl addr in FONT

        ex de,hl

        push hl
        ld a,(user_scr0_low)
        SETPGC000
        ld b,8
_ppnz2:
        push bc
        ld a,(de)
        ld (hl),a
        inc de
        ld bc,40
        add hl,bc
        pop bc
        djnz _ppnz2
        pop hl

        push hl
        ld a,(user_scr0_high)
        SETPGC000
        ld b,8
_ppnz3:
        push bc
        ld a,(de)
        ld (hl),a
        inc de
        ld bc,40
        add hl,bc
        pop bc
        djnz _ppnz3
        pop hl

        ld a,h
        xor 0x20
        bit 5,h
        ld h,a
        jr z,_ppnz4:
        inc hl

_ppnz4:        
        ld (COORDS),hl
        ld bc,(CORDS)
        inc c
        ld (CORDS),bc
        ld a,c
        cp 64
        ret c

        inc b
        ld c,0
        jp _pradd

UPHL1   CALL UPHL
UPHL
        PUSH BC
        LD BC,40
        AND A
        SBC HL,BC
        POP BC
        RET


DHL1    CALL DHL
DHL
        PUSH BC
        LD BC,40
        ADD HL,BC
        POP BC
        RET
;;;;;;;;;;;;;;;;;;;;;;;
clear_whole_screen:
        call storec000
        ld a,(user_scr0_high)
        SETPGC000
        LD HL,#C000
        LD DE,#C001
        LD BC,16383
        LD [HL],L
        LDIR
        ld a,(user_scr0_low)
        SETPGC000
        LD HL,#C000
        LD DE,#C001
        LD BC,16383
        LD [HL],L
        LDIR
        jp restorec000
;;;;;;;;;;;;;;;;;;;;;;;;
_clear_textbox:
        call storec000

        ld a,(user_scr0_high)
        SETPGC000
CLEARER_ LD HL,0xda44      ;D080
CLEARER1 LD B,32
        XOR A
25      PUSH HL
        LD C,32
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ 25B

CLEARER2 LD HL,0xfa44   ;F080
CLEARER3 LD B,32
        XOR A
25      PUSH HL
        LD C,32
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ 25B

        ld a,(user_scr0_low)
        SETPGC000
CLEARER_A LD HL,0xda44
CLEARER1A LD B,32
        XOR A
25      PUSH HL
        LD C,32
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ 25B
CLEARER2A LD HL,0xfa44
CLEARER3A LD B,32
         XOR A
25         PUSH HL
         LD C,32
         LD (HL),A
         INC HL
         DEC C
         JR NZ,$-3
         POP HL
        LD DE,40
        ADD HL,DE
         DJNZ 25B
        
         jp restorec000

;----------------------------------------------------
_pre_setup
        ; ld a,(hl);string length
        ld a,(hl)
        ld (_line_lenght),a
        inc hl 

        ld a,(hl)
        ld (DOWN_LIMIT),a
        inc hl 
        push hl
        xor a
        ld (CUR_POS),a
        LD HL,#121A
        LD (_mnpos),HL
        pop hl
        ret
;----------------------------------------------------
_prt_menu
        ld bc,0
_mnpos: equ $-2        
        call _pradd
prt_m1:
        ld a,(hl)
        inc hl
        and a
        RET Z
        cp 1
        JR Z,PRT_M2
        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2        
        SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR prt_m1
PRT_M2: LD A,(_mnpos+1)
        INC A
        LD (_mnpos+1),A
        JR _prt_menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_sel_menu:
        ld hl,0xD691   ;- left top corner of menus
        ld a,0
CUR_POS EQU $-1 
        and a 
        jr z,_sel_m_skip_c

        ld bc,320
_sel_menu_clc:
        add hl,bc
        dec a
        jr nz,_sel_menu_clc

_sel_m_skip_c:
        ld (SEL_S),hl

        call _highlight_selected
_sel_wait_loop:
        call waitkey

        cp key_up
        jr z,_sel_move_up
        cp key_down
        jr z,_sel_move_down
        cp key_enter
        jr z,_sel_sel_key
        cp ' '
        jr z,_sel_sel_key
        cp key_esc
        jr z,_sel_esc_key
        jr _sel_wait_loop

_sel_move_down
        ld hl,0
SEL_S   EQU $-2
        call _highlight_selected        
        ld hl,CUR_POS
        ld a,(hl)
        cp 0
DOWN_LIMIT EQU $-1        
        jp nc,_sel_menu
        inc (hl)
        jp _sel_menu

_sel_move_up
        ld hl,(SEL_S)
        call _highlight_selected        
        ld hl,CUR_POS
        ld a,(hl)
        and a
        jp z,_sel_menu
        dec (HL)
        jp _sel_menu
_sel_sel_key:
        ld hl,(SEL_S)
        call _highlight_selected
        ld a,(CUR_POS)
        ret

_sel_esc_key:
SEL_L   
        ld hl,(SEL_S)
        call _highlight_selected
        ld a,0xff
        ret

;--------------------------------------
;in hl adress in screen
_highlight_selected
;LINE1
        push de
        push hl
        call storec000
        pop hl 

        LD A,0
_line_lenght equ $-1
        LD [LINELEN],A
        LD [LINELEN0],A
        LD [LINELEN1],A
        LD [LINELEN2],A

         LD [LINE1_1],HL
         set 5,h
         LD [LINE1_2],HL

         ld a,(user_scr0_high)
         SETPGC000

         LD HL,0
LINE1_1  EQU $-2
         LD B,8
0        PUSH BC,HL
         LD B,6
LINELEN EQU $-1
1        LD A,(HL)
         XOR %00010010
         LD (HL),A
         INC HL
         DJNZ 1B
         POP HL
         CALL DHL
         POP BC
         DJNZ 0B
         LD HL,0
LINE1_2  EQU $-2
         LD B,8
0        PUSH BC,HL
         LD B,6
LINELEN0 EQU $-1
1        LD A,(HL)
         XOR %00010010
         LD (HL),A
         INC HL
         DJNZ 1B
         POP HL
         CALL DHL
         POP BC
         DJNZ 0B

         ld a,(user_scr0_low)
         SETPGC000

         LD HL,(LINE1_1)
         LD B,8
0        PUSH BC,HL
         LD B,6
LINELEN1 EQU $-1
1        LD A,(HL)
         XOR %00010010
         LD (HL),A
         INC HL
         DJNZ 1B
         POP HL
         CALL DHL
         POP BC
         DJNZ 0B

         LD HL,[LINE1_2]
         LD B,8
0        PUSH BC,HL
         LD B,6
LINELEN2 EQU $-1
1        LD A,(HL)
         XOR %00010010
         LD (HL),A
         INC HL
         DJNZ 1B
         POP HL
         CALL DHL
         POP BC
         DJNZ 0B

         call restorec000
         pop de
         ret
;;;;;;;;;;;;;;;;;;;;;;
_pre_menu_store_bgnd:
        push af
        push hl
        ;#d680
        call store8000c000

        ld a,(src_buf1)
        SETPG8000

        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0xd680
        ld de,0x8000
        ld bc,320*7
        ldir

        ld hl,0xf680
        ld bc,320*7
        ldir


        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0xd680
        ld bc,320*7
        ldir

        ld hl,0xf680
        ld bc,320*7
        ldir

        call restore8000c000
        pop hl
        pop af
        ret
_pre_menu_restore_bgnd:
        push af
        push hl
        ;#d680
        call store8000c000

        ld a,(src_buf1)
        SETPG8000

        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0x8000
        ld de,0xd680
        ld bc,320*7
        ldir

        ld de,0xf680
        ld bc,320*7
        ldir

        ld a,(user_scr0_high)
        SETPGC000
        ld de,0xd680
        ld bc,320*7
        ldir

        ld de,0xf680
        ld bc,320*7
        ldir
        call restore8000c000        
        pop hl
        pop af
        ret
;---------------------------
store_scr0_mem_buf:
        call store8000c000

        ld a,(mem_buf1)
        SETPG8000

        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0xc000
        ld de,0x8000
        ld bc,16384
        ldir

        ld a,(mem_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0xc000
        ld de,0x8000
        ld bc,16384
        ldir

        ld hl,pal
        ld de,0xbfff-32
        ld bc,32
        ldir        
        jp restore8000c000

restore_scr0_mem_buf:
        call store8000c000

        ld a,(mem_buf2)
        SETPG8000

        ld a,(user_scr0_high)
        SETPGC000

        ld de,pal
        ld hl,0xbfff-32
        ld bc,32
        ldir

        ld a,1
        ld (setpalflag),a

        ld de,0xc000
        ld hl,0x8000
        ld bc,16384
        ldir

        ld a,(mem_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000
        ld de,0xc000
        ld hl,0x8000
        ld bc,16384
        ldir

        jp restore8000c000        
;--------------------------- 
EXITDARK
       CALL clear_whole_screen
       JP begin

;;;;;;=====
FLASH
        ld b,(hl)
        inc hl
        push hl

        push bc

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir

        pop bc

FLASH_LP:
        push bc

        ld hl,whitepal
        ld de,pal
        ld bc,32 
        ldir

        ld a,1
        ld (setpalflag),a

        halt
        halt
        halt
        halt
        halt


        ld hl,temppal
        ld de,pal
        ld bc,32 
        ldir

        ld a,1
        ld (setpalflag),a

        halt
        halt
        halt
        halt
        halt

        pop bc
        djnz FLASH_LP
        pop hl
        jp _print


SHAKE:
        ld b,(hl)
        inc hl

        push hl
        push bc

        call store8000c000

        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr1_low)
        SETPGC000

        ld hl,0x8000+320
        ld de,0xc000
        ld bc,8000-320
        ldir
        ;ld hl,0x8000
        ;ld bc,320
        ;ldir

        ld hl,0xa000+320
        ld de,0xe000
        ld bc,8000-320
        ldir
        ;ld hl,0xa000
        ;ld bc,320
        ;ldir


        ld a,(user_scr0_high)
        SETPG8000
        ld a,(user_scr1_high)
        SETPGC000

        ld hl,0x8000+320
        ld de,0xc000
        ld bc,8000-320
        ldir
        ;ld hl,0x8000
        ;ld bc,320
        ;ldir

        ld hl,0xa000+320
        ld de,0xe000
        ld bc,8000-320
        ldir
        ;ld hl,0xa000
        ;ld bc,320
        ;ldir


        pop bc
SHAKE_LP:
        push bc

        ld e,1
        OS_SETSCREEN

        halt
        halt
        halt
        halt
        halt

        ld e,0
        OS_SETSCREEN

        halt
        halt
        halt
        halt
        halt

        pop bc
        djnz SHAKE_LP

        call restore8000c000
        pop hl
        jp _print
;;;;;;;;;;;;;;;;;;;;;;
; РИСУНОК ИЗ ПАМЯТИ В БУФЕР ВЫВОДА
RESTOREBGND
       PUSH HL

       call store8000c000

       ld a,(mem_buf1)
       SETPG8000
       ld a,(load_buf1)
       SETPGC000

       ld hl,0x8000
       ld de,0xc000
       ld bc,16384
       ldir

       ld a,(mem_buf2)
       SETPG8000
       ld a,(load_buf2)
       SETPGC000

       ld hl,0x8000
       ld de,0xc000
       ld bc,16384
       ldir

       ld hl,mempal
       ld de,pal
       ld bc,32
       ldir

       call restore8000c000
       POP HL
       JP _print

;-----
;В ТЕОРИИ ДОЛЖНО БЫТЬ ЗАКИДЫВАНИЕ ЭКРАНА В "PAGEMEM"
;СЕЙЧАС СДЕЛАЛ ЗАКИДЫВАНИЕ "PAGEBUF"  В  "PAGEMEM"
STOREBGND
       PUSH HL
       call store8000c000

       ld a,(mem_buf1)
       SETPG8000
       ld a,(load_buf1)
       SETPGC000

       ld hl,0xc000
       ld de,0x8000
       ld bc,16384
       ldir

       ld a,(mem_buf2)
       SETPG8000
       ld a,(load_buf2)
       SETPGC000

       ld hl,0xc000
       ld de,0x8000
       ld bc,16384
       ldir

       ld hl,pal
       ld de,mempal
       ld bc,32
       ldir

       call restore8000c000
       POP HL
       JP _print       

;-------GROUP15 TEMINATORS-----
ALLANIMOFF
CLRANIM JP _print
ANIMON  INC HL
        JR CLRANIM
LOADANIM
          LD DE,4
          ADD HL,DE
LOADANIM0 LD A,(HL)
          AND A
          JR Z,LOADANIM1
          INC HL
          JR LOADANIM0
LOADANIM1 INC HL
          JP _print

;-----------------------------
CLRSCREEN LD A,(HL)
          LD (outtyp),A
          INC HL
          PUSH HL

          call store8000c000
          ld a,(user_scr1_low)
          SETPG8000

          ld hl,0x8000
          ld de,0x8001
          ld bc,16383
          ld (hl),0
          ldir

          ld a,(user_scr1_high)
          SETPG8000

          ld hl,0x8000
          ld de,0x8001
          ld bc,16383
          ld (hl),0
          ldir

          call restore8000c000
          call _2ndscreen_output
          pop hl
          jp _print

;======================
load_tb008:
        inc hl
        LD A,(HL)
        LD (DELAY),A
        inc hl
        push hl
        call load_gfx_to_load_buf_nopal
        pop hl
       ld de,buf
        call copystr_hlde
        inc hl
        JP _print        

;======================
SPRITELOAD1:
        ld a,(hl)
        cp 07
        jr z,load_tb008
        INC HL
        LD A,(HL)
        LD (DELAY),A
        INC HL
        LD A,(HL)
        CP #0D
        JP Z,NORMALSPR

;----------------------------------------------------------------------------------------
;ВОЗМОЖНО ВСЕТАКИ ТУТ НАДО ЗАКИДЫВАНИЕ ЭКРАНА В "PAGEBUF"

        ;здесь грузится tb_008 !!!!!

        LD DE,7
        ADD HL,DE
        JP _print


NORMALSPR
        INC HL
        LD A,(HL)
        LD (XPOS),A
        INC HL,HL

        PUSH HL
        call load_gfx_to_scr_buf
        pop hl

        ld de,buf
        call copystr_hlde
        inc hl

        push hl
        CALL DECR_SPR
        POP HL
        JP _print


decrspr_offset dw 0 ;offset to draw sprite
dcrspr_len dw 0      ; cutted length
DECR_SPR:

        ld a,0
XPOS    EQU $-1
        SRL A
        jr nc,xpos1
        inc a
xpos1:        
        ld c,a
        ld b,0

;         LD BC,0
;XPOS     EQU $-2
;        LD HL,ZONEADR
;        ADD HL,BC
;        LD C,(HL)
;        ld b,0

        ld (decrspr_offset),bc

        and a
        ld hl,32
        SBC hl,bc
        ld (dcrspr_len),hl

        call store8000c000

        ld a,(scr_buf1)
        SETPG8000
        ld a,(load_buf1)
        SETPGC000

        ld bc,(decrspr_offset)
        ld hl,0xc004
        add hl,bc
        ld de,0x8004

        ld b,160
decr_spr_lp1:
        push bc

        push hl
        push de

        ld bc,(dcrspr_len)
        call _iob

        pop hl ; (de)
        call DHL
        ex de,hl
        pop hl
        call DHL

        pop bc
        djnz decr_spr_lp1


        ld bc,(decrspr_offset)
        ld hl,0xe004
        add hl,bc
        ld de,0xa004

        ld b,160
decr_spr_lp2:
        push bc

        push hl
        push de

        ld bc,(dcrspr_len)
        call _iob

        pop hl ; (de)
        call DHL
        ex de,hl
        pop hl
        call DHL

        pop bc
        djnz decr_spr_lp2


        ld a,(scr_buf2)
        SETPG8000
        ld a,(load_buf2)
        SETPGC000

        ld bc,(decrspr_offset)
        ld hl,0xc004
        add hl,bc
        ld de,0x8004

        ld b,160
decr_spr_lp3:
        push bc

        push hl
        push de

        ld bc,(dcrspr_len)
        call _iob

        pop hl ; (de)
        call DHL
        ex de,hl
        pop hl
        call DHL

        pop bc
        djnz decr_spr_lp3


        ld bc,(decrspr_offset)
        ld hl,0xe004
        add hl,bc
        ld de,0xa004

        ld b,160
decr_spr_lp4:
        push bc

        push hl
        push de

        ld bc,(dcrspr_len)
        call _iob

        pop hl ; (de)
        call DHL
        ex de,hl
        pop hl
        call DHL

        pop bc
        djnz decr_spr_lp4

        jp restore8000c000
;-----------------------
_prt_ingame_menu:
        ld bc,0
_ingame_m_mnpos: equ $-2
        call _pradd
prt_ingame_m1:
        ld a,(hl)
        inc hl
        and a
        RET Z
        cp 1
        JR Z,prt_ingame_m2
        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2        
        SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR prt_ingame_m1
prt_ingame_m2:
        LD A,(_ingame_m_mnpos) ;x-coord
        add a,16
        ld (_ingame_m_mnpos),a
        cp 64
        jr c,_prt_ingame_menu
        and 0x3f
        LD (_ingame_m_mnpos),A
        ld a,(_ingame_m_mnpos+1)
        inc a
        ld (_ingame_m_mnpos+1),a
        JR _prt_ingame_menu
;------------------------------------

_sel_ingame_menu:
        ld a,0
_ingame_m_curpos equ $-1
        ld hl,MENUCURHELPER
        call sel_word
        ld (_sel_ingame_SELS4),hl
        call _highlight_selected
_sel_ingame_SELS3:        
        call waitkey

        cp key_esc
        jp z,_sel_ingame_esc

        cp key_left
        jr z,_sel_ingame_SELS_keyleft
        cp key_right
        jr z,_sel_ingame_SELS_keyright

        cp key_up
        jr z,_sel_ingame_SELS_keyup
        cp key_down
        jr z,_sel_ingame_SELS_keydown
                
        cp key_enter
        jr z,_sel_ingame_SELECTED
        cp ' '
        jr z,_sel_ingame_SELECTED
        jr _sel_ingame_SELS3        
_sel_ingame_esc:
        ld hl,0
_sel_ingame_SELS4: equ $-2
        call _highlight_selected
        ld a,0xff
        ret
_sel_ingame_SELS_keyleft:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 

        ld hl,_ingame_m_curpos
        ld a,(hl)
        and a
        jp z,_sel_ingame_menu
        dec (HL)
        jp _sel_ingame_menu

_sel_ingame_SELS_keyright:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 
        ld hl,_ingame_m_curpos
        ld a,(hl)
        cp 0
_ingame_m_downlimit EQU $-1        
        jp nc,_sel_ingame_menu
        inc (hl)
        jp _sel_ingame_menu
_sel_ingame_SELECTED:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected
        ld a,(_ingame_m_curpos)
        ret

_sel_ingame_SELS_keyup:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 


        ld hl,_ingame_m_curpos
        ld a,(hl)
        sub 4
        jp m,_sel_ingame_menu        
        ld (hl),a
        jp _sel_ingame_menu

_sel_ingame_SELS_keydown:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 

        ld a,(_ingame_m_downlimit)
        inc a
        ld b,a

        ld hl,_ingame_m_curpos
        ld a,(hl)
        add a,4
        sub b       
        jp p,_sel_ingame_menu        
        add a,b
        ld (hl),a

        jp _sel_ingame_menu        