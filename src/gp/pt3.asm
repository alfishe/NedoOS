; ProTracker modules player for AY8910/TurboSound
; Player for MIDI UART connected to AY port A.2 (e.g. ZX MultiSound)

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

MDLADDR = 0x8000
TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 210
MEMORYSTREAMERRORMASK = 255
MIDMAXTRACKS = 64
MIDCHANNELS = 16

	struct MIDTRACK
lastcommand ds 1
nexteventtick ds 4
streamoffset ds 4
	ends

	struct MIDPLAYER
filetype ds 1
trackcount ds 1
tickcounter ds 4
ticksperupdate ds 4
ticksperqnoteXupdatelen ds 4
tracks ds MIDTRACK*MIDMAXTRACKS
	ends

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
	call ismidfile
	jr nz,.checkpt
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress
.checkpt
	ld a,c
	cp 'p'
	ret nz
	ld a,d
	cp 't'
	ret nz
	ld a,e
	cp '2'
	jr nz,.checkpt3
;prepare local variables
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld (MUSICPROGRESSADDR),hl
	ret
.checkpt3
	cp '3'
	ret nz
;prepare local variables
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress

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
;hl = GPSETTINGS
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld (playerpage),a
	call setuartdelay
	ld a,(hl)
	ld (page8000),a
	inc hl
	ld a,(hl)
	ld (pageC000),a
	ld a,(waitspincount)
	or a
	call z,initwaitspincount
	ld hl,initokstr
	xor a
	ret

setuartdelay
	push hl
	pop ix
	ld de,(ix+GPSETTINGS.midiuartdelayoverride)
	ld a,d
	or e
	ret z
	ld bc,3*256
.loop	ld a,(de)
	sub '0'
	jr c,.done
	cp 10
	jr nc,.done
	ld (.digit),a
	ld a,c
	add a,a
	ld c,a
	add a,a
	add a,a
	add a,c
.digit=$+1
	add a,0
	ld c,a
	inc de
	djnz .loop
.done	ld a,c
	ld (waitspincount),a
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
;out: zf=1 if the file is ready for playing, zf=0 otherwise
	call ismidfile
	jr nz,.ptfile
	call midloadfile
	ret nz
	ld a,255
	ld (isplayingmidfile),a
	xor a
	ret
.ptfile	ex de,hl
	call openstream_file
	or a
	ret nz
page8000=$+1
	ld a,0
	SETPG8000
pageC000=$+1
	ld a,0
	SETPGC000
	ld de,MDLADDR
	ld hl,de
	call readstream_file
	push hl
	call closestream_file
	pop ix
	call getconfig
	ld (SETUP),a
	ld de,MDLADDR
	add hl,de
	ex hl,de
	call INIT
playerpage=$+1
	ld a,0
	ld hl,PLAY
	OS_SETMUSIC
	xor a
	ld (isplayingmidfile),a
	ret

musicunload
	ld a,(isplayingmidfile)
	or a
	jp nz,midunload
	ld a,(playerpage)
	ld hl,play_reter
	OS_SETMUSIC
	jp MUTE

play_reter
	ret

musicplay
;out: zf=0 if still playing, zf=1 otherwise
	ld a,(isplayingmidfile)
	or a
	jp nz,midplay
	YIELD
	YIELD
	YIELD
	YIELD
	YIELD
	ld a,(SETUP)
	and 2
	ld a,(VARS1+VRS.CurPos)
	call z,updateprogress
	ld a,(SETUP)
	cpl
	and 128
	ret

findts
;ix = file size
;out: zf = 1 if TS data is found, hl = offset to the second module if available
	ld de,MDLADDR
	add ix,de ;past-the-end address of the data buffer
	ld a,'0'
	cp (ix-4)
	ret nz
	ld a,'2'
	cp (ix-3)
	ret nz
	ld a,'T'
	cp (ix-2)
	ret nz
	ld a,'S'
	cp (ix-1)
	ret nz
	ld hl,(ix-12)
	ret

getconfig
;ix = file size
;out: a = player config bits, hl = offset to the second module if available
	ld a,(MDLADDR)
	cp 'V'
	jr z,.ispt3
	cp 'P'
	jr z,.ispt3
	ld a,%00000011 ;PT2
	ret
.ispt3
	ld a,(MDLADDR+101)
	call setprogressdelta
;set title
	ld hl,titlestr
	ld (MUSICTITLEADDR),hl
	ld de,titlestr+1
	ld bc,TITLELENGTH-1
	ld (hl),' '
	ldir
	xor a
	ld (de),a
	ld hl,titlestr-1
	ld de,MDLADDR+30
	ld bc,68*256+TITLELENGTH
.copytitleloop
	ld a,(de)
	inc de
	cp ' '
	jr nz,$+5
	cp (hl)
	jr z,$+7
	inc hl
	ld (hl),a
	dec c
	jr z,$+4
	djnz .copytitleloop
	call findts
	ld a,%00010001 ;2xPT3
	ret z
	ld a,%00100001 ;PT3
	ret

	include "../_sdk/file.asm"
	include "ptsplay/ptsplay.asm"
	include "common/memorystream.asm"
	include "common/muldiv.asm"
	include "progress.asm"

VSYNC_FREQ = 49
BAUD_RATE = 31250
WAIT_LOOP_TSTATES = 14
BENCHMARK_LOOP_TSTATES = 42
DEFAULT_QNOTE_DURATION_MCS = 500000

VSYNC_MCS = 1000000/VSYNC_FREQ
CC1 = WAIT_LOOP_TSTATES*BAUD_RATE
CC2 = (VSYNC_FREQ*BENCHMARK_LOOP_TSTATES*65536+CC1/2)/CC1

SSG_REG = 0xfffd
SSG_DAT = 0xbffd

	macro wait_32us reducebytstates
	ld a,(waitspincount)
	add a,-(20+reducebytstates+7)/14
	dec a
	jp nz,$-1
	endm

midinitport
	ld bc,SSG_REG
	ld a,0xff
	out (c),a
	ld a,7
	out (c),a
	ld bc,SSG_DAT
	ld a,0xfc
	out (c),a
	ret

midsend3
;dhl = data
	call midsendbyte
midsend2
;hl = data
	ld d,h
	call midsendbyte
	ld d,l
midsendbyte
;d = data
	di
	ld bc,SSG_REG
	ld a,14
	out (c),a
	ld bc,SSG_DAT
	ld a,%11111010
	out (c),a
	wait_32us 42
	scf
	rr d
.loop	sbc a,a
	and %00000100
	add a,%11111010
	out (c),a
	wait_32us 48
	srl d
	jp nz,.loop
	nop
	nop
	nop
	ld a,%11111110
	out (c),a
	wait_32us 0
	ei
	ret

initwaitspincount
	call swapinterrupthandler ;avoid OS while benchmarking
	halt
	ld hl,0
	ld e,0
	xor a
	ld (.spincount),a
	ld a,33
	halt
;--> 42 t-states loop start
.loop	inc e
	jp nz,$+4
	inc hl
	nop
.spincount=$+1
	ld bc,0
	cp c
	jp nc,.loop
;<-- loop end
	push de
	push hl
	call swapinterrupthandler ;restore OS handler
	pop hl
	pop de
;hl = hle / 32
	sla e : adc hl,hl
	sla e : adc hl,hl
	sla e : adc hl,hl
	ld (framelength),hl
	ex de,hl
	ld bc,CC2
	call uintmul16
	xor a
	rl h
	adc a,e
	ld (waitspincount),a
	ret

swapinterrupthandler
	di
	ld hl,.store
	ld de,0x38
	ld b,3
.loop	ld a,(de)
	ld c,(hl)
	ld (hl),a
	ld a,c
	ld (de),a
	inc hl
	inc de
	djnz .loop
	ei
	ret
.store	jp lightweightinterrupthandler

lightweightinterrupthandler
	push af
	push hl
	ld hl,initwaitspincount.spincount
	inc (hl)
	pop hl
	pop af
	ei
	ret

midloadfile
;hl = input file name
;out: zf=1 if loaded, zf=0 otherwise
	ex de,hl
	call memorystreamloadfile
	ret nz
	ld hl,midplayer
	ld de,midplayer+1
	ld bc,MIDPLAYER-1
	ld (hl),0
	ldir
	call memorystreamstart
	ld b,midheadersigsize
	ld de,midheadersig
	call midchecksignature
	jp nz,memorystreamfree ;sets zf=0
	memory_stream_read_2 c,a
	ld (midplayer.filetype),a
	memory_stream_read_2 c,a
	ld (midplayer.trackcount),a
	add a,-MIDMAXTRACKS-1
	sbc a,a
	ret nz
	memory_stream_read_2 b,c
	ld de,VSYNC_MCS
	call uintmul16
	add hl,hl : rl de
	add hl,hl : rl de
	ld (midplayer.ticksperqnoteXupdatelen+0),hl
	ld (midplayer.ticksperqnoteXupdatelen+2),de
	call midloadtracks
	jp nz,memorystreamfree ;sets zf=0
	call midsetprogressdelta
	ld de,0
	ld hl,14
	call memorystreamseek
	call midloadtracks
	jp nz,memorystreamfree ;sets zf=0
	call midinitport
	ld hl,DEFAULT_QNOTE_DURATION_MCS%65536
	ld de,DEFAULT_QNOTE_DURATION_MCS/65536
	call setticksperupdate
	xor a
	ret

midchecksignature
;b = byte count
;de = signature
;out: zf=1 if ok, zf=0 otherwise
	ld hl,(memorystreamcurrentaddr)
.loop	memory_stream_read_byte c
	ld a,(de)
	cp c
	ret nz
	inc de
	djnz .loop
	ld (memorystreamcurrentaddr),hl
	ret

midloadtracks
	ld ix,midplayer.tracks
	ld iy,(midplayer.trackcount)
.loop	ld b,midtracksigsize
	ld de,midtracksig
	call midchecksignature
	ret nz
	call memorystreamread4
	ld l,b
	ld h,c
	push hl
	ld e,a
	push de
	call memorystreamgetpos
	push de
	push hl
	ld hl,(memorystreamcurrentaddr)
	call midreadvarint
	ld (memorystreamcurrentaddr),hl
	ld (ix+MIDTRACK.nexteventtick+0),de
	ld (ix+MIDTRACK.nexteventtick+2),c
	call memorystreamgetpos
	ld (ix+MIDTRACK.streamoffset+0),hl
	ld (ix+MIDTRACK.streamoffset+2),de
	pop hl
	pop de
	pop bc
	add hl,bc
	ex de,hl
	pop bc
	adc hl,bc
	ex de,hl
	call memorystreamseek
	ld bc,MIDTRACK
	add ix,bc
	dec iyl
	jp nz,.loop
	ret

midmute
	ld e,0xb0
	ld b,MIDCHANNELS
.loop	push bc
	ld d,e
	ld hl,123*256
	call midsend3 ;notes off
	ld d,e
	ld hl,120*256
	call midsend3 ;sounds off
	ld d,e
	ld hl,121*256
	call midsend3 ;controllers off
	pop bc
	inc e
	djnz .loop
	ret

midunload
	call midmute
	jp memorystreamfree

midplay
	YIELD
;advance tick counter
	ld hl,(midplayer.tickcounter+0)
	ld de,(midplayer.ticksperupdate+0)
	add hl,de
	ld (midplayer.tickcounter+0),hl
	ex de,hl
	ld hl,(midplayer.tickcounter+2)
	ld bc,(midplayer.ticksperupdate+2)
	adc hl,bc
	ld (midplayer.tickcounter+2),hl
	ex de,hl
	call midgetprogress
	call updateprogress
;iterate through the tracks
	ld ix,midplayer.tracks
	ld a,(midplayer.trackcount)
	ld b,a
	ld c,0
.trackloop
	bit 7,(ix+MIDTRACK.streamoffset+3)
	jr nz,.skiptrack
	ld c,255
	ld hl,(midplayer.tickcounter+0)
	ld de,(ix+MIDTRACK.nexteventtick+0)
	sub hl,de
	ld hl,(midplayer.tickcounter+2)
	ld de,(ix+MIDTRACK.nexteventtick+2)
	sbc hl,de
	jr c,.skiptrack
	push bc
	call midhandletrackevent
	pop bc
	jr .trackloop
.skiptrack
	ld de,MIDTRACK
	add ix,de
	djnz .trackloop
	ld a,c
	or a
	ret

midreadvarint
;hl = memory stream addr
;out: cde = number, hl = memory stream addr
	ld de,0
	ld c,0
.loop	memory_stream_read_byte b
	ld a,e
	rrca
	xor b
	and 0x80
	xor b
	rr c
	rr de
	ld c,d
	ld d,e
	ld e,a
	bit 7,b
	jr nz,.loop
	ret

	macro process_midi_event call_send_byte,call_send_2,call_send_3
;ix = track
;hl = memory stream address
	memory_stream_read_byte b
	bit 7,b
	jr z,.gotdatabyte
	ld (ix+MIDTRACK.lastcommand),b
	memory_stream_read_byte d
	jr .handlecommand
.gotdatabyte
	ld d,b
	ld b,(ix+MIDTRACK.lastcommand)
.handlecommand
	ld a,b
	rrca
	rrca
	rrca
	rrca
	and 7
	ld c,a
	add a,a
	add a,c
	ld (.commandtable),a
.commandtable=$+1
	jr $
	jp .send3 ; 8 Note Off
	jp .send3 ; 9 Note On
	jp .send3 ; A Polyphonic Pressure
	jp .send3 ; B Control Change	
	jp .send2 ; C Program Change
	jp .send2 ; D Channel Pressure
	jp .send3 ; E Pitch Bend
;;;;;;;;;;;;;;;;;;; F System
	ld a,b
	cp 0xff
	jp z,.handlemeta
	cp 0xf0
	jp nz,.finalize
	call midreadvarint
	ld d,0xf0
	call_send_byte
.sendloop
	memory_stream_read_byte e
	ld d,e
	call_send_byte
	ld a,e
	cp 0xf7
	jr nz,.sendloop
	ld (memorystreamcurrentaddr),hl
	jr .finalize
.handlemeta
	ld a,d
	cp 0x2f
	jr z,.markdone
	cp 0x51
	jr z,.setduration
	call midreadvarint
	ld a,e
	or d
	jr z,.finalize
	ld a,e
	dec de
	inc d
	ld c,d
	ld b,a
.skiploop
	bit 6,h
	call nz,memorystreamnextpage
	inc hl
	djnz .skiploop
	dec c
	jr nz,.skiploop
	ld (memorystreamcurrentaddr),hl
	jr .finalize
.markdone
	set 7,(ix+MIDTRACK.streamoffset+3)
	ret
.setduration
	call midreadvarint
	memory_stream_read_byte a
	memory_stream_read_byte d
	memory_stream_read_byte e
	ld (memorystreamcurrentaddr),hl
	ex de,hl
	ld e,a
	ld d,0
	push ix
	call setticksperupdate
	pop ix
	jr .finalize
.send2	ld (memorystreamcurrentaddr),hl
	ld l,d
	ld h,b
	call_send_2
	jr .finalize
.send3	memory_stream_read_byte e
	ld (memorystreamcurrentaddr),hl
	ex de,hl
	ld d,b
	call_send_3
.finalize
	ld hl,(memorystreamcurrentaddr)
	call midreadvarint
	ld (memorystreamcurrentaddr),hl
	ld b,0
	sla de : rl bc
	sla de : rl bc
	ld hl,(ix+MIDTRACK.nexteventtick+0)
	add hl,de
	ld (ix+MIDTRACK.nexteventtick+0),hl
	ld hl,(ix+MIDTRACK.nexteventtick+2)
	adc hl,bc
	ld (ix+MIDTRACK.nexteventtick+2),hl
	endm

midhandletrackevent
;ix = track
	ld hl,(ix+MIDTRACK.streamoffset+0)
	ld de,(ix+MIDTRACK.streamoffset+2)
	call memorystreamseek
	process_midi_event <call midsendbyte>,<call midsend2>,<call midsend3>
	call memorystreamgetpos
	ld (ix+MIDTRACK.streamoffset+0),hl
	ld (ix+MIDTRACK.streamoffset+2),de
	ret

midgetprogress
;dehl = ticks
;out: a = progress
	ld a,e
	add hl,hl : rla
	add hl,hl : rla
	add hl,hl : rla
	add hl,hl : rla
	ret

midsetprogressdelta
	ld ix,midplayer.tracks
	ld a,(midplayer.trackcount)
	ld b,a
	ld c,0
.trackloop
	push bc
	ld hl,(ix+MIDTRACK.streamoffset+0)
	ld de,(ix+MIDTRACK.streamoffset+2)
	call memorystreamseek
.eventloop
	call midadvancetrack
	bit 7,(ix+MIDTRACK.streamoffset+3)
	jr z,.eventloop
	ld hl,(ix+MIDTRACK.nexteventtick+0)
	ld de,(ix+MIDTRACK.nexteventtick+2)
	call midgetprogress
	pop bc
	cp c
	jr c,$+3
	ld c,a
	ld de,MIDTRACK
	add ix,de
	djnz .trackloop
	ld a,c
	jp setprogressdelta

midadvancetrack
;ix = track
	ld hl,(memorystreamcurrentaddr)
	process_midi_event < >,< >,< >
	ret

setticksperupdate
;dehl = qnote duration in mcs
	exx
	ld hl,(midplayer.ticksperqnoteXupdatelen+0)
	ld de,(midplayer.ticksperqnoteXupdatelen+2)
	call uintdiv32
	ld (midplayer.ticksperupdate+0),hl
	ld (midplayer.ticksperupdate+2),de
	ret

midheadersig
	db "MThd",0,0,0,6
midheadersigsize = $-midheadersig
midtracksig
	db "MTrk"
midtracksigsize = $-midtracksig
initokstr
	db "OK\r\n",0
playernamestr
	db "ProTracker and MIDI UART player",0
end

titlestr ds TITLELENGTH+1
isplayingmidfile ds 1
framelength ds 2
waitspincount ds 1
midplayer MIDPLAYER

	assert $ <= PLAYEREND ;ensure everything is within the player page

	savebin "pt3.bin",begin,end-begin
