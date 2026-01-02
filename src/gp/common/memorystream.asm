memorystreamloadfile
;de = file name
;out: zf=1 if successful, zf=0 otherwise
;configurable params:
; .pagestoload <= MEMORYSTREAMMAXPAGES
; .errormask = 0xff to require loading the entire file into memory, 0x00 if only [pagestoload] needed
;ON_DATA_LOADED_CALLBACK defines label called upon every page load
	call openstream_file
	or a
	ld a,MEMORYSTREAMERROR_FILEIO
	ld (memorystreamerrorcode),a
	ret nz
	ifdef ON_FILE_OPENED_CALLBACK
	call ON_FILE_OPENED_CALLBACK
	endif
	ld hl,0
	ld de,hl
	ld c,l
.pagestoload=$+1
	ld b,MEMORYSTREAMMAXPAGES
.loadloop
	ld a,c
	ld (.pageindex),a
	inc c ;increase page count
	push bc
	push de
	push hl
	OS_NEWPAGE
	or a
	jr z,.pageallocated
	pop hl
	pop de
	pop bc
	dec c ;decrease page count because there's no page
	ld a,MEMORYSTREAMERROR_OOM
	ld (memorystreamerrorcode),a
	jr .breakloop
.pageallocated
.pageindex=$+1
	ld a,0
	add a,memorystreampages%256
	ld l,a
	adc a,memorystreampages/256
	sub l
	ld h,a
	ld (hl),e
	inc hl
	ld (memorystreampageaddr),hl
	ld a,e
	ld (memorystreamcurrentpage),a
	SETPG8000
	ld de,0x8000
	ld hl,0x4000
	call readstream_file
	ex (sp),hl
	pop bc
	pop de
	add hl,bc
	jr nc,$+3
	inc e
	ld a,b
	pop bc
	ifdef ON_DATA_LOADED_CALLBACK
	push hl,de,bc,af
	res 6,h
	set 7,h
	and 0x40
	jr z,$+5
	ld hl,0xc000
	ld (memorystreamcurrentaddr),hl
	ld a,c
	ld (memorystreampagecount),a
	call ON_DATA_LOADED_CALLBACK
	pop bc
	ld a,b
	pop bc,de,hl
	jr nz,.breakloop
	endif
	and 0x40
	jr z,.breakloop
	djnz .loadloop
.errormask=$+1
	and MEMORYSTREAMERRORMASK
.breakloop
	push af
	ld (memorystreamsize+0),hl
	ld (memorystreamsize+2),de
	ld a,c
	ld (memorystreampagecount),a
	call closestream_file
	pop af
	jp nz,memorystreamfree
	ld a,MEMORYSTREAMERROR_SUCCESS
	ld (memorystreamerrorcode),a
	ret

memorystreamfree
;out: zf=0 so that this function can be used to return error condition
memorystreampagecount=$+1
	ld a,0
	call memorystreamfreecustompagecount
	or 1
	ret

memorystreamfreecustompagecount
;a = page count
;UNUSED_PAGE_ADDR defines address containing page index used to mark the pages that are already released
	or a
	ret z
	ld b,a
	ld hl,memorystreampages
.pagefreeloop
	ld e,(hl)
	ifdef UNUSED_PAGE_ADDR
	ld a,(UNUSED_PAGE_ADDR)
	cp e
	jr z,.alreadydeleted
	ld (hl),a
	endif
	push bc
	push hl
	OS_DELPAGE
	pop hl
	pop bc
.alreadydeleted
	inc hl
	djnz .pagefreeloop
	ret

memorystreamstart
	ld hl,0xffff
	ld (memorystreamcurrentaddr),hl
	ld hl,memorystreampages
	ld (memorystreampageaddr),hl
	ret

memorystreamnextpage
memorystreampageaddr=$+1
	ld hl,0
	push af
	ld a,(hl)
	inc hl
	ld (memorystreamcurrentpage),a
	ld (memorystreampageaddr),hl
	push bc
	SETPG8000
	pop bc
	pop af
	ld hl,0x8000
	ret

memorystreamskip
;b = byte count
	ld hl,(memorystreamcurrentaddr)
.loop	bit 6,h
	call nz,memorystreamnextpage
	inc hl
	djnz .loop
	ld (memorystreamcurrentaddr),hl
	ret

	macro memory_stream_write_byte src
	bit 6,h
	call nz,memorystreamnextpage
	ld (hl),src
	inc hl
	endm

	macro memory_stream_read_byte dest
	bit 6,h
	call nz,memorystreamnextpage
	ld dest,(hl)
	inc hl
	endm

	macro memory_stream_read_1 dst
	ld hl,(memorystreamcurrentaddr)
	memory_stream_read_byte dst
	ld (memorystreamcurrentaddr),hl
	endm

	macro memory_stream_read_2 dst1,dst2
	ld hl,(memorystreamcurrentaddr)
	memory_stream_read_byte dst1
	memory_stream_read_byte dst2
	ld (memorystreamcurrentaddr),hl
	endm

	macro memory_stream_read_3 dst1,dst2,dst3
	ld hl,(memorystreamcurrentaddr)
	memory_stream_read_byte dst1
	memory_stream_read_byte dst2
	memory_stream_read_byte dst3
	ld (memorystreamcurrentaddr),hl
	endm

memorystreamread1
;out: a = byte
	memory_stream_read_1 a
	ret

memorystreamread2
;out: de = word
	memory_stream_read_2 e,d
	ret

memorystreamread3
;out: c = byte0, e = byte1, d = byte2
	memory_stream_read_3 c,e,d
	ret

memorystreamread4
;out: adbc = dword
memorystreamcurrentaddr=$+1
	ld hl,0
	memory_stream_read_byte c
	memory_stream_read_byte b
	memory_stream_read_byte d
	memory_stream_read_byte a
	ld (memorystreamcurrentaddr),hl
	ret

memorystreamread
;bc = number of bytes
;de = dest addr
	ld a,c
	dec bc
	inc b
	ld c,b
	ld b,a
	ld hl,(memorystreamcurrentaddr)
.readloop
	memory_stream_read_byte a
	ld (de),a
	inc de
	djnz .readloop
	dec c
	jr nz,.readloop
	ld (memorystreamcurrentaddr),hl
	ret

memorystreamwrite
;bc = number of bytes
;de = src addr
	ld a,c
	dec bc
	inc b
	ld c,b
	ld b,a
	ld hl,(memorystreamcurrentaddr)
.writeloop
	ld a,(de)
	memory_stream_write_byte a
	inc de
	djnz .writeloop
	dec c
	jr nz,.writeloop
	ld (memorystreamcurrentaddr),hl
	ret

memorystreamseek
;dehl = absolute position
;out: hl = read address
	ld a,e
	ld b,h
	sla b
	rla
	sla b
	rla
	add a,memorystreampages%256
	ld e,a
	adc a,memorystreampages/256
	sub e
	ld d,a
	ld a,(de)
	ld (memorystreamcurrentpage),a
	inc de
	ld (memorystreampageaddr),de
	SETPG8000
	res 6,h
	set 7,h
	ld (memorystreamcurrentaddr),hl
	ret

memorystreamgetpos
;out: dehl = absolute position
	ld hl,(memorystreampageaddr)
	ld de,-memorystreampages-1
	add hl,de
	ex de,hl
	ld hl,(memorystreamcurrentaddr)
	res 7,h
	bit 6,h
	jr z,$+6
	inc de
	ld hl,0
	xor a
	rr e
	rra
	rr e
	rra
	or h
	ld h,a
	ret

MEMORYSTREAMERROR_SUCCESS = 0
MEMORYSTREAMERROR_FILEIO  = 1
MEMORYSTREAMERROR_OOM     = 2

memorystreamsize
	ds 4
memorystreampages
	ds MEMORYSTREAMMAXPAGES
memorystreamcurrentpage
	ds 1
memorystreamerrorcode
	ds 1
