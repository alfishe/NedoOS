MEMORYBUFFERMAXPAGES = 255

memorybufferloadfile
;de = file name
;out: zf=1 if successful, zf=0 otherwise
	call openstream_file
	or a
	ret nz

	ld hl,memorybufferpages
	ld (memorybufferpageaddr),hl
	ld hl,0
	ld de,hl
	ld c,l
	ld b,MEMORYBUFFERMAXPAGES
.loadloop
	push bc
	push de
	push hl
	OS_NEWPAGE
	or a
	jr z,.pageallocated
	pop hl
	pop de
	pop bc
	jr .breakloop

.pageallocated
	ld hl,(memorybufferpageaddr)
	ld (hl),e
	inc hl
	ld (memorybufferpageaddr),hl

	ld a,e
	SETPG8000

	ld de,0x8000
	ld hl,0x4000
	call readstream_file
	ex (sp),hl
	pop bc
	add hl,bc
	pop de
	jr nc,$+3
	inc e
	ld a,b
	pop bc
	inc c
	and 0x40
	jr z,.breakloop
	djnz .loadloop
.breakloop
	push af
	ld (memorybuffersize+0),hl
	ld (memorybuffersize+2),de
	ld a,c
	ld (memorybufferpagecount),a
	call closestream_file
	pop af
	ret z
	call memorybufferfree
	or 1
	ret

memorybufferallocate
;dehl = buffer size
;out: zf=1 if successful, zf=0 otherwise
	ld (memorybuffersize+0),hl
	ld (memorybuffersize+2),de
	ld a,e
	ld de,0x3fff
	add hl,de
	ld c,0
	adc a,c
	sla h
	rla
	sla h
	rla
	ld b,a
	ld a,MEMORYBUFFERMAXPAGES
	cp b
	ret c
	ld hl,memorybufferpages
.loop
	push bc
	push hl
	OS_NEWPAGE
	pop hl
	pop bc
	or a
	jr z,.pageallocated
	ld a,c
	ld (memorybufferpagecount),a
	call memorybufferfree
	or 1
	ret

.pageallocated
	ld (hl),e
	inc hl
	inc c
	djnz .loop
	ld a,c
	ld (memorybufferpagecount),a
	xor a
	ret

memorybufferfree
memorybufferpagecount=$+1
	ld a,0
	or a
	ret z
	ld b,a
	ld hl,memorybufferpages
.pagefreeloop
	push bc
	push hl
	ld e,(hl)
	OS_DELPAGE
	pop hl
	pop bc
	inc hl
	djnz .pagefreeloop
	ret

memorybufferstart
	ld hl,0xffff
	ld (memorybuffercurrentaddr),hl
	ld hl,memorybufferpages
	ld (memorybufferpageaddr),hl
	ret

memorybuffernextpage
memorybufferpageaddr=$+1
	ld hl,0
	push af
	ld a,(hl)
	inc hl
	ld (memorybuffercurrentpage),a
	ld (memorybufferpageaddr),hl
	push bc
	SETPG8000
	pop bc
	pop af
	ld hl,0x8000
	ret

memorybufferskip
;b = byte count
	ld hl,(memorybuffercurrentaddr)
.loop
	bit 6,h
	call nz,memorybuffernextpage
	inc hl
	djnz .loop
	ld (memorybuffercurrentaddr),hl
	ret

	macro memory_buffer_write_byte src
	bit 6,h
	call nz,memorybuffernextpage
	ld (hl),src
	inc hl
	endm

	macro memory_buffer_read_byte dest
	bit 6,h
	call nz,memorybuffernextpage
	ld dest,(hl)
	inc hl
	endm

	macro memory_buffer_read_1 dst
	ld hl,(memorybuffercurrentaddr)
	memory_buffer_read_byte dst
	ld (memorybuffercurrentaddr),hl
	endm

	macro memory_buffer_read_2 dst1,dst2
	ld hl,(memorybuffercurrentaddr)
	memory_buffer_read_byte dst1
	memory_buffer_read_byte dst2
	ld (memorybuffercurrentaddr),hl
	endm

	macro memory_buffer_read_3 dst1,dst2,dst3
	ld hl,(memorybuffercurrentaddr)
	memory_buffer_read_byte dst1
	memory_buffer_read_byte dst2
	memory_buffer_read_byte dst3
	ld (memorybuffercurrentaddr),hl
	endm

memorybufferread1
;out: a = byte
	memory_buffer_read_1 a
	ret

memorybufferread2
;out: de = word
	memory_buffer_read_2 e,d
	ret

memorybufferread3
;out: c = byte0, e = byte1, d = byte2
	memory_buffer_read_3 c,e,d
	ret

memorybufferread4
;out: adbc = dword
memorybuffercurrentaddr=$+1
	ld hl,0
	memory_buffer_read_byte c
	memory_buffer_read_byte b
	memory_buffer_read_byte d
	memory_buffer_read_byte a
	ld (memorybuffercurrentaddr),hl
	ret

memorybufferread
;bc = number of bytes
;de = dest addr
	ld a,c
	dec bc
	inc b
	ld c,b
	ld b,a
	ld hl,(memorybuffercurrentaddr)
.readloop
	memory_buffer_read_byte a
	ld (de),a
	inc de
	djnz .readloop
	dec c
	jr nz,.readloop
	ld (memorybuffercurrentaddr),hl
	ret

memorybufferwrite
;bc = number of bytes
;de = src addr
	ld a,c
	dec bc
	inc b
	ld c,b
	ld b,a
	ld hl,(memorybuffercurrentaddr)
.writeloop
	ld a,(de)
	memory_buffer_write_byte a
	inc de
	djnz .writeloop
	dec c
	jr nz,.writeloop
	ld (memorybuffercurrentaddr),hl
	ret

memorybufferseek
;dehl = absolute position
;out: hl = read address
	ld a,e
	ld b,h
	sla b
	rla
	sla b
	rla
	add a,memorybufferpages%256
	ld e,a
	adc a,memorybufferpages/256
	sub e
	ld d,a
	ld a,(de)
	inc de
	ld (memorybufferpageaddr),de
	SETPG8000
	res 6,h
	set 7,h
	ld (memorybuffercurrentaddr),hl
	ret

memorybuffersize
	ds 4
memorybufferpages
	ds MEMORYBUFFERMAXPAGES
memorybuffercurrentpage
	ds 1
