_MENU_SET:

        call _fill_sc_com_tables
        call _precache_menu

        push hl
        xor a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;reset cursor position
       ld h,a
       ld l,h
       ld (g_curpos),hl
       pop hl
        call _menu
        CALL WINCLR2



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


        LD BC,4
        ADD HL,BC
        LD A,(HL)
        INC HL,HL
        LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A

        JP _txt_out
SEARCH1:
        INC HL,HL,HL
        JR SEARCH0


_flg_if:
        ld b,(hl)  ;opcode
        inc hl

                ld d,HIGH GLOBVARS
                ld e,(hl) ;variable

                ld a,(de) ; variable value
                ld d,a     ; move variable value to d

                ld a,b    ; move opcode to a
                ld b,d    ; move variable value to b

                ;exit a - opcode  b - variable value

        inc hl
        ld c,(hl) ;value
        inc hl
        ld e,(hl)
        inc hl
        ld d,(hl)  ;goto value
        inc hl

        and a
        jr z,flg_if_equ
        dec a ;1
        jr z,flg_if_greater_equ
        dec a ;2
        jr z,flg_if_less_equ
        dec a ;3
        jr z,flg_if_less
        dec a ;4
        jr z,flg_if_greater
        dec a  ;5
        jr z,flg_if_not_equ
        dec a ;6
        jr z,flg_if_not_equ

        pop hl
        jp flg_if_error

flg_if_not_equ:
        ld a,b
        cp c
        jr nz,flg_if_jump
        jr flg_if_exit
flg_if_equ:
        ld a,b
        cp c
        jr z,flg_if_jump
        jr flg_if_exit
flg_if_less:
        ld a,b
        cp c
        jr c,flg_if_jump
        jr flg_if_exit
flg_if_greater:
        ld a,b
        cp c
        jr c,flg_if_exit
        and a
        jr z,flg_if_exit
        jr flg_if_jump
flg_if_greater_equ:
        ld a,b
        cp c
        jr nc,flg_if_jump
        jr flg_if_exit
flg_if_less_equ:
        ld a,b
        cp c
        jr z,flg_if_jump
        jr c,flg_if_jump
        jr flg_if_exit
flg_if_jump:
        ex de,hl
flg_if_exit:
        jp _print





_goto:
        LD A,(HL)
        INC HL
        LD H,(HL)
        LD L,A
        JP _print

_jtbl:
        LD E,(HL)
        LD D,HIGH GLOBVARS
        LD A,(DE)
        ADD A,A
        INC HL
        LD D,0
        LD E,A
        ADD HL,DE
        LD C,(HL)
        INC HL
        LD B,(HL)
        EX DE,HL
        ld h,b
        LD L,C

        JP _print  ;!!!!!!!!! skip set ret addr

_gata:
        inc hl
        ld b,(hl)
        inc hl

        push hl
        push bc

        call store8000c000

        ld a,(user_scr0_low)
        SETPG8000
        ld a,(user_scr1_low)
        SETPGC000

        ld hl,0x8000+320
        ld de,0xc000
        ld bc,8000-320
        ldir


        ld hl,0xa000+320
        ld de,0xe000
        ld bc,8000-320
        ldir

        ld a,(user_scr0_high)
        SETPG8000
        ld a,(user_scr1_high)
        SETPGC000

        ld hl,0x8000+320
        ld de,0xc000
        ld bc,8000-320
        ldir

        ld hl,0xa000+320
        ld de,0xe000
        ld bc,8000-320
        ldir


        pop bc
.gata_lp:
        push bc

        ld e,1
        OS_SETSCREEN

        halt
        halt
        halt
        halt
        halt

        ld e,0
        OS_SETSCREEN

        halt
        halt
        halt
        halt
        halt

        pop bc
        djnz .gata_lp

        call restore8000c000
        pop hl
        jp _print

t_ppal:
        dw blackpal
        dw whitepal
        dw redpal

_flash:
        inc hl
        ld b,(hl)
        inc hl
        ld a,(hl)
        inc hl ; skip flash color
        push hl

        push bc



        ld hl,t_ppal
        call sel_word
        ld (.pall),hl

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir

        pop bc

.FLASH_LP:
        push bc

        ld hl,0
.pall:  equ $-2
        ld de,pal
        ld bc,32
        ldir

        ld a,1
        ld (setpalflag),a

        halt
        halt
        halt
        halt
        halt


        ld hl,temppal
        ld de,pal
        ld bc,32
        ldir

        ld a,1
        ld (setpalflag),a

        halt
        halt
        halt
        halt
        halt

        pop bc
        djnz .FLASH_LP
        pop hl
        jp _print

SCREENOUTPUT1A:


        INC HL
        LD A,(HL) ;DELAY
        LD (DELAY),A
        INC HL,HL
        LD A,(HL)
        LD (outtyp),A
        INC HL
        LD A,(HL)
        INC HL,HL
        PUSH HL
        CP 3       ;SELECTOR 3-FROM OUTPUT BUFER
        JR Z,scrop2m   ;         4- FROM MEMORY BUFFER
        CALL _memory_output_mask
        JR scrop1
scrop2m:
        CALL _buffer_output_mask
scrop1m:
        POP HL
        JP _print

_SCREENOUTPUT1  ;SHOW FROM BUFFERS
;out load buffer to screen by mask index8
                push hl
                ld a,(redraw_border)
                and a
                jr z,.redraw_skip
                call redraw_border_sub
                xor a
                ld (redraw_border),a
.redraw_skip:
                pop hl
        INC HL
        ld a,(hl)
        cp 8
        jr z,SCREENOUTPUT1A

        INC HL
        LD A,(HL) ;DELAY
        LD (DELAY),A
        INC HL,HL
        LD A,(HL)
        LD (outtyp),A
        INC HL
        LD A,(HL)
        INC HL,HL
        PUSH HL
        CP 3       ;SELECTOR 3-FROM OUTPUT BUFER
        JR Z,scrop2   ;         4- FROM MEMORY BUFFER
        CALL _memory_output
        JR scrop1
scrop2:
        CALL _buffer_output
scrop1:
        POP HL
        JP _print



_LOAD_TO_MEM
        INC HL,HL

        push hl
        call load_gfx_to_mem_buf

        call clear_all_stored_names

        pop hl

        ld de,loadedCg
        call copystr_hlde
        xor a
        ld (de),a
        inc hl
        JP _print


_COPY_MEM_2_LOAD:
       PUSH HL
       call store8000c000

       ld a,(mem_buf1)
       SETPG8000
       ld a,(load_buf1)
       SETPGC000

       ld hl,0x8000
       ld de,0xc000
       ld bc,16384
       ldir

       ld a,(mem_buf2)
       SETPG8000
       ld a,(load_buf2)
       SETPGC000

       ld hl,0x8000
       ld de,0xc000
       ld bc,16384
       ldir

       ld hl,mempal
       ld de,pal
       ld bc,32
       ldir

       call restore8000c000

       ;call clear_all_stored_names_spr

       POP HL
       JP _print

_T_CG:
        inc hl
        inc hl
        inc hl
        ld a,(hl)
        inc hl
        inc hl

        push hl
        push af
        call load_gfx_to_scr_buf
        pop af
;        ld (spr_poss),a

;         ld de,loadedSpr1
;         cp 1
;         jr z,.pos0a
;         ld de,loadedSpr2
;         cp 2
;         jr z,.pos0a
;         ld de,loadedSpr3
; .pos0a
         pop hl

        push af
        ld de,buf
        call copystr_hlde
        xor a
;        ld (de),a
        ld (outtyp),a
        inc hl
        pop af

;         ld b,2
;         dec a
;         jr z,.pos11a
;         ld b,20
;         dec a
;         jr z,.pos11a
;         ld b,36
; .pos11a
;         ld a,b
;         ld (XPOS),a

        push hl,de
        push af

        ld a,(gfx_mode)
        ld hl,Modes_x
        call sel_word
        pop af
        dec a
        ld d,0
        ld e,a
        add hl,de
        ld a,(hl)
        ld (XPOS),a
        pop de

        call copy_screen_to_loadbuf

        CALL DECR_SPR

        call _buffer_output
        ;call copy_loadbuf_to_screen

        pop hl
        jp _print

_loadovl:
;        POP DE
        inc hl
        ld de,OVL
        call copystr_hlde
        xor a
        ld (DE),a
        ld a,(gfx_mode_base)
        ld (gfx_mode),a
        JP BEG
_var_equal:
          ld a,(hl)
          inc hl
          ld b,(hl)
          inc hl
          push hl

          ld h,high GLOBVARS

          cp 0xf0
          jr z,.dialogue
          ld l,a

          ld (hl),b


          ld a,(redraw_border)
          and a
          jr nz,.skip ;do not redraw if blackout
          call check_yoku
          call update_satus
.skip:



          pop hl
          jp _print

.dialogue:
         ld l,0xf0
.dialogue_lp:
         ld (hl),b
         inc l
         ld a,l
         cp 0xf8
         jr nz,.dialogue_lp
          pop hl
          jp _print


_var_plus:
          ld a,(hl)
          inc hl
          ld b,(hl)
          inc hl
          push hl

          ld h,high GLOBVARS
          ld l,a
          ld a,(hl)
          add a,b
          ld (hl),a

          ld a,(redraw_border)
          and a
          jr nz,.skip ;do not redraw if blackout
          call check_yoku
          call update_satus
.skip:

          pop hl
          jp _print

_var_minus:
          ld a,(hl)
          inc hl
          ld b,(hl)
          inc hl
          push hl

          ld h,high GLOBVARS
          ld l,a
          ld a,(hl)
          sub b
          ld (hl),a

          ld a,(redraw_border)
          and a
          jr nz,.skip ;do not redraw if blackout
          call check_yoku
          call update_satus
.skip:

          pop hl
          jp _print

_var_div:
          ld a,(hl)
          inc hl
          ld b,(hl)
          inc hl
          push hl

          ld h,high GLOBVARS
          ld l,a
          ld c,(hl)
          push hl
          call DIVIS
          ld l,a
          pop hl
          ld (hl),a


          ld a,(redraw_border)
          and a
          jr nz,.skip ;do not redraw if blackout

          call check_yoku
          call update_satus
.skip:
          pop hl
          jp _print


_var_down:       ;W variable (0xf0) only
          ld a,(hl)
          inc hl
          ld b,(hl)
          inc hl
          push hl
          cp 0xf0
          jr nz,.skip

          ld a,b
          add a,0xf0
          ld l,a
          ld h,high GLOBVARS
          ld (hl),0

.skip:
          pop hl
          jp _print

check_yoku:
          ld a,l
           cp 201
           ret nz
           ld a,(hl)
           and a
           jp p,.next1
            ;yoku <0  . set to 0
           ld (hl),0
            ret
.next1:
            cp 101
            ret c
            ld (hl),100
            ret

update_satus:
          ld a,l
          cp 201
          jr z,update_satus_bar
          cp 7
          jr z,update_satus_bar
          ;;;cp 2
          ;;;jr z,.update_satus_bar
          ret





update_satus_bar:
          push bc,de,hl

          call clear_status_bar
          call print_excite
          call print_lamp_post
          ;;;call print_date
          call print_loaded  ;;;debug

          call print_day

          ld bc ,txt_coor
          call _pradd_p


          pop hl,de,bc
          ret



_SCR_SET:
        push hl

        call clear_all_stored_names
        pop hl
        push hl

        call load_gfx_to_mem_buf
        pop hl
        ld de,loadedCg
        call copystr_hlde
        xor a
        ld (de),a

        inc hl
        push hl

        call load_gfx_to_mem2_buf

        pop hl
        ld de,buf
        call copystr_hlde
        xor a
        ld (de),a
        inc hl

        ld a,(hl)
        ld (_toleft_x),a
        inc hl
        ld a,(hl)
        ld (_toup_y),a
        inc hl
        ld a,(hl)
        ld (_toright_x),a
        inc hl
        ld a,(hl)
        ld (_todown_y),a
        inc hl
        push hl
        call _scr_move_
        pop hl
        jp _print

_toleft_x:
         db 0
_toup_y:
        db 0
_toright_x:
        db 0
_todown_y:
        db 0



_WAV
        inc hl
        push hl
        ld a,(hl)
        push af
        call setcorepage
        pop af
        and a
        jr z,.mute
        dec a
        ld c,10
        call ayfx.PLAY

.mit:
        call unsetcorepage
        pop hl
        inc hl
        JP _print
.mute:
        
        ld a,(mus_mode)
        and a
        jp z,.mit        

        ld a,(tsfm_detected)
        and a
        call nz,set_ay1

        ld hl, sfxdata
        call   ayfx.INIT

        ld a,(tsfm_detected)
        and a
        call nz,set_ay0
        jp .mit

_CDPLAY:
        inc hl
        PUSH HL
        LD A,(HL)
        CALL load_mus
        POP HL
        INC HL
        JP _print
_T_WAIT:
        inc hl
        LD A,(HL)
        LD B,A
        INC HL
        PUSH HL
        RLCA
        LD B,A
.t1:
        ld c,6
.t2:     HALT
         dec c
         jr nz,.t2
        DJNZ .t1

        ld hl,txt_buff
        ld (hl),32
        inc hl
        ld (hl),0
        call _print_txt_buf_p

        ;call WINCLR2
        POP HL
        JP _print


_cls:
        call WINCLR2
        jr WINCLR3
;;;;;-------------
WINCLR:
        CALL WINCLR1
WINCLR3:

        ld a,1
        ld (first_word),a
        ld (first_letter),a

        inc hl
        JP _print

WINCLR1:
         CALL waitkey_a
WINCLR2:
        PUSH HL
        CALL _clear_textbox  ;-0-0-3423566400------------------

COOOR   LD BC,txt_coor
        call _pradd_p
        pop hl
        ret
        ;ret
;;;;;-------------
_F_O
        ld a,(hl)
        ld (outtyp),a
        inc hl
        inc hl ;skip fade color
        push hl
        call clear_all_stored_names
        call _F_O_sub
        pop hl
        jp _print

_F_O_sub:
                ld a,(mem_buf3)
                SETPGC000
                ld hl,0xc000
                ld de,0xc001
                ld bc,16383
                ld (hl),0
                ldir
                ld a,(mem_buf4)
                SETPGC000
                ld hl,0xc000
                ld de,0xc001
                ld bc,16383
                ld (hl),0
                ldir



               jp _memory2_output_nopal
;;;;;-------------
_B_O:
               inc hl ;skip fade type
               ld a,(hl) ;fade color
               inc hl
               push hl

               call _B_O_sub

               ld a,1
               ld (redraw_border),a

               call clear_all_stored_names

                CALL _clear_textbox


               pop hl
               jp _print

_B_O_sub:
               call fade_toblack

               call clear_whole_screen

                ld de,pal
                ld hl,nblackpal
                ld bc,32
                ldir
                halt
                ld a,1
                ld (setpalflag),a
                ret


_EVENT_CG:
                ld a,(redraw_border)
                and a
                jr z,.redraw_skip
                call redraw_border_sub
                xor a
                ld (redraw_border),a

.redraw_skip
                inc hl,hl
                ld a,(hl)
                ld (DELAY),a
                inc hl,hl
                ld a,(hl)
                ld (outtyp),a
                inc hl
                inc hl ; skip gallery image ID


                push hl
                call load_gfx_to_load_buf
                call _buffer_output


                call clear_all_stored_names


                pop hl

                ld de,loadedCg
                call copystr_hlde
                xor a
                ld (de),a
                inc hl

                JP _print
_gameend
        call fade_towhite
        CALL clear_whole_screen
        jp begin
;================
set_ay0;
      	ld a,0+%11111000
        jr $+4
set_ay1:
	ld a,1+%11111000
	ld bc,0xFFFD
	out (c),a
	in a,(c)
	rlca
	jr c,$-3 
        ret