; MoonBlaster Wave modules player

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

	org PLAYERSTART

begin   PLAYERHEADER playerwindowui

TITLELENGTH = 64

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
	ld a,c
	cp 'm'
	ret nz
	ld hl,'wm'
	sbc hl,de
	ret

cleanupvars
;out: zf=0 so this function can be used as error handler
	xor a
	ld (titlestr),a
	inc a
	jp initprogress

playerinit
;ix = GPSETTINGS
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld a,(ix+GPSETTINGS.sharedpages+0) : ld (songdata_bank1+0),a
	ld a,(ix+GPSETTINGS.sharedpages+1) : ld (songdata_bank1+1),a
	ld a,(ix+GPSETTINGS.sharedpages+2) : ld (songdata_bank1+2),a
	call cleanupvars
	ld a,(ix+GPSETTINGS.moonsoundstatus)
	cp 2
	ld hl,initokstr
	ret z
	ld hl,nodevicestr
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
;out: hl = device mask, zf=1 if the file is ready for playing, zf=0 otherwise
;
;First try loading wavekit with the same filename as input file.
;This allows overriding wavekit specified in MWM header without
;having the file edited.
	ld de,wavekiterrorstr
	ld (ERRORSTRINGADDR),de
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
;didn't find wavekit, so now have to load and parse module header
	ld de,(filenameaddr)
	call openstream_file
	or a
	jp nz,cleanupvars
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
	jp nz,cleanupvars
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
	jp nz,cleanupvars
loadmwkdata
	call mwkload
	push af
	call closestream_file
	pop af
	jp nz,cleanupvars
loadmwm
	ld hl,moduleerrorstr
	ld (ERRORSTRINGADDR),hl
	ld de,(filenameaddr)
	call openstream_file
	or a
	jp nz,cleanupvars
	call mwmload
	jp nz,cleanupvars
	call closestream_file
	call start_music
;set music length
	ld a,(xloop)
	ld c,a
	ld b,0
	cp 255
	ld a,(xleng)
	jr nc,noloopinmusic
;the loop is played one additional time
	ld l,a
	ld h,b
	add hl,hl
	sbc hl,bc
	ld a,l
	srl h
noloopinmusic
	rra
	adc a,b
	call setprogressdelta
;set title
	ld hl,0x80dc
	ld de,titlestr
	ld bc,50
	ldir
	ld b,TITLELENGTH-50
	ld a,' '
.filltitleloop
	ld (de),a
	inc de
	djnz .filltitleloop
	xor a
	ld (de),a
;init progress vars
	ld (lastplaypos),a
	ld (loopcounter),a
	ld hl,0
	ld (playposacc),hl
	ld (ERRORSTRINGADDR),hl
	ld hl,DEVICE_MOONSOUND_MASK
	ret

musicunload
	call cleanupvars
	jp stop_music

musicplay
;out: zf=0 if still playing, zf=1 otherwise
	ld a,(play_busy)
	or a
	ret z
	in a,(MOON_STAT)
	rlca
	jr nc,$-3
	call play_int
;update progress
lastplaypos=$+1
	ld b,0
	ld a,(play_pos)
	ld (lastplaypos),a
	sub b
	jr z,playposunchanged
	jr nc,loopwasnotencountered
	ld hl,xleng
	add a,(hl)
	ld hl,xloop
	sub (hl)
	ld hl,loopcounter
	inc (hl)
loopwasnotencountered
playposacc=$+1
	ld hl,0
	ld c,a
	ld b,0
	add hl,bc
	ld (playposacc),hl
	ld a,l
	srl h
	rra
	call updateprogress
playposunchanged
	ld a,(play_busy)
	or a
	ret z
loopcounter=$+1
	ld a,0
	cp 2 ;repeat the loop once
	sbc a,a
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
	include "common/opl4.asm"
	include "mbwave/basic.asm"
	include "progress.asm"

initokstr
	db "OK\r\n",0
nodevicestr
	db "no device!\r\n",0
mwknone
	db "NONE    "
playernamestr
	db "MBWave",0
wavekiterrorstr
	db "Unable to load wavekit!",0
moduleerrorstr
	db "Failed to load the module!",0
playerwindowui
	PROGRESSIVEPLAYERWINDOWTEMPLATE titlestr,musicprogress+1
end

titlestr
	ds TITLELENGTH+1

	savebin "mwm.bin",begin,end-begin

	assert $ <= PLAYEREND ;ensure everything is within the player page
