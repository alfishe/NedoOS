MEMORYBUFFERMAXPAGES = 150

memorybufferloadfile
;de = file name
;b = max number of pages to read (MEMORYBUFFERMAXPAGES max)
;out: zf=1 if successful, zf=0 otherwise
	push bc
	call openstream_file
	pop bc
	or a
	ret nz

	ld hl,memorybufferpages
	ld (memorybuffercurrentpage),hl
	ld hl,0
	ld de,hl
	ld c,l
.loadloop
	inc c
	push bc
	push de
	push hl

	OS_NEWPAGE
	ld hl,(memorybuffercurrentpage)
	ld (hl),e
	inc hl
	ld (memorybuffercurrentpage),hl

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
	bit 6,b
	pop bc
	jr z,$+4
	djnz .loadloop
	push af
	ld (memorybuffersize+0),hl
	ld (memorybuffersize+2),de
	ld a,c
	ld (memorybufferpagecount),a
	call closestream_file
	pop af
	ret z
	jr memorybufferfree

memorybufferfree
	ld hl,memorybufferpages
memorybufferpagecount=$+1
	ld b,0
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
	ld (memorybuffercurrentpage),hl
	ret

memorybuffernextpage
memorybuffercurrentpage=$+1
	ld hl,0
	push af
	ld a,(hl)
	inc hl
	ld (memorybuffercurrentpage),hl
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

memorybuffersize
	ds 4
memorybufferpages
	ds MEMORYBUFFERMAXPAGES
