; ProTracker modules player for AY8910/TurboSound

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

MDLADDR = 0x8000
TITLELENGTH = 64

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
	ld a,c
	cp 'p'
	ret nz
	ld a,d
	cp 't'
	ret nz
	ld a,e
	cp '2'
	jr nz,checkpt3
;prepare local variables
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld (MUSICPROGRESSADDR),hl
	ret
checkpt3
	cp '3'
	ret nz
;prepare local variables
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress

playerinit
;hl = GPSETTINGS
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld (playerpage),a
	ld a,(hl)
	ld (page8000),a
	inc hl
	ld a,(hl)
	ld (pageC000),a

	ld hl,initokstr
	xor a
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
;out: zf=1 if the file is ready for playing, zf=0 otherwise
	ex de,hl
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
	ret

musicunload
	ld a,(playerpage)
	ld hl,play_reter
	OS_SETMUSIC

	jp MUTE

play_reter
	ret

musicplay
;out: zf=0 if still playing, zf=1 otherwise
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
	include "progress.asm"

initokstr
	db "OK\r\n",0
playernamestr
	db "Universal PT2'n'PT3 Turbo Sound",0
end

titlestr
	ds TITLELENGTH+1

	savebin "pt3.bin",begin,end-begin
