	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"
	include "playerdefs.asm"

	org PLAYERSTART

begin   PLAYERHEADER

isfilesupported
;cde = file extension
mdrsupported=$+1
	ld a,'m'
	cp c
	ret nz
	ld hl,'dr'
	sub hl,de
	ret

playerinit
;hl = shared pages
;a = player page
	call ismoonsoundpresent
	ret z
	ld (mdrsupported),a ;writes 255 disabling the extension
	ret

playerdeinit
	ret

musicload
;de = input file name
	call openstream_file
	or a
	ret nz

	ld hl,datapages
	ld bc,0x8000
loadloop
	push bc
	push hl
	OS_NEWPAGE
	pop hl
	pop bc
	ld (hl),e

	ld a,c
	inc c
	call change_page3

	push bc
	push hl
	ld de,0x8000
	ld hl,0x4000
	call readstream_file
	bit 6,h
	pop hl
	pop bc
	jr z,exitloadloop

	inc hl
	djnz loadloop

exitloadloop
	ld a,c
	ld (datapagecount),a

	call closestream_file

	call moon_load_pcm
	call moon_init_all
	call resetloopflag

	xor a
	ld (loopcount),a

	ld de,0x022f
	call moon_fm1_out

	ld de,0x0421
	call moon_fm1_out

	xor a
	ret

musicunload
	call moon_seq_all_keyoff

	ld hl,datapages
datapagecount=$+1
	ld b,0
pagefreeloop
	push bc
	push hl
	ld e,(hl)
	OS_DELPAGE
	pop hl
	pop bc
	inc hl
	djnz pagefreeloop
	ret

musicplay
;out: zf=0 if still playing, zf=1 otherwise
	in a,(MOON_STAT)
	rla
	jr nc,musicplay

	ld de,0x0481
	call moon_fm1_out

	call moon_proc_tracks
	call checkifallchannelslooped
	ret nz

	call resetloopflag

	ld hl,loopcount
	inc (hl)
	ld a,(hl)
	cp 2 ;repeat twice
	ret

change_page3
	push bc
	add a,datapages%256
	ld c,a
	adc a,datapages/256
	sub c
	ld b,a
	ld a,(bc)
	SETPG8000
	pop bc
	ret

resetloopflag
	ld hl,seq_work+IDX_NOT_LOOPED
	ld de,SEQ_WORKSIZE
	ld b,USE_CH
	ld a,255
resetloopflagloop
	ld (hl),a
	add hl,de
	djnz resetloopflagloop
	ret

checkifallchannelslooped
; zf=1 if all channels looped at least once, zf=0 otherwise
	xor a
	call change_page3_bank
	ld hl,seq_work+IDX_NOT_LOOPED
	ld de,SEQ_WORKSIZE
	ld a,(S_DEVICE_FLAGS)
	or a
	jr z,checkopl4
	rrca
	jr nc,checkopl3
checkopl4
	ld c,a
	ld b,$18 ;24 channels OPL4
	call checkchannels
	ret nz
	ld a,c
checkopl3
	or a
	ret z
	ld b,$12 ;18 channels OPL3
checkchannels
	ld a,(hl)
	or a
	ret nz
	add hl,de
	djnz checkchannels
	ret

	include "../_sdk/file.asm"
	include "moonsound.asm"
	include "moondriver/moon_driver.asm"

end

datapages
	ds 128 ;there are max. 256 banks 8192 bytes each, so we can use up to 128 16k-pages
loopcount
	ds 1

	savebin "mdr.bin",begin,end-begin
