; SMF player for ZXM-MoonSound (OPL4)

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"
	
	org PLAYERSTART

begin   PLAYERHEADER
isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
ismoonsounddisabled=$+1
	jr nosupportedfiles
	call ismidfile
	ret nz
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress
nosupportedfiles
	or 1
	ret
	
ismidfile
;cde = file extension
;out: zf=1 if .mod, zf=0 otherwise
	ld a,'m'
	cp c
	ret nz
	ld a,'i'
	cp d
	ret nz
	ld a,'d'
	cp e
	ret
	
playerinit
;hl,ix = GPSETTINGS
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld (.settingsaddr),hl
	ld a,(ix+GPSETTINGS.moonsoundstatus)
	cp 2
	ld hl,nodevicestr
	ret nz
;init additional tables
	OS_NEWPAGE
	or a
	ld hl,outofmemorystr
	ret nz
	ld a,e
	push af
	SETPGC000
;move additional tables to its own page
	ld hl,opl4tables
	ld de,0xc000
	ld bc,opl4tables_end-opl4tables
	ldir
;start initing vars after the table was copied
	pop af
	ld (opl4tablespage),a
.settingsaddr=$+2
	ld ix,0
	ld hl,initokstr
	xor a
	ld (ismoonsounddisabled),a
	ret
	
playerdeinit
opl4tablespage=$+1
	ld e,0
	OS_DELPAGE
	ret	
	
musicload:	
	call midloadfile
	xor a
	ld hl,DEVICE_MOONSOUND_MASK
	ret

musicunload
	jp midunload	
	
musicplay
;out: zf=0 if still playing, zf=1 otherwise
	jp midplay
	
	
MAX_NR_OF_TRACKS = 64
NR_OF_MIDI_CHANNELS = 16
NR_OF_WAVE_CHANNELS = 24


TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 210
MEMORYSTREAMERRORMASK = 255

DRUM_CHANNEL = 9

DEFAULT_QNOTE_DURATION_MCS = 500000
VSYNC_FREQ = 46 ;49 ;46
VSYNC_MCS = 1000000/VSYNC_FREQ





	
	include "../_sdk/file.asm"
	include "common/opl4.asm"
	include "moonmid/midi_def.asm"
	include "moonmid/opl.asm"
	include "moonmid/moonsound.asm"
	
	
	include "common/memorystream.asm"
	include "common/muldiv.asm"
	include "moonmid/muldiv.asm"
	include "moonmid/mnmid.asm"
	include "progress.asm"	
	
	
	
	
	
	
midloadfile
;hl = input file name
;out: zf=1 if loaded, zf=0 otherwise
	ex de,hl
	call memorystreamloadfile
	ret nz
	call memorystreamstart

;init midi file	
	ld b,midheadersigsize
	ld de,midheadersig
	call midchecksignature 
	ret nz

	memory_stream_read_2 c,a
/*file type*/
	;c a - midi file  format ; 0x0000,0x0001,0x0002
	cp 3
	ret nc
	ld (g_header.file_format),a

/*tracks count*/
	memory_stream_read_2 c,a
	ld (g_header.number_of_tracks),a

	add a,-MAX_NR_OF_TRACKS-1
	sbc a,a
	ret nz

	memory_stream_read_2 b,c
	ld a,c
	ld (g_header.ticks_per_qnote),a
	ld a,b
	ld (g_header.ticks_per_qnote+1),a
	ld de,VSYNC_MCS
	call uintmul16
	add hl,hl : rl de
	add hl,hl : rl de
	ld (g_header.ticksperqnoteXupdatelen+0),hl
	ld (g_header.ticksperqnoteXupdatelen+2),de

	ld a,16
	ld (g_volume_boost),a
	
	ld a,SNDRV_MIDI_MODE_GM
	ld (g_header.midi_mode),a
	
	ld a,127
	ld (g_header.gs_master_volume),a
	
	call midloadtracks
	jp nz,memorystreamfree ;sets zf=0
	call rewind
	
	call midsetprogressdelta
	call rewind
	
	call set_refresh
;	call opl4_reset
	call opl4init
    jp generate_tables	
	
midunload
	call opl4_reset
	call opl4mute
	jp memorystreamfree
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
	include "moonmid/pitch_table.asm"
	
playernamestr
	db "MoonSound MIDI",0
outofmemorystr
	db "Out of memory!",0
initokstr
	db "OK\r\n",0
nodevicestr
	db "no device!\r\n",0

tempmemorystart = $
opl4tables
	DISP 0xc000
	include "moonmid/yrw801imap_robo.asm"
	ENT	
opl4tables_end
end

	savebin "moonmid.bin",begin,end-begin


					org tempmemorystart
newtareastart					
free_voice:     	ds 2
oldest_voice:   	ds 2
g_ticks_per_update  ds 4,0
g_MIDI_counter 		ds 4,0
g_volume_boost 		ds 1,16
n_on_voices         ds 1,0  
n_on_data           ds 8,0   ; dw wave_data, dw voice_data
n_on_data_ptr       ds 2
g_header   			MIDI_HEADER
					align 256
midi_ch_table: 		ds NR_OF_MIDI_CHANNELS*2,0
newtareaend




	display "moonmid load = ",/d,end-begin," bytes"
	display "moonmid work = ",/d,newtareaend-begin," bytes"
	display "sample table = ",/d,opl4tables_end-opl4tables," bytes"