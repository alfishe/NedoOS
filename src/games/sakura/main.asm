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

cmd_begin
    OS_HIDEFROMPARENT

    ld sp,0x4000
    ld e,6+0x80  //set TEXT mode  keep
    OS_SETGFX

        ld e,0
        OS_CLS

        OS_GETMAINPAGES
;dehl=≠Æ¨•‡† ·‚‡†≠®Ê ¢ 0000,4000,8000,c000
        ld a,d
        ld (winpage0),a
        ld a,e
        ld (winpage1),a
        ld a,h
        ld (winpage2),a
        ld a,l
        ld (winpage3),a

; get music page page
        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (music_buf),a

; get gfx load buffer  2 pages
        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (load_buf1),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (load_buf2),a

; get ingame gfx buffer pages 6 pages
        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (scr_buf1),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (scr_buf2),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (mem_buf1),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (mem_buf2),a

        ld hl,txt_setup
        call print_hl
setup_lp:        
        YIELDGETKEYLOOP
        cp "1"
        jr z,setup_is1
        cp "2"
        jr z,setup_is2
        cp "3"
        jr z,setup_is3
        jr setup_lp
setup_is1:
          xor a
          jr setup_set
setup_is2:
         ld a,1
          jr setup_set
setup_is3:
         ld a,2
setup_set:
        ld (language),a
;-----------------------------------------
        ;go to resources directory
        ld de,res_path
        OS_CHDIR
        or a
        jp nz,dirchangeerror

        ;----------------------
        ;--load music player


              call setmusicpage
                ld a,(mus_mode)
                ld hl,mus_modes
                call sel_word

                ld de,buf
                call copystr_hlde
                ld hl,mus_plr_path
                call copystr_hlde
                xor a
                ld (de),a

                ld de,buf
                call openstream_file
                or a
                jp nz,fileopenerror

                ld hl,0x4000 ;len
                ld de,player_load ;addr
                call readstream_file
                or a
                jp nz,filereaderror 

                call closestream_file

             call unsetmusicpage


        call int_set

        ;set mode
        ld e,0+0x80  //set EGA mode keep
        OS_SETGFX

        call clear_screen
        LD B,75
;b_l:
;        halt
;        djnz b_l
;-----------------------------------------
begin:
        ld a,0x15
        ld (COOOR+2),a ;y coord for ingame initial text position


        ld a,10
        call load_mus

        ld a,0
intro_  equ $-1
        and a
        call z,introduction

       
        

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load menu picture
        ld hl,menu_pic
        call load_big_img_dark


        ld hl,menu_pic2
        call load_gfx_to_load_buf
        call _immed_big

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_main_menu:
        ld hl,TABLE_W
        ld (CODEPAGE),hl 

        
;-----open gallery file
        call _load_cdata
;-----------------------------------------------                

        call store_scr0_mem_buf

_main_menu_mmm:

        ld a,0
_mmnr   equ $-1        
        and a
        jr z,_dont_need_restore

        call restore_scr0_mem_buf
        xor a
        ld (_mmnr),a

_dont_need_restore:
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

_characters
_to_chr_page1
        ld hl,loc_chars1_menu
        ld de,menu_chars1_action        
        ld a,1

_characters_lp
        ld (characters_current),a
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

_to_chr_page2
        ld hl,loc_chars2_menu
        ld de,menu_chars2_action 
        ld a,2
        jr _characters_lp
_to_chr_page3
        ld hl,loc_chars3_menu
        ld de,menu_chars3_action 
        ld a,3
        jr _characters_lp
_to_chr_page4        
        ld hl,loc_chars4_menu
        ld de,menu_chars4_action 
        ld a,4
        jr _characters_lp
;0x33 = 33 reiko op01
;0x34 = 33 kiyomi 02
;0x35 = 33 mio 03
;0x36 = 33 shoko 04
;0x37 = 33 ruri    08   
;0x38 = 33 aki 05
;0x39 = 33 seia 06
;0x3a = 33 meimi 07

_op1_show ;reiko
        ld bc,0x0001
        jr _op_show
_op2_show ;kiyomi
        ld bc,0x0101
        jr _op_show        
_op3_show ;mio
        ld bc,0x0201
        jr _op_show        
_op4_show ;shoko
        ld bc,0x0301
        jr _op_show
_op5_show ;aki
        ld bc,0x0401
        jr _op_show
_op6_show ;seia
        ld bc,0x0501
        jr _op_show        
_op7_show ;meimi
        ld bc,0x0601
        jr _op_show        
_op8_show ;ruri
        ld bc,0x0701
        jr _op_show        
_op9_show ;kyoko
        ld bc,0x0800
        jr _op_show        
_op10_show ;makoto
        ld bc,0x0900
        jr _op_show                
_op11_show ;nobuyuki
        ld bc,0x0a00
        jr _op_show         
_op12_show ;emi
        ld bc,0x0b00
        jr _op_show         
_op13_show ;shinji
        ld bc,0x0c00
        jr _op_show                 
_op14_show ; dean
        ld bc,0x0d00
_op_show
        ld a,1
        ld (_mmnr),a

        ld a,b
        ld (_current_op),a

        ld a,c
        and a
        jr z,_op_skp

        ld e,b
        ld d,0
        ld hl,_op_slct
        add hl,de
        ld e,(hl)
        ld hl,CDATA
        add hl,de
        ld a,(hl)

        ld (_op_rslt),a

_op_skp:
        push bc

        ld a,b
        inc a
        call a_to_dec
        LD (op_path2+3),A
        LD A,B
        LD (op_path2+2),A        

        ld hl,op_path2
        call load_gfx_to_load_buf
        call _immed_big


        pop bc
        ld a,c
        and a
        jr z,_op_skp2
        ld a,(_op_rslt)
        cp 0x33
        jr nz,_op_skp2

;--------------------------
        ;TODO show badge
        ; show add menu
        ld hl,badge_pic
        call load_gfx_to_load_buf

        call _immed_overlay_big


        call waitkey

        ld hl,loc_lb_menu
        ld de,menu_lb_action

        push de
        ld a,(language)
        call sel_word
        
        call _pre_setup
        call _pre_menu_store_bgnd
        call _prt_menu
_mmnu_r2        
        call _sel_menu
        cp 0xff
        jr z,_mmnu_r2 ;block esc

        call _pre_menu_restore_bgnd

        pop hl
        call sel_word
        jp (hl)


;-------------------------

_op_skp2:
        call waitkey        

_mem_decline:
        ld a,(characters_current)
        cp 1
        jp z,_to_chr_page1
        cp 2
        jp z,_to_chr_page2
        cp 3
        jp z,_to_chr_page3
        cp 4
        jp z,_to_chr_page4        
        jp _to_chr_page1
;-----------------------------------------------------------------------
_mem_look_back:
        ld a,(_current_op)
        ld hl,_op_endings
        call sel_word   ;hl name ovl to load
        jp GAMESTART1
;-----------------------------------------------------------------------
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

;-----------------------------------------------------------------------        
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

        call clear_whole_screen
GAMESTART
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

;;—“»–¿≈Ã LOCVARS » ACTMENU
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
; TODO ËÒÔ‡‚ËÚ¸!!!!
        LD HL,#1100
        LD (g_atpos),HL            ;ATPOS= Y=#11 X=1
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
        pop hl

TXTOUT:
        LD BC,#1500
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






        include "../../_sdk/file.asm"
        include "variables.asm"
        include "sub_vars.asm"
        include "sub_func.asm"
        include "sub_dsk.asm"
        include "gfx_func.asm"
FONT:   incbin  "font_rus.bin"
CDATA:  ds 100,0
buf:            
txt_setup:          db 0x0A,"Season of the Sakura (Sakura no Kisetsu)",0x0D,0x0A
                    db "(c) 1996 JAST",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "language setup",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. English (DOS)",0x0D,0x0A
                    db "2. English (Jast USA memorial collection)",0x0D,0x0A
;                    db "2. Russian",0        
                    db "3. ",0x90,0xe3,0xe1,0xe1,0xaa,0xa8,0xa9,0        
buf_ext             ds 538-(buf_ext-txt_setup),0

cmd_end:        
        include "ptsplay.asm"

        savebin "saku-zx.com",cmd_begin,cmd_end-cmd_begin
        savebin "aym_plr.bin",ptsbegin,ptsend-ptsbegin
        LABELSLIST "..\..\..\us\user.l"
