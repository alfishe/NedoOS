;utf8
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
load_buf1:   db 0  ;13
load_buf2:   db 0  ;24
mem_buf1:    db 0 ;13
mem_buf2:    db 0 ;24
scr_buf1:    db 0 ;13 ;additional buffers. (reserved) !!! load sprites here !!!
scr_buf2:    db 0 ;24 ;additional buffers. (reserved)
font_page:   db 0;here goes font_rus
plr_page:    db 0
plr_page2:   db 0
plr_page3:   db 0
zx0_page:    db 0
pagestbllen=$-pagestbl


src_buf1:     db 0 ;datasource for screen output 
src_buf2:     db 0

;----setup---
res_path:    db "SanShimai",0

language:    db 0  ;0 eng | 1 rus
gfx_mode:    db 0  ;0 DDp | 1 16c | 2 ATM
mus_mode:    db 0  ;0 AY  | 1 s98

censor_mode db 0  ;0-normal 1-censorship
;------intro-----

intro_txt0      DB	"Transman/U_Corp and NCy",0
intro_txt1       DB	"   Proudly Presents:   ",0
intro_txt2       DB	"       (c)JAST         ",0

intro_pic1      db "kitunem",0
intro_pic2      db "sp_001",0

intro_text      db "intro.OVL",0

intro_mus:      DB 1  

menu_pic 	 db "sansi",0
menu_mus 	 db 23



ingame_border   db "flerin",0
anim_w          db "push",0

font_file       db "font_rus.bin",0

SAVETEMPL	db "SSSDATA0.000",0
SAVETEMPL_N	equ SAVETEMPL+7

endingovl	db "GOVER.OVL",0
FSTOVL		db "SK_101.OVL",0

tb008:           db "tb_008",0
OVL		ds 13,0
LOADED		ds 13,0	
;---palette----
setpalflag:  db 0

pal_rgb   ds 32,0xff

stdpal:  STANDARDPAL
pal:     ds 32,0xff 
mempal:  ds 32,0xff
temppal  ds 32,0xff
whitepal  ds 32,12 ;00001100b
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
CORDS dw 0

g_curpos dw 0 ; 㼡񡮭硯������  (򭦹殨㡮𞮩
g_atpos  dw 0 ; 믮񥩭᳻ 嬿 㼢怒  y x
;------------------------------
DELAY db 0
;------------------------------
mus_path1:
        db "mus/",0
mus_path2:        
        db  "/ss_00.",0

gfx_path1:        
		db "gfx/",0
gfx_ext db ".16z",0		

ovl_path1:
		db "ovl/",0	


anim_ext: db ".gfx",0	

censor_path: db "censored/",0
;------------------------------
namebuf ds 14,0

MENUCURHELPER:
	dw 0xda44-160
	dw 0xda4c-160
	dw 0xda54-160
	dw 0xda5c-160

	dw 0xdb84-160
	dw 0xdb8c-160
	dw 0xdb94-160
	dw 0xdb9c-160

	dw 0xdcc4-160
	dw 0xdccc-160
	dw 0xdcd4-160
	dw 0xdcdc-160

	dw 0xde04-160
	dw 0xde0c-160
	dw 0xde14-160
	dw 0xde1c-160
eyes_table:
	db "ST01a0",0
	dw 32,24
	dw 32,12
	db 3
	db "ST02a0",0
	dw 32,24
	dw 32,12
	db 3
	db "ST03a0",0
	dw 32,24
	dw 32,12
	db 3	
	db "ST04a0",0
	dw 32,24
	dw 32,12
	db 3	
	db "ST05a0",0
	dw 48,24
	dw 28,12
	db 3	
	db "ST06a0",0
	dw 156,32
	dw 32,12
	db 3	
	db "ST07a0",0
	dw 156,32
	dw 32,12
	db 3	
	db "ST08a0",0
	dw 32,32
	dw 32,12
	db 3	
	db "ST09a0",0
	dw 32,32
	dw 32,12
	db 3
	db "ST10a0",0
	dw 112,32
	dw 32,12
	db 2
	db "ST11a0",0
	dw 112,32
	dw 32,12
	db 2
	db "ST12a0",0
	dw 84,36
	dw 24,8
	db 2
	db "ST13a0",0
	dw 44,44
	dw 28,16
	db 2
	db "ST14a0",0
	dw 172,44
	dw 28,16
	db 3
	db "ST15a0",0
	dw 172,44
	dw 28,16
	db 3
	db "ST16a0",0
	dw 152,16
	dw 32,12
	db 3
	db "ST17a0",0
	dw 152,16
	dw 32,12
	db 3
	db "ST18a0",0
	dw 48,12
	dw 24,12
	db 3
	db "ST19a0",0
	dw 28,20
	dw 24,16   ;24,16
	db 3
	db "ST20a0",0
	dw 172,24
	dw 28,20
	db 2
	db "ST21a0",0
	dw 96,24
	dw 24,16
	db 3
	db "ST21a1",0
	dw 136,44
	dw 28,16
	db 3
	db "ST22a0",0
	dw 108,28
	dw 28,16
	db 3
	db "ST23a0",0
	dw 44,28
	dw 28,12
	db 3
	db "ST24a0",0
	dw 36,36
	dw 32,20
	db 3
	db "ST25a0",0
	dw 152,20
	dw 24,12
	db 2
	db "ST26a0",0
	dw 36,28
	dw 28,12
	db 3
	db "ST27a0",0
	dw 36,28
	dw 28,12
	db 3
	db "ST28a0",0
	dw 96,36
	dw 32,12
	db 2
	db "ST29a0",0
	dw 116,28
	dw 28,16
	db 3
	db "ST30a0",0
	dw 116,28
	dw 28,16
	db 3
	db "ST31a0",0
	dw 36,24
	dw 28,20
	db 3
	db "ST32a0",0
	dw 36,24
	dw 28,20
	db 3
	db "ST33a0",0
	dw 168,28
	dw 28,12
	db 3
	db "ST34a0",0
	dw 168,28
	dw 28,12
	db 3
	db "ST35a0",0
	dw 112,24
	dw 28,16
	db 3
	db "ST36a0",0
	dw 92,36
	dw 32,12
	db 3
	db "ST38a0",0
	dw 156,32
	dw 32,12
	db 2
	db "ST39a0",0
	dw 36,24
	dw 28,20
	db 3
	db "ST40a0",0
	dw 152,16
	dw 32,12
	db 3
	db 0xff