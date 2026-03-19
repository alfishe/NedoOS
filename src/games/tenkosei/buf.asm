
MOON_BASE = 0xc4
MOON_REG1 = MOON_BASE
MOON_DAT1 = MOON_BASE+1
MOON_REG2 = MOON_BASE+2
MOON_DAT2 = MOON_BASE+3
MOON_STAT = MOON_BASE
MOON_WREG = 0xc2
MOON_WDAT = MOON_WREG+1

OPN_REG = $FFFD
OPN_DAT = $BFFD


	macro switch_to_pcm_ports_c2_c3
	in a,(MOON_REG2)
	endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
memoryerror2:
        pop hl,bc
        jp memoryerror
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

        ld a,(load_buf1)
        ld (src_buf1),a
        ld a,(load_buf2)
        ld (src_buf2),a


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
        jr setup_lp
setup_is1:
          xor a
          jr setup_set
setup_is2:
         ld a,1
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

        jr setup_glp
setup_gis1:
        xor a
        jr setup_gset
setup_gis2:
        ld a,1
setup_gset:
        ld (gfx_mode_base),a
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
        ld bc,blackpallen
        ldir

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       setup music
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
        ld (tsfm_detected),a
        jr _set_mu
_set_ay:
        xor a
_set_mu:
        ld (mus_mode),a

        call tsfm_check

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
                and a
                jp z,.bypass_plr_load

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
.bypass_plr_load
             call unset_music_pages

        ld a,(mus_mode)
        and a
        jp nz,.bypass_nomus_setup
        ld a,0xc9
        ld (free_s98_file),a
        ld (load_mus),a
.bypass_nomus_setup:

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

            ld a,(mus_mode)
            and a
            jr z,.bypass_sfxinit

                ld a,(tsfm_detected)
                and a
                push af
                call nz,ym_reset
                pop af
                call nz,set_ay1
                
                ld hl,sfxdata
                call   ayfx.INIT

                ld a,(tsfm_detected)
                and a
                call nz,set_ay0
.bypass_sfxinit:
              call unsetcorepage

        ;set mode
        ld e,0+0x80  //set EGA mode keep
        OS_SETGFX

;prepare animation
        call clear_screen

        ld hl,anim_w
        call load_gfx_to_load_buf_nopal
        call import_push
        call import_cursor
        call clrsa
        jp int_set
clrsa:
        ld a,(mem_buf1)
        call clrsr
        ld a,(mem_buf2)
clrsr:
        SETPGC000
        ld hl,0xc000
        ld de,0xc001
        ld bc,16383
        ld (hl),0
        ldir
        ret




tsfm_check
	LD BC,OPN_REG
	LD A,%11111000
	OUT (C),A	;FM on,status rg read on

	ld d,$FF
1	dec d
	jr nz,1b	;pause
	
	XOR A
	OUT (C),A	;select rg 0
	
1	dec d
	jr nz,1b 	;pause
	
	LD B,HIGH OPN_DAT
	OUT (C),B	;write some data in rg 0
	
1	dec d
	jr nz,1b	;pause
	
	inc a		;a=1
	LD B,HIGH OPN_REG
	IN F,(c)	;read status (P=ready)
        
	ld a,0
        jp m,.no_tsfm
        inc a
.no_tsfm
        ld (tsfm_detected),a
        ret


ym_reset
        
;rhythm_mute
			;xor a
			;ld (rhythm_voldown),a	;out off
	
	ld a,%11111001	;chip2
	ld bc,OPN_REG
	out (c),a

	call ym_reset_1
	
	ld a,%11111000	;chip1
	ld b,HIGH OPN_REG
	out (c),a
	
	call ym_reset_1
	
	ret

ym_reset_1
	
	
		ld a,$0D	;a start reg	0D...00		SSG
		ld hl,$00FF	;h 00 reset
				;l last reg-1
		call ym_reset_loop
		
		ld a,$B3	;		B3...50		FM
		ld l,$4F	;
		call ym_reset_loop
		
		ld a,$3F	;		3F...30		DETUNE MUL
		ld l,$2F	;
		call ym_reset_loop
		
		ld a,$07	;a reg		07		SSG MIXER
		ld h,$F8	;h F8 reset
		call ym_reset_write	
		
		ld a,$8F	;a start reg	8F...80		SUSTAIN RELEASE
		ld hl,$0F7F	;h 0F reset
		;		;l last reg-1
		call ym_reset_loop
	
	
		ld a,$28	;a start reg	28		KEY OFF CH1
		ld h,$00	;h 00 reset
		call ym_reset_write
		
		;ld a,$28	;a start reg	28		KEY OFF CH2
		ld hl,$01	;h 00 reset
		call ym_reset_write
		
		;ld a,$28	;a start reg	28		KEY OFF CH3
		ld hl,$02	;h 00 reset
		call ym_reset_write		
	
		ld a,$27	;a start reg	27		TIMER
		ld hl,$02	;h 00 reset
		call ym_reset_write		


		ld a,$4F	;a start reg	4F...40		TOTAL LEVEL
		ld hl,$7F3F	;h 00 reset
		;		;l last reg-1
		call ym_reset_loop		
	
	

		ld a,$2F	;a start reg	2F		PRESCALER
		ld h,$7F	;h 00 reset
		call ym_reset_write	
		

		ld a,$2D	;a start reg	2D		PRESCALER
		ld hl,$7F	;h 00 reset
		call ym_reset_write	
	
		ret					
		
;------------------------------------------------------------------------------
ym_reset_loop
		call ym_reset_write
		dec a
		cp l
		jr nz,ym_reset_loop	;if =>
		ret
		
;------------------------------------------------------------------------------	
ym_reset_write
			ld bc,OPN_REG
2				
                                nop
                                nop
                                in f,(c)
				jp m,2B
			out (c),a
			
2				
                                nop
                                nop
                                in f,(c)
				jp m,2B
			ld b,HIGH OPN_DAT		;FD
			out (c),h

			ret
					
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


txt_setup:          db 0x0A,"Transfer student (Monmon Gakuen -Ten.ko.sei-)",0x0D,0x0A
                    db "(c) 1998-2002 JAST",0x0D,0x0A
                    db "(c) 2022-2025 Zorba (Transman/Triumpf)",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Music powered by:",0x0D,0x0A
                    db "> TurbosoundFM S98 driver by NEO SPECTRUMAN",0x0D,0x0A
                    db "> ZXM-Moonsound OPL3 driver by Galstaff",0x0D,0x0A
                    db "> ZXM-Moonsound OPL4 MIDI driver by Zorba",0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A,0x0D,0x0A
                    db 0x0D,0x0A,0x0D,0x0A
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
                    db 0

mus_gfx_setup:
                    db 0x0D,0x0A
                    db "----------------------------------------",0x0D,0x0A
                    db "Music device",0x0D,0x0A
                    db 0x0D,0x0A
                    db "1. None",0x0D,0x0A
                    db "2. TurbosoundFM",0x0D,0x0A
                    db "3. OPL3 board [ BomgeMoon ]",0x0D,0x0A
                    db "4. OPL4 board [ ZXM-Moonsound ]",0x0D,0x0A
                    db 0