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

gfx_path1:        
		db "gfx/",0
gfx_path2:        
		db ".pct",0
;------------------------





exe_s		dw exe_j
			dw exe_r
exe_j		db "exec_j.bin",0
exe_r		db "exec_r.bin",0


exe_z		dw exe_zj
			dw exe_zr
exe_zj		db "j",0
exe_zr		db "r",0
;------------------------


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
scr_buff2		db 0	;для сохранения фона под меню
plr_page        db 0
plr_page2       db 0
plr_page3       db 0

textpage1		db 0
textpage2		db 0

pagestbllen=$-pagestbl


src_buf1:     	db 0 ;datasource for screen output 
src_buf2:     	db 0

res_path:    	db "kissofmurder",0

txt_mdl:		db "j_mdl4.bin",0

saveslot= $+4
savename		db "slot0.sav",0
intr1_img		db "gfx/intr.gfd",0
intr_b_img		db "gfx/intr_b.gfd",0
intr_k_img		db "gfx/intr_k.gfd",0
intr_s_img		db "gfx/intr_s.gfd",0
intr_n_img		db "gfx/intr_n.gfd",0
intr_b_n_img		db "gfx/intr_b_n.gfd",0

ep1_img			db "gfx/1a.gfd",0
ep2_img			db "gfx/2a.gfd",0
ep3_img			db "gfx/3a.gfd",0
ep4_img			db "gfx/4a.gfd",0
ep5_img			db "gfx/5a.gfd",0


;---palette----
setpalflag:  	db 0

pal_rgb   ds 32,0xff

stdpal:  STANDARDPAL
pal:     ds 32,0xff 
mempal:  ds 32,0xff
temppal  ds 32,0xff
blackpal  ds 32,0xff

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
buf:			ds 64,0

				align 256
gamestate_fdc_buffer: ds 256
text_buffer			  ds 512
text_buffer_len = $-text_buffer
init_fname	db "init.bin",0
intro_fname	db "intro.bin",0
outro_fname:    db "outro.bin",0

file_index:						    db 51h               ;0x8d1e



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
characters_to_print                 	db 0				;0x8d53
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

load_image_directly:					db 0

location_id:    db 2                    ; byte_8d1f
txt_string_id:  dw 3
word_B9E7:      dw 0
temp_location_id:db 0
temp_location_id_byte_b9ea:dw 100h

word_B9EC:      dw 0
                dw 0
                dw 0
				
byte_B9F2:      db 0
next_modul:     db 0
unk_B9F4:       db 0
byte_B9F5:      db 0
                db    0
word_B9F7:      dw 0


table_dialogue_questions_index_buffer:
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
				db 0Eh, 0Dh, 10h, 0, 0, 0, 0
                db 1, 2, 26h, 4, 5, 0, 0
                db 1, 3, 27h, 6, 8, 7, 0
                db 16h, 1Ah, 0, 0, 0, 0, 0
                db 11h, 12h, 0Dh, 0Fh, 0, 0, 0
                db 13h, 15h, 0Fh, 10h, 0, 0, 0
                db 0Eh, 14h, 15h, 0Fh, 10h, 0, 0
                db 18h, 19h, 9, 1Fh, 20h, 1Ah, 0
                db 20h, 1Ah, 0, 0, 0, 0, 0
                db 1Bh, 1Dh, 1Ch, 17h, 9, 1Fh, 1Ah
                db 1Dh, 1Ch, 17h, 1Eh, 1Fh, 20h, 1Ah
                db 22h, 23h, 21h, 1Ah, 0, 0, 0
                db 24h, 25h, 19h, 1Ah, 0, 0, 0
                db 0Ah, 0Bh, 0Ch, 1Ah, 0, 0, 0
                db 1, 28h, 2, 0, 0, 0, 0
                db 1, 28h, 3, 0, 0, 0, 0h
msg_9F24:       db 0F8h, 76h, 0AFh, 9Dh, 8Ah, 0FFh
                                        ; ?????? Настоящее начало таблицы где?
                db 83h, 83h, 83h, 0FFh
                db 0B4h, 98h, 94h, 0FFh
                db 9Dh, 8Eh, 87h, 98h, 82h, 0FFh
                db 9Eh, 0ACh, 87h, 9Bh, 8Fh, 98h, 82h, 0FFh
byte_9F40:      db 7Fh, 83h, 82h, 86h, 84h, 93h, 8Bh, 94h, 9Ah, 9Ch, 96h, 95h, 9Fh, 0A0h
                db  7Fh ; 
                db 82h, 8Bh, 0A0h, 7Fh, 86h, 87h, 9Ah
                db 0A0h, 92h, 0, 7Fh, 82h, 84h, 87h
                db 8Fh, 92h, 95h, 7Fh, 80h, 84h, 87h
                db 9Dh, 92h, 95h, 7Fh, 81h, 87h, 84h
                db 9Dh, 92h, 0, 7Fh, 85h, 86h, 88h
                db 84h, 92h, 0, 7Fh, 89h, 8Ah, 93h
                db 92h, 91h, 0, 7Fh, 8Bh, 8Ah, 93h
                db 92h, 0, 0, 7Fh, 94h, 97h, 92h
                db 0, 0, 0, 7Fh, 8Bh, 93h, 92h
                db 90h, 99h, 0, 7Fh, 94h, 98h, 92h
                db 0, 0, 0, 7Fh, 9Ch, 93h, 97h
                db 92h, 0, 0, 7Fh, 8Dh, 8Eh, 0
                db 0, 0, 0, 7Fh, 8Ch, 8Ah, 92h
                db 0, 0, 0, 7Fh, 9Bh, 8Ah, 92h
                db 0, 0, 0, 1, 4, 7, 6
                db 8, 0Ah, 0, 0, 0, 1, 4
                db 7, 6, 8, 0Ah, 0, 0, 0
                db 1, 9, 0Bh, 0Eh, 0Fh, 8, 0
                db 0, 0, 1, 8, 0Ah, 7, 6
                db 0, 0, 0, 0, 1, 2, 3
                db 4, 5, 9, 7, 8, 0Ch, 1
                db 3, 4, 8, 0Ch, 0, 0, 0
                db 0, 1, 3, 4, 8, 0Ch, 0
                db 0, 0, 0, 1, 3, 4, 0
                db 0, 0, 0, 0, 0, 1, 3
                db 2, 4, 5, 8, 0Ch, 0, 0
                db 1, 3, 2, 4, 5, 8, 0
                db 0, 0, 1, 9, 0Bh, 0Eh, 0Fh
                db 0, 0, 0, 0, 1, 6, 7
                db 2, 5, 8, 0Ch, 0, 0, 1
byte_A021:      db 3, 2, 4, 5, 8
                db 0Ch, 0, 0, 1, 4
                db 5, 3, 2, 8, 0Ch
                db 0, 0, 1, 3, 2
                db 8, 0Ch, 0, 0, 0
                db 0, 1, 6, 7, 2
                db 5, 8, 0Ch, 0, 0
                db 1, 3, 2, 4, 5
                db 8, 0Ch, 0, 0, 0
                db 0, 0, 0, 0, 0
                db 0, 0, 0, 1, 0Ch
                db 8, 0, 0, 0, 0
                db 0, 0, 1, 4, 5
                db 0, 0, 0, 0, 0
                db 0, 1, 3, 4, 0Ch
                db 0, 0, 0, 0, 0
                db  7Eh ; ~
                db  88h
                db  8Bh
                db  98h
                db 0A0h
                db  7Eh ; ~
                db 0A0h
                db    0
                db    0
                db    0
                db  7Eh ; ~
                db  84h
                db  98h
                db  94h
                db 0A0h
                db  7Eh ; ~
                db  8Bh
                db 0A0h
                db    0
                db    0
                db  7Eh ; ~
                db  86h
                db 0A0h
                db    0
                db    0
                db  7Eh ; ~
                db 0A0h
                db    0
                db    0
                db    0
                db  7Eh ; ~
                db  7Fh ; 
                db  95h
                db  9Eh
                db 0A0h
                db  7Eh ; ~
                db  7Fh ; 
                db 0A0h
                db    0
                db    0
                db  7Eh ; ~
                db  7Fh ; 
                db  82h
                db 0A0h
                db    0
                db  7Eh ; ~
                db  84h
                db 0A0h
                db    0
                db    0
                db  7Eh ; ~
                db  94h
                db 0A0h
                db    0
                db    0
                db  7Eh ; ~
                db  7Fh ; 
                db  86h
                db  85h
                db 0A0h
                db  7Eh ; ~
                db  7Fh ; 
                db 0A0h
                db    0
                db    0
                db  7Eh ; ~
                db  84h
                db 0A0h
                db    0
                db    0
                db  7Eh ; ~
                db  7Fh ; 
                db  84h
                db 0A0h
                db    0
                db  7Eh ; ~
                db  7Fh ; 
                db  86h
                db  85h
                db 0A0h
                db  7Eh ; ~
                db  7Fh ; 
                db 0A0h
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db    0
                db  7Eh ; ~
                db  9Fh
                db 0A0h
                db    0
                db    0
                db  7Eh ; ~
                db 0A0h
                db    0
                db    0
                db    0
                db  7Eh ; ~
                db  95h
                db 0A0h
                db    0
                db    0

menu_strings_index_array_table_unk_97F2:
				db 0ADh
                db 0AEh