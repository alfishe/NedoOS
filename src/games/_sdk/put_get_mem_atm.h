#ifndef __MEM
#define __MEM
#include "startup.h"

void put_mem(u8 pg, u16 addr, u8 data) __naked
{
//addr=32768+nn
__asm
	push	ix
	ld	ix,#0
	add	ix,sp
//pg
ld a,4 (ix)
xor #0x7f
ld bc,#0xbff7
ld (_MEMSLOT2),a
out (c),a
//addr
ld l,5 (ix)
ld h,6 (ix)
//data
ld a,7 (ix)
ld (hl),a
ld a,#0x71
out (c),a
	pop ix
	ret
__endasm;
}


u8 get_mem(u8 pg, u16 addr) __naked
{
//addr=32768+nn
__asm
	push	ix
	ld	ix,#0
	add	ix,sp
//pg
ld a,4 (ix)
xor #0x7f
ld bc,#0xbff7
ld (_MEMSLOT2),a
out (c),a
//addr
ld l,5 (ix)
ld h,6 (ix)
//data
ld l,(hl)
ld a,#0x71
out (c),a
	pop ix
	ret
__endasm;
} 

void put_memw(u8 pg, u16 addr, u16 data) __naked
{
//addr=32768+nn
__asm
	push	ix
	ld	ix,#0
	add	ix,sp
//pg
	ld a,4 (ix)
	xor #0x7f
	ld bc,#0xbff7
	ld (_MEMSLOT2),a
	out (c),a
//addr
	ld l,5 (ix)
	ld h,6 (ix)
//data
	ld a,7 (ix)
	ld (hl),a
	inc	hl
	ld	a,8 (ix)
	ld	(hl),a	
	ld a,#0x71
	out (c),a
	pop ix
	ret
__endasm;
}


u16 get_memw(u8 pg, u16 addr) __naked
{
//addr=32768+nn
__asm
	push	ix
	ld	ix,#0
	add	ix,sp
//pg
	ld a,4 (ix)
	xor #0x7f
	ld bc,#0xbff7
	ld (_MEMSLOT2),a
	out (c),a
//addr
	ld l,5 (ix)
	ld h,6 (ix)
//data
	ld	a,(hl)
	inc	hl
	ld h,(hl)
	ld	l,a
	ld a,#0x71
	out (c),a
	pop ix
	ret
__endasm;
} 


void put_meml(u8 pg, u16 addr, u32 data) __naked
{
//addr=32768+nn
__asm
//pg
	ld a,4 (ix)
	xor #0x7f
	ld bc,#0xbff7
	ld (_MEMSLOT2),a
	out (c),a
//addr
	ld l,5 (ix)
	ld h,6 (ix)
//data
	ld a,7 (ix)
	ld (hl),a
	inc	hl
	ld	a,8 (ix)
	ld	(hl),a	
	inc	hl
	ld a,9 (ix)
	ld (hl),a
	inc	hl
	ld a,10 (ix)
	ld (hl),a
	ld a,#0x71
	out (c),a
__endasm;
}


u32 get_meml(u8 pg, u16 addr) __naked
{
//addr=32768+nn
__asm
//pg
	ld a,4 (ix)
	xor #0x7f
	ld bc,#0xbff7
	ld (_MEMSLOT2),a
	out (c),a
//addr
	ld l,5 (ix)
	ld h,6 (ix)
//data
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld a,#0x71
	out (c),a
__endasm;
}


#endif