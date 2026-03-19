pre_setup:          db 0x0A,"Season of the Sakura (Sakura no Kisetsu)",0x0D,0x0A
                    db "Version 1.03",0x0D,0x0A
                    db "(c) 1996 JAST",0x0D,0x0A
                    db "(L) 2024 Zorba (Transman/Triumf)",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Music powered by:",0x0D,0x0A
                    db "> TurbosoundFM S98 driver by NEO SPECTRUMAN",0x0D,0x0A
                    db "> ZXM-Moonsound OPL3 driver by Galstaff",0x0D,0x0A
                    db "> ZXM-Moonsound OPL4 MIDI driver by Zorba",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A,0x0D,0x0A

txt_setup:          db 0x0D,0x0A,"language setup",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. English (DOS)",0x0D,0x0A
                    db "2. English (Jast USA memorial collection)",0x0D,0x0A     
                    db "3. ",0x90,0xe3,0xe1,0xe1,0xaa,0xa8,0xa9,0     

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

txt_censor_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Censorship? (If available)",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. Yes",0x0D,0x0A
                    db "2. No",0x0D,0x0A
                    db 0   


txt_pefomance_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Visual Enchancements? (14 MHz or greater)",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. Yes",0x0D,0x0A
                    db "2. No",0x0D,0x0A
                    db 0   


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

;buf_ext             ds 538-(buf_ext-txt_setup),0





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

pre_init
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


; get gfx load buffer  2 pages
        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (zx0_page),a

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

; get ingame gfx buffer pages 4 pages
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

;== font page
        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (font_page),a
;== additional executable page at $4000
        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (core_page),a

;== 3 pages for player
eerra:
        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (plr_page),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (plr_page2),a


        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (plr_page3),a


        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (anim_slot03),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (anim_slot47),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (anim_slot811),a

       call set_music_pages
       ld a,0xc9
       ld (0x9000),a
       call unset_music_pages

;==========================================
;== setup language
        ld hl,pre_setup
        call print_hl

to_lang:
;==========================================

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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
setup_gset2:
;censor setup
;----------------------------------------
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


        ld hl,txt_pefomance_setup
        call print_hl
setup_plpc:        
        YIELDGETKEYLOOP
        cp "1"
        jr z,skip_setup
        cp "2"
        jr z,setup_pisc2
        jr setup_plpc
setup_pisc2:
        ld a,0xc9
         ld   (eyes_perfomance),a
         ld (petals_perfomance),a

          
;----------------------------------------
skip_setup:
        ;go to resources directory
        ld de,res_path
        OS_CHDIR
        or a
        jp nz,dirchangeerror

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


loadfont:
; 4*8
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

loadcorepage:
              call setcorepage
              ld de,core_file  
              call openstream_file
              or a
              jp nz,fileopenerror

              ld hl,0x4000 ;len
              ld de,0x4000 ;addr
              call readstream_file
              or a
              jp nz,filereaderror 

              call closestream_file


        ;load star
        ld hl,tiare_p1
        call load_anim_pre_sub
        ld de,tiare_p1_spr
        ld hl,256
        call readstream_file
        or a
        jp nz,filereaderror
        
        ld hl,tiare_p2
        call load_anim_pre_sub
        ld de,tiare_p2_spr
        ld hl,256
        call readstream_file
        or a
        jp nz,filereaderror

        ;load sakura petals
        ld hl,saku_leaf
        call load_anim_pre_sub
        ld de,leaf_spr
        ld hl,672
        call readstream_file
        or a
        jp nz,filereaderror
                



leaftablesgen:
;generate 256 bytes long tables
;

;step 2: generate initial x positions table for petals
                     ld hl,y_coord_tbl
                     ld b,0 
                     ld d,100

.ll_a2:                 call randr
                        cp d
                        jr nc,.ll_a2
                        ld (hl),a  ; y pos        ;*1
                        inc hl
                     djnz    .ll_a2

;step 3: generate x direction and speed  table for petals
                     ld hl,x_speed_tbl
                     ld b,0 
                     ld d,5
.ll_a3:                 call randr
                        and 7
                        cp d
                        jr nc,.ll_a3
                        sub 2
                        ld (hl),a  ; direction   fd fe ff - left 0-down 1 2 3- right *2
                        inc hl
                     djnz    .ll_a3

;step 4: generate initial petals fase table
                     ld hl,xy_init_fase
                     ld b,0 
                        ld d,20
.ll_a4:                 call randr
                        and 31
                        cp d
                        jr nc,.ll_a4
                        ld (hl),a  ; initial sprite fase 0-19       *3
                        inc hl
                     djnz    .ll_a4


;step 5: generate y speed table for petals
                        ld hl,y_speed_tbl
                        ld b,0
                        ld d,2
.ll_a6:                 call randr
                        and 3
                        cp d
                        jr nc,.ll_a6
                        inc a
                        ld (hl),a  ; desired y - speed 1-2        *4
                        inc hl
                        djnz .ll_a6

;step 6: generate x moving distance for petals 
                        ld hl,x_moving_distance
                        ld b,0
.ll_a7:
                       call randr
                        and 15
                        inc a
                        ld (hl),a  ; x-axis movind distance        *5
                        inc hl
                        djnz .ll_a7

;step 7: generate time to change petal fase
                        ld hl,petal_fase_change_time
                        ld b,0
.ll_a8:
                       call randr
                        and 15
                        inc a
                        ld (hl),a  ;
                        inc hl
                        djnz .ll_a8


              call unsetcorepage

        call int_set





        ;set mode
        ld e,0+0x80  ;+8  //set EGA mode keep
        OS_SETGFX

        xor a
        out (0xfe),a

        
        YIELD


;prepare animation
        call clear_screen



        ld hl,anim_w
        call load_gfx_to_load_buf_nopal
        call import_push
;===clear_memory bufer
        ld a,(mem_buf1)
        call pg_clr
        ld a,(mem_buf2)
pg_clr:
        SETPGC000
        ld hl,0xc000
        ld de,0xc001
        ld bc,16383
        ld (hl),0
        ldir
        ret
