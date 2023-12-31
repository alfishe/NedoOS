        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

SAVEDATA=0x4000
SAVEDATAsz=0x8000

        org PROGSTART
begin
	OS_HIDEFROMPARENT
        ld e,0 ;EGA
        OS_SETGFX
;memorize screen pages
;don't do this in regular programs!!!
	ld a,(user_scr0_low)
	ld (my_scr0_low),a
	ld a,(user_scr0_high)
	ld (my_scr0_high),a
	ld a,(user_scr1_low)
	ld (my_scr1_low),a
	ld a,(user_scr1_high)
	ld (my_scr1_high),a
        ld e,-1 ;disable gfx (out: e=old gfxmode)
        OS_SETGFX

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        push hl
	OS_DELPAGE ;4000
	pop hl
	push hl
	ld e,h
	OS_DELPAGE ;8000
	pop hl
	ld e,l
	OS_DELPAGE ;c000

loop
        YIELD
;wait for cs+ss+L keypress
	ld a,0x7f
	in a,(0xfe) ;space,ss...
	rra ;ss...
	ld bc,0xfefe
	in b,(c) ;cs...
	or b
	ld bc,0xbffe
	in b,(c) ;enter,L...
	rr b
	or b
	and 1
oldext=$+1
	ld c,0
	ld (oldext),a
	xor c
	jr z,loop
	bit 0,c
	jr z,loop ;was pressed
;keypress
	ld de,pal
	OS_GETPAL

	ld a,'0'
	ld (scrnum),a
my_scr0_low=$+1
	ld a,0
	SETPG4000
my_scr0_high=$+1
	ld a,0
	SETPG8000
	call savescreen
	ld a,'1'
	ld (scrnum),a
my_scr1_low=$+1
	ld a,0
	SETPG4000
my_scr1_high=$+1
	ld a,0
	SETPG8000
	call savescreen

	ld hl,filename+2
	
	ld a,(hl)
	inc (hl)
	cp '9'
	jr nz,noinc
	ld (hl),0

	dec hl
	ld a,(hl)
	inc (hl)
	cp '9'
	jr nz,noinc
	ld (hl),0

	dec hl	
	ld a,(hl)
	inc (hl)
	cp '9'
	jr nz,noinc
	ld (hl),0
	
noinc
	jp loop
        ;QUIT

savescreen
	ld de,filename
	OS_CREATEHANDLE
	push bc
	ld de,SAVEDATA
	ld hl,SAVEDATAsz
	push bc
	OS_WRITEHANDLE
	pop bc
	ld de,pal
	ld hl,32
	OS_WRITEHANDLE
	pop bc
	OS_CLOSEHANDLE
	ret


filename
	db "000scr0"
scrnum=$-1
	db ".16c",0

end
pal
	ds 32

	savebin "scrshot.com",begin,end-begin

	LABELSLIST "../../us/user.l",1
