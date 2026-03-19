txt_memoryerror:    db 0x0A,"Memory allocation error!",0x0D,0x0A,0
txt_fopenerror:     db 0x0A,"Cannot open file: ",0
txt_fcreateerror:    db 0x0A,"Cannot create file: ",0
txt_freaderror:     db 0x0A,"Cannot read file: ",0
txt_fwriteerror:     db 0x0A,"Cannot write file: ",0	
txt_dircherror:     db 0x0A,"Cannot change directory: ",0
txt_unkcode:        db 0x0A,"unknown code: ",0
txt_nl:             db 0x0D,0x0A,0
txt_unkflag:     db 0x0A,"Unknown flg_if: ",0



;-----memory------
winpage0:    db 0 ;0x0000-0x3fff
script_buf1:
winpage1:    db 0 ;0x4000-0x7fff
script_buf2:
winpage2:    db 0 ;0x8000-0xbfff
winpage3:    db 0 ;0xc000-0xffff

;reserved pages in memory


load_buf1:   db 0  ;13
load_buf2:   db 0  ;24

mem_buf1:    db 0 ;13
mem_buf2:    db 0 ;24

mem_buf3:    db 0 ;13
mem_buf4:    db 0 ;24

scr_buf1:    db 0 ;13 ;additional buffers. (reserved) !!! load sprites here !!!
scr_buf2:    db 0 ;24 ;additional buffers. (reserved)


src_buf1:     db 0 ;datasource for screen output 
src_buf2:     db 0

anim_slot03   db 0
anim_slot47   db 0
anim_slot811   db 0

zx0_page        db 0
;------------
font_page      db 0;here goes font_rus

core_page      db 0;additional page for executable. at $4000

;----setup---
res_path:    db "Saku_R",0

language:    db 0  ;0 eng | 1 rus
gfx_mode:    db 0  ;0 DDp | 1 16c | 2 ATM

mus_mode:    db 0  ;0 AY  | 1 s98 | 2 moonsound
censor_mode db 0  ;0-normal 1-censorship
;------intro-----
intro_pic:   db "sp_001",0
intro_mus:   db 10  
into_text:   db "OP_01.OVL",0


menu_mus:   db 10  
menu_pic 	 db "saku_p",0
menu_pic2 	 db "saku_t",0


gallery_file    db "CDATA.000",0 	
badge_pic	db "hanko",0

anim_w          db "push",0

font_file       db "font_rus.bin",0
core_file       db "page4000.bin",0

ingame_border   db "frefre",0

tiare           db "tiare_s",0
tiare_p1        db "tiare_p1",0
tiare_p2        db "tiare_p2",0

saku_leaf:      db "sakura",0
;=======================
SAVETEMPL	db "SAKDATA0.000",0
SAVETEMPL_N	equ SAVETEMPL+7

endingovl	db "ENDING0.OVL",0
FSTOVL		db "CS101.OVL",0
OVL		ds 13,0
LOADED		ds 13,0	


;---palette----
setpalflag:  db 0


pal_rgb   ds 32,0xff

stdpal:  STANDARDPAL
pal:     ds 32,0xff 
mempal:  ds 32,0xff
temppal  ds 32,0
whitepal  ds 32,0
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
        db  "/mt_00.",0

gfx_path1:        
		db "gfx/",0
gfx_ext db ".16z",0		

ovl_path1:
		db "ovl/",0	
op_path2:
	db  "op..",0

anim_ext: db ".gfx",0	

censor_path: db "censored/",0
;------------------------------
active_scr:   db 0     ;뱠롪ﳮ񼧠ﳮⱠ硥󲽠(衯鲼 餸𡮠 㳮񯧠뱠맍
;------------------------------
characters_current db 0 ;current page 
_current_op db 0	; selected girl
_op_rslt db 0
_op_slct db 0x33,0x34,0x35,0x36,0x38,0x39,0x3a,0x37	
_op_endings:
	dw _op01_ending ;reiko
	dw _op02_ending ;kiyomi
	dw _op03_ending ;mio
	dw _op04_ending ;shoko
	dw _op05_ending ;aki
	dw _op06_ending ;seija
	dw _op07_ending ;meimi
	dw _op08_ending ;ruri

_op01_ending  db "CSC03_A.OVL",0  ;reiko
_op02_ending  db "CSC03_B.OVL",0;kiyomi
_op03_ending  db "CSC03_C.OVL",0;mio
_op04_ending  db "CSE_D_1.OVL",0;shoko
_op05_ending  db "CSE_F_1.OVL",0;aki
_op06_ending  db "CSE_G_1.OVL",0;seija
_op07_ending  db "CSE_H_1.OVL",0;meimi
_op08_ending  db "CSE_E_1.OVL",0;ruri
;---------
;0x33 = 33 reiko;
;0x34 = 33 kiyomi
;0x35 = 33 mio
;0x36 = 33 shoko
;0x37 = 33 ruri       
;0x38 = 33 aki
;0x39 = 33 seia
;0x3a = 33 meimi
_op_end_slct:
	db 0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a;
_op_gfx_ending:
	dw _reiko_ending_gfx
	dw _kiyomi_ending_gfx
	dw _mio_ending_gfx
	dw _shoko_ending_gfx
	dw _ruri_ending_gfx
	dw _aki_ending_gfx
	dw _seija_ending_gfx
	dw _meimi_ending_gfx

_reiko_ending_gfx        db "ae_193",0
_kiyomi_ending_gfx	 db "ae_194",0
_mio_ending_gfx		 db "ae_195",0
_shoko_ending_gfx 	 db "ae_197",0
_ruri_ending_gfx 	 db "ae_191",0
_aki_ending_gfx		 db "ae_192",0
_seija_ending_gfx	 db "ae_196",0
_meimi_ending_gfx	 db "ae_198",0
;'''''''''''''''''''''''''''''''''''''''
;ZONEADR DB 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6, 6
;	DB 6, 7, 7, 8, 8, 9, 9, 9, 10,10,11,11,12,12,12,13
;	DB 13,14,14,15,15,15,16,16,17,17,18,18,18,19,19,20
;	DB 20,21,21,21,22,22,23,23,24,24,24,25

;------------
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


namesslot_temp: ds 5,0
nameslots_tbl:
                DB "CT01",255
                DB "CT02",255
                DB "CT03",255
                DB "CT04",255
                DB "CT05",255
                DB "CT06",255
                DB "CT07",255
                DB "CT08",255
                DB "CT09",255
                DB "CT10",255
                DB "CT11",255
                DB "CT12",255
                DB "CT13",255
                DB "CT14",255
                db 0xff

nameslots_tbl_bk
                DB "CT01",255
                DB "CT02",255
                DB "CT03",255
                DB "CT04",255
                DB "CT05",255
                DB "CT06",255
                DB "CT07",255
                DB "CT08",255
                DB "CT09",255
                DB "CT10",255
                DB "CT11",255
                DB "CT12",255
                DB "CT13",255
                DB "CT14",255
                db 0xff
nameslots_tbl_bke