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
;out: zf=1 if init is successful, hl=init message
	call ismoonsoundpresent
	ld hl,nodevicestr
	jr nz,disableplayer

;initialize to enable OPL4 function
	call moon_init
;memory write mode
	ld de,$0211
	call moon_wave_out
;check ROM
	call moon_check_rom
	ld hl,initokstr
	ret z

	ld hl,firmwareerrorstr
	ld a,255
disableplayer
	ld (mdrsupported),a ;writes 255 disabling the extension
	ret

playerdeinit
	ret

musicload
;cde = file extension
;hl = input file name
	ex de,hl
	ld b,MEMORYBUFFERMAXPAGES
	call memorybufferloadfile
	ret nz

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
	jp memorybufferfree

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
	add a,memorybufferpages%256
	ld c,a
	adc a,memorybufferpages/256
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
	include "memorybuffer.asm"
	include "moondriver/moon_driver.asm"

initokstr
	db "OK\r\n",0
firmwareerrorstr
	db "requires ZXM-MoonSound firmware 1.01!\r\n",0
nodevicestr
	db "no device!\r\n",0
playernamestr
	db "MoonSound MoonDriver",0
end

loopcount
	ds 1

	savebin "mdr.bin",begin,end-begin
