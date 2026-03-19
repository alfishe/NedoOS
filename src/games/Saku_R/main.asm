        DEVICE ZXSPECTRUM48
        include "../../_sdk/sys_h.asm"
        org PROGSTART


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

;================================================================
leaf_count       equ 6    ;êîëè÷åñòâî ëèòüåâ íå áîëüøå 20

module equ 0xc000
player_load = 0x4000

ovl_start = 0x4000

PLR_INIT  = 0x4000
PLR_PLAY  = 0x4005
PLR_MUTE  = 0x4008

GLOBVARS = 0x3800
LOCVARS  = 0x3900
ACTMENU  = 0x3a00
ILINK    = 0x3b00
STK_MENU = 0x3c00
STK_SUB  = 0x3d64


FONT     = 0x8000

ANIM_BFF  = 0x8000
ANIM_BFFR = 0x5000

sp_main = 0x4000
sp_alt  = 0x3f70
;================================================================

cmd_begin
                    OS_HIDEFROMPARENT
                    ld sp,sp_main
                    call pre_init  

begin:

        call no_mus

        call disable_anim
        call disable_anim_switches
        call clear_anim_stack
        ld a,2
        ld (petals_key),a

        ld a,(user_scr0_low)
        ld (_type_scr_low),a

        ld a,(user_scr0_high)
        ld (_type_scr_high),a


        ld a,0x13
        ld (COOOR+2),a ;y coord for ingame initial text position


        ld a,(menu_mus)
        call load_mus

        ld a,0
intro_  equ $-1
        and a
        call z,introduction

        call setcorepage

        jp  mm_mnu 



_load_common:
        ld hl,538 ;len
        ld de,buf
        call readstream_file
        or a
        jp nz,filereaderror

        call closestream_file

        call save_to_globals

        jp GAMESTART1   ;hl-pointer to ovl name to load.

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
        ld de,OVL
        call copystr_hlde
        xor a
        ld (de),a        
        ld a,2
        ld (petals_key),a
        halt

        call clear_whole_screen
GAMESTART

        xor a
        ld (_mmnr),a

        call unsetcorepage


        ld hl,TABLE_J
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

        ld de,pal
        ld hl,temppal
        ld bc,32
        ldir        

        ld a,1
        ld (setpalflag),a

;---------------------------------------------
BEG

        ld a,0xaf ;xor a
        ld (SUBLOCK),a  ; ???? hz chto eto. ne pomnu




        call disable_anim
        call disable_anim_switches
        call clear_anim_stack
    
;;Ò’ÉEÊ LOCVARS Æ ACTMENU
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
; TODO é²¯ñ¡£¨óºŸ¡!! ???????hz chto eto nuzhno posmotret
;        LD HL,#1100
;        LD (g_atpos),HL            ;ATPOS= Y=#11 X=1
;-------------------------------------------------
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



main_end:
        include "../../_sdk/file.asm"

gf_func_start:
        include "gfx_func.asm"
gf_func_end:


sub_func_start:
        include "sub_func.asm"

sub_func2_start:
        include "sub_func2.asm"

sub_func_end:


sub_eyes_start:
        include "sub_eyes.asm"
sub_eyes_end:



sub_vars_start:
        include "sub_vars.asm"
sub_vars_end:

sub_dsk_start:
        include "sub_dsk.asm"
sub_dsk_end:


sub_variables_start:
        include "variables.asm"
sub_variables_end:

        include "dzx0b.asm"




             align 256
font_buf                ds 16,0
anim_switches ds 16,0     ;//8 animation slots max. 1- anim enable 0 - anim disable

x_pos_anim_divided db 0            ;x -offset of eyes sprite

anim_is_found db 0         ;found anim or not in list
anim_spr_cnt dw 0          ;location of last char of name to check for animations


load_anim_slot             db      0    ;slot 0-7
load_anim_slot_addr        dw 0    ;start addr in slot to load

anim_stack_slot_pointer       dw 0    ;where slot data for animations stored in anim_stack (64 bytes chunk per slot)

temp_addr_storage          dw 0
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

;+11+12dw fase 0 offset
;+13+14dw fase 1 offset
;+15+16dw fase 2 offset
;+17+18dw fase 3 offset
;+19+20dw fase 4 offset
;+21+22dw fase 5 offset
;+23+24dw fase 6 offset
;+25+26dw fase 7 offset


;;; san shimai version
;dw sprite adress  +0+1
;dw sprite scr adress +2+3
;db len  +4
;db hgt +5
;db num of phases +6
;db seq position +7
;db next seq counter +8
;ds 7,0 placeholder

anim_stack_cursor dw 0



sparklings2_seq: db 1,0,0,0,0xfe,0   ;fase,time between fases
sparklings3_seq: db 1,0,2,0,0,0,0xfe,0
sparklings4_seq: db 1,0,2,0,3,0,0,0,0xfe,0
sparklings5_seq: db 1,0,2,0,3,0,4,0,0,0,0xfe,0


sparklings3_spec_seq db 1,2, 0,2,1,2, 0,2, 1,2, 0,2, 2,2, 0,1, 1,2, 0,2, 1,2, 0,2,1,2, 0,2, 1,2, 2,2, 0,1, 2,1,0,1,0xfe,0

halfblinks3_seq   db 1,1,2,1,1,1,0,1,0xff,0  
halfblinks7_seq   db 1,1,2,1,3,1,4,1,5,1,6,1,0,1,0xff,0

blinks2_seq: db 1,2,0,2,1,4,0,2,0xff,0
blinks3_seq: db 1,2,2,2,1,2,0,2,1,4,2,2,1,2,0,2,0xff,0
blinks4_seq: db 1,2,2,2,3,2,2,2,1,2,0,2,1,4,2,2,3,2,2,2,1,2,0,2,0xff,0

ani_mode_tbl:
        dw blinks_tbl
        dw halfblinks_tbl
        dw sparklings_tbl
        dw sparklings2_tbl

sparklings_tbl:
        dw 0
        dw 0
        dw sparklings2_seq
        dw sparklings3_seq
        dw sparklings4_seq
        dw sparklings5_seq

sparklings2_tbl:
        dw 0
        dw 0
        dw 0
        dw sparklings3_spec_seq

blinks_tbl:
        dw 0
        dw 0
        dw blinks2_seq
        dw blinks3_seq
        dw blinks4_seq
halfblinks_tbl:
        dw 0
        dw 0
        dw 0
        dw halfblinks3_seq
        dw 0
        dw 0
        dw 0
        dw halfblinks7_seq
CDATA:  ds 100,0

             align 256
t_s98_file00_pages_list:  ds 256,0

PUSH_DATA:  ds 256,0  ;//wait animation
anim_stack: ds 1024,0

;x_table                 incbin "x_table.bin"
;//8*32 bytes// 32bytes per slot
;//  





code_end:


buf:            
         include "buf.asm"
cmd_end:        
         include "page4000.asm"


        display "code_end ",/d,code_end," bytes"
        display "buf_start ",/d,buf," bytes"

        display "main.com free space ",/d,GLOBVARS-buf-768," bytes"

       display "main.com code_length ",/d,code_end-cmd_begin ," bytes"

        display "main.com length ",/d,main_end-cmd_begin," bytes"
        display "gf_func length ",/d,gf_func_end-gf_func_start," bytes"
        display "sub_func length ",/d,sub_func_end-sub_func_start," bytes"
        display "sub_eyes length ",/d,sub_eyes_end-sub_eyes_start," bytes"

        display "sub_vars length ",/d,sub_vars_end-sub_vars_start," bytes"

        display "sub_dsk length ",/d,sub_dsk_end-sub_dsk_start," bytes"
        display "sub_variables length ",/d,sub_variables_end-sub_variables_start," bytes"


        display "other length ",/d,code_end-font_buf," bytes"


        display "buf start",/d,buf," bytes"
        display "cmd_end end",/d,cmd_end," bytes"
        display "buf lenght",/d,cmd_end-buf," bytes"
        display "all gfx out routunes",/d,out_routines_end-out_routines_start," bytes"




        savebin "Saku_R.com",cmd_begin,cmd_end-cmd_begin
        savebin "Saku_R/page4000.bin",page4000begin,page4000end-page4000begin
;        LABELSLIST "..\..\..\us_ns2\user.l"    
        LABELSLIST "..\..\..\us\user.l",1