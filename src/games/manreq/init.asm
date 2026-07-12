ii_start
		DISP T_START
		ld e,6+0x80  //set TEXT mode  keep
		OS_SETGFX

		call clear_screen

		OS_GETMAINPAGES
;dehl=??N?a ???a?? o 0000,4000,8000,c000
        ld a,e
        ld (winpage1),a
        ld a,h
        ld (winpage2),a
        ld a,l
        ld (winpage3),a
		
		ld a,(user_scr0_high)
		ld (scr0high),a
		ld a,(user_scr0_low)
		ld (scr0low),a

		
        ld b,pagestbllen
        ld hl,pagestbl
.getpagesloop
        push bc,hl
        OS_NEWPAGE
		pop hl,bc
;        or a
;        jp nz,memoryerror
        ld (hl),e
        inc hl
        djnz .getpagesloop
		
        ld hl,txt_setup
        call print_hl
setup_lp:
        YIELDGETKEYLOOP
        cp "1"
        jr c,setup_lp
        cp "3"
        jr nc,setup_lp
		sub "1"
        ld (lang_mode),a		

        ld hl,mus_setup
        call print_hl
setup_mus_lp:
        YIELDGETKEYLOOP
        cp "1"
        jr c,setup_mus_lp
        cp "3"
        jr nc,setup_mus_lp
		sub "1"
		ld (mus_mode),a
		ld a,0xff
		ld (old_mus),a
;-----------------------------------------
		ld e,2+0x80  //set HW multicolor mode keep
		OS_SETGFX
		call clear_screen

;-----------------------------------------
;--load music player
		call set_music_pages

		ld a,(mus_mode)

		ld hl,plr_tabl
		call sel_word
		ld de,buf
		call copystr_hlde
		
		xor a
		ld (de),a
		ld de,buf
		call openstream_file
;		or a
;		jp nz,fileopenerror
		ld hl,0x8000 ;len
		ld de,player_load ;addr
		call readstream_file
;		or a
;		jp nz,filereaderror
		call closestream_file
.bypass_plr_load:
		call unset_music_pages
;----------------------------------------------------
;set PC-88 pALETTE
		ld de,pal
		ld hl,stdpal+16
		ld bc,16
		ldir
		ld hl,stdpal
		ld bc,16
		ldir
		ld a,1
        ld (setpalflag),a
;----------------------------------------------------
			jp int_set
			
			
			


txt_setup:
			db 0x0A," J.B. Harold Series #2: Manhattan Requiem - Angels Flying in the Dark",0x0D,0x0A
			db "(c) 1987 Riverhill Soft Inc.",0x0D,0x0A
			db "(L) 2026 Zorba",0x0D,0x0A
			db "----------------------------------------",0x0D,0x0A
			db "Music powered by:",0x0D,0x0A
			db "> TurbosoundFM S98 driver by NEO SPECTRUMAN",0x0D,0x0A
			db "----------------------------------------",0x0D,0x0A,0x0D,0x0A
			db "language setup",0x0D,0x0A
			db 0x0D,0x0A
			db "1. Japanese (original)",0x0D,0x0A
			db "2. ",0x90,0xe3,0xe1,0xe1,0xaa,0xa8,0xa9," (Fan-made translation)",0x0D,0x0A,0
mus_setup:
			db 0x0D,0x0A
			db "----------------------------------------",0x0D,0x0A
			db "Music device",0x0D,0x0A
			db 0x0D,0x0A
			db "1. AY",0x0D,0x0A
			db "2. TurbosoundFM",0x0D,0x0A
			db 0
			ENT
ii_end:
			savebin "jb2manreq/init.bin",ii_start,ii_end-ii_start