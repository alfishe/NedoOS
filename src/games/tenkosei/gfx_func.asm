clear_screen:
        ld e,0
        OS_CLS
        ret

setpal_proc
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
		call setcorepage
		call _immed_big_core
		jp 	unsetcorepage
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
; _sprite_output_mask_no_pal:
        ; ld a,1
        ; jr _sprite_output_o
; sprite_output_no_pal:
        ; xor a
; _sprite_output_o:        
        ; ld (mask_mode),a

        ; ld a,(scr_buf1)
        ; ld (src_buf1),a
        ; ld a,(scr_buf2)
        ; ld (src_buf2),a

        ; jp _mb_output


_memory2_output_mask:
        ld a,1
        jr _memory2_output_o
_memory2_output:
        xor a
_memory2_output_o:        
        ld (mask_mode),a
		call setcorepage
		call _memory2_output_core
		jp unsetcorepage
		
_memory2_output_mask_nopal:
        ld a,1
        jr _memory2_output_o_nopal
_memory2_output_nopal:
        xor a
_memory2_output_o_nopal:        
        ld (mask_mode),a
		call setcorepage
		call _memory2_output_nopal_core
		jp unsetcorepage
	



_memory_output_mask:
        ld a,1
        jr _memory_output_o
_memory_output:
        xor a
_memory_output_o:        
        ld (mask_mode),a
		call setcorepage
		call _memory_output_core
		jp unsetcorepage



; _2ndscreen_output:
        ; xor a
        ; ld (mask_mode),a
        ; ld a,(user_scr1_low)
        ; ld (src_buf1),a
        ; ld a,(user_scr1_high)
        ; ld (src_buf2),a 
        ; jr _mb_output
		
_buffer_output_mask:
        ld a,1
        jr _buffer_output_o
_buffer_output
        xor a
_buffer_output_o:        
        ld (mask_mode),a 
_buffer_output_op:               
		call setcorepage
		call _buffer_output_core
		jp unsetcorepage

  
;------------------------------------------------------------------ 

_ldi_30
        ld a,(mask_mode)
        and a
        jp z,_ldi_30_noeob
_ldi_30_iob
        ex de,hl
        dup 30
        call _iob_byte
        inc hl
        inc de
        edup
        ex de,hl
        ret
_ldi_40_noeob:        
        dup 10
        ldi
        edup
_ldi_30_noeob:
        dup 30
        ldi
        edup
        ret
;----

;hl-src de-dest b,counter
_down_cpy:

        ld a,(mask_mode)
        and a
        jr nz,_down_cpy_iob
_down_cpy1:
        push bc
        ld a,(hl)
        ld (de),a
        call DHL
        ex de,hl
        call DHL
        ex de,hl
        pop bc
        djnz _down_cpy1
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
        djnz _down_cpy_iob
        ret
;------------------------------------------------------------------        
; 240x148
;left to right
;mode  ????? ;0x3d
/*
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

        halt
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

        halt
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

        jp restore8000c000*/
;------------------------------------------------------------------        
/*; 240x148
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

        jp restore8000c000*/
;------------------------------------------------------------------        
; 240x148
;top to middle and bottom to middle same time
;mode ???
/*_ud_nd:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005
        ld (_ud_nd_top),hl
        ld hl,0x8005+(147*40)
        ld (_ud_nd_btm),hl


        ld b,148/2 ;160/2
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

        jp restore8000c000*/
;------------------------------------------------------------------               
; 240x148
;from center up and down same time
;mode 0x3a
/*_dn_up:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005+(74*40)
        ld (_dn_up_top),hl
        ld hl,0x8005+(73*40)
        ld (_dn_up_btm),hl


        ld b,74 ;148/2
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

        jp restore8000c000*/
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
/*_cntsds:
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
        ret*/
;------------------------------------------------------------------        
; 240x148
;from sides left and right  to center same time 
;mode 0x39
/*_cntsds_r:
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
        halt
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
        jp _down_cpy*/

;------------------------------------------------------------------  
_pradd_p:
        LD (CORDS_P),BC
        SRL     C
        SBC     A
        AND %00100000
        LD      (.M111),A

        PUSH HL
        LD H,#80
        LD A,H
        OR 0
.M111    EQU $-1
        LD H,A

        LD A,C
        ADD A,4
        LD L,A

        push bc
        ld a,b
        and a
        jr z,.skip
        LD DE,320
.pradd_l:        
        ADD HL,DE
        DJNZ .pradd_l
.skip
        LD (COORDS_P),HL

        pop bc
        ld h,0x80
        ld l,37
        ld a,b
        and a
        jr z,.skip2
        LD DE,320
.pradd_l2:        
        ADD HL,DE
        DJNZ .pradd_l2
.skip2
        ld (COORDS_P_L),hl


        POP HL
        RET     
COORDS_P_L: DW 0

/*
_pradd_p2:
        LD (CORDS_P),BC
        SRL     C
        SBC     A
        AND %00100000
        LD      (.M111),A

        PUSH HL
        LD H,#80
        LD A,H
        OR 0
.M111    EQU $-1
        LD H,A

        LD A,C
        ADD A,4
        LD L,A

        ld a,b
        and a
        jr z,.skip
        LD DE,320
.pradd_l:        
        ADD HL,DE
        DJNZ .pradd_l
.skip
        ld de,160+320
        add hl,de
        LD (COORDS_P),HL
        ld hl,0xffff ;!!!!!!!!!!!!
        ld (COORDS_P_L),hl
        POP HL
        RET        
*/        
;------------------------------------------------------------------  

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
prcharprop_shch
        ;ld a,'Щ'
        call prcharprop_do
        ld a,255
        jr prcharprop_do

_type_p:
        ;ld ix,0x47b8; palette 16 color
        ld ix,0x47b8; palette 9 color
_type_color equ $-2   
;         exx
;         ld a,0xff
;         sub hx
;         ld h,a
;         ld a,0xff
;         sub lx
;         ld l,a
;         exx

     
        ld hl,0
COORDS_P equ $-2
prcharprop_do
;print with proportional font (any char width)
;hl=screen addr
;c=phase (even=left, odd=right pixel)
;a=char
       push hl

        call setfontpage

        ld l,a
        ld h,FONT2/256  ;propfont
        ld de,font_buf  ;chardata
;1. copy char data
;shift 1 pix right if needed
        bit 0,c
        jr z,prcharprop_copyfontnoscroll
        dup 7
        ld a,(hl)
        rrca
        ld (de),a
        inc h
        inc e
        edup
        ld a,(hl)
        rrca
        jp prcharprop_copyfontq
prcharprop_copyfontnoscroll
        dup 7
        ld a,(hl)
        ld (de),a
        inc h
        inc e
        edup
        ld a,(hl)
prcharprop_copyfontq
        ld (de),a
        inc h
        ld b,(hl) ;charwidth
        ld a,c ;phase
        add a,b
        ld ly,a ;next phase = phase + charwidth
        ld a,c ;phase
        and 1 ;phase&1
        inc a
        add a,b ;charwidth
        rra
        ld hy,a ;number of 2 pixel columns = (charwidth + (phase&1) + 1)/2

       call unsetfontpage

        ld a,(user_scr0_low) ;ok
        SETPG8000
        ld a,(user_scr0_high) ;ok
        SETPGC000

       pop hl
;hl=screen addr
;hy=number of 2 pixel columns = (charwidth + (phase&1) + 1)/2
;ly=next phase (even=left, odd=right pixel)
;2. print 2 pixel vertical line (scroll left bits 7,6 in char data)
        ld bc,40
prcharprop_columns0
        push hl
        ld de,font_buf

        dup 7
        ex de,hl
        ld a,(de)
        rl (hl) ;CY=left pixel
        jr nc,$+6
        and 0b10111000    
        or hx ;0x47 ;
        rl (hl) ;CY=right pixel
        jr nc,$+6
        and 0b01000111
        or lx ;0xb8 ;
        ld (de),a
        ex de,hl
        add hl,bc
        inc e
        edup
        ex de,hl
        ld a,(de)
        rl (hl) ;CY=left pixel
        jr nc,$+6
        and 0b10111000    
        or hx ;0x47 
        rl (hl) ;CY=right pixel
        jr nc,$+6
        and 0b01000111
        or lx ;0xb8 ;

        ld (de),a
;3. next column and loop
        pop hl
        ld d,h
        ld e,l ;this will be next screen addr if the char ends in odd column ((ly&1) = 1)
	bit 6,h
	set 6,h
	jr z,$+2+4+2+2+1
	 ld a,h
	 xor 0x60
	 ld h,a
	 and 0x20
	 jr nz,$+3
	 inc hl
        dec hy
        jp nz,prcharprop_columns0
        ld c,ly
;c=next phase (even=left, odd=right pixel)
        bit 0,c
        ;ret z
        jr z,_skpp
        ex de,hl ;old screen addr if the char ends in odd column ((ly&1) = 1)
;hl=next screen addr
;        ret



_skpp:
        push bc
        ld (COORDS_P),hl
        ld bc,(CORDS_P)
        inc c
        ld (CORDS_P),bc
        pop bc
        ret

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


        ld hl,niggapal
        ld de,pal
        ld bc,32
        ldir
        ld a,1
        ld (setpalflag),a
        halt

        jp restorec000
;;;;;;;;;;;;;;;;;;;;;;;;
_clear_textbox:
        ;ld hl,0xda44-160-320-2
        ;ld b,32+8+8
        ;LD C,32+4
        ;call clear_uni
        jp _draw_box

clear_status_bar:
        ld hl,0xc000
        ld b,8
        ld c,40
clear_uni:
        ld a,b
        ld (clear_uni_s.c2a),a
        ld (clear_uni_s.c2b),a

        ld a,c
        ld (clear_uni_s.c3a),a
        ld (clear_uni_s.c3b),a

        ld (clear_uni_s.c1a),hl
        set 5,h
        ld (clear_uni_s.c1b),hl

        call storec000


        ld a,(user_scr0_high)
        SETPGC000

        call clear_uni_s

        ld a,(user_scr0_low)
        SETPGC000

        call clear_uni_s


        jp restorec000
     

clear_uni_s:    
       LD HL,0
.c1a   equ $-2        
       LD B,0
.c2a   equ $-1     
        XOR A
.c0l:
        PUSH HL
        LD C,0
.c3a    equ $-1    
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ .c0l

        LD HL,0
.c1b:   equ $-2
        LD B,0
.c2b equ $-1   
        XOR A
.c1l:   PUSH HL
        LD C,0
.c3b equ $-1
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ .c1l
        ret
 
;----------------------------------------------------
_draw_menu_box:
        push hl
        ld a,(user_scr0_low) ;ok
        SETPG8000
        ld a,(user_scr0_high) ;ok
        SETPGC000

        ld l,64
        ld e,140
        ld hx,0b11001001 ;fill color byte 0bRLrrrlll
        ld lx,0b00000000 ;11111111 ;brush color byte 0bRLrrrlll
        ld b,0 ;hgt-1
__d_m_box_hgt: equ $-1
        ld c,0 ;wid/2
__d_m_box_len: equ $-1

;l=x/2
;e=y
;lx=brush color byte 0bRLrrrlll
;hx=fill color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        call drawwindow
        pop hl
        ret
;----------------------------------------------------
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
;e=y (не портитс€)
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
      
;----------------------------------------------
_pre_setup
        ; ld a,(hl);string length
        ld a,(hl)
        ld (_line_lenght),a

                inc a
                inc a

                add a,a 
                add a,a
                ;add a,a

                dec a
        ld (__d_m_box_len),a

        inc hl 

        ld a,(hl)
        ld (DOWN_LIMIT),a

                inc a
                inc a
                add a,a ;x2
                add a,a ;x4
                add a,a ;x8
                dec a
                ld  (__d_m_box_hgt),a

        inc hl 
        push hl
        xor a
        ld (CUR_POS),a
        LD HL,#1219
        LD (_mnpos),HL
        pop hl
        ret
;----------------------------------------------------
_prt_menu
        ld bc,0
_mnpos: equ $-2        
        call _pradd_p
.m1:
        ld a,(hl)
        inc hl
        and a
        RET Z
        cp 1
        JR Z,.m2
        PUSH HL
        CALL _type_p
        POP HL
        JR .m1
.m2:
        LD A,(_mnpos+1)
        INC A
        LD (_mnpos+1),A
        JR _prt_menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_sel_menu:
        ld a,0
CUR_POS EQU $-1 

        ld hl,MENUCURHELPER_MAINMNU
        call sel_word
        ld (SELS4),hl

        call show_hand
;         ld hl,0xD691 ;+320+160   ;- left top corner of menus
;         and a 
;         jr z,_sel_m_skip_c
;         ld bc,320
; _sel_menu_clc:
;         add hl,bc
;         dec a
;         jr nz,_sel_menu_clc
; _sel_m_skip_c:
;        ld (SEL_S),hl

;        call _highlight_selected
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
        ld hl,(SELS4)
  ;      call _highlight_selected        
        call restore_hand
        ld hl,CUR_POS
        ld a,(hl)
        cp 0
DOWN_LIMIT EQU $-1        
        jp nc,_sel_menu
        inc (hl)
        jp _sel_menu

_sel_move_up
        ld hl,(SELS4)
;        call _highlight_selected        
        call restore_hand
        ld hl,CUR_POS
        ld a,(hl)
        and a
        jp z,_sel_menu
        dec (HL)
        jp _sel_menu
_sel_sel_key:
        ld hl,(SELS4)
;        call _highlight_selected
        call restore_hand
        ld a,(CUR_POS)
        ret

_sel_esc_key:
SEL_L   
        ld hl,(SELS4)
;        call _highlight_selected
        call restore_hand
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
          xor %00010010;0xff ;XOR %00010010
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
         xor %00010010;0xff ;XOR %00010010
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
         xor %00010010;0xff ;XOR %00010010
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
         xor %00010010;0xff ;XOR %00010010
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

        ld hl,0xd680-320
        ld de,0x8000
        ld bc,320*8
        ldir

        ld hl,0xf680-320
        ld bc,320*8
        ldir


        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0xd680-320
        ld bc,320*8
        ldir

        ld hl,0xf680-320
        ld bc,320*8
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
        ld de,0xd680-320
        ld bc,320*8
        ldir

        ld de,0xf680-320
        ld bc,320*8
        ldir

        ld a,(user_scr0_high)
        SETPGC000
        ld de,0xd680-320
        ld bc,320*8
        ldir

        ld de,0xf680-320
        ld bc,320*8
        ldir
        call restore8000c000        
        pop hl
        pop af
        ret
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

        call store8000c000

        ld a,(user_scr0_low)
        SETPG8000

        ld a,(user_scr0_high)
        SETPGC000

        
        ld hl,PUSH_DATA
        ld de,0x9e23-160+1

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
      
        ld b,1
        ld c,8
        call export_cursor_uni 


;         push hl
;         ld b,8
; export_push_iloop1:
;         ld a,(de)
;         ld (hl),a
;         call DHL
;         inc de
;         djnz export_push_iloop1
;         pop hl

;         set 6,H
;         push hl
;         ld b,8
; export_push_iloop2:
;         ld a,(de)
;         ld (hl),a
;         call DHL
;         inc de
;         djnz export_push_iloop2
;         pop hl

;         res 6,H
;         set 5,H

;         push hl
;         ld b,8
; export_push_iloop3:
;         ld a,(de)
;         ld (hl),a
;         call DHL
;         inc de
;         djnz export_push_iloop3
;         pop hl

;         set 6,H

;         ld b,8
; export_push_iloop4:
;         ld a,(de)
;         ld (hl),a
;         call DHL
;         inc de
;         djnz export_push_iloop4
dbbg:
        ld a,(FASE)
        inc a
                ;and 7
        cp 6
        jr nz,export_push_iloop6      
        xor a
export_push_iloop6:
        ld (FASE),a

        jp restore8000c000
;----------------------------- 
import_cursor_uni:
        ld b,2    ;2х8
.l0:
        push bc


        push hl
        ld b,16
.l1:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz .l1
        pop hl

        set 6,H
        push hl
        ld b,16
.l2:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz .l2
        pop hl

        res 6,H
        set 5,H

        push hl
        ld b,16
.l3:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz .l3
        pop hl

        set 6,H
        push hl
        ld b,16
.l4:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz .l4
        pop hl

        res 6,H
        res 5,H
        inc hl

        pop bc
        djnz .l0
        ret
;-----------------------------
export_cursor_uni:
       ;b - columns
       ;c - lines 
       ;ld b,2
.lp0:
        push bc

        push hl
        ld b,c;16
.lp1:
        call _iob_byte
        call DHL
        inc de
        djnz .lp1
        pop hl
        set 6,H

        push hl
        ld b,c;16
.lp2:
        call _iob_byte
        call DHL
        inc de
        djnz .lp2
        pop hl
        res 6,H
        set 5,H

        push hl
        ld b,c;16
.lp3:
        call _iob_byte
        call DHL
        inc de
        djnz .lp3
        pop hl
        set 6,H
        
        push hl
        ld b,c;16
.lp4:
        call _iob_byte
        call DHL
        inc de
        djnz .lp4

        pop hl
        res 6,H
        res 5,H
        inc hl

        pop bc
        djnz .lp0
        ret
;-----------------------------
restore_hand:
        call store8000c000
        push hl,bc,de

        ld a,(user_scr0_low)
        SETPG8000

        ld a,(user_scr0_high)
        SETPGC000

        ld de,CUR_BGND_STORE
        
        ld hl,(SELS4)
        ld b,2
        ld c,16



.lp0:
        push bc

        push hl
        ld b,c;16
.lp1:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz .lp1
        pop hl
        set 6,H

        push hl
        ld b,c;16
.lp2:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz .lp2
        pop hl
        res 6,H
        set 5,H

        push hl
        ld b,c;16
.lp3:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz .lp3
        pop hl
        set 6,H
        
        push hl
        ld b,c;16
.lp4:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz .lp4

        pop hl
        res 6,H
        res 5,H
        inc hl

        pop bc
        djnz .lp0



        pop de,bc,hl        
        jp restore8000c000  
  
show_hand:
; hl - sprite position

        call store8000c000

        push hl,bc,de

        ld a,(user_scr0_low)
        SETPG8000

        ld a,(user_scr0_high)
        SETPGC000

        
        ld de,CUR_BGND_STORE

        push hl        
        call import_cursor_uni
        pop hl
    
        ld de,CUR_DATA
        ;hl - cursor screen addr
        ;de - cursor data
        ld b,2
        ld c,16
        call export_cursor_uni  



        pop de,bc,hl 

        jp restore8000c000


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
_scr_move_
        ;TODO
        ;prepare screen
        ;*** copy screen to second screen
        call store8000c000
                xor a
                ld (mask_mode),a 

                ld a,(user_scr0_low)
                SETPG8000
                ld a,(user_scr1_low)
                SETPGC000

                ld hl,0x8000
                ld de,0xc000
                ld bc,8000
                ldir
                ld hl,0xa000
                ld de,0xe000
                ld bc,8000
                ldir

                ld a,(user_scr0_high)
                SETPG8000
                ld a,(user_scr1_high)
                SETPGC000

                ld hl,0x8000
                ld de,0xc000
                ld bc,8000
                ldir
                ld hl,0xa000
                ld de,0xe000
                ld bc,8000
                ldir

        
        xor a
        ld (active_scr),a


        ld a,(_todown_y)
        and a
        jp nz,_scr_move_down
        ld a,(_toup_y)
        and a
        jp nz,_scr_move_up
        ld a,(_toright_x)
        and a
        jp nz,_scr_move_right
        ld a,(_toleft_x)
        and a
        jp nz,_scr_move_left
        ret
active_scr:   db 0     ;экран который отображаетс€ (запись идЄт на второй экран)

;b - counter vert lines
;hl - source (loaded scr)
;de - dest  (scr) (mention about +320 vert offset)
set_scr_low:
        ld a,(active_scr)
        and a
        jr nz,.spl1
          ld a,(user_scr1_low)  ;ld a,(user_scr1_low)
         SETPGC000
         ret
.spl1:
        ld a,(user_scr0_low)
        SETPGC000
        ret

set_scr_high:
        ld a,(active_scr)
        and a
        jr nz,.spl1
          ld a,(user_scr1_high) ;ld a,(user_scr1_high)
         SETPGC000
         ret
.spl1:
        ld a,(user_scr0_high)
        SETPGC000
        ret


copy_i_line:
.lp:
        ld a,b
        and a
        ret z
        push bc

        call _ldi_30

        ld bc,10
        add hl,bc

        ex de,hl
        add hl,bc
        ex de,hl

        pop bc 

        djnz .lp
        ret     







s_move_adr1:  dw 0

s_move_lines1: db 0
s_move_lines2: db 0
;--------------------------------------------------
_scr_move_up:
        ld hl,0x8005+5920; second line
        ld (s_move_adr1),hl
        ld a,0
        ld (s_move_lines1),a
        ld a,148
        ld (s_move_lines2),a
        ld hl,-80  ;-40
        ld a,0x3c          ;inc a
        ld b,0x3d          ;dec a 
        jr _scr_move_ud

;------
_scr_move_down:
        ;init
        ld hl,0x8005; second line
        ld (s_move_adr1),hl
        ld a,148
        ld (s_move_lines1),a
        ld a,0
        ld (s_move_lines2),a
        ld hl,80 ;40
        ld a,0x3d          ;dec a
        ld b,0x3c          ;inc a
_scr_move_ud:        
        ld (.offs40),hl
        ld (.sp_opc1-1),a
        ld (.sp_opc1),a
        ld a,b
        ld (.sp_opc2-1),a
        ld (.sp_opc2),a
                ;ld hl,0xc005+320 всегда!!!
        ld b,148/2+1 ;149
.lp0:
        push bc

                        call set_scr_low



                        ld a,(mem_buf1)
                        SETPG8000
                        

                        
                        ld hl,(s_move_adr1)
                        ld de,0xc005+320         ;screen

                        ld a,(s_move_lines1)
                        ld b,a
                        push hl,de
                        call copy_i_line
                        pop de,hl

                        set 5,h
                        set 5,d

                        ld a,(s_move_lines1)
                        ld b,a
                        call copy_i_line

                        push de
                        ld a,(mem_buf3)
                        SETPG8000                        
                        ld hl,0xa005   ;always -begin of secondimage
                        pop de

                        ld a,(s_move_lines2)
                        ld b,a
                        push hl,de
                        call copy_i_line
                        pop de,hl

                        res 5,h
                        res 5,d

                        ld a,(s_move_lines2)
                        ld b,a
                        call copy_i_line




                        call set_scr_high



                        ld a,(mem_buf2)
                        SETPG8000
                        
                        ld hl,(s_move_adr1)
                        ld de,0xc005+320         ;screen
                        ld a,(s_move_lines1)
                        ld b,a

                        push hl,de

                        call copy_i_line

                        pop de,hl
                        set 5,h
                        set 5,d

                        ld a,(s_move_lines1)
                        ld b,a
                        call copy_i_line

                        push de

                        ld a,(mem_buf4)
                        SETPG8000                        


                        ld hl,0xa005
                        pop de
                        ld a,(s_move_lines2)
                        ld b,a

                        push hl,de
                        call copy_i_line
                        pop de,hl
                        res 5,h
                        res 5,d

                        ld a,(s_move_lines2)
                        ld b,a
                        call copy_i_line




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
        

        ld a,(s_move_lines1)
        dec a
        dec a
.sp_opc1: equ $-1        
        ld (s_move_lines1),a
        ld a,(s_move_lines2)
        inc a
        inc a
.sp_opc2: equ $-1        
        ld (s_move_lines2),a


        ld hl,(s_move_adr1)
        ld bc,40
.offs40 equ $-2        
        add hl,bc
        ld (s_move_adr1),hl


        pop bc

        dec b
        jp nz,.lp0
               
        
eerrr0
        ld a,(active_scr)
        and a 
        jr  z,.spl11
        ;copy scr1 to scr0

        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr1_low)
        SETPGC000
        ld b,148
        ld hl,0xc005+320
        ld de,0x8005+320
        call copy_i_line

        ld b,148
        ld hl,0xe005+320
        ld de,0xa005+320
        call copy_i_line

        ld a,(user_scr0_high)
        SETPG8000
        ld a,(user_scr1_high)
        SETPGC000

        ld b,148
        ld hl,0xc005+320
        ld de,0x8005+320
        call copy_i_line

        ld b,148
        ld hl,0xe005+320
        ld de,0xa005+320        
        call copy_i_line

.spl11:
        ld e,0
        OS_SETSCREEN

        jp restore8000c000        



s_move_base_src: dw 0

copy_h_line:

        ld a,b
        and a
        ret z

        push de,bc

        ld a,40
        sub b   
        ld b,a

        push hl,de

        ld hl,_ldi_40_noeob
        add a,a
        ld d,0
        ld e,a
        add hl,de
        ld (._ldi_routine),hl

        ld a,b
        ld (.mnoffs),a

        pop de,hl



        ld b,148
.inl:        
        push bc
        ld bc,.inl_r
        push bc  ;
        jp 0
._ldi_routine    equ $-2

.inl_r: 
        ld bc,10
.mnoffs:  equ $-2
        add hl,bc

        ex de,hl
        add hl,bc
        ex de,hl



        pop bc
        djnz .inl

        pop bc,hl
        ld c,b
        ld b,0
        add hl,bc
        ex de,hl 

        ret


;--------------------------------------------------
_scr_move_left:
        ld hl,0x8005+18  ; 
        ld (s_move_base_src),hl ;src


        ld a,12 ;+1 
        ld (s_move_lines1),a
        ld a,148/8  ;8 pixels per move
        ld (s_move_lines2),a

        ld hl,-1
        ld a,0x3c          ;inc a
        ld b,0x3d          ;dec a
        jr _scr_move_lr        
_scr_move_right:
        ;a = vert counter

        ld hl,0x8005  ; 
        ld (s_move_base_src),hl ;src


        ld a,240/8 ;+1 
        ld (s_move_lines1),a
        ld a,0  ;8 pixels per move
        ld (s_move_lines2),a

        ld hl,1
        ld a,0x3d          ;dec a
        ld b,0x3c          ;inc a

_scr_move_lr:        
        ld (.offs40),hl
        ld (.sp_opc1),a
        ld a,b
        ld (.sp_opc2),a


        ld b,148/8+1
.lp0:        
        push bc

                call set_scr_low

                ld a,(mem_buf1)
                SETPG8000

                ld de,0xc005+320   ;0xc005 +320 for real
                ld hl,(s_move_base_src)

                ld a,(s_move_lines1)
                ld b,a
                push hl,de
                call copy_h_line
                pop de,hl


                set 5,h
                set 5,d

                ld a,(s_move_lines1)
                ld b,a
                call copy_h_line


                        push de
                        ld a,(mem_buf3)
                        SETPG8000                        
                        ld hl,0xa005   ;always -begin of secondimage
                        pop de

                        ld a,(s_move_lines2)
                        ld b,a
                        push hl,de
                        call copy_h_line
                        pop de,hl

                        res 5,h
                        res 5,d

                        ld a,(s_move_lines2)
                        ld b,a
                        call copy_h_line


                        call set_scr_high



                        ld a,(mem_buf2)
                        SETPG8000
                        
                        ld hl,(s_move_base_src)
                        ld de,0xc005+320         ;screen
                        ld a,(s_move_lines1)
                        ld b,a

                        push hl,de

                        call copy_h_line

                        pop de,hl
                        set 5,h
                        set 5,d

                        ld a,(s_move_lines1)
                        ld b,a
                        call copy_h_line

                        push de

                        ld a,(mem_buf4)
                        SETPG8000                        


                        ld hl,0xa005
                        pop de
                        ld a,(s_move_lines2)
                        ld b,a

                        push hl,de
                        call copy_h_line
                        pop de,hl
                        res 5,h
                        res 5,d

                        ld a,(s_move_lines2)
                        ld b,a
                        call copy_h_line


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
        

        ld a,(s_move_lines1)
        dec a
.sp_opc1: equ $-1        
        ld (s_move_lines1),a
        ld a,(s_move_lines2)
        inc a
.sp_opc2: equ $-1        
        ld (s_move_lines2),a


        ld hl,(s_move_base_src)
        ld bc,1
.offs40 equ $-2        
        add hl,bc
        ld (s_move_base_src),hl


        pop bc

        dec b
        jp nz,.lp0
               
        

        ld a,(active_scr)
        and a 
        jr  z,.spl11
        ;copy scr1 to scr0

        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr1_low)
        SETPGC000
        ld b,148
        ld hl,0xc005+320
        ld de,0x8005+320
        call copy_i_line

        ld b,148
        ld hl,0xe005+320
        ld de,0xa005+320
        call copy_i_line

        ld a,(user_scr0_high)
        SETPG8000
        ld a,(user_scr1_high)
        SETPGC000

        ld b,148
        ld hl,0xc005+320
        ld de,0x8005+320
        call copy_i_line

        ld b,148
        ld hl,0xe005+320
        ld de,0xa005+320        
        call copy_i_line

.spl11:
        ld e,0
        OS_SETSCREEN

        jp restore8000c000        


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
        ld hx,0b00001001 ;0b00000000 ;0b00001001;0b00111111 ;fill color byte 0bRLrrrlll
_draw_box_color: equ $-1
        ld lx,0b00000000 ;0b00001001 ;0b00000000 ;11111111 ;brush color byte 0bRLrrrlll
        ld b,44-2 ;hgt-1
        ld c,142 ;0 ;wid/2


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
