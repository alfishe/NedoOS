        	ORG 0x4000
page4000begin:
pre_intro:
		ld a,(menu_mus)
		call load_mus
		
        ld hl,menu_pic_btm
		call store_name
        call load_big_img_dark2
        call palette_precalc_sub
        call fade_fromblack

		call load_bgnd_anim
		
		ld de,0
		ld bc,0x0150
.loop
		halt
        call getkey
        cp NOKEY

		jp nz,.pre_intro_exit
		inc de
		push de
		pop hl
		and a
		sbc hl,bc
		jr nz,.loop

.lop_ext
		xor a
		ld (alock),a
		
	;1 - copy screen to mem buf
		call store8000c000
		
		ld a,(user_scr0_low)
		SETPG8000
        ld a,(mem_buf3)
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
        ld a,(mem_buf4)
        SETPGC000
		ld hl,0x8000
		ld de,0xc000
		ld bc,8000
		ldir
		ld hl,0xa000
		ld de,0xe000
		ld bc,8000
		ldir

		call restore8000c000
		
	;2 - load new image to mem2 buf

        ld hl,menu_pic_top
		call store_name
		call load_gfx_to_mem_buf

	;3 call screen scrool
		call _scr_move_fullscreen_up
		
		call load_bgnd_anim
		
		ld de,0
		ld bc,0x00a8
.loop2
		halt
        call getkey
        cp NOKEY

		jp nz,.pre_intro_exit
		inc de
		push de
		pop hl
		and a
		sbc hl,bc
		jr nz,.loop2


		ld hl,ROGOL
        call load_gfx_to_load_buf
        call _immed_overlay_big_routine
		
		;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		;>> here we should wait for tune end
		
		call storec000
		ld a,(plr_page)
		SETPGC000
.wait_mus_end		
        call getkey
        cp NOKEY
		jp nz,.pre_intro_exit2
		ld a,(0xc200) ;(0x4200)
		cp 0xc9
		jr nz,.wait_mus_end
.pre_intro_exit2
		call restorec000
.pre_intro_exit
		xor a
		ld (alock),a
		call fade_toblack
		jp no_mus
;<===================================================
mainMenu:
        ld hl,opening_pic2
        call load_big_img_dark2
        call palette_precalc_sub
        call fade_fromblack

        ld a,(user_scr0_low) ;ok
        SETPG8000
        ld a,(user_scr0_high) ;ok
        SETPGC000
		
mainMenu1:
        ld hl,loc_main_menu
        ld de,menu_main_action

        push de
        ld a,(language)
        call sel_word

        call _menu_pre_setup
		push hl
		call clear_menu_box
		pop hl
		call _prt_menu
		
._mmnu_r1
        call _sel_menu_main
        cp 0xff
        jr z,._mmnu_r1 ;block esc
        pop hl
        call sel_word
        jp (hl)


_loadgame
        ld hl,loc_load_menu_b
        ld de,menu_load_action

        push de
        ld a,(language)
        call sel_word

        call _menu_pre_setup
		push hl
		call clear_menu_box
		pop hl
        call _prt_menu

        call _sel_menu_main
        pop hl

        cp 0xff
        jp z,mainMenu1

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

		ld (start_mode),a
        add a,"0"
        ld (SAVETEMPL_N),a
        ld de,SAVETEMPL
        call openstream_file
        or a
		jp nz,_loadgame		
		jp closestream_file
		
;==================================================================
_newgame:
		call fade_toblack
		
		call clear_whole_screen
		
		ld a,(opening_mus)
		call load_mus
		
		ld hl,opening_pic1
        call load_gfx_to_load_buf
		call showpalz
		halt
		
		
		;clear global variables
		xor a
		LD HL,GLOBVARS
        LD B,A
        LD (HL),A
        INC HL
        DJNZ $-2
		
		call _set_clear_box_intro
		call _set_box_anim_intro
		
		ld a,print_p_len
		ld (_print_b.set_pLen),a
		ld bc ,txt_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p
		
		
		ld a,(language)
		ld hl,script_part1
		call sel_word
		call _print_b
		
		xor a
		ld (wlock),a
		
		
		ld hl,opening_pic2
        call load_big_img_dark2
		call _immed_big_core
		
		xor a
		ld (cur_question),a
.q_loop		

		ld a,questions_p_len
		ld (_print_b.set_pLen),a
		
		ld bc ,txt_coor_questions
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p		
		


		
		call clear_menu_box
		
		
		ld a,(cur_question)
		ld hl,q_table
		call sel_word
        ld a,(language)
        call sel_word
		call _print_b


		ld a,(cur_question)
		ld hl,a_table
		call sel_word
		

        ld a,(language)
        call sel_word

        call _menu_pre_setup

        call _prt_menu
.orto
        call _sel_menu_main


        cp 0xff
        jp z,.orto

		push af
        ld a,(cur_question)
		inc a
		ld l,a
		ld h,HIGH GLOBVARS
		pop af
		ld (hl),a
		
		ld a,(cur_question)
		cp 9
		jr z,.all_q_done
		inc a
		ld (cur_question),a
		jp .q_loop
		
.all_q_done
		call clear_whole_screen

		ld a,print_p_len
		ld (_print_b.set_pLen),a
		ld bc ,txt_coor_intro
		ld (COOOR+1),bc
		ld a,c
		ld (x_txt_coor),a
        call _pradd_p

		ld a,(language)
		ld hl,script_part2
		call sel_word
		call _print_b		
		
		xor a
		ld (wlock),a
		
		ld a,0xff
		ld (start_mode),a
		ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<		
cur_question db 0
;===========================================clear_status_bar:
clear_menu_box:
        ld hl,0x800e+3*320-4
        ld b,140-24-32
        ld c,16+5
		call clear_uni
        ld hl,0xc00e+3*320-4
        ld b,140-24-32
        ld c,16+5
clear_uni:
        ld a,b
        ld (clear_uni_s.c2a),a
        ld (clear_uni_s.c2b),a

        ld a,c
        ld (clear_uni_s.c3a),a
        ld (clear_uni_s.c3b),a

        ld (clear_uni_s.c1a),hl
        set 5,h
        ld (clear_uni_s.c1b),hl
        jp clear_uni_s

		
		

clear_uni_s:    
       LD HL,0
.c1a   equ $-2        
       LD B,0
.c2a   equ $-1     
        XOR A
.c0l:
        PUSH HL
        LD C,0
.c3a    equ $-1    
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ .c0l

        LD HL,0
.c1b:   equ $-2
        LD B,0
.c2b equ $-1   
        XOR A
.c1l:   PUSH HL
        LD C,0
.c3b equ $-1
        LD (HL),A
        INC HL
        DEC C
        JR NZ,$-3
        POP HL
        LD DE,40
        ADD HL,DE
        DJNZ .c1l
        ret
		
;===========================================
_sel_menu_main:
        ld a,0
CUR_POS EQU $-1 

        ld hl,MENUCURHELPER_MAINMNU
        call sel_word
        ld (SELSo4),hl

        call show_hand

		
		
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
        ld hl,(SELSo4)
        call restore_hand
        ld hl,CUR_POS
        ld a,(hl)
        cp 0
DOWN_LIMIT EQU $-1        
        jp nc,_sel_menu_main
        inc (hl)
        jp _sel_menu_main

_sel_move_up
        ld hl,(SELSo4)
        call restore_hand
        ld hl,CUR_POS
        ld a,(hl)
        and a
        jp z,_sel_menu_main
        dec (HL)
        jp _sel_menu_main
_sel_sel_key:
        ld hl,(SELSo4)
;        call _highlight_selected
        call restore_hand
        ld a,(CUR_POS)
        ret
_sel_esc_key:
SEL_L   
        ld hl,(SELSo4)
;        call _highlight_selected
        call restore_hand
        ld a,0xff
        ret
;===========================================
restore_hand:
        push hl,bc,de
        ld de,CUR_BGND_STORE
        
        ld hl,(SELSo4)
        ld b,2
        ld c,16

.lp0:
        push bc

        push hl
        ld b,c;16
.lp1:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz .lp1
        pop hl
        set 6,H

        push hl
        ld b,c;16
.lp2:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz .lp2
        pop hl
        res 6,H
        set 5,H

        push hl
        ld b,c;16
.lp3:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz .lp3
        pop hl
        set 6,H
        
        push hl
        ld b,c;16
.lp4:
        ld a,(de)
        ld (hl),a
        call DHL
        inc de
        djnz .lp4

        pop hl
        res 6,H
        res 5,H
        inc hl

        pop bc
        djnz .lp0

        pop de,bc,hl        
		ret 
  
show_hand:
; hl - sprite position
        push hl,bc,de        
        ld de,CUR_BGND_STORE
        push hl        
        call import_cursor_uni
        pop hl
    
        ld de,CUR_DATA
        ;hl - cursor screen addr
        ;de - cursor data
        ld b,2
        ld c,16
        call export_cursor_uni  
        pop de,bc,hl 
		ret
;;;;
MENUCURHELPER_MAINMNU:		;hand position addresses
	dw 0x8aae-80 							; 0x96df;+40 ; 0x9902+80-320-320
	dw 0x8aae+320-80  						;0x981f;+40 ;0x9902+80-320
	dw 0x8aae+320+320-80					;0x995f;+40   ;0x9902+80
	dw 0x8aae+320+320+320-80					;0x9a4f;+40  ;0x9902+320
	dw 0x8aae+320+320+320+320-80


;===========================================
_menu_pre_setup
        ld a,(hl);string length
        ld (_line_lenght),a
		
;^^^^^^^^^^^^^^^^^^^^^^^^^^
;                inc a
;                inc a
;                add a,a 
;                add a,a
;                ;add a,a
;                dec a
;        ld (__d_m_box_len),a
;^^^^^^^^^^^^^^^^^^^^^^^^^^
		
		

        inc hl 
        ld a,(hl)
        ld (DOWN_LIMIT),a
		
		
;^^^^^^^^^^^^^^^^^^^^^^^^^^
;                inc a
;                inc a
;                add a,a ;x2
;                add a,a ;x4
;                add a,a ;x8
;                dec a
;                ld  (__d_m_box_hgt),a
;^^^^^^^^^^^^^^^^^^^^^^^^^^				
				
        inc hl 
        push hl
        xor a
        ld (CUR_POS),a
        LD HL,#0817
        LD (_mnpos),HL
        pop hl
        ret
		
;=====================
_prt_menu
        ld bc,0
_mnpos: equ $-2        
        call _pradd_p
.m1:
        ld a,(hl)
        inc hl
        and a
        RET Z
        cp 1
        JR Z,.m2
        PUSH HL
        CALL _type_p
        POP HL
        JR .m1
.m2:
        LD A,(_mnpos+1)
        INC A
        LD (_mnpos+1),A
        JR _prt_menu
;===================
;///////////////////////////////////////////
_immed_overlay_big_routine:
        call store8000c000

        ld a,(load_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000        

        ld hl,0xc000
        ld de,0x8000
        ld bc,16384

        call _iob

        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000  

        ld hl,0xc000 ;dest
        ld de,0x8000 ;src
        ld bc,16384

        call _iob

        jp restore8000c000    
;///////////////////////////////////////////		
_iob
._iob_loop        
        call _iob_byte
        inc de
        inc hl
        dec bc
        ld a,b
        or c
        jr nz,._iob_loop
        ret
;///////////////////////////////////////////
_scr_move_fullscreen_up
        ;*** copy screen to second screen
        call store8000c000
		
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
		
        xor a
        ld (active_scr),a

        ld hl,0x8000+(200*40)	;0x8005+5920; second line  0x8005+(148*40)
        ld (s_move_adr1),hl
        ld a,0
        ld (s_move_lines1),a
        ld a,200   ;148
        ld (s_move_lines2),a
        ld hl,-80  ;-40
        ld a,0x3c          ;inc a
        ld b,0x3d          ;dec a 
;_scr_move_ud:        
        ld (.offs40),hl
        ld (.sp_opc1-1),a
        ld (.sp_opc1),a
        ld a,b
        ld (.sp_opc2-1),a
        ld (.sp_opc2),a
                ;ld hl,0xc005+320 всегда!!!
        ld b,200/2+1    ;101  -> previously    148/2+1 ;149
.lp0:
        push bc

		call set_scr_low

		ld a,(mem_buf1)
		SETPG8000

		ld hl,(s_move_adr1)
		ld de,0xc000    ; previously 0xc005+320         ;screen

		ld a,(s_move_lines1)
		ld b,a
		push hl,de
		call copy_i_line_fullscreen
		pop de,hl

		set 5,h
		set 5,d

		ld a,(s_move_lines1)
		ld b,a
		call copy_i_line_fullscreen

		push de
		ld a,(mem_buf3)
		SETPG8000                        
		ld hl,0xa000   ; previously 0xa005   ;always -begin of secondimage
		pop de

		ld a,(s_move_lines2)
		ld b,a
		push hl,de
		call copy_i_line_fullscreen
		pop de,hl

		res 5,h
		res 5,d

		ld a,(s_move_lines2)
		ld b,a
		call copy_i_line_fullscreen




		call set_scr_high

		ld a,(mem_buf2)
		SETPG8000
		ld hl,(s_move_adr1)
		ld de,0xc000  ;previously 0xc005+320         ;screen
		ld a,(s_move_lines1)
		ld b,a

		push hl,de
		call copy_i_line_fullscreen
		pop de,hl
		set 5,h
		set 5,d

		ld a,(s_move_lines1)
		ld b,a
		call copy_i_line_fullscreen

		push de

		ld a,(mem_buf4)
		SETPG8000                        
		
		ld hl,0xa000 ; previously 0xa005
		pop de
		ld a,(s_move_lines2)
		ld b,a

		push hl,de
		call copy_i_line_fullscreen
		pop de,hl
		res 5,h
		res 5,d

		ld a,(s_move_lines2)
		ld b,a
		call copy_i_line_fullscreen


        halt
        ld a,(active_scr)
        and a
        jr nz,.spl1
        
        ; active scr 0 ; show 2nd screen . set active scr1
        inc a
        ld (active_scr),a
        ld e,a
        OS_SETSCREEN
        jr .spl0
.spl1:        
        ; active scr 1 ; show 1nd screen . set active scr 0
        dec a
        ld (active_scr),a
        ld e,a
        OS_SETSCREEN



.spl0:
        ld a,(s_move_lines1)
        dec a
        dec a
.sp_opc1: equ $-1        
        ld (s_move_lines1),a
        ld a,(s_move_lines2)
        inc a
        inc a
.sp_opc2: equ $-1        
        ld (s_move_lines2),a


        ld hl,(s_move_adr1)
        ld bc,40
.offs40 equ $-2        
        add hl,bc
        ld (s_move_adr1),hl
        pop bc
        dec b
        jp nz,.lp0

        ld a,(active_scr)
        and a 
        jr  z,.spl11
        ;copy scr1 to scr0

        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr1_low)
        SETPGC000
		
		ld hl,0xc000
		ld de,0x8000
		ld bc,8000
		ldir
		ld hl,0xe000
		ld de,0xa000
		ld bc,8000
		ldir		


        ld a,(user_scr0_high)
        SETPG8000
        ld a,(user_scr1_high)
        SETPGC000

		ld hl,0xc000
		ld de,0x8000
		ld bc,8000
		ldir
		ld hl,0xe000
		ld de,0xa000
		ld bc,8000
		ldir		

.spl11:
        ld e,0
        OS_SETSCREEN

        jp restore8000c000 

;<--------------------
copy_i_line_fullscreen:

        ld a,b
        and a
        ret z
.lp:
        push bc
        call _ldi_40_noeob
        pop bc 
        djnz .lp
        ret  
;<======================		





		
		
		
		
;///////////////////////////////////////////
_immed_big_core:
        ld a,1
        ld (setpalflag),a
        call store8000c000
        halt

        ld a,(load_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000
        ld hl,0x8000
        ld de,0xc000
        ld bc,8000
        ldir

        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0x8000
        ld de,0xc000
        ld bc,8000
        ldir

        ld a,(load_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000
        ld hl,0xa000
        ld de,0xe000
        ld bc,8000
        ldir

        ld a,(load_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0xa000
        ld de,0xe000
        ld bc,8000
        ldir

        jp restore8000c000
;///////////////////////////////////////////

palette_precalc_sub:
                ld hl,pal
                ld de,pal_rgb

                ld b,16
mkpalATM3RGB
                push bc
                ld a,(hl)
                inc hl
                push hl
                ld h,(hl)
                ld l,a
                push de

                call calchexcolor ;hl=color (DDp palette) ;out: ;b=B, d=R, e=G

                ld a,e ;G
                add a,a
                add a,a
                add a,a
                add a,a
                or d ;R
                pop de
                ld c,a ;GR
                ld a,b
                add a,a
                add a,a
                add a,a
                add a,a
                ld (de),a ;B0
                inc de
                ld a,c
                ld (de),a ;GR
                inc de
                pop hl
                inc hl
                pop bc
                djnz mkpalATM3RGB
                ret

calchexcolor ;hl=color (DDp palette) ;out: ;b=B, d=R, e=G
;keep c!!!
;DDp palette: %grbG11RB(low),%grbG11RB(high)
;high B, high b, low B, low b
                ld b,0;0xff
                ld de,0;0xffff
                ld a,h
               cpl
                rra
                rl b ;B high
                rra
                rl d ;R high
                rra
                rra
                rra
                rl e ;G high
                rra
                rl b ;b high
                rra
                rl d ;r high
                rra
                rl e ;g high
                ld a,l
               cpl
                rra
                rl b ;B low
                rra
                rl d ;R low
                rra
                rra
                rra
                rl e ;G low
                rra
                rl b ;b low
                rra
                rl d ;r low
                rra
                rl e ;g low
;b=B
;d=R
;e=G
        ret


;===================
recolour
;hl=palfrom (RGB)
;de=palto (DDp)
;lx=brightness=0..15
        di
        ld (recoloursp),sp
        ld sp,hl
       ld h,tbright/256 ;once
        ld hx,16
bripalATM3
         ;ld a,(hl) ;B0
         ;inc hl
         ;push hl
         ;ld b,(hl) ;GR
       pop bc
       ld a,c
         ;ld h,tbright/256
;de=palto
;h=tbright/256
;lx=brightness
;a,b = B0,GR
         add a,lx
        ld l,a
        ld c,(hl) ;B colour component with brightness
        ld a,b
        and 0xf0
         add a,lx
        ld l,a
        ld a,b
        ld b,(hl) ;G colour component with brightness
        add a,a
        add a,a
        add a,a
        add a,a
         add a,lx
        ld l,a
        ld l,(hl) ;R colour component with brightness

       ld a,b ;G
       rlca ;g??G???? ;G10
       xor l ;R
       and 0b10010000;0b01000010 ;R10
       xor l;gr?G??R?
       rlca ;r?G??R?g
       xor c ;B
       and 0b10100101;0b01000010 ;B10
       xor c;rbG??RBg
       rrca ;grbG??RB
        or 0b00001100 ;unused bits
        ld (de),a ;low %grbG11RB
        inc de ;TODO ld (),a

       ld a,b ;G
       rlca ;?g??G??? ;G32
       xor l ;R
       and 0b01001000;0b00100001 ;R32
       xor l;?gr?G??R
       rlca ;gr?G??R?
       xor c ;B
       and 0b11010010;0b00100001 ;B32
       xor c;grbG??RB
        or 0b00001100 ;unused bits
        ld (de),a ;high %grbG11RB
        inc de ;TODO ld (),a

         ;pop hl
         ;inc hl
         dec hx
         jp nz,bripalATM3 ;TODO dup..edup
recoloursp=$+1
        ld sp,0
        ei
        ret
;===================
  ;#DD #2C      INC  IXL           #FD #2C       INC  IYL
 ; #DD #2D      DEC  IXL



fade_to_sub:
        ld (fade_tocolor),a
        ld (fade_to_op),hl

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;

        call palette_precalc_sub

        ld lx,8
fade0
        dec lx
fade_to_op: equ $-2
        ld hl,pal_rgb
        ld de,pal
        call recolour
        push ix

	ld a,1
	ld (setpalflag),a

	halt
	halt
;	halt
        pop ix
        ld a,lx
        cp 0
fade_tocolor: equ $-1
        jr nz,fade0
	halt
	halt
;	halt
        ret

fade_from_sub:
        ld (fade_fromcolor),a
        ld (fade_from_op),hl


        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir        ;;


        call palette_precalc_sub

        ld lx,15
fade_fromcolor: equ $-1


fadew1:
        dec lx
fade_from_op: equ $-2
        ld hl,pal_rgb
        ld de,pal
        call recolour
        push ix

	ld a,1
	ld (setpalflag),a

	halt
	halt
;	halt
        pop ix
        ld a,lx
        cp 8
        jr nz,fadew1
	halt
	halt
;	halt

        ld hl,temppal
        ld bc,32
        ld de,pal
        ldir
	ld a,1
	ld (setpalflag),a
        halt
        ret

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


        include "ayfxplay.asm";///////////////////////////////////////////
sfxdata     
        incbin "tngogo_sfx.afb"        
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
loc_main_menu:
        dw menu_main_eng
        dw menu_main_rus
loc_load_menu_b:        
        dw menu_load_eng_b
        dw menu_load_rus_b


menu_main_eng:
          db 8,2  ;max len in CHR (symbols x2) , num strings in menu - 1
		  DB "     LOAD",1
          DB " START GAME",1
          DB "     QUIT",0
menu_main_rus:
          db 10,2  ;max len, num strings in menu - 1
		  DB " ЗАГРУЗИТЬ ИГРУ",1
          DB "  НОВАЯ  ИГРА",1
          DB " ВЫЙТИ ИЗ ИГРЫ",0


menu_main_action:
          dw _loadgame
          dw _newgame
          dw _gamequit
;====

menu_load_eng_b :
          db 6,4  ;max len, num strings in menu - 1
          DB " LOAD 1   ",1
          DB " LOAD 2   ",1
          DB " LOAD 3   ",1
          DB " LOAD 4   ",1
		  DB " LOAD 5   ",0
menu_load_rus_b:
          db 8,4  ;max len, num strings in menu - 1
          DB " ЗАГРУЗИТЬ  1 ",1
          DB " ЗАГРУЗИТЬ  2 ",1
          DB " ЗАГРУЗИТЬ  3 ",1
          DB " ЗАГРУЗИТЬ  4 ",1
          DB " ЗАГРУЗИТЬ  5 ",0

;------------------------------------------
q_table:
		dw loc_Q1
		dw loc_Q2
		dw loc_Q3
		dw loc_Q4
		dw loc_Q5
		dw loc_Q6
		dw loc_Q7
		dw loc_Q8
		dw loc_Q9
		dw loc_Q10

a_table:
		dw loc_A1
		dw loc_A2
		dw loc_A3
		dw loc_A4
		dw loc_A5
		dw loc_A6
		dw loc_A7
		dw loc_A8
		dw loc_A9
		dw loc_A10




loc_Q1
        dw txt_q1_eng
        dw txt_q1_rus
loc_Q2
        dw txt_q2_eng
        dw txt_q2_rus
loc_Q3
        dw txt_q3_eng
        dw txt_q3_rus
loc_Q4
        dw txt_q4_eng
        dw txt_q4_rus
loc_Q5
        dw txt_q5_eng
        dw txt_q5_rus
loc_Q6
        dw txt_q6_eng
        dw txt_q6_rus
loc_Q7
        dw txt_q7_eng
        dw txt_q7_rus
loc_Q8
        dw txt_q8_eng
        dw txt_q8_rus
loc_Q9
        dw txt_q9_eng
        dw txt_q9_rus
loc_Q10
        dw txt_q10_eng
        dw txt_q10_rus


loc_A1
        dw txt_a1_eng
        dw txt_a1_rus
loc_A2
        dw txt_a2_eng
        dw txt_a2_rus
loc_A3
        dw txt_a3_eng
        dw txt_a3_rus
loc_A4
        dw txt_a4_eng
        dw txt_a4_rus
loc_A5
        dw txt_a5_eng
        dw txt_a5_rus
loc_A6
        dw txt_a6_eng
        dw txt_a6_rus
loc_A7
        dw txt_a7_eng
        dw txt_a7_rus
loc_A8
        dw txt_a8_eng
        dw txt_a8_rus
loc_A9
        dw txt_a9_eng
        dw txt_a9_rus
loc_A10
        dw txt_a10_eng
        dw txt_a10_rus
;----------------------------------------------------------
txt_q1_eng: db "Do you prefer someone older or younger?",0x1f,0
txt_q1_rus: db "Кого ты предпочитаешь — старше тебя или младше?",0x1f,0

txt_q2_eng: db "If you could be alone with your girlfriend, would you prefer a bright place or a dark place?",0x1f,0
txt_q2_rus: db "Если бы вы остались наедине с девушкой, предпочёл бы светлое место или тёмное?",0x1f,0

txt_q3_eng: db "Have you ever made your girlfriend cry?",0x1f,0
txt_q3_rus: db "Было ли такое, что ты заставил свою девушку плакать?",0x1f,0

txt_q4_eng: db "Do you prefer long or short hair?",0x1f,0
txt_q4_rus: db "Какие волосы тебе нравятся - длинные или короткие?",0x1f,0

txt_q5_eng: db "Which do you prefer, a cheerful girl or a shy girl?",0x1f,0
txt_q5_rus: db "Какая девушка тебе по душе — открытая или застенчивая?",0x1f,0

txt_q6_eng: db "Could you love a girl you've been with once for your whole life?",0x1f,0
txt_q6_rus: db "Смог бы ты всю жизнь любить девушку, с которой был близок лишь однажды?",0x1f,0

txt_q7_eng: db "Which do you choose, desire or duty?",0x1f,0
txt_q7_rus: db "Что для тебя важнее — долг или желание?",0x1f,0

txt_q8_eng: db "Which do you prioritize, love or friendship?",0x1f,0
txt_q8_rus: db "Что ты поставишь на первое место — любовь или дружбу?",0x1f,0

txt_q9_eng: db "If a girl were in trouble, would you help her?",0x1f,0
txt_q9_rus: db "Если девушка окажется в беде, поможешь ли ты ей?",0x1f,0

txt_q10_eng: db "Which is more important, love or money?",0x1f,0
txt_q10_rus: db "Что для тебя важнее — любовь или деньги?",0x1f,0

txt_a1_eng: db 4,1
            db " Younger ",1
            db " Older   ",0
txt_a1_rus: db 3,1
            db " Младше",1
            db " Старше",0


txt_a2_eng: db 3,1
            db " Dark  ",1
            db " Bright",0
txt_a2_rus: db  7,1
            db " Тёмное место  ",1
            db " Светлое место ",0
           

txt_a3_eng: db 2,1
            db " No  ",1
            db " Yes ",0
txt_a3_rus: db 2,1
            db " Нет ",1
            db " Да ",0
                   
           
txt_a4_eng: db 3,1
            db " Long  ",1
            db " Short ",0
txt_a4_rus: db 4,1
            db " Длинные ",1
            db " Короткие",0   
               

          
txt_a5_eng: db 4,1
            db " shy     ",1
            db " Cheerful",0
txt_a5_rus: db 6,1
            db " Застенчивая ",1
            db " Открытая    ",0
               

          
txt_a6_eng: db 5,1
            db " I couldn't",1
            db " I could   ",0
txt_a6_rus: db 5,1
            db " Не смог бы",1
            db " Смог бы   ",0
               
          
txt_a7_eng: db 3,1
            db " Duty  ",1
            db " Desire",0
txt_a7_rus: db 4,1
            db " Долг    ",1
            db " Желание ",0
               

          
txt_a8_eng: db 5,1
            db " Friendship",1
            db " Love      ",0
txt_a8_rus: db 3,1
            db " Дружба",1
            db " Любовь",0
               

          
txt_a9_eng: db 7,1
            db " Wouldn't help ",1
            db " Would help    ",0
txt_a9_rus: db 5,1
            db " Не помогу ",1
            db " Помогу    ",0
               
           
txt_a10_eng: db 3,1       
             db " Money ",1
             db " Love  ",0
txt_a10_rus: db 3,1
             db " Деньги",1
             db " Любовь",0
                



script_part1:
             dw sc_ip1_eng
             dw sc_ip1_rus
script_part2:
             dw sc_ip2_eng
             dw sc_ip2_rus



sc_ip1_eng:
		db 0x1F,1	;clear whole screen
        db "[%001]: ...Hmm hmm hmm hmm hmm...",0x1F,3
        db "[%001]: Date, date, tra-la-la-la-la...",0x1F,3
        db "[%001]: ...Hm? What's this?",0x1F,3
        db "[%001]: Was there always something like this here...? Oh well. I have time, so maybe I'll stop by for a bit.",0x1F,3
		db 0x1F,2	;show opening screen and draw box
        db "[Fortune Teller]: Welcome... This is the hall where you can glimpse the future.",0x1F,3
        db "[%001]: ...Well, that's pretty standard.",0x1F,3
        db "[Fortune Teller]: Did you say something?",0x1F,3
        db "[%001]: No, nothing in particular...",0x1F,3
        db "[Fortune Teller]: That's fine. Please, have a seat there.",0x1F,3
        db "[%001]: ...Alright, alright.",0x1F,3
        db "[Fortune Teller]: ...So, what kind of future do you wish for?",0x1F,3
        db "[%001]: A bright family plan with you, miss.",0x1F,3
        db "[Fortune Teller]: ......",0x1F,3
        db "[%001]: ...Just kidding.",0x1F,3
        db "[Fortune Teller]: ...Hmph, fine.",0x1F,3
        db "[Fortune Teller]: Listen... From now on, questions will appear in this crystal ball.",0x1F,3
        db "[Fortune Teller]: Only you can see these questions. So, write the questions and your answers on this paper.",0x1F,3
        db "[Fortune Teller]: When the questions stop, show me the paper. Then, you will be able to know your future.",0x1F,3
        db "(To know the future, huh...)",0x1F,3
        db "[Fortune Teller]: Come on, hurry up.",0x1F,3
        db "[%001]: Ah... okay, okay.",0x1F,3
		dw 0x1F,0
sc_ip2_eng:
		db 0x1F,2	;show opening screen and draw box
        db "[%001]: ...Yes.",0x1F,3
        db "[Fortune Teller]: Let's see... Hmm, I see...",0x1F,3
        db "[Fortune Teller]: Your future is that of a playboy.",0x1F,3
        db "[%001]: Sigh...",0x1F,3
        db "[Fortune Teller]: Isn't that perfect for a lady's man like you?",0x1F,3
        db "[%001]: ...Yeah, is that so...",0x1F,3
        db "[Fortune Teller]: ...Oh, I forgot to mention one thing.",0x1F,3
        db "(...There's still more?)",0x1F,3
        db "[Fortune Teller]: Someone important to you is in danger. Only you can save them. Remember that well.",0x1F,3
        db "[%001]: ...I see. Thanks, I guess...",0x1F,3
		db 0x1F,1
        db "[%001]: ...Phew. How long was I in there...? Hey!",0x1F,3
        db "[%001]: Oh crap! I'm late!!",0x1F,3
        db "I dashed toward the station at full speed.",0x1F,3
		dw 0x1F,0
sc_ip1_rus:
		db 0x1F,1	;clear whole screen
        db "[%001]: ...хм-хм-хм-хм...",0x1F,3
        db "[%001]: Свидание, свидание, тра-ля-ля-ля-ля-ля...",0x1F,3
        db "[%001]: ... Хм? Что это тут такое?",0x1F,3
        db "[%001]: Интересно, всегда ли тут было что-то подобное?.. Ну да ладно. Времени хватает, загляну-ка я ненадолго.",0x1F,3
		db 0x1F,2
        db "[Гадалка]: Добро пожаловать... Здесь находится обитель, где можно заглянуть в будущее.",0x1F,3
        db "[%001]: ...Ну да, как и положено по сценарию.",0x1F,3
        db "[Гадалка]: Ты что-то сказал?",0x1F,3
        db "[%001]: Нет, ничего особенного...",0x1F,3
        db "[Гадалка]: Ну и хорошо. Прошу, садись вот сюда.",0x1F,3
        db "[%001]: ...Ладно-ладно.",0x1F,3
        db "[Гадалка]: ...Итак, какое будущее ты бы хотел увидеть?",0x1F,3
        db "[%001]: Светлое семейное будущее с вами, барышня.",0x1F,3
        db "[Гадалка]: ......",0x1F,3
        db "[%001]: ...Шучу.",0x1F,3
        db "[Гадалка]: ...Хм, ну да ладно.",0x1F,3
        db "[Гадалка]: Слушай внимательно... Сейчас в этом хрустальном шаре начнут появляться вопросы.",0x1F,3
        db "[Гадалка]: Эти вопросы сможешь видеть только ты. Поэтому ты должен записать их и свои ответы на этом листке бумаги.",0x1F,3
        db "[Гадалка]: Когда вопросы закончатся, покажи мне этот лист. Тогда ты узнаешь своё будущее.",0x1F,3
        db "('Узнать будущее', говоришь...)",0x1F,3
        db "[Гадалка]: Ну что, давай, не тяни.",0x1F,3
        db "[%001]: А, да-да...",0x1F,3
		db 0x1F,0
sc_ip2_rus:
		db 0x1F,2	;show opening screen and draw box
        db "[%001]: ...Да.",0x1F,3
        db "[Гадалка]: Ну-ка, посмотрим... Хм-хм, вот как...",0x1F,3
        db "[Гадалка]: Твоё будущее - быть ловеласом.",0x1F,3
        db "[%001]: Эх...",0x1F,3
        db "[Гадалка]: Для такого любителя женщин, как ты, самое то, не правда ли?",0x1F,3
        db "[%001]: ... Да уж, вот так новость...",0x1F,3
        db "[Гадалка]: ... Ах да, чуть не забыла сказать.",0x1F,3
        db "(... Неужели ещё что-то?)",0x1F,3
        db "[Гадалка]: Того, кто тебе дорог, подстерегает опасность. И только ты сможешь спасти этого человека. Не забудь об этом..",0x1F,3
        db "[%001]: ... Понятно. Спасибо, наверное...",0x1F,3
		db 0x1F,1
        db "[%001]: ... Фух. Интересно, сколько времени я там просидел... Эй!",0x1F,3
        db "[%001]: Вот чёрт! Я же опаздываю!!",0x1F,3
        db "Я со всех ног бросился к станции.",0x1F,3
		db 0x1F,0
;==================================================
PARSER_EXIT:
		ret
gameover_message_tbl:
		dw _go_mes_eng
		dw _go_mes_rus
_go_mes_eng:	DB "GAME OVER",0x1F,3,0x1F,0		
_go_mes_rus:	DB "КОНЕЦ ИГРЫ",0x1F,3,0x1F,0

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


clear_big_screen
		push hl,bc,de,af
		call clear_whole_screen
		
		ld a,31
		ld (__d_m_box_hgt),a
		ld a,132
		ld (__d_m_box_len),a
		call _draw_menu_box
		
		pop af,de,bc,hl
		;inc hl
		jp _print_b

show_opening_screen
		push hl
		ld hl,opening_pic1
        call load_big_img_dark2
		call _immed_big_core
		ld a,31
		ld (__d_m_box_hgt),a
		ld a,132
		ld (__d_m_box_len),a
		call _draw_menu_box
		call  _clear_textbox
		pop hl
		jp _print_b



_draw_menu_box:
        push hl
		call store8000c000
        ld a,(user_scr0_low) ;ok
        SETPG8000
        ld a,(user_scr0_high) ;ok
        SETPGC000

        ld l,14;64-8
        ld e,164 ;140
		
        ld lx,0b11111111	;0b11001001 ;fill color byte 0bRLrrrlll
        ld hx,0b00000000 ;11111111 ;brush color byte 0bRLrrrlll
        ld b,0 ;hgt-1
__d_m_box_hgt: equ $-1
        ld c,0 ;wid/2
__d_m_box_len: equ $-1

;l=x/2
;e=y
;lx=brush color byte 0bRLrrrlll
;hx=fill color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        call drawwindow
		call restore8000c000
        pop hl
        ret

;----------------------------------------------------
drawwindow
;l=x/2
;e=y
        ld hy,e
        ld a,l
        ld ly,a
;ly=x/2
;hy=y
        call xytoscraddr
;hl=screen addr
;lx=brush color byte 0bRLrrrlll
;hx=fill color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        push bc
        push hl
        
drawwindowfill0
        push bc
        push hl
        ld c,hx ;ld c,0b11111111 ;color byte 0bRLrrrlll
        call drawverline
        pop hl
        NEXTCOLUMN
        pop bc
        dec c
        jr nz,drawwindowfill0
        
        pop hl ;screen addr
        pop bc

        push bc

        push bc
        push hl
      ;  call drawbox
        pop hl
        pop bc
        NEXTCOLUMN
        ld de,40*2
        add hl,de ;второй бокс внутри первого
        dec c
        dec c
        ld a,b
        sub 4
        ld b,a
        call drawbox
        
        pop bc ;b=hgt-1, c=wid/2
        
;ly=x/2
;hy=y
        ld e,hy
        inc e
        ;call drawwindowhormarks
        
        ld a,hy
        add a,b ;+hgt-1
        dec a
        ld e,a
        ;call drawwindowhormarks

        push bc
        ;call drawwindowvermarks
        pop bc
        ld a,ly
        add a,c ;wid/2
        dec a
        ld ly,a
        ;call drawwindowvermarks
        
        ret
;----------------------------------------------

xytoscraddr
;l=x/2
;e=y (не портится)
;screen pages are mapped in 2 CPU windows
;addr = tY(y) + tX(x)
        ld h,tx/256
        ld d,ty/256
        ld a,(de) ;(y*40)
        add a,(hl) ;x div 4
        ld (xytoscraddr_l),a
        inc d
        inc h
        ld a,(de) ;'(y*40)
        adc a,(hl) ;f(x mod 4)
        ld h,a
xytoscraddr_l=$+1
        ld l,0
        ret

  
drawwindowvermarks
;ly=x/2
;hy=y
;b=hgt-1
;lx=color byte 0bRLrrrlll
        ld a,ly
        ld l,a
        ld a,hy
        add a,6
        ld e,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        ld (hl),a
        ld a,ly
        ld l,a
        ld a,hy
        add a,b ;+hgt-1
        sub 6
        ld e,a
;l=x/2
;e=y        
        call xytoscraddr
        ld a,lx
        ld (hl),a
        ret

        
drawwindowhormarks
;ly=x/2
;e=y
;c=wid/2
        ld a,ly
        add a,3
        ld l,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        xor hx
        and 0b01000111 ;color byte 0bRLrrrlll
        xor hx
        ld (hl),a

        ld a,ly
        add a,c ;+wid/2
        sub 3+1
        ld l,a
;l=x/2
;e=y
        call xytoscraddr
        ld a,lx
        xor hx
        and 0b10111000 ;color byte 0bRLrrrlll
        xor hx
        ld (hl),a
        ret
        

drawbox
;hl=screen addr
;lx=color byte 0bRLrrrlll
;b=hgt-1
;c=wid/2
        push bc
        push hl
        push bc
        ld a,lx
        xor hx
        and 0b01000111 ;color byte 0bRLrrrlll
        xor hx
        ld c,a
        call drawverline ;left line
        pop bc
        ld b,c ;wid/2
        ex (sp),hl
        ld c,lx ;ld c,0b11111111 ;color byte 0bRLrrrlll
        push bc
        call drawhorline ;top line
        pop bc ;b=wid/2, c=color byte 0bRLrrrlll
        ex (sp),hl ;bottom of left line
        call drawhorline ;bottom line
        pop hl ;rightmost byte of top line
        ld de,40
        add hl,de
        pop bc
        dec b ;b=hgt/2
        ld a,lx
        xor hx
        and 0b10111000 ;color byte 0bRLrrrlll
        xor hx
        ld c,a
        ;call drawverline ;right line
        ;ret
drawverline
;hl=scraddr
;c=color byte 0bRLrrrlll
;b=hgt
        ld de,40
drawverline0
        ld (hl),c
        add hl,de
        djnz drawverline0
        ret

drawhorline
;hl=scraddr
;c=color byte 0bRLrrrlll
;b=wid/2
        ld de,0x4000
        jr drawhorline0go
drawhorline0
        NEXTCOLUMN
drawhorline0go
        ld (hl),c
        djnz drawhorline0
        ret
;=-----------------------		
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
		
PUSH_DATA_INTRO:  	ds 256,0  ;//wait animation
CUR_DATA:   		ds 128,0
;---------------------------------------
_sprite_output_core:
        ld a,(scr_buf1)
        ld (src_buf1),a
        ld a,(scr_buf2)
        ld (src_buf2),a
        jr _mb_output



_memory2_output_core:
        ld hl,mempal
        ld de,pal
        ld bc,32
        ldir            ;copy palette for image in membuf
_memory2_output_nopal_core:
        ld a,(mem_buf3)
        ld (src_buf1),a
        ld a,(mem_buf4)
        ld (src_buf2),a
        jp _mb_output

_memory_output_core:
        ld a,(mem_buf1)
        ld (src_buf1),a
        ld a,(mem_buf2)
        ld (src_buf2),a

        ld hl,mempal
        ld de,pal
        ld bc,32
        ldir            ;copy palette for image in membuf
        jr _mb_output


_buffer_output_core
        ld a,(load_buf1)
        ld (src_buf1),a
        ld a,(load_buf2)
        ld (src_buf2),a
_mb_output:
        ld a,(draw_effect)
        cp 0
        jp z,_immed
		
		cp 1
		jp z,_fullscreen_image
		
        cp 3
        jp z,scrollable_image
		
        cp 4
        jp z,_sidas
        cp 5
        jp z,_jaluzi
        cp 6
        jp z,_sidas
        cp 7
        jp z,_cntsds
        cp 8
        jp z,_dn_up
        cp 9
        jp z,_immed
        cp 10
        jp z,_jaluzi
        cp 11
        jp z,_lftrgt
        cp 12
        jp z,_cntsds_r
        cp 13
        jp z,_ud_nd
		cp 14
		jp z,_immed_big_core
		cp 15
		jp z,_img_fade_toblack
		cp 16
		jp z,_img_fade_fromblack
        jp _jaluzi
		

_fullscreen_image:
        call _immed_big_core
        jp WINCLR2
		

_img_fade_toblack:
		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		jp fade_to_sub

_img_fade_fromblack:
		call palette_precalc_sub
		ld hl,0x2ddd
		xor a
		jp fade_from_sub



;; 240x148
;mode 0x32
;---
_immed:
;        ld a,1
;        ld (setpalflag),a
        call store8000c000


        halt
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0x8005
        ld b,148
        call copy_immed_line

        halt
        ld hl,0xa005
        ld b,148
        call copy_immed_line


        ld a,1
        ld (setpalflag),a

        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        halt
        ld hl,0x8005
        ld b,148
        call copy_immed_line

        ld hl,0xa005
        ld b,148
        call copy_immed_line

        jp restore8000c000

;pg8000 sourc
;pgc000 dest scr
;hl laddr
;b - num vert lines
copy_immed_line:
.lp:
        push bc
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        call _ldi_30
        ld bc,10
        add hl,bc
        pop bc
        djnz .lp
        ret
		
;------------------------------------------------------------------        
; 240x148
;left to right
;mode  ????? ;0x3d
_lftrgt:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005

        ld b,30
_lftrgt_loop        
        push bc

        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl


        push hl
        push de

        halt
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld b,148
        call _down_cpy

        pop de
        pop hl
        push hl
        push de

;        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld b,148
        call _down_cpy


        pop de
        pop hl

        set 5,H
        set 5,D

        push hl
        push de

        halt

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld b,148
        call _down_cpy

        pop de
        pop hl
        push hl
        push de

;        halt
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld b,148
        call _down_cpy

        pop de
        pop hl
        res 5,h
        inc hl


        pop bc
        dec b
        jp nz,_lftrgt_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 240x148
;left to right and right to left same time (interleave)
;mode  ???? 
_sidas:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005
        ld (sidas_l),hl
        ld hl,0x8005+29
        ld (sidas_r),hl

;        halt

        ld b,30
_sidas_loop        

_sidas_lock:
         ld a,0        
        xor 1
        ld (_sidas_lock+1),a
        jr z,_sidas_halt_skip
        halt
_sidas_halt_skip:


        push bc


        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000




        ld hl,0
sidas_l equ $-2        
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        ld b,148
        call _down_cpy

        pop de
        pop hl
        push hl

        set 5,H
        set 5,D

        ld b,148
        call _down_cpy

        pop  hl
        inc hl
        ld (sidas_l),hl


        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,0
sidas_r equ $-2        
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,H
        set 5,D

        push hl
        push de

        ld b,148
        call _down_cpy

        pop de
        pop hl
        push hl

        res 5,H
        res 5,D

        ld b,148
        call _down_cpy

        pop  hl
        dec hl
        ld (sidas_r),hl


        pop bc
        dec b
        jp nz,_sidas_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 240x148
;top to middle and bottom to middle same time
;mode ???
_ud_nd:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005
        ld (_ud_nd_top),hl
        ld hl,0x8005+(147*40)
        ld (_ud_nd_btm),hl

;        halt 

        ld b,148/2 ;160/2
_ud_nd_loop:
        
_ud_nd_lock:
         ld a,0        
        xor 1
        ld (_ud_nd_lock+1),a
        jr z,_ud_nd_halt_skip
        halt
_ud_nd_halt_skip:


        push bc



        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_ud_nd_top: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld hl,0
_ud_nd_btm: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_ud_nd_top)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call DHL
        ld (_ud_nd_top),hl

        ld hl,(_ud_nd_btm)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call UPHL
        ld (_ud_nd_btm),hl


        pop bc
        dec b
        jp nz,_ud_nd_loop

        jp restore8000c000
;------------------------------------------------------------------               
; 240x148
;from center up and down same time
;mode 0x3a
_dn_up:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005+(74*40)
        ld (_dn_up_top),hl
        ld hl,0x8005+(73*40)
        ld (_dn_up_btm),hl

;        halt
        ld b,74 ;148/2
_dn_up_loop:       

 
_dn_up_lock:
         ld a,0        
        xor 1
        ld (_dn_up_lock+1),a
        jr z,_dn_up_halt_skip
        halt
_dn_up_halt_skip:



        push bc



        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_dn_up_top: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld hl,0
_dn_up_btm: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_dn_up_top)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call DHL
        ld (_dn_up_top),hl

        ld hl,(_dn_up_btm)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call UPHL
        ld (_dn_up_btm),hl


        pop bc
        dec b
        jp nz,_dn_up_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 240x148
;jaluzi top to bottom and bottom to top same tome interleave
;mode 0x3c
_jaluzi:
        ld a,1
        ld (setpalflag),a
        call store8000c000



        ld hl,0x8005
        ld (_jaluzi_top),hl
        ld hl,0x8005+(147*40)
        ld (_jaluzi_btm),hl

;        halt
        ld b,74 ;148/2
_jaluzi_loop:


_jaluzi_lock:
         ld a,0        
        xor 1
        ld (_jaluzi_lock+1),a
        jr z,_jaluzi_halt_skip
        halt
_jaluzi_halt_skip:

        push bc

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000


        ld hl,0
_jaluzi_top: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld hl,0
_jaluzi_btm: equ $-2

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl


        set 5,h
        set 5,d

        call _ldi_30

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000


        ld hl,(_jaluzi_top)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl
        push hl

        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call DHL1
        ld (_jaluzi_top),hl

        ld hl,(_jaluzi_btm)

        push hl
        pop de        

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        push hl
        push de

        call _ldi_30

        pop de
        pop hl

        push hl
        set 5,h
        set 5,d

        call _ldi_30

        pop hl
        call UPHL1
        ld (_jaluzi_btm),hl

        pop bc
        dec b
        jp nz,_jaluzi_loop

        jp restore8000c000
;------------------------------------------------------------------        
; 240x148
;from center to sides left and right same time
;mode 0x39
_cntsds:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005+14  ;to left
        ld (_cntsds_lft),hl

        ld hl,0x8005+15 ;to right
        ld (_cntsds_rgt),hl

        xor a
        ld (_cntsds_fsa),a

;        halt

        ld b,60  ; 256 /2 /2
_cntsds_loop:


_cntsds_lock:
         ld a,0        
        xor 1
        ld (_cntsds_lock+1),a
        jr z,_cntsds_halt_skip
        halt
_cntsds_halt_skip:



        push bc

        ld hl,_cntsds_loop_end
        push hl


        ld a,0
_cntsds_fsa: equ $-1
        and a
        jp z,_cntsds_f0
        cp 1
        jp z,_cntsds_f1
        cp 2
        jp z,_cntsds_f2
        cp 3
        jp z,_cntsds_f3


_cntsds_loop_end:
        ld a,(_cntsds_fsa)
        inc a
        and 3
        ld (_cntsds_fsa),a
        pop bc
        dec b
        jp nz,_cntsds_loop


        jp restore8000c000

;----
_cntsds_f0:
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,0
_cntsds_lft: equ $-2
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        call _down_cpy

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0
_cntsds_rgt: equ $-2
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        jp _down_cpy


;----
_cntsds_f2:
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_lft)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_rgt)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        jp _down_cpy


;----
_cntsds_f1:
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_lft)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        call _down_cpy

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        jp _down_cpy
;----
_cntsds_f3:
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_lft)
        push hl
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy

        pop hl
        dec hl
        ld (_cntsds_lft),hl

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt)
        push hl
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d


        ld b,148
        call _down_cpy

        pop hl
        inc hl
        ld (_cntsds_rgt),hl
        ret
;------------------------------------------------------------------        
; 240x148
;from sides left and right  to center same time 
;mode 0x39
_cntsds_r:
        ld a,1
        ld (setpalflag),a
        call store8000c000


        ld hl,0x8005  ;to left
        ld (_cntsds_lft_r),hl

        ld hl,0x8005+29 ;to right
        ld (_cntsds_rgt_r),hl

        xor a
        ld (_cntsds_fsa_r),a

;        halt 

        ld b,64  ; 256 /2 /2
_cntsds_loop_r:



_cntsds_lock1:
         ld a,0        
        xor 1
        ld (_cntsds_lock1+1),a
        jr z,_cntsds_halt_skip1
        halt
_cntsds_halt_skip1:


        push bc

        ld hl,_cntsds_loop_end_r
        push hl


        ld a,0
_cntsds_fsa_r: equ $-1
        and a
        jp z,_cntsds_f3_r
        cp 1
        jp z,_cntsds_f2_r
        cp 2
        jp z,_cntsds_f1_r
        cp 3
        jp z,_cntsds_f0_r


_cntsds_loop_end_r:
        ld a,(_cntsds_fsa_r)
        inc a
        and 3
        ld (_cntsds_fsa_r),a
        pop bc
        dec b
        jp nz,_cntsds_loop_r


        jp restore8000c000

;----
_cntsds_f0_r:
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,0
_cntsds_lft_r: equ $-2
        push hl
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        call _down_cpy

        pop hl
        inc hl
        ld (_cntsds_lft_r),hl

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0
_cntsds_rgt_r: equ $-2

        push hl
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy
        pop hl
        dec hl
        ld (_cntsds_rgt_r),hl
        ret


;----
_cntsds_f2_r:
        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_lft_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy

        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_rgt_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        jp _down_cpy


;----
_cntsds_f1_r:
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_lft_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d

        ld b,148
        call _down_cpy

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        jp _down_cpy
;----
_cntsds_f3_r:
        ld a,(src_buf1)
        SETPG8000
        ld a,(user_scr0_low)
        SETPGC000

        ld hl,(_cntsds_lft_r)
        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        ld b,148
        call _down_cpy

        ld a,(src_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000

        ld hl,(_cntsds_rgt_r)

        push hl
        pop de

        ex de,hl
        set 6,h
        ld bc,320
        add hl,bc
        ex de,hl

        set 5,h
        set 5,d


        ld b,148
        jp _down_cpy
		
_down_cpy:
        ld a,(mask_mode)
        and a
        jr nz,_down_cpy_iob

_down_cpy_a
;        push bc
        ld a,(hl)
        ld (de),a
        call DHL
        ex de,hl
        call DHL
        ex de,hl
;        pop bc
        djnz _down_cpy_a
        ret
_down_cpy_iob:
;        push bc
        ex de,hl
        call _iob_byte
        call DHL
        ex de,hl
        call DHL
;        pop bc
        djnz _down_cpy_iob
        ex de,hl
        ret
;--------------------------------------------------		
scrollable_image
		call _immed		;
store_scr0_mem_buf1:
        call store8000c000

        ld a,(mem_buf1)
        SETPG8000

        ld a,(user_scr0_low)
        SETPGC000

        ld hl,0xc000+320
        ld de,0x8000
        ld bc,16384-320
        ldir

        ld a,(mem_buf2)
        SETPG8000
        ld a,(user_scr0_high)
        SETPGC000
        ld hl,0xc000+320
        ld de,0x8000
        ld bc,16384-320
        ldir
        jp restore8000c000
;ending sequence
credits_img1	db "TI_135",0
credits_img2	db "TI_135A",0

credits_img3    db "TB_140",0
credits_img3a   db "TT_02",0

credits_img4    db "TB_030",0
credits_img4a   db "TT_10",0

credits_img5    db "TB_028A",0
credits_img5a   db "TT_08",0

credits_img6    db "TB_031",0
credits_img6a   db "TT_12",0

credits_img7    db "TB_145",0
credits_img7a   db "TT_16",0

credits_img8    db "TB_025",0
credits_img8a   db "TT_09",0

credits_img9    db "TI_049",0		

credits_txt_1	db "                           DIRECTOR",0x1f,4
				db 0x1f,4,0x1f,4
				db "                 Mizuno Taki (Takei Hidehiko)"
				db 0x1F,0

credits_txt_2	db "                           ARTIST",0x1f,4
				db 0x1f,4,0x1f,4
				db "                      Hanayashiki Botan"
				db 0x1F,0
				
credits_txt_3	db "                           GRAPH",0x1f,4
				db 0x1f,4
				db "            Mizuno Taki, Billiard Matsuyama"
				db 0x1f,4
				db "               Usa Usagi, Yumirin, Asano"
				db 0x1F,0
				
credits_txt_4	db "                          SCENARIO",0x1f,4
				db 0x1f,4,0x1f,4
				db "          Professor Asshuku, ponz (Kurusu Tatsuya)"
				db 0x1F,0
				
credits_txt_5	db "                          MUSIC",0x1f,4
				db 0x1f,4,0x1f,4
				db "                   H2 (Higuchi Hideki)"
				db 0x1F,0
				
credits_txt_6	db "                          PROGRAM",0x1f,4
				db 0x1f,4
				db "       Professor Asshuku (Professor Compression)"
				db 0x1f,4
				db "                       Hakaishi Taizou"
				db 0x1F,0
				
credits_txt_7	db "                       PRRESENTED BY",0x1f,4
				db 0x1f,4,0x1f,4
				db "                       JAST Co., Ltd."
				db 0x1F,0
page4000end:

