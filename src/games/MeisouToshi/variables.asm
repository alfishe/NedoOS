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
man_buf1:    db 0 ;buffer for in_menu animation
man_buf2:    db 0
plr_page:    db 0
plr_page2:   db 0
plr_page3:   db 0
font_page:   db 0;here goes font_rus
zx0_page:    db 0
pagestbllen=$-pagestbl


src_buf1:    db 0 ;datasource for screen output 
src_buf2:    db 0

;----setup---
res_path:    db "Mei",0

language:    db 0  ;0 eng | 1 rus
gfx_mode:    db 0  ;0 DDp | 1 16c | 2 ATM
mus_mode:    db 0  ;0 AY  | 1 s98

censor_mode db 0  ;0-normal 1-censorship
;------intro-----
intro_sequence:
        dw intro_pic1
        dw intro_pic2
        dw intro_pic3
        dw intro_pic4
        dw intro_pic5
        dw intro_pic6
        dw intro_pic7
        dw intro_pic8
        dw intro_pic9
        dw intro_pic10
        dw intro_pic11
        dw intro_pic12


intro_pic1:   db "op_001",0
intro_pic2:   db "op_002",0
intro_pic3:   db "op_003",0
intro_pic4:   db "op_004",0
intro_pic5:   db "op_005",0
intro_pic6:   db "op_006",0
intro_pic7:   db "op_007",0
intro_pic8:   db "op_008",0
intro_pic9:   db "op_009",0
intro_pic10:   db "op_010",0
intro_pic11:   db "op_011",0
intro_pic12:   db "op_012",0

intro_txt0      DB	"Transman/U_Corp and NCy",0
intro_txt1       DB	"   Proudly Presents:   ",0
intro_txt2       DB	"       (c)JAST         ",0

intro_mus:      DB 34  

menu_pic 	 db "op_013",0

menu_anim_cnt       db 4 ;5-1
menu_anim_order:
                 dw menu_f1_name
                 dw menu_f2_name
                 dw menu_f3_name
                 dw menu_f4_name
                 dw menu_f5_name

menu_f1_name: db "op_013a0",0
menu_f2_name: db "op_013a1",0
menu_f3_name: db "op_013a2",0
menu_f4_name: db "op_013a3",0
menu_f5_name: db "op_013a4",0

tiare   db "tiare_s",0

menu_mus 	 db 35


ingame_border   db "meif",0
anim_w          db "push",0

font_file       db "font_rus.bin",0
SAVETEMPL	db "RUNDATA0.000",0
SAVETEMPL_N	equ SAVETEMPL+7

endingovl	db "GAMEEND.OVL",0
FSTOVL		db "MT_0101.OVL",0

tb008:           db "tb_008",0
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
;------------------------------
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
	db "M8_001a0",0
	dw 44,32
	dw 40,16
	db 3
	db "M8_002a0",0
	dw 40,36
	dw 36,16
	db 3
	db "M8_003a0",0
	dw 40,24
	dw 40,20
	db 3
	db "M8_004a0",0
	dw 44,28
	dw 32,16
	db 3
	db "M8_005a0",0
	dw 152,40
	dw 16,4
	db 2
	db "M8_006a0",0
	dw 36,32
	dw 36,20
	db 3
	db "M8_007a0",0
	dw 44,32
	dw 36,16
	db 3
	db "M8_008a0",0
	dw 68,32
	dw 40,16
	db 3
	db "M8_009a0",0
	dw 160,28
	dw 40,16
	db 3
	db "M8_010a0",0
	dw 40,28
	dw 40,20
	db 3
	db "M8_011a0",0
	dw 164,32
	dw 36,20
	db 3
	db "M8_012a0",0
	dw 76,24
	dw 40,12
	db 3
	db "M8_013a0",0
	dw 160,20
	dw 36,12
	db 3
	db "M8_014a0",0
	dw 28,32
	dw 36,24
	db 3
	db "M8_015a0",0
	dw 136,16
	dw 32,20
	db 3
	db "M8_016a0",0
	dw 24,24
	dw 40,16
	db 5
	db "M8_017a0",0
	dw 44,24
	dw 36,16
	db 3
	db "M8_018a0",0
	dw 68,20
	dw 28,12
	db 3
	db "M8_019a0",0
	dw 44,32
	dw 40,16
	db 3
	db "M8_020a0",0
	dw 44,32
	dw 40,16
	db 3
	db "M8_021a0",0
	dw 164,32
	dw 36,20
	db 3
	db "M8_022a0",0
	dw 28,32
	dw 36,24
	db 3
	db 0xff