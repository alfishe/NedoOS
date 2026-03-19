        	ORG 0x4000
page4000begin:

_immed_big_kernel:
            jp _immed_big_routine
_immed_overlay_big_kernel:
            jp _immed_overlay_big_routine
_memory_output_kernel
            jp _memory_output_routine
_clrscreen_kernel
            jp _clrscreen_routine
_buffer_output_kernel
            jp _buffer_output_routine
_buffer_output_mask_kernel:
            jp _buffer_output_mask_routine
;==============================================
_memory_output_routine:
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



_buffer_output_mask_routine:
        ld a,1
        jr _buffer_output_o
_buffer_output_routine:
        xor a
_buffer_output_o:        
        ld (mask_mode),a        
        ld a,(load_buf1)
        ld (src_buf1),a
        ld a,(load_buf2)
        ld (src_buf2),a
_mb_output:
        ld a,(outtyp)
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
;_immed  32  (50) моментально
;_sidas  36 54 от краёв к центру прямоугольником
;_jaluzi 37  55 по спирали от края к центру в два хода.
;_sidas  38  56 из центра во все стороны прямоугольником
;_cntsds 39 -57 от центра экрана влево и вправо одновременно.
;_dn_up  3A -58 от центра экрана вверх и вниз одновременно.
;_ud_nd  3B -59 проявление обратным растворением. 
;_jaluzi 3C -60 жалюзи. сверху вниз и снизу вверх одновременно через строку
;_lftrgt 3D - 61 слева направо. (ветер)
;============================================--
_immed_big_routine:
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
;=================
_immed_overlay_big_routine:
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
;================


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

_down_cpy_a
;        push bc
        ld a,(hl)
        ld (de),a
        call DHL
        ex de,hl
        call DHL
        ex de,hl
;        pop bc
        djnz _down_cpy_a
        ret
_down_cpy_iob:
;        push bc
        ex de,hl
        call _iob_byte
        call DHL
        ex de,hl
        call DHL
;        pop bc
        djnz _down_cpy_iob
        ex de,hl
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

        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl


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

;        halt

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

;        halt 

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

;        halt
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

;        halt
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

;        halt

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

;        halt 

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

clear_2_nd_scr:
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
          ret
;================================
_clrscreen_routine:
         LD A,(HL)
          LD (outtyp),A
          INC HL
          PUSH HL

          call store8000c000

          call clear_2_nd_scr

          call restore8000c000
          call _2ndscreen_output
          pop hl
          ret

;/////////////////////////////////////////////////////////////
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
;/////////////////////////////////////////////////////////////
mm_mnu:



    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load menu picture

        ld hl,menu_pic
        call load_big_img_dark2

        call palette_precalc
        call fade_fromblack


        ld hl,menu_pic2
        call load_gfx_to_load_buf
        call _immed_big

;        ld a,200-32-16-8
        xor a
        ld b,200-32-16-8
        ld c,(320-8+2)/2
        call leaf_init


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

_main_menu:





        ld hl,TABLE_W
        ld (CODEPAGE),hl 

        
;-----open gallery file
        call _load_cdata
;-----------------------------------------------                

        call store_scr0_mem_buf

_main_menu_mmm:



        ld a,0
_mmnr   equ $-1        
        and a
        jr z,_dont_need_restore

        call restore_scr0_mem_buf
        xor a
        ld (_mmnr),a


_dont_need_restore:
        ld a,1
        ld (petals_key),a


        ld hl,loc_main_menu
        ld de,menu_main_action

        push de
        ld a,(language)
        call sel_word
        
        call _pre_setup             ;!-------------
        call _pre_menu_store_bgnd   ;!-------------
        call _prt_menu              ;!-------------   


_mmnu_r1        
        call _sel_menu
        cp 0xff
        jr z,_mmnu_r1 ;block esc
        call _pre_menu_restore_bgnd
        pop hl
        call sel_word
        jp (hl)
;       call waitkey
_gamequit
        call no_mus

        jp cmd_quit



_loadgame
        ld hl,loc_load_menu
        ld de,menu_load_action        

        push de
        ld a,(language)
        call sel_word
        
        call _pre_setup
        call _pre_menu_store_bgnd
        call _prt_menu
        
        call _sel_menu
        call _pre_menu_restore_bgnd
        pop hl

        cp 0xff
        jp z,_main_menu_mmm

        call sel_word
        jp (hl)







_characters

_to_chr_page1
        ld hl,loc_chars1_menu
        ld de,menu_chars1_action        
        ld a,1

_characters_lp
        ld (characters_current),a
        push de
        ld a,(language)
        call sel_word
        
        call _pre_setup
        call _pre_menu_store_bgnd
        call _prt_menu
        
        call _sel_menu
        call _pre_menu_restore_bgnd
        pop hl

        cp 0xff
        jp z,_main_menu_mmm

        call sel_word
        jp (hl)

_to_chr_page2
        ld hl,loc_chars2_menu
        ld de,menu_chars2_action 
        ld a,2
        jr _characters_lp
_to_chr_page3
        ld hl,loc_chars3_menu
        ld de,menu_chars3_action 
        ld a,3
        jr _characters_lp
_to_chr_page4        
        ld hl,loc_chars4_menu
        ld de,menu_chars4_action 
        ld a,4
        jr _characters_lp
;0x33 = 33 reiko op01
;0x34 = 33 kiyomi 02
;0x35 = 33 mio 03
;0x36 = 33 shoko 04
;0x37 = 33 ruri    08   
;0x38 = 33 aki 05
;0x39 = 33 seia 06
;0x3a = 33 meimi 07

_op1_show ;reiko
        ld bc,0x0001
        jr _op_show
_op2_show ;kiyomi
        ld bc,0x0101
        jr _op_show        
_op3_show ;mio
        ld bc,0x0201
        jr _op_show        
_op4_show ;shoko
        ld bc,0x0301
        jr _op_show
_op5_show ;aki
        ld bc,0x0401
        jr _op_show
_op6_show ;seia
        ld bc,0x0501
        jr _op_show        
_op7_show ;meimi
        ld bc,0x0601
        jr _op_show        
_op8_show ;ruri
        ld bc,0x0701
        jr _op_show        
_op9_show ;kyoko
        ld bc,0x0800
        jr _op_show        
_op10_show ;makoto
        ld bc,0x0900
        jr _op_show                
_op11_show ;nobuyuki
        ld bc,0x0a00
        jr _op_show         
_op12_show ;emi
        ld bc,0x0b00
        jr _op_show         
_op13_show ;shinji
        ld bc,0x0c00
        jr _op_show                 
_op14_show ; dean
        ld bc,0x0d00
_op_show
        ld a,2
        ld (petals_key),a

        ld a,1
        ld (_mmnr),a

        ld a,b
        ld (_current_op),a

        ld a,c
        and a
        jr z,_op_skp

        ld e,b
        ld d,0
        ld hl,_op_slct
        add hl,de
        ld e,(hl)
        ld hl,CDATA
        add hl,de
        ld a,(hl)

        ld (_op_rslt),a

_op_skp:
        push bc

        ld a,b
        inc a
        call a_to_dec
        LD (op_path2+3),A
        LD A,B
        LD (op_path2+2),A        

        call fade_toblack
        ld hl,op_path2
;        call load_gfx_to_load_buf
;        call _immed_big

        call load_big_img_dark2

        call palette_precalc
        call fade_fromblack

        pop bc
        ld a,c
        and a
        jr z,_op_skp2
        ld a,(_op_rslt)
        cp 0x33
        jr nz,_op_skp2

;--------------------------
        ;TODO show badge
        ; show add menu
        ld hl,badge_pic
        call load_gfx_to_load_buf

        call _immed_overlay_big


        call waitkey

        ld hl,loc_lb_menu
        ld de,menu_lb_action

        push de
        ld a,(language)
        call sel_word
        
        call _pre_setup
        call _pre_menu_store_bgnd
        call _prt_menu
_mmnu_r2        
        call _sel_menu
        cp 0xff
        jr z,_mmnu_r2 ;block esc

        call _pre_menu_restore_bgnd

        pop hl
        call sel_word
        jp (hl)


;-------------------------

_op_skp2:
        call waitkey        

_mem_decline:
        ld a,(characters_current)
        cp 1
        jp z,_to_chr_page1
        cp 2
        jp z,_to_chr_page2
        cp 3
        jp z,_to_chr_page3
        cp 4
        jp z,_to_chr_page4        
        jp _to_chr_page1
;-----------------------------------------------------------------------
_mem_look_back:
        ld a,(_current_op)
        ld hl,_op_endings
        call sel_word   ;hl name ovl to load
        jp GAMESTART1
;-----------------------------------------------------------------------
_load_slot1:
        ld a,1
        jr _load_slot
_load_slot2:
        ld a,2
        jr _load_slot
_load_slot3:
        ld a,3
        jr _load_slot
_load_slot4:
        ld a,4
        jr _load_slot
_load_slot5:
        ld a,5
_load_slot:
        add a,"0"
        ld (SAVETEMPL_N),a


        ld de,SAVETEMPL
        call openstream_file
        or a
        jp nz,_loadgame
        jp _load_common


;-----------------------------------------------------------------------        

;////////////////////////////////////////////////////////////////////////////////////////////////
;script subroutiones
GATA:
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

        jp restore8000c000
;////////////////////////////////////////////////////////////////////////////////////////
RESTOREBGND_SUB:
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

       jp restore8000c000

;-----
; У…ПђЙ€ ЕЋМ†ОЋ В›Уњ ИЂЛ€Е›ГЂО€Г ЮЉСЂОЂ  "PAGEMEM"
;Т…К—Q Т„Ж‹K ИЂЛ€Е›ГЂО€Г "PAGEBUF"    "PAGEMEM"
STOREBGND_SUB:
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

       jp restore8000c000     
;///////////////////////////////////////////
FLASH_SUB:
        push bc

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir

        pop bc

.flash_lp:
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
        djnz .flash_lp
        ret 
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
;---------------------------------------

shifter:
        call store8000c000

        call clear_2_nd_scr


            xor a
            ld (mask_mode),a 
            ld (active_scr),a
;--------------------
        ld hl,0x8005
        ld (sslb_s),hl
        ld hl,0xC004
        ld (sslb_d),hl

        ld hl,0xA005
        ld (sslb_s2),hl
        ld hl,0xE004
        ld (sslb_d2),hl


        ld b,5

.exl_l:
        push bc
        call shift_screen_left_big

        halt
        halt
        ld a,(active_scr)
        and a
        jr nz,.spl1
        
        ; active scr 0 ; show 2nd screen . set active scr1
        inc a
        ld (active_scr),a
        ld e,a
        OS_SETSCREEN
        jr .spl0
.spl1:        
        ; active scr 1 ; show 1nd screen . set active scr 0
        dec a
        ld (active_scr),a
        ld e,a
        OS_SETSCREEN

.spl0:
        ld hl,(sslb_s)
        dec hl
        ld (sslb_s),hl
        ld hl,(sslb_s2)
        dec hl
        ld (sslb_s2),hl
        ld hl,(sslb_d)
        dec hl
        ld (sslb_d),hl
        ld hl,(sslb_d2)
        dec hl
        ld (sslb_d2),hl


        pop bc
        dec b
        jp nz,.exl_l

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        call force_scr0

        jp restore8000c000

;--------------------------
shift_screen_left_big:
        call set_scr_low


        ld hl,0  ;0xc005
sslb_s equ $-2
        ld de,0  ;0xc000
sslb_d equ $-2
        ld b,200
._immed_v1:
        push bc
            call _ldi_30
            ldi
           ldi
            ld bc,8
            add hl,bc
                ex de,hl
                ld bc,8
                add hl,bc
                ex de,hl        
        pop bc
        djnz ._immed_v1


        ld hl,0      ;0xe005
sslb_s2 equ $-2
        ld de,0      ;0xe000
sslb_d2 equ $-2
        ld b,200
._immed_v3:
        push bc
            call _ldi_30
            ldi
            ldi
            ld bc,8
            add hl,bc
                ex de,hl
                ld bc,8
                add hl,bc
                ex de,hl        
        pop bc
        djnz ._immed_v3


        call set_scr_high


        ld hl,(sslb_s)
        ld de,(sslb_d)
        ld b,200
._immed_v2:
        push bc
            call _ldi_30
            ldi
            ldi
            ld bc,8
            add hl,bc
                ex de,hl
                ld bc,8
                add hl,bc
                ex de,hl        
        pop bc
        djnz ._immed_v2


        ld hl,(sslb_s2)
        ld de,(sslb_d2)
        ld b,200
._immed_v4:
        push bc
            call _ldi_30
            ldi
            ldi
            ld bc,8
            add hl,bc
                ex de,hl
                ld bc,8
                add hl,bc
                ex de,hl        
        pop bc
        djnz ._immed_v4

        ret
_psl_mover:
        call set_scr_low

        ld hl,0xa01d+40
        ld de,0xa01d ;0xe01d
        push hl
        push de

        ld hl,0x801d+40
        ld de,0x801d;0xc01d

        ld b,200-1
._immed_v1:
        push bc
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ld bc,29
            add hl,bc
                ex de,hl
                ld bc,29
                add hl,bc
                ex de,hl        
        pop bc
        djnz ._immed_v1
    
        pop de
        pop hl

        ld b,200-1
._immed_v2:
        push bc
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ld bc,29
            add hl,bc
                ex de,hl
                ld bc,29
                add hl,bc
                ex de,hl        
        pop bc
        djnz ._immed_v2


        call set_scr_high

        ld hl,0xa01d+40
        ld de,0xa01d; 0xe01d
        push hl
        push de

        ld hl,0x801d+40
        ld de,0x801d ;0xc01d

        ld b,200-1
._immed_v3:
        push bc
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ld bc,29
            add hl,bc
                ex de,hl
                ld bc,29
                add hl,bc
                ex de,hl        
        pop bc
        djnz ._immed_v3
    
        pop de
        pop hl

        ld b,200-1
._immed_v4:
        push bc
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ldi
            ld bc,29
            add hl,bc
                ex de,hl
                ld bc,29
                add hl,bc
                ex de,hl        
        pop bc
        djnz ._immed_v4


        ret


_to_psl_loop_core:        

               call _psl_mover
    

                halt
                halt
                halt
;                halt
/*
                ld a,(active_scr)
                and a
                jr nz,.spl1
                
                ; active scr 0 ; show 2nd screen . set active scr1
                inc a
                ld (active_scr),a
                ld e,a
                OS_SETSCREEN
                jr .spl0
.spl1:        
                ; active scr 1 ; show 1nd screen . set active scr 0
                dec a
                ld (active_scr),a
                ld e,a
                OS_SETSCREEN

.spl0:

*/

         ld a,(lines_up_ctr1)
          dec a
         ld (lines_up_ctr1),a

         jr nz,_to_psl_loop_core

         ld a,(lines_up_ctr2)
         dec a
         ret z
         ld (lines_up_ctr2),a
         ld a,8
         ld (lines_up_ctr1),a
         jr _to_psl_loop_core

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

        call palette_precalc
        call fade_toblack

        ld hl,blackpal
        ld de,pal
        ld bc,32 
        ldir

        ld a,1
        ld (setpalflag),a

        call store8000c000

        ld a,(mem_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000
        ld de,0xc000
        ld hl,0x8000
        ld bc,16384
        ldir

        ld a,(mem_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld de,0xc000
        ld hl,0x8000
        ld bc,16384
        ldir

        ld de,pal
        ld hl,0xbfff-32
        ld bc,32
        ldir





        call restore8000c000 


        call palette_precalc
        jp fade_fromblack

/*
        call palette_precalc
        call fade_toblack

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
*/
;=====================================
_draw_box:
        push hl,bc,de
        call store8000c000

        ld a,(user_scr0_low) ;ok
        SETPG8000
        ld a,(user_scr0_high) ;ok
        SETPGC000

        ld l,10
        ld e,157
        ld hx,0  ;0b00001001 ;0b00000000 ;0b00001001;0b00111111 ;fill color byte 0bRLrrrlll
_draw_box_color: equ $-1
        ld lx,0xff ;0b00000000 ;0b00001001 ;0b00000000 ;11111111 ;brush color byte 0bRLrrrlll
        ld b,44-2 ;hgt-1
        ld c,140 ;0 ;wid/2


;l=x/2
;e=y
;lx=brush color byte 0bRLrrrlll
;hx=fill color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        call drawwindow
        call restore8000c000
        pop de,bc,hl
        ret


drawwindow
;l=x/2
;e=y
        ld hy,e
        ld a,l
        ld ly,a
;ly=x/2
;hy=y
        call xytoscraddr
;hl=screen addr
;lx=brush color byte 0bRLrrrlll
;hx=fill color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        push bc
        push hl
        
drawwindowfill0
        push bc
        push hl
        ld c,hx ;ld c,0b11111111 ;color byte 0bRLrrrlll
        call drawverline
        pop hl
        NEXTCOLUMN
        pop bc
        dec c
        jr nz,drawwindowfill0
        
        pop hl ;screen addr
        pop bc

        push bc

        push bc
        push hl
        call drawbox
        pop hl
        pop bc
        NEXTCOLUMN
        ld de,40*2
        add hl,de ;второй бокс внутри первого
        dec c
        dec c
        ld a,b
        sub 4
        ld b,a
        call drawbox
        
        pop bc ;b=hgt-1, c=wid/2
        
;ly=x/2
;hy=y
        ld e,hy
        inc e
        call drawwindowhormarks
        
        ld a,hy
        add a,b ;+hgt-1
        dec a
        ld e,a
        call drawwindowhormarks

        push bc
        call drawwindowvermarks
        pop bc
        ld a,ly
        add a,c ;wid/2
        dec a
        ld ly,a
        call drawwindowvermarks
        
        ret
;----------------------------------------------

xytoscraddr
;l=x/2
;e=y (не портится)
;screen pages are mapped in 2 CPU windows
;addr = tY(y) + tX(x)
        

        ld h,tx/256
        ld d,ty/256
        ld a,(de) ;(y*40)
        add a,(hl) ;x div 4
        ld (xytoscraddr_l),a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
xytoscraddr_l=$+1
        ld l,0

        ret

  
drawwindowvermarks
;ly=x/2
;hy=y
;b=hgt-1
;lx=color byte 0bRLrrrlll
        ld a,ly
        ld l,a
        ld a,hy
        add a,6
        ld e,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        ld (hl),a
        ld a,ly
        ld l,a
        ld a,hy
        add a,b ;+hgt-1
        sub 6
        ld e,a
;l=x/2
;e=y        
        call xytoscraddr
        ld a,lx
        ld (hl),a
        ret

        
drawwindowhormarks
;ly=x/2
;e=y
;c=wid/2
        ld a,ly
        add a,3
        ld l,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        xor hx
        and 0b01000111 ;color byte 0bRLrrrlll
        xor hx
        ld (hl),a

        ld a,ly
        add a,c ;+wid/2
        sub 3+1
        ld l,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        xor hx
        and 0b10111000 ;color byte 0bRLrrrlll
        xor hx
        ld (hl),a
        ret
        

drawbox
;hl=screen addr
;lx=color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        push bc
        push hl
        push bc
        ld a,lx
        xor hx
        and 0b01000111 ;color byte 0bRLrrrlll
        xor hx
        ld c,a
        call drawverline ;left line
        pop bc
        ld b,c ;wid/2
        ex (sp),hl
        ld c,lx ;ld c,0b11111111 ;color byte 0bRLrrrlll
        push bc
        call drawhorline ;top line
        pop bc ;b=wid/2, c=color byte 0bRLrrrlll
        ex (sp),hl ;bottom of left line
        call drawhorline ;bottom line
        pop hl ;rightmost byte of top line
        ld de,40
        add hl,de
        pop bc
        dec b ;b=hgt/2
        ld a,lx
        xor hx
        and 0b10111000 ;color byte 0bRLrrrlll
        xor hx
        ld c,a
        ;call drawverline ;right line
        ;ret
drawverline
;hl=scraddr
;c=color byte 0bRLrrrlll
;b=hgt
        ld de,40
drawverline0
        ld (hl),c
        add hl,de
        djnz drawverline0
        ret

drawhorline
;hl=scraddr
;c=color byte 0bRLrrrlll
;b=wid/2
        ld de,0x4000
        jr drawhorline0go
drawhorline0
        NEXTCOLUMN
drawhorline0go
        ld (hl),c
        djnz drawhorline0
        ret

;===============================================
ttr_timer:  db 0
ttr_sprlen: db 0
ttr_sprfaze db 0   ;0 for even x coords  1 - for odd x coords

ttr_s0_buf_status db 0; 0 - empty. do not restore
ttr_s1_buf_status db 0; 0 - empty. do not restore

ttr_s0_scr_adr: dw 0  ;previous position for background restore
ttr_s1_scr_adr: dw 0

ttr_s0_scr_len :
                db 0 ; sprite len /2
ttr_s1_scr_len :
                db 0 ; sprite len /2



temp_s_buf_status db 0; 0 - empty. do not restore
temp_s_scr_adr:   dw 0
temp_s_scr_len     db 0
temp_s_buf:        dw 0

set_draw_vars:
        ld a,(active_scr)
        and a
        jr z,.l1
;---draw to scr 0
        ld a,(ttr_s0_buf_status)
        ld (temp_s_buf_status),a

        ld hl,(ttr_s0_scr_adr)
        ld (temp_s_scr_adr),hl

        ld a,(ttr_s0_scr_len)
        ld (temp_s_scr_len),a

        ld hl,tiare_s0_buf
        ld (temp_s_buf),hl
        ret
.l1:
;draw to scr1
        ld a,(ttr_s1_buf_status)
        ld (temp_s_buf_status),a

        ld hl,(ttr_s1_scr_adr)
        ld (temp_s_scr_adr),hl

        ld a,(ttr_s1_scr_len)
        ld (temp_s_scr_len),a

        ld hl,tiare_s1_buf
        ld (temp_s_buf),hl
        ret


store_draw_vars:
        ld a,(active_scr)
        and a
        jr z,.l1
;---draw to scr 0
        ld a,(temp_s_buf_status)
        ld (ttr_s0_buf_status),a
        ld hl,(temp_s_scr_adr)
        ld (ttr_s0_scr_adr),hl
        ld a,(temp_s_scr_len)
        ld (ttr_s0_scr_len),a
        ret
.l1:
;draw to scr1
        ld a,(temp_s_buf_status)
        ld (ttr_s1_buf_status),a
        ld hl,(temp_s_scr_adr)
        ld (ttr_s1_scr_adr),hl
        ld a,(temp_s_scr_len)
        ld (ttr_s1_scr_len),a

        ret

;star mover

tiare_star_lnm_a:
        ld a,8
        ld (_m_tiare_hgt),a   ;set tiare buf height        
        ret
tiare_star_lnm:
        ld hl,tiare_star_lnm_a
        push hl 
       
        xor a
        ld (ttr_s0_buf_status),a
        ld (ttr_s1_buf_status),a
        ld (ttr_timer),a

        ld a,16
        ld (_m_tiare_hgt),a   ;set tiare buf height


        ld hl,tiare_star_route


;delay with halt
.srt_loop1:
        ld a,(ttr_timer)
        and a
        jr z,.srt_c1
        halt
        dec a
        ld (ttr_timer),a
        jr .srt_loop1

.srt_c1:
        
        ld a,(hl)
        cp 0xff
        jp z,force_scr0      ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                             ;оґ¦о¬ вґ¤ж° force_scr0

        ld (ttr_timer),a
        
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl)

;change  x coord to even but keep in mind it's odd
        ld a,e
        and 1
        ld (ttr_sprfaze),a
        ld a,e
        and 0xfe
        ld e,a          

        push hl
            and a
            ld hl,320
            sbc hl,de
            ld a,l
            ld b,24
            cp b
            jr c,.srl_tt
            ld a,b
.srl_tt:
            srl a
            ld (ttr_sprlen),a ;sprite len divided by 2 because it draw by 2 pixels at once
        pop hl



        inc hl
        ex de,hl
        call p_calc_x
        ex de,hl
        
        ld a,(hl)
        inc hl
        ex de,hl
        call p_calc_y_fast
        ex de,hl
;now de = addr to draw sprite
;    hl- pointer to next sprite position 
        push hl
        push de
        call set_draw_scr   ;set alternative screen pages in 0x8000-0xffff
        call set_draw_vars

    
;select buffer   active_scr==0 
        ld a,(temp_s_buf_status)
        and a
        call nz,restore_s_buffer        ;//restore screen from buffer

        pop de
        push de
        call store_new_buff


        pop de
        call draw_tiare_sprite

        ;=== here we shouild switch screens
        halt
        ld a,(active_scr)
        and a
        jr nz,.spl1
        
        ; active scr 0 ; show 2nd screen . set active scr1
        inc a
        ld (active_scr),a
        ld e,a
        OS_SETSCREEN
        jr .spl0
.spl1:        
        ; active scr 1 ; show 1nd screen . set active scr 0
        dec a
        ld (active_scr),a
        ld e,a
        OS_SETSCREEN
.spl0


        pop hl
        jp .srt_loop1



draw_tiare_sprite:
        ld a,(ttr_sprfaze)
        ld hl,tiare_p1_spr
        and a
        jr z,_d_al
        ld hl,tiare_p2_spr
_d_al
        ex de,hl
        ld a,(ttr_sprlen)


_draw_custom_spr:
         ld b,a
_d_inner_lp1
        push bc
        push hl

        ld b,8
_m_tiare_hgt: equ $-1
_d_inner_lp2
        call _iob_byte
        inc de
        call DHL
        djnz _d_inner_lp2
        pop hl
        call p_nextcolumn
        pop bc
        djnz _d_inner_lp1
        ret


store_new_buff:
        ld hl,(temp_s_buf)
        ex de,hl
        
        ld (temp_s_scr_adr),hl

        ld a,(ttr_sprlen)
        ld (temp_s_scr_len),a

        call _store_custom_spr

        ld a,1
        ld (temp_s_buf_status),a
        jp store_draw_vars



_store_custom_spr:
         ld b,a
_e_inner_lp1
        push bc
        push hl


        ld b,16
_e_inner_lp2
        ld a,(hl)
        ld (de),a
        inc de
        call DHL
        djnz _e_inner_lp2
        pop hl
        call p_nextcolumn
        pop bc
        djnz _e_inner_lp1         
        ret


restore_s_buffer:
        ld de,(temp_s_buf)
        ld hl,(temp_s_scr_adr)
        ld a,(temp_s_scr_len)


_restore_custom_spr:        
         ld b,a
_m_inner_lp1
        push bc
        push hl


                ld b,16
_m_inner_lp2
                ld a,(de)
                ld (hl),a
                inc de
                call DHL
                djnz _m_inner_lp2
        pop hl
        call p_nextcolumn
        pop bc
        djnz _m_inner_lp1
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

        align 256
tx
        dup 256
        db ($&0xff)/4
        edup
        dup 64
        db 0x80
        db 0xc0
        db 0xa0
        db 0xe0
        edup
ty
        dup 200
        db 0xff&(($&0xff)*40)
        edup
        ds 56,0xff&8000
        dup 200
        db (($&0xff)*40)/256
        edup
        ds 56,8000/256


        align 256
titles:
                db 1
                db "ZX SPECTRUM VERSION",1
                db " NedoOS adaptation",1
                db 2,1
                db "      ZORBA (2024)",1
                db 2,6
                db "  TSFM MUSIC PLAYER",1
                db 2,1
                db "    NEO SPECTRUMAN",1
                db 2,6

                db "   OPL3 PLAYER FOR ",1
                db "    ZXM-MOONSOUND  ",1
                db 2,1
                db "       GALSTAFF",1
                db 2,6

                db "   MIDI PLAYER FOR ",1
                db "    ZXM-MOONSOUND  ",1
                db 2,1
                db "        ZORBA",1
                db 2,6

                db "   ORIGINAL CREDITS",1
                db 2,3
                db "      DIRECTOR",1
                db 2,1
                db " TAIZO THE DESTROYER",1
                db 2,6
                db "  ORIGINAL ARTWORK",1
                db 2,1
                db "   ISSHIKI RYOTARO",1
                db 2,6
                db "    ART DIRECTOR",1
                db 2,1
                db "    OSHIMA SANAGI",1
                db 2,6
                db "      GRAPHICS",1
                db 2,1
                db "      USA USAGI",1
                db " YUMILIN",1
                db "      (NOT REAL NAME)",1
                db "      IZAWA SAYA",1
                db "        CURLY",1
                db 2,6
                db "       ASSISTANT",1
                db 2,1
                db "         OGURO",1
                db 2,6
                db "       SCENARIO",1
                db 2,1
                db "     SHISHA KAORU",1
                db "   PROFESSOR",1
                db "        COMPRESSION",1
                db "      KONNO NAOZO",1
                db 2,6
                db "        MUSIC",1
                db 2,1
                db "    TAKANORI",1 
                db "          NAKAIGAWA",1
                db 2,6
                db "       PROGRAM",1
                db 2,1
                db " TAIZO THE DESTROYER",1
                db 2,6
                db "      THANKS TO",1
                db 2,1
                db "         EIWA",1
                db " TECHINICAL SERVICE",1
                db 2,6
                db " ENGLISH TRANSLATION",1
                db 2,1
                db " TOTORO",1
                db "      HUNTER LETO II",1
                db "   SLAVE IN AMERICA",1
                db "     MOTENAI YODA",1
                db 2,6
                db "       PLANNING",1
                db "    & DEVELOPMENT",1
                db 2,1
                db "         JAST",1
                db 2,25
                db 3
titles_end:
title_len equ titles_end-titles

        align 256
tiare_p1_spr:     ds 256,0
tiare_p2_spr:     ds 256,0
tiare_s0_buf:        ds 256,0
tiare_s1_buf:        ds 256,0

l_dell    equ  0    ;linear delay  298-212
l_dell1   equ 1
l_dell2   equ 2
l_dell3   equ 3
l_dell4   equ 4


tiare_star_route:  ;delay,xx,y
                    db l_dell
                    dw 300
                    db 0
                    db l_dell
                    dw 298
                    db 1
                    db l_dell
                    dw 296
                    db 2
                    db l_dell
                    dw 294
                    db 3
                    db l_dell
                    dw 292
                    db 4
                    db l_dell
                    dw 290
                    db 5
                    db l_dell
                    dw 288
                    db 6
                    db l_dell
                    dw 286
                    db 7
                    db l_dell
                    dw 284
                    db 8
                    db l_dell
                    dw 282
                    db 9
                    db l_dell
                    dw 280
                    db 10
                    db l_dell
                    dw 278
                    db 11
                    db l_dell
                    dw 276
                    db 12
                    db l_dell
                    dw 274
                    db 13
                    db l_dell
                    dw 272
                    db 14
                    db l_dell
                    dw 270
                    db 15
                    db l_dell
                    dw 268
                    db 16
                    db l_dell
                    dw 266
                    db 17
                    db l_dell
                    dw 264
                    db 18
                    db l_dell
                    dw 262
                    db 19
                    db l_dell
                    dw 260
                    db 20
                    db l_dell
                    dw 258
                    db 21
                    db l_dell
                    dw 256
                    db 22
                    db l_dell
                    dw 254
                    db 23
                    db l_dell
                    dw 252
                    db 24
                    db l_dell
                    dw 250
                    db 25
                    db l_dell
                    dw 248
                    db 26
                    db l_dell
                    dw 246
                    db 27
                    db l_dell
                    dw 244
                    db 27
                    db l_dell
                    dw 242
                    db 29
                    db l_dell
                    dw 240
                    db 30
                    db l_dell
                    dw 238
                    db 31
                    db l_dell
                    dw 236
                    db 32
                    db l_dell
                    dw 234
                    db 33
                    db l_dell
                    dw 232
                    db 34
                    db l_dell
                    dw 230
                    db 35
                    db l_dell
                    dw 228
                    db 36
                    db l_dell
                    dw 226
                    db 37
                    db l_dell
                    dw 224
                    db 38
                    db l_dell
                    dw 222
                    db 39
                    db l_dell
                    dw 220
                    db 40
                    db l_dell
                    dw 218
                    db 41
                    db l_dell
                    dw 216
                    db 42
                    db l_dell
                    dw 214
                    db 43
                    db l_dell
                    dw 212
                    db 44


                    db l_dell1
                    dw 211
                    db 45
                    db l_dell1
                    dw 210
                    db 46
                    db l_dell1
                    dw 209
                    db 47
                    db l_dell1
                    dw 207
                    db 48
                    db l_dell1
                    dw 206
                    db 49
                    db l_dell1
                    dw 205
                    db 50
                    db l_dell1
                    dw 204
                    db 51
                    db l_dell1
                    dw 203
                    db 52
                    db l_dell1
                    dw 202
                    db 53
                    db l_dell1
                    dw 201
                    db 54
                    db l_dell1
                    dw 201
                    db 55

                    db l_dell2
                    dw 200
                    db 56
                    db l_dell2
                    dw 199
                    db 57
                    db l_dell2
                    dw 198
                    db 58
                    db l_dell2
                    dw 198
                    db 59
                    db l_dell2
                    dw 197
                    db 60
                    db l_dell2
                    dw 196
                    db 61
                    db l_dell2
                    dw 196
                    db 62
                    db l_dell2
                    dw 195
                    db 63
                    db l_dell2
                    dw 195
                    db 64


                    db l_dell3
                    dw 194
                    db 65
                    db l_dell3
                    dw 194
                    db 66
                    db l_dell3
                    dw 194
                    db 67
                    db l_dell3
                    dw 193
                    db 68
                    db l_dell3
                    dw 193
                    db 69
                    db l_dell3
                    dw 193
                    db 70
                    db l_dell3
                    dw 192
                    db 71
                    db l_dell3
                    dw 192
                    db 72
                    db l_dell3
                    dw 192
                    db 73


                    db l_dell4
                    dw 191
                    db 74
                    db l_dell4
                    dw 191
                    db 75
                    db l_dell4
                    dw 191
                    db 76
                    db l_dell4
                    dw 191
                    db 77
                    db l_dell4
                    dw 191
                    db 78


                    db l_dell4
                    dw 190
                    db 79
                    db l_dell4
                    dw 190
                    db 80
                    db l_dell4
                    dw 190
                    db 81
                    db l_dell4
                    dw 190
                    db 82
                    db l_dell4
                    dw 190
                    db 83
                    db l_dell4
                    dw 190
                    db 84
                    db l_dell4
                    dw 190
                    db 85

                    db l_dell4
                    dw 191
                    db 86
                    db l_dell4
                    dw 191
                    db 87
                    db l_dell4
                    dw 191
                    db 88

                    db l_dell4
                    dw 192
                    db 89
                    db l_dell4
                    dw 192
                    db 90


                    db 0xff




leaf_spr:           ds 1024,0

leaf_table          dw leaf_spr
                    dw leaf_spr+32*1
                    dw leaf_spr+32*2
                    dw leaf_spr+32*3
                    dw leaf_spr+32*4
                    dw leaf_spr+32*5
                    dw leaf_spr+32*6
                    dw leaf_spr+32*7
                    dw leaf_spr+32*8
                    dw leaf_spr+32*9
                    dw leaf_spr+32*10
                    dw leaf_spr+32*11
                    dw leaf_spr+32*12
                    dw leaf_spr+32*13
                    dw leaf_spr+32*14
                    dw leaf_spr+32*15
                    dw leaf_spr+32*16
                    dw leaf_spr+32*17
                    dw leaf_spr+32*18
                    dw leaf_spr+32*19

max_leaf_count       equ 20
leaf_s0_buf_status:  ds max_leaf_count,0
leaf_s0_buf_scr_addr:  ds max_leaf_count*2,0





;leaf work table for [leaf_count] 20 leafs
;struct
;   0    x - position 0 - 155 ( * 2 actually so it will be 0-311)
;   1    y - position  (0 - limit-8)  limit 200 or less
;   2    direction   + speed   left 0 -down  <0 left >0 right
;   3    index of current sprite (to use on leaf_table)
;   4    speed y
;   5    distance 1-4
;   6    distance generated 1-4
;   7    direction   + speed   generated 
;   8    time to change sprite fase
;   9    2*reserved
;
;
;
leaf_data_table ds max_leaf_count*10,0








                align 256
;in
;a = 0  single screen draw  a=1 based on active_scr variable (with shadow screen)
;b - petals max y coord
;c - petals max X coord

leaf_init:
                ld a,b
                ld (leaf_y_limit),a


                ld a,c
                ld (.leaf_x_limit_gen),a
                ld (_ere_petals_x_limit),a

                ;make copy of current screen to have scr restoration data

                call store8000c000
                call copy_scr0_scr1
                call restore8000c000


; regenerate x positions table for petals with x coord limitations
                     ld hl,x_coord_tbl
                     ld b,0 
                     ld d,157
.leaf_x_limit_gen:      equ $-1

.ll_a1:                 call randr
                        cp d
                        jr nc,.ll_a1
                        ld (hl),a  ; x pos low   ;*0
                        inc hl
                     djnz    .ll_a1





                ld b,leaf_count
                ld hl,leaf_data_table

.loop1
                ;x-pos
                        ld a,(x_c_pointer)        
                        ld e,a
                        ld d,high x_coord_tbl
                        inc a
                        ld (x_c_pointer),a
                        ld a,(de)
                        ld (hl),a
                        inc hl

               ;y-pos
                        ld a,(y_c_pointer)        
                        ld e,a
                        ld d,high y_coord_tbl
                        inc a
                        ld (y_c_pointer),a
                        ld a,(de)
                        ld (hl),a
                        inc hl

                ;x-direction & speed
                        ld a,(x_s_pointer)        
                        ld e,a
                        ld d,high x_speed_tbl
                        inc a
                        ld (x_s_pointer),a
                        ld a,(de)
                        ld (hl),a
                        inc hl
                     push af   

                ;initial fase 
                        ld a,(xy_i_f_pointer)        
                        ld e,a
                        ld d,high xy_init_fase
                        inc a
                        ld (xy_i_f_pointer),a
                        ld a,(de)
                        ld (hl),a
                        inc hl

                ;y-speed  
                        ld a,(y_s_pointer)        
                        ld e,a
                        ld d,high y_speed_tbl
                        inc a
                        ld (y_s_pointer),a
                        ld a,(de)
                        ld (hl),a
                        inc hl
                ;x-moving distance
                        ld a,(x_m_dist_pointer)        
                        ld e,a
                        ld d,high x_moving_distance
                        inc a
                        ld (x_m_dist_pointer),a
                        ld a,(de)
                        ld (hl),a
                        inc hl

                        ld (hl),a   ;x-axis movind distance generated       *6
                        inc hl
                      pop af
                        ld (hl),a  ;x-direction + speed generated *7
                        inc hl


                ;time to change petal fase
                        ld a,(p_f_c_pointer)        
                        ld e,a
                        ld d,high petal_fase_change_time
                        inc a
                        ld (p_f_c_pointer),a
                        ld a,(de)
                        ld (hl),a             ;time to change sprite fase   *8
                        inc hl

                        ld (hl),0
                        inc hl

                djnz .loop1

;clear buffer status
                ld hl,leaf_s0_buf_status
                ld b,leaf_count
                xor a
.loop2                
                ld (hl),a
                inc hl
                djnz .loop2

                ret                

petals_render:
;        ld a,(_m_tiare_hgt)
;        ld (_m_storr),a

;        ld a,8        
;        ld (_m_tiare_hgt),a
        
mrei0:
        call _petals_restore_background

        ;set scr0 pages  at 8000-ffff
        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld a,(petals_key)
        cp 2
        jr z,mrei2        

mrei01:

        call _petals_draw_
        call _petals_calculate_next
mrei2
        ld a,(petals_key)
        cp 2        
        call z,petlsclearbbb


;        ld a,8
;_m_storr: equ $-1
;        ld (_m_tiare_hgt),a

        ret

petlsclearbbb:

                ld hl,leaf_s0_buf_status
                ld b,leaf_count
                xor a
.loop2                
                ld (hl),a
                inc hl
                djnz .loop2
        
        ld (petals_key),a
        ret

_petals_restore_background
        ld b,leaf_count
.lop
        push bc
                ;ld a,leaf_count
                ;sub b
                ld a,b
                dec a

                ld hl,leaf_s0_buf_status
                  ld e,a
                  ld d,0      
                  add hl,de
                ld a,(hl)
                and a
                call nz,_petals_need_restore
        pop bc
        djnz .lop
        ret



_petals_need_restore

        ld a,b
        dec a        


        ; a = current slot

          ;store screen addr from DE
          ld hl,leaf_s0_buf_scr_addr
          add a,a
          ld e,a
          ld d,0      
          add hl,de
          ld e,(hl)
          inc hl
          ld d,(hl)


        ;de = screen addr
;нужно 4 разных процедуры в зависимости от смещения по координате Х.  0 (8000) +2(c000) +4 (a000) +6(e000)

        push de
        pop hl
        bit 6,h
        
        jp nz,._is_scr1


        ;here scr0
._is_scr0:
        set 6,h
        res 6,d

        push hl,de
        call  set_scr_low.spl0
        pop de,hl

        push hl,de
        bit 5,h

        
        jr nz,._is_scr0_offs_4

._is_scr0_offs_0:
        ld b,8
.loop_sc1_0
        push bc

        ld bc,40

        ld a,(hl)
        ld (de),a
        set 5,h
        set 5,d
        ld a,(hl)
        ld (de),a
        res 5,h
        res 5,d
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl

        pop bc
        djnz .loop_sc1_0

        call  set_scr_high.spl0

        pop de,hl 

        ld b,8
.loop_sc1_1
        push bc

        ld bc,40

        ld a,(hl)
        ld (de),a
        set 5,h
        set 5,d
        ld a,(hl)
        ld (de),a
        res 5,h
        res 5,d
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl

        pop bc
        djnz .loop_sc1_1


        ret

._is_scr0_offs_4:


        ld b,8
.loop_sc4_0:
        push bc

        ld bc,40

        ld a,(hl)
        ld (de),a
        res 5,h
        res 5,d    
        inc hl,de
        ld a,(hl)
        ld (de),a
        set 5,h
        set 5,d
        dec hl,de
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl
        
        pop bc
        djnz .loop_sc4_0


        call  set_scr_high.spl0
        pop de,hl 

        ld b,8
.loop_sc4_1:
        push bc

        ld bc,40

        ld a,(hl)
        ld (de),a
        res 5,h
        res 5,d    
        inc hl,de
        ld a,(hl)
        ld (de),a
        set 5,h
        set 5,d
        dec hl,de
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl

        pop bc
        djnz .loop_sc4_1
        ret






























._is_scr1:



        set 6,h
        res 6,d

        push hl,de
        call  set_scr_high.spl0
        pop de,hl

        push hl,de
        bit 5,h

        jr nz,._is_scr0_offs_6

._is_scr0_offs_2:
        ld b,8
.loop_sc2_0
        push bc

        ld bc,40

        res 5,h
        res 5,d
        ld a,(hl)
        ld (de),a
        ;inc hl,de

        set 5,h
        set 5,d
        ld a,(hl)
        ld (de),a
       ; dec hl,de

        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl

        pop bc
        djnz .loop_sc2_0

        call  set_scr_low.spl0

        pop de,hl 

        ld b,8
.loop_sc2_1
        push bc

        ld bc,40

        set 5,h
        set 5,d
        ld a,(hl)
        ld (de),a
        inc hl,de

        res 5,h
        res 5,d        
        ld a,(hl)
        ld (de),a
        dec hl,de

        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl

        pop bc
        djnz .loop_sc2_1
        ret


._is_scr0_offs_6:

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

        ld b,8
.loop_sc3_0:
        push bc

        ld bc,40

        ld a,(hl)
        ld (de),a
        res 5,h
        res 5,d    
        inc hl,de

        ld a,(hl)
        ld (de),a
        set 5,h
        set 5,d
        dec hl,de

        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl
        
        pop bc
        djnz .loop_sc3_0


        call  set_scr_low.spl0
        pop de,hl 

        inc hl,de
        ld b,8
.loop_sc3_1:
        push bc

        ld bc,40

        res 5,h
        res 5,d    

        ld a,(hl)
        ld (de),a

        set 5,h
        set 5,d


        ld a,(hl)
        ld (de),a



        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl

        pop bc
        djnz .loop_sc3_1
        ret

_petals_x_min equ 0
_petals_x_max equ 155







_petals_calculate_next:

        ld hl,leaf_data_table
        ld b,leaf_count
_ere_lll:
        push bc
                push hl
                push hl
                pop ix

                ld a,(ix+5)     ;distance to fly. if 0 generate new parameters
                
                and a
                call z,_petals_sub_gen ;

                ld a,(ix+1)  ;check y coord
                ld b,(ix+4)  ;y-speed
                add a,b
                ld (ix+1),a

                cp 200-32  ;!!!!!!!todo vertical limit
leaf_y_limit: equ $-1
                call nc,_petals_gen_full


                ld a,(ix+8)
                and a
                jr nz,_ere_ll14

                        ld a,(p_f_c_pointer)        
                        ld e,a
                        ld d,high petal_fase_change_time
                        inc a
                        ld (p_f_c_pointer),a
                        ld a,(de)
                ld (ix+8),a
            
    
                        ld a,(xy_i_f_pointer)        
                        ld e,a
                        ld d,high xy_init_fase
                        inc a
                        ld (xy_i_f_pointer),a
                        ld a,(de)
                 ld (ix+3),a ;sprite index


_ere_ll14:
                ld a,(ix+2)   ;direction
                ld l,(ix+0)   ;x-pos
                add a,l
                ld (ix+0),a
                cp 157
_ere_petals_x_limit equ $-1
                jr c,_ere_ll13
                    ;out of bounds.change movement direction
                ld a,(ix+2)
                neg
                ld (ix+2),a
                add a,l
                ld (ix+0),a

_ere_ll13:
                dec (ix+5)  ;decrease time to change direction
                dec (ix+8)  ;decrease time to change sprite fase
                pop hl 
                ld bc,10
                add hl,bc               
        pop bc
        djnz _ere_lll
        ret


_petals_gen_full:



                        ld a,(x_c_pointer)        
                        ld e,a
                        ld d,high x_coord_tbl
                        inc a
                        ld (x_c_pointer),a
                        ld a,(de)
                        ld (ix+0),a  ; x pos low
                        ld (ix+1),0  ;y_pos        


        
_petals_sub_gen:
                        ld a,(x_s_pointer)        
                        ld e,a
                        ld d,high x_speed_tbl
                        inc a
                        ld (x_s_pointer),a
                        ld a,(de)
                        ld (ix+2),a  ;x dirction + speed
                        ld (ix+7),a  ;x dirction + speed


                        ld a,(y_s_pointer)        
                        ld e,a
                        ld d,high y_speed_tbl
                        inc a
                        ld (y_s_pointer),a
                        ld a,(de)
                        ld (ix+4),a ;speed y

                        ld a,(x_m_dist_pointer)        
                        ld e,a
                        ld d,high x_moving_distance
                        inc a
                        ld (x_m_dist_pointer),a
                        ld a,(de)
                        ld (ix+5),a ;disance
                        ld (ix+6),a ;disance
                        ret



;=============================================       
;in hl - x-adress in atm2 ega screen
;   a - y coord - 0-199
;;out hl -adress in 8000 - ffff atm2 ega screen (xy offset)
p_calc_y_fast:
                        push hl
                        
                                add a,a
        
                                ld l,a
                                ld a,0
                                adc a,0
                                ld h,a
                                ld bc,y_table
                                add hl,bc                      
                                ld c,(hl)
                                inc hl
                                ld b,(hl)
                        pop hl
                        add hl,bc
                        ret


;in a - x coord divided by 2
;out hl - hl -adress in 8000 - ffff atm2 ega screen (xy offset)

                        align 256
y_table                 dw 0,40,80,120,160,200,240,280,320,360,400,440,480,520,560,600,640,680,720,760,800,840,880,920,960,1000
                        dw 1040,1080,1120,1160,1200,1240,1280,1320,1360,1400,1440,1480,1520,1560,1600,1640,1680,1720,1760,1800,1840,1880,1920,1960,2000
                        dw 2040,2080,2120,2160,2200,2240,2280,2320,2360,2400,2440,2480,2520,2560,2600,2640,2680,2720,2760,2800,2840,2880,2920,2960,3000
                        dw 3040,3080,3120,3160,3200,3240,3280,3320,3360,3400,3440,3480,3520,3560,3600,3640,3680,3720,3760,3800,3840,3880,3920,3960,4000
                        dw 4040,4080,4120,4160,4200,4240,4280,4320,4360,4400,4440,4480,4520,4560,4600,4640,4680,4720,4760,4800,4840,4880,4920,4960,5000
                        dw 5040,5080,5120,5160,5200,5240,5280,5320,5360,5400,5440,5480,5520,5560,5600,5640,5680,5720,5760,5800,5840,5880,5920,5960,6000
                        dw 6040,6080,6120,6160,6200,6240,6280,6320,6360,6400,6440,6480,6520,6560,6600,6640,6680,6720,6760,6800,6840,6880,6920,6960,7000
                        dw 7040,7080,7120,7160,7200,7240,7280,7320,7360,7400,7440,7480,7520,7560,7600,7640,7680,7720,7760,7800,7840,7880,7920,7960,8000
                        align 256



BLINKS = 0   ;
HALFBLINKS = 1
SPARKLING = 2
SPARKLING2 = 3


eyes_table:
	DB "CT01A0",0,0
	DW 28,20       ;!!!!56-40 !
	DW 36,12
	DB 3
    DB BLINKS
	DB "CT01DA0",0
	DW 28,20           ;!!!!56-40 !
	DW 36,12
	DB 3
    DB BLINKS
	DB "CT01IA0",0
	DW 28,20           ;!!!!56-40 !
	DW 36,12
	DB 3
    DB BLINKS	
	DB "CT01KA0",0
	DW 28,20           ;!!!!56-40 !
	DW 36,12
	DB 2	
    DB SPARKLING
	DB "CT01RA0",0
	DW 28,20           ;!!!!56-40 !
	DW 36,12
	DB 3	
    DB SPARKLING
	DB "CT01VA0",0
	DW 28,16          ;!!!!56-32
	DW 36,24
	DB 3
    DB BLINKS





	DB "CT02A0",0,0
	DW 24,16          ;!!!!48-32 !
	DW 32,20
	DB 3	
    DB BLINKS                                       ;2 TIMES
	DB "CT02DA0",0
	DW 24,16          ;!!!!48-32 !
	DW 32,20
	DB 3	
    DB BLINKS
	DB "CT02IA0",0
	DW 24,20          ;!!!!48-40 !
	DW 32,16
	DB 3
    DB BLINKS
	DB "CT02KA0",0
	DW 24,20          ;!!!!48-40R !
	DW 32,16
	DB 3
    DB SPARKLING2
	DB "CT02VA0",0
	DW 24,16          ;!!!!48-32R   !
	DW 32,24
	DB 7
    DB HALFBLINKS





	DB "CT03A0",0,0
	DW 72,20           ;!!!!144-40 !
	DW 28,20
	DB 3
    DB BLINKS                   ; 1+2+1+1
	DB "CT03DA0",0
	DW 72,20           ;!!!!144-40 !
	DW 28,20
	DB 3
    DB BLINKS
	DB "CT03IA0",0
	DW 72,20           ;!!!!144-40 !
	DW 28,24
	DB 3
    DB BLINKS
	DB "CT03KA0",0
	DW 72,20           ;!!!!144-40 !
	DW 28,20
	DB 3
    DB BLINKS




	DB "CT04A0",0,0
	DW 28,20        ;!!!!56-40 !
	DW 36,12
	DB 3
    DB BLINKS
	DB "CT04DA0",0
	DW 28,20        ;!!!!56-40 !
	DW 36,12
	DB 3
    DB BLINKS
	DB "CT04IA0",0
	DW 28,20        ;!!!!56-40 !
	DW 36,20
	DB 5
    DB SPARKLING
	DB "CT04KA0",0
	DW 28,20        ;!!!!56-40 !
	DW 36,12
	DB 2
    DB SPARKLING


	DB "CT05A0",0,0
	DW 20,16               ;!!!!40-32  !
	DW 32,16               
	DB 3
    DB BLINKS
	DB "CT05DA0",0
	DW 20,16               ;!!!!40-32 !
	DW 32,16               
	DB 3
    DB BLINKS
	DB "CT05IA0",0
	DW 20,16               ;!!!!40-32 !
	DW 32,16               
	DB 4
    DB BLINKS
	DB "CT05KA0",0
	DW 20,16               ;!!!!40-32 !
	DW 32,16               
	DB 3
    DB BLINKS

	DB "CT06A0",0,0
	DW 28,16               ;!!!!56-32 !
	DW 32,20
	DB 3
    DB BLINKS
	DB "CT06DA0",0
	DW 28,16               ;!!!!56-32 !
	DW 32,20
	DB 3
    DB BLINKS
	DB "CT06KA0",0
	DW 28,16               ;!!!!56-32 !
	DW 32,20
	DB 2
    DB SPARKLING


	DB "CT07A0",0,0    
	DW 20,24            ;!!!!40-48 !
	DW 32,12
	DB 3
    DB BLINKS
	DB "CT07DA0",0
	DW 20,24            ;!!!!40-48 !
	DW 32,12
	DB 3
    DB BLINKS
	DB "CT07IA0",0
	DW 20,24            ;!!!!40-48 !
	DW 32,12
	DB 3
    DB BLINKS
	DB "CT07KA0",0
	DW 20,24            ;!!!!40-48 !
	DW 32,12
	DB 3
    DB BLINKS                    ;BLINKS DOUBLE TIMES  2+2
	DB "CT07VA0",0
	DW 20,24            ;!!!!40-48 !
	DW 32,12
	DB 3
    DB BLINKS



	DB "CT08A0",0,0
	DW 52,16               ;!!!!104-32  !
	DW 32,28
	DB 3
    DB BLINKS
	DB "CT08DA0",0
	DW 52,20               ;!!!!104-40   !
	DW 32,24
	DB 3
    DB BLINKS                                     ;BLINKS 1 TIMES
	DB "CT08IA0",0
	DW 52,20               ;!!!!104-40  !
	DW 32,24
	DB 3
    DB BLINKS
	DB "CT08KA0",0
	DW 52,24               ;!!!!104-48 !
	DW 28,20
	DB 2
    DB SPARKLING


	DB "CT09A0",0,0
	DW 60,16              ;!!!!120-32  !
	DW 28,6
	DB 3
    DB BLINKS                       ;BLINKS ONE TIME

	DB "CT10A0",0,0
	DW 20,28          ;!!!!40-56   !   
	DW 24,8
	DB 2
    DB SPARKLING           ;SPARKLINH CONSTANTLY WITHOUT DELAY

	DB "CT11A0",0,0
	DW 12,44                 ;!!!!24-88  !
	DW 32,16
	DB 3
    DB BLINKS
	DB "CT11DA0",0
	DW 12,44                 ;!!!!24-88 !
	DW 32,16
	DB 3
    DB BLINKS
	DB "CT11IA0",0
	DW 12,44                 ;!!!!24-88 !
	DW 32,16
	DB 3
    DB BLINKS
	DB "CT11KA0",0
	DW 12,44                 ;!!!!24-88 !R
	DW 32,16
	DB 2
    DB SPARKLING


	DB "CT12A0",0,0
	DW 20,16                 ;!!!!40-32  !
	DW 32,8
	DB 3
    DB BLINKS
	DB "CT12DA0",0
	DW 20,16                 ;!!!!40-32 !
	DW 32,8
	DB 3
    DB BLINKS
	DB "CT12IA0",0
	DW 20,16                 ;!!!!40-32 !
	DW 32,8    
	DB 2
    DB SPARKLING
	DB "CT12KA0",0
	DW 20,16                 ;!!!!40-32 !
	DW 32,8
	DB 2
    DB SPARKLING

	DB "CT13A0",0,0
	DW 44,20                 ;!!!!88-40 !
	DW 32,8
	DB 3
    DB BLINKS                 ;BLINKS ONE TIME
	DB "CT13DA0",0
	DW 44,20                 ;!!!!88-40 !
	DW 32,8
	DB 3
    DB BLINKS
	DB "CT13KA0",0
	DW 44,32                 ;!!!!88-64
	DW 32,12    
	DB 2
    DB BLINKS


	DB "CT14A0",0,0
	DW 40,16                 ;!!!!80-32   !
	DW 32,16
	DB 3
    DB BLINKS                                          ;BLINKS 3 + 1 TIMES
	DB "CT14DA0",0
	DW 40,16                 ;!!!!80-32   !
	DW 32,16
	DB 3
    DB BLINKS
	DB "CT14DA1",0
	DW 60,28                 ;!!!!120-56 !
	DW 12,12    
	DB 2
    DB SPARKLING
	DB "CT14IA0",0
	DW 40,20                 ;!!!!80-40 !
	DW 28,12
	DB 2
    DB SPARKLING
	DB "CT14IA1",0
	DW 48,32                 ;!!!!96-64 !R
	DW 16,8
	DB 2
    DB BLINKS
	DB "CT14KA0",0
	DW 40,20                 ;!!!!80-40 !
	DW 28,12
	DB 2
    DB SPARKLING               ;SPARKLING CONSTANTLY


	db 0xff
        align 256
x_table:
                        incbin "x_table.bin"

x_c_pointer     db 0
y_c_pointer     db 0
x_s_pointer     db 0
y_s_pointer     db 0 
xy_i_f_pointer  db 0
x_m_dist_pointer   db 0
p_f_c_pointer   db 0
                        align 256
x_coord_tbl:            ds 256,0      ;0-156
y_coord_tbl:            ds 256,0      ;0-99
x_speed_tbl:            ds 256,0      ;fd - 3
y_speed_tbl:            ds 256,0      ;1-2
xy_init_fase:           ds 256,0      ;0-19
x_moving_distance:      ds 256,0      ;1-7
petal_fase_change_time:  ds 256,0      ;1-3

/*
p_calc_x_fast:
                        push bc


                        sla a             ;

                        ld l,a
                        ld a,0
                        adc a,0
                        ld h,a

                        ld bc,x_table
                        add hl,bc                      
                        ld a,(hl)
                        inc hl
                        ld h,(hl)
                        ld l,a

                        pop bc
                        ret
*/        
page4000end: