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

begin   PLAYERHEADER

isfilesupported
;cde = file extension
;out: zf=1 if this player can handle the file and the sound hardware is available, zf=0 otherwise
isgsdisabled=$+1
	jr nosupportedfiles
	call ismodfile
	jr nz,checkmid
	ld hl,0
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress
nosupportedfiles
	or 1
	ret
checkmid
vsversion=$+1
	ld a,255
	ld l,'m'
	ld h,b
	sub hl,bc
	jr nz,checkogg
	ld hl,'id'
	sbc hl,de
	jr nz,checkogg
	cp SS_VER_VS1003
	jr z,initmidvars
	cp SS_VER_VS1033
	jr z,initmidvars
	cp SS_VER_VS1053
	jr z,initmidvars
	cp SS_VER_VS1103
	ret nz
initmidvars
	ld (filechunkcounter),hl
	ld (MUSICTITLEADDR),hl
	ld (MUSICPROGRESSADDR),hl
	jp initprogress
checkogg
	ld l,'o'
	ld h,b
	sub hl,bc
	jr nz,checkaac
	ld hl,'gg'
	sbc hl,de
	jr nz,checkaac
	cp SS_VER_VS1053
	jr z,initmp3vars
	cp SS_VER_VS1063
	jr z,initmp3vars
	ret	
checkaac
	ld l,'a'
	ld h,b
	sub hl,bc
	jr nz,checkmp3
	ld hl,'ac'
	sbc hl,de
	jr nz,checkmp3
	cp SS_VER_VS1033
	jr z,initmp3vars
	cp SS_VER_VS1053
	jr z,initmp3vars
	cp SS_VER_VS1063
	jr z,initmp3vars
	ret
checkmp3
	ld l,'m'
	ld h,b
	sub hl,bc
	ret nz
	ld hl,'p3'
	sbc hl,de
	ret nz
	and ~SS_VER_MASK
	ret nz
initmp3vars
	ld (filechunkcounter),hl
	ld (MUSICTITLEADDR),hl
	ld hl,musicprogress+1
	ld (MUSICPROGRESSADDR),hl
	jp initprogress

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

playerinit
;hl,ix = GPSETTINGS
;a = player page
;out: zf=1 if init is successful, hl=init message
	ld a,(hl)
	ld (page8000),a
	inc hl
	ld a,(hl)
	ld (pageC000),a
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
	ld a,(vsversion)
	cp SS_VER_VS1103+1
	ld hl,gsinitok
	jr nc,.gsonly
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
	ld hl,ngsinitokstr
.gsonly
	xor a
	ld (isgsdisabled),a
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
;out: a = device mask, zf=1 if the file is ready for playing, zf=0 otherwise
	call ismodfile
	ld a,1
	jr z,$+3
	dec a
	ld (isplayingmodfile),a
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
	ld a,(isplayingmodfile)
	or a
	jr nz,loadmod
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
	ld a,DEVICE_NEOGS_MASK
	cp a
	ret

TITLELENGTH = 64
MODHEADERSIZE = 1084

loadmod
	ld hl,MODHEADERSIZE
	ld de,BUFADDR
	call readstream_file
;init progress
	call getmodtype
	ld a,(BUFADDR+950)
	jr z,$+5
	ld a,(BUFADDR+470)
	call setprogressdelta
;set title
	ld hl,titlestr
	ld (MUSICTITLEADDR),hl
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
	ld hl,BUFADDR
	ld bc,MODHEADERSIZE
.uploadloop
	ld a,(hl)
	out (GSDAT),a
	WD
	inc hl
	dec bc
	ld a,b
	or c
	jr nz,.uploadloop
	ld hl,BUFSIZE
	ld de,BUFADDR
	push de
	call readstream_file
	ex (sp),hl
	pop bc
	ld a,b
	or c
	jr nz,.uploadloop
	call closestream_file
;close stream
	SC 0xD2
	WC
;play module
	ld a,1
	out (GSDAT),a
	SC 0x31
	WC
	xor a
	ld (currentposition),a
	ld a,DEVICE_GS_MASK
	ret

musicunload
	ld a,(isplayingmodfile)
	or a
	jr nz,unloadmod
	call closestream_file
	jp gscodereset

unloadmod
	SC 0xf3
	WC
	ret

musicplay
;out: zf=0 if still playing, zf=1 otherwise
isplayingmodfile=$+1
	ld a,0
	or a
	jr nz,playmod

bufferreadptr=$+1
	ld hl,0
bufferdataleft=$+1
	ld bc,0
	ld a,c
	or b
	jr nz,checkifcanupload
readfilechunk
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
	jr checkifcanupload

uploaddataloop
	ld a,(hl)
	out (GSDAT),a
	WD
	inc hl
	djnz uploaddataloop
	dec c
	jr z,readfilechunk          ;done uploading current chunk
	bit 0,c
	jr z,uploaddataloop         ;poll GS once per 512 bytes
checkifcanupload
	SC CMDGETFREEBUFFERSPACE
	WC
	WN
	GD
	cp 6
	jr nc,uploaddataloop	    ;keep uploading until we have less than 1024 free buffer space
	ld (bufferreadptr),hl
	ld (bufferdataleft),bc
	YIELD
	or 1
	ret

playmod
	YIELD
	YIELD
	YIELD
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
gsinitok
	db "GS\r\n",0
nodevicestr
	db "no device!\r\n",0
playernamestr
	db "GS/NeoGS",0
end

currentposition
	ds 1
filechunkcounter
	ds 2
titlestr
	ds TITLELENGTH+1

	savebin "mp3.bin",begin,end-begin
