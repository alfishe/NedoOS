        DEVICE ZXSPECTRUM48
        include "../../_sdk/sys_h.asm"
        org PROGSTART

;====================================================
        macro NEXTCOLUMN
        bit 6,h
        set 6,h
        jr z,1f;shapes_linehorR_incxok
        ld a,h
        xor 0x60
        ld h,a
        and 0x20
        jr nz,1f;shapes_linehorR_incxok
        inc hl
1 ;shapes_linehorR_incxok
        endm
;====================================================
        macro BRIGHTBYTE x
_=x
        if _>15
_=15
        endif
_g0=~_&1
_g1=(~_>>1)&1
_g2=(~_>>2)&1
_g3=(~_>>3)&1
;0g20G3G3
        ;db _
        db (_g0<<6)+(_g2<<5)+(_g1<<3)+(_g3<<2)+(_g1<<1)+(_g3<<0)
        endm
;====================================================


module 		= 0xc000
player_load = 0x4000

ovl_start = 0x4000

PLR_INIT  = 0x4000
PLR_PLAY  = 0x4005
PLR_MUTE  = 0x4008

GLOBVARS = 0x3800
LOCVARS  = GLOBVARS + 256  ;0x3900
ACTMENU  = LOCVARS  + 256  ;0x3a00
ILINK    = ACTMENU  + 256  ;0x3b00
STK_MENU = ILINK    + 256  ;0x3c00
STK_SUB  = STK_MENU + 100  ;0x3d64

FONT     = 0x8000
FONT2    = 0x9000
ANIM_BFF  = 0xA000

sp_main = 0x4000
sp_alt  = 0x3f70


print_v_limit:   equ 0x18
;----
;intro
game_p_len			equ 49
print_p_len:     	equ 51


credits_coor_intro:        equ 0x1400
txt_coor_intro:        equ 0x1500

txt_coor_questions = 0x0310
questions_p_len = 46
;----

txt_coor_8_4=0x1300
txt_coor2:        equ 0x1420

;=========================================================
cmd_begin:
    OS_HIDEFROMPARENT

    ld sp,sp_main
    call pre_init  
	
	ld hl,GLOBVARS
	ld de,GLOBVARS+1
	ld bc,STK_SUB-GLOBVARS+154
	ld (hl),l
	ldir
	
begin:
    call disable_anim
	
	call setcorepage
	call pre_intro
begin1:	
	call mainMenu
	call unsetcorepage
	
	ld a,(start_mode)
	cp 0xff
	jp z,_gamestart
	
	
	add a,"0"
	ld (SAVETEMPL_N),a
	ld de,SAVETEMPL
	call openstream_file	
_load_common:
	ld hl,538 ;len
	ld de,buf
	call readstream_file
	or a
	jp nz,filereaderror

	call closestream_file
	call save_to_globals
	jr _gamestart1
	
_gamestart:
        ld hl,FSTOVL
_gamestart1:        
        ld de,OVL
        call copystr_hlde
        xor a
        ld (de),a        

		call setcorepage
		call clear_whole_screen
		call unsetcorepage


		ld a,game_p_len
		ld (_print_b.set_pLen),a
		ld bc ,txt_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p
		
		call _set_clear_box_game
		call _set_box_anim_game

        ld hl,TABLE_W
        ld (CODEPAGE),HL
		
;---------------------------------------------
;-draw pretty border
       ld hl,ingame_border
        call load_gfx_to_load_buf

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir

        ld hl,blackpal
        ld de,pal
        ld bc,32 
        ldir

        call _immed_big

        ld hl,temppal
        ld de,pal
        ld bc,32
        ldir        

        ld a,1
        ld (setpalflag),a
        halt
;-------------------------------------------------
BEG
        ld a,0xaf ;xor a
        ld (SUBLOCK),a  ; ???? hz chto eto. ne pomnu
		call disable_anim
;>>> clear LOCVARS and ACTMENU
        xor a
        ld hl,LOCVARS
        ld bc,2
        ld (hl),a
        inc hl
        djnz $-2
        dec c
        jr nz,$-5
		
       ld h,a
       ld l,h
       ld (g_curpos),hl 


        ld hl,OVL
        call load_ovl_to_script_buf

        ;store loaded ovl name
        ld hl,OVL
        ld de,LOADED
        ld bc,13
        ldir
		
		
		
		
        call _ftp ;search first text 
        push hl
        call _precache
        
        xor a
        call _get_show_scr
        pop hl 
		
		
TXTOUT:
		xor a
		ld (first_word),a
        call WINCLR2
        CALL _print_ovl
TXTOUT1:
        call WINCLR3
        call _menu
        call WINCLR2

SEARCH:
        LD DE,ILINK
        EX DE,HL
SEARCH0:
        LD A,(HL)
        INC HL
        CP E
        JR NZ,SEARCH1
        LD A,(HL)
        INC HL
        CP D
        JR NZ,SEARCH1+1
        LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        LD A,HIGH ovl_start; #40
        ADD A,H
        LD H,A
        LD BC,4
        ADD HL,BC
        LD A,(HL)
        INC HL,HL
        LD D,HIGH LOCVARS
        LD E,A
        LD A,(DE)
        ADD A,A
        LD E,A
        LD D,0
        ADD HL,DE
        LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        LD A,HIGH ovl_start  ;#40
        ADD A,H
        LD H,A
        JP TXTOUT
SEARCH1:
        INC HL,HL,HL
        JR SEARCH0
		
		

		

	
_gamequit
		pop hl
        call no_mus
        jp cmd_quit	
	
	
	
	
;____________________	
_print_ovl:	
		
        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)
        SETPG8000 	
		
	
_print_b:
        push hl
        call clear_txt_buff
        pop hl

        ld de,txt_buff
        ld c,0   ;//symbol counter
.p0:
        LD A,(HL)
        CP 32+1
        JR C,.p1 ;is control code
		cp '-'
		JR z,.p1
		cp '.'
		JR z,.p1
		cp '%'
		jr z,._print_hero_name
        ;copy string yo buffer
        ld (de),a
.p_endl_point:	
		ld a,1
		ld (first_word),a
        inc hl
        inc de
        inc c
        jr .p0		

._print_hero_name:
		inc hl
		ld a,(hl)
		cp "0"
		jp nz,.not_hero_name1
		inc hl
		ld a,(hl)
		cp "0"
		jp nz,.not_hero_name2
		inc hl
		ld a,(hl)
		cp "1"
		jp nz,.not_hero_name3
;>>>%001 detected. replace with name'
		push hl
        ld a,(language)
        ld hl,loc_hero_name
        call sel_word    ;hl - point to localized name
.phn_copy
		ld a,(hl)
		and a
		jp z,.phn_copy_exit
		ld (de),a
		inc hl
		inc de
		jr .phn_copy
.phn_copy_exit:
		pop hl
		dec de
		jp .p_endl_point

.not_hero_name3:
		dec hl
.not_hero_name2:
		dec hl
.not_hero_name1:
		dec hl
		ld a,(hl)
		ld (de),a
		jp .p_endl_point



.p1:
	    push af
        ld a,c
        and a
        jr nz,.p1_1     ;buffer not empty. print string
        pop af
		
        cp 32
		jp z,.p_a
		cp '-'
		jp z,.p_a
		cp '.'
        jp nz,._print_token
.p_a:	
		ld (first_word),a
		ld (.p_chr),a
        ld a,(just_cr)
        and a
        jr nz,.p1_0 ;if just go to new line - do not print space
.p_chr = $+1		
        ld a,32
        ld (de),a ;print space
        inc hl
        inc c
.p1_0:
        push af
.p1_1:
        ld a,c
        ld bc,(CORDS_P)           ;B-y C-X
        add a,c
.set_pLen = $+1		
        cp print_p_len
        jr c,.p1_no_overflow
        call _linefeed
       jr .npo
.p1_no_overflow:
        xor a
        ld (just_cr),a
.npo:
        call _print_txt_buf_p
        pop af
        jp _print_b

._print_token:
        push hl
        ld hl,_tokenTable
        ld c,a
		
.p2:
        ld a,(hl)
        inc hl
        cp 0xff
        jr z,.p4  ;table end
        cp c
        jr z,.p3  ;code found
        inc hl
        inc hl
        jr .p2
.p3:
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ex (sp),hl
        ret
.p4:
		pop hl ;<< unknown token
		ret
;====================================
_print_sub_token:
		ld c,a
.p2:
        ld a,(hl)
        inc hl
        cp 0xff
        jr z,.p4  ;table end
        cp c
        jr z,.p3  ;code found
        inc hl
        inc hl
        jr .p2
.p3:
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ex (sp),hl
        ret
.p4:
		pop hl ;<< unknown token
		ret
		
	
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<	
_print_txt_buf_p:
            push bc,hl,af
                    ld hl,txt_buff
                    call _type_txt_buf_p
                    call clear_txt_buff
            pop af,hl,bc
            ret	
;;;;;;;;;;;;;;;;;;;;;
_type_txt_buf_p:
            ld c,1
.l1
            ld a,(hl)
            and a
            ret z
			push hl
			cp '['
			jr z,.set_color
			cp ']'
			jr z,.unset_color
            call _type_p


.debb:
            ld hl,COORDS_P
            ld a,(COORDS_P_L)
            cp (hl)
            jr z,.debb2
            jr c,.debb2
            jr .debb0
.debb2:
            call _linefeed
.debb0:
            pop hl
            inc hl
            jr .l1
.set_color	
	        ld hl,0x45a8 ;0x46B0					;>>>0100010110101000     ;>>>>> 0x0108 ; index 1  0000 0001 0000 1000
			ld (_type_color),hl
			jr .debb0

.unset_color	
	        ld hl,0x47b8 		;0100011110111000
			ld (_type_color),hl
			jr .debb0	
			
;------------
_linefeed:
        ld a,1
       ld (just_cr),a

        ld bc,(CORDS_P)
        inc b
x_txt_coor = $+1
        ld c,0
        call _pradd_p

        ld bc,(CORDS_P)
        LD A,B
        CP print_v_limit
        CALL NC, WINCLR1
        ret			
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<	
_tokenTable:
        DB 00
        DW ENDTEXT                              ;++++
		
        DB 01
        DW WINCLR  ;IF PRESSED KEY              ;++++
		
        DB 02
        DW LOADSCRIPT  ;                         ;++++

        DB 06
        DW SHOWSCR
		
        DB 07
        DW SELMUSIC ;07XX                       ;++++
		
        DB 08
        DW LOADSFX                        	  ;----
		
        DB 09
        DW LOADSCRIPT2BYTE                          ;++++
		
        DB #0A
        DW LINEFEED                             ;++++
		
        DB #0F
        DW ENDING		;EXITLIGHT                            ;---
        DB #10
        DW GAMEOVER 	;EXITDARK              ;---


        DB #13
        DW FLASH ;#16XX XX-BLINKS               ;++++
        DB #14
        DW PAUSE                                ;++++
		
        DB #0B
        DW GROUP0B
		
        DB #0C
        DW GROUP0C
		
        DB #0E
        DW SCROLLCG								;-------
		
        DB #12
        DW GROUP12
        DB #1F
        DW GROUP1F
        DB #FF
_tokenTable_0C
             DB 01
             DW G_COPYF		;GLOBTOLOC                       ;++++
             DB 02
             DW G_COPYG		;LOCTOGLOB                       ;++++
             DB 03
             DW G_COPYI		;GLOBLET                         ;++++
             DB 255

_tokenTable_0B:
        DB 01
        DW F_CALI 		;ADDNUM                               ;++++
        DB 2
        DW F_PLUS		;ADDVAR                               ;++++
        DB 3
        DW F_MINUS		;SUBVAR                               ;++++
        DB 5
        DW F_COPYI		;LOCLET                               ;++++
        DB 6
        DW SUBSTRACT                         				  ;++++
        DB 7
        DW F_COMPI		;SUBNUM                               ;++++
        DB 8
        DW F_AND		;COMPAND                              ;++++
        DB 9
        DW F_OR			;COMPOR                               ;++++
        DB #0A
        DW F_EXIT		;TRUECONT                             ;++++
        DB #14
        DW F_RAND		;RANDOMIZE                            ;++++
        DB #32
        DW F_JGR		;ISPOSITIVEGOTO                       ;++++
        DB #33
        DW F_JEQ		;ISZEROGOTO                           ;++++
        DB #34
        DW F_JLW		;ISNEGATIVEGOTO                       ;++++
        DB #35
        DW F_JNEQ		;ISNOTZEROGOTO                         ;++++
        DB #36
        DW F_JR			;GOTO                                 ;++++

        DB 255

_tokenTable_12:
        DB 01
        DW C_V_ON		;MENUOFF                              ;????
        DB 02
        DW C_V_OFF		;MENUON                               ;????
        DB 04
        DW C_N_ON		;SUBMENUOFF                           ;????
        DB 05
        DW C_N_OFF		;SUBMENUON                            ;????
        DB 255

_tokenTable_1F:
		db 0
		dw PARSER_EXIT
		db 1
		dw clear_big_screen
		db 2
		dw show_opening_screen
		db 3
		dw WINCLRB
		db 4
		dw LINEFEEDB

GROUP0C LD DE,_tokenTable_0C
        JR GROUPS
GROUP0B LD DE,_tokenTable_0B
        JR GROUPS
GROUP12 LD DE,_tokenTable_12
        JR GROUPS
GROUP1F LD DE,_tokenTable_1F
        JR GROUPS
GROUPS  
		inc hl
		LD A,(HL)
        INC HL
        PUSH HL
        EX DE,HL
        JP _print_sub_token




end:
        include "../../_sdk/file.asm"
		include "sub_func.asm"
		include "sub_dsk.asm"
		include "gfx_func.asm"
		include "sub_vars.asm"
        include "variables.asm"
		include "sub_eyes.asm"
dzx0_:
        include "dzx0b.asm"		
	  ;  include "dzx0b_mega.asm"		



load_anim_slot_addr			dw 0
anim_stack_slot_pointer		dw 0
anim_is_found				db 0
anim_spr_cnt 				dw 0          ;location of last char of name to check for animations
temp_addr_storage			dw 0


;eye twinkle
anim1_seq: 					db 0,1,1,1,0xfe,0  ;fase,time between fases

;eye blinks one time
anim3_seq: 					db 0,35, 1,1, 2,1, 1,10 ,0,1,0,55,0xfe,0  ;


blinks2_seq: db 1,2,0,2,1,4,0,2,0xff,0
blinks3_seq: db 1,2,2,2,1,2,0,2,1,4,2,2,1,2,0,2,0xff,0
blinks4_seq: db 1,2,2,2,3,2,2,2,1,2,0,2,1,4,2,2,3,2,2,2,1,2,0,2,0xff,0

sparklings2_seq: db 1,0,0,0,0xfe,0   ;fase,time between fases
sparklings3_seq: db 1,0,2,0,0,0,0xfe,0
sparklings4_seq: db 1,0,2,0,3,0,0,0,0xfe,0
sparklings5_seq: db 1,0,2,0,3,0,4,0,0,0,0xfe,0




ani_mode_tbl:
        dw blinks_tbl
        dw sparklings_tbl
        dw single_blink_tbl


blinks_tbl:
        dw 0
        dw 0
        dw blinks2_seq
        dw blinks3_seq
        dw blinks4_seq

sparklings_tbl:
        dw 0
        dw 0
        dw sparklings2_seq
        dw sparklings3_seq
        dw sparklings4_seq
        dw sparklings5_seq
		
single_blink_tbl:
		dw 0			;animation has zero fases
		dw 0			;animation has one fase
		dw 0			;animation has two fases
		dw anim3_seq	;animation has three fases


		
		


font_buf 					ds 16,0
							align 256
PUSH_DATA:  				ds 256,0  ;//wait animation
anim_stack: 				ds 256,0
txt_buff: 					ds 256,0
;struct
;+0+1dw sprite addr in slot page
;+2+3dw screen addr
;+4 db len
;+5 db hgt
;+6 db num of fases
;+7 db anim type ;BLINKS = 0   ;;HALFBLINKS = 1;SPARKLING = 2
;+8 db counter1 fase counter
;+9 db counter2 time between fase in animation
;+10 db counter3 time between animations
;+11 db use_mask?  0 - don't use transparency 1 - use

;+12+13dw fase 0 offset
;+14+15dw fase 1 offset
;+16+17dw fase 2 offset
;+18+19dw fase 3 offset
;+20+21dw fase 4 offset
;+22+23dw fase 5 offset
;+24+25dw fase 6 offset
;+26+27dw fase 7 offset
t_s98_file00_pages_list:	ds 256,0

buf:            
         include "buf.asm"
cmd_end:    
         include "page4000.asm"


	display "Buff loc ",/d,buf," bytes"
	display "cmd_end ",/d,cmd_end," bytes"
	display "GLOBVARS ",/d,GLOBVARS	," bytes"

        savebin "t_no_gogo/page4000.bin",page4000begin,page4000end-page4000begin
        savebin "t_no_gogo.com",cmd_begin,cmd_end-cmd_begin
		LABELSLIST "..\..\..\us\user.l",1