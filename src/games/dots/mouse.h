#ifndef __LIB_MOUSE
#define __LIB_MOUSE

static u8 mouse_x,mouse_y;

void mouse_read(void)__naked
{
__asm
	jp _MOUSE_POS
__endasm;
}

u8 mouse_position(void)
{
	u8 mousebtn;

	mouse_read();

	mouse_x=*(u16*)_MOUSE_X;
	mouse_y=*(u16*)_MOUSE_Y;
	mousebtn=*(u16*)_MOUSE_BTN;
	return mousebtn;
}

void mouse_setup(u8 x,u8 y)
{
__asm
	ld hl,#2
	add hl,sp
	ld a,(hl)
	ld (_MOUSE_X),a
	inc hl
	ld a,(hl)
	ld (_MOUSE_Y),a
__endasm;
}

void mouse_clipping(u8 xmin,u8 ymin,u8 xmax,u8 ymax) __naked
{
__asm
	ld hl,#2
	add hl,sp
	ld a,(hl)
	ld (_MOUSE_CX1),a
	inc hl
	ld a,(hl)
	ld (_MOUSE_CY1),a
	inc hl
	ld a,(hl)
	ld (_MOUSE_CX2),a
	inc hl
	ld a,(hl)
	ld (_MOUSE_CY2),a
__endasm;
}

#endif