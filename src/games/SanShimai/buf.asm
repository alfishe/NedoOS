txt_setup:          db 0x0A,"Three Sisters' story (San Shimai)",0x0D,0x0A
                    db "(c) 1996 JAST",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "language setup",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. English v1.0 (Sakura Soft)",0x0D,0x0A
                    db "2. English v1.1 (Jast USA)",0x0D,0x0A
;                    db "3. Russian",0        
                    db "3. ",0x90,0xe3,0xe1,0xe1,0xaa,0xa8,0xa9," (The Asenheim Project)",0x0D,0x0A,0
txt_censor_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Censorship? (If available)",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. Yes",0x0D,0x0A
                    db "2. No",0x0D,0x0A
                    db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
import_push:
        
        call store8000c000

        ld a,(load_buf1)
        SETPG8000

        ld a,(load_buf2)
        SETPGC000

        ld hl,0x8005
        ld de,PUSH_DATA

        ld b,8
import_push_loop:
        push bc


        push hl
        ld b,8
import_push_iloop1:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz import_push_iloop1
        pop hl

        set 6,H
        push hl
        ld b,8
import_push_iloop2:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz import_push_iloop2
        pop hl

        res 6,H
        set 5,H

        push hl
        ld b,8
import_push_iloop3:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz import_push_iloop3
        pop hl

        set 6,H
        push hl
        ld b,8
import_push_iloop4:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz import_push_iloop4
        pop hl

        res 6,H
        res 5,H
        inc hl

        pop bc
        djnz import_push_loop
        jp restore8000c000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
pre_init
    ld e,6+0x80  //set TEXT mode  keep
    OS_SETGFX

        ld e,0
        OS_CLS

        OS_GETMAINPAGES
;dehl=??N?a ???a?? o 0000,4000,8000,c000
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

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (font_page),a


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

        ld hl,txt_censor_setup
        call print_hl
setup_lpc:        
        YIELDGETKEYLOOP
        cp "1"
        jr z,setup_isc1
        cp "2"
        jr z,setup_isc2
        jr setup_lpc
setup_isc1:
          ld a,1
          jr setup_setc
setup_isc2:
         xor a
setup_setc:
        ld (censor_mode),a
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
                ld (wlock),a

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
;load font 
loadfont:
              call setfontpage
              ld de,font_file  
              call openstream_file
              or a
              jp nz,fileopenerror

              ld hl,0x4000 ;len
              ld de,FONT ;addr
              call readstream_file
              or a
              jp nz,filereaderror 

              call closestream_file

              call unsetfontpage

        call int_set

        ;set mode
        ld e,0+0x80  //set EGA mode keep
        OS_SETGFX

;prepare animation
        call clear_screen
deb_lnk
        ld hl,anim_w
        call load_gfx_to_load_buf_nopal
        call import_push
;;



;ï¸¨á¦¬ mem_buf. é²¯ï¬¼è´¥ó²½ ë¡ª í¾§í±­ç¡½ë± ë‹Š        ld a,(mem_buf1)
        SETPGC000
        ld hl,0xc000
        ld de,0xc001
        ld bc,16383
        ld (hl),0
        ldir
        ld a,(mem_buf2)
        SETPGC000
        ld hl,0xc000
        ld de,0xc001
        ld bc,16383
        ld (hl),0
        ldir
        ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

introduction
        ;---load resources
        ; '1' - load image

        ld hl,intro_text
        call load_ovl_to_script_buf

        ld hl,TABLE_W
        ld (CODEPAGE),hl



        ld b,0
introduction_loop:
        push bc;
    
        call _ppp_pause

        ld hl,introduction_pause
        push hl
        
        ld a,b
        and a
        jp z,introduction_st1
        cp 1
        jp z,introduction_st2
        cp 2
        jp z,introduction_st3



introduction_pause:

        pop bc
        ld a,b
        cp 2
        jr z,introduction_exit
        inc b
        jr introduction_loop

introduction_exit:
;        call clear_whole_screen
        ld a,1
        ld (intro_switch),a
        ret


introduction_st1
        ld hl,intro_pic1
        call load_big_img_dark2

        call palette_precalc
        jp fade_fromblack


introduction_st3
        call fade_towhite
        ret

introduction_st2
        call fade_toblack


        ld hl,intro_pic2
        call load_big_img_dark2

        call palette_precalc
        call fade_fromblack



        call store8000c000
        ld a,(user_scr0_low) ;ok
        SETPG8000
        ld a,(user_scr1_low) ;ok
        SETPGC000

        ld hl,0x8000
        ld de,0xc000
        ld bc,16384
        ldir


        ld a,(user_scr0_high) ;ok
        SETPG8000
        ld a,(user_scr1_high) ;ok
        SETPGC000

        ld hl,0x8000
        ld de,0xc000
        ld bc,16384
        ldir

;        ld e,1
;        OS_SETSCREEN
;
;        ld a,(user_scr0_low) ;ok
;        SETPG8000
;        ld a,(user_scr0_high) ;ok
;        SETPGC000
;
;        ld hl,0x8000
;        ld de,0x8001
;        ld bc,32767
;        ld (hl),0
;        ldir
;        call restore8000c000



;        ld a,1
 ;       ld (screenswapper),a


        call _ppp_type


        call store8000c000
        ld a,(user_scr1_low) ;ok
        SETPG8000
        ld a,(user_scr0_low) ;ok
        SETPGC000

        ld hl,0x8000
        ld de,0xc000
        ld bc,16384
        ldir


        ld a,(user_scr1_high) ;ok
        SETPG8000
        ld a,(user_scr0_high) ;ok
        SETPGC000

        ld hl,0x8000
        ld de,0xc000
        ld bc,16384
        ldir

        ld e,0
        OS_SETSCREEN

        call restore8000c000
        xor a
        ld (screenswapper),a



        ret

                
_ppp_type
        LD	HL,ovl_start
_ppp_type_c:
        LD	BC,#0300
        CALL	_pradd

_ppp:
        ld a,(hl)
        inc hl
        cp 32
        jr  c,_ppp1
        jr z,_ppp_skip_ch
        cp 128
        call nc,change_cp
        CP "#"
        call z,change_cp1
        CP "@"
        call z,change_cp2
        sub 32 
_ppp_o:
        push hl
        call _type
        pop hl
        jr _ppp

_ppp1:  and a
        ret z

        cp 1
        jr z,_ppp_wait_key

        cp 0x0a
        jr z,_ppp_line_feed


        ld a,"?"  ;unknown opcode print '?' char
        jr _ppp_o

_ppp_wait_key:
        push hl
        call waitkey

        ;call clear_whole_screen
        call _immed_big

        pop hl
        jp _ppp_type_c
_ppp_pause:
        push bc
          ld b,50
1        halt
        djnz 1b
        pop bc
        ret

_ppp_skip_ch:
        push hl
        ld bc,(CORDS)
        inc c
        ld (CORDS),bc
        ld a,c
        cp 64
        jr c,_ppp_skip_ch1

        inc b
        ld c,0
_ppp_skip_ch1:
        call _pradd
        pop hl
        jp _ppp

_ppp_line_feed:
        push hl
        ld bc,(CORDS)
        inc b
        ld c,0
        call _pradd
        pop hl
        jp _ppp



