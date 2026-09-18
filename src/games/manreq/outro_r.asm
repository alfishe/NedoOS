	MODULE outro_r
ri_start:
EXT_RTN = 0x5800
FLAG_STOP = 0x4008      ;is_music_ended
SCROLL_LOCK = 0x4015    ;exit_routine
UNBL_FLAG = 0x4019
SCR0HIGH_  = 0x401a
SCR0LOW_  = 0x401b

font_height = 0x08
		DISP T_START
		call clear_loc_screen
		ld a,6
		call load_mus
		ld hl,1
		ld (display_image_from_buffer.display_delay),hl		
		call set_music_pages
		ld hl,srollp
		ld de,EXT_RTN
		ld bc,xtr1_len
		ldir
		ld a,(scr0high)
		ld (SCR0HIGH_),a
		ld a,(scr0low)
		ld (SCR0LOW_),a
		xor a
		ld (SCROLL_LOCK),a		
		call unset_music_pages
		
		call wait_progress
		
		ld hl,0xc000 + 50*40     ;0xcfa0 pc88
		ld (screen_adr_img),hl
		ld a,0x09
		call load_image
		
		call wait_progress
		

		ld hl,0xc000 + 150*40+30       ;0xef1c pc88
		ld (screen_adr_img),hl
		
		call set_music_pages
		ld a,0xc9
		ld (SCROLL_LOCK),a		
		call unset_music_pages
		
		ld a,0x07
		call load_image
		YIELDGETKEYLOOP
		QUIT
		jp $
	


wait_progress
		ld a,(curpg4000)
		ld (.swer),a
		ld a,(plr_page)
		SETPG4000
.wait_ubl		
		ld a,(UNBL_FLAG)
		and a
		jr z,.wait_ubl
		xor a
		ld (UNBL_FLAG),a
.swer
		ld a,0
		SETPG4000
		ret


srollp:		
        ENT    



;EXT_RTN
xtr1:
                DISP EXT_RTN
				jp ext_start
				align 256
ext_font:		incbin "_rus/intro_font.bin"
ext_txt			include "_rus/outro_text.asm"
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
				cp font_height  ;font height
				jr z,line_complete	;<<<<<<<<< 8f9b
				
				ld c,a
text_pointer = $+1
				ld hl,ext_txt
				call print_one_font_line
				inc c
				ld a,c
				ld (lines_counter),a  ;8f80
				cp font_height   ;font height
				jp nz,ext_exit
				ld (text_pointer),hl
				jp ext_exit
line_complete:
				xor a
				ld (lines_counter),a
				ld a,(displayed_text_row_counter)
				inc a
				ld (displayed_text_row_counter),a

				cp 3	;0x03
				call z,unblock_next_intro_section
				cp 0x2e+7	;0x2e
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
				add hl,hl	;hl*8
				add hl,hl
				add hl,hl
				ld de,ext_font
				add hl,de
				ld b,0		;c - offset to current displayed line in font	
				;add hl,bc
				add hl,bc ;offset to current line in font symbol
				pop de		;hl -font de - scr addr
				
				ld a,(hl)
				ld (de),a
				ld a,d
				xor 0x20
				ld d,a
				bit 5,d
				jr nz,$+3
				inc de
				pop hl
				jr .loop
				
                ENT
xtr1_len=$-xtr1
ri_end:
			savebin "jb2manreq/outro_r.bin",ri_start,ri_end-ri_start
			ENDMODULE

