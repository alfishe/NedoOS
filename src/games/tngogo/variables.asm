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
load_buf1       db 0
load_buf2       db 0
mem_buf1        db 0
mem_buf2        db 0
mem_buf3        db 0
mem_buf4        db 0
scr_buf1        db 0
scr_buf2        db 0
font_page       db 0
plr_page        db 0
plr_page2       db 0
plr_page3       db 0
core_page		db 0
zx0_page        db 0
pagestbllen=$-pagestbl


src_buf1:     	db 0 ;datasource for screen output 
src_buf2:     	db 0

tempimagename	ds 32,0
;----setup---
res_path:    	db "t_no_gogo",0

language:    	db 0  ;0 eng | 1 rus
gfx_mode:    	db 0  ;0 DDp | 1 16c | 2 ATM
mus_mode:    	db 0  ;0 AY  | 1 s98
censor_mode     db 0  ;0-normal 1-censorship
tsfm_detected   db 0 ;0- no ;1-yes
;------intro-----
opening_pic1    db "OP_1",0
opening_pic2    db "OP_2",0
opening_mus:    DB 20  

menu_pic_btm: 	db "0001_B",0
menu_pic_top: 	db "0001_A",0
menu_mus:   	db 35



ingame_border   db "TENK11",0
anim_w          db "push5",0

core_file       db "page4000.bin",0
font_file       db "font_rus.bin",0
font_file2      db "propfont.bin",0
FSTOVL			db "TEN_S003.OVL",0

ovldigitpntr	= $+5
OVLLOAD			db "TEN_S000.OVL",0

ROGOL			db "ROGOL2",0

SAVETEMPL		db "TENDATA0.000",0
SAVETEMPL_N		equ SAVETEMPL+7

;tb008:           db "tb_008",0
;-----------------------------------------------



OVL				ds 13,0
LOADED			ds 13,0	
;---palette----
setpalflag:  	db 0

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
CORDS_P dw 0

g_curpos dw 0 ;
g_atpos  dw 0 ;

SELSo4	dw 0

start_mode 	db 0


outtype2 db 0
draw_effect   db 0

active_scr:   db 0 
s_move_base_src: dw 0
s_move_adr1:  dw 0

s_move_lines1: db 0
s_move_lines2: db 0
;------------------------------
DELAY db 0


first_word	db 0 ; is first word in line flag
first_letter    db 0
just_cr		db 0 ;
;------------------------------
mus_path1:
        db "mus/",0
mus_path2:        
        db  "/TEN000.",0

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
	
	
	
	
SINGLE_BLINK = 2
SPARKLING    = 1
BLINKS		 = 0

eyes_table:
eyerec_s:
	db "0001_AA0",0
eyerec_d:
	dw 56,82		;x-y					;ix+0
	dw 24,20        ;len-hgt				;+4
	db 3            ;num phases				;+8
	db 0				;x-screen offset	;+9
	db 0				;y-screen offset	;+10
	db SINGLE_BLINK			;pattern		;+11
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13
eyerec_e	
	
	
	db "0001_AA1",0
	dw 134,90
	dw 20,20
	db 3
	db 0				;x-screen offset	;+9
	db 0				;y-screen offset	;+10
	db SINGLE_BLINK			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13
	
	db "0001_BA0",0
	dw 224,68
	dw 24,22
	db 3
	db 0				;x-screen offset	;+9
	db 0				;y-screen offset	;+10
	db SINGLE_BLINK			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13



	db "TT_01A0",0,0
	dw 62,32
	dw 28,16
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13

	db "TT_02A0",0,0
	dw 148,28
	dw 30,14
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13

	db "TT_03A0",0,0
	dw 144,23
	dw 26,12
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13

	db "TT_04A0",0,0
	dw 132,21
	dw 22,16
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13

	db "TT_05A0",0,0
	dw 72,24
	dw 30,18
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13

	db "TT_07A0",0,0
	dw 164,27
	dw 28,14
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13


	db "TT_08A0",0,0
	dw 50,27
	dw 24,12
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13

	db "TT_09A0",0,0
	dw 44,24
	dw 26,18
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13

	db "TT_10A0",0,0
	dw 160,30
	dw 30,22
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13
	
	
	db "TT_11A0",0,0
	dw 146,28
	dw 28,16
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13

	db "TT_12A0",0,0
	dw 110,28
	dw 30,8
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13	

	db "TT_13A0",0,0
	dw 34,34
	dw 36,16
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13	

	db "TT_14A0",0,0
	dw 108,30
	dw 30,12
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13	

	db "TT_15A0",0,0
	dw 76,22
	dw 30,20
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13	
	
	db "TT_17A0",0,0
	dw 104,32
	dw 30,12
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13		
	
	db "TT_18A0",0,0
	dw 100,27
	dw 36,16
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13		

	db "TT_19A0",0,0
	dw 88,22
	dw 28,10
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13		

	db "TT_20A0",0,0
	dw 106,20
	dw 20,22
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13	

	db "TT_21A0",0,0
	dw 160,31
	dw 32,20
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13	

	db "TT_22A0",0,0
	dw 42,32
	dw 32,12
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 1				;use mask 			;+13	


	db "TH_013A0",0
	dw 90,54
	dw 54,40
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	


	db "TH_014A0",0
	dw 48,30
	dw 24,34
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	

	db "TH_017A0",0
	dw 136,25
	dw 52,28
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13	

	db "TH_018A0",0
	dw 18,95
	dw 14,32
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	


	db "TH_022A0",0
	dw 30,58
	dw 28,34
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	

	db "TH_032A0",0
	dw 124,30
	dw 30,11
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13	

	db "TH_033A0",0
	dw 170,45
	dw 14,11
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	

;!!! TODO check for animation
	db "TH_034A0",0
	dw 140,74
	dw 10,10
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	

	db "TH_038A0",0
	dw 177,92
	dw 20,34
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	


;!!! TODO check for animation
	db "TH_039A0",0
	dw 122,58
	dw 22,16
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	

;!!! TODO check for animation
	db "TH_039A0",0
	dw 92,94
	dw 10,8
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13		
	
;!!! TODO check for animation	
	db "TH_044A0",0
	dw 76,59
	dw 10,8
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13	
	
	db "TH_045A0",0
	dw 178,30
	dw 28,33
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13		
	
	
	db "TH_046A0",0
	dw 50,43
	dw 12,24
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13		
	
	db "TH_052A0",0
	dw 174,20
	dw 30,16
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13		

	db "TH_053A0",0
	dw 68,52
	dw 6,6
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13		

	db "TH_054A0",0
	dw 116,72
	dw 30,10
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	

;!!! TODO check for animation	
	db "TH_060A0",0
	dw 176,90
	dw 10,10
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13		

	db "TH_061A0",0
	dw 66,45
	dw 18,16
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13	

;!!! TODO check for animation	
	db "TH_062A0",0
	dw 178,31
	dw 8,15
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13		

	db "TH_066A0",0
	dw 58,53
	dw 34,30
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13		


	db "TH_067A0",0
	dw 82,30
	dw 32,33
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13	
	
	db "TH_067A1",0
	dw 112,78
	dw 10,8
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13	

;!!! TODO check for animation	
	db "TH_068A0",0
	dw 160,10
	dw 24,20
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_073A0",0
	dw 36,38
	dw 36,20
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_074A0",0
	dw 156,28
	dw 24,28
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_080A0",0
	dw 80,34
	dw 46,20
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_081A0",0
	dw 156,34
	dw 22,37
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_083A0",0
	dw 164,32
	dw 14,10
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_088A0",0
	dw 64,40
	dw 34,40
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13
	
;!!! TODO check for animation
	db "TH_089A0",0
	dw 172,80
	dw 8,8
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13

;!!! TODO check for animation
	db "TH_090A0",0
	dw 46,101
	dw 22,20
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13


;!!! TODO check for animation
	db "TH_095A0",0
	dw 82,18
	dw 26,30
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13

;!!! TODO check for animation
	db "TH_096A0",0
	dw 154,82
	dw 12,12
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_097A0",0
	dw 42,23
	dw 18,36
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13


	db "TH_100A0",0
	dw 52,35
	dw 42,14
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_101A0",0
	dw 64,19
	dw 22,17
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_124A0",0
	dw 102,28
	dw 28,20
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_125A0",0
	dw 186,38
	dw 12,28
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13


;!!! TODO check for animation
	db "TH_126A0",0
	dw 84,98
	dw 10,8
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_130A0",0
	dw 94,34
	dw 54,34
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0			;randomize start time	;+12
	db 0				;use mask 			;+13

;!!! TODO check for animation
	db "TH_131A0",0
	dw 8,44
	dw 22,12
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13

	db "TH_132A0",0
	dw 32,19
	dw 36,21
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1			;randomize start time	;+12
	db 0				;use mask 			;+13



	db "TI_006A0",0
	dw 108,34
	dw 36,30
	db 2
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db SPARKLING			;pattern
	db 0				;randomize start time	;+12
	db 0				;use mask 			;+13			
	
	db "TI_029A0",0
	dw 58,54
	dw 8,10
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13		

	db "TI_029A1",0
	dw 112,24
	dw 30,22
	db 3
	db 5			;x-screen offset	;+9
	db 8				;y-screen offset	;+10
	db BLINKS			;pattern
	db 1				;randomize start time	;+12
	db 0				;use mask 			;+13		

	db 0xff