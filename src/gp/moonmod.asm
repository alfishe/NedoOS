; S3M and MOD player for MoonSound

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

TITLELENGTH = 64
MEMORYSTREAMMAXPAGES = 20
MEMORYSTREAMERRORMASK = 0

	org PLAYERSTART

begin   PLAYERHEADER 0

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
	call ismodfile
	ret z
.checks3m
	ld a,'s'
	cp c
	ret nz
	ld hl,'3m'
	sbc hl,de
	ret

cleanupvars
;only destroys af and hl
;out: zf=0 so this function can be used as error handler
	ld hl,playerwindowloading
	ld (CUSTOMUIADDR),hl
	xor a
	ld (titlestr),a
	ld (currentposition),a
	inc a
	jp initprogress

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
	call checkmoddevicesettings
	call cleanupvars
	xor a
	ld hl,initokstr
	ret

checkmoddevicesettings
;output: zf=1 if this player is enabled, zf=0 otherwise
	ld de,(ix+GPSETTINGS.moddevice)
	ld a,d
	or e
	ret z
	ld a,(de)
	cp '0'
	ret z
	cp '1'
	ret z
	ld hl,isfilesupported.checks3m
	ld (ISFILESUPPORTEDPROCADDR),hl
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
;ix = draw progress callback
;out: hl = device mask, zf=1 if the file is ready for playing, zf=0 otherwise
	ld (drawsampleloadingprogress.callback),ix
	call ismodfile
	ex de,hl
	jr nz,.loads3m
	call modload
	jp nz,cleanupvars ;sets zf=0
	call modprintinfo
	ld a,255
	ld (isplayingmodfile),a
	ld a,(modinfo.songlength)
	jr .finalize
.loads3m
	call s3mload
	jp nz,cleanupvars ;sets zf=0
	call s3mprintinfo
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
	ld hl,playerwindowui
	ld (CUSTOMUIADDR),hl
	xor a
	ld hl,DEVICE_MOONSOUND_MASK
	ret

musicunload
	call cleanupvars
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

atodecimalstring
;a = number
;de = string buffer
	ld l,a
	ld h,0
hltodecimalstring
;hl = number
;de = string buffer
	ld ixl,e
	ld bc,-10000
	inc ixl
	call .writedigit
	ld bc,-1000
	call .writedigit
	ld bc,-100
	call .writedigit
	ld bc,-10
	call .writedigit
	ld bc,-1
	dec ixl ;ensure the last zero is printed
	call .writedigit
	xor a
	ld (de),a
	ret
.writedigit
	ld a,'0'-1
	inc a
	add hl,bc
	jr c,$-2
	sbc hl,bc
	ld (de),a
	inc de
	cp '0'
	ret nz
;remove leading zeroes
	ld a,e
	cp ixl
	ret nz
	dec de
	ret

strcopy_hltode
	ld a,(hl)
	ld (de),a
	or a
	ret z
	inc hl
	inc de
	jr strcopy_hltode

modprintinfo
	ld hl,(modinfo.moduletypestr)
	ld (playerwindowui.trackertext+CUSTOMUIPRINTTEXT.straddr),hl
	ld de,chnumstr
	ld a,(modinfo.channelcount)
	call atodecimalstring
	ld de,instnumstr
	ld a,(modinfo.samplecount)
	call atodecimalstring
	ld hl,(modinfo.samplesizesinkb)
	jr printsamplesize

s3mprintinfo
	ld hl,st3str
	ld (playerwindowui.trackertext+CUSTOMUIPRINTTEXT.straddr),hl
	ld de,chnumstr
	ld a,(s3minfo.chnum)
	call atodecimalstring
	ld de,instnumstr
	ld a,(s3minfo.instnum)
	call atodecimalstring
	ld hl,(s3minfo.samplesizesinkb)
printsamplesize
	ld de,samplesizestr
	call hltodecimalstring
	ld hl,kbytestr
	jp strcopy_hltode

drawsampleloadingprogress
.callback=$+1
	jp 0

trackertextstr db "Tracker: ",0
st3str db "Scream Tracker 3",0
chnumtextstr db "Channels: "
chnumstr ds 4
instnumtextstr db "Instruments: "
instnumstr ds 4
samplesizetextstr db "Samples: "
samplesizestr ds 10
kbytestr db "KB",0

playernamestr
	db "MoonSound S3M/MOD",0
outofmemorystr
	db "Out of memory!",0
initokstr
	db "OK\r\n",0
nodevicestr
	db "no device!\r\n",0
loadingtitlestr
	db "Loading tracker module...",0
playerwindowloading
	PROGRESSIVELOADINGWINDOWTEMPLATE loadingtitlestr,musicprogress+1

playerwindowui
	CUSTOMUISETCOLOR ,COLOR_PANEL
	CUSTOMUIDRAWWINDOW ,6,8,66,7
	CUSTOMUISETCOLOR ,15
	CUSTOMUISEPARATOR ,7,13,64,196,196,196
	CUSTOMUIPLAYERWINDOWTITLE ,8,8
	CUSTOMUISONGTITLE ,8,10,titlestr
	CUSTOMUIPLAYPROGRESS ,8,11,musicprogress+1
	CUSTOMUIPLAYTIME ,67,8
	CUSTOMUISETCOLOR ,COLOR_PANEL_FILE
	CUSTOMUIPRINTTEXT ,9,14,trackertextstr
.trackertext
	CUSTOMUIPRINTTEXT ,18,14,st3str
	CUSTOMUIPRINTTEXT ,8,15,chnumtextstr
	CUSTOMUIPRINTTEXT ,49,14,instnumtextstr
	CUSTOMUIPRINTTEXT ,53,15,samplesizetextstr
	CUSTOMUIDRAWEND

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
