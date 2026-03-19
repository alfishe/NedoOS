;-------GROUP15 TEMINATORS----- TODO!!!

LOADANIM
        ld a,0
        ld(alock),a

        ld a,(hl)
        ld (load_anim_slot),a
        
        push hl
        call init_setslotpage_by_a   ;set slot page, also set "load_anim_slot_half" and "load_anim_slot_addr"
        pop hl


        inc hl
        inc hl
        ld a,(hl)
        srl a
        jr nc,.lam1
        inc a
.lam1:
        ld (x_pos_anim_divided),a  ;x position  div 2  ; equ to x_position of main sprite
        inc hl
        inc hl        

        ;//name fom this position
        call store_name        
                dec de
                ld a,e
                ld (anim_spr_cnt),a
                ld a,d
                ld (anim_spr_cnt+1),a   ;addr of last symbol of animation name. need to check if next animation exists (a0,a1,a2 etc)        
                ;set 0 in the end of string
                inc de
        xor a
        ld (de),a

        inc hl
        push hl









        ld hl,nameslots_tbl

.emry_main_loop:
        ld de,namesslot_temp
        push hl
        call cmpr_dehl
        jp nz,.emry_skip_to_next

        ld a,(load_anim_slot)
        ld b,a
        ld a,(hl)
        cp b
        jr z,.emry_skips
        cp 255
        jr z,.emry_skips

        push hl
        call clear_slot_area_by_a
        pop hl

.emry_skips
        ld a,(load_anim_slot)
        ld (hl),a
        pop hl
        jr .emry_ext

.emry_skip_to_next:
        pop hl
        ld bc,5
        add hl,bc
        jr .emry_main_loop


.emry_ext






.lam0:
        call load_eyes
        ld a,(anim_is_found)
        and a
        jr z,.lam2            ;next animation not found. exit

        ld hl,(anim_spr_cnt)  ;animation founc. change file name and check again
        inc (hl)
        jr .lam0

.lam2:

        call unsetslotpage

        ld a,1
        ld(alock),a

        pop hl
        JP _print




ANIM_INIT:
        //init animations
        push hl
        call disable_anim_switches
        call clear_anim_stack
        pop hl
        JP _print


ALLANIMOFF:
        push hl
        call disable_anim_switches
        pop hl
        JP _print



ANIMON
        ld a,(hl)
        inc hl
        push hl
        push de
                call animon_sub
        pop de
        pop  hl        
        JP _print

animon_sub:
            ld e,a
            ld d,0
            ld hl,anim_switches
            add hl,de
            ld (hl),1
             ret        
;===========================================================================

clear_screen:
        ld e,0
        OS_CLS
        ret
setpal_proc
        ld de,pal
        OS_SETPAL
        xor a
        ld (setpalflag),a
        ret   


print_hl
        ld a,(hl)
        or a
        ret z
        push hl
        PRCHAR
        pop hl
        inc hl
        jp print_hl
        ret

;---------------------------------------



out_routines_start:
;for 320x200
_immed_big:
        call setcorepage
        call _immed_big_kernel
        jp unsetcorepage

;-------------
;draw load buf over scr0 . color 0x08 is transparent
_immed_overlay_big:
        call setcorepage
        call _immed_overlay_big_kernel
        jp unsetcorepage


;_immed  32  (50) моментально
;_sidas  36 54 от краёв к центру прямоугольником
;_jaluzi 37  55 по спирали от края к центру в два хода.
;_sidas  38  56 из центра во все стороны прямоугольником
;_cntsds 39 -57 от центра экрана влево и вправо одновременно.
;_dn_up  3A -58 от центра экрана вверх и вниз одновременно.
;_ud_nd  3B -59 проявление обратным растворением. 
;_jaluzi 3C -60 жалюзи. сверху вниз и снизу вверх одновременно через строку
;_lftrgt 3D - 61 слева направо. (ветер)


mask_mode db 0
_memory_output_mask:
        ld a,1
        jr _memory_output_o
_memory_output:
        xor a
_memory_output_o:        
        ld (mask_mode),a

        call setcorepage
        call _memory_output_kernel
        jp unsetcorepage


out_routines_end:
;------------------------------------------------------------------  
;in B - y C-x
;out   set coordinates for TYPE

_pradd
        LD (CORDS),BC
        SRL     C
        SBC     A
        AND %00100000
        LD      (M111),A

        PUSH HL
        LD H,#C0
        LD A,H
        OR 0
M111    EQU $-1
        LD H,A

        LD A,C
        ADD A,4
        LD L,A

        LD DE,320
pradd_l:        
        ADD HL,DE
        DJNZ pradd_l
        ld de,160+320
        add hl,de
        LD (COORDS),HL
        POP HL
        RET   

_type_scr_low:  db 0     
_type_scr_high: db 0
;---------------        
;in A - char to print
_type
        
        ld de,0
COORDS  equ $-2        
        ld h,0
        ld l,a
M10:
        ld bc,FONT
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,bc ;hl addr in FONT

 ;       ex de,hl
        push de
        push hl
        call setfontpage
        pop hl
        ld de,font_buf
        ld bc,16
        ldir
        call unsetfontpage


        pop hl

        ld de,font_buf
        push hl
        ld a,(_type_scr_low)
        SETPGC000
        ld b,8
_ppnz2:
        push bc
        ld a,(de)
        ld (hl),a
        inc de
        ld bc,40
        add hl,bc
        pop bc
        djnz _ppnz2
        pop hl

        push hl
        ld a,(_type_scr_high)
        SETPGC000
        ld b,8
_ppnz3:
        push bc
        ld a,(de)
        ld (hl),a
        inc de
        ld bc,40
        add hl,bc
        pop bc
        djnz _ppnz3
        pop hl

        ld a,h
        xor 0x20
        bit 5,h
        ld h,a
        jr z,_ppnz4:
        inc hl

_ppnz4:        
        ld (COORDS),hl
        ld bc,(CORDS)
        inc c
        ld (CORDS),bc
        ld a,c
        cp 64
        ret c
_ppnz4_hook: equ $-1

        inc b
        ld c,0
        jp _pradd

UPHL1   CALL UPHL
UPHL
        PUSH BC
        LD BC,40
        AND A
        SBC HL,BC
        POP BC
        RET


DHL1    CALL DHL
DHL
        PUSH BC
        LD BC,40
        ADD HL,BC
        POP BC
        RET
;;;;;;;;;;;;;;;;;;;;;;;
clear_whole_screen:
        call storec000
        ld a,(user_scr0_high)
        SETPGC000
        LD HL,#C000
        LD DE,#C001
        LD BC,16383
        LD [HL],L
        LDIR
        ld a,(user_scr0_low)
        SETPGC000
        LD HL,#C000
        LD DE,#C001
        LD BC,16383
        LD [HL],L
        LDIR
        jp restorec000
;;;;;;;;;;;;;;;;;;;;;;;;
_clear_textbox:
        call storec000

        ld a,(user_scr0_high)
        SETPGC000
CLEARER_ LD HL,0xda44-160      ;D080
CLEARER1 LD B,32
        XOR A
25      PUSH HL
        LD C,32
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ 25B

CLEARER2 LD HL,0xfa44-160   ;F080
CLEARER3 LD B,32
        XOR A
25      PUSH HL
        LD C,32
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ 25B

        ld a,(user_scr0_low)
        SETPGC000
CLEARER_A LD HL,0xda44-160
CLEARER1A LD B,32
        XOR A
25      PUSH HL
        LD C,32
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ 25B
CLEARER2A LD HL,0xfa44-160
CLEARER3A LD B,32
         XOR A
25         PUSH HL
         LD C,32
         LD (HL),A
         INC HL
         DEC C
         JR NZ,$-3
         POP HL
        LD DE,40
        ADD HL,DE
         DJNZ 25B
        
         jp restorec000

;----------------------------------------------------

_pre_setup
        ; ld a,(hl);string length
        ld a,(hl)
        ld (_line_lenght),a
        inc hl 

        ld a,(hl)
        ld (DOWN_LIMIT),a
        inc hl 
        push hl
        xor a
        ld (CUR_POS),a
        LD HL,#121A
        LD (_mnpos),HL
        pop hl
        ret
;----------------------------------------------------

_prt_menu
        ld bc,0
_mnpos: equ $-2        
        call _pradd
prt_m1:
        ld a,(hl)
        inc hl
        and a
        RET Z
        cp 1
        JR Z,PRT_M2
        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2        
        SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR prt_m1
PRT_M2: LD A,(_mnpos+1)
        INC A
        LD (_mnpos+1),A
        JR _prt_menu


_sel_menu:
        ld hl,0xD691+320+160    ;- left top corner of menus
        ld a,0
CUR_POS EQU $-1 
        and a 
        jr z,_sel_m_skip_c

        ld bc,320
_sel_menu_clc:
        add hl,bc
        dec a
        jr nz,_sel_menu_clc

_sel_m_skip_c:
        ld (SEL_S),hl

        call _highlight_selected
_sel_wait_loop:
        call waitkey

        cp key_up
        jr z,_sel_move_up
        cp key_down
        jr z,_sel_move_down
        cp key_enter
        jr z,_sel_sel_key
        cp ' '
        jr z,_sel_sel_key
        cp key_esc
        jr z,_sel_esc_key
        jr _sel_wait_loop

_sel_move_down
        ld hl,0
SEL_S   EQU $-2
        call _highlight_selected        
        ld hl,CUR_POS
        ld a,(hl)
        cp 0
DOWN_LIMIT EQU $-1        
        jp nc,_sel_menu
        inc (hl)
        jp _sel_menu

_sel_move_up
        ld hl,(SEL_S)
        call _highlight_selected        
        ld hl,CUR_POS
        ld a,(hl)
        and a
        jp z,_sel_menu
        dec (HL)
        jp _sel_menu
_sel_sel_key:
        ld hl,(SEL_S)
        call _highlight_selected
        ld a,(CUR_POS)
        ret

_sel_esc_key:
SEL_L   
        ld hl,(SEL_S)
        call _highlight_selected
        ld a,0xff
        ret

;--------------------------------------
;in hl adress in screen
_highlight_selected
;LINE1
        push de
        push hl
        call storec000
        pop hl 

        LD A,0
_line_lenght equ $-1
        LD [LINELEN],A
        LD [LINELEN0],A
        LD [LINELEN1],A
        LD [LINELEN2],A

         LD [LINE1_1],HL
         set 5,h
         LD [LINE1_2],HL

         ld a,(user_scr0_high)
         SETPGC000

         LD HL,0
LINE1_1  EQU $-2
         LD B,8
0        PUSH BC,HL
         LD B,6
LINELEN EQU $-1
1        LD A,(HL)
         XOR %00010010
         LD (HL),A
         INC HL
         DJNZ 1B
         POP HL
         CALL DHL
         POP BC
         DJNZ 0B
         LD HL,0
LINE1_2  EQU $-2
         LD B,8
0        PUSH BC,HL
         LD B,6
LINELEN0 EQU $-1
1        LD A,(HL)
         XOR %00010010
         LD (HL),A
         INC HL
         DJNZ 1B
         POP HL
         CALL DHL
         POP BC
         DJNZ 0B

         ld a,(user_scr0_low)
         SETPGC000

         LD HL,(LINE1_1)
         LD B,8
0        PUSH BC,HL
         LD B,6
LINELEN1 EQU $-1
1        LD A,(HL)
         XOR %00010010
         LD (HL),A
         INC HL
         DJNZ 1B
         POP HL
         CALL DHL
         POP BC
         DJNZ 0B

         LD HL,[LINE1_2]
         LD B,8
0        PUSH BC,HL
         LD B,6
LINELEN2 EQU $-1
1        LD A,(HL)
         XOR %00010010
         LD (HL),A
         INC HL
         DJNZ 1B
         POP HL
         CALL DHL
         POP BC
         DJNZ 0B

         call restorec000
         pop de
         ret
;;;;;;;;;;;;;;;;;;;;;;
_pre_menu_store_bgnd:
        push af
        push hl
        ;#d680
        call store8000c000

        ld a,(scr_buf1)
        SETPG8000

        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0xd680
        ld de,0x8000
        ld bc,320*7
        ldir

        ld hl,0xf680
        ld bc,320*7
        ldir


        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0xd680
        ld bc,320*7
        ldir

        ld hl,0xf680
        ld bc,320*7
        ldir

        call restore8000c000
        pop hl
        pop af
        ret
_pre_menu_restore_bgnd:
        push af
        push hl
        ;#d680
        call store8000c000

        ld a,(scr_buf1)
        SETPG8000

        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0x8000
        ld de,0xd680
        ld bc,320*7
        ldir

        ld de,0xf680
        ld bc,320*7
        ldir

        ld a,(user_scr0_high)
        SETPGC000
        ld de,0xd680
        ld bc,320*7
        ldir

        ld de,0xf680
        ld bc,320*7
        ldir
        call restore8000c000        
        pop hl
        pop af
        ret
       
;--------------------------- 
EXITDARK
       CALL clear_whole_screen
       JP begin

;;;;;;=====
FLASH
        ld b,(hl)
        inc hl
        push hl
        call setcorepage
        call FLASH_SUB
        call unsetcorepage
        pop hl
        jp _print


SHAKE:
        ld b,(hl)
        inc hl

        push hl
        call setcorepage
        call GATA
        call unsetcorepage

        pop hl
        jp _print
;;;;;;;;;;;;;;;;;;;;;;
; С€Т“ОЋИ Й‡ РЂНџУ€  В“Х…О Г›ГЋЕЂ
RESTOREBGND
       PUSH HL
        call setcorepage
        call RESTOREBGND_SUB
        call unsetcorepage
       POP HL
       JP _print

;-----
; У…ПђЙ€ ЕЋМ†ОЋ В›Уњ ИЂЛ€Е›ГЂО€Г ЮЉСЂОЂ  "PAGEMEM"
;Т…К—Q Т„Ж‹K ИЂЛ€Е›ГЂО€Г "PAGEBUF"    "PAGEMEM"
STOREBGND
       PUSH HL
        call setcorepage
        call STOREBGND_SUB
        call unsetcorepage
       POP HL
       JP _print       


;-----------------------------
CLRSCREEN

        call setcorepage
        call _clrscreen_kernel
        call unsetcorepage
        jp _print

;======================
load_tb008:
        inc hl
        LD A,(HL)
        LD (DELAY),A
        inc hl
        push hl
        call load_gfx_to_load_buf_nopal
        pop hl
       ld de,buf
        call copystr_hlde
        inc hl
        JP _print        

;======================
SPRITELOAD1:
        ld a,(hl)
        cp 07
        jr z,load_tb008
        INC HL
        LD A,(HL)
        LD (DELAY),A
        INC HL
        LD A,(HL)
        CP #0D
        JP Z,NORMALSPR

;----------------------------------------------------------------------------------------
;ГЋИЊП†ОЋ Г‘Ж’JЖ У“Р ОЂЕЋ ИЂЛ€Е›ГЂО€Г ЮЉСЂОЂ  "PAGEBUF"

        ;иҐҐтєЎЈсґЁЁуІЅ tb_008 !!!!!

        LD DE,7
        ADD HL,DE
        JP _print


NORMALSPR
        INC HL
        LD A,(HL)
        LD (XPOS),A
        INC HL,HL

        PUSH HL
        call load_gfx_to_scr_buf
        pop hl

        ld de,buf
        call copystr_hlde
        inc hl

        push hl
        CALL DECR_SPR
        POP HL
        JP _print


decrspr_offset dw 0 ;offset to draw sprite
dcrspr_len dw 0      ; cutted length
DECR_SPR:

        ld a,0
XPOS    EQU $-1
        SRL A
        jr nc,xpos1
        inc a
xpos1:        
        ld c,a
        ld b,0

;         LD BC,0
;XPOS     EQU $-2
;        LD HL,ZONEADR
;        ADD HL,BC
;        LD C,(HL)
;        ld b,0

        ld (decrspr_offset),bc

        and a
        ld hl,30
        SBC hl,bc
        ld (dcrspr_len),hl

        call store8000c000

        ld a,(scr_buf1)
        SETPG8000
        ld a,(load_buf1)
        SETPGC000

        call setcorepage


        ld bc,(decrspr_offset)
        ld hl,0xc005  ;
        add hl,bc
        ld de,0x8005

        ld b,148
decr_spr_lp1:
        push bc

        push hl
        push de

        ld bc,(dcrspr_len)
        call _iob

        pop hl ; (de)
        call DHL
        ex de,hl
        pop hl
        call DHL

        pop bc
        djnz decr_spr_lp1


        ld bc,(decrspr_offset)
        ld hl,0xe005
        add hl,bc
        ld de,0xa005

        ld b,148
decr_spr_lp2:
        push bc

        push hl
        push de

        ld bc,(dcrspr_len)
        call _iob

        pop hl ; (de)
        call DHL
        ex de,hl
        pop hl
        call DHL

        pop bc
        djnz decr_spr_lp2


        ld a,(scr_buf2)
        SETPG8000
        ld a,(load_buf2)
        SETPGC000

        ld bc,(decrspr_offset)
        ld hl,0xc005
        add hl,bc
        ld de,0x8005

        ld b,148
decr_spr_lp3:
        push bc

        push hl
        push de

        ld bc,(dcrspr_len)
        call _iob

        pop hl ; (de)
        call DHL
        ex de,hl
        pop hl
        call DHL

        pop bc
        djnz decr_spr_lp3


        ld bc,(decrspr_offset)
        ld hl,0xe005
        add hl,bc
        ld de,0xa005

        ld b,148
decr_spr_lp4:
        push bc

        push hl
        push de

        ld bc,(dcrspr_len)
        call _iob

        pop hl ; (de)
        call DHL
        ex de,hl
        pop hl
        call DHL

        pop bc
        djnz decr_spr_lp4

        call unsetcorepage
        jp restore8000c000
;-----------------------
;-----------------------
_prt_ingame_menu:
        ld bc,0
_ingame_m_mnpos: equ $-2
        call _pradd
prt_ingame_m1:
        ld a,(hl)
        inc hl
        and a
        RET Z
        cp 1
        JR Z,prt_ingame_m2
        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2        
        SUB 32
        PUSH HL
        CALL _type
        POP HL
        JR prt_ingame_m1
prt_ingame_m2:
        LD A,(_ingame_m_mnpos) ;x-coord
        add a,16
        ld (_ingame_m_mnpos),a
        cp 64
        jr c,_prt_ingame_menu
        and 0x3f
        LD (_ingame_m_mnpos),A
        ld a,(_ingame_m_mnpos+1)
        inc a
        ld (_ingame_m_mnpos+1),a
        JR _prt_ingame_menu
;------------------------------------

_sel_ingame_menu:
        ld a,0
_ingame_m_curpos equ $-1
        ld hl,MENUCURHELPER
        call sel_word
        ld (_sel_ingame_SELS4),hl
        call _highlight_selected
_sel_ingame_SELS3:        
        call waitkey

        cp key_esc
        jp z,_sel_ingame_esc

        cp key_left
        jr z,_sel_ingame_SELS_keyleft
        cp key_right
        jr z,_sel_ingame_SELS_keyright

        cp key_up
        jr z,_sel_ingame_SELS_keyup
        cp key_down
        jr z,_sel_ingame_SELS_keydown
                
        cp key_enter
        jr z,_sel_ingame_SELECTED
        cp ' '
        jr z,_sel_ingame_SELECTED
        jr _sel_ingame_SELS3        
_sel_ingame_esc:
        ld hl,0
_sel_ingame_SELS4: equ $-2
        call _highlight_selected
        ld a,0xff
        ret
_sel_ingame_SELS_keyleft:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 

        ld hl,_ingame_m_curpos
        ld a,(hl)
        and a
        jp z,_sel_ingame_menu
        dec (HL)
        jp _sel_ingame_menu

_sel_ingame_SELS_keyright:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 
        ld hl,_ingame_m_curpos
        ld a,(hl)
        cp 0
_ingame_m_downlimit EQU $-1        
        jp nc,_sel_ingame_menu
        inc (hl)
        jp _sel_ingame_menu
_sel_ingame_SELECTED:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected
        ld a,(_ingame_m_curpos)
        ret

_sel_ingame_SELS_keyup:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 


        ld hl,_ingame_m_curpos
        ld a,(hl)
        sub 4
        jp m,_sel_ingame_menu        
        ld (hl),a
        jp _sel_ingame_menu

_sel_ingame_SELS_keydown:
        ld hl,(_sel_ingame_SELS4)
        call _highlight_selected 

        ld a,(_ingame_m_downlimit)
        inc a
        ld b,a

        ld hl,_ingame_m_curpos
        ld a,(hl)
        add a,4
        sub b       
        jp p,_sel_ingame_menu        
        add a,b
        ld (hl),a

        jp _sel_ingame_menu        
;=========================================
;-----------------------
anim_wait:
        LD	A,0
        INC	A
        AND	7
        LD	(anim_wait+1),A
        RET	NZ



        
        ld hl,PUSH_DATA
        ld de,0x9e23-160

        ld a,0
FASE    equ $-1

        add a,a;x2
        add a,a;x4
        add a,a;x8
        add a,a;x16
        add a,a;x32
        ld c,a
        ld b,0
        add hl,bc        
        
        ex de,hl
      

        push hl
        ld b,8
export_push_iloop1:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz export_push_iloop1
        pop hl

        set 6,H
        push hl
        ld b,8
export_push_iloop2:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz export_push_iloop2
        pop hl

        res 6,H
        set 5,H

        push hl
        ld b,8
export_push_iloop3:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz export_push_iloop3
        pop hl

        set 6,H

        ld b,8
export_push_iloop4:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz export_push_iloop4

        ld a,(FASE)
        inc a
        and 7
        ld (FASE),a

        ret
;----------------------------- 


petals_draw:
petals_perfomance:
        nop

        ld a,(petals_key)
        cp 2
        jr z,mrei

        LD      A,0
petals_blocker equ $-1
        INC     A
        AND     3
        LD      (petals_blocker),A
        RET     NZ

mrei:
        call setcorepage
        call petals_render
        jp unsetcorepage


_petals_draw_:
        ld hl,leaf_data_table
        ld b,leaf_count
.lll:
        push bc
                ld a,(hl)
.testpoint
                sla a             ;
                ld e,a          ;
                ld a,0          ;
                adc a,0         ;   
                ld d,a          ;
                

                inc hl          ;*1
;                ex de,hl
 ;               call p_calc_x ;_fast2     ;fast приводит к зависанию.
  ;              ex de,hl

                        push hl
                        ld hl,x_table
                        add hl,de
                        ld e,(hl)
                        inc hl
                        ld d,(hl)
                        pop hl                


                ld a,(hl)
                ex de,hl
                push bc
                call p_calc_y_fast
                pop bc
                ex de,hl
                inc hl         ;*2
                ;hl = direction

                inc hl        ;*3
                ;hl = sprite
                ld a,(hl)



                ;now de = addr to draw sprite
                ;    hl- pointer to next sprite position 
                push hl
                        push de
                          ;store background
                           push af
                                ld a,leaf_count
                                sub b
                                ; now A - current slot
                                push af
                                  ld hl,leaf_s0_buf_status
                                  ld c,a
                                  ld b,0      
                                  add hl,bc
                                  ld (hl),1  ;set status - "screen should be restored"
                                pop af

                                  ;store screen addr from DE
                                  ld hl,leaf_s0_buf_scr_addr
                                  add a,a

                                  ld c,a
                                  ld b,0      
                                  add hl,bc

                                  ld (hl),e
                                  inc hl
                                  ld (hl),d   ;save scr addr where should be scr restore apply
                           pop af

                        pop  de

                        ld hl,leaf_table
                        call sel_word
                        ex de,hl
                        ld a,4                       
                        call _draw_custom_spr



                pop hl

                inc hl      ;*4

                ld bc,6
                add hl,bc
        pop bc
        djnz .lll
        ret


;---
;in hl - x-coord 0-319
;;out hl -adress in 8000 - ffff atm2 ega screen (x-offset)
p_calc_x:
        and a
        rr h
        rr l
        ld a,l
        rrca
        rrca
        ld h,0
        and a
        push af
        rla
        rr h
        rla
        rr h
        scf
        rr h
        pop af
        and 0x3f
        ld l,a
        ret 
;=============================================       
;in hl - x-adress in atm2 ega screen
;   a - y coord - 0-199
;;out hl -adress in 8000 - ffff atm2 ega screen (xy offset)
p_calc_y:
        ld bc,40
p_calc_y_loop:
        and a
        ret z
        add hl,bc
        dec a
        jr p_calc_y_loop        
;=============================================       
p_nextcolumn:
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
    ret
;---------------------------------------


;------------------------------------------------------------------        
;copy image to screen by mask (9 color in palette is mask)
_iob_byte:
        ld a,(de)
        cp 0b11000000   ;double transparent bytes
        jr z,_iob_next_b
        push af
        and 0b10111000
        cp  0b10000000
        jr z,_iob_left_transparent
        pop  af
        push af
        and 0b01000111
        cp  0b01000000
        jr z,_iob_right_transparent
        pop af
_iob_next_b1:
        ld (hl),a; all solid. copy
_iob_next_b
        ret        


_iob_left_transparent
        ld a,0b10111000 ;
        and (hl)
        ld (hl),a
        pop af
        and 0b01000111
        or (hl)
;       ld (hl),a
        jr _iob_next_b1
_iob_right_transparent
        ld a,0b01000111
        and (hl)
        ld (hl),a
        pop af
        and 0b10111000
        or (hl)
;       ld (hl),a
        jr _iob_next_b1       
;------------------------------------------------------------------        

;==============
;_type_scr_low:  db 0     
;_type_scr_high: db 0
;        ld a,(user_scr0_low)
;        ld (_type_scr_low),a

;        ld a,(user_scr0_high)
;        ld (_type_scr_high),a
;============
set_type_to_active_scr:
;set '_type' output to displayed screen
        ld a,(active_scr)
        and a
        jr nz,.sttac1
         ld a,(user_scr0_low)
         ld (_type_scr_low),a

         ld a,(user_scr0_high)
         ld (_type_scr_high),a
        ret
.sttac1
         ld a,(user_scr1_low)
         ld (_type_scr_low),a

         ld a,(user_scr1_high)
         ld (_type_scr_high),a
        ret
;===================================
set_cur_scr:
        ld a,(active_scr)
        and a
        jr nz,set_draw_scr.spl0
        jr set_draw_scr.spl1
set_draw_scr:
        ld a,(active_scr)
        and a
        jr nz,.spl1
.spl0:
          ld a,(user_scr1_low)  ;ld a,(user_scr1_low)
         SETPG8000
          ld a,(user_scr1_high)  ;ld a,(user_scr1_low)
         SETPGC000

         ret
.spl1:
        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ret



set_scr_low:
        ld a,(active_scr)
        and a
        jr nz,.spl1
.spl0:
         ld a,(user_scr0_low)  ;ld a,(user_scr1_low)
         SETPG8000
          ld a,(user_scr1_low)  ;ld a,(user_scr1_low)
         SETPGC000

         ret
.spl1:
        ld a,(user_scr1_low)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000
        ret

set_scr_high:
        ld a,(active_scr)
        and a
        jr nz,.spl1
.spl0:
          ld a,(user_scr0_high) ;ld a,(user_scr1_high)
         SETPG8000
          ld a,(user_scr1_high) ;ld a,(user_scr1_high)
         SETPGC000
         ret
.spl1:
        ld a,(user_scr1_high)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ret
;=================================================
copy_scr0_scr1:
                ld a,(user_scr0_low)
                SETPG8000
                ld a,(user_scr1_low)
                SETPGC000

                ld hl,0x8000
                ld de,0xc000
                ld bc,8000
                ldir
                ld hl,0xa000
                ld de,0xe000
                ld bc,8000
                ldir

                ld a,(user_scr0_high)
                SETPG8000
                ld a,(user_scr1_high)
                SETPGC000

                ld hl,0x8000
                ld de,0xc000
                ld bc,8000
                ldir
                ld hl,0xa000
                ld de,0xe000
                ld bc,8000
                ldir
                ret
force_scr0:
eerrr0
        ld a,(active_scr)
        and a 
        jr  z,.spl11
        ;copy scr1 to scr0
                
        call copy_scr1_scr0

        xor a
        ld (active_scr),a
.spl11:
        ld e,0
        OS_SETSCREEN
        ret

copy_scr1_scr0:
                ld a,(user_scr1_low)
                SETPG8000
                ld a,(user_scr0_low)
                SETPGC000

                ld hl,0x8000
                ld de,0xc000
                ld bc,8000
                ldir
                ld hl,0xa000
                ld de,0xe000
                ld bc,8000
                ldir

                ld a,(user_scr1_high)
                SETPG8000
                ld a,(user_scr0_high)
                SETPGC000

                ld hl,0x8000
                ld de,0xc000
                ld bc,8000
                ldir
                ld hl,0xa000
                ld de,0xe000
                ld bc,8000
                ldir
        ret

