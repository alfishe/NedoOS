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
		
_immed_big:
		call setcorepage
		call _immed_big_core
		jp 	unsetcorepage

;==================================================================

anim_wait:
        LD	A,0
        INC	A
        AND	7
        LD	(anim_wait+1),A
        RET	NZ
.push_data  = $+1      
        ld hl,PUSH_DATA_INTRO
.push_addr = $+1
        ld de,0x9e23-160

        ld a,0
.FASE    equ $-1

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
        ld a,(.FASE)
        inc a
.fases= $+1
		cp 6
        jr nz,.anim_w_skip
        xor a
.anim_w_skip:
        ld (.FASE),a

        ret

/*
anim_wait:
        LD	A,0
        INC	A
        AND	7
        LD	(anim_wait+1),A
        RET	NZ
       
        ld hl,PUSH_DATA
        ld de,0x9e23-320	;-160

        ld a,0
.FASE    equ $-1

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

        ld a,(.FASE)
        inc a
        and 7
        ld (.FASE),a

        ret
*/

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
_iob_next_b1:
        ld (hl),a; all solid. copy
_iob_next_b
        ret        


_iob_left_transparent
        ld a,0b10111000 ;
        and (hl)
        ld (hl),a
        pop af
        and 0b01000111
        or (hl)
;       ld (hl),a
        jr _iob_next_b1
_iob_right_transparent
        ld a,0b01000111
        and (hl)
        ld (hl),a
        pop af
        and 0b10111000
        or (hl)
        jr _iob_next_b1    
;======================================		
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
;=============================================

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
prcharprop_shch
        ;ld a,'Щ'
        call prcharprop_do
        ld a,255
        jr prcharprop_do
_type_p:
_type_color: equ $+2
        ld ix,0x47b8; palette 9 color
COORDS_P: equ $+1 
        ld hl,0
prcharprop_do:
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
		
;=============================
_set_box_anim_intro
		ld a,6
		ld (anim_wait.fases),a
		ld hl,PUSH_DATA_INTRO
		ld (anim_wait.push_data),hl
		ld hl,0x9e23-320
		ld (anim_wait.push_addr),hl
		ret
_set_box_anim_game:
		ld a,8
		ld (anim_wait.fases),a
		ld hl,PUSH_DATA
		ld (anim_wait.push_data),hl
		ld hl,0x9e23-160
		ld (anim_wait.push_addr),hl
		ret



_set_clear_box_intro:
	ld hl,0xda44
	ld (CLEARER_+1),hl
	LD HL,0xfa44
	ld (CLEARER2+1),hl
	ld hl,0xda44
	ld (CLEARER_A+1),hl
	LD HL,0xfa44
	ld (CLEARER2A+1),hl
	
	ld a,24
	ld (CLEARER1+1),a
	ld (CLEARER3+1),a
	ld (CLEARER1A+1),a
	ld (CLEARER3A+1),a
	ret

_set_clear_box_game:
	ld hl,0xda44-160
	ld (CLEARER_+1),hl
	LD HL,0xfa44-160	
	ld (CLEARER2+1),hl
	ld hl,0xda44-160
	ld (CLEARER_A+1),hl
	LD HL,0xfa44-160	
	ld (CLEARER2A+1),hl
	
	ld a,32
	ld (CLEARER1+1),a
	ld (CLEARER3+1),a
	ld (CLEARER1A+1),a
	ld (CLEARER3A+1),a	

	ret
	
	
_clear_textbox:
        call storec000

        ld a,(user_scr0_high)
        SETPGC000
CLEARER_ LD HL,0xda44-160      ;D080
CLEARER1 LD B,32
        XOR A
25      PUSH HL
CLEARER7 LD C,32
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
CLEARER8 LD C,32
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
CLEARER7A LD C,32
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
CLEARER8A  LD C,32
         LD (HL),A
         INC HL
         DEC C
         JR NZ,$-3
         POP HL
        LD DE,40
        ADD HL,DE
         DJNZ 25B
        
         jp restorec000	   
		 
;;;;;;;;;;;;;;;;;;;;;;
;clear mem_buf1,mem_buf2
clrsa:
			ld a,(mem_buf1)
			call clrsr
			ld a,(mem_buf2)
clrsr:
			SETPGC000
			ld hl,0xc000
			ld de,0xc001
			ld bc,16383
			ld (hl),0
			ldir
			ret
			
;---------------------------------
mask_mode db 0

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


_sprite_output_mask_no_pal:
        ld a,1
        jr _sprite_output_o
sprite_output_no_pal:
        xor a
_sprite_output_o:        
        ld (mask_mode),a
		call setcorepage
		call _sprite_output_core
		jp unsetcorepage


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
		
		
		
;----------------------------------

FLASH
		inc hl
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
        jp _print_ovl
;-----
CUR_BGND_STORE: 	ds 128,0

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
          xor  0xff ;%00010010;0xff ;XOR %00010010
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
         xor 0xff ;%00010010;0xff ;XOR %00010010
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
         xor 0xff ;%00010010;0xff ;XOR %00010010
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
         xor 0xff ;%00010010;0xff ;XOR %00010010
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

;---------------------
pre_scroll_init:
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
				ret


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





_img_to_up:
		call pre_scroll_init
        ld hl,0x8005+5920  ; second line
        ld (s_move_adr1),hl
        ld a,0
        ld (s_move_lines1),a
        ld a,148
        ld (s_move_lines2),a
        ld hl,-80  ;-40
        ld a,0x3c          ;inc a
        ld b,0x3d          ;dec a 
        jr _scr_move_ud
_img_to_down:
		call pre_scroll_init
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

;----------------------------------------------

_img_to_left:
		call pre_scroll_init
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
_img_to_right:
		call pre_scroll_init
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