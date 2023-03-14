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
isgsdisabled=$+1
	jr nosupportedfiles
	call ismodfile
	ret z
vsversion=$+1
	ld a,255
	ld l,'m'
	ld h,b
	sub hl,bc
	jr nz,checkogg
	ld hl,'id'
	sub hl,de
	jr nz,checkogg
	cp SS_VER_VS1003
	ret z
	cp SS_VER_VS1033
	ret z
	cp SS_VER_VS1053
	ret z
	cp SS_VER_VS1103
	ret
checkogg
	ld l,'o'
	ld h,b
	sub hl,bc
	jr nz,checkaac
	ld hl,'gg'
	sub hl,de
	jr nz,checkaac
	cp SS_VER_VS1053
	ret z
	cp SS_VER_VS1063
	ret	
checkaac
	ld l,'a'
	ld h,b
	sub hl,bc
	jr nz,checkmp3
	ld hl,'ac'
	sub hl,de
	jr nz,checkmp3
	cp SS_VER_VS1033
	ret z
	cp SS_VER_VS1053
	ret z
	cp SS_VER_VS1063
	ret
checkmp3
	ld l,'m'
	ld h,b
	sub hl,bc
	ret nz
	ld hl,'p3'
	sub hl,de
	ret nz
	and ~SS_VER_MASK
	ret
nosupportedfiles
	or 1
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

playerinit
;hl = shared pages
;a = player page
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
	ret c

;get chip id
	call gsstartcode
	SC CMDGETCHIPID
	WC
	WN
	GD
	ld (vsversion),a
	call gscodereset

	xor a
	ld (isgsdisabled),a
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
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

	call gsstartcode

	ld hl,firstpaddingframedata
	ld (paddingframedataptr),hl
	ld hl,0
	ld (paddingframecount),hl
	ld (bufferdataleft),hl

	xor a
	ret

loadmod
;load module
	SC 0x30
	WC
;open stream
	SC 0xD1
	WC
.loadchunk
	ld hl,BUFSIZE
	ld de,BUFADDR
	push de
	call readstream_file
	ex (sp),hl
	pop bc
	ld a,b
	or c
	jr z,.doneloading
.uploadloop
	ld a,(hl)
	out (GSDAT),a
	WD
	inc hl
	dec bc
	ld a,b
	or c
	jr nz,.uploadloop
	jr .loadchunk

.doneloading
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
	ld (patternindex),a
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
;read pattern index
	SC 0x60
	WC
	WN
	GD
;check if the index is increasing monotonically
	ld hl,patternindex
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
	ret z
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

playernamestr
	db "GS/NGS",0
end

patternindex
	db 0

	savebin "mp3.bin",begin,end-begin
