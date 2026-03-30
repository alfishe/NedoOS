; Player for NeoGS decoder chip (also GS/NeoGS .mod player)
; Supports a range of VLSI decoders: VS1001, VS1011, VS1003, VS1033, VS1053

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "ngsdec/gscodedefs.asm"
	include "ngsdec/gsports.asm"
	include "ngsdec/vs10xx.asm"
	include "playerdefs.asm"

BUFADDR = 0x8000
BUFSIZE = 0x8000

	org PLAYERSTART

begin   PLAYERHEADER 0

FILETYPE_MP3 = 1
FILETYPE_MOD = 2
FILETYPE_MID = 3

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
	ld a,c
	cp 'o'
	jp nz,.checkaac
	ld hl,'gg'
	sbc hl,de
	jp nz,.checkaac
	ld a,(vsversion)
	cp SS_VER_VS1053
	jr z,.initmp3vars
	cp SS_VER_VS1063
	jr z,.initmp3vars
	ret
.checkaac
	cp 'a'
	jp nz,.checkmp3modmid
	ld hl,'ac'
	sbc hl,de
	jp nz,.checkmp3modmid
	ld a,(vsversion)
	cp SS_VER_VS1053
	jr z,.initmp3vars
	cp SS_VER_VS1033
	jr z,.initmp3vars
	cp SS_VER_VS1063
	jr z,.initmp3vars
	ret
.checkmp3modmid
	cp 'm'
	ret nz
	ld hl,'od'
	sbc hl,de
.disablemod=$+1
	jr z,.initmodvars
	ld hl,'id'
	sub hl,de
.disablemid=$+1
	jr z,.checkmid
	ld hl,'p3'
	sub hl,de
	ret nz
.initmp3vars
	ld hl,0
	ld (CUSTOMUIADDR),hl
	ld a,FILETYPE_MP3
	ld (filetype),a
	ret
.initmodvars
	ld hl,modplayerwindowloading
	ld (CUSTOMUIADDR),hl
	ld a,FILETYPE_MOD
	ld (filetype),a
	ret
.checkmid
	ld a,(vsversion)
	cp SS_VER_VS1053
	jr z,.initmidvars
	cp SS_VER_VS1003
	jr z,.initmidvars
	cp SS_VER_VS1033
	jr z,.initmidvars
	cp SS_VER_VS1103
	ret nz
.initmidvars
	ld hl,midiplayerwindowui
	ld (CUSTOMUIADDR),hl
	ld a,FILETYPE_MID
	ld (filetype),a
	ret

cleanupvars
;out: zf=0 so this function can be used as error handler
	xor a
	ld (titlestr),a
	ld (filechunkcounter+0),a
	ld (filechunkcounter+1),a
	ld (filetype),a
	dec a
	ld (streaminfobyte),a
	jp initprogress

isfilesupportedgsonly
;specialized function for GeneralSound
	ld a,c
	cp 'm'
	ret nz
	ld hl,'od'
	sbc hl,de
	ret nz
	jr isfilesupported.initmodvars

ismodenabled
;output: zf=1 if .mod is enabled on this device, zf=0 otherwise
	ld de,(ix+GPSETTINGS.moddevice)
	ld a,d
	or e
	ret z
	ld a,(de)
	cp '0'
	ret z
	cp '2'
	ret

checkmididevicesettings
;output: zf=1 if this player is enabled, zf=0 otherwise
	ld de,(ix+GPSETTINGS.mididevice)
	ld a,d
	or e
	ret z
	ld a,(de)
	cp '0'
	ret z
	cp '2'
	ret z
	ld a,0
	ld (isfilesupported.disablemid),a
	ret

playerinit
;ix = GPSETTINGS
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld (.settingsaddr),ix
	ld a,(ix+GPSETTINGS.sharedpages)
	ld (page8000),a
	ld a,(ix+GPSETTINGS.sharedpages+1)
	ld (pageC000),a
	ld hl,(ix+GPSETTINGS.drawprogresscallback)
	ld (drawloadingprogress.callback),hl
	ld hl,(ix+GPSETTINGS.drawcustomui)
	ld (drawcustomui.callback),hl
	call cleanupvars
;	call gssoftreset
;b==0 if no reply from GS
;	dec b
;	inc b
;	call z,gshardreset
	call gshardreset
;b==0 if no reply from GS
	ld a,b
	cp 1
	ld hl,nodevicestr
	ret c
;get chip id
	call gsstartcode
	SC CMDGETCHIPID
	WC
	WN
	GD
	ld (vsversion),a
	call gscodereset
.settingsaddr=$+2
	ld ix,0
	ld a,(vsversion)
	cp SS_VER_VS1103+1
	jr nc,.initgsonly
	rrca
	rrca
	add a,idtostr%256
	ld l,a
	adc a,idtostr/256
	sub l
	ld h,a
	ld de,chipidstr
	ld bc,4
	ldir
	call ismodenabled
	jr z,$+6
	xor a
	ld (isfilesupported.disablemod),a
	call checkmididevicesettings
	xor a
	ld hl,ngsinitokstr
	ret
.initgsonly
	call ismodenabled
	ld hl,playerdisabledstr
	ret nz
	ld hl,isfilesupportedgsonly
	ld (ISFILESUPPORTEDPROCADDR),hl
	xor a
	ld hl,gsinitokstr
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
;out: hl = device mask, zf=1 if the file is ready for playing, zf=0 otherwise
	push hl
	ld a,(filetype)
	cp FILETYPE_MP3
	jr nz,.skipmp3setup
	ld hl,mp3playerwindowui
	ld (CUSTOMUIADDR),hl
	call setdefaultstreaminfoui
.skipmp3setup
	pop de
	call openstream_file
	or a
	jp nz,cleanupvars
page8000=$+1
	ld a,0
	SETPG8000
pageC000=$+1
	ld a,0
	SETPGC000
	ld a,(filetype)
	cp FILETYPE_MOD
	jr z,loadmod
	cp FILETYPE_MID
	jr nz,.skipmidicheck
	ld hl,16
	ld de,BUFADDR
	call readstream_file
	call checksmf0
	jr z,.donemidicheck
	ld hl,smf0errorui | 0x8000
	ld (ERRORSTRINGADDR),hl
	call closestream_file
	jp cleanupvars
.donemidicheck
	ld a,(filehandle)
	ld b,a
	ld hl,0
	ld de,hl
	OS_SEEKHANDLE
.skipmidicheck
	ld a,(filehandle)
	ld b,a
	OS_GETFILESIZE
	ld a,e
	call setprogressdelta
	call gsstartcode
	ld hl,firstpaddingframedata
	ld (paddingframedataptr),hl
	ld hl,0
	ld (paddingframecount),hl
	ld (bufferdataleft),hl
	ld hl,DEVICE_NEOGS_MASK
	xor a
	ret

checksmf0
	ld hl,(BUFADDR)
	ld de,"TM"
	sub de,hl
	ret nz
	ld hl,(BUFADDR+2)
	ld de,"dh"
	sbc de,hl
	ret nz
	ld hl,(BUFADDR+8)
	ld de,0
	sbc hl,de	
	ret

TITLELENGTH = 64

loadmod
;setup loading progress
	ld (.savedsp),sp
	ld a,(filehandle)
	ld b,a
	OS_GETFILESIZE
	ld a,e
	ld de,0x7fff
	add hl,de
	adc a,0
	add hl,hl
	rla
	call setprogressdelta
;start loading
	ld hl,BUFSIZE
	ld de,BUFADDR
	call readstream_file
	push hl
;get pattern count
	call getmodtype
	ld a,(BUFADDR+950)
	jr z,$+5
	ld a,(BUFADDR+470)
	ld (.pattnum),a
;set title
	ld hl,titlestr
	ld de,BUFADDR
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
;load module
	SC 0x30
	WC
;open stream
	SC 0xD1
	WC
;upload file
	pop bc
	ld d,0
.uploadnextchunk
	inc d
	push de
	ld hl,BUFADDR
	ld a,c
	dec bc
	inc b
	ld c,b
	ld b,a
.uploadloop
	ld a,(hl)
	out (GSDAT),a
	WD
	inc hl
	djnz .uploadloop
	dec c
	jr nz,.uploadloop
	ld a,d
	call updateprogress
	call drawloadingprogress
	jr nz,.cancelloading
	ld hl,BUFSIZE
	ld de,BUFADDR
	call readstream_file
	ld bc,hl
	pop de
	ld a,b
	or c
	jr nz,.uploadnextchunk
	call closestream_file
;close stream
	SC 0xD2
	WC
;play module
	ld a,1
	out (GSDAT),a
	SC 0x31
	WC
;finalize
	call initprogress
.pattnum=$+1
	ld a,0
	call setprogressdelta
	ld hl,modplayerwindowui
	ld (CUSTOMUIADDR),hl
	xor a
	ld (currentposition),a
	ld hl,DEVICE_GS_MASK
	ret
.cancelloading
.savedsp=$+1
	ld sp,0
	call closestream_file
;cold reset because warm reset hangs randomly if stream is not closed
	SC 0xf4
	WC
	jp cleanupvars

drawloadingprogress
.callback=$+1
	jp 0

drawcustomui
.callback=$+1
	jp 0

musicunload
	ld hl,cleanupvars
	push hl
	ld a,(filetype)
	cp FILETYPE_MOD
	jr z,.unloadmod
	call closestream_file
	ld a,(filetype)
	cp FILETYPE_MID
	jp nz,gscodereset
;gscodereset didn't always work for extremely slow MIDI streams
	ld a,C_GRST
	out (GSCTR),a
	ret
.unloadmod
;warm reset
	SC 0xf3
	WC
	ret

musicplay
;out: zf=0 if still playing, zf=1 otherwise
filetype=$+1
	ld a,0
	cp FILETYPE_MOD
	jp z,playmod
bufferreadptr=$+1
	ld hl,0
bufferdataleft=$+1
	ld bc,0
	ld a,c
	or b
	jr nz,.checkifcanupload
.readfilechunk
	ld hl,(paddingframecount)
	ld de,150
	sub hl,de
	sbc a
	ret z
	call readdata
	ld hl,BUFADDR
	ex de,hl
	sub hl,de
	ld b,l
	dec hl
	inc h
	ld c,h
	ex de,hl
	jr .checkifcanupload
.uploaddataloop
	ld a,(hl)
	out (GSDAT),a
	WD
	inc hl
	djnz .uploaddataloop
	dec c
	jr z,.readfilechunk          ;done uploading current chunk
	bit 0,c
	jr z,.uploaddataloop         ;poll GS once per 512 bytes
.checkifcanupload
	SC CMDGETFREEBUFFERSPACE
	WC
	WN
	GD
	cp 6
	jr nc,.uploaddataloop       ;keep uploading until we have less than 1024 free buffer space
	ld (bufferreadptr),hl
	ld (bufferdataleft),bc
	SC CMDGETSTREAMINFO
	WC
	WN
	GD
streaminfobyte=$+1
	ld b,255
	cp b
	call nz,updatestreaminfo
	YIELD
	or 1
	ret

updatestreaminfo
	ld (streaminfobyte),a
	cp 255
	jr z,.decoderidle
	ld c,a
;update bitrate
	and 31
	add a,a
	add a,a
	add a,a
	add a,mp3bitratearraystr%256
	ld l,a
	adc a,mp3bitratearraystr/256
	sub l
	ld h,a
	ld (mp3bitratetext+CUSTOMUIPRINTTEXT.straddr),hl
	ld a,b
	inc b
	jr z,.forcefullupdate
	xor c
	and %11100000
	ld ix,bitrateonlyui
	jp z,drawcustomui
.forcefullupdate
	bit 7,c	
	jr z,.notmpeg
	ld hl,decodermpegstr
	ld (mp3codectext+CUSTOMUIPRINTTEXT.straddr),hl
	ld a,c
	rlca
	rlca
	rlca
	and 3
	ld b,a
	add a,a
	add a,a
	ld c,a
	add a,a
	add a,b
	add a,c ;a*13
	add a,mp3modes%256
	ld l,a
	adc a,mp3modes/256
	sub l
	ld h,a
	ld (mp3modetext+CUSTOMUIPRINTTEXT.straddr),hl
	ld ix,allstreamstatsui
	jp drawcustomui
.decoderidle
	call setdefaultstreaminfoui
	ld ix,allstreamstatsui
	jp drawcustomui
.notmpeg
	bit 6,c
	ld hl,decoderaacstr
	jr z,$+5
	ld hl,decoderoggstr
	ld (mp3codectext+CUSTOMUIPRINTTEXT.straddr),hl
	ld hl,emptyfieldstr
	ld (mp3modetext+CUSTOMUIPRINTTEXT.straddr),hl
	ld ix,allstreamstatsui
	jp drawcustomui

setdefaultstreaminfoui
	ld hl,emptyfieldstr
	ld (mp3codectext+CUSTOMUIPRINTTEXT.straddr),hl
	ld (mp3modetext+CUSTOMUIPRINTTEXT.straddr),hl
	ld (mp3bitratetext+CUSTOMUIPRINTTEXT.straddr),hl
	ret

mp3bitratearraystr
	db "8Kbps  ",0
	db "16Kbps ",0
	db "24Kbps ",0
	db "32Kbps ",0
	db "40Kbps ",0
	db "48Kbps ",0
	db "56Kbps ",0
	db "64Kbps ",0
	db "80Kbps ",0
	db "96Kbps ",0
	db "112Kbps",0
	db "128Kbps",0
	db "144Kbps",0
	db "160Kbps",0
	db "176Kbps",0
	db "192Kbps",0
	db "224Kbps",0
	db "256Kbps",0
	db "288Kbps",0
	db "320Kbps",0
	db "352Kbps",0
	db "384Kbps",0
	db "416Kbps",0
	db "448Kbps",0
	; emptyfieldstr

emptyfieldstr  db "-              ",0
decoderaacstr  db "AAC (ADTS/ADIF)",0
decoderoggstr  db "Ogg Vorbis     ",0
decodermpegstr db "MPEG Audio     ",0

mp3modes
	db "Stereo      ",0
	db "Joint Stereo",0
	db "Dual Channel",0
	db "Mono        ",0

playmod
	YIELD
;update progress
	SC 0x60
	WC
	WN
	GD
	push af
	call updateprogress
	pop af
;check if the position is increasing monotonically
	ld hl,currentposition
	cp (hl)
	ld (hl),a
	ccf
	sbc a
	ret

readdata
;out: de = past-the-end data pointer
	ld hl,(paddingframecount)
	ld a,l
	or h
	ld hl,BUFSIZE
	ld de,BUFADDR
	jr nz,writepadding
	call readstream_file
	ld bc,hl
	ld hl,BUFADDR
	add hl,bc
	ex de,hl
	ld hl,BUFSIZE
	sub hl,bc
	jr nz,writepadding
;update progress
	ld hl,(filechunkcounter)
	ld de,BUFSIZE>>8 ;256 bytes chunks
	add hl,de
	ld (filechunkcounter),hl
	ld a,h
	call updateprogress
	ld de,(BUFADDR+BUFSIZE)%65536
	ret

writepadding
	ld bc,paddingframedata_end-paddingframedata
	sub hl,bc
	ret c
	push hl
paddingframedataptr=$+1
	ld hl,0
	ldir
	ld hl,paddingframedata
	ld (paddingframedataptr),hl
paddingframecount=$+1
	ld hl,0
	inc hl
	ld (paddingframecount),hl
	pop hl
	jr writepadding

gshardreset
;out: b!=0 if got reply from GS, b==0 otherwise
	ld a,C_GRST
	out (GSCTR),a               ;hw reset
	YIELD
	YIELD
	YIELD
gssoftreset
	SC 0xf3                     ;GS reset
	ld b,50                     ;max spins
wcloop
	push bc
	YIELD
	pop bc
	dec b
	ret z
	in a,(GSCOM)
	rrca
	jr c,wcloop
	ret

gsstartcode
	ld bc,GSDAT
	ld de,gscode_end-gscode
	ld hl,GSPROGSTART
	out (c),e
	SC 0x14
	WC
	out (c),d
	WD
	out (c),l
	WD
	out (c),h
	WD
;start upload
	ld hl,gscode
.uploadloop
	outi
	WD
	dec de
	ld a,d
	or e
	jr nz,.uploadloop
;launch the code
	ld hl,GSPROGSTART
	out (c),l
	SC 0x13
	WC
	out (c),h
	WD
;the code is starting
	YIELD
	YIELD
	YIELD
	ret

getmodtype
;https://github.com/psbhlw/gs-firmware/blob/6c783a56147511b43d197e4079e993c2b94b4f12/firmware/src/PLAY.a80#L27
;out: zf=0 for SoundTracker 4/15 file, zf=1 otherwise
	LD A,(BUFADDR+1080)
	CP "M"
	JR Z,TTY1
	CP "4"
	JR Z,TTY1
	CP "F"
	JR Z,TTY1
	ret
TTY1	LD A,(BUFADDR+1081)
	CP "."
	JR Z,TTY2
	CP "L"
	JR Z,TTY2
	CP "!"
	JR Z,TTY2
	CP "C"
	JR Z,TTY2
	ret
TTY2	LD A,(BUFADDR+1082)
	CP "K"
	ret z
	CP "T"
	ret z
	CP "H"
	ret

gscodereset
	SC CMDRESET
	WC
	ret

firstpaddingframedata
	db 0xFF,0xFB,0x90,0x64,0x00,0x0F,0xF0,0x00,0x00
	db 0x69,0x00,0x00,0x00,0x08,0x00,0x00,0x0D,0x20
	db 0x00,0x00,0x01,0x00,0x00,0x01,0xA4,0x00,0x00
	db 0x00,0x20,0x00,0x00,0x34,0x80,0x00,0x00,0x04
	ds 381,0x55
firstpaddingframedata_end

paddingframedata
	db 0xFF,0xFB,0x90,0x64,0x40,0x8F,0xF0,0x00,0x00
	db 0x69,0x00,0x00,0x00,0x08,0x00,0x00,0x0D,0x20
	db 0x00,0x00,0x01,0x00,0x00,0x01,0xA4,0x00,0x00
	db 0x00,0x20,0x00,0x00,0x34,0x80,0x00,0x00,0x04
	ds 381,0x55
paddingframedata_end


gscode
	incbin "gscode.bin"
gscode_end

	include "../_sdk/file.asm"
	include "progress.asm"

SS_VER_VS1001 = 0x00
SS_VER_VS1011 = 0x10
SS_VER_VS1002 = 0x20
SS_VER_VS1003 = 0x30
SS_VER_VS1053 = 0x40
SS_VER_VS8053 = 0x40
SS_VER_VS1033 = 0x50
SS_VER_VS1063 = 0x60
SS_VER_VS1103 = 0x70

vsversion
	db 255
idtostr
	db "1001"
	db "1011"
	db "1002"
	db "1003"
	db "1053"
	db "1033"
	db "1063"
ngsinitokstr
	db "NeoGS with VS"
chipidstr
	db "????\r\n",0
gsinitokstr
	db "GS\r\n",0
nodevicestr
	db "no device!\r\n",0
playernamestr
	db "GS/NeoGS",0
playerdisabledstr
	db "disabled!\r\n",0
loadingtitlestr
	db "Loading tracker module...",0
modplayerwindowloading
	PROGRESSIVELOADINGWINDOWTEMPLATE loadingtitlestr,musicprogress+1
modplayerwindowui
	PROGRESSIVEPLAYERWINDOWTEMPLATE titlestr,musicprogress+1
midiplayerwindowui
	PLAYERWINDOWTEMPLATE 0

smf0error1str db "MIDI file must be in SMF format 0! Please convert it using",0
smf0error2str db "GN1:0 MIDI Converter http://www.gnmidi.com/gn1to0.zip",0
errorwindowheaderstr db "Error",0

smf0errorui
	CUSTOMUIDRAWWINDOW ,7,8,60,4
	CUSTOMUIPRINTTEXT ,9,8,errorwindowheaderstr
	CUSTOMUIPRINTTEXT ,9,10,smf0error1str
	CUSTOMUIPRINTTEXT ,12,11,smf0error2str
	CUSTOMUIDRAWEND

codectextstr db "Codec:",0
bitratetextstr db "Bitrate:",0
modetextstr db "Mode:",0

mp3playerwindowui
	CUSTOMUISETCOLOR ,COLOR_PANEL
	CUSTOMUIDRAWWINDOW ,6,8,66,7
	CUSTOMUISETCOLOR ,15
	CUSTOMUISEPARATOR ,7,13,64,196,196,196
	CUSTOMUIPLAYERWINDOWTITLE ,8,8
	CUSTOMUISONGTITLE ,8,10,titlestr
	CUSTOMUIPLAYPROGRESS ,8,11,musicprogress+1
	CUSTOMUIPLAYTIME ,67,8
	CUSTOMUISETCOLOR ,COLOR_PANEL_FILE
	CUSTOMUIPRINTTEXT ,11,14,codectextstr
	CUSTOMUIPRINTTEXT ,45,14,modetextstr
	CUSTOMUIPRINTTEXT ,9,15,bitratetextstr
	CUSTOMUISETCOLOR
	CUSTOMUISEPARATOR ,7,17,66,196,196,196
	CUSTOMUIVERTICALLINE ,74,9,8
allstreamstatsui
	CUSTOMUISETCOLOR ,COLOR_PANEL_FILE
mp3codectext
	CUSTOMUIPRINTTEXT ,18,14,emptyfieldstr
mp3modetext
	CUSTOMUIPRINTTEXT ,51,14,emptyfieldstr
bitrateonlyui
	CUSTOMUISETCOLOR ,COLOR_PANEL_FILE
mp3bitratetext
	CUSTOMUIPRINTTEXT ,18,15,emptyfieldstr
	CUSTOMUIDRAWEND
end

currentposition
	ds 1
filechunkcounter
	ds 2
titlestr
	ds TITLELENGTH+1

	savebin "mp3.bin",begin,end-begin
