txt_memoryerror:    db 0x0A,"Memory allocation error!",0x0D,0x0A,0
txt_fopenerror:     db 0x0A,"Cannot open file: ",0
txt_fcreateerror:    db 0x0A,"Cannot create file: ",0
txt_freaderror:     db 0x0A,"Cannot read file: ",0
txt_fwriteerror:     db 0x0A,"Cannot write file: ",0	
txt_dircherror:     db 0x0A,"Cannot change directory: ",0
txt_unkcode:        db 0x0A,"unknown code: ",0
txt_nl:             db 0x0D,0x0A,0
txt_unkflag:     db 0x0A,"Unknown flg_if: ",0



;------------------------

loadedCg:	ds 32,0	
text_pointer:   dw 0
	
redraw_border: db 0   ;if set is not zero - redraw border, then set variable to zero  ; if set - F_0 required then loaded



first_word	db 0 ; is first word in line flag
first_letter    db 0
just_cr		db 0 ;

;-----memory------
winpage0:    db 0 ;0x0000-0x3fff
script_buf1:
winpage1:    db 0 ;0x4000-0x7fff
script_buf2:
winpage2:    db 0 ;0x8000-0xbfff
winpage3:    db 0 ;0xc000-0xffff

;reserved pages in memory

plr_page:    db 0
plr_page2:    db 0
plr_page3:    db 0

load_buf1:   db 0  ;13
load_buf2:   db 0  ;24

mem_buf1:    db 0 ;13
mem_buf2:    db 0 ;24

mem_buf3:    db 0 ;13
mem_buf4:    db 0 ;24

scr_buf1:    db 0 ;13 ;additional buffers. (reserved) !!! load sprites here !!!
scr_buf2:    db 0 ;24 ;additional buffers. (reserved)
;-------------

src_buf1:     db 0 ;datasource for screen output 
src_buf2:     db 0
;------------
font_page      db 0;here goes font_rus

bank1:  db 0  ;current page for 4000
bank2:  db 0  ;current page for 8000
bank3:  db 0  ;current page for c000


tbank1 db 0  ;temp page store for 4000
tbank2 db 0  ;temp page store for 8000
tbank3: db 0  ;temp page store for c000


zbank1 db 0  ;temp page store for 4000
zbank2 db 0  ;temp page store for 8000
zbank3: db 0  ;temp page store for c000	
;----setup---
res_path:    db "tenkosei",0

language:    db 1  ;0 eng | 1 rus
gfx_mode:    db 0  ;0 DDp | 1 16c | 2 ATM
mus_mode:    db 0  ;0 AY  | 1 s98
tsfm_mode    db 0 ;0- mode1 nedopc ;1-mode 2 moonsound
tsfm_detected   db 0 ;0- no ;1-yes

censor_mode db 0  ;0-normal 1-censorship
;------intro-----

menu_pic 	 db "th_ti00",0
menu_mus 	 db 24

anim_w          db "push4",0

font_file       db "font_rus.bin",0
font_file2       db "font1251.bin",0

SAVETEMPL	db "TSIDATA0.000",0
SAVETEMPL_N	equ SAVETEMPL+7
SAVETEMPL_EXT   equ SAVETEMPL+9

PERSISTSAVE     db "CDATA",0

;FSTOVL		db "MON_01.OVL",0
FSTOVL		db "MON_01.OVL",0  ;for test purposes

OVL		ds 32,0
LOADED		ds 32,0	
SAVESLOT:       ds 33,0

t_mus:         db 0

;---palette----
setpalflag:  db 0

stdpal:  STANDARDPAL
pal:     ds 32,0xff 
mempal:  ds 32,0xff
temppal:  ds 32,0xff

t_pal:  ds 32,0xff

niggapal:
	  ds 32,0xff

whitepal:  ds 32,0x0c ;00001100b
redpal:	   ds 32,0xbd


blackpal:
	  ds 16,0xff
	  db 0x8c,0xff ;db 0x9c,0x9c
	  ds 12,0x0ff
	  db 0x0c,0x0c	

nblackpal:
	  db 0xff,0xff
          db 0x9c,0x9c	;  db 0x8c,0xff	
	  ds 12,0xff
	  db 0x8c,0xff ;db 0x9c,0x9c
	  ds 12,0x0ff
	  db 0x0c,0x0c	  



pal_rgb   ds 32,0xff


DDp_pal:
;blackpal:
	  ds 16,0xff
	  db 0x8c,0xff ;db 0x9c,0x9c
	  ds 12,0x0ff
	  db 0x0c,0x0c	
;nblackpal:
	  db 0xff,0xff
          db 0xce,0x8c	;  db 0x8c,0xff	
	  ds 12,0xff
	  db 0x8c,0xff ;db 0x9c,0x9c
	  ds 12,0x0ff
	  db 0x0c,0x0c	  
ATM_pal:
;blackpal:
	  ds 16,0xff
	  db 0x8c,0x8c ;db 0x9c,0x9c
	  ds 12,0x0ff
	  db 0x0c,0x0c	
;nblackpal:
	  db 0xff,0xff
          db 0x8c,0x8c	;  db 0x8c,0xff	
	  ds 12,0xff
	  db 0x1f,0x1f ;db 0x9c,0x9c
	  ds 12,0x0ff
	  db 0x0c,0x0c	  

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

g_curpos dw 0 ;
g_atpos  dw 0 ;
;------------------------------
DELAY db 0
;------------------------------
mus_path1:
        db "mus/",0
mus_path2:        
        db  "/mt_00.",0

gfx_path1:        
		db "gfx/",0
gfx_ext db ".16c",0		

ovl_path1:
		db "ovl/",0	

censor_path: db "censored/",0

;------------------------------
namebuf ds 14,0
namebuf1: ds 128,0
namebuf2: ds 128,0
ovlnamebuf ds 128,0


MENUCURHELPER:
;MENUCURHELPER_MAINMNU
	dw 0x9902+80
	dw 0x9902+320+80
	dw 0x9902+320+320+80
	dw 0x9902+320+320+320+80

	dw 0x9912+80
	dw 0x9912+320+80
	dw 0x9912+320+320+80
	dw 0x9912+320+320+320+80


MENUCURHELPER_MAINMNU:
	dw  0x96df;+40 ; 0x9902+80-320-320
	dw 0x981f;+40 ;0x9902+80-320
	dw 0x995f;+40   ;0x9902+80
	dw 0x9a4f;+40  ;0x9902+320

;	dw 0xD692-2+80
;	dw 0xD692+320-2+80
;	dw 0xD692+320+320-2+80
;	dw 0xD692+320+320+320-2+80