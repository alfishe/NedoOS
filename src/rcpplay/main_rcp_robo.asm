        DEVICE ZXSPECTRUM48
        include "../_sdk/sys_h.asm"
AREA_C000_FFFF   equ 1

MDLADDR = 0xc000

MAX_NR_OF_TRACKS = 18
NR_OF_MIDI_CHANNELS = 16
NR_OF_WAVE_CHANNELS = 16 ;24


TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 210
MEMORYSTREAMERRORMASK = 255

DRUM_CHANNEL = 9

DEFAULT_QNOTE_DURATION_MCS = 500000
VSYNC_FREQ = 49
VSYNC_MCS = 1000000/VSYNC_FREQ

sp_main equ 0xC000

        org PROGSTART

cmd_begin
        ld sp,sp_main
        ld e,6+0x80  //set TEXT mode  keep
        OS_SETGFX
        ld e,7
        OS_CLS

        OS_GETMAINPAGES
        ;dehl= o 0000,4000,8000,c000
        ld a,d
        ld (winpage0),a
        ld a,e
        ld (winpage1),a
        ld a,h
        ld (winpage2),a
        ld a,l
        ld (winpage3),a
		
		ld hl,COMMANDLINE ;command line
		call skipword
		call skipspaces
		ld a,(hl)
		or a
		jp z,.exit_no_rcp
		
		
        push hl
        ld hl,plr_info
        call print_hl: call print_nl
        call check_available_memory
        call init_opl4_device
		call generate_tables
		
            ld hl,mes_nowplay
            call print_hl
            call print_nl
        pop hl
        push hl
            call print_hl
            call print_nl            
            call print_nl
        pop hl
		
        call load_init_rcp

		call show_song_info

        ld hl,song_title_buf
        call print_hl

.play_rewind:
        call rewind

.play_loop
        call rcp_play
;out  ;a 0 track still play  !0 - finished        
        jr z,.play_rewind ;play_exit

        GET_KEY
        cp " "
        jr nz,.play_loop

.play_exit      		
        call opl4mute
        call opl4_reset
        call memorystreamfree
.exit
        QUIT

.exit_no_rcp:
        ld hl,mes_no_rcp_file
printerrorandexit:
		call print_hl
		ld hl,pressanykeystr
		call print_hl
		YIELDGETKEYLOOP
		jr cmd_begin.play_exit

		include "../_sdk/file.asm"
		include "../_sdk/string.asm"


new_line_string defb "\n\r"


skipword
;hl=string
;out: hl=terminator/space addr
getword0
		ld a,(hl)
		or a
		ret z
		cp " "
		ret z
		inc hl
		jr getword0	
skipspaces
;hl=string
;out: hl=after last space
		ld a,(hl)
		cp ' '
		ret nz
		inc hl
		jr skipspaces
		
		
		include "common/opl4.asm"
		include "common/opl.asm"

		include "common/memorystream.asm"
		include "common/muldiv.asm"
		include "common/rcp_robo.asm"
		include "common/rcpload.asm"
		
;--------------------------
check_available_memory:

        call print_nl
        ld hl,mes_mem_available
        call print_hl
        call mem_check
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
        call printushort_hl
        ld hl,msg_opl_is_detected2
        call print_hl
        jp print_nl



mem_check:
        ld d,0
        ld e,0
.loop
        push de
        dec e
        OS_GETPAGEOWNER
        ld a,e
        pop de

        and a
        jr nz,.ll
        inc d
.ll:
        dec e
        jr nz,.loop 
        ld h,0
        ld l,d
        ret       


mes_nowplay:
    db "Now playing: ",0
	
mes_not_rcp_error:
		db "Not ReComposer file",0

mes_loadError
		db "Can't load file.",0

pressanykeystr
		db "\r\nPress any key to continue...\r\n",0
firmwareerrorstr
		db "\r\nfirmware problem!\r\nPlease update ZXM-MoonSound firmware to revision 1.01\r\n",0

noYRW801mes:
		db "\r\nYRW801 not found...\r\n",0
romYRW801mes:
        db "\r\nYRW801 ROM version a.a\r\n",0
romYRW801mes_v1 equ $-6
romYRW801mes_v2 equ $-4

mes_tracks:
		db "Number of tracks : ",0 
mes_detected_tracks:
		db "Detected tracks : ",0 
		
		include "yrw801/yrw801imap_robo.asm"
		include "yrw801/pitch_table.asm"

winpage0:   db 0
winpage1:   db 0
winpage2:   db 0
winpage3:   db 0

rom001200   db "CopyrightYAMAHA"
oplbuff:    ds 15,0

plr_info    db "Recomposer v2.x player (Wave) V0.3 For ZXM-MoonSound by Zorba (l)2025",0
mes_mem_available DB "Memory available: ",0

mes_no_rcp_file DB "Error! No RCP file specified.",0

tick_counter	ds 4

song_title_buf: ds 64,0
                db 0


g_ticks_per_update_high dw 0

g_volume_boost db 32

n_on_voices          db 0  
n_on_data            ds  8,0   ; dw wave_data, dw voice_data

n_on_data_ptr        dw 0

g_header   MIDI_HEADER

                align 256
				
midi_ch_table: ds NR_OF_MIDI_CHANNELS*2,0





cmd_end:

        display "end ",/d,cmd_end," bytes"
        savebin "rcpplay.com",cmd_begin,cmd_end-cmd_begin
        LABELSLIST "..\..\us\user.l",1