;for s3m_period in 1...4095      -> lookup_table[s3m_period-1] = opl4_regs(s3m_period)
;for s3m_period in 4096...32767  -> lookup_table[(s3m_period-4096)/8+4096] = opl4_regs(s3m_period)

	DEVICE ZXSPECTRUM128
	include "../_sdk/sys_h.asm"

	org PROGSTART
begin
	ld sp,0x4000
	OS_HIDEFROMPARENT
	ld e,6 ;textmode
	OS_SETGFX
	ld e,7
	OS_CLS
	ld hl,generatingstr
	call print_hl
	ld de,0x8000
	ld hl,1
	ld bc,4096
	ld a,1
	call writetablechunk
	ld bc,4096
	ld a,8
	call writetablechunk
;write table to disk
	ld hl,writingstr
	call print_hl
	ld de,outfilenamestr
	call openstream_file
	or a
	jr z,.openedfile
	ld de,outfilenamestr
	OS_CREATEHANDLE
	or a
	ld hl,unabletowriteoutputstr
	jp nz,printerrorandexit
	ld a,b
	ld (filehandle),a
.openedfile
	ld a,(filehandle)
	ld b,a
	ld de,0x8000
	ld hl,0x4000
	OS_WRITEHANDLE
	call closestream_file
	xor a
	QUIT

printerrorandexit
	call print_hl
	ld hl,pressanykeystr
	call print_hl
	YIELDGETKEYLOOP
	QUIT

writetablechunk
;hl = s3m period
;de = write addr
;bc = iterations
;a = period increment
	ld (.increment),a
.loop	push bc
	push hl
	call writelookupentry
	pop hl
.increment=$+1
	ld bc,0
	add hl,bc
	pop bc
	dec bc
	ld a,b
	or c
	jr nz,.loop
	ret

writelookupentry
;hl = s3m period
;de = write addr
	push de
	call opl4period
	pop de
	add hl,hl
	ld a,b
	add a,a
	add a,a
	add a,a
	add a,a
	or h
	ld (de),a
	inc de
	ld a,l
	or 1
	ld (de),a
	inc de
	ret

opl4period
;hl = s3m period
;out: hl = f-number, b = octave
	ld de,0
	exx
	ld de,0x0512
	ld hl,0xb383
	call uintdiv32
	push de
	push hl
	ld b,-7
	exx
	pop hl
	pop de
	srl de : rr h
	srl de : rr h
	srl de : rr h
	ld a,d
	or e
	or h
	jr z,.skip
.loop	exx
	inc b
	srl de : rr hl
	exx
	srl de : rr h
	ld a,d
	or e
	or h
	jr nz,.loop
.skip	exx
	ld a,h
	and 0x3
	ld h,a
	ret

	include "../_sdk/file.asm"
	include "common/muldiv.asm"

print_hl
	ld a,(hl)
	or a
	ret z
	push hl
	PRCHAR
	pop hl
	inc hl
	jp print_hl

generatingstr
	db "Generating table...\r\n",0
writingstr
	db "Writing table...\r\n",0
outfilenamestr
	db "periodlookup.bin",0
unabletowriteoutputstr
	db "Failed to write output",0
pressanykeystr
	db "!\r\nPress any key to exit...\r\n",0
end

	savebin "generateperiodlookup.com",begin,end-begin
