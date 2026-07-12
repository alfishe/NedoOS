	MODULE exec_r
ri_start:

		DISP T_START		
;		call load_card_image
return_to_city:		
		call location_in_front_of_jed_office_gamestart
hot_return_to_city:
		call print_text_at_location
loc_ADCB:
		call print_location_menu

loc_ADCE
		call wait_for_user_decision
		jr loc_ADCE

A650_strings:
		include "_rus/r_A650.asm"
menu_strings_table:		;строки текста для вывода меню
		include "_rus/r_menu.asm"		
		
MSG_B2ED:       db "Какой ФАЙЛ нужно СОХРАНИТЬ?",0xff
unk_B2FA:       db 0xB1,0xB2,0xB3
MSG_B2FD:       db "Меню 'Перерыв в расследовании'", 0FFh
MSG_B307:       db "Сбор информации", 0FFh
MSG_B30C:       db "Взаимоотношения", 0FFh
MSG_B312:       db "Найдено улик   ", 0FFh
MSG_B317:       db "Опрошено людей ", 0FFh
MSG_B31C:       db "Общий прогресс ", 0FFh
MSG_B321:       db "Для выбора  используйте ENTER", 0FFh
MSG_B33F:       db " Имя", 0FFh
MSG_B344:       db " Местоположение", 0FFh
MSG_B34A:       db " Район", 0FFh		
;===================================
sub_AF67:
                call    get_pointer_to__gamestate_main_by_8D27value
                inc     hl
                inc     hl
                inc     hl
                bit     4, (hl)
                jr      z, .loc_AF86
                add     a, 0x1F
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
.loc_AF86:
                jp      load_card_image
;============================================
;enter_pressed_loc_B07C char print subr
subsub_b07c:
				call load_image
				ld hl,0x0536
				ld (draw_line_on_screen.lp1),hl
				ld (draw_line_on_screen.lp2),hl
                ld      hl, 0xc000+11*40+30	;  0C3ACh pc-88
                call      display_image_from_buffer_with_addr
				ld hl,0x771a
				ld (draw_line_on_screen.lp1),hl
				ld (draw_line_on_screen.lp2),hl
				ret
;============================================
sub_8a0c:
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
; ---------------------------------------------------------------------------
location_B436:
                ld      hl, func_B4DC
                call    func_AE47
                jp      z, loc_B4D5
                ld      hl, 9
                ld      (txt_string_id), hl
                push    af
                call    print_text_at_location
                pop     af
                call    sub_8E4E
                call    sub_8a0c
                ld      a, 1
                ld      (portrait_lock), a
                call    get_pointer_to__gamestate_main_by_8D27value
                push    hl
				
			call store_48c
				
                ld      a, (hl)
                add     a, 0x8D
				ld hl,IMG_BUFFER
				call load_image_waddr
				ld a,0x8d
				ld hl,IMG_BUFFER+1836
				call load_image_waddr
				pop     hl
				inc     hl
				ld      a, (hl)
				push    af
				call    get_pointer_to__gamestate_main_by_A
				inc     hl
				inc     hl
				inc     hl
				set     4, (hl)
				pop     af				
				add     a, 1Fh
				ld      hl, IMG_BUFFER+16384+1024
				call 	load_image_waddr

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


				call    get_pointer_to__gamestate_main_by_8D27value
				ld      a, (hl)
				add     a, a
				ld      c, a
				ld      b, 0
				ld      hl, (word_8d22)
				add     hl, bc
				ld      c, 0xF8
				add     hl, bc
				ld      (txt_string_id), hl
				push    hl
				call    print_text_at_location ; show 'news' message
				call    sub_928C        ; show msg 'hit return key', wait for enter
				pop     hl
				inc     hl
				ld      (txt_string_id), hl
				call    print_text_at_location ; show continuation of news message
				call    sub_928C        ; show msg 'hit return key', wait for enter
				ld      a, 0x54
				call    load_image
				xor     a
				ld      a, 0x22
				call    load_portrait_image
				ld      hl, (word_8d22)
				ld      de, 0x15E
				add     hl, de
				jr      loc_B4D8
loc_B4D5:
                ld      hl, 0x0C
loc_B4D8:
                xor     a
                jp      loc_B55E
func_B4DC:
                inc     hl
                inc     hl
                ld      a, (hl)
                cp      0x63
                ret     nz
                ld      de, 4
                add     hl, de
                bit     6, (hl)
                ret     z
                jp      func_AE6D
;-------
;---------------------------------------------------
menu_choose_file_to_load:               ; CODE XREF: seg004:AD7Ep
                ld      (frame_screen_address), hl
                ld      (loc_964F+1), de
                push    hl
                ld      hl, G_BUFFER2
                ld      (screen_buffer_address), hl
                ld      a, 0x18
                ld      (count_of_vertical_lines_in_the_frame), a
                call    render_message_frame
                xor     a
                ld      (characters_to_print_byte_8D53), a
                ld      a, 6
                ld      (symbol_color), a
                ld      a, 30
                ld      (characters_in_text_line), a
                pop     hl
                push    hl
                ld      de, 5*40+2	;194h
                add     hl, de
                ld      (text_screen_address), hl

loc_964F:                               ; DATA XREF: seg003:9625w
                ld      hl, 0
                call    print_text_line
                ld      a, 0x0E
                ld      (characters_in_text_line), a
                pop     hl
                push    hl
                ld      de, 12*40		;3C0h
                add     hl, de
                ld      (frame_screen_address), hl
                ld      a, "1"
                ld      (loc_8EC8+1), a
                ld      c, 0
                ld      b, 2
                ld      hl, menu_strings_index_array_table_unk_96AF ; массив номеров строк которые используются для выбора текстовых строк для отображения меню
                call    sub_8E93
                ld      a, "A"
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
sub_969F:                               ; CODE XREF: seg003:96AAp
                ld      (frame_screen_address), hl
                or      a
                ret
SPACE_is_pressed:                       ; CODE XREF: seg003:968Aj
                                        ; seg003:9690j
                pop     hl
                call    sub_969F
                scf
                ret
;-----
			
print_text_at_location:
;clear bottom part of window based on 'keep_top_text_line' default = 0 clear whole
		ld hl,0xc000+167*40+1	
		ld bc,0x2127		;39*2 = 78 знакомест.  высота - 33 линии
		ld a,(keep_top_text_line)
		or a
		jr nz,.kp_top_line
		ld hl,0xc000+156*40+1		;
		ld b,0x2c
.kp_top_line:
		call clear_window
		xor a
		ld (keep_top_text_line),a
		ld (characters_to_print_byte_8D53),a
		
		ld hl,0xc000+168*40+2				;text scr addr
		ld (text_screen_address),hl
		ld a,7
		ld (symbol_color),a
		
		ld a,0x24*2
		ld (characters_in_text_line),a
		
		
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
;send cmd 2 + A E
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
		
		ld hl,8*40
		ld (do_cr.hgt),hl
		ld hl,text_buffer
		call print_text_line 
		ld hl,11*40
		ld (do_cr.hgt),hl
		
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
		cp 0x39
		call z,.sub_90ba
		cp 0x40
		call z,.sub_90ba
		call get_pointer_to__gamestate_main_by_A		
		add hl,de
.loc_90b6:
		set 0,(hl)
		jr .loc_908d
		
.sub_90ba:
		push af
		ld a,e
		cp 4
		jr nz,1f
		ld a,(.loc_90b6+1)
		cp 0xde				;????
		jr nz,1f
		ld a,0x0e
		ld (byte_8d1f),a
1		pop af
		ret

.seek_prev_string:
		dec a
		dec hl
2		dec hl
		cp (hl)
		jr nz,2b
		inc hl
		jr .loc_9082

.loc_90d7:
                push    af
                ld      a, (unk_8d2b)
                ld      l, a
                add     a, a
                add     a, l
                ld      l, a
                ld      h, 0            ; unk_8d2b*3
                ld      de, 0x03E6
                add     hl, de
                ex      de, hl          ; de = unk_8d2b*3+0x3e6
                pop     af
                dec     a
                jp      z, .loc_907c
                call    randomizer_pseudo
                dec     de
                rrca
                jp      nc,.loc_907c
                dec     de
                jp      .loc_907c


;non japaneese version
print_text_line:
				push hl,de,bc,af
				
				ld      de, (text_screen_address)
				ld      (text_screen_address_current), de
				ld      a, (characters_in_text_line)
				ld      c, a            ; 24h ??? at jb office entrance
                                ;here we remove special codes. all 0-255 chars in use
.loop:
				ld a,(hl)
				cp 0xff
				jr z,.end_of_string
                inc hl
				cp 0xf0
				jr z,.f0_modifier   ;quoted text
				call print_char
				call check_cr
				jr .loop
.end_of_string:
				nop
				pop af,bc,de,hl
.closed_bracket_print:
				ret
				push af
				ld a,0x22   ;0x0b
				call print_char
				ld a,0xc9
				ld (.closed_bracket_print),a
				pop af
				ret
.f0_modifier:
				ld      a,0x22 		;0x0a
				call    print_char
				dec     c
				xor     a
				ld      (.closed_bracket_print), a
				jr      .loop
check_cr:
				dec c
				ret nz
				ld a,(characters_in_text_line)
				ld c,a
do_cr:
				push hl
				ld hl,(text_screen_address)
.hgt = $+1				
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
				ld      b, a    ;char code
				ld      l, a
				ld      h, 0
				add     hl, hl
				add     hl, hl
				add     hl, hl
				ld      de, font
				add     hl, de         ;char code*8+font addr
				ld      de, (text_screen_address_current)
.print_single_char:				
				;TODO - two pass print. first - pixels attributes. second - draw attributes.

				ld a,(symbol_color)
				call fill_char_8x8_color				
				call print_char_8x8
				nextcolumnde		;inc     de
				ld      (text_screen_address_current), de
				
				call restore_c000
				pop 	af,bc,de,hl
				ret
				


fill_char_8x8_color:
				push af
				ld a,(user_scr0_low)
				SETPGC000
				pop af
				
                push    hl,de
				ex      de, hl
                ld      d,8
				ld 		e,a
                ld      bc, 40
.loc_lp:
                ld      (hl), e
                add     hl, bc
                dec     d
                jp      nz, .loc_lp
                pop     de,hl
                ret
				
				
print_char_8x8:
				ld a,(user_scr0_high)
				SETPGC000			
                push    hl,de
;                ld      a, 4
                ld      bc, 40
                ld      (.storesp+1), sp
                di
                ld      sp, hl
                ex      de, hl
;.loc_lp:    

                pop     de
                ld      (hl), e
                add hl,bc
                ld      (hl), d
                add     hl, bc
                pop     de
                ld      (hl), e
                add     hl, bc
                ld      (hl), d
                add     hl, bc

                pop     de
                ld      (hl), e
                add hl,bc
                ld      (hl), d
                add     hl, bc
                pop     de
                ld      (hl), e
                add     hl, bc
                ld      (hl), d
                add     hl, bc


;                dec     a
;                jp      nz, .loc_lp
.storesp: 
                ld      sp, 0
                pop     de,hl
                ei
                ret

;-----------------------------------------------------------------------------------------------
print_location_menu:
				ld a,(byte_8d1f)
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
				ld      (characters_to_print_byte_8D53), a
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
                dec     hl
;                dec     hl
;                prevcolumnhl  - alt version

                ld      (text_screen_address_current), hl
                ld      a, 5
                ld      (symbol_color), a
                ld      a, 8
                sub     b
                add a,"0"
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
                add     hl, de			        ;hl - screen address
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
                ld      c, 8            ; 0Bh          ; vertical lines to invert     8 lines for non jp version
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




;----------------------------------------------------------------------------
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
                dw location_at_jb_office
                dw location_AF9D
                dw location_B07F
                dw location_B0D1
                dw location_B12F
                dw location_B1C1
                dw location_B1E7
                dw travel_menu
                dw go_into_jed_office             ; здесь переход на оффис Jed
                dw location_in_front_of_jed_office_gamestart
                dw location_at_lions
                dw location_bar
                dw location_B3ED
                dw location_B436
                dw location_B4EC
                dw location_investigation_break
                dw load_saved_state
                dw location_B51D
                dw location_B59E
                dw location_B5AC
                dw location_B5B2
                dw location_B5D5
                dw location_B5F8
                dw location_B656
                dw location_B6AF
                dw location_B6CD
                dw location_B72D
                dw location_B79F
                dw location_B7DB
                dw location_B851
                dw location_B867
                dw location_B8BD
                dw location_B926
                dw location_B996
                dw location_B9CE
jump_hl:
		jp (hl)
loc_ADF2:
				ld sp,sp_main
                call    restore_background
                call    revert_line_inv_lock_1
                call    load_card_image
                jp      loc_ADCE
; ---------------------------------------------------------------------------
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
			jp loc_ADF2			

;---------------------------------------------------
func_AE47:
                ld      (.callhl+1), hl
                ld      hl, table_dialogue_questions_index_buffer_8D5D
                ld      (func_AE6D+1), hl
                ld      c, 1
                ld      hl, gamestate_main
.loop:
                push    hl
.callhl
                call    0
                pop     hl
                ld      de, 8
                add     hl, de
                inc     c
                ld      a, c
                cp      0xAF
                jr      nz,.loop
                ld      a, (func_AE6D+1)
                sub     LOW table_dialogue_questions_index_buffer_8D5D	
										; проверка что адрес соотвествует 8d5d и выше
                                        ; при переносе требуется соответствующая корректировка
                ret     nc
                neg                     ; требуется изучить поведение данного куска кода
                ret

func_B396: 
                push    hl
                ld      de, 4
                add     hl, de
                bit     1, (hl)
                pop     hl
                ret     z
func_B39F:
                inc     hl
                inc     hl
                ld      a, (location_id_8d28+1)
                cp      (hl)
                ret     nz
                inc     hl
                bit     7, (hl)
                ret     z
func_AE6D
		ld      hl, table_dialogue_questions_index_buffer_8D5D
		ld      (hl), c
		inc     hl
		ld      (func_AE6D+1), hl
		ret
func_AEA4:
               ld      a, (byte_8d2d)
               ld      c, a
               add     a, a
               add     a, c
               ld      c, a            ; c = 8d2d *3
               ld      a, (byte_8d2a)
               dec     a
               add     a, a
               add     a, a
               add     a, a
               add     a, c            ; (8d2a-1)*8 + (8d2d*3)
               ld      hl, (word_8d22)
               ld      c, a
               ld      b, 0
               add     hl, bc
               ret

func_AEBB:
                ld      a, (byte_8d33)
                dec     a
loc_AEBF:
                ld      l, a
                ld      h, 0x71
                call    mul_h_l
                ld      bc, (word_8d22)
                add     hl, bc
                ld      b, 0
                ld      a, (byte_8d2d)
                ld      c, a
                add     a, a
                add     a, c
                ld      c, a
                ld      a, (byte_8d2e)
                add     a, a
                add     a, a
                add     a, a
                add     a, c
                ld      c, a
                add     hl, bc
                ret
sub_AEDD:
                ld      a, (byte_8d2f)
                jr      loc_AEBF
func_AEE2: 
                ld      a, (load_text_module+1)
                cp      3
                ld      a, (hl)
                jr      nz,1f
                sub     5
1
                dec     a
                add     a, a
                add     a, a
                push    af
                call    sub_AEDD
                pop     af
                ld      c, a
                add     hl, bc
                ret
;---------------------------------------------------
sub_AE76:
                ld      hl, table_96FF   ; 14 bytes per entry ; min offset is1
                ld      d, 0x0E
                call    sub_AE99        ; search for value A in table HL.
                                        ; found - hl=addr of value,d=(0x0e-position in table)
                                        ; not found - d=0xff
                ret     z
sub_AE7F:
                ld      hl, 0
                ld      d, 0x0A
                jr      sub_AE99.loop
sub_AE86:         
                ld      hl, table_unk_9992
                ld      d, 0x0B
                jr      sub_AE99
sub_AE8D:
                ld      hl, data_unk_999D
                ld      d, 9
                jr      sub_AE99
sub_AE94:
                ld      hl, table_unk_9979
                ld      d, 0x19
sub_AE99:
                ld      e, 1
.loop
                cp      (hl)
                ret     z
                inc     hl
                inc     e
                dec     d
                jr      nz,.loop
                dec     d
                ret					
;===========================================================================================

location_in_front_of_jed_office_gamestart:
			ld a,1
			call load_mus
			ld a,4
			call load_text_module  ;modules_loader
			;in front of J.B. office
			ld a,0x51
			call load_image
			ld a,1
			ld (location_id_8d28+1),a
			inc a
			ld (byte_8d1f),a	;oo_location_menu_entries_8D1F

			ld a,0x9c
			ld (randomizer_pseudo.curr_line_counter),a
			ld hl, vertial_coordinates_array+1
			ld (randomizer_pseudo.curr_line_ptr), hl

			call randomizer_pseudo
			and 1
			add a,3	;a = random 3-4
loc_b3c2:  
			ld l,a
			ld h,0
			ld (txt_string_id),hl  ;0x8d20
			ret
			
location_at_lions		;sub_b3c9						;lions
			ld a,0x53
			call load_image
			ld a,2
			ld (location_id_8d28+1),a			
			inc a
			ld (byte_8d1f),a
			ld a,5
			jr loc_b3c2
			
			
;l---  TODO
location_at_jb_office:
			call sub_8a0c                   ;!!!!!!!!
			ld a,0x51
			call load_image			
			ld hl,1
			ld (txt_string_id),hl
			ld a,2
			ld (byte_8d1f),a
			ret
;---			
go_into_jed_office:
			ld      a, (location_id_8d28+1)
			cp      0x1A
			jp      z, sub_B371
			ld      a, (byte_8d1f)
			and     0xfe
			cp      2
			jr      nz, 1f
			ld      a, 4
			call    load_text_module		
1
			ld      a, (file_index)
			inc     a
			ld      (location_image_number), a
			call    load_image			
			ld      hl, func_B39F
			call    func_AE47			
			ld      (loc_B337+1), a
			dec     a
			jr      z, 1f
			ld      hl, func_B396
			call    func_AE47
1
			ld a,(table_dialogue_questions_index_buffer_8D5D)
			ld (location_id_8d28),a
			push af
			call    get_pointer_to__gamestate_main_by_A
			inc     hl
			ld      a, (hl)
			ld      (byte_8d33), a
			pop     af
			add     a, 0x1F
			
			call    load_portrait_image
			ld      a, (load_text_module+1)
			cp      4
			jr      z, loc_B343
			
			call    func_AEA4
			ex      de, hl
			call    get_pointer_to__gamestate_main_by_8D27value
			inc     hl
			inc     hl
			inc     hl
			ld      c, 3
			bit     4, (hl)
			jr      z, 1f
			inc     c
1
            ex      de, hl
            add     hl, bc
            ld      (txt_string_id), hl
loc_B337
            ld      a, 0            ; проверка - равно значение 1 или нет
            dec     a
            ld      a, 8
            jr      z, 1f     ; если равно то передаётся значение 8 если нет то 9
            inc     a
1
            ld      (byte_8d1f), a
            ret

loc_B343:
                ld      hl, (word_8d22)
                ld      a, (location_id_8d28)
                cp      2
                jr      nz, loc_B360
                ld      bc, 0x154
                call    randomizer_pseudo
                and     3
                add     a, c
                ld      c, a
                add     hl, bc
                ld      a, b
loc_B359:
                ld      (txt_string_id), hl
                ld      (byte_8d1f), a
                ret
loc_B360:
                ld      bc, 157h
loc_B363:
                call    randomizer_pseudo
                and     3
                jr      z, loc_B363
                add     a, c
                ld      c, a
                add     hl, bc          ; hl=hl+0x0157+rnd(1,3)
                                        ; hl = номер строки для печати из текстового модуля
                ld      a, 4
                jr      loc_B359

sub_B371:
                ld      a, 3
                ld      (unk_8d2b), a
                add     a, a
                ld      (location_id_8d28), a
                add     a, a
                ld      (byte_8d1f), a
                ld      a, 4
                call    load_text_module
				
                ld      a, 0x86
                ld      (location_image_number), a
                call    load_image
                ld      hl, 2
                ld      (txt_string_id), hl
                ld      a, 0x25 ; 
                jp      load_portrait_image
;---
location_B5AC:
                ld      hl, func_B2B8
                jp      travel_menu.ent1
travel_menu:
				ld      hl, func_B2BD
.ent1:
				call func_AE47
				call sub_8E4E					;!!!!!!
                call    get_pointer_to__gamestate_main_by_A
                ld      a, (hl)
                ld      (byte_8d32), a
                inc     hl
                ld      a, (hl)
                push    hl
                call    load_image
                pop     hl
                inc     hl
                ld      a, (hl)
                ld      de, 0x10A
                cp      0x14
                jr      c, 1f
                ld      de, 0x214
                cp      1Eh
                jr      c, 1f
                ld      de, 0x31E
1
				sub     e
				ld      b, a
				dec     b
				ld      (byte_8d31), a
				ld      a, 6
				ld      (byte_8d1f), a
				xor     a
				ld      (location_id_8d28), a
				ld      a, b
				add     a, a
				add     a, b
				ld      c, a
				ld      b, 0
				ld      hl, 0x0D
				add     hl, bc
				call    randomizer_pseudo
				and     1
				ld      c, a
				add     hl, bc
				ld      (txt_string_id), hl
				ld      a, d
				call    load_text_module
				ld      l, d
				ld      h, 0
				add     hl, hl
				add     hl, hl
				ld      bc, table_loc_B2C7-4 ; 4 bytes per entry
										; min offset is 1
				add     hl, bc
				ld      de, byte_8d2d
				ld      bc, 4
				ldir
				ret				
table_loc_B2C7: db 4, 9, 0Ah, 1
                db 2, 8, 0Ah, 0
                db 4, 9, 0Bh, 1				
func_B2B8:
                ld      a, (byte_8d32)
                cp      (hl)
                ret     z
func_B2BD:
                ld      de, 4
                add     hl, de
                bit     7, (hl)
                ret     z
                jp      func_AE6D	
;=========================================================
location_B51D:
                ld      hl, func_B57C
                call    func_AE47
                jr      z, loc_B565

loc_B525:                               ; CODE XREF: sub_B59E+Bj
                call    sub_8E4E			;						!!!!!!!!!!!!
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                inc     hl
                ld      a, (hl)
                call    load_image
                pop     hl
                ld      a, (hl)
                ld      b, 0x0A
                cp      0x14
                jr      c, 1f
                ld      b, 0x14
                cp      0x1E
                jr      c, 1f
                ld      b, 0x1E
1
                sub     b
                ld      (byte_8d2a), a
                ld      a, (temp_location_id_byte_8d27)
                sub     32h ; '2'
                ld      (location_id_8d28+1), a
                call    func_AEA4
                push    hl
                ld      hl, sub_B58E
                call    func_AE47
                pop     hl
                jr      z, 1f
                inc     hl
1
                inc     hl
                ld      a, 7
loc_B55E:
                ld      (txt_string_id), hl
                ld      (byte_8d1f), a
                ret
location_B59E:
                ld      hl, func_B575
                call    func_AE47
                ld      hl, 6
                jr      z, loc_B55E
                jp      loc_B525
loc_B565:
                ld      a, (byte_8d31)
                ld      c, a
                add     a, a
                add     a, c
                ld      c, a
                ld      b, 0
                ld      hl, (word_8d22)
                add     hl, bc
sub_B572:
                xor     a
                jr      loc_B55E				
func_B575:
                ld      a, (location_id_8d28+1)
                add     a, 32h ; '2'
                cp      c
                ret     z
func_B57C:
                inc     hl
                inc     hl
                ld      a, (byte_8d32)
                cp      (hl)
                ret     nz
                inc     hl
                inc     hl
                bit     5, (hl)
                ret     z
                bit     6, (hl)
                ret     z
loc_B58B:
                jp      func_AE6D
sub_B58E:
                inc     hl
                inc     hl
                ld      a, (location_id_8d28+1)
                cp      (hl)
                ret     nz
                inc     hl
                bit     0, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                jr      loc_B58B
;-----------------------------------------------				
location_B4EC:
                call    sub_8a0c
                ld      a, (location_image_number)
                dec     a
                dec     a
                cp      0x5D
                jr      z, 1f
                cp      0x6C
                jr      z, 1f
                inc     a
1
                call    load_image
                call    func_AEA4
                ld      c, 7
                add     hl, bc
                ld      a, (location_id_8d28+1)
                cp      2
                jr      z, loc_B516
                push    hl
                call    sub_AF4F
                pop     hl
                ld      a, 7
                jr      loc_B55E
; ---------------------------------------------------------------------------

loc_B516:
                ld      a, 3
                ld      hl, 8
                jr      loc_B55E
;-------------------------------------
sub_AF4F:
                push    af
                push    bc
                ld      a, (byte_8d32)
                ld      b, 1
                cp      5
                jr      c, 1f
                inc     b
                cp      7
                jr      c, 1f
                inc     b
1
                ld      a, b
                call    load_text_module
                pop     bc
                pop     af
                ret		
;----------
location_B5B2:
                call    func_AEBB
                inc     hl
                ex      de, hl
                ld      a, (location_id_8d28)
                call    get_pointer_to__gamestate_main_by_A
                inc     hl
                inc     hl
                inc     hl
                bit     4, (hl)
                jr      z, loc_B5D2
                inc     de
                bit     1, (hl)
                jr      z, loc_B5D2
                inc     de
                inc     hl
                inc     hl
                inc     hl
                bit     4, (hl)
loc_B5CF:
                jr      z, loc_B5D2
loc_B5D1:
                inc     de
loc_B5D2:
                ex      de, hl
                jp      sub_B572
				
location_B5D5:
                call    func_AEBB
                ld      c, 5
                add     hl, bc
                ex      de, hl
                ld      a, (location_id_8d28)
                call    get_pointer_to__gamestate_main_by_A
                inc     c
                add     hl, bc
                bit     4, (hl)
                jr      nz, loc_B5F4
                dec     hl
                dec     hl
                dec     hl
                bit     4, (hl)
                jr      z, loc_B5D2
                inc     de
                bit     1, (hl)
                jr      loc_B5CF
loc_B5F4:
                inc     de
                inc     de
                jr      loc_B5D1
; ---------------------------------------------------------------------------

location_B8BD: 

                 ld      a, (location_id_8d28)
                 call    get_pointer_to__gamestate_main_by_A
                 ld      de, 6
                 add     hl, de
                 bit     4, (hl)
                 jr      nz, loc_B91F
                 dec     hl
                 dec     hl
                 dec     hl
                 bit     0, (hl)
                 ld      a, (loc_B337+1)
                 jr      z, loc_B8F9
                 dec     a
                 ld      a, 0x0D
                 jr      nz, 1f
                 dec     a
1
                 ld      (byte_8d1f), a
                 dec     hl
                 dec     hl
                 dec     hl
                 ld      a, (hl)
                 ld      (unk_8d2b), a
                 call    func_AEBB
                 ld      c, 0x0A
                 call    sub_B91A
                 call    print_text_at_location
                 ld      a, 4
                 call    load_text_module
                 pop     hl
                 jp      loc_ADCB
loc_B8F9:
                 dec     a
                 ld      a, 0x0B
                 jr      nz, loc_B912
                 ld      a, (location_id_8d28+1)
                 add     a, 0x32 ; '2'
                 call    get_pointer_to__gamestate_main_by_A
                 ld      de, 4
                 add     hl, de
                 ld      a, 0x0A
                 bit     3, (hl)
                 jr      z, loc_B912
                 ld      a, 0x0E
loc_B912:
                 ld      (byte_8d1f), a
                 call    func_AEBB
                 ld      c, 9
sub_B91A:
                 add     hl, bc
                 ld      (txt_string_id), hl
                 ret
loc_B91F:
                 call    func_AEBB
                 ld      c, 0x0B
                 jr      sub_B91A
;--------------------------------------------------------------------
sub_AEF7:
                ld      hl, (unk_8d2b)
                ld      h, 0x35
                call    mul_h_l
                ld      bc, (word_8d22)
                add     hl, bc
                ld      bc, 0x129
                add     hl, bc
                ld      b, 0
                ret
sub_AF0B:
                ld      a, (location_id_8d28)
                ld      (temp_location_id_byte_8d27), a
                call    get_pointer_to__gamestate_main_by_A
                ld      a, (hl)
                ld      (unk_8d2b), a
                ret
;-------------------------------------------------------------------
sub_8E4E:
                call    print_menu_with_frame			;!!!!!!!!!!!
                call    sub_8EEB
                push    af
                call    restore_background
                pop     af
                ret
				
sub_8EEB:
                call    wait_for_user_decision
                call    nullsub_2
                call    highlight_letter_selection
                ld      e, a
                ld      d, 0
                ld      hl, table_dialogue_questions_index_buffer_8D5D
                add     hl, de
                ld      a, (hl)
                ld      (temp_location_id_byte_8d27), a
                ld      e, a
                push    af
                ld      hl, 0xc000+157*40+3				;        0F116h pc-88
                ld      (text_screen_address), hl
                dec     hl
                ld      (text_screen_address_current), hl
                ld      bc, 0A19h
                call    clear_window
                ld      a, 1
                ld      (characters_to_print_byte_8D53), a
                ld      a, 6
                ld      (symbol_color), a
                ld      hl, A650_strings
                call    find_string_by_de
                ld      a, "'"
                call    print_char
                call    print_text_line
                inc     a
                ld      (keep_top_text_line), a
				ld      a, "'"
                call    print_char
                pop     af
                ret
				
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
nullsub_2:
                ret
loc_9029:
                ld      hl, 0
sub_902c:
                push    af
                ld      a, 0xC9
                jr      loc_9020

;---------------------------------------------------------------------------------
restore_background:
			ld a,(can_use_letters)
			or a
			ret z
.loc_8E14:
			xor a
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
			ld a,(scr_buff)
			SETPG8000
			ld a,(user_scr0_high)
			SETPGC000

			ld hl,(frame_screen_address)
			ld de,(screen_buffer_address)
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
                ld      hl, G_BUFFER1					;133Ch
                ld      (screen_buffer_address), hl
                call    render_message_frame
                ld      a, 0xC9
                ld      (nullsub_2), a
                pop     bc
                ld      c, 0
                ld      hl, table_dialogue_questions_index_buffer_8D5D
sub_8E93: 
                ld      a, 14h
                ld      (characters_to_print_byte_8D53), a
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
                ;add     a, 0x10
                add     a,"A"
                call    print_char
                ld      a, ":"		;79h ; 'y'
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
                ld      (can_use_letters), a
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
;------------------------------------------------------------------------
location_B3ED:                          ; DATA XREF: seg003:AE18o
                ld      hl, sub_B41E
                call    func_AE47
                call    print_menu_with_frame
.loop
                call    sub_8EEB
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                ld      a, (hl)
                call    sub_AE8D
                ld      a, e
                add     a, a
                ld      c, a
                ld      b, 0
                ld      hl, (word_8d22)
                add     hl, bc
                inc     h
                ex      de, hl
                pop     hl
                ld      c, 5
                add     hl, bc
                bit     4, (hl)
                jr      z, 1f
                inc     de
1
                ld      (txt_string_id), de
                call    print_text_at_location
                jr      .loop
sub_B41E:
                ld      b, (hl)
                inc     hl
                ld      a, (hl)
                cp      5
                ret     nz
                ld      de, 4
                add     hl, de
                bit     6, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                ld      a, b
                call    sub_AE8D
                ret     nz
                jp      func_AE6D
;------------------------------------------------------------------------
location_B5F8:
                ld      hl, func_B644
                call    func_AE47
                call    print_menu_with_frame
.loop
                call    sub_8EEB
                call    get_pointer_to__gamestate_main_by_A
                ld      a, (hl)
                ld      c, a
                ld      b, 0
                push    bc
                dec     a
                jr      nz, 1f
                ld      a, (location_id_8d28)
                call    get_pointer_to__gamestate_main_by_A
                inc     hl
                inc     hl
                inc     hl
                set     4, (hl)
1
                call    func_AEBB
                ld      c, 0x0B
                add     hl, bc
                pop     bc
                add     hl, bc
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      a, c
                ld      c, 5
                add     hl, bc
                bit     5, (hl)
                ex      de, hl
                jr      z, 2f
                cp      1
                jr      nz, 1f
                ld      c, 7
                add     hl, bc
1
                cp      7
                jr      nz, 2f
                inc     hl
                inc     hl
2
                ld      (txt_string_id), hl
                call    print_text_at_location
                jr      .loop
func_B644:
                inc     hl
                ld      a, (hl)
                cp      3
                ret     nz
                ld      de, 4
                add     hl, de
                bit     6, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                jp      func_AE6D
;------------------------------------------------------------------------
location_B656:
                ld      hl, (location_id_8d28)
                ld      h, 0x0A
                call    mul_h_l
                ld      de, table_unk_96E5 ; 10 bytes per entry
                add     hl, de
                ld      (sub_AE7F+1), hl
                ld      hl, func_B697
                call    func_AE47
                call    print_menu_with_frame
.loop
                call    sub_8EEB
                call    sub_AE76
                call    func_AEBB
                ld      d, 0
                add     hl, de
                add     hl, de
                ld      e, 0x16
                add     hl, de
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_8D27value
                inc     hl
                inc     hl
                inc     hl
                bit     1, (hl)
                jr      z, 1f
                bit     2, (hl)
                jr      z, 1f
                inc     de
1
                ld      (txt_string_id), de
                call    print_text_at_location
                jr      .loop
func_B697:
                inc     hl
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
                bit     6, (hl)
                ret     z
                bit     3, (hl)
                jr      nz, 1f
                bit     4, (hl)
                ret     z
1
                ld      a, c
                call    sub_AE76
                ret     nz
                jp      func_AE6D				
;------------------------------------------------------------------------
location_B72D:
                ld      hl, func_B783
                call    func_AE47
                call    print_menu_with_frame ; in:; a - max letters in the menu
.loop
                call    sub_8EEB
                call    get_pointer_to__gamestate_main_by_A
                call    func_AEE2
                ld      (txt_string_id), hl
                call    get_pointer_to__gamestate_main_by_8D27value
                inc     hl
                inc     hl
                ld      a, (hl)
                ld      (loc_B793+1), a
                ld      c, 4
                add     hl, bc
                bit     7, (hl)
                push    af
                ld      hl, func_B792
                call    func_AE47
                ld      a, (table_dialogue_questions_index_buffer_8D5D)
                call    get_pointer_to__gamestate_main_by_A
                ld      bc, 5
                add     hl, bc
                pop     af
                jr      z, .loc_B778
                set     0, (hl)
                ld      hl, (txt_string_id)
.loc_B769:
                inc     hl
                ld      (txt_string_id), hl
                call    print_text_at_location
                ld      hl, func_B783
                call    func_AE47
                jr      .loop
.loc_B778:
                bit     2, (hl)
                ld      hl, (txt_string_id)
                inc     hl
                jr      nz, .loc_B769
                inc     hl
                jr      .loc_B769
func_B783:
                inc     hl
                ld      a, (location_id_8d28+1)
                cp      (hl)
                ret     nz
                inc     hl
                inc     hl
                inc     hl
                bit     0, (hl)
                ret     z
loc_B78F:
                jp      func_AE6D
func_B792:
                ld      a, (hl)
loc_B793:
                cp      0
                ret     nz
                ld      de, 5
                add     hl, de
                bit     3, (hl)
                ret     z
                jr      loc_B78F
; ---------------------------------------------------------------------------
location_B867:
                call    sub_AF0B
                ld      hl, func_B8AB
                call    func_AE47
                call    print_menu_with_frame

.loop:                               ; CODE XREF: seg003:B8A9j
                call    sub_8EEB
                call    get_pointer_to__gamestate_main_by_A
                ld      a, (hl)
                dec     a
                ld      c, a
                add     a, a
                add     a, c
                call    sub_AEF7
                ld      c, a
                add     hl, bc
                ex      de, hl
                ld      a, (location_id_8d28)
                call    get_pointer_to__gamestate_main_by_A
                ld      c, 6
                add     hl, bc
                bit     3, (hl)
                jr      z, 1f
                bit     1, (hl)
                jr      z, 1f
                inc     de
                bit     2, (hl)
                jr      z, 1f
                dec     hl
                dec     hl
                bit     5, (hl)
                jr      z, 1f
                inc     de
1
                inc     de
                ld      (txt_string_id), de
                call    print_text_at_location
                jr      .loop
func_B8AB:
                inc     hl
                ld      a, (hl)
                cp      6
                ret     nz
                ld      de, 4
                add     hl, de
                bit     6, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                jp      func_AE6D
; ---------------------------------------------------------------------------
location_B9CE:
                ld      hl, (location_id_8d28)
                ld      h, 0x0A
                call    mul_h_l
                ld      de, table_unk_981B ; 10 bytes per entry:?
                                        ; min offset is 1
                add     hl, de
                ld      (sub_AE7F+1), hl
                ld      hl, func_BA52
                call    func_AE47
                call    print_menu_with_frame
.loop
                call    sub_8EEB
                call    get_pointer_to__gamestate_main_by_A
                ld      c, (hl)
                inc     hl
                ld      a, (hl)
                cp      4
                jr      z, 1f
                ld      e, 1
                ld      a, c
                call    sub_AE7F
                call    func_AEBB
                ld      c, 0x4A
                jr      2f
1
                inc     hl
                ld      e, (hl)
                call    func_AEBB
                ld      c, 0x48
2
                add     hl, bc
                ld      a, e
                add     a, a
                ld      c, a
                add     hl, bc
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_8D27value
                inc     hl
                inc     hl
                ld      a, (hl)
                cp      0x0C
                jr      nz, 4f
                ld      a, (location_id_8d28)
                call    get_pointer_to__gamestate_main_by_A
                ld      c, 5
                add     hl, bc
                bit     4, (hl)
                jr      z, 3f
                inc     de
                jr      .loc_BA48
3
                set     4, (hl)
                jr      .loc_BA48
4
                dec     a
                jr      nz, .loc_BA40
                ld      a, (location_id_8d28)
                call    get_pointer_to__gamestate_main_by_A
                ld      c, 5
                add     hl, bc
                bit     1, (hl)
                jr      z, .loc_BA3E
                inc     de
                set     5, (hl)
.loc_BA3E:
                jr      .loc_BA48
.loc_BA40:
                inc     hl
                inc     hl
                inc     hl
                bit     4, (hl)
                jr      z, .loc_BA48
                inc     de
.loc_BA48:
                inc     de
                ld      (txt_string_id), de
                call    print_text_at_location
                jp      .loop
func_BA52:
                ld      b, (hl)
                inc     hl
                ld      a, (hl)
                ld      de, 4
                add     hl, de
                bit     7, (hl)
                ret     z
                bit     6, (hl)
                ret     z
                sub     e
                jr      z, 1f
                dec     a
                ret     nz
                ld      a, b
                call    sub_AE7F
                ret     nz
1
                jp      func_AE6D
; ---------------------------------------------------------------------------
location_B926:
                call    sub_AF0B
                call    sub_AEF7
                ld      c, 0x13
                add     hl, bc
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      c, 6
                add     hl, bc
                xor     a
                bit     1, (hl)
                jr      z, .loc_B95E
                bit     3, (hl)
                jr      z, .loc_B960
                bit     2, (hl)
                jr      z, .loc_B960
                bit     0, (hl)
                jr      z, .loc_B960
                inc     a
                inc     de
                dec     hl
                dec     hl
                set     5, (hl)
                inc     hl
                inc     hl
                bit     5, (hl)
                jr      z, .loc_B960
                dec     hl
                dec     hl
                bit     3, (hl)
                jr      z, .loc_B960
                inc     de
                inc     de
                inc     a
                jr      .loc_B960
.loc_B95E:
                set     1, (hl)

.loc_B960: 
                or      a
                jr      z, .loc_B993
                dec     a
                jr      z, .loc_B982
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      c, 6
                add     hl, bc
                set     4, (hl)
                ld      (txt_string_id), de
                ld      a, (unk_8d2b)
                dec     a
.loc_B976:
                jp      z, module_9d
                cp      7
                jr      z, .loc_B976
                cp      2
                jp      z, module_9f
.loc_B982:
                ld      (txt_string_id), de
                call    print_text_at_location
                call    sub_928C					;!!!!!!!!!!!!!
                ld      hl, (txt_string_id)
                inc     hl

.loc_B990:
                jp      sub_B572
.loc_B993:
                ex      de, hl
                jr      .loc_B990

;wait_enter_key
sub_928C:
                ld      hl, 0xc000+157*40+18			;0F134h
                ld      (text_screen_address), hl
                ld      hl, msg_hit_return_key
                ld      a, 2
                ld      (characters_to_print_byte_8D53), a
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

msg_hit_return_key:db "Нажмите ENTER",0xff

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

location_B996:
                ld      hl, func_B1B4
                call    func_AE47
                call    print_menu_with_frame
.loop
                call    sub_8EEB
                sub     0x49
                call    load_item_image
                call    get_pointer_to__gamestate_main_by_8D27value
                push    hl
                ld      a, (hl)
                add     a, a
                call    sub_AEF7
                ld      c, a
                add     hl, bc
                ld      c, 16h
                add     hl, bc
                ex      de, hl
                pop     hl
                ld      c, 5
                add     hl, bc
                bit     4, (hl)
                jr      z, 1f
                bit     5, (hl)
                jr      z, 2f
                inc     de
1
                set     4, (hl)
2
                ld      (txt_string_id), de
                call    print_text_at_location
                jr      .loop

func_B1B4:
                ld      de, 5
                add     hl, de
                bit     2, (hl)
                ret     z
                bit     3, (hl)
                ret     z
                jp      func_AE6D
; ---------------------------------------------------------------------------
location_B851:
                ld      hl, func_B39F
                call    func_AE47
                ld      a, (table_dialogue_questions_index_buffer_8D5D)
                add     a, 0x1F
                call    load_portrait_image
                ld      hl, 0x0B
                ld      a, 0x0E
                jp      loc_B55E
; ---------------------------------------------------------------------------
location_B7DB:
                ld      hl, func_B82A
                call    func_AE47
                jr      z, .loc_B821
                call    sub_8E4E
                sub     0x49
                call    load_item_image
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      a, (hl)
                ld      (loc_B846+1), a
                ld      de, 5
                add     hl, de
                set     2, (hl)
                ld      hl, func_B83F
                call    func_AE47
                ld      a, (table_dialogue_questions_index_buffer_8D5D)
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                ld      de, 6
                add     hl, de
                res     7, (hl)
                pop     hl
                call    func_AEE2
                ld      c, 4
                add     hl, bc
                ld      (txt_string_id), hl
                ld      hl, func_B82A
                call    func_AE47
                ret     z
                call    print_text_at_location
                jr      location_B7DB
.loc_B821:
                call    restore_background
                ld      hl, 0x0A
                jp      sub_B572
				
func_B82A:
                inc     hl
                ld      a, (location_id_8d28+1)
                cp      (hl)
                ret     nz
                ld      de, 4
                add     hl, de
                ld      a, (hl)
                rra
                ret     nc
                rra
                rra
                ret     c
                rra
                ret     nc
loc_B83C:
                jp      func_AE6D

func_B83F:
                inc     hl
                ld      a, (location_id_8d28+1)
                cp      (hl)
                ret     nz
                inc     hl
loc_B846:
                ld      a, 0
                cp      (hl)
                ret     nz
                inc     hl
                inc     hl
                bit     0, (hl)
                ret     z
                jr      loc_B83C
; ---------------------------------------------------------------------------
location_B79F:
                call    func_AEBB
                ld      c, 0x15
                add     hl, bc
                ex      de, hl
                ld      a, (location_id_8d28)
                call    get_pointer_to__gamestate_main_by_A
                ld      c, 6
                add     hl, bc
                bit     7, (hl)
                jr      z, .loc_B7D5
                inc     de
                bit     6, (hl)
                jr      z, .loc_B7D7
                inc     de
                ex      de, hl
                call    sub_B572
                ld      hl, 0x260
                ld      de, 0x22D
                ld      bc, 0x267
                call    sub_AF19
                ld      hl, 0x18C
                ld      de, 0x159
                ld      bc, 0x368
                jp      sub_AF19
.loc_B7D5:
                set     7, (hl)
.loc_B7D7:
                ex      de, hl
                jp      sub_B572
				
sub_AF19:
                ld      (.preserve_hl+1), hl ; in:
                                        ; b - ???? required text module ????
                                        ; c - ???? location_id ???
                                        ; de - ??? text string index to display
                                        ; hl - ???
                ld      hl, (txt_string_id)
                call    cp_hl_de
                ret     nz
                ld      a, (load_text_module+1)
                cp      b
                ret     nz
                ld      a, c
                ld      (temp_location_id_byte_8d27), a
                call    get_pointer_to__gamestate_main_by_A
                ld      de, 5
                add     hl, de
                bit     2, (hl)
                jr      nz, .preserve_hl
                set     2, (hl)
                sub     0x49
                call    load_item_image
                call    print_text_at_location
                call    sub_928C
                call    load_card_image
                ret
.preserve_hl:
                ld      hl, 0
                ld      (txt_string_id), hl
                ret
; ---------------------------------------------------------------------------
location_B6CD:
                ld      hl, func_B71A
                call    func_AE47
                call    sub_8E4E
                ld      a, (load_text_module+1)
                cp      4
                call    z, sub_AF4F
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      de, 4
                add     hl, de
                cp      4
                jr      nz, .loc_B6ED
                bit     2, (hl)
                jr      nz, .loc_B712
.loc_B6ED:
                cp      6
                jr      nz, .loc_B6F5
                bit     2, (hl)
                jr      nz, .loc_B712

.loc_B6F5:
                call    sub_8a0c
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      (location_id_8d28), a
                push    af
                inc     hl
                ld      a, (hl)
                ld      (byte_8d33), a
                pop     af
                add     a, 0x1F
                call    load_portrait_image
                ld      hl, 7
.loc_B70D:
                ld      a, 9
                jp      loc_B55E
.loc_B712:
                call    func_AEBB
                ld      c, 0x48
                add     hl, bc
                jr      .loc_B70D
func_B71A:
                ld      a, (location_id_8d28)
                cp      c
                ret     z
                inc     hl
                inc     hl
                ld      a, (location_id_8d28+1)
                cp      (hl)
                ret     nz
                inc     hl
                bit     7, (hl)
                ret     z
                jp      func_AE6D
; ---------------------------------------------------------------------------
location_B6AF:
                call    sub_8a0c
                ld      a, (location_id_8d28+1)
                cp      7
                ld      a, 0x5F
                ld      hl, 0x4DF
                jr      z, .loc_B6C3
                ld      a, 0x6E
                ld      hl, 0x550
.loc_B6C3:
                push    hl
                call    load_image
                pop     hl
                ld      a, 0x0F
                jp      loc_B55E
; ---------------------------------------------------------------------------
location_B07F:
                ld      hl, func_B0BC
                call    func_AE47
                call    print_menu_with_frame
.loop
                call    sub_8EEB
                call    sub_AE94
                ld      a, e
                add     a, a
                add     a, e
                ld      c, a
                ld      b, 0
                ld      hl, (word_8d22)
                add     hl, bc
                ld      bc, 0x37
                add     hl, bc
                ex      de, hl
                call    get_pointer_to__gamestate_main_by_8D27value
                inc     hl
                inc     hl
                inc     hl
                bit     1, (hl)
                jr      z, 1f
                inc     de
                inc     hl
                inc     hl
                inc     hl
                bit     4, (hl)
                jr      z, 1f
                inc     de
1
                ld      (txt_string_id), de
                call    sub_AF67				;!!!!!!!!!!!!!!!!!!!!!!!
                call    print_text_at_location
                jr      .loop
func_B0BC:
                inc     hl
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
                bit     3, (hl)
                jr      nz, .loc_B0C9
                bit     4, (hl)
                ret     z
.loc_B0C9:
                ld      a, c
                call    sub_AE94
                ret     nz
                jp      func_AE6D



; ---------------------------------------------------------------------------
location_B0D1:
                ld      hl, func_B117
                call    func_AE47
                call    print_menu_with_frame
.loop:
                call    sub_8EEB
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                ld      a, (hl)
                call    sub_AE86
                ld      a, e
                add     a, a
                add     a, e
                ld      c, a
                ld      b, 0
                ld      hl, (word_8d22)
                add     hl, bc
                ld      bc, 0x85
                add     hl, bc
                ex      de, hl
                pop     hl
                ld      c, 5
                add     hl, bc
                bit     4, (hl)
                jr      z, 1f
                inc     de
                bit     5, (hl)
                jr      z, 1f
                inc     de
1
                ld      (txt_string_id), de
                ld      bc, 0x45E
                ld      de, 0x99
                ld      hl, 0x96
                call    sub_AF19
                call    print_text_at_location
                jr      .loop
func_B117:
                ld      b, (hl)
                inc     hl
                ld      a, (hl)
                cp      5
                ret     nz
                ld      de, 4
                add     hl, de
                bit     7, (hl)
                ret     z
                bit     6, (hl)
                ret     z
                ld      a, b
                call    sub_AE86
                ret     nz
                jp      func_AE6D
; ---------------------------------------------------------------------------
location_B12F:
                ld      hl, func_B1B4
                call    func_AE47
                call    print_menu_with_frame
.loop:
                call    sub_8EEB
                sub     0x49
                call    load_item_image
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      a, (hl)
                ld      de, 6
                add     hl, de
                ld      d, (hl)
                push    de
                add     a, a
                dec     a
                ld      c, a
                ld      b, 0
                ld      de, 0xD5
                ld      a, (location_id_8d28)
                cp      2
                jr      z, 1f
                ld      de, 0x135
1
                ld      hl, (word_8d22)
                add     hl, de
                add     hl, bc
                pop     af
                bit     4, a
                jr      z, 1f
                inc     hl
1
                ld      (txt_string_id), hl
                ld      de, 0xF7
                call    cp_hl_de
                jr      z, .loc_B186
                ld      de, 0x14A
                call    cp_hl_de
                jr      z, .loc_B193
                ld      e, 0x4E
                call    cp_hl_de
                jr      z, .loc_B1AD
.loc_B181:
                call    print_text_at_location
                jr      .loop
.loc_B186:
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      de, 5
                add     hl, de
                res     2, (hl)
                res     0, (hl)
                jr      .loc_B181
.loc_B193:
                ld      a, 0x5E
                ld      bc, 0x141
.loc_B198:
                call    get_pointer_to__gamestate_main_by_A
                ld      de, 5
                add     hl, de
                bit     1, (hl)
                jr      z, .loc_B1A9
                ld      (txt_string_id), bc
                jr      .loc_B181
.loc_B1A9:
                set     1, (hl)
                jr      .loc_B181
.loc_B1AD:
                ld      a, 0x60
                ld      bc, 0x140
                jr      .loc_B198

; ---------------------------------------------------------------------------
location_B1C1:
                ld      hl, func_B1B4
                call    func_AE47
                call    print_menu_with_frame
.loop:
                call    sub_8EEB
                sub     0x49
                call    load_item_image
                call    get_pointer_to__gamestate_main_by_8D27value
                ld      e, (hl)
                ld      d, 0
                call    func_AEBB
                add     hl, de
                ld      e, 0x62
                add     hl, de
                ld      (txt_string_id), hl
                call    print_text_at_location
                jr      .loop
; ---------------------------------------------------------------------------
location_B1E7:
                ld      hl, func_B23F
                call    func_AE47
                call    print_menu_with_frame
.loop:
                call    sub_8EEB
                call    get_pointer_to__gamestate_main_by_A
                ld      de, 5
                add     hl, de
                ld      c, (hl)
                inc     hl
                ld      b, (hl)
                bit     4, b
                jr      nz, .loc_B22A
                dec     hl
                dec     hl
                dec     hl
                ld      de, 0x102
                bit     2, (hl)
                jr      z, .loc_B21E
                inc     e
                bit     6, b
                jr      z, .loc_B21E
                inc     e
                bit     5, c
                jr      z, .loc_B21E
                inc     e
                bit     1, (hl)
                jr      z, .loc_B21E
                ld      e, 0
                set     0, (hl)
.loc_B21E:
                ld      (txt_string_id), de
                call    sub_AF67
                call    print_text_at_location
                jr      .loop
.loc_B22A:
                ld      e, 0xDF
                cp      4
                jr      z, .loc_B21E
                inc     e
                cp      0x0C
                jr      z, .loc_B21E
                inc     e
                cp      6
                jr      z, .loc_B21E
                ld      de, 0x101
                jr      .loc_B21E
func_B23F:
                ld      a, (hl)
                or      a
                ret     z
                inc     hl
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
                bit     5, (hl)
                ret     z
                bit     4, (hl)
                jr      nz, .loc_B252
                bit     3, (hl)
                ret     z
.loc_B252:
                jp      func_AE6D
; ---------------------------------------------------------------------------

location_AF9D:
                ld      hl, func_B041
                call    func_AE47
                jr      nz, .loc_AFF5
.loc_AFA5:
                ld      hl, (word_8d22)
                ld      (word_8d24), hl
                ld      hl, func_B063

.loc_AFAE:                               ; CODE XREF: seg003:B01Cj
                call    func_AE47
                call    print_menu_with_frame

.loc_AFB4:                               ; CODE XREF: seg003:AFF3j
                call    sub_8EEB
                call    get_pointer_to__gamestate_main_by_A
                push    hl
                ld      a, (hl)
                dec     a
                ld      e, a
                add     a, a
                add     a, e
                ld      e, a            ; a*3
                ld      d, 0
                ld      hl, (word_8d24)
                add     hl, de
                inc     hl
                ex      de, hl
                pop     hl
                ld      a, (temp_location_id_byte_8d27)
                cp      0x74
                jp      z, .loc_B01F
                ld      bc, 5
                add     hl, bc
                bit     4, (hl)
                jr      z, .loc_AFE0
                inc     de
                bit     5, (hl)
                jr      z, .loc_AFE0
                inc     de
.loc_AFE0:
                ld      (txt_string_id), de
                ld      de, 0x21
                ld      hl, 0x93
                ld      bc, 0x466
                call    sub_AF19
.loc_AFF0:
                call    print_text_at_location
                jr      .loc_AFB4
.loc_AFF5:
                ld      hl, func_B052
                call    func_AE47
                call    sub_8E4E
                ld      (.loc_B01F+1), a
                cp      0x77
                jr      z, .loc_AFA5
                sub     0x78
                ld      l, a
                ld      h, 9
                call    mul_h_l
                ld      de, (word_8d22)
                add     hl, de
                ld      de, 0x15
                add     hl, de
                ld      (word_8d24), hl
                ld      hl, func_B071
                jp      .loc_AFAE
.loc_B01F:
                ld      a, 0
                call    get_pointer_to__gamestate_main_by_A
                ld      bc, 5
                add     hl, bc          ; check 5's  element in record
                bit     5, (hl)
                jr      z, .set_bit_5
                inc     de
                bit     4, (hl)
                jr      z, .set_bit_4
                inc     de
                jr      .loc_B036
.set_bit_5:
                set     5, (hl)
.loc_B036:
                ld      (txt_string_id), de
                jp      .loc_AFF0
.set_bit_4:
                set     4, (hl)
                jr      .loc_B036
func_B041:
                ld      a, c
                cp      0x78
                ret     c
                cp      0x7C
                ret     nc
                ld      de, 5
                add     hl, de
                bit     6, (hl)
                ret     z
loc_B04F:
                jp      func_AE6D

func_B052:
                inc     hl
                ld      a, (hl)
                cp      2
                ret     nz
                ld      de, 4
                add     hl, de
                bit     6, (hl)
                ret     z
                bit     7, (hl)
                ret     z
                jr      loc_B04F

func_B063:
                inc     hl
                inc     hl
                ld      a, (hl)
                cp      0x64
                ret     nz
                inc     hl
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
loc_B06F:
                jr      loc_B04F
func_B071:
                inc     hl
                inc     hl
                ld      a, (hl)
                cp      2
                ret     nz
                inc     hl
                inc     hl
                inc     hl
                bit     7, (hl)
                ret     z
                jr      loc_B06F
; ---------------------------------------------------------------------------
load_saved_state:

				ld bc,32768
33				dec bc
				ld a,b
				or c
				jr nz, 33b

                ld      hl, 0xc000+5*40	;0C190h
                ld      de, text_byte_BA9E
                call    menu_choose_file_to_load
                jp      c, loc_ADF2     ; SPACE pressed. restore screen
				
				add a,"1"
				ld (saveslot),a
				ld de,savename
				call openstream_file
				or a
				jp nz,loc_ADF2	;no file
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
				
                ld      hl, 0x169
                ld      (txt_string_id), hl
                call    print_text_at_location
                jp      loc_ADF2
				
text_byte_BA9E: db "Какой ФАЙЛ нужно ЗАГРУЗИТЬ?",0xff
; ---------------------------------------------------------------------------

location_bar:
                ld      a, 0x55
                call    load_image
                ld      a, 4
                call    load_text_module
                ld      a, 5
                ld      hl, 0x167
                jp      loc_B55E
resume_investigation:
				ld a,1
				call load_mus
				call clear_loc_screen
				call load_card_image
				call location_bar
				ld hl,0x168
				ld (txt_string_id),hl
				jp hot_return_to_city
location_investigation_break:
				ld a,2
				call load_mus
				ld a,0x56
				call load_image
				xor a
				ld (load_card_image+1),a
				ld (print_location_menu.loc_8f39+1),a
loc_AD68:
                call    sub_B244				
loc_AD6B:
                call    sub_B292
                ld      hl, (loc_9029+1)
                push    hl
                jp      z, investigation_statistcs
                dec     a
                jp      z, relation_connections
                ld      hl, 0xc000+60*40+6  ;0D2CCh      ; save progress
                ld      de, MSG_B2ED
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
loc_ADA0:
                pop     hl
                call    sub_902c
                jp      loc_AD6B				
				
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
				ld      a, 0x0F+3
				ld      (characters_in_text_line), a
				ld      hl, msg_bar_s
				call    print_text_line
				ld      hl,0xc000+66*40+7			;0D4AEh
				ld      (text_screen_address), hl
				ld      hl, MSG_B307
				ld      a, 3
				call    sub_AE69
				ld      hl, bfunc_AEA4
				ld      de, 0FFD5h
				call    loc_AE7C
				push    hl
				ld      a, 9Bh
				call    display_percentage
				ld      hl, MSG_B30C
                ld      a, 6
                call    sub_AE69
                ld      hl, func_AEBC
                ld      de, 0
                call    loc_AE7C
				
                push    hl
                ld      a, 0x48
                call    display_percentage
                ld      hl, MSG_B312
                ld      a, 1
                call    sub_AE69
                ld      hl, func_AED2
                ld      de, 0FFFEh 
                call    loc_AE7C
                push    hl
                ld      a, 49h ; 'I'
                call    display_percentage
                ld      hl, MSG_B317
                ld      a, 4
                call    sub_AE69
                ld      hl, loc_AEE0
                ld      de, 0FFF1h
                call    loc_AE7C
                push    hl
                ld      a, 54h ; 'T'
                call    display_percentage
                ld      hl, MSG_B31C
                ld      a, 2
                call    sub_AE69
                pop     hl
                pop     de
                add     hl, de
                pop     de
                add     hl, de
                pop     de
                add     hl, de
                ld      a, 2
                call    div_hl_a
                ld      a, 0C0h
                call    display_percentage
.loop
                xor     a
                call    wait_for_key_input
                cp      0x1B
                jr      z, .loc_AE60
                jr      .loop
.loc_AE60:
                call    restore_background
                jp      loc_ADA0
; ---------------------------------------------------------------------------
				
sub_AE69:
                ld      (symbol_color), a
                push    hl
                ld      hl, (text_screen_address)
                ld      de, 9*40 		;370h        ; adress offset
                add     hl, de
                ld      (text_screen_address), hl
                pop     hl
                call    print_text_line
                ret

loc_AE7C:
                push    de
                ld      (.loc_AE94+1), hl

				ld 		hl,(0x0000)
				push hl
				ld 		hl,(0x0002)
				push hl
                ld      hl, 0CC8h       ; ret z:inc c
                ld      (0), hl
                ld      a, 0xC9			;ret
                ld      (2), a
				
                ld      d, 0
                ld      hl, gamestate_main
                ld      bc, 0xAE00
.loop:
                push    hl
.loc_AE94:
                call    0
                pop     hl
                ld      de, 8
                add     hl, de
                djnz    .loop
				
				pop hl
				ld (0x0002),hl
				pop hl
				ld (0x0000),hl
				
                ld      l, c
                ld      h, 0
                pop     de
                add     hl, de
                ret
; ---------------------------------------------------------------------------

bfunc_AEA4:                              ; DATA XREF: seg004:ADDFo
                ld      e, 4
                add     hl, de
                bit     2, (hl)
                rst     0               ; ret z: inc c: ret
                inc     hl
                bit     4, (hl)
                rst     0
                bit     5, (hl)
                rst     0
                bit     6, (hl)
                rst     0
                inc     hl
                bit     3, (hl)
                rst     0
                bit     6, (hl)
                rst     0
                ret
func_AEBC:
                inc     hl
                inc     hl
                inc     hl
                bit     1, (hl)
                rst     0
                inc     hl
                bit     3, (hl)
                rst     0
                inc     hl
                inc     hl
                bit     0, (hl)
                rst     0
                bit     2, (hl)
                rst     0
                bit     5, (hl)
                rst     0
                ret
func_AED2:
                ld      e, 5
                add     hl, de
                bit     2, (hl)
                rst     0
                inc     hl
                bit     4, (hl)
                rst     0
                bit     7, (hl)
                rst     0
                ret
loc_AEE0:				
                inc     hl
                inc     hl
                inc     hl
                bit     2, (hl)
                rst     0
                bit     3, (hl)
                rst     0
                inc     hl
                bit     5, (hl)
                rst     0
                inc     hl
                bit     1, (hl)
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
                ld      de, 16+0x2000			;21h ; '!'		;16
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
				add a,"0"
                call    print_char
                djnz    .loop3
                ld      a, "%"		;0CDh
                call    print_char
                ret
; ----------------------------

sub_B244:
                ld      hl,0xc000 + 5*40+1		;0C192h
                ld      (frame_screen_address), hl
                ld      hl, G_BUFFER2				;initially  3 because we need 3 first bytes
                ld      (screen_buffer_address), hl
                ld      a, 0x23
                ld      (count_of_vertical_lines_in_the_frame), a
                call    render_message_frame
                xor     a
                ld      (characters_to_print_byte_8D53), a
                ld      a, 4
                ld      (symbol_color), a
                ld      a, 0x0E
                ld      (characters_in_text_line), a
                ld      hl, 0xc000+10*40+4		;  0C32Fh
                ld      (text_screen_address), hl
				ld      a,(characters_in_text_line)
				push af
				ld a,30
				ld 		(characters_in_text_line),a
                ld      hl, MSG_B2FD
                call    print_text_line
				pop af
				ld 		(characters_in_text_line),a
				
                ld      hl,0xc000+17*40+1				; 0C552h
                ld      (frame_screen_address), hl
                ld      a, "1"
                ld      (loc_8EC8+1), a
                ld      c, 0
                ld      b, 3
                ld      hl, unk_B2FA    ; номера строк в a650
                call    sub_8E93
                ld      a, "A"
                ld      (loc_8EC8+1), a
                ret
sub_B292:
                ld      hl, 0xc000+17*40+1			;0C552h
                ld      (frame_screen_address), hl
.loc_B29B:
                xor     a
                call    wait_for_key_input
                dec     a
                cp      3
                jr      c, 1f
                cp      1Ah
                jr      z, .loc_B2CB
                ld      (.loc_B2CB+1), a
                jr      .loc_B29B
1
                push    af
                call    highlight_letter_selection
                xor     a
                ld      (.loc_B2CB+1), a
                pop     af
                or      a
                ret
.loc_B2CB:
                ld      a, 1
                or      a
                jr      z, .loc_B29B
                ld      hl,0xc000+5*40+1			; 0C192h
                ld      (frame_screen_address), hl
                ld      hl, G_BUFFER2
                ld      (screen_buffer_address), hl
                ld      a, 0x23
                ld      (count_of_vertical_lines_in_the_frame), a
                call    restore_background.loc_8E14
                jp      resume_investigation
				
				
				
				
sprbuf			ds 32
relation_connections:
				ld a,0x0A
				call load_image
				ld a,0xff
				ld (loc_B236_clr+1),a
		;----------------------------------------				
				;copy icon
				ld a,(curpgc000)
				push af
				ld a,(user_scr0_high)
				SETPGC000
		
				ld hl,0xc000+27+0x2000
				ld de,sprbuf
				ld bc,0x020f
.cp_lp1
				push bc
				push hl
.cp_lp2				
				push bc
				ld a,(hl)
				ld (de),a
				inc de
				ld bc,40
				add hl,bc
				pop bc
				dec c
				jr nz,.cp_lp2
				pop hl
				nextcolumnhl
				pop bc
				djnz .cp_lp1
				
				pop af
				SETPGC000
		;----------------------------------------		
				;fill known person hexs
				ld a,4
				ld b,0x23
.f_lp1:
				call loc_B1BF
				inc a
				djnz .f_lp1
				
				ld hl,0xc000+0*40+31
				ld      (text_screen_address), hl
				ld      a, 7
				ld      (symbol_color), a
				xor     a
				ld      (characters_to_print_byte_8D53), a
				ld      hl, MSG_AC93
				call    print_text_line
				ld      a, 6
				ld      (symbol_color), a
				ld      a, 0x0C
				ld      (characters_in_text_line), a
				ld      hl,0xc000+168*40+30		;0F4BCh
				ld      (text_screen_address), hl
				ld      hl, MSG_B321
				call    print_text_line				
					
.loc_B00C:
				ld a,(keymatrixix+1)
				bit 0,a
				jr z,.loc_B00C
.loc_B00F:				
				xor     a
                call    wait_for_key_input					
                inc     a
                jr      z, .enter_pressed_loc_B07C
                cp      1Ch
                jr      z, .space_pressed     ; 1b+1


				jr      .loc_B00F
; ---------------------------------------------------------------------------
;exit by space
.space_pressed
				ld a,(curpgc000)
				ld (.staf),a
				ld a,(user_scr0_low)
				SETPGC000
                call    loc_B236_clr
.staf = $+1
				ld a,0
				SETPGC000
                ld      a, 0x56
                call    load_image
                jp      loc_AD68
; ---------------------------------------------------------------------------
;enter pressed
.enter_pressed_loc_B07C: 
                ld      a, (.loc_B0AC+1)
.loc_B07F:
                inc     a
                cp      28h ; '('
                jr      c, .loc_B087
                xor     a
                jr      .loc_B07F
.loc_B087:
                call    get_pointer_to__gamestate_main_by_A
                inc     hl
                inc     hl
                inc     hl
                bit     4, (hl)
                jr      z, .loc_B07F
                ld      (.loc_B0AC+1), a
				
                push    af
				ld a,(curpgc000)
				ld (.staf),a
				ld a,(user_scr0_low)
				SETPGC000
				
                call    loc_B236_clr
                pop     af
                call    sub_B1AF	;get person coordinate
				ld a,(hl)
				ld (loc_B236_clr+1),a
                ld      (loc_B236+1), hl	;новые координаты
.staf = $+1
				ld a,0
				SETPGC000

.loc_B0AC:
                ld      a, 0
                add     a, 1Fh
                ld      (portrait_lock), a
				call    subsub_b07c
                ld      hl,0xc000+101*40+30		; 0DFCCh
                ld      bc, 0x420a			;4214h
                call    clear_window
                ld      a, 14h
                ld      (characters_in_text_line), a
                ld      a, (.loc_B0AC+1)
                ld      b, a
                call    bsub_B11E
                ld      a, (.loc_B0AC+1)
                call    get_pointer_to__gamestate_main_by_A
                inc     hl
                inc     hl
                ld      a, (hl)
                add     a, 32h ; '2'
                ld      (.loc_B0E9+1), a
                ld      b, 0AEh
.loc_B0E8:
                ld      a, b
.loc_B0E9:
                cp      0
                jr      nz, .loc_B0F8
                call    get_pointer_to__gamestate_main_by_A
                ld      de, 4
                add     hl, de
                bit     6, (hl)
                jp      nz, loc_B13B
.loc_B0F8:
                djnz    .loc_B0E8
				
loc_B0FA:
				call    get_pointer_to__gamestate_main_by_A
				inc     hl
				inc     hl
				ld      a, (hl)
				ld      (loc_B10A+1), a
				ld      b, 0AEh
loc_B105:
                ld      a, b
                call    get_pointer_to__gamestate_main_by_A
                ld      a, (hl)
loc_B10A:
                cp      0
                jr      nz, loc_B116
                ld      de, 4
                add     hl, de
                bit     7, (hl)
                jr      nz, loc_B151
loc_B116:
                djnz    loc_B105

loc_B118:
				ld a,(curpgc000)
				ld (.staf),a
				ld a,(user_scr0_low)
				SETPGC000
				ld a,6
                call    loc_B236
.staf = $+1
				ld a,0
				SETPGC000
					push bc,af
					ld bc,49152
1					dec bc
					ld a,b
					or c
					jr nz,1b
					pop af,bc
                jp      relation_connections.loc_B00C
				
loc_B236_clr:
				ld a,0xff				
loc_B236:
				ld hl,0000		;scr addr
				cp 0xff
				ret z
				ld (fill_hex_clr.spa_clr),a
				jp fill_hex_clr		

bsub_B11E: 
                push    bc
                ld      a, 1
                ld      (characters_to_print_byte_8D53), a
                ld      hl,0xc000+93*40+30	; 0DCACh
                ld      (text_screen_address), hl
                ld      hl, MSG_B33F
                ld      a, 6
                call    sub_AE69
                pop     bc
                call    bsub_B165
                ld      a, 7
                jp      sub_AE69	
loc_B151:
                push    bc
                ld      hl, MSG_B34A
                ld      a, 6
                call    sub_AE69
                pop     bc
                call    bsub_B165
                ld      a, 7
                call    sub_AE69
                jr      loc_B118
loc_B13B:
                push    bc
                ld      hl, MSG_B344
                ld      a, 6
                call    sub_AE69
                pop     bc
                push    bc
                call    bsub_B165
                ld      a, 7
                call    sub_AE69
                pop     af
                jp      loc_B0FA				
bsub_B165:
                ld      e, b
                ld      d, 0
                ld      hl, A650_strings
                jp    find_string_by_de
				
sub_B1AF:
                push    af
                add     a, a
                ld      hl, person_icons_coordinates_array-2
                add     a, l            ; add hl,a
                ld      l, a
                jr      nc, 1f
                inc     h
1
                ld      a, (hl)
                inc     hl
                ld      h, (hl)
                ld      l, a
                pop     af
                ret



loc_B1BF:
			call get_pointer_to__gamestate_main_by_A
			inc     hl
			inc     hl
			inc     hl
			bit     4, (hl)
			ret     z
			ld      c, a
			push    bc
			call    sub_B1AF	;hl screen coordinates
			ld a,(curpgc000)
			push af
			ld a,(user_scr0_high)
			SETPGC000
			push hl
				
				ld de,sprbuf
				ld bc,0x020f
.spp_lp1
				push bc
				push hl
.spp_lp2				
				push bc
				ld a,(de)
				ld (hl),a
				inc de
				ld bc,40
				add hl,bc
				pop bc
				dec c
				jr nz,.spp_lp2
				pop hl
				nextcolumnhl
				pop bc
				djnz .spp_lp1
			
			ld a,(user_scr0_low)
			SETPGC000
			pop hl
							
				ld a,4
				ld (fill_hex_clr.spa_clr),a
				call fill_hex_clr
				
				pop af
				SETPGC000
			pop bc
			ld a,c
			ret
; ---------------------------------------------------------------------------
fill_hex_clr:			
				ld bc,0x020f
.spa_lp1
				push bc
				push hl
.spa_lp2				
				push bc
.spa_clr=$+1				
				ld (hl),4
				ld bc,40
				add hl,bc
				pop bc
				dec c
				jr nz,.spa_lp2
				pop hl
				nextcolumnhl
				pop bc
				djnz .spa_lp1
				ret				
;=--------------------------------------------------------------
print_answer_text_String:
                call    print_text_at_location
                ld      hl, (txt_string_id)
                inc     hl
                ld      (txt_string_id), hl
                ret
display_answ_image:
                ld      hl, (screen_adress_for_npc_portrait)
zloc_AE3A:
                ld      de, 0
                add     hl, de
                ld      (screen_adr_img), hl
                ld      a, (image_to_display_AE5B)
                add     a, 3
                jp      load_portrait_image

wait_enter_key = sub_928C
some_strings:
                push    bc
                call    wait_enter_key
                call    print_answer_text_String
                pop     bc
                djnz    some_strings
                ret
module_9d:
				call no_mus
				call    print_answer_text_String
				call    sub_928C	;wait_enter_key
				call    print_text_at_location
				ld      a, 5
				call    load_text_module
				call    sub_928C	;wait_enter_key
				ld      hl, 0Dh         ; text string index
				ld      b, 1
				ld      de,40*40	; 0C80h       ; screen addr offset
				ld      (zloc_AE3A+1), de
				;ld      de, MUSIC_answ_aea8
				ld e,3
				ld      a, (unk_8d2b)
				cp      8
				jr      z, .loc_AD99
				ld      l, 1Dh          ; text string index
				inc     b
				ld      de, 60*40	;12C0h       ; screen addr offset
				ld      (zloc_AE3A+1), de
				;ld      de, mus_answ_b3ee
				ld e,4
.loc_AD99:
                ld      (txt_string_id), hl
                ld      a, b
                ld      (image_to_display_AE5B), a
				ld a,e
				call load_mus
                ;ld      (mus_pointer), de
				;call    initialize_OPN

                call    print_answer_text_String
                call    display_answ_image
                call    wait_enter_key
                call    print_answer_text_String
                ;call    sub_AE49        ; что-то с управлением музыкой
                call    wait_enter_key
                call    print_answer_text_String
                call    wait_enter_key
                call    print_answer_text_String
                ;call    sub_AE49        ; что-то с управлением музыкой
                call    wait_enter_key
                call    print_answer_text_String
                call    sub_8a0c
				
                ld      hl, 0xC001
                ld      (screen_adr_img), hl
                ld      a, (image_to_display_AE5B)
                call    load_image
                ld      a, (location_id_8d28)
                add     a, 1Fh
                call    load_portrait_image
                call    display_answ_image
                ;call    sub_AE49
                ld      b, 5
				call some_strings
                ;call    sub_AE49
                ld      b, 5
				call some_strings
                ;call    sub_AE49
                call    wait_enter_key
                call    print_text_at_location
				call wait_enter_key

				ld a,(curpgc000)
				push af
				ld a,(user_scr0_low)
				SETPGC000
				
                ld      hl, 0C000h
                ld      bc, 0
                ld      xh, 0Dh

.loc_AE73:                 
				xor a
				ld (.rety),a
                push    bc
                push    hl
				halt
.loc_AE75:                          
                xor     a
				ld (hl),a
                ld      de, 6
                add     hl, de
				nextcolumnhl
.rety	= $+1			
				ld a,0				
                add     a, c
                add     a, e
                ld      c, a
				push af
				ld a,(.rety)
				xor 1
				ld (.rety),a
				pop af
                sub     29			;3Ah ; ':'
                jr      c, .loc_AE75
				
                ld      c, a
                ld      de, 11	;16h
                add     hl, de
                inc     b
                ld      a, b
                cp      9Ch
                jr      c, .loc_AE75
                pop     hl
                pop     bc
                inc     hl
                inc     c
                dec     xh
                jr      nz, .loc_AE73

				pop af
				SETPGC000

                jp      return_to_city			

				
module_9f:
				call 	no_mus
				call    print_answer_text_String
				call    sub_928C
				call    print_text_at_location				
				ld      a, 5
				call    load_text_module
				call    sub_928C
				;ld      hl, 0B08Eh
				;ld      (mus_pointer), hl
				;call    initialize_OPN
				ld a,5
				call load_mus
				
				ld      hl, 2Dh ; '-'
				ld      (txt_string_id), hl
				call    print_answer_text_String
				ld      b, 3
				call    some_strings
				call    sub_928C
				call    clear_loc_screen
				ld      hl, 0xc000+11	;0C016h
				ld      (screen_adr_img), hl
				ld      a, 3
				call    load_image
				call    print_answer_text_String
				;call    rsub_AE14
				ld      b, 4
				call    some_strings
				;call    rsub_AE14
				ld      b, 4
				call    some_strings
				;call    rsub_AE14
				ld      b, 4
				call    some_strings
				ld      a, 8
				call    load_image
				;call    sub_AE14
				ld      b, 1
				call    some_strings
				;call    sub_AE14
				ld      b, 2
				call    some_strings
				;call    sub_AE14
				ld      b, 2
				call    some_strings
				ld      hl, 0xC001
				ld      (screen_adr_img), hl
				ld      a, 6
				call    load_image
				call    wait_enter_key
				call    print_answer_text_String
				;call    sub_AE14
				call    wait_enter_key
				call    print_answer_text_String
				;call    sub_AE14
				call    wait_enter_key
				
				ld sp,sp_main
				ret
;				ld      a, 64h ; 'd'
;				ld      (loc_AE82+1), a
;				ld      (loc_AE8C+1), a



		display "exec_ru_code_ends: ",/d,$
font	        incbin "_rus/intro_font.bin"
                display "exec_ru_full_ends: ",/d,$
                ENT
ri_end:
	savebin "jb2manreq/exec_r.bin",ri_start,ri_end-ri_start
	ENDMODULE