txt_memoryerror:    db 0x0A,"Memory allocation error!",0x0D,0x0A,0
txt_fopenerror:     db 0x0A,"Cannot open file: ",0
txt_fcreateerror:    db 0x0A,"Cannot create file: ",0
txt_freaderror:     db 0x0A,"Cannot read file: ",0
txt_fwriteerror:     db 0x0A,"Cannot write file: ",0	
txt_dircherror:     db 0x0A,"Cannot change directory: ",0
txt_nl:             db 0x0D,0x0A,0





;-----memory------
winpage0:    db 0 ;0x0000-0x3fff
script_buf1:
winpage1:    db 0 ;0x4000-0x7fff
script_buf2:
winpage2:    db 0 ;0x8000-0xbfff
winpage3:    db 0 ;0xc000-0xffff

pagestbl:
plr_page     db 0
plr_page2    db 0
plr_page3    db 0
load_buf1:   db 0  ;13
load_buf2:   db 0  ;24
mem_buf1:    db 0 ;13
mem_buf2:    db 0 ;24
scr_buf1:    db 0 ;13 ;additional buffers. (reserved) !!! load sprites here !!!
scr_buf2:    db 0 ;24 ;additional buffers. (reserved)
font_page    db 0;here goes font_rus
zx0_page     db 0
pagestbllen=$-pagestbl


src_buf1:     db 0 ;datasource for screen output 
src_buf2:     db 0





;----setup---
res_path:    db "BOD",0

language:    db 1  ;0 eng | 1 rus
gfx_mode:    db 0  ;0 DDp | 1 16c | 2 ATM
mus_mode:    db 0  ;0 AY  | 1 s98
v_mode       db 0  ; default | 1 director's cut
dc_enabled   db 0  ;0 -disabled 1-enabled
censor_mode db 0  ;0-normal 1-censorship
;------intro-----

intro_pic1      db "title0",0
intro_pic2      db "title1",0
intro_pic3      db "title2",0

intro_mus:      DB 4  

menu_pic 	 db "menu",0
menu_mus 	 db 4

anim_w          db "push",0

font_file       db "font_rus.bin",0
font_file2       db "propfont.bin",0

SAVETEMPL	db "BODDATA0.000",0
SAVETEMPL_N	equ SAVETEMPL+7

PERSISTSAVE     db "CDATA",0

FSTOVL		db "1.ovl",0

OVL		ds 32,0
LOADED		ds 32,0	
SAVESLOT:       ds 33,0
;---palette----
setpalflag:  db 0

stdpal:  STANDARDPAL
pal:     ds 32,0xff 
mempal:  ds 32,0xff
temppal  ds 32,0xff
whitepal  ds 32,12 ;00001100b
blackpal  ds 32,0xff
pal_rgb   ds 32,0xff

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
CORDS dw 0
CORDS_P dw 0

;------------------------------
DELAY db 0
;------------------------------
mus_path1:
        db "mus/",0
mus_path2:        
        db  "/mt_00.",0

gfx_path1:        
		db "gfx/",0
gfx_ext db ".16z",0		

ovl_path1:
		db "ovl/",0	

censor_path: db "censored/",0
dc_prefix:
		db "dc_",0	
;------------------------------
namebuf ds 14,0
namebuf1: ds 128,0
namebuf2: ds 128,0
ovlnamebuf ds 128,0


lines1: db  "1. ",0
lines2: db  "2. ",0


help_text: db "'Q' - Выход 'S' - Сохранить игру 'L' - Загрузить игру",0

TEXT1 	   DB "(C) 2006 Полет навигатора",0
TEXT3      DB "(С) 2006 I Turned Into Martian!",0
TEXT2	   DB "(L) 2009-2022 Triumph game labs",0

menu1           db "1. Новая игра",0
menu2           db "2. Продолжить",0
menu3           db "3. Выход",0
menu4           db "4. Director's cut",0