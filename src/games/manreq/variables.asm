mus_mode:	db 0
lang_mode	db 0


scr0high	db 0
scr0low		db 0
;------------------------
plr_tabl_intro
			dw plr1_intro
			dw plr2_intro	
plr1_intro:		db "ay_plr1.bin",0
plr2_intro:		db "opn_plr1.bin",0

plr_tabl_game
			dw plr1_game
			dw plr2_game	
plr1_game:		db "ay_plr.bin",0
plr2_game:		db "opn_plr.bin",0
;------------------------

ext_name	dw e_name_ay
			dw e_name_tfm
e_name_tfm:
e_name_ay	db ".s98",0
			

f_name		dw s_name_ay
			dw s_name_tfm
s_name_ay	db "ay/",0
s_name_tfm      db "tfm/",0
;------------------------


gfx_path1:        
		db "gfx/",0
gfx_path2:        
		db ".pct",0
;------------------------
intro_s		dw intro_j
			dw intro_r
intro_j		db "intro_j.bin",0
intro_r		db "intro_r.bin",0


outro_s		dw outro_j
			dw outro_r
outro_j		db "outro_j.bin",0
outro_r		db "outro_r.bin",0


exe_s		dw exe_j
			dw exe_r
exe_j		db "exec_j.bin",0
exe_r		db "exec_r.bin",0


exe_z		dw exe_zj
			dw exe_zr
exe_zj		db "j",0
exe_zr		db "r",0
;------------------------
game_s		dw game_j
			dw game_e

game_j		db "game_j.bin"
game_e		db "game_e.bin"


winpage1:	db 0
winpage2:	db 0
winpage3:	db 0

pagestbl:
load_buf1       db 0
load_buf2       db 0
jb_logo_buf		db 0	;для загрузки jb logo
portrait_buf	db 0	;для загрузки портретов
item_buf		db 0	;для загрузки предметов
scr_buff		db 0	;для сохранения фона под меню
font_page       db 0
plr_page        db 0
plr_page2       db 0
plr_page3       db 0

textpage1		db 0
textpage2		db 0
textpage3		db 0

pagestbllen=$-pagestbl


src_buf1:     	db 0 ;datasource for screen output 
src_buf2:     	db 0

res_path:    	db "jb2manreq",0

txt_mdl:		db "j_mdl4.bin",0

saveslot= $+4
savename		db "slot0.sav",0
;---palette----
setpalflag:  	db 0

pal_rgb   ds 32,0xff

stdpal:  STANDARDPAL
pal:     ds 32,0xff 
mempal:  ds 32,0xff
temppal  ds 32,0xff
gfdpal  ds 32,0xff

;-------keyboard
keyreg db 0
keymatrixbc dw 0
keymatrixde dw 0
keymatrixhl dw 0
keymatrixix dw 0 

lastvar
lastkey db 0
lastspace dw 0
lastchar db 0
;------------------------------


			align 256
t_s98_file00_pages_list:
				ds 256,0
buf:			ds 64,0


;===========================
;ingame variables


file_index:						    db 51h               ;0x8d1e
byte_8d1f: 							db 0                ;oo_location_menu_entries_8D1F
txt_string_id:						dw 0				;0x8d20
word_8d22:						    dw 0Ch 
word_8d24:      					dw 0
									db 0
temp_location_id_byte_8d27:			db 0				;0x8d27
location_id_8d28: 					dw 0				;0x8d28
byte_8d2a:  					    db 0  				;0x8d2a
unk_8d2b							db 0				;0x8d2b
location_image_number:				db 0          		;0x8d2c

byte_8d2d:						    db 0     			;0x8d2d	array 4 byte
byte_8d2e:     						db 0             
byte_8d2f:      					db 0             
									db 0
									
byte_8d31:      					db 0             
byte_8d32:      					db 0             
byte_8d33							db 0				;0x8d33

sizex   db 0
sizey   db 0	
screen_adr_img 							dw 0
portrait_lock:  						db 0                ;0x8d48
screen_adress_for_npc_portrait:			dw 0   				;0x8d49
frame_screen_address:					dw 0C000h           ;0x8d4b
                                        ; store_piece_of_screen_in_buffer+6vr ...
                                        ; адрес экранной области, начиная с которого будет рисоваться рамка меню
screen_buffer_address:					dw 133Ch     	    ;0x8d4d
count_of_vertical_lines_in_the_frame	db 0				;0x8d49
can_use_letters							db 0				;0x8d50
max_letter_allowed						db 0			    ;0x8d51
use_second_half_of_font					db 0				;0x8d52
characters_to_print_byte_8D53       	db 0				;0x8d53
text_screen_address                 	dw 0				;0x8d54
text_screen_address_current				dw 0				;0x8d56
symbol_color							db 0				;0x8d58
characters_in_text_line             	db 0				;0x8d59
current_menu_entry_pointer				dw 0				;0x8d5a
frame_horisontal_offset_type			db 2				;0x8d5c ; определяет начиная с какого адреса рисовать рамку
																	; 0 - c1a0 (pc-88)
																	; 1 - c190
																	; 2 - c198
keep_top_text_line                  	db 0				;0x8d76
image_to_display_AE5B:					db 0

gamestate_fdc_buffer: ds 256
text_buffer			  ds 512
text_buffer_len = $-text_buffer
init_fname	db "init.bin",0

i_1     		db "gfx/zx1.gfd",0
i_2     		db "gfx/zx2.gfd",0
i_3     		db "gfx/zx3.gfd",0
i_4     		db "gfx/zx4.gfd",0
i_5     		db "gfx/zx5.gfd",0
i_6     		db "gfx/zx6.gfd",0
i_7     		db "gfx/zx7.gfd",0
i_8     		db "gfx/zx8.gfd",0
i_9     		db "gfx/zx9.gfd",0
i_a     		db "gfx/zxa.gfd",0
i_b     		db "gfx/zxb.gfd",0
i_c     		db "gfx/zxc.gfd",0
i_d     		db "gfx/zxd.gfd",0
;=====================================
				display "table_dialogue_questions_index_buffer_8D5D :",/d,$
table_dialogue_questions_index_buffer_8D5D:
                                        ; table: byte per entry. first offset is 0
                                        ; буфер для номеров строк которые будут показываться в окошке - меню выбора в диаллогах

				db    1
                db    2
                db    3
                db    4
                db    5
                db    6
                db    7
                db    8
                db    9
                db  0Ah
                db  0Bh
                db  0Ch
                db  0Dh
                db  0Eh
                db  0Fh
                db  10h
                db  11h
                db  12h
                db  13h
                db  14h
                db  15h
                db  17h
                db  18h
                db  19h
                db  1Ah

location_menu_entries_table:
                db 1, 2, 3, 4, 5, 7, 0
                db 9, 8, 0Bh, 0Ch, 0, 0, 0
                db 9, 8, 0Ah, 0Ch, 0, 0, 0
                db 0Eh, 0Dh, 5, 0Fh, 0, 0, 0
                db 10h, 11h, 0Ah, 0Bh, 0, 0, 0
                db 12h, 14h, 0Ah, 0Bh, 0Ch, 0, 0
                db 9, 13h, 14h, 0Ah, 0Bh, 0Ch, 0
                db 15h, 16h, 20h, 0Fh, 0, 0, 0
                db 15h, 16h, 20h, 1Ah, 0Fh, 0, 0
                db 17h, 1Ch, 18h, 23h, 6, 0Fh, 0
                db 17h, 1Ch, 18h, 23h, 6, 1Ah, 0Fh
                db 1Fh, 21h, 22h, 0Fh, 0, 0, 0
                db 1Fh, 21h, 22h, 0Fh, 0, 0, 0
                db 17h, 1Ch, 18h, 23h, 6, 19h, 0Fh
                db 1Bh, 1Dh, 1Eh, 0, 0, 0, 0

menu_strings_index_array_table_unk_96AF:
				db 0xaf,0xb0 ;номера текстовых строк file1 file2
;фактическая таблица				96AF 				
person_icons_coordinates_array: ;now- ATM screen scr addr / was coordinates list y,x - dw yyxx 
                dw 0xc000+0x39*40+8			; 3810h
                dw 0xc000+0x09*40+14			; 081Ch
                dw 0xc000+0x11*40+15+0x2000	; 101Fh
                dw 0xc000+0xa1*40+6+0x2000		; 0A00Dh							;a=4*2
                dw 0xc000+0x21*40+9+0x2000		; 2013h
                dw 0xc000+0x69*40+5			; 680Ah
                dw 0xc000+0x79*40+5			; 780Ah
                dw 0xc000+0x71*40+6+0x2000		; 700Dh
                dw 0xc000+0x09*40+23			; 82Eh
                dw 0xc000+0x39*40+20			; 3828h
                dw 0xc000+0x21*40+18+0x2000	; 2025h
                dw 0xc000+0x21*40+27+0x2000	; 2037h
                dw 0xc000+0x31*40+21+0x2000	; 302Bh
                dw 0xc000+0x41*40+12+0x2000	; 4019h
                dw 0xc000+0x29*40+11			; 2816h
                dw 0xc000+0x39*40+5			; 380Ah
                dw 0xc000+0x29*40+2			; 2804h
                dw 0xc000+0x59*40+11			; 5816h
                dw 0xc000+0x89*40+14			; 881Ch
                dw 0xc000+0x79*40+11			; 7816h
                dw 0xc000+0xa9*40+14			; 0A81Ch
                dw 0xc000+0xb1*40+15+0x2000	; 0B01Fh
                dw 0xc000+0x39*40+26			; 3834h
                dw 0xc000+0x71*40+21+0x2000	; 702Bh
                dw 0xc000+0x89*40+20			; 8828h
                dw 0xc000+0x71*40+24+0x2000	; 7031h
table_unk_96E5:
				dw 0xc000+0x71*40+27+0x2000	; 7037h
				dw 0xc000+0xa1*40+24+0x2000	; 0a031h
				dw 0xc000+0xa1*40+27+0x2000 ; 0a037h
				dw 0xc000+0x69*40+2			; 6804h
				dw 0xc000+0x09*40+5			;080ah
				dw 0xc000+0x09*40+11		;0816h				
                dw 0xc000+0x59*40+20		;5828h
                dw 0xc000+0xa9*40+5			;0A80Ah
                dw 0xc000+0x21*40+24+0x2000	;2031h
                dw 0xc000+0x51*40+27+0x2000	;5037h
                dw 0xc000+0x71*40+12+0x2000	;7019h
				dw 0xc000+0x21*40+6	+0x2000	;200Dh
				dw 0xc000+0x01*40+27+0x2000	;37h

table_96FF:     db 4, 5, 6, 7, 0Bh, 0Ch, 0Eh, 11h, 18h, 19h, 1Ah, 20h, 23h, 26h

;table_unk_96E5 actual start
                db 22h, 10h, 15h, 21h, 0Ah, 1Eh, 1Dh, 1Fh, 9, 28h
                db 10h, 0Fh, 1Fh, 15h, 0Ah, 0, 0, 0, 0, 0
                db 21h, 1Eh, 28h, 1Ch, 15h, 1Fh, 8, 0, 0, 0 
                db 21h, 1Eh, 28h, 1Ch, 15h, 1Fh, 8, 0, 0, 0
                db 15h, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 22h, 0Ah, 0, 0, 0, 0, 0, 0, 0, 0
                db 0Dh, 17h, 15h, 9, 0, 0, 0, 0, 0, 0
                db 0Ah, 0Dh, 15h, 17h, 9, 0, 0, 0, 0, 0
                db 9, 0Ah, 0Dh, 17h, 15h, 0, 0, 0, 0, 0
                db 0Ah, 17h, 15h, 0, 0, 0, 0, 0, 0, 0
                db 0Fh, 10h, 12h, 0, 0, 0, 0, 0, 0, 0
                db 10h, 12h, 0, 0, 0, 0, 0, 0, 0, 0
                db 0Fh, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 10h, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 14h, 0Fh, 13h, 0, 0, 0, 0, 0, 0, 0
                db 14h, 12h, 0, 0, 0, 0, 0, 0, 0, 0
                db 12h, 13h, 15h, 0, 0, 0, 0, 0, 0, 0
                db 16h, 0Ah, 14h, 17h, 0Dh, 1Dh, 21h, 1Eh, 0, 0
                db 15h, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 15h, 0Ah, 9, 0, 0, 0, 0, 0, 0, 0
                db 1Bh, 1Ch, 14h, 1Dh, 15h, 9, 28h, 21h, 0, 0
                db 1Bh, 1Ch, 14h, 1Dh, 21h, 0, 0, 0, 0, 0
                db 1Bh, 1Ch, 1Dh, 15h, 9, 0, 0, 0, 0, 0
                db 1Ch, 1Dh, 0, 0, 0, 0, 0, 0, 0, 0
                db 1Dh, 1Bh, 9, 0, 0, 0, 0, 0, 0, 0
                db 1Ch, 15h, 0, 0, 0, 0, 0, 0, 0, 0
                db 28h, 15h, 0, 0, 0, 0, 0, 0, 0, 0
				
table_unk_981B: db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0Fh, 15h, 0Ah, 0, 0, 0, 0, 0, 0, 0
                db 28h, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 1Dh, 15h, 9, 0, 0, 0, 0, 0, 0, 0
                db 3, 4, 8, 12h, 14h, 1Bh, 0Ah, 0Eh, 22h, 0
                db 3, 4, 7, 23h, 1Ah, 8, 14h, 16h, 12h, 1Eh
                db 3, 4, 5, 22h, 16h, 1Dh, 19h, 12h, 14h, 23h
                db 3, 4, 5, 22h, 16h, 12h, 0, 0, 0, 0
                db 3, 4, 5, 22h, 16h, 0, 0, 0, 0, 0
                db 0Eh, 0Ah, 14h, 13h, 0, 0, 0, 0, 0, 0
                db 14h, 13h, 15h, 0Ah, 0, 0, 0, 0, 0, 0
                db 14h, 13h, 15h, 17h, 0, 0, 0, 0, 0, 0
                db 14h, 12h, 0Ah, 22h, 13h, 0, 0, 0, 0, 0
                db 14h, 0Ah, 13h, 0, 0, 0, 0, 0, 0, 0
                db 3, 4, 7, 8, 24h, 14h, 15h, 0, 0, 0
                db 3, 4, 12h, 8, 14h, 7, 6, 0, 0, 0
                db 3, 4, 7, 8, 14h, 0, 0, 0, 0, 0
                db 0Dh, 3, 7, 4, 14h, 0, 0, 0, 0, 0
                db 3, 4, 7, 8, 24h, 0, 0, 0, 0, 0
                db 3, 7, 0Fh, 0Eh, 0, 0, 0, 0, 0, 0
                db 3, 7, 20h, 0Fh, 8, 0, 0, 0, 0, 0
                db 3, 8, 14h, 9, 22h, 18h, 25h, 0, 0, 0
                db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 3, 7, 1Eh, 16h, 0Ah, 0Eh, 0, 0, 0, 0
                db 3, 1Ah, 0Fh, 22h, 0Eh, 14h, 18h, 0Ah, 0, 0
                db 3, 17h, 0Fh, 0Eh, 22h, 14h, 15h, 0, 0, 0
                db 3, 15h, 0Fh, 0Eh, 14h, 22h, 0, 0, 0, 0
                db 0Fh, 0Eh, 22h, 0, 0, 0, 0, 0, 0, 0
                db 0Fh, 0Eh, 22h, 17h, 18h, 0, 0, 0, 0, 0
                db 22h, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 21h, 19h, 0, 0, 0, 0, 0, 0, 0, 0
                db 1Ch, 15h, 0, 0, 0, 0, 0, 0, 0, 0
                db 3, 16h, 15h, 4, 12h, 0, 0, 0, 0, 0
                db 0Ah, 0, 0, 0, 0, 0, 0, 0, 0, 0
                db 0Eh, 0, 0, 0, 0, 0, 0, 0, 0, 0

table_unk_9979: db 4, 5, 6, 7, 0Bh, 0Ch, 0Eh, 11h, 18h, 19h, 1Ah, 20h, 23h, 26h, 15h, 9, 0Ah, 1Dh, 1Bh, 1Ch, 21h, 1Eh, 1
                db 25h, 24h
table_unk_9992: db 3, 4, 8, 9, 0Bh, 0Ch, 0Eh, 12h, 14h, 23h, 22h
data_unk_999D:  db    3
table_unk_999E: db 4, 8, 9, 0Eh, 12h, 14h, 23h, 22h ; 999e is base pointer to table at 99a6
                                        ; so no value 0 can be passed to get data. minimum value is 1
										