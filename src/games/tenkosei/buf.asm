txt_setup:          db 0x0A,"Transfer student (Monmon Gakuen -Ten.ko.sei-)",0x0D,0x0A
                    db "(c) 1998-2002 JAST",0x0D,0x0A
                    db "(c) 2022 Transman/Triumpf",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "language setup",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. English",0x0D,0x0A    
                    db "2. ",0x90,0xe3,0xe1,0xe1,0xaa,0xa8,0xa9," (The Asenheim Project)",0x0D,0x0A,0
txt_censor_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Censorship? (If available)",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. Yes",0x0D,0x0A
                    db "2. No",0x0D,0x0A
                    db 0
txt_gfx_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Graphics set",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. DDp palette",0x0D,0x0A
                    db "2. ATM palette",0x0D,0x0A
;                    db "3. DDp palette (alt)",0x0D,0x0A
                    db 0

mus_gfx_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Music set",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. AY",0x0D,0x0A
                    db "2. TSFM ("
                    db 0

tsfm_is_not_detected:
                    db "not "
                    db 0


tsfm_is_detected:   db "detected)"
                    db 0x0D,0x0A
                    db 0
import_cursor:
        
        call store8000c000

        ld a,(load_buf1)
        SETPG8000

        ld a,(load_buf2)
        SETPGC000

        ld hl,0x8005+320
        ld de,CUR_DATA


        call import_cursor_uni

        jp restore8000c000
import_push:
        
        call store8000c000

        ld a,(load_buf1)
        SETPG8000

        ld a,(load_buf2)
        SETPGC000

        ld hl,0x8005
        ld de,PUSH_DATA

        ld b,7 ;8
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
/*        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (music_buf),a
*/
; get gfx load buffer  2 pages
        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (load_buf1),a
        ld (src_buf1),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (load_buf2),a
        ld (src_buf2),a

; get ingame gfx buffer pages 6 pages
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
        ld (mem_buf3),a

        OS_NEWPAGE
        or a
        jp nz,memoryerror
        ld a,e
        ld (mem_buf4),a

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
        ld (font_page),a


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

       ;jr skip_setup ;////!!!!!!!!!!!!!!!!!
       // заглушка для os_setmusic 
       // !!!!!! костыль !!!!!!
       call set_music_pages
       ld a,0xc9
       ld (0x9000),a
       call unset_music_pages

;language setup
;----------------------------------------
        ld hl,txt_setup
        call print_hl
setup_lp:        
        YIELDGETKEYLOOP
        cp "1"
        jr z,setup_is1
       cp "2"
       jr z,setup_is2
;        cp "3"
;        jr z,setup_is3
        jr setup_lp
setup_is1:
          xor a
          ;ld a,0
          jr setup_set
setup_is2:
         ld a,1
;          jr setup_set
;setup_is3:
;         ld a,2
setup_set:
        ld (language),a

        ld hl,loc_modes
        call sel_word
        ld de,SAVETEMPL_EXT
        ld bc,3
        ldir



        ld hl,txt_gfx_setup
        call print_hl
setup_glp:
        YIELDGETKEYLOOP
        cp "1"
        jr z,setup_gis1
       cp "2"
       jr z,setup_gis2
;       cp "3"
;       jr z,setup_gis3

        jr setup_glp
setup_gis1:
          xor a
          jr setup_gset
setup_gis2:
         ld a,1
;          jr setup_gset
;setup_gis3:
;         ld a,2
setup_gset:
        ld (gfx_mode),a


        push af
        ld hl,box_color_x
        call sel_word
        ld a,(hl)
        ld (_draw_box_color),a
        pop af
        ld hl,pal_mode
        call sel_word
        ld de,blackpal
        ld bc,pal_rgb-blackpal
        ldir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       setup music
        call tsfm_check
;        and a
;        jr z,_set_ay
        ld (tsfm_detected),a
        dec a
        ld (tsfm_mode),a
        

        
        ld hl,mus_gfx_setup
        call print_hl
        ld a,(tsfm_detected)
        and a
        jr nz,setup_mus_lop

        ld hl,tsfm_is_not_detected
        call print_hl
setup_mus_lop:
        ld hl,tsfm_is_detected
        call print_hl

setup_mus_lp:
        YIELDGETKEYLOOP
        cp "1"
        jr z,_set_ay
        cp "2"
        jr z,_set_tsfm
        jr setup_mus_lp



_set_tsfm:
        ld a,1
        jr _set_mu
_set_ay:
        xor a
_set_mu:
        ld (mus_mode),a
setup_gset2:
//        jr skip_setup ;////!!!!!!!!!!!!!!!!!
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
;setup is done 
;----------------------------------------

skip_setup:
;-----------------------------------------
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

                ld hl,0x4000 ;len
                ld de,player_load ;addr
                call readstream_file
                or a
                jp nz,filereaderror 

                call closestream_file



             call unset_music_pages
;load font 
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

; 5*8
              ld de,font_file2  
              call openstream_file
              or a
              jp nz,fileopenerror

              ld hl,0x1000 ;len
              ld de,FONT2 ;addr
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
        call import_cursor
;;

      
        ld a,(mem_buf1)
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
tsfm_check:
        call tsfm_check_mode1
        jp m,.next_none ;.next_check2
        ld a,1
        ret
//.next_check2:
//        call tsfm_check_mode2
//        jp m,.next_none
//        ld a,2
//        ret
.next_none:
        xor a
        ret
;-------------------------------------------
;tsfm type
;	if tsfm_type = 1
;sFFFD = $FFFD
;sFF   = $FF
;sBFFD = $BFFD
;sBF   = $BF
;
;sFFBF = $FFBF
;	endif
;------------------------------------------------------------------------------	
;	if tsfm_type = 2
;sFFFD = $7F3B
;sFF   = $7F
;sBFFD = $7E3B
;sBF   = $7E
;
;sFFBF = $7F7E
;	endif
tsfm_check_mode1:
	LD BC,0xFFFD
	LD A,%11111000
	OUT (C),A	;FM on,status rg read on

	ld d,$FF
1	dec d
	jr nz,1b	;pause
	
	XOR A
	OUT (C),A	;select rg 0
	
1	dec d
	jr nz,1b 	;pause
	
	LD B,0xBF
	OUT (C),B	;write some data in rg 0
	
1	dec d
	jr nz,1b	;pause
	
	inc a		;a=1
	LD B,0xFF
	IN F,(c)	;read status (P=ready)
	
;	jp m,tsfm_absent
        ret



tsfm_check_mode2:
	LD BC,0x7F3B
	LD A,%11111000
	OUT (C),A	;FM on,status rg read on

	ld d,$FF
1	dec d
	jr nz,1b	;pause
	
	XOR A
	OUT (C),A	;select rg 0
	
1	dec d
	jr nz,1b 	;pause
	
	LD B,0x7e
	OUT (C),B	;write some data in rg 0
	
1	dec d
	jr nz,1b	;pause
	
	inc a		;a=1
	LD B,0x7f
	IN F,(c)	;read status (P=ready)
;	jp m,tsfm_absent
        ret