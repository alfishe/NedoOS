MOON_BASE = 0xc4
MOON_REG1 = MOON_BASE
MOON_DAT1 = MOON_BASE+1
MOON_REG2 = MOON_BASE+2
MOON_DAT2 = MOON_BASE+3
MOON_STAT = MOON_BASE
MOON_WREG = 0xc2
MOON_WDAT = MOON_WREG+1       


	macro switch_to_pcm_ports_c2_c3
	in a,(MOON_REG2)
	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
memoryerror2:
        pop hl,bc
        jp memoryerror
       
pre_init:
        switch_to_pcm_ports_c2_c3

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

;-----------------------------------------		
        ld b,pagestbllen
        ld hl,pagestbl
.getpagesloop
        push bc,hl
        OS_NEWPAGE
        or a
        jp nz,memoryerror2
        pop hl,bc
        ld (hl),e
        inc hl
        djnz .getpagesloop
;-----------------------------------------


        ld hl,txt_setup
        call print_hl
setup_lp:        
        YIELDGETKEYLOOP
        cp "1"
        jr z,setup_is1
        cp "2"
        jr z,setup_is2
        jr setup_lp
setup_is1:
          xor a
          jr setup_set
setup_is2:
         ld a,1
setup_set:
        ld (language),a

;============================
        ld hl,mus_gfx_setup
        call print_hl


setup_mus_lp:
        YIELDGETKEYLOOP
        cp "1"
        jr z,_set_ay
        cp "2"
        jr z,_set_tsfm
        cp "3"
        jr z,_set_msnd
        cp "4"
        jr z,_set_midi
        jr setup_mus_lp
_set_midi:
        ld a,3
        jr _set_mu
_set_msnd:
        ld a,2
        jr _set_mu
_set_tsfm:
        ld a,1
        jr _set_mu
_set_ay:
        xor a
_set_mu:
        ld (mus_mode),a

;============================

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

;set tiare

        ;set mode
        ld e,0+0x80  //set EGA mode keep
        OS_SETGFX

;prepare animation
        call clear_screen





        ;----------------------
        ;--load music player


              call set_music_pages
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

                ld hl,0x8000 ;len
                ld de,player_load ;addr
                call readstream_file
                or a
                jp nz,filereaderror 

                call closestream_file

             call unset_music_pages


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;
        call int_set


        ld de,pal
        ld hl,blackpal
        ld bc,32
        ldir    
        halt
	ld a,1
	ld (setpalflag),a


        ld hl,tiare
        call load_big_img_dark2

        call palette_precalc
        call fade_fromwhite



load_menu_anim:
                call setmanpage1



                ld b,0
load_menu_anim_loop:
                push bc        

                ld a,b

                push af

                ld hl,menu_anim_order
                call sel_word

                call load_anim_pre_sub

                pop af


                add a,a ;x2
                add a,a ;x4                
                add a,a ;x8
                add a,a ;x16
                ld d,a
                ld a,0x40
                add a,d
                ld d,a
                ld e,0 ;addr
                ld hl,0x1000 ; len 4096

                call readstream_file
                or a
                jp nz,filereaderror
                call closestream_file

                pop bc
                inc b
                ld a,(menu_anim_cnt)
                cp b
                jr nz,load_menu_anim_loop

                push bc
                call unsetmanpage1

                call setmanpage2
                pop bc

                ld a,b
                ld hl,menu_anim_order
                call sel_word
                call load_anim_pre_sub

                ld de,0x4000
                ld hl,0x1000 ; len 4096

                call readstream_file
                or a
                jp nz,filereaderror
                call closestream_file


                call unsetmanpage2
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;        call int_set

;        ;set mode
;        ld e,0+0x80  //set EGA mode keep
;        OS_SETGFX
;
;;prepare animation
;        call clear_screen
deb_lnk
        ld hl,anim_w
        call load_gfx_to_load_buf_nopal
        call import_push
;;



;===clear_memory bufer
        ld a,(mem_buf1)
        call pg_clr
        ld a,(mem_buf2)
        call pg_clr
;----------------------------------------------------
;        call palette_precalc
        call fade_toblack
        CALL clear_whole_screen

        ld de,pal
        ld hl,temppal
        ld bc,32
        ldir    
	ld a,1
	ld (setpalflag),a

        jp introduction
        
pg_clr:
        SETPGC000
        ld hl,0xc000
        ld de,0xc001
        ld bc,16383
        ld (hl),0
        ldir
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;         
introduction
        ;---load resources
        ; '1' - load image

        ld hl,TABLE_J
        ld (CODEPAGE),hl


        ld a,(intro_mus)
        call load_mus

        ld b,0
introduction_loop:
        push bc

        ld hl,introduction_pause
        push hl
        
        ld a,b
        and a
        jp z,introduction_st1
        cp 1
        jp z,introduction_st2
        cp 2
        jp z,introduction_st3
        sub 3
        jp introduction_st4


introduction_pause:
        call _ppp_pause
        pop bc
        ld a,b
        cp 14
        jr z,introduction_exit
        inc b
        jr introduction_loop

introduction_exit:
;        call clear_whole_screen
        ld hl,mega_dzx
        ld de,std_dzx
        ld bc,mega_dzx_len
        ldir
        call palette_precalc
        jp fade_towhite


introduction_st1
        call clear_whole_screen
        LD	BC,#0A15
        CALL	_pradd
        LD	HL,intro_txt0
        jp	_ppp

introduction_st2
        call clear_whole_screen
        LD	BC,#0A15
        CALL	_pradd
        LD	HL,intro_txt1
        jp	_ppp
introduction_st3
        call clear_whole_screen
        LD	BC,#0A15
        CALL	_pradd
        LD	HL,intro_txt2
        jp	_ppp
introduction_st4:
        ld hl,intro_sequence
        call sel_word

        call load_gfx_to_load_buf

        ld hl,pal
        ld de,temppal
        ld bc,32
        ldir

        ld hl,blackpal
        ld de,pal
        ld bc,32 
        ldir

        ld a,1
        ld (setpalflag),a
        halt

        call clear_whole_screen
        ;jp _immed_big
        call _immed_big

        ld de,pal
        ld hl,temppal
        ld bc,32
        ldir        
        ld a,1
        ld (setpalflag),a


        ret




_ppp:
        ld a,(hl)
        inc hl
        cp 32
        jr  c,_ppp1
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

        ld a,"?"  ;unknown opcode print '?' char
        jr _ppp_o

_ppp_pause:
          ld b,0xff ;450
_ppp_halt_loop:
        push bc,hl
        halt
        pop hl,bc
        call getkey
        cp NOKEY
        jr nz,_ppp_exit
_ppp_p2:
        djnz _ppp_halt_loop      
        ret

_ppp_exit:
        pop hl
        pop hl
        jp introduction_exit


;==============================
txt_setup:          db 0x0A,"Runaway City (Meisou Toshi)",0x0D,0x0A
                    db "(c) 1995 JAST",0x0D,0x0A
                    db "(L) 2021 - 2025 Zorba (Transman/Triumf)",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Music powered by:",0x0D,0x0A
                    db "> TurbosoundFM S98 driver by NEO SPECTRUMAN",0x0D,0x0A
                    db "> ZXM-Moonsound OPL3 driver by Galstaff",0x0D,0x0A
                    db "> ZXM-Moonsound OPL4 MIDI driver by Zorba",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A,0x0D,0x0A
                    db "language setup",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. English (DOS)",0x0D,0x0A    
                    db "2. ",0x90,0xe3,0xe1,0xe1,0xaa,0xa8,0xa9," (The Asenheim Project)",0x0D,0x0A,0

txt_censor_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Censorship? (If available)",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. Yes",0x0D,0x0A
                    db "2. No",0x0D,0x0A
                    db 0

mus_gfx_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Music set",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. AY",0x0D,0x0A
                    db "2. TSFM [ s98 ]",0x0D,0x0A
                    db "3. OPL3 board [ VGM ]",0x0D,0x0A
                    db "4. OPL4 board [ MIDI ]",0x0D,0x0A
                    db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     
import_push:
        
        call store8000c000

        ld a,(load_buf1)
        SETPG8000

        ld a,(load_buf2)
        SETPGC000

        ld hl,0x8005  ;8005
        ld de,PUSH_DATA

        ld b,8 ;8
.l0:
        push bc


        push hl
        ld b,8
.l1:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz .l1
        pop hl

        set 6,H
        push hl
        ld b,8
.l2:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz .l2
        pop hl

        res 6,H
        set 5,H

        push hl
        ld b,8
.l3:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz .l3
        pop hl

        set 6,H
        push hl
        ld b,8
.l4:
        ld a,(hl)
        ld (de),a
        call DHL
        inc de
        djnz .l4
        pop hl

        res 6,H
        res 5,H
        inc hl

        pop bc
        djnz .l0
        jp restore8000c000