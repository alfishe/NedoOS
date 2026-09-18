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
		LD A,D			;1
        XOR #20			;2
        LD D,A			;1
        BIT 5,D			;2
        jr NZ,$+3		;2
        inc de			;1
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
		
G_BUFFER1 = 0x8000
G_BUFFER2 = G_BUFFER1+6384*2
G_BUFFER3 = 0xC000
		
DEFAULT_DELAY = 0x0ff
SCROLL_LOCK = 0x400b

player_load = 0x4000
p_init = 0x4000
p_play = 0x4002
p_mute = 0x4005
mus_end = 0x4008
p_mod   = 0x4009
p_advance = 0x400c
p_unmod   = 0x400f

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
        include "_common/gamestate_main.asm"
gamestate_fdc:
        include "_common/gamestate_fdc.asm"
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
						
;------- loading intro
		ld de,intro_fname
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


		call no_mus
		call store_48c
		call clear_loc_screen		
;----		
		ld de,pal
		ld hl,stdpal+16
		ld bc,16
		ldir
		ld hl,stdpal
		ld bc,16
		ldir
		ld a,1
        ld (setpalflag),a
		
		ld hl,pal
		ld de,mempal
		ld bc,32
		ldir
;----		
		ld e,0
		OS_SETSCREEN
		
		
		call set_music_pages
		ld a,(mus_mode)
		ld hl,plr_tabl_game
		call sel_word
		ex de,hl
		call openstream_file
						;		or a : jp nz,fileopenerror
		ld hl,0x8000 ;len
		ld de,player_load ;addr
		call readstream_file
						;		or a : jp nz,fileopenerror
		call closestream_file
		call unset_music_pages
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<	
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
						;		or a : jp nz,fileopenerror
		ld hl,0x8000 ;len
		ld de,T_START ;addr
		call readstream_file
						;		or a : jp nz,fileopenerror
		call closestream_file
		call restore_48c
		
;------------------------------------------		
		;executing game
		ld sp,sp_ret
		call T_START
;------- loading outro
j_outro:
		ld de,outro_fname
		call openstream_file
						;		or a : jp nz,fileopenerror
		ld hl,0x8000 ;len
		ld de,T_START ;addr
		call readstream_file
						;		or a : jp nz,fileopenerror
		call closestream_file
		call T_START

		call no_mus
        ld e,6+0x80
        OS_SETGFX

        call int_reset

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
		include "intro.asm" 
		include "outro.asm" 

		
		include "exec_j.asm" ;jp version
		include "exec_r.asm" ;ru version

		display "T_START: ",/d,T_START
		display "free space above T_START: ",/d,T_START-freestart
		
        savebin "kissofmurder.com",cmd_begin,cmd_end-cmd_begin


        org PROGSTART
		include "opn_plr1.asm" ;OPN player for intro
		include "opn_plr.asm" ;OPN player for game
		include "ay_plr1.asm" ;AY player for intro
		include "ay_plr.asm" ;AY player for game

		LABELSLIST "..\..\..\us\user.l",1










