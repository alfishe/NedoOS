	MODULE intro
ri_start:


		DISP T_START



		call clear_loc_screen
		
		
		
		ld hl,blackpal
		ld de,pal
		ld bc,32
		ldir
		ld a,1
		ld (setpalflag),a
		halt

		ld hl,9+74*40+0xc000
		ld (screen_adr_img),hl
		ld a,0x94
		call load_image
		call display_image_from_buffer

		ld hl,mempal
		ld de,pal
		ld bc,32
		ldir 
		call fade_fromblack
		xor a
		call load_mus

		ld a,0x5d
		call wait_int
		
		call fade_toblack
		
		ld a,0x10
		call wait_int

		
		call store_48c
		ld a,(user_scr0_high)
		SETPG8000
		ld a,(user_scr0_low)
		SETPGC000
		ld de,intr1_img
		call openstream_file
						;		or a
						;		jp nz,fileopenerror
		ld hl,0x8000 ;len
		ld de,0x8000 ;addr
		call readstream_file
						;		or a
						;		jp nz,filereaderror
		call closestream_file
		call restore_48c


		ld hl,mempal
		ld de,pal
		ld bc,32
		ldir 
		call fade_fromblack

;------------------ загружаем изображения		
		call store_48c
		ld a,(scr_buff)
		SETPG4000
		ld hl,0x4000
		ld de,0x4001
		ld bc,16383
		ld (hl),0
		ldir
		
		ld a,(item_buf)	;"KI. только пиксели
		SETPG4000
		ld de,intr_k_img		
		call openstream_file
		ld hl,0x4000 ;len
		ld de,0x4000 ;addr
		call readstream_file
		call closestream_file

		ld a,(portrait_buf)	;"SS. только пиксели
		SETPG4000
		ld de,intr_s_img
		call openstream_file
		ld hl,0x4000 ;len
		ld de,0x4000 ;addr
		call readstream_file
		call closestream_file		
				
		call restore_48c			
		
;=========================================================
		ld a,0x47
		call wait_int
		
		call fade_toblack		
		
		call clear_loc_screen
		
		ld hl,mempal
		ld de,pal
		ld bc,32
		ldir 
		ld a,1
		ld (setpalflag),a
		halt


		ld a,0x71
		call load_image
		call display_image_bgnd
		
		
;переносим атрибуты фона в основной экран.		
;		call store_48c
		

		ld a,(load_buf1)
		SETPG4000
		ld a,(load_buf2)
		SETPG8000
		ld de,intr_b_img		;background
		call openstream_file
		ld hl,0x8000 ;len
		ld de,0x4000 ;addr
		call readstream_file
		call closestream_file				


		ld hl,0x4000+4800-1
		ld de,0x4000+63*40+4800-1
		ld bc,4800
		lddr
		ld hl,0x4000+0x2000+4800-1
		ld de,0x4000+63*40+0x2000+4800-1
		ld bc,4800
		lddr			
		
		ld a,(user_scr0_low)
		SETPGC000
		ld hl,0x8000
		ld de,0xc000+63*40
		ld bc,4800
		ldir
		ld hl,0x8000+0x2000
		ld de,0xc000+63*40+0x2000
		ld bc,4800
		ldir

		call pre_scroll_init
		
		ld a,(load_buf1)	;background
		SETPG4000


		ld a,(scr_buff)
		ld h,a
		ld a,(item_buf)
		ld l,a
		call _scroll_image

		ld a,(item_buf)
		ld h,a
		ld a,(portrait_buf)
		ld l,a
		call _scroll_image

		ld a,(portrait_buf)
		ld h,a
		ld a,(scr_buff)
		ld l,a
		call _scroll_image



        ld a,(active_scr)
        and a 
        jr  z,.spl11z
		
        ;copy scr1 to scr0
        ld a,(user_scr1_high)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0x8000
        ld de,0xc000
        ld bc,16384
		ldir



        ld a,(user_scr0_low)
        SETPG8000
		ld hl, 0x8000+57*40
		ld de, 0x8000+57*40+1
		ld (hl),7
		ld bc,4799+40+40+40+40+40+40
		ldir
		ld hl, 0x8000+57*40+0x2000
		ld de, 0x8000+57*40+1+0x2000
		ld (hl),7
		ld bc,4799+40+40+40+40+40+40
		ldir		


.spl11z:

		
		ld a,(portrait_buf)	;"SS. только пиксели
		SETPG8000
		ld de,intr_n_img
		call openstream_file
		ld hl,0x4000 ;len
		ld de,0x8000 ;addr
		call readstream_file
		call closestream_file


		ld a,0x25
		call wait_int

		ld hl,57*40+0xc000					;d1d0
		ld (screen_adr_img),hl
		call floating_name
		
		
		ld a,0x25
		call wait_int
		
		ld a,(load_buf1)
		SETPG4000
		ld a,(load_buf2)
		SETPG8000
		ld de,intr_b_n_img		;background
		call openstream_file
		ld hl,0x8000 ;len
		ld de,0x4000 ;addr
		call readstream_file
		call closestream_file				
		
		call show_off_bgnd
		
;		call restore_48c
		ld a,(plr_page)
		SETPG4000

.w_e		
		call check_space_key
		ld a,(mus_end)
		and a
		jr z,.w_e
quickexit:		
		call p_mute
		jp ze_start

check_space_key
		call getkey
		cp " "
		ret nz
		ld a,(plr_page)
		SETPG4000
		jr quickexit
		
wait_int:
		ld b,a
.lp
		call check_space_key
		halt
		call check_space_key
		halt
		djnz .lp
		ret

wait_int_2:
		ld b,a
.lp
		;call check_space_key
		halt
		;call check_space_key
		halt
		djnz .lp
		ret

s_addr1 dw 0
s_dest1 dw 0
s_addr2 dw 0
s_dest2 dw 0
show_off_bgnd:
		ld hl,0x4000
		ld (s_addr1),hl
		ld hl,0xc000+57*40
		ld (s_dest1),hl

		ld hl,0x6027
		ld (s_addr2),hl
		ld hl,0xe90f
		ld (s_dest2),hl

		ld b,40
.loop	
		push bc
		
		halt
		ld a,(user_scr0_low)
		SETPGC000
		ld hl,(s_addr1)
		push hl
		ld a,h
		add a,0x40
		ld h,a
		ld de,(s_dest1)
		push de
		call draw_column
		pop de,hl
		push hl,de
		ld a,(user_scr0_high)
		SETPGC000
		call draw_column
		pop de,hl
		inc hl
		ld (s_addr1),hl
		inc de
		ld (s_dest1),de

		ld a,(user_scr0_low)
		SETPGC000
		ld hl,(s_addr2)
		push hl
		ld a,h
		add a,0x40
		ld h,a
		ld de,(s_dest2)
		push de
		call draw_column
		pop de,hl
		push hl,de
		ld a,(user_scr0_high)
		SETPGC000
		call draw_column
		pop de,hl
		dec hl
		ld (s_addr2),hl
		dec de
		ld (s_dest2),de
		pop bc
		djnz .loop
		ret
		
draw_column:
		ld b,130
.lop
		push bc
		ld a,(hl)
		ld (de),a
		ld bc,40
		add hl,bc
		ex de,hl
		add hl,bc
		ex de,hl
		pop bc
		djnz .lop
		ret
		
floating_name:
			
			ld a,130
			ld xh,a
			ld yh,a
.loc_8E95:			
			ld hl,0x8000
			ld (.loc_8EA3+1),hl
			db 0xfd,0x6c	; ld iyl,iyh
			ld de,(screen_adr_img)
.loc_8EA1:
			call check_space_key
			ld a,xh
.loc_8EA3:
			ld hl,0
			push hl,de
			ld bc,56/2
			ldir
			pop de,hl
			push de
			set 5,h
			set 5,d
			ld bc,56/2
			ldir
			pop de
			ld hl,40
			add hl,de
			ex de,hl
			dec yl
			jr      z, .loc_8ED3
			dec     a
			jr      nz, .loc_8EA3
			ld hl,640/8/2		;56	;/2
			ld      a, xh
			ld      h, a
			
			
			call    mul_h_l
			ld      bc, (.loc_8EA3+1)
			add     hl, bc
			ld      (.loc_8EA3+1), hl
			jr      .loc_8EA1
.loc_8ED3:
			dec     xh
			jr      nz, .loc_8E95
			ret


			
pre_scroll_init:

                ld a,(user_scr0_low)
                SETPGC000
                ld a,(user_scr1_low)
                SETPG8000

                ld hl,0xC000
                ld de,0x8000
                ld bc,8000
                ldir
                ld hl,0xE000
                ld de,0xa000
                ld bc,8000
                ldir

                ld a,(user_scr0_high)
                SETPGC000
                ld a,(user_scr1_high)
                SETPG8000

                ld hl,0xC000
                ld de,0x8000
                ld bc,8000
                ldir
                ld hl,0xE000
                ld de,0xa000
                ld bc,8000
                ldir
				xor a
				ld (active_scr),a
				ret
	
active_scr: db 0


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
		

_scroll_image:
		ld a,h
		ld (.bank_1),a
		ld a,l
		ld (.bank_2),a		
		ld hl,0x8000
        ld (.s_move_base_src),hl ;src
        ld a,640/8
        ld (.s_move_lines1),a
        ld a,0
        ld (.s_move_lines2),a

;		jp $

		ld b,640/8+1
.lp0
		push bc
		call set_scr_high
		
.bank_1 = $+1
		ld a,0
		SETPG8000
		ld de,0x4000+63*40	;куда выводить - 32768
.s_move_base_src = $+1
		ld hl,0
		
.s_move_lines1 = $+1
		ld a,0
		ld b,a
		srl b
		and 1
		jr z,.spp1
		inc b
.spp1	

		push hl,de
		call copy_and_line
		call check_space_key
		pop de,hl

		nextcolumnhl
		nextcolumnde
		
		ld a,(.s_move_lines1)
		ld b,a
		srl b

		call  copy_and_line
		call check_space_key
		
;		push de
.bank_2 = $+1
		ld a,0
		SETPG8000
		ld hl,0x8000
		
		ld a,(.s_move_lines1)
		and 1
		jr nz,1f
		prevcolumnde
1
.s_move_lines2 = $+1
		ld a,0
		ld b,a
		srl b
		and 1
		jr z,.spp2
		inc b
.spp2		
		
		push hl,de
		call copy_and_line
		call check_space_key
		pop de,hl
		nextcolumnhl
		nextcolumnde


		ld a,(.s_move_lines2)
		ld b,a
		srl b
;		and 1
;		jr z,.spp2
;		inc b
;.spp2		


		call  copy_and_line	
		call check_space_key
		
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
        

        ld a,(.s_move_lines1)
        dec a
        ld (.s_move_lines1),a
        ld a,(.s_move_lines2)
        inc a
        ld (.s_move_lines2),a


        ld hl,(.s_move_base_src)
        nextcolumnhl
        ld (.s_move_base_src),hl


        pop bc

        dec b
        jp nz,.lp0

        ld e,0
        OS_SETSCREEN
		ret
		
		
copy_and_line:
        ld a,b
        and a
        ret z

        ld a,40
        sub b   
        push hl,de

		ld l, a         ; Move A to L
		ld h, 0         ; Clear H (HL = A)
		add hl, hl      ; HL = A * 2 (11 T-states)
		add hl, hl      ; HL = A * 4 (11 T-states)
		add hl, hl      ; HL = A * 8 (11 T-states)
		add a, l        ; Add original A to L (4 T-states)
		ld l, a         ; Update L with the sum (4 T-states)
		adc a, h        ; Add carry to H (4 T-states)
		sub l           ; Restore H from the accumulator carry trick
		ld h, a         ; Update H
		ld de,_ldi_40_noeob
		add hl,de
        ld (._ldi_routine),hl
		ld (._ldi_routine2),hl

        pop hl,de	;with ex de,hl


		push de,hl
		;ex de,hl
._ldi_routine2 = $+1
		call 0
			;ex de,hl
		ld (.exitde),hl
			;pop de,hl	;->ex de,hl
		pop hl,de
		ld bc,40
		add hl,bc
		ex de,hl
		add hl,bc
		;ex de,hl		;now iniial hl restored

		ex de,hl	;< swap hl de again
		
        ld b,119
.inl:        
        push bc
		push hl,de
		;ex de,hl
        ld bc,.inl_r
        push bc  ;
        jp 0
._ldi_routine    equ $-2

.inl_r: 
		pop hl,de	;with ex de,hl
		ld bc,40
		add hl,bc
		ex de,hl
		add hl,bc
        pop bc
        djnz .inl

.exitde = $+1
		ld de,0
        ret


		

_ldi_40_noeob:	;9
;hl src de - dest        
        dup 40
		ld a,(de)	;1
		and (hl)	;1
		set 7,h		;2
		ld (hl),a	;1
		res 7,h		;2
		inc hl		;1
		inc de		;1	
        edup
        ret		
		
		ENT

ri_end:
			savebin "kissofmurder/intro.bin",ri_start,ri_end-ri_start
			ENDMODULE

