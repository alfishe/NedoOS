        DEVICE ZXSPECTRUM48
        include "../../_sdk/sys_h.asm"

		MACRO nextcolumnhl
		LD A,H
        XOR #20
        LD H,A
        BIT 5,H
        jr NZ,$+3
        INC HL
		ENDM
		
		MACRO nextcolumnde
		LD A,D
        XOR #20
        LD D,A
        BIT 5,D
        jr NZ,$+3
        inc de
		ENDM

		MACRO prevcolumnhl
		LD A,H
        XOR #20
        LD H,A
        BIT 5,H
        jr Z,$+3
        dec hl
		ENDM
		
		MACRO prevcolumnde
		LD A,D
        XOR #20
        LD D,A
        BIT 5,D
        jr Z,$+3
        dec de
		ENDM		
		
		
G_BUFFER1 = 0x8000
G_BUFFER2 = G_BUFFER1+6384*2
		
DEFAULT_DELAY = 0x0ff
SCROLL_LOCK = 0x400b

PLR_INIT  = 0x4000
PLR_PLAY  = 0x4005
PLR_MUTE  = 0x4008

module 		= 0xc000
player_load = 0x4000

IMG_BUFFER = 0x4000


TEXT_START = 0x4000


        org PROGSTART


cmd_begin:
			OS_HIDEFROMPARENT
			ld sp,sp_main
			jp start
;----stack------------			
			ds 128
sp_alt:
			ds 128
sp_main:
			ds 2
sp_ret
;---------------------

;--gamestate
gamestate:
gamestate_main:
        incbin "_common/gamestate_main.bin"
gamestate_fdc:
        incbin "_common/gamestate_fdc.bin"
gamestate_len = $-gamestate
		
;--some variables
				include "variables.asm"
;--some functions
				include "func.asm"
				include "../../_sdk/file.asm"
				
start:
			        ;go to resources directory
        ld de,res_path
        OS_CHDIR
						;or a
						;jp nz,dirchangeerror
;------------------------------------------	
;------- loading pre_setup		
		ld de,init_fname
		call openstream_file
						;		or a
						;		jp nz,fileopenerror
		ld hl,0x4000 ;len
		ld de,T_START ;addr
		call readstream_file
						;		or a
						;		jp nz,filereaderror
		call closestream_file
		call T_START
;------------------------------------------	
		
;------- loading intro
	    ld a,(lang_mode)
		ld hl,intro_s
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
		ld de,T_START ;addr
		call readstream_file
						;		or a
						;		jp nz,filereaderror
		call closestream_file
		call T_START
;------------------------------------------	
ze_start:	;fresh start after intro sequence

		ld sp,sp_main
        ld a,(winpage1)
		SETPG4000
        ld a,(winpage2)
		SETPG8000
        ld a,(winpage3)
		SETPGC000
		
		call store_48c
		call clear_loc_screen

		call load_card_image


;------------------------------------------		
; load executable		
	    ld a,(lang_mode)
		ld hl,exe_z
		call sel_word
		ld de,txt_mdl
		call copystr_hlde
;txt_mdl+5 == 4

	    ld a,(lang_mode)
		ld hl,exe_s
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
		ld de,T_START ;addr
		call readstream_file
						;		or a
						;		jp nz,filereaderror
		call closestream_file
		call restore_48c
;------------------------------------------		
		;executing game
		ld sp,sp_ret
		call T_START
;------- loading outro
	    ld a,(lang_mode)
		ld hl,outro_s
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
		ld de,T_START ;addr
		call readstream_file
						;		or a
						;		jp nz,filereaderror
		call closestream_file
		call T_START

		call no_mus
        ld e,6+0x80
        OS_SETGFX

        call int_reset

        ld hl,t_s98_file00_pages_list+$FF 
        call free_s98_file

        ld b,pagestbllen
        ld hl,pagestbl
.getpagesloop
        push bc,hl
        ld e,(hl)
        OS_DELPAGE
        pop hl,bc
        inc hl
        djnz .getpagesloop
        QUIT 
		
		
freestart = $




			align 256
T_START:










			



			

cmd_end:
		include "init.asm"
		include "intro_j.asm" ;jp version
		include "intro_r.asm" ;ru version
		include "outro_j.asm" ;jp version
		include "outro_r.asm" ;ru version

		
		include "exec_j.asm" ;jp version
		include "exec_r.asm" ;ru version

;		include "page4000j.asm" ;
;		include "page4000r.asm" ;
		LABELSLIST "..\..\..\us\user.l",1



		display "T_START: ",/d,T_START
		display "free space above T_START: ",/d,T_START-freestart
		
        savebin "jb2manreq.com",cmd_begin,cmd_end-cmd_begin






