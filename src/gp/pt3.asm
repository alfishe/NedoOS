	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

MDLADDR = 0x8000

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
	ld a,c
	cp 'p'
	ret nz
	ld a,d
	cp 't'
	ret nz
	ld a,e
	cp '3'
	ret z
	cp '2'
	ret

playerinit
;hl = shared pages
;a = player page
	ld a,(hl)
	ld (page8000),a
	inc hl
	ld a,(hl)
	ld (pageC000),a

	xor a
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
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
	call getptsconfig
	ld (SETUP),a

	ld de,MDLADDR
	add hl,de
	ex hl,de
	call INIT

	xor a
	ret

musicunload
	jp MUTE

musicplay
;out: zf=0 if still playing, zf=1 otherwise
	YIELD
	call PLAY

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

getptsconfig
;ix = file size
;out: a = player config bits, hl = offset to the second module if available
	call findts
	ld a,%00010001 ;2xPT3
	ret z

	ld a,(MDLADDR)
	cp 'V'
	jr z,$+4
	cp 'P' ;'P'/'V' for PT3
	ld a,%00100001 ;PT3
	ret z

	ld a,%00000011 ;PT2
	ret

	include "../_sdk/file.asm"
	include "ptsplay/ptsplay.asm"

playernamestr
	db "Universal PT2'n'PT3 Turbo Sound",0
end

	savebin "pt3.bin",begin,end-begin
