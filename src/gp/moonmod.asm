; S3M and MOD player for MoonSound

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 20
MEMORYSTREAMERRORMASK = 0

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
ismoonsounddisabled=$+1
	jr nosupportedfiles
	call ismodfile
	jr z,initplayvars
	ld a,'s'
	cp c
	ret nz
	ld hl,'3m'
	sbc hl,de
	ret nz
initplayvars
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress
nosupportedfiles
	or 1
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
;init period lookup
	OS_NEWPAGE
	or a
	ld hl,outofmemorystr
	ret nz
	ld a,e
	push af
	SETPGC000
;move period lookup table to its own page
	ld hl,periodlookup
	ld de,0xc000
	ld bc,periodlookup_end-periodlookup
	ldir
;start initing vars after the table was copied
	pop af
	ld (modperiodlookuppage),a
.settingsaddr=$+2
	ld ix,0
	ld a,(ix)
	ld (modfilebufferpage),a
	call setdefaultpanning
	ld hl,initokstr
	xor a
	ld (ismoonsounddisabled),a
	ret

setdefaultpanning
;ix = GPSETTINGS
	ld de,(ix+GPSETTINGS.moonmoddefaultpanning)
	ld a,d
	or e
	ret z
	ld b,4
	ld hl,moddefaultpanning
.setpanningloop
	ld a,(de)
	sub 'A'
	jr nc,$+4
	add a,'A'-'0'-10
	add a,10
	and 15
	ld (hl),a
	inc hl
	inc de
	djnz .setpanningloop
	ret

playerdeinit
modperiodlookuppage=$+1
	ld e,0
	OS_DELPAGE
	ret

ismodfile
;cde = file extension
;out: zf=1 if .mod, zf=0 otherwise
	ld a,'m'
	cp c
	ret nz
	ld a,'o'
	cp d
	ret nz
	ld a,'d'
	cp e
	ret

musicload
;cde = file extension
;hl = input file name
;out: hl = device mask, zf=1 if the file is ready for playing, zf=0 otherwise
	call ismodfile
	ex de,hl
	jr nz,.loads3m
	call modload
	ret nz
	ld a,255
	ld (isplayingmodfile),a
	ld a,(modinfo.songlength)
	jr .finalize
.loads3m
	call s3mload
	ret nz
	xor a
	ld (isplayingmodfile),a
	ld a,(s3mheader.ordernum)
.finalize
	call setprogressdelta
	ld de,MODHEADERADDR
	ld a,(de)
	or a
	jr z,.notitle
	ld hl,titlestr
	ld (MUSICTITLEADDR),hl
	ld b,TITLELENGTH+1
.copytitleloop
	ld a,(de)
	ld (hl),a
	inc de
	inc hl
	dec b
	or a
	jr nz,.copytitleloop
	dec hl
.filltitleloop
	ld (hl),' '
	inc hl
	djnz .filltitleloop
	ld (hl),0
.notitle
	xor a
	ld (currentposition),a
	ld hl,DEVICE_MOONSOUND_MASK
	ret

musicunload
	ld a,(isplayingmodfile)
	or a
	jp nz,modunload
	jp s3munload

musicplay
;out: zf=0 if still playing, zf=1 otherwise
	ld a,(isplayingmodfile)
	or a
	jr nz,.playmod
	call s3mplay
	ld a,(s3mplayer.patterntableindex)
	call updateprogress
	ld a,(s3mplayer.patterntableindex)
	jr .finalize
.playmod
	call modplay
	ld a,(modplayer.patterntableindex)
	call updateprogress
	ld a,(modplayer.patterntableindex)
.finalize
;check if the position is increasing monotonically
	ld hl,currentposition
	cp (hl)
	ld (hl),a
	ccf
	sbc a
	ret

	include "../_sdk/file.asm"
	include "common/memorystream.asm"
	include "common/opl4.asm"
	include "common/muldiv.asm"
	include "moonmod/mod.asm"
	include "moonmod/s3m.asm"
	include "progress.asm"

playernamestr
	db "MoonSound S3M/MOD",0
outofmemorystr
	db "Out of memory!",0
initokstr
	db "OK\r\n",0
nodevicestr
	db "no device!\r\n",0

tempmemorystart = $
periodlookup
	incbin "moonmod/periodlookup.bin"
periodlookup_end
end

titlestr equ tempmemorystart
currentposition equ titlestr+TITLELENGTH+1
modfilebufferpage equ currentposition+1
isplayingmodfile equ modfilebufferpage+1
modtempmemory equ isplayingmodfile+1

	org modtempmemory
modinfo MODINFO
modwaveheaderbuffer = $
modplayer MODPLAYER

	assert $ <= PLAYEREND ;ensure everything is within the player page

	org modtempmemory
s3minfo S3MINFO
s3mwaveheaderbuffer = $
s3mplayer S3MPLAYER

	assert $ <= PLAYEREND ;ensure everything is within the player page

	org MODHEADERADDR
modheader MODHEADER

	org S3MHEADERADDR
s3mheader S3MHEADER

	assert MODWAVEHEADERBUFFERSIZE <= PLAYEREND-modwaveheaderbuffer
	assert S3MWAVEHEADERBUFFERSIZE <= PLAYEREND-s3mwaveheaderbuffer

	savebin "moonmod.bin",begin,end-begin
