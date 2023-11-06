; FT2-compatible .mod player for MoonSound

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 20

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
modsupported=$+1
	ld a,'m'
	cp c
	ret nz
	ld a,'o'
	cp d
	ret nz
	ld a,'d'
	cp e
	ret nz
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress

playerinit
;hl = GPSETTINGS
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld a,(hl)
	ld (modfilebufferpage),a
	call setdefaultpanning
	ld ix,modplayer
	call opl4initwave
	jr nz,.error
;init period lookup
	OS_NEWPAGE
	or a
	ld hl,outofmemorystr
	jr nz,.error
	ld a,e
	ld (modperiodlookuppage),a
	SETPGC000
;	call modinitperiodlookup
;load the table from disk, modinitperiodlookup is very slow on ATM2
	ld hl,modperiodopl4
	ld de,0xc000
	ld bc,modperiodopl4_end-modperiodopl4
	ldir
	ld hl,initokstr
	xor a
	ret
.error
	ld a,255
	ld (modsupported),a ;writes 255 disabling the extension
	ret

setdefaultpanning
;hl = GPSETTINGS
	push hl
	pop ix
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

musicload
;cde = file extension
;hl = input file name
;out: zf=1 if the file is ready for playing, zf=0 otherwise
	ex de,hl
	call modload
	ret nz
	ld a,(modinfo.songlength)
	call setprogressdelta
	ld hl,titlestr
	ld (MUSICTITLEADDR),hl
	ld de,0xc000
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
	xor a
	ld (currentposition),a
	ret

musicunload
	jp modunload

musicplay
;out: zf=0 if still playing, zf=1 otherwise
	call modplay
	ld a,(modplayer.patterntableindex)
	call updateprogress
;check if the position is increasing monotonically
	ld a,(modplayer.patterntableindex)
	ld hl,currentposition
	cp (hl)
	ld (hl),a
	ccf
	sbc a
	ret

	include "../_sdk/file.asm"
	include "common/memorystream.asm"
	include "common/opl4utils.asm"
	include "common/muldiv.asm"
	include "moonmod/mod.asm"
	include "progress.asm"

playernamestr
	db "MoonSound MOD Player",0
outofmemorystr
	db "Out of memory!",0

modinfo MODINFO
modwaveheaderbuffer = $
modplayer MODPLAYER
titlestr ds TITLELENGTH+1
currentposition ds 1
modfilebufferpage ds 1

modperiodopl4
	incbin "moonmod/modperiodopl4.bin"
modperiodopl4_end
end

	org MODHEADERADDR
modheader MODHEADER

	assert MODWAVEHEADERBUFFERSIZE <= MODPLAYER

	savebin "moonmod.bin",begin,end-begin
