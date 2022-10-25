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

print_v_limit:   equ 0x17
print_p_len:     equ 53
txt_coor:        equ 0x1400
x_txt_coor  =    low txt_coor


txt_coor2:        equ 0x1420

module equ 0xc000
player_load = 0x4000

ovl_start = 0x4000

PLR_INIT  = 0x4000
PLR_PLAY  = 0x4005
PLR_MUTE  = 0x4007


;LOCVARS  = 0x3900
;ACTMENU  = 0x3a00
GLOBVARS = 0x3c00 ;0x3800
ILINK    = 0x3d00
STK_MENU = 0x3e00

FONT     = 0x8000
FONT2    = 0x9000

ANIM_BFF  = 0x9000
ANIM_BFFR = 0x5000        

sp_main = 0x4000
sp_alt  = 0x3f90

cmd_begin
                    OS_HIDEFROMPARENT
                    ld sp,sp_main
                    call pre_init    


begin:
                        ld a,6
                        ld (outtyp),a

                
                        ld a,(menu_mus)
                        call load_mus



        ld hl,menu_pic
        call load_big_img_dark2



        call palette_precalc
        call fade_fromwhite



_main_menu:
_main_menu_mmm:

        ld hl,loc_main_menu
        ld de,menu_main_action

        push de
        ld a,(language)
        call sel_word
        
        call _pre_setup
        call _pre_menu_store_bgnd
        call _draw_menu_box
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
        call _draw_menu_box
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
_load_slot:
        add a,"0"
        ld (SAVETEMPL_N),a


        ld de,SAVETEMPL
        call openstream_file
        or a
        jp nz,_loadgame

_load_common:
        ;load screenshot to load_buf with palette

        ;call no_mus ;!!!!!!!!!

        call store8000c000

        ld a,(load_buf1)
        SETPG8000

        ld a,(load_buf2)
        SETPGC000


         ld hl,0x8000
         ld de,0x8000
         call readstream_file
         or a
        jp nz,filereaderror 

        call restore8000c000

        ld de,t_pal;curpal
        ld hl,32
        call readstream_file
        or a
        jp nz,filereaderror 


        ld de,GLOBVARS
        ld hl,256
        call readstream_file
        or a
        jp nz,filereaderror 


        ld de,loadedCg
        ld hl,32
        call readstream_file
        or a
        jp nz,filereaderror 

        ld de,OVL
        ld hl,32
        call readstream_file
        or a
        jp nz,filereaderror 


        ld de,text_pointer
        ld hl,2
        call readstream_file
        or a
        jp nz,filereaderror 

        ld de,redraw_border
        ld hl,1
        call readstream_file
        or a
        jp nz,filereaderror 

        ld de,t_mus
        ld hl,1
        call readstream_file
        or a
        jp nz,filereaderror 

        call closestream_file

freddd:
;_redraw screen
        ld hl,OVL
        call load_ovl_to_script_buf

;memorize ovl name
                ld hl,OVL
                ld de,LOADED
                call copystr_hlde
                xor a
                ld (de),a

        ;clear OVL variable
                ld hl,OVL
                ld de,OVL+1
                ld (hl),0
                ld bc,31
                ldir

        ;//load CG to mem buf
        ld hl,loadedCg
        ld a,(hl)
        and a
        call nz,load_gfx_to_mem_buf

;;;;F_o
        ld a,(t_mus)
        call load_mus


        call _B_O_sub

        ld a,(redraw_border)
        jr nz,.nnn


        ld hl,t_pal
        ld de,pal
        ld bc,32
        ldir 

        xor a
        ld (outtyp),a
        inc a
        ld (setpalflag),a
        halt

        call update_satus_bar

        ld hl,loadedCg
        ld a,(hl)
        and a    
        call nz,_buffer_output


.nnn
        call _clear_textbox
        ld hl,(text_pointer)


        jp _txt_out   ;hl-pointer to ovl name to load.

;------------------------------------------------
_newgame:
NWGAM:
        ld a,1
        ld (redraw_border),a
        xor a
        LD HL,GLOBVARS
        LD B,A
        LD (HL),A
        INC HL
        DJNZ $-2
        ld hl,FSTOVL

GAMESTART1:      
        ld de,OVL
        call copystr_hlde
        xor a
        ld (de),a        

        call clear_whole_screen


GAMESTART:
BEG:


;load ovl
        ld hl,OVL
        call load_ovl_to_script_buf
;memorize ovl name
        ld hl,OVL
        ld de,LOADED
        call copystr_hlde
        xor a
        ld (de),a

;clear OVL variable
        ld hl,OVL
        ld de,OVL+1
        ld (hl),0
        ld bc,31
        ldir

          ld a,(redraw_border)
          and a
          call z,update_satus_bar

        CALL _clear_textbox


        ld hl,0x4000 ;script start adress
;---------------------------------------------------
_txt_out:

        ;TODO
        ld bc ,txt_coor
        call _pradd_p

        ld a,1
        ld (first_word),a
        ld (first_letter),a
        ld (just_cr),a


;---------------------------------------------------
;print routine
_print:
        push hl
        call clear_txt_buff

        pop hl

        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)
        SETPG8000 

        ld de,txt_buff        
        ld c,0   ;//symbol counter

.p0:
        LD A,(HL)
        CP 32+1
        JR C,.p1 ;is control code
        ;copy string yo buffer

        ld (de),a

        ld a,(first_word)
        and a
        jr z,.pm0
        ld a,(first_letter)
        and a
        jr z,.pm0
        xor a
        ld (first_letter),a
        ld (text_pointer),hl
        

.pm0
        inc hl
        inc de
        inc c
        jr .p0


.p1:
        push af
        ld a,c
        and a
        jr nz,.p1_1     ;buffer not empty. print string
        pop af

        cp 32
        jp nz,_print_token

        ld a,(just_cr)
        and a
        jr nz,.p1_0 ;if just go to new line - do not print space

        ld a,32
        ld (de),a ;print space
        inc hl
        inc c
;        jr .p1_0
;.p1_01:
;        xor a
;        ld (just_cr),a    
.p1_0:

        push af
.p1_1:
        ld a,c
        ld bc,(CORDS_P)           ;B-y C-X
        add a,c
        cp print_p_len

        jr c,.p1_no_overflow

        call _linefeed

       jr .npo
.p1_no_overflow:
        xor a
        ld (just_cr),a
.npo:

        ld a,(first_word)
        and a
        jr z,.npo0

        dec de
        ld a,(de)
        cp ':'
        jr nz,.npo00
        push hl
;        ld hl,0x4080 ;index 8 magenta
        ld hl,0x0108 ; index 1
        ld (_type_color),hl
        pop hl
        jr .npo0
.npo00        
        xor a
        ld (first_word),a
.npo0      
        call _print_txt_buf_p

        ld a,(first_word)
        and a
        jr z,.npo3
                xor a
                ld (first_word),a
                push hl
                ld hl,0x47b8
                ld (_type_color),hl
                pop hl
.npo3
        pop af
        jp _print

_print_token:

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
        pop hl

        ;    inc hl ;!debug! skip unused code
        ;jr _print
;;;;;!!!!!!!!!!!!

        push hl

        ld hl,stdpal
        ld bc,32
        ld de,pal
        ldir

        ld a,1
        ld (setpalflag),a

        pop  hl

    ld a,(hl)
    call a_to_dec
    ld hl,buf+2
    ld (hl),0
    dec hl
    ld (hl),a
    dec hl
    ld a,b
    ld (hl),a
    ld hl,txt_unkcode
    jp openerror

;;;;;!!!!!!!!!!!!
_linefeed:
                ld a,1
       ld (just_cr),a

        ld bc,(CORDS_P)
        inc b
        ld c,x_txt_coor
        call _pradd_p

        ld bc,(CORDS_P)
        LD A,B
        CP print_v_limit
        CALL NC, WINCLR1
        ret

        call waitkey
        jp _gamequit



_tokenTable
        db 0x01
        dw WINCLR  ;IF PRESSED KEY              ;++++

        db 0x04
        dw _loadovl

        db 0x06
        dw _CDPLAY

        db 0x0b
        dw _group0b ;!!!!!!!!

        db 0x0f
        dw _gameend

        db 0x10
        dw _cls

        db 0x13
        dw _group13 ;!!!!!!!!

        db 0x14
        dw _group14;!!!!!!!!

        db 0x16
        dw _flash

        db 0x17
        dw _T_WAIT

        db 0x18
        dw _gata

        db 0x19
        dw _group19 ;!!!!!!!!

        db 0xff



_tokenTable0b
        db 0x01
        dw _var_plus
        db 0x05
        dw _var_equal
        db 0x0d
        dw _var_minus
        db 0x0e
        dw _var_div
        db 0x0f
        dw _var_down

        db 0x36
        dw _goto
        db 0x39
        dw _jtbl
        db 0x40
        dw _flg_if
        
        db 0xff

_tokenTable13
        db 0x01
        dw _EVENT_CG ; show cg
        db 0x02
        dw _SCREENOUTPUT1
        db 0x03
        dw _T_CG
        db 0x04
        dw _LOAD_TO_MEM
        db 0x0f
        dw _COPY_MEM_2_LOAD    
        db 0xff


_tokenTable14
        db 0x03
        dw _F_O   ;clear cg screen to black
        db 0x04
        dw _B_O   ;whole screen blackout

        db 0x08
        dw _SCR_SET

        db 0xff

_tokenTable19
        db 0x01
        dw _MENU_SET
        db 0xff


_group0b:
        ld de,_tokenTable0b
        jr _groups
_group19:
        ld de,_tokenTable19
        jr _groups
_group13:
        ld de,_tokenTable13
        jr _groups
_group14:
        ld de,_tokenTable14
_groups:
        inc hl
        ld a,(hl)
        inc hl
        push hl
        ex de,hl

        ld c,a
.p5_6:
        ld a,(hl)
        inc hl
        cp 0xff
        jr z,.p5_8
        cp c
        jr z,.p5_7
        inc hl
        inc hl
        jr .p5_6
.p5_7:
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ex (sp),hl
        ret
.p5_8:
        pop hl
        jp _print     





txt_buff: ds 256,0

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

sub_vars_start:
        include "sub_vars.asm"
sub_vars_end:

sub_dsk_start:
        include "sub_dsk.asm"
sub_dsk_end:

sub_variables_start:
        include "variables.asm"
sub_variables_end:



code_end:
;FONT:   incbin  "font_rus.bin"





        align 256
font_buf                ds 16,0

        align 256
t_s98_file00_pages_list:  ds 256,0

PUSH_DATA:  ds 256,0  ;//wait animation
CUR_DATA:   ds 128,0
CUR_BGND_STORE: ds 128,0


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

        align 256
tbright
;brightness levels (black 0..7 less than original, 8 equal, 9..15 to white)
;0, 1/12, 1/8, 3/16, 2/8, 3/8, 4/8, 6/8, 1
_lev=0
        dup 16 ;colour component level
_antilev=15-_lev
        BRIGHTBYTE _lev*0
        BRIGHTBYTE _lev/12
        BRIGHTBYTE _lev*1/8
        BRIGHTBYTE _lev*3/16
        BRIGHTBYTE _lev*2/8
        BRIGHTBYTE _lev*3/8
        BRIGHTBYTE _lev*4/8
        BRIGHTBYTE _lev*6/8

        BRIGHTBYTE _lev

        BRIGHTBYTE 15-(_antilev*6/8)
        BRIGHTBYTE 15-(_antilev*4/8)
        BRIGHTBYTE 15-(_antilev*3/8)
        BRIGHTBYTE 15-(_antilev*2/8)
        BRIGHTBYTE 15-(_antilev*3/16)
        BRIGHTBYTE 15-(_antilev*1/8)
        BRIGHTBYTE 15

_lev=_lev+1
        edup

        align 256
tx
        dup 256
        db ($&0xff)/4
        edup
        dup 64
        db 0x80
        db 0xc0
        db 0xa0
        db 0xe0
        edup
ty
        dup 200
        db 0xff&(($&0xff)*40)
        edup
        ds 56,0xff&8000
        dup 200
        db (($&0xff)*40)/256
        edup
        ds 56,8000/256


;dw sprite adress
;dw sprite scr adress
;db len
;db hgt
;db num of phases
;db seq position
;db next seq counter
;ds 7,0 placeholder

;0x0000 EOF
        align 256
SCTBL:          ;structure
        DW      S1, S2, S3, S4, S5, S6, S7, S8
        dw 0xffff    

COMTBL:         ;tree
        DW      CM1, CM2, CM3, CM4, CM5, CM6, CM7, CM8
        dw 0xffff

CM1:    DW      0 ,    -1  ;0  - adress od menu name string
CM2:    DW      0 ,    -1
CM3:    DW      0 ,    -1
CM4:    DW      0 ,    -1
CM5:    DW      0 ,    -1
CM6:    DW      0 ,    -1
CM7:    DW      0 ,    -1
CM8:    DW      0 ,    -1
        DW      0xffff
S1:     DW      0,-1,1, 1 ;0  - adress od menu name string
S2:     DW      0,-1,2, 1 ;1 - goto addr.
S3:     DW      0,-1,3, 1
S4:     DW      0,-1,4, 1        
S5:     DW      0,-1,5, 1
S6:     DW      0,-1,6, 1
S7:     DW      0,-1,7, 1
S8:     DW      0,-1,8, 1        
        DW      0xffff
buf:            
         include "buf.asm"

;buf_ext             ds 538-(buf_ext-txt_setup),0

cmd_end:        
        include "ptsplay.asm"
;        include "intro.eng.asm"
;        include "intro.rus.asm"



        display "main.com free space ",/d,GLOBVARS-buf," bytes"

       display "main.com code_length ",/d,code_end-cmd_begin ," bytes"

        display "main.com length ",/d,main_end-cmd_begin," bytes"
        display "gf_func length ",/d,gf_func_end-gf_func_start," bytes"
        display "sub_func length ",/d,sub_func_end-sub_func_start," bytes"
        display "sub_vars length ",/d,sub_vars_end-sub_vars_start," bytes"
        display "sub_dsk length ",/d,sub_dsk_end-sub_dsk_start," bytes"
        display "sub_variables length ",/d,sub_variables_end-sub_variables_start," bytes"

        display "buf lenght",/d,cmd_end-buf," bytes"


        savebin "tenkosei.com",cmd_begin,cmd_end-cmd_begin
        savebin "aym_plr.bin",ptsbegin,ptsend-ptsbegin
        LABELSLIST "../../../us/user.l",1
