        DEVICE ZXSPECTRUM48
        include "../../_sdk/sys_h.asm"
        org PROGSTART


print_p_len: equ 51
txt_coor:       equ 0x1400
x_txt_coor= low txt_coor



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
FONT2    = 0x9000

ANIM_BFF  = 0x9000
ANIM_BFFR = 0x5000        

sp_main = 0x4000
sp_alt  = 0x3f70

cmd_begin
    OS_HIDEFROMPARENT
    ld sp,sp_main
    call pre_init    



;----------------------------------------------------


begin:
        ld a,6
        ld (outtyp),a

       ; ld a,0x12
       ; ld (COOOR+2),a ;y coord for ingame initial text position

        ld a,(menu_mus)
        call load_mus


        ld a,0
intro_switch equ $-1
        and a
        call z,introduction


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; load menu picture
        ld hl,menu_pic
        call load_big_img_dark2



	LD bc,0
	CALL _pradd2
	LD HL,TEXT1
	CALL _type_txt_buf

	LD BC,#0100
	CALL _pradd2
	LD HL,TEXT3
	CALL _type_txt_buf


	LD BC,#1800
	CALL _pradd2
	LD HL,TEXT2
	CALL _type_txt_buf

;;;;;;;;;;;
	LD BC,#090f
	CALL _pradd2
	LD HL,menu1
	CALL _type_txt_buf


	LD BC,#0a0f
	CALL _pradd2
	LD HL,menu2
	CALL _type_txt_buf


	LD BC,#0b0f
	CALL _pradd2
	LD HL,menu3
	CALL _type_txt_buf


;;;;;;;;;;;
        ld a,(dc_enabled)
        and a
        jr z,_nnn

	LD BC,#0d0f
	CALL _pradd2
	LD HL,menu4
	CALL _type_txt_buf


_nnn:
        call palette_precalc
        call fade_fromwhite



_main_menu:
        ld hl,TABLE_W
        ld (CODEPAGE),hl 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
1	CALL waitkey
	CP "4"
	JR Z,NWGAM_DC
	CP "1"
	JR Z,NWGAM
	CP "2"
	JR Z,CONT_GAME
	CP "3"
	JR NZ,1B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_gamequit
        call no_mus
        jp cmd_quit


CONT_GAME:
        ld de,SAVETEMPL
        call openstream_file
        or a
        jr nz,_main_menu

        ld hl,33 ;len
        ld de,buf
        call readstream_file
        or a
        jp nz,filereaderror

        call closestream_file

        ld hl,buf
        ld a,(hl)
        inc a
        jp nz,_main_menu
        inc hl
        jp GAMESTART1

;------------------------------------------------
_newgame:
NWGAM_DC:
        ld a,(dc_enabled)
        and a
        jp z,_main_menu

        ld a,1
        jr NWGAMa
NWGAM:
        xor a
NWGAMa:
        ld (v_mode),a
        ld hl,FSTOVL
GAMESTART1        
        ld de,OVL
        call copystr_hlde
        xor a
        ld (de),a        



        call clear_whole_screen
GAMESTART
        ld hl,TABLE_W
        ld (CODEPAGE),HL
;---------------------------------------------


;---------------------------------------------
BEG




        CALL _clear_textbox
        ;call clear_whole_screen


        LD BC,#1600
        CALL _pradd

        ld hl,#eee6
        ld (clr1),hl
        ld (clr2),hl
        
        ld hl,help_text
        call _type_txt_buf
        

        ld hl,0
        ld (clr1),hl
        ld (clr2),hl



        ld hl,OVL
        call load_ovl_to_script_buf

        ;store loaded ovl name
        ld hl,OVL
        ld de,LOADED
        call copystr_hlde
        xor a
        ld (de),a


        ld hl,OVL
        ld de,OVL+1
        ld (hl),0
        ld bc,31
        ldir

        ld hl,#4000
    ;//load mus
        PUSH HL
        LD A,(HL)
        CALL load_mus
        POP HL
        INC HL
    ;//load bg
        push hl

        ld de,ovlnamebuf

        ld a,(v_mode)
        and a
        jr z,.skip1_dc
        ld hl,dc_prefix
        call copystr_hlde


.skip1_dc
        pop hl       
        call copystr_hlde
        inc hl
        push hl
        ld hl,ovlnamebuf
        call load_gfx_to_load_buf

        call clear_ovlnamebuf


        ld de,ovlnamebuf
        ld a,(v_mode)
        and a
        jr z,.skip2_dc
        ld hl,dc_prefix
        call copystr_hlde
.skip2_dc
        pop hl
        call copystr_hlde
        inc hl
        push hl
        ld hl,ovlnamebuf
        call load_gfx_to_scr_buf

        call clear_ovlnamebuf

        call DECR_SPR
        call _buffer_output

        pop hl


        jp _main_txtout ;@@@@@@@@@@@@
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


_exitlight:
        call fade_towhite
        CALL clear_whole_screen

        ld de,PERSISTSAVE
        call openstream_file
        or a
        jr z,.skip_ps

         LD DE,PERSISTSAVE
         OS_CREATEHANDLE
         OR A
         JP NZ,filecreateeerror
         ld a,b
         ld (filehandle),a      

        ld hl,1 ;len
        ld de,buf ;addr
        call savestream_file
        or a
        jp nz,filewriteerror 
        call closestream_file        
                
        ld a,1
        ld (dc_enabled),a

.skip_ps

        jp begin
_exitdark
        call fade_toblack 
        CALL clear_whole_screen
        jp begin



_scenario:
        ld de,OVL      
        call copystr_hlde
        jp BEG

        call waitkey
        jp _gamequit


_menu_s:
        ld de,namebuf1
        call copystr_hlde
        xor a
        ld (de),a
        inc hl
        ld de,namebuf2
        call copystr_hlde
        xor a
        ld (de),a
        inc hl
        
        push hl
        ld bc,#1200
        call _pradd_p2
        ld hl,lines1
        call _type_txt_buf_p

        ld bc,#1203
        call _pradd_p2
        pop hl
        call _print_b

        push hl
        ld bc,#1400
        call _pradd_p2
        ld hl,lines2
        call _type_txt_buf_p

        ld bc,#1403
        call _pradd_p2
        pop hl
        call _print_b


1	call waitkey_a
	CP "1"
	JR Z,_g1a
	CP "2"
	JR Z,_g2a
        jr 1b

_g1a:    ld hl,namebuf1
        jr _g3a
_g2a:    ld hl,namebuf2
_g3a:     jp _scenario
        



;//////////////////////////////////////
_print_b:
        call clear_txt_buff
_print_b1
        ld de,txt_buff        
        ld c,0   ;//symbol counter
.txt_lp1
        ld a,(hl)
        cp 32+1 
        jr c, _printb_controlcode

        ;copy string yo buffer
        ld (de),a
        inc hl
        inc de
        inc c
        jr .txt_lp1


_printb_controlcode:
        push af
                ;check if buffer overflow   
                ld a,c
                and a
                jr z,_printb_cc_sp_tk   ;buffer is empty. attempt to print space or token

                ;buffer not empty. print string
                ld bc,(CORDS_P)           ;B-y C-X
                add a,c
                cp print_p_len
                jr nc,_printb_overflow

                call _print_txt_buf_p
        pop af
        jp _print_b1


_printb_cc_sp_tk:
        pop af   ;restore curren symbol

        inc hl;!!!!!!!!!!!!

        cp 32
        ret nz  ;char is token
        ; print space
        ld bc,(CORDS_P)
        ld a,c          ;check for overflow
        inc a
        cp print_p_len
        jr nc,_printb_overflow1  ;not restore af
        ld a,32
        ld (de),a
        call _print_txt_buf_p
        jp _print_b1
        
        
_printb_overflow:
         pop af
_printb_overflow1:
        ld bc,(CORDS_P)
        inc b
        ld c,x_txt_coor
        call _pradd_p2

        ld bc,(CORDS_P)
    	LD A,B
    	CP #17
    	 CALL NC,WINCLR1 

        call _print_txt_buf_p
        jr _print_b1
    


;//////////////////////////////////////

_main_txtout:

        ;//ovl print pre-init


_txtout:
        LD BC,txt_coor
        CALL _pradd_p
        



_txtout1:
_txtout2:

        push hl
        call clear_txt_buff
        pop hl
        ld a,(script_buf1)
        SETPG4000
        ld a,(script_buf2)
        SETPG8000         


        ld de,txt_buff        
        ld c,0   ;//symbol counter
.txt_lp1
        ld a,(hl)
        cp 32+1 
        jr c, _txtout_controlcode

        ;copy string yo buffer
        ld (de),a
        inc hl
        inc de
        inc c
        jr .txt_lp1







_txtout_controlcode:
        push af
                ;check if buffer overflow   
                ld a,c
                and a
                jr z,_txtout_cc_sp_tk   ;buffer is empty. attempt to print space or token

                ;buffer not empty. print string
                ld bc,(CORDS_P)           ;B-y C-X
                add a,c
                cp print_p_len
                jr nc,_ttout_overflow

                call _print_txt_buf_p
        pop af
        jp _txtout2        
                                                                        
                                                                        
                                         
;buffer is empty. attempt to print space or token      AF in stack
_txtout_cc_sp_tk:
        pop af   ;restore curren symbol

        inc hl;!!!!!!!!!!!!

        cp 32
        jr nz,_txtout_cc_token  ;char is token
        ; print space
        ld bc,(CORDS_P)
        ld a,c          ;check for overflow
        inc a
        cp print_p_len
        jr nc,_ttout_overflow1  ;not restore af
        ld a,32
        ld (de),a
        call _print_txt_buf_p
        jp _txtout2
        
        
_ttout_overflow:
         pop af
_ttout_overflow1:
        ld bc,(CORDS_P)
        inc b
        ld c,x_txt_coor
        call _pradd_p

        ld bc,(CORDS_P)
    	LD A,B
    	CP #17
    	 CALL NC,     WINCLR1                                                                                                                           

        call _print_txt_buf_p
        jr _txtout2
    
_txtout_cc_token:
        and a
        jr nz,_tt_opcodes1
        push hl
        call WINCLR1
        pop hl
        jp _txtout2


_tt_opcodes1:
	  CP 2
	  JP Z,_exitdark
      cp 4 
	  JP Z,_exitlight
	  CP 1
	  JP Z,_scenario
	  CP 3
	  JP Z,_menu_s

	 LD A,4
	 OUT (#FE),A
        jp $


_print_txt_buf:
            push hl
                    ld hl,txt_buff
                    call _type_txt_buf
                    call clear_txt_buff
            pop hl
            ret

_type_txt_buf:
            ld a,(hl)
            and a
            ret z
        	CP 128
        	CALL NC,change_cp
            sub 32
            push hl
            call _type
            pop hl
            inc hl
            jr _type_txt_buf

_print_txt_buf_p:
            push hl
                    ld hl,txt_buff
                    call _type_txt_buf_p
                    call clear_txt_buff
            pop hl
            ret

_type_txt_buf_p:
            ld c,1
.l1
            ld a,(hl)
            and a
            ret z
      ;  	CP 128
       ; 	CALL NC,change_cp
     ;       sub 32
            push hl
            call _type_p
            pop hl
            inc hl
            jr .l1

clear_txt_buff:
        push bc,de
        xor a
        ld b,64
        ld de,txt_buff
.lp1
        ld (de),a
        inc de
        djnz .lp1
        pop de,bc
        ret
        



txt_buff: ds 64,0

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
        include "dzx0b.asm"


        align 256
font_buf ds 16,0
        align 256
PUSH_DATA:  ds 256,0  ;//wait animation
t_s98_file00_pages_list:  ds 256,0

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

;buf_ext             ds 538-(buf_ext-txt_setup),0

cmd_end:        

	display "main.com free space ",/d,GLOBVARS-buf," bytes"



	display "main.com length ",/d,main_end-cmd_begin," bytes"
	display "gf_func length ",/d,gf_func_end-gf_func_start," bytes"
	display "sub_func length ",/d,sub_func_end-sub_func_start," bytes"
	display "sub_vars length ",/d,sub_vars_end-sub_vars_start," bytes"
	display "sub_dsk length ",/d,sub_dsk_end-sub_dsk_start," bytes"
	display "sub_variables length ",/d,sub_variables_end-sub_variables_start," bytes"

	display "buf lenght",/d,cmd_end-buf," bytes"


        savebin "BOD.com",cmd_begin,cmd_end-cmd_begin
        LABELSLIST "..\..\..\us\user.l",1