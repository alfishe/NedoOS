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
;-------------

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
;----------------------------------------
mask_mode db 0
_sprite_output_mask_no_pal:
        ld a,1
        jr _sprite_output_o
sprite_output_no_pal:
        xor a
_sprite_output_o:        
        ld (mask_mode),a

        ld a,(scr_buf1)
        ld (src_buf1),a
        ld a,(scr_buf2)
        ld (src_buf2),a

        jr _mb_output
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
_buffer_output_op:               
        ld a,(load_buf1)
        ld (src_buf1),a
        ld a,(load_buf2)
        ld (src_buf2),a
_mb_output:
        ld a,0
outtyp equ $-1
        cp 0
        jp z,_immed
        cp 4
        jp z,_sidas
        cp 5
        jp z,_jaluzi
        cp 6
        jp z,_sidas
        cp 7
        jp z,_cntsds
        cp 8
        jp z,_dn_up
        cp 9
        jp z,_immed
        cp 10
        jp z,_jaluzi
        cp 11
        jp z,_lftrgt
        cp 12
        jp z,_cntsds_r
        cp 13
        jp z,_ud_nd
        jp _jaluzi
;------------------------------------------------------------------        
; 240x148
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

        ld hl,0x8005
        ld b,148
_immed_v1:
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
        djnz _immed_v1



;        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,0x8005
        ld b,148
_immed_v2:
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
        djnz _immed_v2

        halt
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0xa005
        ld b,148
_immed_v3:
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
        djnz _immed_v3

;        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000        

        ld hl,0xa005
        ld b,148
_immed_v4:
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
        djnz _immed_v4
        jp restore8000c000

;------------------------------------------------------------------        
_ldi_30
        ld a,(mask_mode)
        and a
        jr nz,_ldi_30_iob
        dup 30
        ldi
        edup
        ret
_ldi_30_iob
        ex de,hl
        dup 30
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

;        push bc
        ld a,(hl)
        ld (de),a
        call DHL
        ex de,hl
        call DHL
        ex de,hl
;        pop bc
        djnz _down_cpy
        ret
_down_cpy_iob:
;        push bc

        ex de,hl
        call _iob_byte
        ex de,hl

        call DHL
        ex de,hl
        call DHL
        ex de,hl
;        pop bc
        djnz _down_cpy
        ret
;------------------------------------------------------------------        
; 240x148
;left to right
;mode  ????? ;0x3d
_lftrgt:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005

        ld b,30
_lftrgt_loop        
        push bc


_lftrgt_lock:
         ld a,0        
        xor 1
        ld (_lftrgt_lock+1),a
        jr z,_lftrgt_halt_skip
        halt
_lftrgt_halt_skip:

        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl


        push hl
        push de


        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld b,148
        call _down_cpy

        pop de
        pop hl
        push hl
        push de

;        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld b,148
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


        ld b,148
        call _down_cpy

        pop de
        pop hl
        push hl
        push de

;        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld b,148
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
; 240x148
;left to right and right to left same time (interleave)
;mode  ???? 
_sidas:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005
        ld (sidas_l),hl
        ld hl,0x8005+29
        ld (sidas_r),hl

        ld b,30
_sidas_loop        


_sidas_lock:
         ld a,0        
        xor 1
        ld (_sidas_lock+1),a
        jr z,_sidas_halt_skip
        halt
_sidas_halt_skip:


        push bc


        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000



        ld hl,0
sidas_l equ $-2        
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        ld b,148
        call _down_cpy

        pop de
        pop hl
        push hl

        set 5,H
        set 5,D

        ld b,148
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

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,H
        set 5,D

        push hl
        push de

        ld b,148
        call _down_cpy

        pop de
        pop hl
        push hl

        res 5,H
        res 5,D

        ld b,148
        call _down_cpy

        pop  hl
        dec hl
        ld (sidas_r),hl


        pop bc
        dec b
        jp nz,_sidas_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 240x148
;top to middle and bottom to middle same time
;mode ???
_ud_nd:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005
        ld (_ud_nd_top),hl
        ld hl,0x8005+(147*40)
        ld (_ud_nd_btm),hl


        ld b,148/2 ;160/2
_ud_nd_loop:        


_ud_nd_lock:
         ld a,0        
        xor 1
        ld (_ud_nd_lock+1),a
        jr z,_ud_nd_halt_skip
        halt
_ud_nd_halt_skip:


        push bc



        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_ud_nd_top: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld hl,0
_ud_nd_btm: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_ud_nd_top)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call DHL
        ld (_ud_nd_top),hl

        ld hl,(_ud_nd_btm)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call UPHL
        ld (_ud_nd_btm),hl


        pop bc
        dec b
        jp nz,_ud_nd_loop

        jp restore8000c000
;------------------------------------------------------------------               
; 240x148
;from center up and down same time
;mode 0x3a
_dn_up:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005+(74*40)
        ld (_dn_up_top),hl
        ld hl,0x8005+(73*40)
        ld (_dn_up_btm),hl


        ld b,74 ;148/2
_dn_up_loop:        


_dn_up_lock:
         ld a,0        
        xor 1
        ld (_dn_up_lock+1),a
        jr z,_dn_up_halt_skip
        halt
_dn_up_halt_skip:



        push bc
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_dn_up_top: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld hl,0
_dn_up_btm: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_dn_up_top)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call DHL
        ld (_dn_up_top),hl

        ld hl,(_dn_up_btm)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call UPHL
        ld (_dn_up_btm),hl


        pop bc
        dec b
        jp nz,_dn_up_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 240x148
;jaluzi top to bottom and bottom to top same tome interleave
;mode 0x3c
_jaluzi:
        ld a,1
        ld (setpalflag),a
        call store8000c000



        ld hl,0x8005
        ld (_jaluzi_top),hl
        ld hl,0x8005+(147*40)
        ld (_jaluzi_btm),hl


        ld b,74 ;148/2
_jaluzi_loop:

_jaluzi_lock:
         ld a,0        
        xor 1
        ld (_jaluzi_lock+1),a
        jr z,_jaluzi_halt_skip
        halt
_jaluzi_halt_skip:

        push bc

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_jaluzi_top: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld hl,0
_jaluzi_btm: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_jaluzi_top)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call DHL1
        ld (_jaluzi_top),hl

        ld hl,(_jaluzi_btm)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call UPHL1
        ld (_jaluzi_btm),hl

        pop bc
        dec b
        jp nz,_jaluzi_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 240x148
;from center to sides left and right same time
;mode 0x39
_cntsds:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005+14  ;to left
        ld (_cntsds_lft),hl

        ld hl,0x8005+15 ;to right
        ld (_cntsds_rgt),hl

        xor a
        ld (_cntsds_fsa),a


        ld b,60  ; 256 /2 /2
_cntsds_loop:

_cntsds_lock:
         ld a,0        
        xor 1
        ld (_cntsds_lock+1),a
        jr z,_cntsds_halt_skip
        halt
_cntsds_halt_skip:

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

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        call _down_cpy

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0
_cntsds_rgt: equ $-2
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
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

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_rgt)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
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

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        call _down_cpy

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
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

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
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

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d


        ld b,148
        call _down_cpy

        pop hl
        inc hl
        ld (_cntsds_rgt),hl
        ret
;------------------------------------------------------------------        
; 240x148
;from sides left and right  to center same time 
;mode 0x39
_cntsds_r:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005  ;to left
        ld (_cntsds_lft_r),hl

        ld hl,0x8005+29 ;to right
        ld (_cntsds_rgt_r),hl

        xor a
        ld (_cntsds_fsa_r),a


        ld b,64  ; 256 /2 /2
_cntsds_loop_r:


_cntsds_lock1:
         ld a,0        
        xor 1
        ld (_cntsds_lock1+1),a
        jr z,_cntsds_halt_skip1
        halt
_cntsds_halt_skip1:


        push bc

        ld hl,_cntsds_loop_end_r
        push hl


        ld a,0
_cntsds_fsa_r: equ $-1
        and a
        jp z,_cntsds_f3_r
        cp 1
        jp z,_cntsds_f2_r
        cp 2
        jp z,_cntsds_f1_r
        cp 3
        jp z,_cntsds_f0_r


_cntsds_loop_end_r:
        ld a,(_cntsds_fsa_r)
        inc a
        and 3
        ld (_cntsds_fsa_r),a
        pop bc
        dec b
        jp nz,_cntsds_loop_r


        jp restore8000c000

;----
_cntsds_f0_r:
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,0
_cntsds_lft_r: equ $-2
        push hl
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        call _down_cpy

        pop hl
        inc hl
        ld (_cntsds_lft_r),hl

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0
_cntsds_rgt_r: equ $-2

        push hl
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy
        pop hl
        dec hl
        ld (_cntsds_rgt_r),hl
        ret


;----
_cntsds_f2_r:
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_lft_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_rgt_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        jp _down_cpy


;----
_cntsds_f1_r:
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_lft_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        call _down_cpy

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        jp _down_cpy
;----
_cntsds_f3_r:
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_lft_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt_r)

        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d


        ld b,148
        jp _down_cpy
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
        ld de,160+320
        add hl,de
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

 ;       ex de,hl
        push de
        push hl
        call setfontpage
        pop hl
        ld de,font_buf
        ld bc,16
        ldir
        call unsetfontpage


        pop hl

        ld de,font_buf
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
CLEARER_ LD HL,0xda44-160      ;D080
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

CLEARER2 LD HL,0xfa44-160   ;F080
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
CLEARER_A LD HL,0xda44-160
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
CLEARER2A LD HL,0xfa44-160
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
        ld hl,0xD691+320+160   ;- left top corner of menus
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
          xor 0xff ;XOR %00010010
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
         xor 0xff ;XOR %00010010
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
         xor 0xff ;XOR %00010010
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
         xor 0xff ;XOR %00010010
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
EXITDARK

        call palette_precalc
        call fade_toblack

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

                ld hl,0x8000
                ld de,0xc000+(200-8)*40
                ld bc,8*40
                ldir
        
        
                ld hl,0xa000
                ld de,0xe000+(200-8)*40
                ld bc,8*40
                ldir
        
                ld hl,0x8000+320
                ld de,0xc000
                ld bc,8000-320
                ldir
        
        
                ld hl,0xa000+320
                ld de,0xe000
                ld bc,8000-320
                ldir


        ld a,(user_scr0_high)
        SETPG8000
        ld a,(user_scr1_high)
        SETPGC000

                ld hl,0x8000
                ld de,0xc000+(200-8)*40
                ld bc,8*40
                ldir
        
        
                ld hl,0xa000
                ld de,0xe000+(200-8)*40
                ld bc,8*40
                ldir
        
                ld hl,0x8000+320
                ld de,0xc000
                ld bc,8000-320
                ldir
        
        
                ld hl,0xa000+320
                ld de,0xe000
                ld bc,8000-320
                ldir


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
_ingame_m_downlimit: EQU $-1        

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
;;;;;;;;;;;;;;;;;;;;;;
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
        ld hl,30
        SBC hl,bc
        ld (dcrspr_len),hl

        call store8000c000

        ld a,(scr_buf1)
        SETPG8000
        ld a,(load_buf1)
        SETPGC000

        ld bc,(decrspr_offset)
        ld hl,0xc005
        add hl,bc
        ld de,0x8005

        ld b,148
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
        ld hl,0xe005
        add hl,bc
        ld de,0xa005

        ld b,148
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
        ld hl,0xc005
        add hl,bc
        ld de,0x8005

        ld b,148
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
        ld hl,0xe005
        add hl,bc
        ld de,0xa005

        ld b,148
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
decrspr_offset dw 0 ;offset to draw sprite
dcrspr_len dw 0      ; cutted length
;-----------------------
anim_wait:
        LD	A,0
        INC	A
        AND	7
        LD	(anim_wait+1),A
        RET	NZ

        
        ld hl,PUSH_DATA
        ld de,0x9e23-160

        ld a,0
FASE    equ $-1

        add a,a;x2
        add a,a;x4
        add a,a;x8
        add a,a;x16
        add a,a;x32
        ld c,a
        ld b,0
        add hl,bc        
        
        ex de,hl
      

        push hl
        ld b,8
export_push_iloop1:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz export_push_iloop1
        pop hl

        set 6,H
        push hl
        ld b,8
export_push_iloop2:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz export_push_iloop2
        pop hl

        res 6,H
        set 5,H

        push hl
        ld b,8
export_push_iloop3:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz export_push_iloop3
        pop hl

        set 6,H

        ld b,8
export_push_iloop4:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz export_push_iloop4

        ld a,(FASE)
        inc a
        and 7
        ld (FASE),a

        ret
;----------------------------- 
anim_eyes:

        LD      A,0
        INC     A
        AND     3
        LD      (anim_eyes+1),A
        RET     NZ


        ld a,(font_page)
        SETPG4000

        ld a,(anim_stack_spr_num)
        ld ix,anim_stack

anim_eyes_loop:
        and a
        ret z
        push af        

        ld a,(ix+8)
        and a
        jr z,anim_eyes_mc
        dec a
        ld (ix+8),a
        jp anim_eyes_loop_cont



anim_eyes_mc:
            ;select sequence for anim
            ld a,(ix+6); type . 2 or 3 or 5
            ld hl,anim1_seq
            cp 2
            jr z,2f
            ld hl,anim2_seq
            cp 3
            jr z,2f
            ld hl,anim3_seq             


2           ld (use_seq),hl
            ld a,(ix+7) ;current phase

            cp 0xfe ;need init?
            jr z,anim_mc_fe


            cp 0xff ;need init?
            jr nz,anim_mc_cont_print

            ld (ix+7),0
            call randr
            and 0x7f
            ;add a,a
            ld (ix+8),a               
            jp anim_eyes_loop_cont ;setup complete. skip to next anim



anim_mc_fe:
            ;initialize

            ;ld a,(hl)
            ;ld (ix+7),a
            ld (ix+7),0
            ld hl,(use_seq)
            inc hl
            ld a,(hl)
            ld (ix+8),a
            jp anim_eyes_loop_cont ;setup complete. skip to next anim

anim_mc_cont_print
            call anim_mc_print_sub

                    ;move cursor to next position

anim_mc_cont:
            ;move pointer to next 
            ;a = ix+7 cursor position
            ld hl,(use_seq)
            ld a,(ix+7)
            inc a
            add a,a ; x2
            ld c,a
            ld b,0
            add hl,bc
            ld a,(hl)

            cp 0xfe
            jr c,anim_mc_cont_not_eof ;<254

anim_mc_cont_eof:
            ld (ix+7),a
            jr anim_eyes_loop_cont

anim_mc_cont_not_eof:
            inc (ix+7)

anim_eyes_loop_cont:
        ld bc,16
        add ix,bc   ;pointer to next anim 

        pop af
        dec a
        jp anim_eyes_loop

use_seq: dw 0

;----------------------------- 
anim_mc_print_sub:
                ;calculate `skip` bytes
                ld c,(ix+5);hgt
                ld d,(ix+6)
                dec d
                call C_Time_D   ;c*d a=result
                ld c,a
                ld (anim_mc_skip_anim_frame),bc



                ;calculate sprite start adress based on current frame
                ld l,(ix+0);memory pos
                ld h,(ix+1)

                ld bc,0x4000;
                and a;
                sbc hl,bc;TODO - make refactor. store in stack 0x4000 based values

                push hl
                
                ld a,(ix+7)
                add a,a ;!!!!x2
                ld c,a
                ld b,0
                ld hl,(use_seq)
                add hl,bc
                ld d,(hl)  ;a = current fase sprite offset

                ld c,(ix+5) ;hgt
                call C_Time_D   ;c*d
                ld c,a
                pop hl
                add hl,bc   ;hl sprite adress with vertical offset based on current frame
                ld (anim_src),hl ;prepare sprite src adress 




                ld l,(ix+2);screen pos
                ld h,(ix+3)

                ld de,0
anim_src    equ $-2
                ld b,(ix+4) ;len
                srl b
anim_eyes_inner_loop:
                push bc

                        ;hl ega scr addr
                        push hl
                        ld b,(ix+5) ;hgt
anim_eyes_inner_loop2:
                        push bc  

                        call _iob_byte

                        inc de
                        call DHL

                        pop bc
                        djnz anim_eyes_inner_loop2

                        pop hl
                        call p_nextcolumn

                        ;skip to next column of current frame
                        ex de,hl
                        ld bc,0
anim_mc_skip_anim_frame: equ $-2
                        add hl,bc
                        ex de,hl


                pop bc
                djnz anim_eyes_inner_loop

                ret

;---
;in hl - x-coord 0-319
;;out hl -adress in 8000 - ffff atm2 ega screen (x-offset)
p_calc_x:
        and a
        rr h
        rr l
        ld a,l
        rrca
        rrca
        ld h,0
        and a
        push af
        rla
        rr h
        rla
        rr h
        scf
        rr h
        pop af
        and 0x3f
        ld l,a
        ret 
;=============================================       
;in hl - x-adress in atm2 ega screen
;   a - y coord - 0-199
;;out hl -adress in 8000 - ffff atm2 ega screen (xy offset)
p_calc_y:
        ld bc,40
p_calc_y_loop:
        and a
        ret z
        add hl,bc
        dec a
        jr p_calc_y_loop        
;=============================================       
p_nextcolumn:
	bit 6,h
	set 6,h
	jr z,1f;shapes_linehorR_incxok
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,1f;shapes_linehorR_incxok
	inc hl
1 ;shapes_linehorR_incxok
    ret
;---------------------------------------
