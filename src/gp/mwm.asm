	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
mwmsupported=$+1
	ld a,'m'
	cp c
	ret nz
	ld hl,'wm'
	sub hl,de
	ret

playerinit
;hl = shared pages
;a = player page
	ld de,songdata_bank1
	ld bc,3
	ldir

	call ismoonsoundpresent
	ret z
	ld (mwmsupported),a ;writes 255 disabling the extension
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
;First try loading wavekit with the same filename as input file.
;This allows overriding wavekit specified in MWM header without
;having the file edited.
	ld (filenameaddr),hl
	ld c,'.'
	call findlastchar ;out: de = after last dot or start
	ld hl,2
	add hl,de
	ld (hl),'k'
filenameaddr=$+1
	ld de,0
	push hl
	call openstream_file
	pop hl
	ld (hl),'m'
	or a
	jr z,loadmwkdata
;din't find wavekit so now have to load and parse module header
	ld de,(filenameaddr)
	call openstream_file
	or a
	ret nz
	ld a,(songdata_bank1)
	SETPG8000
	ld de,0x8000
	ld hl,284
	call readstream_file
	call closestream_file
;check if this is a valid MWM file
	ld de,0x8000
	ld a,8 ;file type 8 = wave user song
	call check_header
	ret nz
;check if wavekit is needed
	ld hl,0x8114
	ld de,mwknone
	ld b,8
	call chk_headerlus
	jr z,loadmwm
;build filename
	ld hl,(filenameaddr)
	ld de,0x8000
	call strcopy_hltode
	ld hl,0x8000
	ld c,'/'
	call findlastchar ;out: de = after last slash or start
	ld hl,0x8114
	ld b,8
filenamecopyloop
	ld a,(hl)
	cp ' '
	jr z,donefilenamecopy
	ld (de),a
	inc hl
	inc de
	djnz filenamecopyloop
donefilenamecopy
	ex de,hl
	ld (hl),'.'
	inc hl
	ld (hl),'m'
	inc hl
	ld (hl),'w'
	inc hl
	ld (hl),'k'
	inc hl
	ld (hl),0
;load wavekit
	ld de,0x8000
	call openstream_file
	or a
	ret nz
loadmwkdata
	call mwkload
	push af
	call closestream_file
	pop af
	ret nz
loadmwm
	ld de,(filenameaddr)
	call openstream_file
	or a
	ret nz
	call mwmload
	ret nz
	call closestream_file

	call start_music

	ld a,255
	ld (xloop),a

	xor a
	ret

musicunload
	jp stop_music

musicplay
;out: zf=0 if still playing, zf=1 otherwise
	ld a,(play_busy)
	or a
	ret z
	in a,(MOON_STAT)
	rla
	jr nc,musicplay
	call play_int
	ld a,(play_busy)
	or a
	ret

strcopy_hltode
	ld a,(hl)
	ld (de),a
	or a
	ret z
	inc hl
	inc de
	jr strcopy_hltode

;c = character
;hl = poi to filename in string
;out: de = after last dot or start
findlastchar
	ld d,h
	ld e,l ;de = after last char
findlastchar0
	ld a,(hl)
	inc hl
	or a
	ret z
	cp c
	jr nz,findlastchar0
	jr findlastchar

mwknone
	db "NONE    "

load_file
	push de
	push ix
	call readstream_file
	pop ix
	pop de
	ret

selbank_FE
	SETPG8000
	ret

	include "../_sdk/file.asm"
	include "moonsound.asm"
	include "mbwave/basic.asm"

playernamestr
	db "Moonblaster Wave Replayer",0
end

	savebin "mwm.bin",begin,end-begin
