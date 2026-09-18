	MODULE exec_j
ri_start:

		DISP T_START		
                call load_card_image
                
                ld a,1
                call load_mus
                ld a,4
                call load_text_module  ;modules_loader
				
                call    location_in_front_of_jed_office_gamestart
hot_return_to_city:
                call    print_text_at_location
loc_AAE9:
                call    print_location_menu
								
                ld      a, (location_id)
                cp      0Eh
                call    z, load_music
loc_AAF4:
                call    wait_for_user_decision
                jr      loc_AAF4
				
j_shorts:	;japanese tokens table
		include "_jpn/j_shortening.asm"
A650_strings:	;message_table_9940
		include "_jpn/j_A650.asm"
menu_strings_table:		;строки текста для вывода меню
		include "_jpn/j_menu.asm"				

msg_AF45:       db 22h, 10h, 25h, 14h, 95h, 0B1h, 15h, 18h, 1Bh, 14h, 0A2h, 79h, 0FFh
msg_AF55:       db 0D0h, 0D1h, 0EEh, 0EFh, 1Ch, 14h, 1Dh, 24h, 0FFh
unk_AF52		db 0AFh, 0B0h, 0B1h

MSG_AF5E:       db 0D7h, 0D8h, 0F8h, 2Fh, 7Bh, 0FFh
MSG_AF64:       db 0E3h, 0F8h, 9Ch, 0D4h, 0D5h, 0FFh
MSG_AF6A:       db 0F8h, 7, 0B6h, 8Eh, 0B0h, 0FFh
MSG_AF70:       db 0D9h, 8Fh, 92h, 0A8h, 0FFh
MSG_AF75:       db 7Ah, 0EDh, 0F9h, 4Dh, 5Fh, 0FFh
MSG_AF7B:       db 0C4h, 0A1h, 0DDh, 0DEh, 0A1h, 0F8h, 3, 0E3h, 88h, 0F9h, 0BFh, 58h, 94h, 0A7h, 95h, 8Eh, 0FFh


load_music:
				ld      a, 0
				or      a
				ret     nz
				inc     a
				ld      (load_music+1), a
				ld a,3
				jp load_mus

enable_music_load:
				xor a
				ld (load_music+1),a
				ld a,1
				jp load_mus
; ---------------------------------------------------------------------------
print_final_text:
                ld      hl, 0C006h
                ld      (text_screen_address), hl
                ld      a, 7
                ld      (symbol_color), a
                ld      hl, 120h
                ld      (temp_text_pointer), hl
                ld      b, 0Eh

loc_AC76:
                push    bc
                ld      hl, (temp_text_pointer)
                inc     hl
                ld      (temp_text_pointer), hl
				
				push de,bc
				call set_text_pages
                ld      de, TEXT_START
                ex      de, hl
                call    find_string_by_de
				ld de,text_buffer
				ld bc,text_buffer_len
				ldir
				call unset_text_pages
				pop bc,de
				
				ld hl,text_buffer
                call    print_text_line
				
				ld 		hl,(text_screen_address)
                ld      de, 11*40		;370h
                add     hl, de
                ld      (text_screen_address), hl
                pop     bc
                djnz    loc_AC76
                ret
; ---------------------------------------------------------------------------				
location_B168:
				ld      hl, loc_B1DD
				call    execute_hl
				jp      z, loc_B1D7
				call    sub_8F58

                sub     0A9h
                add     a, a
                ld      l, a
                add     a, 8Ch
                push    hl
                push    af
				
					;call    restore_background_load_image
					push    af
					call    remove_npc_portrait ; restore background from buffer				
					call store_48c
					pop     af
					
					ld hl,IMG_BUFFER	;header
					call load_image_waddr
					
					ld a,0x8d
					ld hl,IMG_BUFFER+1836
					call load_image_waddr
				
                pop     af
                inc     a
				
                ld      hl, IMG_BUFFER+16384+1024
                ;push    hl
                call    load_image_waddr
                ;pop     hl
				
;transfer portrait 
PRTRT_WDTH = 9 ;portrait width (
BS_WDTH = 27   ;overlay width
BS_PRT_OFS = 8 ;offset on overlay to draw portrait
				ld hl,IMG_BUFFER+16384+1024+PRTRT_WDTH*2 ;skip image color lines
				;ld de,IMG_BUFFER+((BS_WDTH*4)*19)+(BS_WDTH*2)+BS_PRT_OFS
				ld de,IMG_BUFFER+((BS_WDTH*4)*19)+BS_PRT_OFS
				ld a,0x5a
.loop
				push de
					push af
					ld a,5
					dup PRTRT_WDTH
					ld (de),a
					inc de
					edup
					ex de,hl
					ld bc,BS_WDTH-PRTRT_WDTH
					add hl,bc
					ex de,hl
					dup PRTRT_WDTH
					ld (de),a
					inc de
					edup	
					ex de,hl
					ld bc,BS_WDTH-PRTRT_WDTH
					add hl,bc
					ex de,hl
					pop af
				ld bc,PRTRT_WDTH
				ldir
				ex de,hl
				ld bc,BS_WDTH-PRTRT_WDTH
				add hl,bc
				ex de, hl		;передвинули de на нужное место (вторая часть Экрана)
				ld bc,PRTRT_WDTH
				ldir
				;теперь скопирована строка 
				ld bc,PRTRT_WDTH*2
				add hl,bc			;next portrait pixels position
				pop de
				ex de,hl
				ld bc,BS_WDTH*4
				add hl,bc
				ex de,hl			;next overlay pixels position
				dec a
				jr nz,.loop
				
				ld hl,0x9c1b
				ld (sizex),hl
				ld hl,0xc001
				call display_image_from_buffer_with_addr
				

                pop     hl
                ld      h, 0
                ld      de, 41Ch
                add     hl, de
                ex      de, hl
                call    sub_AC17
                call    show_msg_hit_return_key
                ld      de, (txt_string_id)
                inc     de
                call    sub_AC17
                call    show_msg_hit_return_key
                ld      a, 36h ; '6'
                call    load_image
                ld      a, 67h ; 'g'
                call    load_portrait_image
                ld      hl, 41Ch
                jr      loc_B1DA				
loc_B1D7:
                ld      hl, 41Dh
loc_B1DA:
                jp      loc_AC13


loc_B1DD:
                inc     hl
                ld      a, (hl)
                cp      4
                ret     nz
                inc     hl
                inc     hl
                inc     hl
                bit     2, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                jp      loc_ABA8

; ---------------------------------------------------------------------------

location_B972:
                push    af
                call    show_msg_hit_return_key
                ld      a, 6
                call    load_text_module
                pop     af
                ld      de, 115h
                cp      5
                jr      z, loc_B986
                ld      de, 11Bh
loc_B986:
                ld      b, 5
loc_B988:
                push    bc
                call    sub_AC17
                call    show_msg_hit_return_key
                ld      de, (txt_string_id)
                inc     de
                pop     bc
                djnz    loc_B988
                call    sub_AC17
                ld      a, 5
                call    load_text_module
                pop     hl
                jp      loc_AAE9
; ---------------------------------------------------------------------------
location_B382:
                xor     a
                ld      (temp_location_id_byte_b9ea), a
                ld      (word_B9EC), a
                ld      a, 7
                ld      (location_id), a
                ld      a, (temp_location_id_byte_b9ea+1)
                add     a, 32h ; '2'
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                inc     hl
                ld      a, (hl)
                call    restore_background_load_image
                ld      a, (load_music+1)
                or      a
                call    nz, enable_music_load
                ld      hl, 25h ; '%'
                call    sub_AC9C
                ex      de, hl
                pop     hl
                ld      c, 5
                add     hl, bc
                bit     0, (hl)
                jr      z, loc_B3B3
                inc     de
loc_B3B3:
                ld      (txt_string_id), de
                ld      b, 17h
                ld      a, 3
                call    sub_B3F7
                ld      b, 15h
                ld      a, 4
                call    sub_B3F7
                ld      b, 7
                ld      a, 0Ah
                call    sub_B3F7
                ld      de, byte_B3D9
                ld      b, 7
loc_B3D1:
                ld      a, (de)
                inc     de
                call    sub_B3E0
                djnz    loc_B3D1
                ret
byte_B3D9:      db 8, 0Ch, 0Ah, 5, 0Dh, 1Ah, 0Eh
sub_B3E0:
                call    get_pointer_to__gamestate_main_by_A
                inc     hl
                inc     hl
                inc     hl
                bit     0, (hl)
                ret     z
                dec     hl
                dec     hl
                dec     hl
                ld      (hl), 0
                cp      0Ah
                ret     nz
                ld      hl,  gamestate_main+1C5h
                set     0, (hl)
                ret
sub_B3F7:
                call    get_pointer_to__gamestate_main_by_A
                inc     hl
                inc     hl
                inc     hl
                bit     3, (hl)
                ret     z
                dec     hl
                dec     hl
                dec     hl
                ld      (hl), b
                cp      0Ah
                ret     nz
                ld      hl,  gamestate_main+1C5h
                res     0, (hl)
                ret



sub_ABF1
                call    get_pointer_to__gamestate_by_temp_location_id
                inc     hl
                inc     hl
                bit     4, (hl)
                jr      z, loc_AC0F
                add     a, 46h ; 'F'
                ld      (portrait_lock), a
                call    load_item_image
                xor     a
                ld      (load_card_image+1), a
				ld hl,0x0536
				ld (draw_line_on_screen.lp1),hl
				ld (draw_line_on_screen.lp2),hl
                ld      hl, 0xc000+77*40+29+0x2000	;  0D84Bh pc-88
                call      display_image_from_buffer_with_addr
				ld hl,0x771a
				ld (draw_line_on_screen.lp1),hl
				ld (draw_line_on_screen.lp2),hl
				ret
loc_AC0F:
                jp      load_card_image
				
menu_choose_file_to_load:
                ld      (frame_screen_address), hl
                ld      (loc_964F+1), de
                push    hl
                ld      hl, G_BUFFER3
                ld      (screen_buffer_address), hl
                ld      a, 0x18
                ld      (count_of_vertical_lines_in_the_frame), a
                call    render_message_frame
                xor     a
                ld      (characters_to_print), a
                ld      a, 6
                ld      (symbol_color), a
                ld      a, 0x0E
                ld      (characters_in_text_line), a
                pop     hl
                push    hl
                ld      de, 5*40+2	;194h
                add     hl, de
                ld      (text_screen_address), hl

loc_964F:
                ld      hl, 0
                call    print_text_line
                pop     hl
                push    hl
                ld      de, 12*40		;3C0h
                add     hl, de
                ld      (frame_screen_address), hl
                ld      a, 1
                ld      (loc_8EC8+1), a
                ld      c, 0
                ld      b, 2
                ld      hl, menu_strings_index_array_table_unk_97F2 ; массив номеров строк которые используются для выбора текстовых строк для отображения меню
                call    sub_8E93
                ld      a, 10h	
                ld      (loc_8EC8+1), a
.loop
                xor     a
                call    wait_for_key_input
                dec     a
                cp      2
                jr      c, _1_or_2_is_pressed
                cp      0x1A
                jr      z, SPACE_is_pressed
                jr      .loop
_1_or_2_is_pressed:
                push    af
                call    highlight_letter_selection
                pop     af
                pop     hl
sub_969F:
                ld      (frame_screen_address), hl
                or      a
                ret
SPACE_is_pressed:
                pop     hl
                call    sub_969F
                scf
                ret
				


remove_npc_portrait	;sub_8a0c:
			ld a,(frame_horisontal_offset_type)
			cp 2
			ret z
			ld hl,0x5a09		;0x5a12		;width = 0x12 ; height 0x5a
			ld (sizex),hl
			ld a,2
			ld (frame_horisontal_offset_type),a
                        call store_48c
                        ld a,(load_buf1)
                        SETPG4000
			ld      hl, (screen_adress_for_npc_portrait)
			jp      display_image_from_buffer_with_addr
			
restore_background_load_portrait:
                 push    af
                 call    remove_npc_portrait
                 pop     af
                 jp      load_portrait_image
 
restore_background_load_image:
                 push    af
                 call    remove_npc_portrait ; restore background from buffer
                 pop     af
                 jp      load_image
				 
;=====
print_text_at_location:
;clear bottom part of window based on 'keep_top_text_line' default = 0 clear whole
		ld hl,0xc000+167*40+1
		ld bc,0x2127		;39*2 = 78 знакомест.  высота - 33 линии
		ld a,(keep_top_text_line)
		or a
		jr nz,.kp_top_line
		ld hl,0xc000+156*40+1
		ld b,0x2c
.kp_top_line:
		call clear_window
		xor a
		ld (keep_top_text_line),a
		ld (characters_to_print),a
		
		ld hl,0xc000+168*40+2				;text scr addr
		ld (text_screen_address),hl
		ld a,7
		ld (symbol_color),a
		ld a,0x24
		ld (characters_in_text_line),a
		
.loc_9166
		ld de,(txt_string_id)
		ld a,(load_text_module+1)
		dec a
		jr z,.loc_9078
		ld b,a
		ld a,4
1		add a,a
		djnz 1b
.loc_9078
		or d
;send cmd 2 + de
		push de
		call gamestate_fdc_handler
		pop de
		ld hl,gamestate_fdc_buffer	;init buffer before read
		ld (get_fdc_byte.gfb),hl
		;find string in text module
		call set_text_pages
.loc_907c:
		ld hl,TEXT_START
		call find_string_by_de
.loc_9082:
		ld a,(hl)
		dec a
		jr z,.seek_prev_string	;code 1
		cp 3
		jr c,.loc_90d7			;code 2 code 3
		
		push bc,de				;!!!!!!! нужно закрыть text pages и иметь в буфере строку для отображения
		ld de,text_buffer
		ld bc,text_buffer_len
		ldir
		call unset_text_pages
		pop de,bc
		
		ld hl,text_buffer
		call print_text_line 		
		

.loc_908d		
		call get_fdc_byte
		cp 0xff
		ret z
		ld e,a
		ld d,0
		call get_fdc_byte
		add a,a
		add a,a
		add a,a
		or 0xc6 		;???
		ld (.loc_90b6+1),a
		call get_fdc_byte
		call get_pointer_to__gamestate_main_by_A		
		add hl,de
.loc_90b6:
		set 0,(hl)
		jr .loc_908d
		
.seek_prev_string:
		dec a
		dec hl
2		dec hl
		cp (hl)
		jr nz,2b
		inc hl
		jr .loc_9082

.loc_90d7:	;loc_91BF
                ld      a, (word_B9EC)
                ld      l, a
                ld      h, 50h ; 'P'
                call    mul_h_l
                ld      de, 0F4h
                add     hl, de
                call    .sub_91D6
                rrca
                jr      nc, .loc_91D3
                inc     hl
.loc_91D3:
                ex      de, hl
                jr      .loc_907c
.sub_91D6:
                push    bc
.loc_91D7:
                ld      b, 0
                ld      a, r
                add     a, b
                ld      (.loc_91D7+1), a
                pop     bc
                ret


;japaneese version
print_text_line:
				push hl,de,bc,af
				
				ld      de, (text_screen_address)
				ld      (text_screen_address_current), de
				ld      a, (characters_in_text_line)
				ld      c, a            ; 24h ??? at jb office entrance
.loop:
				ld a,(hl)
				cp 0xff
				jr z,.end_of_string
				inc hl
				cp 0xfe
				jr z,.fe_modifier	;tokenized text
				cp 0xfd
				jr z,.fd_modifier   ;quoted text
				cp 0xf8
				jr nc,.f8_modifier	;chars from second part of kanji font
				call print_char
				call check_cr
				jr .loop
.end_of_string:
				nop
				pop af,bc,de,hl
.closed_bracket_print:
				ret
				push af
				ld a,0x0b
				call print_char
				ld a,0xc9
				ld (.closed_bracket_print),a
				pop af
				ret
.f8_modifier
				sub 0xf7
				ld b,a
				ld (use_second_half_of_font),a
.loop_f8:				
				ld a,(hl)
				inc hl
				call print_char		;c- количество оставшихся для печати в ряду букв
				call check_cr
				djnz .loop_f8
				xor a
				ld (use_second_half_of_font),a
				jr .loop

.fe_modifier:
				ld      e, (hl)
				inc     hl
				push    hl
				inc     e
				ld      d, 0
				ld      hl, j_shorts
				call    find_string_by_de
				ld      a, 0xC9
				ld      (.end_of_string), a
				call    .loop       ; печатаем строку текста которую упаковали с префиксом FE
				xor     a
				ld      (.end_of_string), a
				pop     hl
.loc_9176:
				jr      .loop
.fd_modifier:
				ld      a,0x0a
				call    print_char
				dec     c
				xor     a
				ld      (.closed_bracket_print), a
				jr      .loc_9176

check_cr:
				dec c
				ret nz
				ld a,(characters_in_text_line)
				ld c,a
do_cr:
				push hl
				ld hl,(text_screen_address)
				ld de,11*40
				add hl,de
				ld (text_screen_address),hl
				ld (text_screen_address_current),hl
				pop hl
				ret	
print_char:
;in a - char code
				push	hl,de,bc,af
				call store_c000
				ld      b, a
				ld      l, a
				ld      h, 0
				add     hl, hl
				add     hl, hl
				ld      d, h
				ld      e, l
				add     hl, hl
				add     hl, hl
				add     hl, de
				ld      de, font
				ld      a, (use_second_half_of_font)
				or      a
				jr      z,1f
				ld      de, font+4960
1
				add     hl, de
				ld      de, (text_screen_address_current)
				ld      a, (characters_to_print)
				or      a
				jr      nz, .print_a_string			
.print_single_char:				
				;TODO - two pass print. first - pixels attributes. second - draw attributes.

				ld a,(symbol_color)
				call fill_char_16x10_color
				
				call print_char_16x10
				nextcolumnde
.loc_91c0:
				nextcolumnde		;inc     de
				ld      (text_screen_address_current), de
				
				call restore_c000
				pop 	af,bc,de,hl
				ret
				
.print_a_string:
				ld a,b
				cp 0x7a
				jr nc,.print_single_char
				ld a,(use_second_half_of_font)
				or a
				jr nz,.print_single_char
				ld a,(symbol_color)
				call fill_char_8x10_color
				call print_char_8x10
				jr .loc_91c0

fill_char_16x10_color:
				push af
				ld a,(user_scr0_low)
				SETPGC000
				pop af
				
                push    hl,de
				ex      de, hl
                ld      d,5
				ld 		e,a
                ld      bc, 40
.loc_lp:
                ld      (hl), e
                nextcolumnhl
                ld      (hl), e
                add     hl, bc
                ld      (hl), e
                prevcolumnhl
                ld      (hl), e
                add     hl, bc
                dec     d
                jp      nz, .loc_lp
                pop     de,hl
                ret
				
				
print_char_16x10:
				ld a,(user_scr0_high)
				SETPGC000			
                push    hl,de
                ld      a, 5
                ld      bc, 40
                ld      (.storesp+1), sp
                di
                ld      sp, hl
                ex      de, hl
.loc_lp:    
				exa
                pop     de
                ld      (hl), e
                nextcolumnhl
                ld      (hl), d
                add     hl, bc
                pop     de
                ld      (hl), d
                prevcolumnhl
                ld      (hl), e
                add     hl, bc
				exa
                dec     a
                jp      nz, .loc_lp
.storesp: 
                ld      sp, 0
                pop     de,hl
                ei
                ret
				
fill_char_8x10_color:
				push hl,de,af		;hl - char addr, de - scr addr a - color
				ld a,(user_scr0_low)
				SETPGC000
				pop af
				ex de,hl
				
				ld de,40
				ld b,10
.loc_lp	:
				ld (hl),a
				add hl,de
				djnz .loc_lp
				pop de,hl
				ret
					
print_char_8x10:
				ld a,(user_scr0_high)
				SETPGC000
;				xor a	;????
                push    de              ; hl - char adress
                                        ; de - screen adress
                                        ; c  - 0 ???
                                        ; a  = 0
                ld      (.storesp+1), sp
                di
                ld      sp, hl
                ex      de, hl
                ld      b, 0Ah

.loc_lp:
                pop     de
                rr      d
                rra
                rr      d
                rr      c
                rr      d
                rra
                rr      d
                rr      c
                rr      d
                rra
                rr      d
                rr      c
                rr      d
                rra
                rr      d
                rr      c
                rr      e
                rra
                rr      e
                rr      c
                rr      e
                rra
                rr      e
                rr      c
                rr      e
                rra
                rr      e
                rr      c
                rr      e
                rra
                rr      e
                rr      c
                or      c		;a = shrinked 16bit wide image into 8 bit
;                ld      c, a		
				
				ld (hl),a

                ld      de,40		; 50h - pc-88
                add     hl, de
                djnz    .loc_lp

.storesp
                ld      sp, 0
                pop     de
                ei
                ret
;---------------------------------------------------
print_location_menu:
				ld a,(location_id)
				or a
1
				jp z,revert_line_inv_lock_1
.loc_8f39
				cp 0
				jr z,1b
				ld (.loc_8f39+1),a
				ld      hl,0xc000+0*40+60/2 				;0C03Ch
				ld      (text_screen_address), hl
				ld      b, a
				add     a, a
				add     a, a
				add     a, a
				sub     b
				ld      e, a            ; e = a*7 (  [8d1f]*7)
				ld      d, 0
				ld      hl, location_menu_entries_table-7 ; table consist 7 bytes per one entry
										; min offset is 1
				add     hl, de
				ld      (current_menu_entry_pointer), hl
				xor     a
				ld      (characters_to_print), a
				ld      b, 7

.loop:
                ex      de, hl          ; hl-addree of location menu
                push    bc
                ld      hl, (text_screen_address)
;                dec     hl
                dec     hl
                ld      bc, 0x0b0b 					;0B16h
                call    clear_window
                pop     bc
                ex      de, hl
                ld      a, (hl)         ; hl - adress of location menu
                or      a
                jr      z, .no_menu_option__skip
                inc     hl
                push    hl
                push    af
                ld      hl, (text_screen_address)
;                dec     hl
                dec     hl
                ld      (text_screen_address_current), hl
                ld      a, 5
                ld      (symbol_color), a
                ld      a, 8
                sub     b
                call    print_char
                ld      a, 7
                ld      (symbol_color), a
                pop     de              ; restore AF into DE
                ld      e, d
                ld      d, 0
                ld      hl, menu_strings_table
                call    find_string_by_de
                call    print_text_line
                pop     hl
.no_menu_option__skip:       
                call    do_cr	;loc_914D
                djnz    .loop
                ld      a, 0xC9
                ld      (revert_line_inv_lock_1), a
                ld      (prev_selection+1), a
                ret

inverse_menu_selection:                
                call    revert_line_inv_lock_1
                push    af
                ld      (prev_selection+1), a
				
                add     a, a
                add     a, a
                ld      l, a
                ld      h, 0x6e			;0DCh pc-88
                call    mul_h_l
				
                ld      de, 0xc000+0*40+58/2		;		0C03Ah      ; выбор экранной строки
                                        ; выбранная кнопка *4 *  0xDC байт
                add     hl, de			;hl - screen address
                ld      (revert_line_inv_lock_1.hl+1), hl ; экранный адрес начала строки, которую надо инвертировать
                xor     a
.entr:
				;in a- lock
				;hl - scr addr
				; - 			does B should be unchanged ?
				ld      (revert_line_inv_lock_1), a
				

                ld      a, 0x16          ; invert selected line
invert_custom_line:                    
				push af,bc
				ld a,(curpgc000)
				ld (.pgc0000stor),a
				ld a,(user_scr0_high)
				SETPGC000
				pop bc,af
				
                ld      (invert_line+1), a
                ld      c, 0Bh          ; vertical lines to invert   11 lines for japaneese version
                ld      de, 0x4E/2+1    ; значение для перевода к началу следующей строки
.loop                               
				call    invert_line
                add     hl, de
                dec     c
                jr      nz,.loop
				
.pgc0000stor = $+1
				ld a,0
				SETPGC000
                pop     af
                ret
				
invert_line:                                                        
                ld      b, 0x16
invert_x_bytes_line:        
                push    hl
.loop:                      
                ld      a, (hl)
                cpl
                ld      (hl), a
                nextcolumnhl
                djnz    .loop
                pop     hl
                ret
revert_line_inv_lock_1:
                ret
.hl:                        
                ld      hl, 0
                push    af
                ld      a, 0xC9
                ld      (prev_selection+1), a
                jr      inverse_menu_selection.entr
				
highlight_letter_selection:
                push    af
                ld      hl, (frame_screen_address)
				
                ld      de,0xc9			;0xc9 = 5*40+1  (Atm); 192h=5*80+1 (pc-88)
                add     hl, de
                ex      de, hl
                and     0FEh
                add     a, a
                ld      l, a
                ld      h, 0x6e    ;???      0DCh - pc88
                call    mul_h_l
                add     hl, de
                pop     af
                push    af
                and     1
                jr      z, 1f
                ld      de, 9+0x2000      ;????    13h-pc-88
                add     hl, de
1
                ld      (loc_9029+1), hl
                xor     a
loc_9020:
                ld      (nullsub_2), a
                ld      a, 0x13			;line length
                jp      invert_custom_line
				
locret_9132:
nullsub_2:
                ret
loc_9029:
                ld      hl, 0
sub_9136:
                push    af
                ld      a, 0xC9
                jr      loc_9020
				

				
;==================================================
location_in_front_of_jed_office_gamestart:
			;in front of Jed's office
                ld      a, 0Bh
                call    restore_background_load_image
                ld      a, 1
                ld      (location_id), a
                ld      a, 1Ah
                ld      (temp_location_id_byte_b9ea+1), a
                ld      de, 2
loc_AC12:
                ex      de, hl
loc_AC13:
                ld      (txt_string_id), hl
                ret
sub_AC17:
                ld      (txt_string_id), de
                jp      print_text_at_location

location_B0E5:
                ld      a, 0Eh
                call    restore_background_load_image
                ld      a, 5
                ld      (location_id), a
                dec     a
                call    load_text_module
                ld      de, 43Eh
                ld      hl,  gamestate_main+260h
                bit     1, (hl)
                jr      z, .loc_B0FE
                inc     de
.loc_B0FE:
                jr      loc_AC12
				
				

wait_for_user_decision:
.w_loop:
			call wait_for_key_input		;out - 0 no key pressed.
			cp NOKEY
			jr z,.w_loop
			cp 8
			jp c,digit_pressed
			ld b,a
			ld a,(can_use_letters)	;0 - only digits 1-7   ;1 letters allowed
			or a
			jr z,.w_loop
			ld a,b
			cp 0x1b
			jr z,key_space
			sub "A"			;switch A-Z range to 0-xxx range
;loc_92E9
			ld b,a
			ld a,(max_letter_allowed)
			dec a
			cp b
			jr c,.w_loop
			ld a,b
			ret
			
digit_pressed:
			dec a
prev_selection:
			cp 0
loc_9401:
			jr z,wait_for_user_decision.w_loop
			ld hl,(current_menu_entry_pointer)
			ld e,a
			ld d,0
			add hl,de
			ld a,(hl)
			or a
			jr z,wait_for_user_decision.w_loop
			push af
			ld a,e
			call inverse_menu_selection
			pop af
			jp goto_new_location		

key_space:
			call restore_background	
loc_9420: 
			jp loc_AB18
			
loc_AB18: ;loc_ADF2
			ld      sp, sp_main
			call    sub_AB25
			jp      loc_AAF4
loc_AB20:
            call    sub_AB25
            jp      hot_return_to_city
sub_AB25:
                call    restore_background
                call    revert_line_inv_lock_1
                call    load_card_image
                ret

;---------------------------------------------------------------------------------
restore_background:
			ld a,(can_use_letters)
			or a
			ret z
.loc_8E14:
			dec a
			ld (can_use_letters),a
			ld a,0xc9
			ld (nullsub_2),a
			ld a,0xeb			;opcode ex de,hl . reverse store function
			
store_background:
			ld (transfer_line.exd1),a
			ld (transfer_line.exd2),a
			push bc						
			ld a,(curpgc000)
			push af
			ld a,(curpg8000)
			push af
			
			ld a,(user_scr0_high)
			SETPGC000
			ld de,(screen_buffer_address)
			bit 6,d
			jr nz,.upperbuf			
			ld a,(scr_buff)
			jr .looo
.upperbuf			
			ld a,(scr_buff2)
			res 6,d				;0xc000 -> 0x8000
.looo
			SETPG8000
			ld hl,(frame_screen_address)
			;ld de,(screen_buffer_address)
			
			ld a,(count_of_vertical_lines_in_the_frame)
			add a,8
.loop1a:
			ld (transfer_line+1),hl
			call transfer_line
			ld bc,40-FRAME_BOX_WIDTH/2
			add hl,bc
			dec a
			jp nz,.loop1a

			ld hl,(frame_screen_address)
			set 5,h
			ld a,(count_of_vertical_lines_in_the_frame)
			add a,8
.loop1b:
			ld (transfer_line+1),hl
			call transfer_line
			ld bc,40-FRAME_BOX_WIDTH/2
			add hl,bc
			dec a
			jp nz,.loop1b

			ld a,(user_scr0_low)
			SETPGC000

			ld hl,(frame_screen_address)
			ld a,(count_of_vertical_lines_in_the_frame)
			add a,8
.loop2a:			
			ld (transfer_line+1),hl
			call transfer_line
			ld bc,40-FRAME_BOX_WIDTH/2
			add hl,bc
			dec a
			jp nz,.loop2a

			ld hl,(frame_screen_address)
                        set 5,h
			ld a,(count_of_vertical_lines_in_the_frame)
			add a,8
.loop2b:			
			ld (transfer_line+1),hl
			call transfer_line
			ld bc,40-FRAME_BOX_WIDTH/2
			add hl,bc
			dec a
			jp nz,.loop2b


			pop af
			SETPG8000
			pop af
			SETPGC000
			pop bc
			ret
;---------------			
transfer_line:
			ld hl,0
.exd1:		nop
			ld bc,FRAME_BOX_WIDTH/2
.loop:		
			dup 7
			ldi
			edup
			jp pe,.loop
.exd2		nop
			ret
;--------------------------------------------			
;--------------------------------------------			

print_menu_with_frame:
                ld      (max_letter_allowed), a ; in:
                                        ; a - максимально возможная буква для выбора опции
                                        ; пересчитываем ее в количество вертикальных строк для отображения меню исходя что высота японского шрифта 10 пикселей
                push    af
                inc     a               ; a+=1
                rr      a               ; a/2   ; т.к. на строке две буквы выбора
                ld      l, a
                add     a, a
                add     a, a
                add     a, a
                add     a, l
                add     a, l
                add     a, l            ; a*11   ; 11 каждая строка высотой 11 пикселей - 10 пикселей высота шрифта + 1 разделитель.
                inc     a
                ld      (count_of_vertical_lines_in_the_frame), a
                ld      a, (frame_horisontal_offset_type) ; определяет начиная с какого адреса рисовать рамку
                                        ; для портретов  - 0/1 выбирается случайно
                                        ; 0 - c1a0
                                        ; 1 - c190
                                        ; --2 устанавливается принудительно по центру экрана
                                        ; 2 - c198
                ld      hl, 0xc000+5*40+8			;0C1A0h - pc-88
                or      a
                jr      z, 1f
                ld      l,5*40 							;90h
                dec     a
                jr      z, 1f
                ld      l, 5*40+4						;98h
1
                ld      (frame_screen_address), hl
loc_8F89:
                ld      hl, G_BUFFER1					;133Ch
                ld      (screen_buffer_address), hl
                call    render_message_frame
                ld      a, 0xC9
                ld      (nullsub_2), a
                pop     bc
                ld      c, 0
                ld      hl, table_dialogue_questions_index_buffer
sub_8E93: 
                ld      a, 14h
                ld      (characters_to_print), a
                ld      (characters_in_text_line), a
                inc     b
                dec     b
                ret     z
                push    hl

;!!!!!!!!!! TODO TODO TODO вычисление экранного адреса для атм экрана
loop_8E9F:  
                ld      a, c            ; c - текущий отображаемый пункт в меню (который сейчас пишется на экран)
                and     0xFE            ; a = 0 / 1  - нечетный / четный столбец по регистру С
                add     a, a
                ld      l, a            ; l - 0 / 2
                ld      h, 0x6e			;??????          0DCh-pc-88
                call    mul_h_l         ; hl = 0 / 0xb8
				
                ld      de, 5*40+1		;??????         192h=5*80  pc-88		;нечетный столбец
                ld      a, c
                and     1
                jr      z, _loc_8EB4
                ld      de,	5*40+10+0x2000			;??? 1A5h        ; нечётный столбец  0x1a5-0x192 =  0x13; 
				
_loc_8EB4:
                add     hl, de
                ld      de, (frame_screen_address)
                add     hl, de
                ld      (text_screen_address_current), hl
;                inc     hl
                inc     hl
                ld      (text_screen_address), hl
                ld      a, 5
                ld      (symbol_color), a
                ld      a, c
loc_8EC8:
                add     a, 10h
                call    print_char
                ld      a, 29h ; 'y'
                call    print_char
                pop     hl
                ld      e, (hl)
                inc     hl
                push    hl
                ld      d, 0
                ld      hl, A650_strings
                call    find_string_by_de
                ld      a, 7
                ld      (symbol_color), a
                call    print_text_line
                inc     c
                djnz    loop_8E9F
                pop     hl
                ret
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
render_message_frame:
				ld      a, (can_use_letters)
				inc     a
				ld      (can_use_letters), a
                xor     a
                call    store_background ; копируем в буффер часть экрана, где будет рисоваться рамка и меню.
                ld      hl, (frame_screen_address)
                ld      de, FRAME_BOX_WIDTH/2			;2Ah  - pc-88
                add     hl, de
				
                xor     a
                ld      d, a
                ld      e, a
                call    draw_frame_line
                ld      de,0x07E0		;d - левый бортик e - правй бортик рамки
                dec     a
                call    draw_frame_line
                ld      de, 1FF8h
                call    draw_frame_line
                ld      de, 3FFCh
                call    draw_frame_line
                ld      a, (count_of_vertical_lines_in_the_frame) ; сколько пиксельных строк в рабочей области рисуемого окна. Исходя из того что высота шрифта 10 пикселей.
                ld      xl, a
                xor     a
.loop
                call    draw_frame_line ; draw vertical border
                dec     xl
                jr      nz, .loop
                dec     a
                call    draw_frame_line ; draw bottom horisontal line
                ld      de, 1FF8h
                call    draw_frame_line
                ld      de, 7E0h
                call    draw_frame_line
                xor     a
                ld      d, a
                ld      e, a

draw_frame_line:
; линия длиной 24 байта из которых 2 - граница
; e - байт описывающий левую границу
; d - байт описывающий правую границу
; a - байт описывающий заливку самого окна.
				set 5,h
                ld      (.setaddr2+1), hl
				ld      (.setaddr4+1), hl
				res 5,h
				ld 		(.setaddr1+1),hl
				ld 		(.setaddr3+1),hl
				ld l,a
				push af
				ld a,(curpgc000)
				push af
				ld a,(user_scr0_high)
				SETPGC000
                ld      (.storesp+1), sp
                di
.setaddr2:
                ld      sp, 0
                ld      h, e
                push    hl
				inc sp
                ld      h,l
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
				push    hl
.setaddr1:
                ld      sp, 0
                push    hl
				inc sp
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                ld      l, d
                push    hl
.storesp:
                ld      sp, 0
				ld a,(user_scr0_low)
				SETPGC000
                ld      (.storesp2+1), sp
.setaddr4:
                ld      sp, 0
                ld      h, 7
                ld      l, h
                push    hl
				inc sp
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
				push    hl

.setaddr3:
                ld      sp, 0
                push    hl
				inc sp
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                push    hl
                ld      hl,0x3d			; 7Ah  - pc88
                add     hl, sp			;<-new screen adress
.storesp2:
                ld      sp, 0
                ei
				pop af
				SETPGC000
				pop af
                ret
				
				
print_text_header:
                call    wait_for_user_decision
                call    locret_9132
                call    highlight_letter_selection
                ld      e, a
                ld      d, 0
                ld      hl, table_dialogue_questions_index_buffer
                add     hl, de
                ld      a, (hl)
                ld      (temp_location_id), a
                ld      e, a
                push    af
                ld      hl, 0xc000+157*40+3				;0F116h
                ld      (text_screen_address), hl
                dec     hl
                ld      (text_screen_address_current), hl
                ld      bc, 0A19h
                call    clear_window
                ld      a, 1
                ld      (characters_to_print), a
                ld      a, 6
                ld      (symbol_color), a
                ld      hl, A650_strings
                call    find_string_by_de
                ld      a, 0Eh
                call    print_char
                call    print_text_line
                inc     a
                ld      (keep_top_text_line), a
                call    print_char
                pop     af
                ret
;------------------------------------------------------------------------

goto_new_location:
				ld sp,sp_main
                push af
                call restore_background
                call load_card_image
                pop af
                add     a, a
                ld      c, a
                ld      b, 0
                ld      hl, locations_table-2
                add     hl, bc
                ld      a, (hl)
                inc     hl
                ld      h, (hl)
                ld      l, a
                call    jump_hl
                jp      hot_return_to_city
locations_table:
				dw location_ACD9
				dw location_ACEB
				dw location_AD13
				dw location_AD3F
				dw location_AD92
				dw location_ADDC
				dw location_AD8D
				dw location_AE30
				dw location_AE7E
				dw location_AEDB
				dw location_AED1
				dw location_AED6
				dw location_AF96
				dw location_AFCC
				dw location_in_front_of_jed_office_gamestart
				dw location_B0E5
				dw location_investigation_break
				dw load_saved_state
				dw location_B100
				dw location_B154
				dw location_B162
				dw location_B168	;archive records
				dw location_B1EE
				dw location_B2E8
				dw location_B315
				dw location_B382
				dw location_B40D
				dw location_B432
				dw location_B4B8
				dw location_B523
				dw location_B549
				dw location_B5B7
				dw location_B698
				dw location_B6D3
				dw location_B72C
				dw location_B7B5
				dw location_B837
				dw location_B893
				dw location_B8C6
				dw location_B8CB
jump_hl:
		jp (hl)

;TODO
;/////////////////////////////////////////////////////////////////////////////////////////

resume_investigation
				ld a,1
				call load_mus
				call clear_loc_screen
				call load_card_image
                call    load_card_image
                call    location_B0E5
                ld      hl, 43Ah
                ld      (txt_string_id), hl
                jp      hot_return_to_city
;/////////////////////////////////////////////////////////////////////////////////////////



sub_AC1E:
                ld      (preserve_hl+1), hl
                ld      hl, (txt_string_id)
                call    cp_hl_de
                ret     nz
                ld      a, (load_text_module+1)
                cp      b
                ret     nz
                ld      a, c
                ld      (temp_location_id), a
                call    get_pointer_to__gamestate_main_by_A
                ld      de, 5
                add     hl, de
                bit     5, (hl)
                jr      nz, preserve_hl
                set     5, (hl)
                add     a, 14h
                call    load_item_image
                call    print_text_at_location
                call    show_msg_hit_return_key
                call    load_card_image
                ret
preserve_hl:
                ld      hl, 0
                ld      (txt_string_id), hl
                ret
show_msg_hit_return_key
                ld      hl, 0xc000+157*40+18			;0F134h
                ld      (text_screen_address), hl
                ld      hl, msg_hit_return_key
                ld      a, 2
                ld      (characters_to_print), a
                ld      (symbol_color), a
                call    print_text_line
loc_92A8:
				ld a,(keymatrixix+1)
				bit 0,a
				jr z,loc_92A8
loc_92A8a:
                xor     a
                call    wait_for_key_input
                inc     a
                jr      nz, loc_92A8a

loc_92B4:		ret
msg_hit_return_key:       db 34h, 34h, 17h, 18h, 23h, 0CFh, 21h, 14h, 23h, 24h, 21h, 1Dh, 34h, 34h, 0FFh


sub_8F58:
                call    print_menu_with_frame
                call    print_text_header
                push    af
                call    restore_background
                pop     af
                ret
				
;================================	
location_ACD9:
                call    remove_npc_portrait
                ld      a, 0Bh
                call    restore_background_load_image
                ld      hl, 1
                ld      a, l
                ld      (location_id), a
                jp      loc_AC13
				
location_ACEB:
                ld      a, 6Bh ; 'k'
                call    restore_background_load_portrait
                ld      a, 25h ; '%'
                ld      (temp_location_id_byte_b9ea), a
                ld      hl,  gamestate_main+126h
                ld      a, 10h
                ld      de, 384h
                bit     3, (hl)
                jr      z, loc_AD0D
                ld      de, 371h
                call    randomizer_pseudo
                rrca
                ld      a, 3
                jr      nc, loc_AD0D
                inc     de
loc_AD0D:
                ld      (location_id), a
                jp      loc_AC12

location_AD13:
                ld      a, 6Ch ; 'l'
                call    restore_background_load_portrait
                ld      a, 26h ; '&'
                ld      (temp_location_id), a
                ld      (temp_location_id_byte_b9ea), a
                ld      a, 13h
loc_AD22:
                ld      b, 0AFh
                ld      (loc_AD3C), a
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      a, 0Fh
                ld      de, 307h
                ld      bc, 6
                add     hl, bc
                bit     3, (hl)
                jr      z, loc_AD3D
                ld      de, 2F4h
                ld      a, 2
loc_AD3C:
                inc     de
loc_AD3D:
                jr      loc_AD0D
				
location_AD3F:
                ld      hl, loc_AD79
                call    execute_hl
                call    print_menu_with_frame
loc_AD48:
                call    print_text_header
                call    sub_ABF1
                call    get_pointer_to__gamestate_by_temp_location_id
                inc     hl
                inc     hl
                ld      de, 5
                bit     1, (hl)
                jr      z, loc_AD74
                push    hl
                call    sub_AC64
                ld      de, 305h
                add     hl, de
                ex      de, hl
                pop     hl
                bit     0, (hl)
                jr      z, loc_AD74
                inc     de
                bit     3, (hl)
                jr      nz, loc_AD73
                inc     hl
                inc     hl
                bit     0, (hl)
                jr      z, loc_AD74

loc_AD73:                               ; CODE XREF: seg002:AD6Bj
                inc     de

loc_AD74:                               ; CODE XREF: seg002:AD58j
                                        ; seg002:AD66j ...
                call    sub_AC17
                jr      loc_AD48
; ---------------------------------------------------------------------------

loc_AD79:                               ; DATA XREF: seg002:location_AD3Fo
                                        ; seg002:loc_ADDCo
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
                ld      a, (temp_location_id_byte_b9ea)
                cp      c
                ret     z
                bit     4, (hl)
                jr      nz, loc_AD8A
                bit     5, (hl)
                ret     z

loc_AD8A:                               ; CODE XREF: seg002:AD85j
                jp      loc_ABA8
			
location_AD8D:
                ld      hl, 3DCh
                jr      loc_AD95
				

location_AD92:
                ld      hl, 332h
loc_AD95:
                ld      (loc_ADB6+1), hl
                ld      hl, loc_ADD0
                call    execute_hl
                ld      de, 6
                jp      z, loc_AC12
                call    print_menu_with_frame
loc_ADA7:
                call    print_text_header
                push    af
                add     a, 14h
                call    load_item_image
                pop     af
                sub     64h ; 'd'
                call    sub_AC64
loc_ADB6:
                ld      de, 0
                add     hl, de
                ex      de, hl
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      c, 5
                add     hl, bc
                bit     2, (hl)
                jr      z, loc_ADCB
                inc     de
                bit     1, (hl)
                jr      z, loc_ADCB
                inc     de
loc_ADCB:
                call    sub_AC17
                jr      loc_ADA7
loc_ADD0:
                ld      e, 5
                add     hl, de
                bit     5, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                jp      loc_ABA8


location_ADDC:
                ld      hl, loc_AD79
                call    execute_hl
                call    print_menu_with_frame
loc_ADE5:
                call    print_text_header
                call    sub_ABF1
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      de, 3AFh
                dec     a
                jr      z, loc_AE05
                inc     hl
                inc     hl
                ld      de, 3DEh
                bit     1, (hl)
                jr      z, loc_AE05
                call    sub_AC64
                ld      bc, 3B1h
                add     hl, bc
                ex      de, hl
loc_AE05:
         
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      bc, 6
                add     hl, bc
                bit     6, (hl)
                jr      z, loc_AE2B
                inc     de
                dec     hl
                dec     hl
                bit     0, (hl)
                dec     hl
                dec     hl
                jr      nz, loc_AE1D
                bit     3, (hl)
                jr      z, loc_AE2B
loc_AE1D:
                inc     de
                inc     hl
                inc     hl
                inc     hl
                bit     2, (hl)
                jr      z, loc_AE2B
                inc     de
                bit     1, (hl)
                jr      z, loc_AE2B
                inc     de
loc_AE2B:
                call    sub_AC17
                jr      loc_ADE5

location_AE30:
                ld      hl, loc_AE6D
                call    execute_hl
                call    print_menu_with_frame
loc_AE39:
                call    print_text_header
                call    sub_ABE1
                ld      a, e
                call    sub_AC64
                ld      de, 382h
                add     hl, de
                ex      de, hl
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      c, 4
                add     hl, bc
                bit     5, (hl)
                jr      z, loc_AE58
                inc     de
                bit     3, (hl)
                jr      z, loc_AE58
                inc     de
loc_AE58:
                ld      (txt_string_id), de
                ld      hl, 2ACh
                ld      de, 388h
                ld      bc, 476h
                call    sub_AC1E
                call    print_text_at_location
                jr      loc_AE39
loc_AE6D:
                ld      e, 4
                add     hl, de
                bit     6, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                ld      a, c
                call    sub_ABE1
                ret     nz
                jp      loc_ABA8

location_AE7E:
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                bit     6, (hl)
                ld      de, 0Ah
                jr      nz, loc_AECE
                push    hl
                ld      hl, 107h
                call    sub_AC86
                ex      de, hl
                pop     hl
                bit     3, (hl)
                jr      nz, loc_AECE
                dec     de
                ld      a, 0Dh
                bit     0, (hl)
                jr      z, loc_AECB
                inc     hl
                inc     hl
                inc     hl
                bit     0, (hl)
                jr      z, loc_AEA6
                inc     a
loc_AEA6:
                ld      (location_id), a
                inc     hl
                bit     5, (hl)
                jr      z, loc_AECE
                dec     hl
                dec     hl
                ld      a, (hl)
                and     3Eh ; '>'
                jr      z, loc_AEB8
                ld      de, 9
loc_AEB8:
                call    sub_AC17
                ld      a, 5
                call    load_text_module
                ld      a, (temp_location_id_byte_b9ea)
                dec     a
                ld      (word_B9EC), a
                pop     hl
                jp      loc_AAE9
loc_AECB:
                ld      (location_id), a
loc_AECE:
                jp      loc_AC12
				

location_AED1:
                ld      hl, 148h
                jr      loc_AEDE
location_AED6:
                ld      hl, 14Ah
                jr      loc_AEDE
location_AEDB:
                ld      hl, 146h
loc_AEDE:
                call    sub_AC93
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_b9ea
                ld      c, 6
                add     hl, bc
                bit     1, (hl)
                jp      z, loc_AF92
                inc     de
                bit     0, (hl)
                jp      z, loc_AF8F
                ld      a, (temp_location_id_byte_b9ea)
                dec     a
                dec     a
                jr      z, loc_AF22
                dec     a
                jr      z, loc_AF0D
                dec     a
                jr      z, loc_AF05
                dec     a
                jr      z, loc_AF1B
                jr      loc_AF28
loc_AF05:
                ld      a, (gamestate_main+3D0h)
                cp      28h ; '('
                jp      nz, loc_AF8F
loc_AF0D:
                ld      a, (gamestate_main+3E0h)
                cp      4
                jr      nz, loc_AF8F
                ld      a, (gamestate_main+3C0h)
                cp      4
                jr      nz, loc_AF8F

loc_AF1B:
                ld      a, (gamestate_main+3D8h)
                cp      0Ch
                jr      nz, loc_AF8F

loc_AF22:
                ld      a, (gamestate_main+3C8h)
                dec     a
                jr      nz, loc_AF8F

loc_AF28:
                ld      a, (temp_location_id_byte_b9ea)
                ld      hl, 14Ch
                call    sub_AC93
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                set     3, (hl)
                ld      hl,  gamestate_main+13h
                cp      2
                jr      z, loc_AF47
                ld      hl,  gamestate_main+1Bh
                cp      5
                jr      nz, loc_AF49
loc_AF47:
                res     0, (hl)
loc_AF49:
                ld      b, 3
loc_AF4B:
                push    bc
                call    sub_AC17
                call    show_msg_hit_return_key
                ld      de, (txt_string_id)
                inc     de
                pop     bc
                djnz    loc_AF4B
                ld      (txt_string_id), de
                ld      hl, 4A9h
                ld      de, 4BFh
                ld      bc, 56Bh
                call    sub_AC1E
                ld      hl, 139h
                ld      de, 14Fh
                ld      bc, 574h
                call    sub_AC1E
                call    print_text_at_location
                ld      a, (temp_location_id_byte_b9ea)
                cp      4
                jp      z, location_B968
                cp      5
                jp      z, location_B972
                cp      3
                jp      z, location_B972
                pop     hl
                jp      loc_AAE9
loc_AF8F:
                jp      loc_AC12
loc_AF92:
                set     2, (hl)
                jr      loc_AF8F

location_AF96:
                ld      hl, loc_AFC3
loc_AF99:
                call    execute_hl
                call    sub_8F58
                sub     28h ; '('
                ld      (byte_B9F2), a
                ld      l, a
                ld      h, 0
                add     hl, hl
                ld      de, 9
                add     hl, de
                ld      (txt_string_id), hl
                call    restore_background_load_image
                xor     a
                ld      (temp_location_id_byte_b9ea), a
                ld      a, 6
                ld      (location_id), a
                ret
loc_AFBC:
                ld      a, (byte_B9F2)
                add     a, 28h ; '('
                cp      c
                ret     z
loc_AFC3:
                inc     hl
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
				jp      loc_ABA8
;===
location_AFCC:	;library
                ld      a, (temp_location_id_byte_b9ea+1)
                ld      hl,  gamestate_main+0CBh
                cp      11h
                jp      z, loc_B09F
                ld      hl,  gamestate_main+43h
                cp      0Dh
                jp      z, loc_B09F
loc_AFDF:
                ld      a, (file_index)
                inc     a
                call    restore_background_load_image
                ld      a, (temp_location_id_byte_b9ea+1)
                add     a, 32h ; '2'
                call    get_pointer_to__gamestate_main_by_A
                ld      bc, 5
                add     hl, bc
                bit     0, (hl)
                jp      nz, loc_B093
                dec     hl
                dec     hl
                bit     0, (hl)
                jr      nz, loc_B04D
loc_AFFD:
                ld      hl, loc_B0AF
                call    execute_hl
                ld      a, (table_dialogue_questions_index_buffer)
                ld      (temp_location_id), a
                call    sub_ACA5
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                add     a, 46h ; 'F'
                call    restore_background_load_portrait
                pop     hl
                inc     hl
                ld      a, (hl)
                call    load_text_module
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      1Ah
                jp      z, loc_AD22+1
                cp      12h
                ld      a, 4
                jr      z, loc_B07D
                add     a, a
                ld      (location_id), a
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                bit     6, (hl)
                ex      de, hl
                jr      z, loc_B045
                ld      hl, 126h
                call    sub_AC6C
loc_B03D:
                ex      de, hl
                bit     4, (hl)
                jr      z, loc_B043
                inc     de
loc_B043:
                jr      loc_B059
loc_B045:
                ld      hl, 11Ah
                call    sub_AC86
                jr      loc_B03D
loc_B04D:
                ld      a, 9
                ld      (location_id), a
                ld      hl, 21h ; '!'
                call    sub_AC9C
                ex      de, hl
loc_B059:
                ld      a, (temp_location_id_byte_b9ea)
                cp      0Ah
                ld      a, (temp_location_id_byte_b9ea+1)
                jr      nz, loc_B06D
                cp      7
                jr      nz, loc_B06D
                ld      de, 28Ch
loc_B06A:
                jp      loc_AC12
loc_B06D:
                cp      0Fh
                jr      nz, loc_B06A
                ld      hl,  gamestate_main+5Ch
                bit     0, (hl)
                jr      z, loc_B06A
                ld      de, 459h
                jr      loc_B06A
loc_B07D:
                ld      (location_id), a
                ld      de, 41Bh
                call    get_pointer_to__gamestate_main_by_b9ea
                ld      bc, 6
                add     hl, bc
                bit     4, (hl)
                jr      z, loc_B08F
                inc     de
loc_B08F:
                set     4, (hl)
                jr      loc_B059
loc_B093:
                ld      de, 69h ; 'i'
                call    sub_AC17
                call    show_msg_hit_return_key
                jp      location_B382
loc_B09F:
                bit     0, (hl)
                jp      z, loc_AFDF
                ld      a, (file_index)
                add     a, 2
                call    restore_background_load_image
                jp      loc_AFFD
loc_B0AF:
                ld      e, (hl)
                inc     hl
                inc     hl
                inc     hl
                bit     1, (hl)
                ret     z
loc_B0B6:
                ld      a, c
                cp      28h ; '('
                ret     nc
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      e
                ret     nz
                bit     0, (hl)
                ret     nz
                jp      loc_ABA8
loc_B0C5:
                ld      e, (hl)
                ld      a, (temp_location_id_byte_b9ea)
                cp      c
                ret     z
                inc     hl
                inc     hl
                inc     hl
                jr      loc_B0B6
				


load_saved_state:
				ld bc,32768
33				dec bc
				ld a,b
				or c
				jr nz, 33b

                ld      hl, 0xc000+5*40	;0C190h
                ld      de, msg_file_to_load
                call    menu_choose_file_to_load
                jp      c, loc_AB18     ; SPACE pressed. restore screen
				
				add a,"1"
				ld (saveslot),a
				ld de,savename
				call openstream_file
				or a
				jp nz,loc_AB18	;no file
				ld hl,gamestate_len
				ld de,gamestate
                call readstream_file
                ;or a
                ;jp nz,filereaderror 
                call closestream_file
				
				ld bc,32768
33				dec bc
				ld a,b
				or c
				jr nz, 33b
				
				ld      de, 43Ch
				call    sub_AC17
				jp      loc_AB18
msg_file_to_load:       db 1Bh, 1Eh, 10h, 13h, 95h, 0B1h, 15h, 18h, 1Bh, 14h, 0A2h, 79h, 0FFh




location_B100:
                ld      hl, loc_B143
                call    execute_hl
                jr      z, loc_B12F
loc_B108:
                call    sub_8F58
                sub     32h ; '2'
                ld      (temp_location_id_byte_b9ea+1), a
                ld      a, 7
                ld      (location_id), a
                ld      hl, 1Fh
                call    sub_AC9C
                ex      de, hl
                call    get_pointer_to__gamestate_by_temp_location_id
                inc     hl
                inc     hl
                bit     1, (hl)
                jr      z, loc_B126
                inc     de
loc_B126:
                ld      (txt_string_id), de
                dec     hl
                ld      a, (hl)
                jp      restore_background_load_image
loc_B12F:
                ld      hl, (byte_B9F2)
                ld      h, 0
                add     hl, hl
                ld      de, 0Ah
                add     hl, de
loc_B139:
                jp      loc_AC13

loc_B13C:
                ld      a, (temp_location_id_byte_b9ea+1)
                add     a, 32h ; '2'
                cp      c
                ret     z
loc_B143:
                ld      a, (byte_B9F2)
                cp      (hl)
                ret     nz
                inc     hl
                inc     hl
                inc     hl
                bit     6, (hl)
                ret     z
                bit     5, (hl)
                ret     z
                jp      loc_ABA8

location_B154:
                ld      hl, loc_B13C
                call    execute_hl
                jp      nz, loc_B108
                ld      hl, 3
                jr      loc_B139


location_B162:
                ld      hl, loc_AFBC
                jp      loc_AF99


location_B1EE:
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                bit     6, (hl)
                jp      nz, loc_B29D
                ld      hl, loc_B2BC
                call    execute_hl
                call    print_menu_with_frame
loc_B201:
                call    print_text_header
                call    get_pointer_to__gamestate_main_by_A
                ld      e, (hl)
                inc     hl
                ld      a, (hl)
                cp      3
                jr      nz, loc_B215
                ld      a, (temp_location_id)
                call    sub_ABD1
                inc     e
loc_B215:
                ld      d, 0
                ld      hl, 11Ch
                add     hl, de
                add     hl, de
                call    sub_AC86
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                ld      a, (temp_location_id)
                cp      0A0h
                jr      z, loc_B235
                cp      7Eh ; '~'
                jr      z, loc_B23F
                call    sub_B24E
                jr      loc_B201
loc_B235:
                bit     0, (hl)
                jr      z, loc_B23A
loc_B239:
                inc     de
loc_B23A:
                call    sub_B25A
                jr      loc_B201
loc_B23F:
                bit     2, (hl)
                jr      z, loc_B23A
                bit     3, (hl)
                jr      z, loc_B239
                ld      hl, 0FFECh
                add     hl, de
                ex      de, hl
                jr      loc_B23A
sub_B24E:
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      bc, 4
                add     hl, bc
                bit     4, (hl)
                jr      z, sub_B25A
                inc     de
sub_B25A:
                ld      (txt_string_id), de
                ld      hl, 1F9h
                ld      de, 1F4h
                ld      bc, 166h
                call    sub_AC1E
                ld      hl, 2ADh
                ld      de, 2B4h
                ld      bc, 469h
                call    sub_AC1E
                ld      hl, 299h
                ld      de, 29Dh
                ld      bc, 378h
                call    sub_AC1E
                ld      hl, 32Fh
                ld      de, 32Ch
                ld      bc, 36Fh
                call    sub_AC1E
                ld      hl, 25Dh
                ld      de, 257h
                ld      bc, 372h
                call    sub_AC1E
                jp      print_text_at_location

loc_B29D:
                ld      hl, loc_B2D6
                call    execute_hl
                call    print_menu_with_frame
loc_B2A6:
                call    print_text_header
                call    sub_ABB1
                ld      d, 0
                ld      hl, 126h
                add     hl, de
                add     hl, de
                call    sub_AC6C
                ex      de, hl
                call    sub_B24E
                jr      loc_B2A6

loc_B2BC:
                inc     hl
                ld      a, (hl)
                inc     hl
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
                bit     6, (hl)
                ret     z
                cp      2
                jr      z, loc_B2D3
                cp      3
                ret     nz
                ld      a, c
                call    sub_ABD1
                ret     nz
loc_B2D3:
                jp      loc_ABA8

loc_B2D6:
                ld      a, c
                inc     hl
                inc     hl
                inc     hl
                inc     hl
                bit     6, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                call    sub_ABB1
                ret     nz
                jp      loc_ABA8

location_B2E8:
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                bit     6, (hl)
                ex      de, hl
                ld      hl, 100h
                jr      nz, loc_B2FA
                call    sub_AC86
                jr      loc_B2FD

loc_B2FA:
                call    sub_AC6C
loc_B2FD:
                ex      de, hl
                bit     0, (hl)
                jr      z, loc_B312
                inc     de
                ld      c, 4
                add     hl, bc
                bit     6, (hl)
                jr      z, loc_B312
                inc     de
                sbc     hl, bc
                bit     3, (hl)
                jr      z, loc_B312
                inc     de
loc_B312:
                jp      loc_AC12

location_B315:
                call    get_pointer_to__gamestate_main_by_b9ea
                cp      0Ah
                jr      nz, loc_B327
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      7
                ld      de, 28Dh
                jp      z, sub_AC17

loc_B327:
                inc     hl
                inc     hl
                push    hl
                bit     6, (hl)
                jr      nz, loc_B35A
                bit     3, (hl)
                jr      nz, loc_B370
                ld      a, (location_id)
                cp      0Dh
                jr      nz, loc_B340
                ld      a, (load_text_module+1)
                cp      5
                jr      z, loc_B379
loc_B340:
                ld      a, 0Ah
                ld      (location_id), a
                ld      de, 8
                pop     hl
                ld      bc, 4
                add     hl, bc
                bit     4, (hl)
                jr      z, loc_B358
                ld      hl, 105h
                call    sub_AC86
loc_B357:
                ex      de, hl
loc_B358:
                jr      loc_B312

loc_B35A:
                ld      hl, 102h
                call    sub_AC6C
                ld      a, 0Bh
                ld      (location_id), a
                ex      de, hl
                pop     hl
                bit     4, (hl)
                jr      z, loc_B36C
                inc     de

loc_B36C:
                set     4, (hl)
                jr      loc_B358


loc_B370:
                pop     hl
                ld      hl, 10Bh
                call    sub_AC86
                jr      loc_B357

loc_B379:
                pop     hl
                ld      hl, 140h
                call    sub_AC93
                jr      loc_B357



location_B40D:
                ld      hl, 108h
                call    sub_AC86
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                bit     4, (hl)
                jr      z, loc_B42D
                inc     de
                ld      c, 4
                add     hl, bc
                bit     5, (hl)
                jr      z, loc_B42F
                inc     de
                sbc     hl, bc
                bit     3, (hl)
                jr      z, loc_B42F
                inc     de
loc_B42D:
                set     4, (hl)
loc_B42F:
                jp      loc_AC12


location_B432:
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                bit     6, (hl)
                jr      nz, loc_B45B
                ld      hl, loc_B47C
                call    execute_hl
                call    print_menu_with_frame
loc_B444:
                call    print_text_header
                ld      e, a
                dec     e
                ld      d, 0
                ld      hl, 132h
                call    sub_AC86
                add     hl, de
                add     hl, de
                call    sub_B49E
                call    sub_AC17
                jr      loc_B444
loc_B45B:
                ld      hl, loc_B490
                call    execute_hl
                call    print_menu_with_frame

sub_B464:
                call    print_text_header
                call    sub_ABC1
                ld      hl, 112h
                call    sub_AC6C
                ld      d, b
                add     hl, de
                add     hl, de
                call    sub_B49E
                call    sub_AC17
                call    sub_B464
loc_B47C:
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
                ld      a, (temp_location_id_byte_b9ea)
                cp      c
                ret     z
                bit     4, (hl)
                jr      nz, loc_B48D
                bit     5, (hl)
                ret     z
loc_B48D:
                jp      loc_ABA8
loc_B490:
                inc     hl
                inc     hl
                ld      a, (hl)
                and     30h ; '0'
                ret     z
                ld      a, c
                call    sub_ABC1
                ret     nz
                jp      loc_ABA8

sub_B49E:
                ex      de, hl
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      c, 4
                add     hl, bc
                cp      8
                jr      z, loc_B4B4
                cp      0Ch
                jr      z, loc_B4B4
                inc     hl
                inc     hl
                bit     4, (hl)
loc_B4B1:
                ret     z
                inc     de
                ret
loc_B4B4:
                bit     0, (hl)
                jr      loc_B4B1


location_B4B8:
                 call    get_pointer_to__gamestate_main_by_b9ea
                 inc     hl
                 inc     hl
                 bit     6, (hl)
                 jr      nz, loc_B4C9
                 ld      hl, 10Eh
                 call    sub_AC86
                 jr      loc_B4CF
 
loc_B4C9:
                 ld      hl, 107h
                 call    sub_AC6C
loc_B4CF:
                 ld      (word_B9E7), hl
                 ld      hl, loc_B513
                 call    execute_hl
                 call    print_menu_with_frame
loc_B4DB:
                 call    print_text_header
                 sub     78h ; 'x'
                 add     a, a
                 ld      e, a
                 ld      a, 0Ch
                 sub     e
                 add     a, a
                 add     a, a
                 or      46h ; 'F'
                 ld      (loc_B4FE+1), a
                 ld      d, 0
                 ld      hl, (word_B9E7)
                 add     hl, de
                 ex      de, hl
                 call    get_pointer_to__gamestate_main_by_b9ea
                 inc     hl
                 inc     hl
                 bit     6, (hl)
                 jr      nz, loc_B508
                 inc     hl
                 inc     hl
loc_B4FE:
                bit     0, (hl)
loc_B500:
                 jr      z, loc_B503
                 inc     de
loc_B503:
                 call    sub_AC17
                 jr      loc_B4DB

loc_B508:
                 call    get_pointer_to__gamestate_by_temp_location_id
                 inc     hl
                 inc     hl
                 inc     hl
                 inc     hl
                 bit     4, (hl)
                 jr      loc_B500
 
loc_B513:
                 inc     hl
                 ld      a, (hl)
                 dec     a
                 ret     nz
                 inc     hl
                 inc     hl
                 inc     hl
                 bit     6, (hl)
                 ret     z
                 bit     7, (hl)
                 ret     z
                 jp      loc_ABA8



location_B523:
                ld      hl, loc_ADD0
                call    execute_hl
                jp      z, loc_B88E
                call    print_menu_with_frame
loc_B52F:
                call    print_text_header
                push    af
                add     a, 14h
                call    load_item_image
                ld      hl, 0FFh
                call    sub_AC6C
                pop     af
                sub     32h ; '2'
                ld      c, a
                add     hl, bc
                ex      de, hl
                call    sub_AC17
                jr      loc_B52F

location_B549:
                call    sub_B595
                ex      de, hl
                ld      a, (temp_location_id_byte_b9ea)
                cp      1Ah
                jr      z, loc_B591
                push    de
                ld      hl, loc_B0C5
                call    execute_hl
                pop     de
                jr      z, loc_B591
                push    af
                call    sub_AC17
                pop     af
                call    sub_8F58
                call    sub_ACA5
                add     a, 46h ; 'F'
                call    restore_background_load_portrait
                call    get_pointer_to__gamestate_by_temp_location_id
                inc     hl
                ld      a, (hl)
                call    load_text_module
                ld      a, 8
                ld      (location_id), a
                inc     hl
                bit     6, (hl)
                jr      z, loc_B588
                ld      hl, 113h
                call    sub_AC6C
                jr      loc_B58E


loc_B588:
                ld      hl, 11Ch
                call    sub_AC86
loc_B58E:
                jp      loc_AC13
loc_B591:
                inc     de
                jp      loc_AC12

sub_B595:
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                bit     6, (hl)
                jr      nz, loc_B5AB
                ld      a, (load_text_module+1)
                cp      5
                jr      nz, loc_B5B1
                ld      hl, 142h
                jp      sub_AC93
loc_B5AB:
                ld      hl, 105h
                jp      sub_AC6C

loc_B5B1:
                ld      hl, 10Ch
                jp      sub_AC86


location_B5B7:
                ld      a, (temp_location_id_byte_b9ea+1)
                add     a, 32h ; '2'
                ld      (temp_location_id), a
                call    sub_B640
                ex      de, hl
                call    get_pointer_to__gamestate_by_temp_location_id
                inc     hl
                inc     hl
                inc     hl
                bit     3, (hl)
                jr      z, loc_B591
                call    sub_AC17
                call    show_msg_hit_return_key
                call    remove_npc_portrait
loc_B5D6:
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      9
                jr      z, loc_B5E7
                cp      15h
                jr      z, loc_B5EB
                cp      17h
                jr      z, loc_B5EB
                jr      loc_B5F5

loc_B5E7:
                ld      a, 22h ; '"'
                jr      loc_B5F2

loc_B5EB: 
                call    get_pointer_to__gamestate_by_temp_location_id
                inc     hl
                ld      a, (hl)
                add     a, 2

loc_B5F2:
                call    restore_background_load_image
loc_B5F5:
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      a, (hl)
                add     a, 28h ; '('
                call    get_pointer_to__gamestate_main_by_A
                ld      a, (hl)
                call    load_text_module
                ld      a, 0Ch
                ld      (location_id), a
                ld      a, (temp_location_id_byte_b9ea+1)
                ld      hl, 418h
                ld      b, 4Dh ; 'M'
                cp      9
                jr      z, loc_B633
                ld      hl, 38Ah
                ld      b, 52h ; 'R'
                cp      15h
                jr      z, loc_B633
                ld      hl, 39Eh
                ld      b, 57h ; 'W'
                cp      17h
                jr      z, loc_B633
                ld      hl, 3F8h
                ld      b, 5Ch ; '\'
                cp      2
                jr      z, loc_B633
                ld      hl, 408h
                ld      a, 60h ; '`'
loc_B633:
                ld      (byte_B9F5), hl
                ld      a, b
                ld      (word_B9F7), a
                ld      hl, 7
                jp      loc_AC13

sub_B640:
                ld      a, (location_id)
                sub     9
                jr      z, loc_B669
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                inc     hl
                bit     6, (hl)
                jr      nz, loc_B65D
                ld      a, (load_text_module+1)
                cp      5
                jr      nz, loc_B663
                ld      hl, 140h
                jp      sub_AC93
loc_B65D:
                ld      hl, 107h
                jp      sub_AC6C
loc_B663:
                ld      hl, 10Eh
                jp      sub_AC86
loc_B669:
                pop     hl
                ld      hl, 24h ; '$'
                call    sub_AC9C
                ex      de, hl
                call    get_pointer_to__gamestate_by_temp_location_id
                inc     hl
                inc     hl
                inc     hl
                inc     hl
                bit     0, (hl)
                jp      z, loc_AC12
                dec     de
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      9
                jp      nz, loc_AFFD
                ld      a, (file_index)
                inc     a
                call    restore_background_load_image
                ld      hl,  gamestate_main+63h
                bit     0, (hl)
                jp      nz, loc_B5D6
                jp      loc_AFFD

location_B698:
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      9
                jr      z, loc_B6CA
                ld      a, 8
                ld      (location_id), a
                ld      a, (temp_location_id_byte_b9ea)
                add     a, 46h ; 'F'
                call    restore_background_load_portrait
                call    get_pointer_to__gamestate_main_by_b9ea
                inc     hl
                ld      a, (hl)
                call    load_text_module
                inc     hl
                bit     6, (hl)
                jr      nz, loc_B6C1
                ld      hl, 11Ah
                call    sub_AC86
                jr      loc_B6C7

loc_B6C1:
                ld      hl, 113h
                call    sub_AC6C
loc_B6C7:
                jp      loc_AC13

loc_B6CA:
                ld      hl, 21h ; '!'
                call    sub_AC9C
                jp      loc_AC13


location_B6D3:
                ld      hl, loc_B71E
                call    execute_hl
                call    print_menu_with_frame
loc_B6DC:
                call    print_text_header
                call    get_pointer_to__gamestate_main_by_A
                push    af
                inc     hl
                ld      a, (hl)
                ld      (word_B9F7+1), a
                pop     af
                ld      hl, (word_B9F7)
                sub     l
                ld      l, a
                dec     l
                ld      h, 0
                add     hl, hl
                add     hl, hl
                ld      de, (byte_B9F5)
                add     hl, de
                ex      de, hl
                call    get_pointer_to__gamestate_by_temp_location_id
                inc     hl
                inc     hl
                inc     hl
                bit     1, (hl)
                ld      a, (word_B9F7+1)
                push    af
                call    get_pointer_to__gamestate_main_by_A
                ld      bc, 5
                add     hl, bc
                pop     af
                jr      nz, loc_B71A
                inc     de
                bit     5, (hl)
                jr      nz, loc_B715
                inc     de
loc_B715:
                call    sub_AC17
                jr      loc_B6DC
loc_B71A:
                set     3, (hl)
                jr      loc_B715
loc_B71E:
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      (hl)
                ret     nz
                inc     hl
                inc     hl
                inc     hl
                bit     2, (hl)
                ret     z
                jp      loc_ABA8

location_B72C:
                ld      hl, loc_B77F
                ld      d, 0
                call    execute_hl
                ld      e, 4
                jp      z, loc_AC12
                jr      loc_B748

location_B73B:
                ld      hl, loc_B77F
                ld      d, 0
                call    execute_hl
                ld      e, 4
                jp      z, loc_AC12
loc_B748:
                call    sub_8F58
                ld      (word_B9F7+1), a
                add     a, 14h
                call    load_item_image
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      de, 5
                add     hl, de
                set     5, (hl)
                ld      hl, loc_B7A2
                call    execute_hl
                ld      a, (table_dialogue_questions_index_buffer)
                call    get_pointer_to__gamestate_main_by_A
                inc     hl
                inc     hl
                inc     hl
                res     1, (hl)
                ld      hl, (word_B9F7)
                sub     l
                ld      l, a
                ld      h, 0
                add     hl, hl
                add     hl, hl
                ld      de, (byte_B9F5)
                add     hl, de
                dec     hl
                jp      loc_AC13

loc_B77F:
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      (hl)
                ret     nz
                inc     hl
                inc     hl
                inc     hl
                bit     2, (hl)
                ret     z
                dec     hl
                dec     hl
                ld      a, (hl)
                call    get_pointer_to__gamestate_main_by_A
                ld      e, 5
                add     hl, de
                bit     3, (hl)
                ret     z
                bit     5, (hl)
                ret     nz
                ld      hl, (loc_ABA8+1)
                ld      (hl), a
                inc     hl
                ld      (loc_ABA8+1), hl
                ret

loc_B7A2:
                ld      a, (temp_location_id_byte_b9ea+1)
                cp      (hl)
                ret     nz
                inc     hl
                ld      a, (word_B9F7+1)
                cp      (hl)
                ret     nz
                inc     hl
                inc     hl
                bit     1, (hl)
                ret     z
                jp      loc_ABA8


location_B7B5:
                ld      hl, loc_B821
                call    execute_hl
                call    print_menu_with_frame
loc_B7BE:
                call    print_text_header
                ld      a, (load_text_module+1)
                cp      5
                jr      nz, loc_B7FC
                call    get_pointer_to__gamestate_by_temp_location_id
                ld      a, (hl)
                ld      e, a
                add     a, a
                add     a, e
                ld      e, a
                ld      d, 0
                ld      hl, 125h
                add     hl, de
                call    sub_AC93
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_b9ea
                ld      c, 6
                add     hl, bc
                bit     4, (hl)
                jr      z, loc_B7F7
                inc     de
                bit     3, (hl)
                jr      z, loc_B7F7
                inc     de
                dec     hl
                bit     0, (hl)
                jr      z, loc_B7F7
                ld      a, 0Eh
                ld      (location_id), a
                jp      loc_AB20

loc_B7F7:
                call    sub_AC17
                jr      loc_B7BE

loc_B7FC:
                call    sub_B80B
                jr      loc_B7F7
loc_B801:
                ld      b, 5Dh ; ']'
                call    loc_B80D
                call    sub_AC17
                jr      loc_B842

sub_B80B:
                ld      b, 5Ah ; 'Z'
loc_B80D: 
                call    randomizer_pseudo
                and     3
                jr      z, loc_B80D
                add     a, b
                ld      l, a
                ld      h, 0
                ld      de, 0FFh
                add     hl, de
                call    sub_AC86
                ex      de, hl
                ret

loc_B821:
                ld      b, 5
loc_B823:
                inc     hl
                ld      a, (hl)
                cp      b
                ret     nz
                inc     hl
                inc     hl
                inc     hl
                bit     6, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                jp      loc_ABA8


loc_B833:
                ld      b, 1
                jr      loc_B823

location_B837:
                ld      hl, loc_ADD0
                call    execute_hl
                jr      z, loc_B88E
                call    print_menu_with_frame
loc_B842:
                call    print_text_header
                add     a, 14h
                call    load_item_image
                ld      a, (load_text_module+1)
                cp      5
                jr      nz, loc_B801
                call    get_pointer_to__gamestate_by_temp_location_id
                push    hl
                sub     65h ; 'e'
                ld      e, a
                ld      d, 0
                ld      hl, 100h
                add     hl, de
                add     hl, de
                call    sub_AC93
                ex      de, hl
                pop     hl
                ld      c, 5
                add     hl, bc
                bit     2, (hl)
                jr      z, loc_B885
                bit     0, (hl)
                jr      z, loc_B880
                inc     de
                call    get_pointer_to__gamestate_main_by_b9ea
                add     hl, bc
                bit     0, (hl)
                jr      z, loc_B880
                ld      a, 0Eh
                ld      (location_id), a
                jp      loc_AB20
loc_B880:
                call    sub_AC17
                jr      loc_B842
loc_B885:
                ld      hl, 144h
                call    sub_AC93
                ex      de, hl
                jr      loc_B880
loc_B88E:
                ld      e, 6
                jp      loc_AC12

location_B893: 
                ld      hl, 2F8h
loc_B896:
                ld      (loc_B8AE+1), hl
                ld      hl, loc_B833
                call    execute_hl
                call    print_menu_with_frame
loc_B8A2:
                call    print_text_header
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                sub     79h ; 'y'
                call    sub_AC64
loc_B8AE:
                ld      de, 2F8h
                add     hl, de
                ex      de, hl
                pop     hl
                ld      c, 4
                add     hl, bc
                bit     5, (hl)
                jr      z, loc_B8C1
                inc     de
                bit     3, (hl)
                jr      z, loc_B8C1
                inc     de
loc_B8C1:
                call    sub_AC17
                jr      loc_B8A2

location_B8C6:
                ld      hl, 375h
                jr      loc_B896

location_B8CB:
                ld      a, (location_id)
                ld      de, 2F6h
                cp      0Fh
                jr      z, loc_B8D8
                ld      de, 373h
loc_B8D8:
                call    get_pointer_to__gamestate_main_by_b9ea
                ld      bc, 6
                add     hl, bc
                bit     4, (hl)
                jr      z, loc_B8F0
                inc     de
                set     3, (hl)
                cp      26h ; '&'
                ld      a, 2
                jr      z, loc_B8ED
                inc     a
loc_B8ED:
                ld      (location_id), a
loc_B8F0:
                set     4, (hl)
                jp      loc_AC12
			
location_investigation_break:
                ;ld      a, 98h;file number to load
loc_AA3A:
                call    no_mus
				ld a,2
				call load_mus
				ld a,0x0d
				ld (load_image_directly),a
				call load_image
				xor a
				ld (load_image_directly),a
				xor     a
				ld      (load_card_image+1), a
				ld      (print_location_menu.loc_8f39+1), a
				
				
loc_AA9C:
                call    bar_rest_menu

loc_AA9F:
                call    wait_for_user_input
                ld      hl, (loc_9029+1)		;loc_9133 pc99
                push    hl
                jp      z, investigation_statistcs
                dec     a
                jp      z, deduction
				
				
                ld      de, msg_AF45
                call    menu_choose_file_to_load
                jr      c, .loc_AD9D
				add a,"1"
				ld (saveslot),a
				
				ld de,savename
				call openstream_file
				or a
				jr z,.savef
				
				ld de,savename
				OS_CREATEHANDLE
                ;OR A
                ;JP NZ,filecreateeerror
                ld a,b
                ld (filehandle),a
.savef:
				ld hl,gamestate_len
				ld de,gamestate
;savestream_file
;de=buf
;hl=size
				ld a,(filehandle)
				ld b,a
				OS_WRITEHANDLE ;->hl=actual size
                ;or a
                ;jp nz,filewriteerror 
                call closestream_file
				
				ld bc,32768
33				dec bc
				ld a,b
				or c
				jr nz, 33b
.loc_AD9D:
                call    restore_background
loc_AAD4:
                pop     hl
                call    sub_9136
                jp      loc_AA9F
				
				
				
				
				
bar_rest_menu:
                ld      hl, 0xc000 + 5*40+1		;0C192h
                ld      (frame_screen_address), hl
                ld      hl, G_BUFFER2
                ld      (screen_buffer_address), hl
                ld      a, 23h ; '#'
                ld      (count_of_vertical_lines_in_the_frame), a
                call    render_message_frame
                xor     a
                ld      (characters_to_print), a
                ld      a, 4
                ld      (symbol_color), a
                ld      a, 0Eh
                ld      (characters_in_text_line), a
                ld      hl, 0xc000+10*40+7+0x2000		;  0C32Fh
                ld      (text_screen_address), hl
                ld      hl, msg_AF55
                call    print_text_line
                ld      hl, 0xc000+17*40+1				; 0C552h
                ld      (frame_screen_address), hl
                ld      a, 1
                ld      (loc_8EC8+1), a		;ld      (loc_8FD2+1), a
                ld      c, 0
                ld      b, 3
                ld      hl, unk_AF52
                call    sub_8E93			;loc_8F9D
                ld      a, 10h
                ld      (loc_8EC8+1), a			;ld      (loc_8FD2+1), a
                ;ld      a, 0C9h
                ;ld      (loc_94BA), a
                ret				
				
				
				
wait_for_user_input:
                ld      hl, 0xc000+17*40+1			;0C552h   
                ld      (frame_screen_address), hl

.loc_AEF0:
                xor     a
                call    wait_for_key_input
                dec     a
                cp      3
                jr      c, 1f
                cp      1Ah
                jr      z, .loc_AF20
                ld      (.loc_AF20+1), a
                jr      .loc_AEF0
1
                push    af
                call    highlight_letter_selection
                xor     a
                ld      (.loc_AF20+1), a
                pop     af
                or      a
                ret				
.loc_AF20:
                ld      a, 1
                or      a
                jr      z, .loc_AEF0

                call    sub_AF31
                call    no_mus
                jp      resume_investigation
sub_AF31:
                ld      hl,0xc000+5*40+1			; 0C192h
                ld      (frame_screen_address), hl
                ld      hl, G_BUFFER2
                ld      (screen_buffer_address), hl
                ld      a, 0x23
                ld      (count_of_vertical_lines_in_the_frame), a
                jp      restore_background

investigation_statistcs:
				ld hl,0xc000+60*40+6
				ld      (frame_screen_address), hl
				ld      hl, G_BUFFER1
				ld      (screen_buffer_address), hl
				ld      a, 0x45
				ld      (count_of_vertical_lines_in_the_frame), a
				call    render_message_frame
				ld      hl,0xc000+65*40+12 	;0D468h
				ld      (text_screen_address), hl
				ld      a, 5
				ld      (symbol_color), a
				ld      a, 0x0F
				ld      (characters_in_text_line), a
				ld      hl, msg_bar_s
				call    print_text_line
				ld      hl,0xc000+66*40+7			;0D4AEh
				ld      (text_screen_address), hl
				
				ld      hl, MSG_AF5E
				ld      a, 3
				call    sub_AB9D
				ld      hl, func_ABD8
				ld      de, 0FFEAh  
				call    loc_ABB0
				push    hl
				ld      a, 41h ; 'A'
				call    display_percentage
				
				ld      hl, MSG_AF64
				ld      a, 6
				call    sub_AB9D
				ld      hl, func_ABE8
				ld      de, 0FFFFh
				call    loc_ABB0
				push    hl
				ld      a, 91h
				call    display_percentage
				
				ld      hl, MSG_AF6A
				ld      a, 1
				call    sub_AB9D
				ld      hl, func_AC0C
				ld      de, 0
				call    loc_ABB0
				push    hl
				ld      a, 40h ; '@'
				call    display_percentage
				
				ld      hl, MSG_AF70
				ld      a, 4
				call    sub_AB9D
				ld      hl, func_AC19
				ld      de, 0FFF4h
				call    loc_ABB0
				push    hl
				ld      a, 41h ; 'A'
				call    display_percentage
				
				ld      hl, MSG_AF75
				ld      a, 2
				call    sub_AB9D
				pop     hl
				pop     de
				add     hl, de
				pop     de
				add     hl, de
				pop     de
				add     hl, de
				ld      a, 3
				call    div_hl_a
				ld      a, 71h ; 'q'
				call    display_percentage
.loop:
                xor     a
                call    wait_for_key_input
                cp      1Bh
                jr      z, .loc_AB94
                jr      .loop
.loc_AB94:
                call    restore_background
                jp      loc_AAD4

sub_AB9D:
                ld      (symbol_color), a
                push    hl
                ld      hl, (text_screen_address)
                ld      de, 11*40 		;370h        ; adress offset
                add     hl, de
                ld      (text_screen_address), hl
                pop     hl
                jp    print_text_line


loc_ABB0:
                push    de
                ld      (.loc_ABC8+1), hl
					ld 		hl,(0)
					push hl
					ld 		hl,(2)
					push hl
                ld      hl, 0CC8h
                ld      (0), hl
                ld      a, 0C9h
                ld      (2), a
                ld      d, 0
                ld      hl, gamestate_main
                ld      bc, 0AC00h
.loop:
                push    hl
.loc_ABC8:
                call    0
                pop     hl
                ld      de, 8
                add     hl, de
                djnz    .loop
					pop hl
					ld (2),hl
					pop hl
					ld (0),hl
                ld      l, c
                ld      h, 0
                pop     de
                add     hl, de
                ret
func_ABD8:
                ld      e, 4
                add     hl, de
                bit     3, (hl)
                rst     0
                bit     4, (hl)
                rst     0
                bit     5, (hl)
                rst     0
                bit     6, (hl)
                rst     0
                ret
func_ABE8:
                inc     hl
                inc     hl
                bit     3, (hl)
                rst     0
                bit     4, (hl)
                rst     0
                ld      e, 4
                add     hl, de
                bit     0, (hl)
                rst     0
                bit     1, (hl)
                rst     0
                bit     2, (hl)
                rst     0
                bit     3, (hl)
                rst     0
                bit     4, (hl)
                rst     0
                bit     5, (hl)
                rst     0
                bit     6, (hl)
                rst     0
                bit     7, (hl)
                rst     0
                ret
func_AC0C:
                ld      e, 5
                add     hl, de
                bit     0, (hl)
                rst     0
                bit     2, (hl)
                rst     0
                bit     5, (hl)
                rst     0
                ret
func_AC19:
                inc     hl
                inc     hl
                bit     0, (hl)
                rst     0
                bit     1, (hl)
                rst     0
                bit     2, (hl)
                rst     0
sub_AC24:
                inc     hl
                bit     3, (hl)
                rst     0
                bit     5, (hl)
                rst     0
                ret

display_percentage:
                ld      h, 64h
                call    mul_h_l
                call    div_hl_a
                ld      a, l
                push    hl
;                call    draw_percent_line
                pop     hl
				
                ld      b, 3
.loop1:
                ld      a, 0Ah
                call    div_hl_a
                push    af
                djnz    .loop1
				
                ld      hl, (text_screen_address)
                ld      de, 16+0x2000			;21h ; '!'
                add     hl, de
                ld      b, 2
.loop2:
                pop     af
                or      a
                jr      nz, 1f
				
                nextcolumnhl		;inc hl
				
                djnz    .loop2
                pop     af
1
                inc     b
                ld      (text_screen_address_current), hl
                jr      .loc_AF22
.loop3:
                pop     af
.loc_AF22:
                call    print_char
                djnz    .loop3
                ld      a, 0CCh		;!!!!!!!!!!!!!!!!!!!!!!! "%"
                call    print_char
                ret
;---------------------
print_suspect_option:
                push    af
                push    hl
                push    de
                push    bc
                ld      a, (byte_AF91)
                ld      l, a
                ld      h, 0x6e; 37h ; '7'
               ; add     hl, hl
                add     hl, hl
                call    mul_h_l
                ld      de,15*40+30+0xc000	; 0C4ECh
                add     hl, de
                ld      (text_screen_address), hl
                ld      bc, 0x0A09	;12h
                call    clear_window
                add     a, 78h ; 'x'
                call    get_pointer_to__gamestate_main_by_A
                ld      e, (hl)
                ld      d, 0
                ld      hl, A650_strings
                call    find_string_by_de
                ld      a, 5
                ld      (symbol_color), a
                call    print_text_line
                pop     bc
                pop     de
                pop     hl
                pop     af
                ret

sub_ADA9:
                ld      hl, 10*40+19+0xc000			;0C346h
                ld      (frame_screen_address), hl
                ld      hl,G_BUFFER1
                ld      (screen_buffer_address), hl
				ld 		hl,3
                ld      de, (gamestate_main+3DCh)
                bit     6, e
                jr      z, .loc_ADC7
                inc     l
                ld      de, (gamestate_main+3E4h)
                bit     6, e
                jr      z, .loc_ADC7
                inc     l
.loc_ADC7:
                ld      a, l
                ld      (loc_ACDA+1), a
                inc     l
                ld      h, 0Bh
                call    mul_h_l
                ld      a, l
                inc     a
                ld      (count_of_vertical_lines_in_the_frame), a
                ret
;----------------------------------------

deduction:
				call sub_AF31
				call    sub_ADA9
				call    render_message_frame
				ld      a, 3
				ld      (symbol_color), a
				ld      hl, 15*40+22+0x2000+0xc000		;0C4DDh
				ld      (text_screen_address), hl
				ld      hl, MSG_AF7B
				call    print_text_line
				ld      a, 5
				ld      (symbol_color), a

loc_ACDA:
                ld      b, 0
                xor     a
.loop:
				inc     a
				push    bc
				push    af
				ld      (byte_AF91), a
				ld      l, a
				ld      h, 0x6e	;37h ; '7'		370h vertcal offset 11 pix
				add     hl, hl
			;	add     hl, hl
				call    mul_h_l
				ld      de, 15*40+20+0xc000		;0C4D8h
				add     hl, de
				ld      (text_screen_address_current), hl
				call    print_char
				ld      a, 29h ; ':'
				call    print_char
				inc     hl
				inc     hl
				ld      (text_screen_address), hl
				pop     af
				push    af
				ld      l, a
				add     a, 78h ; 'x'
				ld      e, a
				ld      d, 0
				ld      hl, A650_strings
				ld      (characters_to_print), a
				call    find_string_by_de
				ld      a, 7
				ld      (symbol_color), a
				call    print_text_line
				call    print_suspect_option
				pop     af
				pop     bc
				djnz    .loop

				
loc_AD1F:
         ;       call    smth_mouse
bloc_AD22:
                xor     a
                call    wait_for_key_input
                dec     a
                ld      hl, (loc_ACDA)
                cp      h
                jr      c, loc_AD4A
                cp      1Ah
                jr      z, loc_AD61
                jr      bloc_AD22


loc_AD4A:;suspects list selector
                inc     a
                ld      (byte_AF91), a
                add     a, a
                call    highlight_letter_selection
                call    loc_AE1A
                call    sub_ADA9
                xor     a
                ld      (nullsub_2), a
                call    nullsub_2
                jr      loc_AD1F

loc_AD61:
                call    sub_ADA9
                ld      a, 1
                ld      (can_use_letters), a
                call    restore_background
                jp      loc_AA9C

sub_ADD7:
                ld      hl, table_dialogue_questions_index_buffer
                ld      (loc_ADFA+1), hl
                ld      c, 1
                ld      hl, gamestate_main
loc_ADE2:
                push    hl
                call    sub_AE03
                pop     hl
                ld      de, 8
                add     hl, de
                inc     c
                ld      a, c
                cp      0ADh
                jr      nz, loc_ADE2
                ld      a, (loc_ADFA+1)
                sub     LOW table_dialogue_questions_index_buffer
                ret     nc
                neg
                ret

loc_ADFA:
                ld      hl, table_dialogue_questions_index_buffer
                ld      (hl), c
                inc     hl
                ld      (loc_ADFA+1), hl
                ret

sub_AE03:
                ld      a, c
                cp      0A9h
                jr      z, loc_AE18
                inc     hl
                inc     hl
                cp      28h ; '('
                jr      z, loc_AE11
                bit     7, (hl)
                ret     z

loc_AE11:
                bit     4, (hl)
                jr      nz, loc_AE18
                bit     5, (hl)
                ret     z
loc_AE18:
                jr      loc_ADFA



loc_AE1A:
                ld      (loc_AE94+1), sp
         ;       call    smth_mouse2
                ld      hl, G_BUFFER3		;2500h
                ld      (loc_8F89+1), hl
                ld      a, 1
                ld      (frame_horisontal_offset_type), a
                ld      a, 18h
                ld      (loc_9401), a
                ld      hl, loc_AE94
                ld      (loc_9420+1), hl
                call    sub_ADD7
                call    print_menu_with_frame
                call    wait_for_user_decision
                ld      e, a
                ld      d, 0
                ld      hl, table_dialogue_questions_index_buffer
                add     hl, de
                ld      a, (hl)
                push    af
                ld      a, (byte_AF91)
                ld      e, a
                ld      d, 0
                ld      hl, lll_a-1
                add     hl, de
                ld      b, (hl)
                add     a, 78h ; 'x'
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                ld      a, (hl)
                call    get_pointer_to__gamestate_main_by_A
                ld      e, 4
                add     hl, de
                ld      a, b
                cpl
                and     (hl)
                ld      (hl), a
                pop     hl
                pop     af
                ld      (hl), a
                call    get_pointer_to__gamestate_main_by_A
                add     hl, de
                ld      a, b
                or      (hl)
                ld      (hl), a
                call    print_suspect_option

loc_AE72:
                ;ld      a, 0C9h
                ;ld      (loc_94BA), a
                call    restore_background
                call    sub_ADA9
                ld      hl, G_BUFFER1		;1990h
                ld      (loc_8F89+1), hl
                ld      a, 2
                ld      (frame_horisontal_offset_type), a
                ld      a, 28h ; '('
                ld      (loc_9401), a
                ld      hl, loc_AB18		;0AB18h
                ld      (loc_9420+1), hl
                ret
; ---------------------------------------------------------------------------

loc_AE94:
                ld      sp, 0
                jr      loc_AE72

lll_a:          db  20h
                db  10h
                db    8
                db    4
                db    2
byte_AF91:		db    0



temp_text_pointer	dw 0
location_B968
				call    show_msg_hit_return_key
				call    no_mus
				call 	set_p_mod
				ld 		a,4
				call 	load_mus

				call fade_toblack		
				call clear_loc_screen
				ld hl,mempal
				ld de,pal
				ld bc,32
				ldir 
				ld a,1
				ld (setpalflag),a
				halt
	
				ld      a, 6
				call    load_text_module
				ld      hl, temp_text_pointer
				ld      (print_text_at_location.loc_9166+2), hl
				ld      hl, 0FFh
				ld      (temp_text_pointer), hl
				call    print_text_and_advance
				call    print_text_and_advance
				call    advance_music
				
				ld de,ep1_img
				call load_gfd
				call draw_image_stripes
				
                call    print_text_and_advance
                call    print_text_and_advance
                call    print_text_and_advance

				ld de,ep2_img
				call load_gfd
				call draw_image_stripes

				call    print_text_and_advance
				call    print_text_and_advance
				call    print_text_and_advance
				call    print_text_and_advance
				call    print_text_and_advance
				call    print_text_and_advance
				
				call    advance_music

				ld de,ep3_img
				call load_gfd
				call draw_image_stripes
				
				call    print_text_and_advance
				call    print_text_and_advance
				call    print_text_and_advance
				call    print_text_and_advance
				call    advance_music
				call    print_text_and_advance
				
				ld de,ep4_img
				call load_gfd
				call draw_image_stripes

				call    print_text_and_advance
				call    advance_music
				call    print_text_and_advance


				ld de,ep5_img
				call load_gfd
				call draw_image_stripes
				
				

				call    advance_music
				call    print_text_and_advance
				call    print_text_and_advance
				call    skip_text_line
				call    advance_music

				call wait_mus_end

				call fade_toblack		
				call clear_loc_screen
				ld hl,mempal
				ld de,pal
				ld bc,32
				ldir 
				ld a,1
				ld (setpalflag),a
				halt

				call    print_final_text
				call    show_msg_hit_return_key
				
				
				ld sp,sp_main
				ret
				
				
				;;;;
						call set_text_pages
.loc_907c:
		ld hl,TEXT_START
		call find_string_by_de
		
		ld de,text_buffer
		ld bc,text_buffer_len
		ldir
		call unset_text_pages
		;;;;
		
		
print_text_and_advance:
				ld      hl, (temp_text_pointer)
				inc     hl
				ld      (temp_text_pointer), hl
				call    print_text_at_location
				call    show_msg_hit_return_key
				ret
skip_text_line:                         ; CODE XREF: seg003:ABD1p
                ld      hl, (temp_text_pointer)
                inc     hl
                ld      (temp_text_pointer), hl
                jp      print_text_at_location
				


		display "exec_j_code_ends: ",/d,$
font	incbin "_jpn/game_font.bin"		
        display "exec_j_full_ends: ",/d,$	
			ENT
ri_end:
	savebin "kissofmurder/exec_j.bin",ri_start,ri_end-ri_start
	ENDMODULE