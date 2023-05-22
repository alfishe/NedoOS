        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
begin
	ld sp,0x4000
        call initstdio

	ld hl,okstr
	call prtext

	call ismoonsoundpresent

	ld hl,okstr
	call prtext


	call opl4_init

	ld hl,okstr
	call prtext

	ld bc,9
	ld d,0
	ld hl,0x1200
	ld ix,step_buffer
	call opl4_readmemory

	ld hl,step_buffer
	call prtext

	ld de,infnamestr
	call memorybufferloadfile
	jr z,.loadok
        QUIT

.loadok
	ld hl,okstr
	call prtext

	call memorybufferstart

	ld hl,(memorybuffersize)
	ld a,(memorybuffersize+2)
	ld d,a
	exx 
	ld hl,0
	ld d,0x20
	call opl4_loadsample

	ld hl,okstr
	call prtext

	call memorybufferfree

;	call opl4_init

	ld de,outfilenamestr
	call openstream_file

	ld hl,0
	ld d,0x20
	ld b,19
.saveloop
	push bc
	push de
	push hl

	ld bc,16384
	ld ix,0xc000
	call opl4_readmemory

	ld de,0xc000
	ld hl,0x4000
        ld a,(filehandle)
	ld b,a
	OS_WRITEHANDLE

	pop hl
	ld bc,16384
	add hl,bc
	pop de
	jr nc,$+3
	inc d
	pop bc
	djnz .saveloop

	call closestream_file        
        QUIT

prtext
;hl=text
        push hl
        call strlen ;hl=length
        pop de ;de=text
        jp sendchars

strlen
;hl=str
;out: hl=length
        xor a
        ld b,a
        ld c,a ;чтобы точно найти терминатор
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret

okstr
	db "\r\nBEBE",0
infnamestr
	db "timesup.mdr",0
outfilenamestr
	db "test.out",0
step_buffer
	db "                             ",0

        include "../_sdk/stdio.asm"
	include "../_sdk/file.asm"
	include "memorybuffer.asm"
	include "moonsound.asm"
	include "opl4.asm"
end
	savebin "hello.com",begin,end-begin

	LABELSLIST "../../us/user.l",1
