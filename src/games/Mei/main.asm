        DEVICE ZXSPECTRUM48
        include "../../_sdk/sys_h.asm"
        org PROGSTART

module equ 0x5000
player_load = 0x4000

ovl_start = 0x4000

PLR_INIT  = 0x4000
PLR_PLAY  = 0x4005
PLR_MUTE  = 0x4007

GLOBVARS = 0x3800
LOCVARS  = 0x3900
ACTMENU  = 0x3a00
ILINK    = 0x3b00
STK_MENU = 0x3c00
STK_SUB  = 0x3d64

FONT     = 0x8000

ANIM_BFF  = 0x9000
ANIM_BFFR = 0x5000        

cmd_begin
    OS_HIDEFROMPARENT

    ld sp,0x4000
    call pre_init


;----------------------------------------------------


begin:
        call disable_anim
        ld a,0x13
        ld (COOOR+2),a ;y coord for ingame initial text position

        ld a,(menu_mus)
        call load_mus

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load menu picture
    xor a
    ld (menu_anim_fase),a
    ld (menu_subanim_fase),a
    inc a
    ld (menuanimer),a



        ld hl,menu_pic
        call load_big_img_dark2

        call palette_precalc
        call fade_fromwhite

_main_menu:
        ld hl,TABLE_W
        ld (CODEPAGE),hl 
_main_menu_mmm:

        ld hl,loc_main_menu
        ld de,menu_main_action

        push de
        ld a,(language)
        call sel_word
        
        call _pre_setup
        call _pre_menu_store_bgnd
        call _prt_menu
_mmnu_r1        
        call _sel_menu
        cp 0xff
        jr z,_mmnu_r1 ;block esc

        call _pre_menu_restore_bgnd

        pop hl
        call sel_word
        jp (hl)
;       call waitkey
_gamequit
        xor a
        ld (menuanimer),a
        call no_mus
        jp cmd_quit


_loadgame
        ld hl,loc_load_menu
        ld de,menu_load_action        

        push de
        ld a,(language)
        call sel_word
        
        call _pre_setup
        call _pre_menu_store_bgnd
        call _prt_menu
        
        call _sel_menu
        call _pre_menu_restore_bgnd
        pop hl

        cp 0xff
        jp z,_main_menu_mmm

        call sel_word
        jp (hl)

_load_slot1:
        ld a,1
        jr _load_slot
_load_slot2:
        ld a,2
        jr _load_slot
_load_slot3:
        ld a,3
        jr _load_slot
_load_slot4:
        ld a,4
        jr _load_slot
_load_slot5:
        ld a,5
_load_slot:
        add a,"0"
        ld (SAVETEMPL_N),a


        ld de,SAVETEMPL
        call openstream_file
        or a
        jp nz,_loadgame

_load_common:

        ld hl,538 ;len
        ld de,buf
        call readstream_file
        or a
        jp nz,filereaderror

        call closestream_file

        call save_to_globals

        jr GAMESTART1   ;hl-pointer to ovl name to load.

;------------------------------------------------
_newgame:
NWGAM:
        xor a
        LD HL,GLOBVARS
        LD B,A
        LD (HL),A
        INC HL
        DJNZ $-2
        ld hl,FSTOVL

GAMESTART1      

        xor a
        ld (menuanimer),a  
        ld de,OVL
        call copystr_hlde
        xor a
        ld (de),a        

        call clear_whole_screen
GAMESTART
        ld hl,TABLE_J
        ld (CODEPAGE),HL
;---------------------------------------------

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

;---------------------------------------------
BEG
        ld a,0xaf ;xor a
        ld (SUBLOCK),a  ; ???? hz chto eto. ne pomnu

        call disable_anim

;;ҒɐEʠLOCVARS ƠACTMENU
        xor a
        ld hl,LOCVARS
        ld bc,2
        ld (hl),a
        inc hl
        djnz $-2
        dec c
        jr nz,$-5
;---
       ld h,a
       ld l,h
       ld (g_curpos),hl 

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; TODO 鲯񡣨󺟡!!
 ;       LD HL,#1100
 ;       LD (g_atpos),HL            ;ATPOS= Y=#11 X=1
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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
        LD BC,#1300
        CALL _pradd
        CALL _print
TXTOUT1:
        call WINCLR2
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
        LD A,#40
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
        LD A,#40
        ADD A,H
        LD H,A
        JP TXTOUT
SEARCH1:
        INC HL,HL,HL
        JR SEARCH0

















        call waitkey
        jp _gamequit



main_end:
        include "../../_sdk/file.asm"

gf_func_start:
        include "gfx_func.asm"
gf_func_end:

sub_func_start:
        include "sub_func.asm"
sub_func_end:

sub_vars_start:
        include "sub_vars.asm"
sub_vars_end:

sub_dsk_start:
        include "sub_dsk.asm"
sub_dsk_end:

sub_variables_start:
        include "variables.asm"
sub_variables_end:




;FONT:   incbin  "font_rus.bin"

anim_stack_cursor dw 0
anim_stack_spr_num db 0

anim1_seq: db 0,1,1,1,0xfe
anim2_seq: db 0,20,1,20,2,20,1,20,0,100,1,20,2,20,1,20,0,20,0xff
anim3_seq: db 0,20,1,20,2,20,3,20,4,20,0,60,0xff
font_buf ds 16,0
menu_anim_fase:  db 0
menu_subanim_fase:  db 0
menu_anim_stack: db 1
                 dw 0x0000
                 db 1
                 dw 0x1000
                 db 1
                 dw 0x2000
                 db 1
                 dw 0x3000
                 db 2
                 dw 0x0000
        align 256
PUSH_DATA:  ds 256,0  ;//wait animation
anim_stack: ds 256,0

                
;db page, dw addr


_pal_bright:
        ds 32,0xff ;0 -min
        ds 32,0xff ;1
        ds 32,0xff ;2
        ds 32,0xff ;3-to black
        ds 32,0xff ;4-to white
        ds 32,0xff ;5
        ds 32,0xff ;6 -max
        ds 32,0xff ;7 -max

;dw sprite adress
;dw sprite scr adress
;db len
;db hgt
;db num of phases
;db seq position
;db next seq counter
;ds 7,0 placeholder

;0x0000 EOF


buf:            
         include "buf.asm"


cmd_end:        
        include "ptsplay.asm"

	display "main.com free space ",/d,GLOBVARS-buf," bytes"



	display "main.com length ",/d,main_end-cmd_begin," bytes"
	display "gf_func length ",/d,gf_func_end-gf_func_start," bytes"
	display "sub_func length ",/d,sub_func_end-sub_func_start," bytes"
	display "sub_vars length ",/d,sub_vars_end-sub_vars_start," bytes"
	display "sub_dsk length ",/d,sub_dsk_end-sub_dsk_start," bytes"
	display "sub_variables length ",/d,sub_variables_end-sub_variables_start," bytes"

	display "buf length",/d,cmd_end-buf," bytes"


        savebin "Mei.com",cmd_begin,cmd_end-cmd_begin
        savebin "aym_plr.bin",ptsbegin,ptsend-ptsbegin
        LABELSLIST "..\..\..\us\user.l"
