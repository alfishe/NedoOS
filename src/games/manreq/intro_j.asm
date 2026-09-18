			MODULE intro_j
ji_start
EXT_RTN = 0x5800
FLAG_STOP = 0x4008      ;is_music_ended
SCROLL_LOCK = 0x4015    ;exit_routine
UNBL_FLAG = 0x4019
SCR0HIGH_  = 0x401a
SCR0LOW_  = 0x401b

		DISP T_START



		call clear_loc_screen


		; load logo
		call store_48c
		ld hl,0xc00f
		ld (screen_adr_img),hl
		ld a,0x0b
		call load_image_intro
		call display_image_from_buffer
;		call restore_48c


		ld bc,0xffff
.arra		
		call check_space_key
		dec bc
		ld a,b 
		or c
		jr nz,.arra


		ld bc,0xffff
.arra2		
		call check_space_key
		dec bc
		ld a,b 
		or c
		jr nz,.arra2
		
		xor a
		call load_mus

		call clear_loc_screen

		ld hl,1
		ld (display_image_from_buffer.display_delay),hl		
		call store_48c
		ld hl,0xc003
		ld (screen_adr_img),hl
		ld a,0x0d
		call load_image_intro
		call display_image_from_buffer
;		call restore_48c

		call check_space_key

		call set_music_pages
		ld hl,srollp
		ld de,EXT_RTN
		ld bc,xtr_len
		ldir
		ld a,(scr0high)
		ld (SCR0HIGH_),a
		ld a,(scr0low)
		ld (SCR0LOW_),a
		xor a
		ld (SCROLL_LOCK),a		
		call unset_music_pages


		call wait_space_progress
		call clear_workarea    ;c000- c022 156lines

		call store_48c
		ld hl,0xc000 + 36*40     ;0xcb40 pc88
		ld (screen_adr_img),hl
		ld a,0x0c
		call load_image_intro
		call display_image_from_buffer
;		call restore_48c


		call wait_space_progress
		call clear_workarea    ;c000- c022 156lines

		call store_48c
		ld hl,0xc000 + 36*40       ;0xcb40 pc88
		ld (screen_adr_img),hl
		ld a,0x0e
		call load_image_intro
		call display_image_from_buffer
;		call restore_48c		
		

		call wait_space_progress
		call clear_workarea    ;c000- c022 156lines


		call wait_space_progress

		call set_music_pages
		ld a,0xc9
		ld (SCROLL_LOCK),a		
		call unset_music_pages
		
		call store_48c
		ld hl,0xc000 + 35*40       ;0xcaf0 pc88
		ld (screen_adr_img),hl
		ld a,0x10
		call load_image_intro
		call display_image_from_buffer
		
		
		ld hl,0x2fff
		ld (display_image_from_buffer.display_delay),hl
		
		ld hl,0xc000 + 35*40       ;0xcaf0 pc88
		ld (screen_adr_img),hl
		ld a,0x0f
		call load_image_intro
		call display_image_from_buffer		
		
		ld hl,DEFAULT_DELAY
		ld (display_image_from_buffer.display_delay),hl		


;		call restore_48c

		ld a,(plr_page)
		SETPG4000
.arra3:		
		call check_space_key
		ld a,(FLAG_STOP)
		and a
		jr z,.arra3
		
		jp check_space_key.fexit


wait_space_progress:
		ld a,(curpg4000)
		ld (.swer),a
		ld a,(plr_page)
		SETPG4000
		
.wait_ubl		
		ld a,(UNBL_FLAG)
		and a
		push af
		call check_space_key
		pop af
		jr z,.wait_ubl
		xor a
		ld (UNBL_FLAG),a
.swer
		ld a,0
		SETPG4000
		ret

clear_workarea:
		ld a,(curpgc000)
		ld (.pgc0000stor1),a
		
		ld a,(user_scr0_high)
		SETPGC000
		
		ld hl,0xc000
		ld b,156
.out_loop		
		push hl
		xor a
		
		dup 23
		ld (hl),a
		set 5,h
		ld (hl),a
		res 5,h
		inc hl
		edup		
		pop hl
		ld de,40
		add hl,de
		dec b
		jp nz,.out_loop
		
.pgc0000stor1 = $+1
		ld a,0
		SETPGC000
		ret		

srollp:		
        ENT    



;EXT_RTN
xtr:
                DISP EXT_RTN
				jp ext_start
				align 256
ext_font:		incbin "_jpn/intro_font.bin"
ext_txt			include "_jpn/intro_text.asm"
ext_txt_end:

displayed_text_row_counter: db 0
decrease_wait_counter
				ld (scroll_delay),a
				jp ext_exit
ext_start:

scroll_delay = $+1
				ld a,0x4
				dec a
				jp nz,decrease_wait_counter

scroll_delay_df:
				ld a,0x4
				ld (scroll_delay),a
				
				
				ld a,(curpgc000)
				ld (pgc0000stor),a
				
				ld a,(SCR0HIGH_)
				SETPGC000
				
				
				
				call scroll_text_up
lines_counter	= $+1
				ld a,0
				cp 0x0a  ;font height
				jr z,line_complete	;<<<<<<<<< 8f9b
				
				ld c,a
text_pointer = $+1
				ld hl,ext_txt
				call print_one_font_line
				inc c
				ld a,c
				ld (lines_counter),a  ;8f80
				cp 0x0a ;font height
				jp nz,ext_exit
				ld (text_pointer),hl
				jp ext_exit
line_complete:
				xor a
				ld (lines_counter),a
				ld a,(displayed_text_row_counter)
				inc a
				ld (displayed_text_row_counter),a

				cp 0x11
				call z,unblock_next_intro_section
				cp 0x1f
				call z,unblock_next_intro_section
				cp 0x3e ;0x32
				call z,unblock_next_intro_section
				cp 0x4d
				jp nz,ext_exit
				call unblock_next_intro_section
ext_exit		
pgc0000stor = $+1
				ld a,0
				SETPGC000
				ret
				
unblock_next_intro_section:
				ld a,1
				ld (UNBL_FLAG),a
				ret

scroll_text_up:
				push bc
				ld a,188
				ld hl,49152+280+23
				ld de,49152+240+23
.loop
				push hl,de
				dup 17
				ldi
				edup
				pop de,hl
				push hl,de
				set 5,h
				set 5,d
				dup 17
				ldi
				edup
				pop de,hl
				ld bc,40
				add hl,bc
				ex de,hl
				add hl,bc
				ex de,hl
				dec a
				jp nz,.loop
				pop bc
				ret


print_one_font_line:
				ld de,49152+7720+23
.loop
				ld a,(hl)
				inc hl
				cp 0xff
				ret z
				push hl,de
				ld l,a
				ld h,0
				ld e,l
				ld d,h
				add hl,hl	;hl*20 (20 bytes per kanji -> width 2 height 10
				add hl,hl
				add hl,de
				add hl,hl
				add hl,hl
				ld de,ext_font
				add hl,de
				ld b,0		;c - offset to current displayed line in font	
				add hl,bc
				add hl,bc ;offset to current line in font symbol
				pop de		;hl -font de - scr addr
				ldi
				dec de
				set 5,d
				ldi
				res 5,d
				inc c
				inc c
				pop hl
				jr .loop
				
                ENT
xtr_len=$-xtr

ji_end:
;        	display "Buff ji_start ",/d,ji_start," bytes"
        	;display "Buff ji_end ",/d,ji_end," bytes"
			savebin "jb2manreq/intro_j.bin",ji_start,ji_end-ji_start
			ENDMODULE
			