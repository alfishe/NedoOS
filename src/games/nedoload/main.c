#include <evo.h>
#include "resources.h"
#include "startup.h"

static u16 gl_addr;
static u8 gl_page;
/*
void pset(u8 x,u8 y, u8 color) __naked
{
		__asm
		push	ix
		ld	ix,#0
		add	ix,sp
		
		ld a,(_SCREENACTIVE)//ищем нужную страницу
		bit 1,a
		jr z,secpageps
frstpageps:
		ld a,#0x1
		jp dopageps
secpageps:
		ld a,#0x3
dopageps:
		//read 	x
		ld c,#0x0
		ld b, 4 (ix)
		srl b
		push bc
		jr c,nechet
		jp done
nechet:	
		ld d,#0x4
		add a,d
		jp done
done:		
		ld (_gl_page),a
		//page
		xor #0x7f
		ld bc,#0xbff7
		ld (_MEMSLOT2),a
		out (c),a
//установили нужную страницу
//найдем нужный адрес
		pop bc
		srl b
		jr nc,nechet2
		ld hl,#0x2000
		jp done2
nechet2:	
		ld hl,#0x0
done2:
		ld c,b
		ld b,#0x0
		add hl,bc
		push hl
		
//смещение по y
//---------------------------		
		ld c,#0x0
		ld b, 5 (ix)
		dec b
		ld hl,#0x28
		ld de,#0x28
		jr z,zerps
mulps:
		add hl,de
		djnz mulps
zerps:	
		pop bc
		add hl,bc
		ld bc,#0x8000
		add hl,bc
//получим цвет
		ld c,#0x0
		ld b, 6 (ix)
		ld(hl),b
		
		
		ld bc,#0xbff7
		ld a,#0x71
		out (c),a
		pop ix
		ret
		__endasm;
}

*/
void do_scrolldown_sector(u8 shift,u8 start, u8 finish) __naked
{
			__asm
		push	ix
		ld	ix,#0
		add	ix,sp
		
		ld a,(_SCREENACTIVE)//ищем нужную страницу
		bit 1,a
		jr z,secpageds
frstpageds:
		ld a,#0x1
		jp dopageds
secpageds:
		ld a,#0x3
dopageds:
		ld (_gl_page),a
begds:		
		
		//page
		ld a,(_gl_page)
		xor #0x7f
		ld bc,#0xbff7
		ld (_MEMSLOT2),a
		out (c),a
beg2ds:		
//---------------------------		
		
//read 	addr
		ld c,#0x0
		ld b, 4 (ix)
		dec b
		ld hl,#0x28
		ld de,#0x28
		jr z,zerds
mulds:
		add hl,de
		djnz mulds
zerds:		
		ld de,(_gl_addr)
		ld b,h
		ld c,l
		//push bc//тут разница в строках
		add hl,de
		ld de,#0x1f40
		add hl,de
		push hl
//-----------------------------		
// write addr
		ld hl,(_gl_addr)
		ld de,#0x1f40
		add hl,de
		pop de
//---------------------------
//чтение и запись

	//---------------------------
		ld a,6 (ix)
		ld c,5 (ix)
		ld b,#0x0
		
		add hl,bc//сдвиг от начала экрана адреса откуда
		ex de,hl
		add hl,bc// сдвиг от начала экрана адреса куда
		ex de,hl
		
		sub c //теперь в А лежит ширина отрезка
		
		push af//тут лежит ширина отрезка
		push bc//тут лежит сдвиг от начала экрана
		
		ld b,#0xc9
		

movds:
		push bc
		push hl
		push de
		ld b,#0x0
		ld c,a
		ldir//перетаскиваем байты
		pop hl//теперь сдвинем адреса на 40 байт - новую строку
		ld bc,#0x28
		sbc hl, bc
		ld d,h
		ld e,l
		pop hl
		sbc hl, bc
		pop bc
		djnz movds
		
	//перенесём то что сдвинулось в конец, в начало
	//адр куда =_gl_addr
	//адр откуда=_gl_addr+#0x8000
	//скока = bc

		
		pop bc//отступ от нчала экрана
		ld hl,(_gl_addr)
		ld de,#0x1f40
		add hl,de
		add hl,bc
		ex de,hl
		ld hl,(_gl_addr)
		add hl,bc
		ex de,hl
		pop bc//ширина отрезка
		ld a,b
		
		ld c,#0x0
		ld b, 4 (ix)
		
adcpyds:		
		push bc
		ld b,#0x0
		ld c,a
		push hl
		push de
		ldir
		pop de
		pop hl
		ld bc,#0x28
		add hl, bc
		ex de,hl
		add hl, bc
		ex de,hl
		pop bc
		djnz adcpyds
		
//----------------------------
				
		ld hl,(_gl_addr)//проверим адрес
		ld bc,#0x8000
		sbc hl,bc
		
		jr z,addrifds
		jp nxtds
addrifds:
		ld hl,#0xa000
		ld(_gl_addr),hl
		jp beg2ds
nxtds:
		ld hl,#0x8000
		ld(_gl_addr),hl
		
		ld a,(_gl_page)
		ld b,#0x1
		sub b
		jr z, frst_chngds
		jp next_page_ifds
frst_chngds:
		ld a,#0x5
		ld (_gl_page),a
		jp begds
next_page_ifds:
		ld a,(_gl_page)
		ld b,#0x3
		sub b
		jr z, sec_chngds
		jp endds
sec_chngds:
		ld a,#0x7
		ld (_gl_page),a
		jp begds

endds:	ld bc,#0xbff7
		ld a,#0x71
		out (c),a
		pop ix
		ret
	__endasm;
}
void do_scrolldown_looped(u8 shift) __naked
{
		__asm
		push	ix
		ld	ix,#0
		add	ix,sp
		ld bc,#0x7ffd
		ld a,(_SCREENACTIVE)//ищем нужную страницу
		bit 1,a
		jr z,secpagedl
frstpagedl:
		ld a,#0x1
		jp dopagedl
secpagedl:
		ld a,#0x3
dopagedl:
		ld (_gl_page),a
begdl:		
		
		//page
		ld a,(_gl_page)
		xor #0x7f
		ld bc,#0xbff7
		ld (_MEMSLOT2),a
		out (c),a
beg2dl:		
//---------------------------		
//read 	addr
		ld c,#0x0
		ld b, 4 (ix)
		dec b
		ld hl,#0x28
		ld de,#0x28
		jr z,zerdl
muldl:
		add hl,de
		djnz muldl
zerdl:		
		ld de,(_gl_addr)
		ld b,h
		ld c,l
		push bc
		add hl,de
		ld de,#0x1f40
		add hl,de
		push hl
//-----------------------------		
// write addr
		ld hl,(_gl_addr)
		add hl,de
		push hl
//---------------------------
//чтение и запись
		//pop bc
		ld hl,#0x1f40
		//sbc hl,bc
		ld b,h
		ld c,l
		inc bc
		pop hl
		pop de
		
		push hl
		lddr
		pop hl
		pop bc
		ld de,(_gl_addr)
		
		ldir
//----------------------------
				
		ld hl,(_gl_addr)//проверим адрес
		ld bc,#0x8000
		sbc hl,bc
		
		jr z,addrifdl
		jp nxtdl
addrifdl:
		ld hl,#0xa000
		ld(_gl_addr),hl
		jp beg2dl
nxtdl:
		ld hl,#0x8000
		ld(_gl_addr),hl
		
		ld a,(_gl_page)
		ld b,#0x1
		sub b
		jr z, frst_chngdl
		jp next_page_ifdl
frst_chngdl:
		ld a,#0x5
		ld (_gl_page),a
		jp begdl
next_page_ifdl:
		ld a,(_gl_page)
		ld b,#0x3
		sub b
		jr z, sec_chngdl
		jp enddl
sec_chngdl:
		ld a,#0x7
		ld (_gl_page),a
		jp begdl

enddl:	ld bc,#0xbff7
		ld a,#0x71
		out (c),a
		pop ix
		ret
	__endasm;
}
void do_scrolldown(u8 shift) __naked
{
		__asm
		push	ix
		ld	ix,#0
		add	ix,sp

		ld a,(_SCREENACTIVE)//ищем нужную страницу
		bit 1,a
		jr z,secpaged
frstpaged:
		ld a,#0x1
		jp dopaged
secpaged:
		ld a,#0x3
dopaged:
		ld (_gl_page),a
begd:		
		
		//page
		ld a,(_gl_page)
		xor #0x7f
		ld bc,#0xbff7//устанавливаем нужную страницу
		ld (_MEMSLOT2),a
		out (c),a
beg2d:		
//---------------------------		
//read 	addr
		ld c,#0x0
		ld b, 4 (ix)//на сколько рядов нужно сдвинуть
		dec b
		ld hl,#0x28
		ld de,#0x28
		jr z,zerd
muld:
		add hl,de
		djnz muld
zerd:		
		ld de,(_gl_addr)//8000
		ld b,h
		ld c,l	
		
		add hl,de
		ld de,#0x1f40
		add hl,de
		push hl
//-----------------------------		
// write addr
		ld hl,(_gl_addr)
		add hl,de
		//ld de,#0x28
		//add hl,de
		push hl
//---------------------------
//чтение и запись
		//pop bc
		ld hl,#0x1f40
		sbc hl,bc
		ld b,h
		ld c,l
	
		pop hl
		pop de
		lddr
		
//----------------------------
				
		ld hl,(_gl_addr)//проверим адрес
		ld bc,#0x8000
		sbc hl,bc
		
		jr z,addrifd
		jp nxtd
addrifd:
		ld hl,#0xa000
		ld(_gl_addr),hl
		jp beg2d
nxtd:
		ld hl,#0x8000
		ld(_gl_addr),hl
		
		ld a,(_gl_page)
		ld b,#0x1
		sub b
		jr z, frst_chngd
		jp next_page_ifd
frst_chngd:
		ld a,#0x5
		ld (_gl_page),a
		jp begd
next_page_ifd:
		ld a,(_gl_page)
		ld b,#0x3
		sub b
		jr z, sec_chngd
		jp endd
sec_chngd:
		ld a,#0x7
		ld (_gl_page),a
		jp begd

endd:	ld bc,#0xbff7
		ld a,#0x71
		out (c),a
		pop ix
		ret
	__endasm;
}

void do_scrollup_sector(u8 shift,u8 start, u8 finish) __naked
{
		__asm
		push	ix
		ld	ix,#0
		add	ix,sp
	
		ld a,(_SCREENACTIVE)//ищем нужную страницу
		bit 1,a
		jr z,secpages
frstpages:
		ld a,#0x1
		jp dopages
secpages:
		ld a,#0x3
dopages:
		ld (_gl_page),a
begs:		
		
		//page
		ld a,(_gl_page)
		xor #0x7f
		ld bc,#0xbff7
		ld (_MEMSLOT2),a
		out (c),a
beg2s:		
//---------------------------		
		
	//перенесём начало за концом
	//адр откуда =_gl_addr
	//адр куда=_gl_addr+#0x8000
	//скока = bc
		ld bc,#0xA0
		ld hl,(_gl_addr)
		ld de,#0x1f40
		add hl,de
		ld d,h
		ld e,l
		ld hl,(_gl_addr)
		ldir

//read 	addr
		ld c,#0x0
		ld b, 4 (ix)
		dec b
		ld hl,#0x28
		ld de,#0x28
		jr z,zers
muls:
		add hl,de
		djnz muls
zers:		
		ld de,(_gl_addr)
		ld b,h
		ld c,l
		
		add hl,de
		
//-----------------------------		
// write addr
		ld de,(_gl_addr)

//---------------------------
//чтение и запись

	//---------------------------
		ld a,6 (ix)
		ld c,5 (ix)
		ld b,#0x0
		add hl,bc//сдвиг от начала экрана адреса откуда
		ex de,hl
		add hl,bc// сдвиг от начала экрана адреса куда
		ex de,hl
		sub c //теперь в А лежит ширина отрезка
		ld b,#0xc9
		
		
		
movs:
		push bc
		push hl
		push de
		ld b,#0x0
		ld c,a
		ldir//перетаскиваем байты
		pop hl//теперь сдвинем адреса на 40 байт - новую строку
		ld bc,#0x28
		add hl, bc
		ld d,h
		ld e,l
		pop hl
		add hl, bc
		pop bc
		djnz movs
//----------------------------
				
		ld hl,(_gl_addr)//проверим адрес
		ld bc,#0x8000
		sbc hl,bc
		
		jr z,addrifs
		jp nxts
addrifs:
		ld hl,#0xa000
		ld(_gl_addr),hl
		jp beg2s
nxts:
		ld hl,#0x8000
		ld(_gl_addr),hl
		
		ld a,(_gl_page)
		ld b,#0x1
		sub b
		jr z, frst_chngs
		jp next_page_ifs
frst_chngs:
		ld a,#0x5
		ld (_gl_page),a
		jp begs
next_page_ifs:
		ld a,(_gl_page)
		ld b,#0x3
		sub b
		jr z, sec_chngs
		jp ends
sec_chngs:
		ld a,#0x7
		ld (_gl_page),a
		jp begs

ends:	ld bc,#0xbff7
		ld a,#0x71
		out (c),a
		pop ix
		ret
	__endasm;
}

void do_scrollup_looped(u8 shift) __naked
{
	__asm
		push	ix
		ld	ix,#0
		add	ix,sp
		ld bc,#0x7ffd
		ld a,(_SCREENACTIVE)//ищем нужную страницу
		bit 1,a
		jr z,secpagel
frstpagel:
		ld a,#0x1
		jp dopagel
secpagel:
		ld a,#0x3
dopagel:
		ld (_gl_page),a
begl:		
		
		//page
		ld a,(_gl_page)
		xor #0x7f
		ld bc,#0xbff7
		ld (_MEMSLOT2),a
		out (c),a
beg2l:		
//---------------------------		
//read 	addr
		ld c,#0x0
		ld b, 4 (ix)
		dec b
		ld hl,#0x28
		ld de,#0x28
		jr z,zerl
mull:
		add hl,de
		djnz mull
zerl:		
		ld de,(_gl_addr)
		ld b,h
		ld c,l
		
		add hl,de
		push hl
//---------------------------
//перенесём начало за концом
//адр откуда =_gl_addr
//адр куда=_gl_addr+#0x8000
//скока = bc

		ld hl,(_gl_addr)
		ld de,#0x1f40
		add hl,de
		ld d,h
		ld e,l
		ld hl,(_gl_addr)
		ldir
//-----------------------------		
//-----------------------------		
// write addr
		ld de,(_gl_addr)

//---------------------------
//чтение и запись
		//pop bc
		ld hl,#0x1f40
		sbc hl,bc
		ld b,h
		ld c,l
		//ld bc,#0x1f40//блок на 8000 байт
		pop hl
		ldir
//----------------------------
				
		ld hl,(_gl_addr)//проверим адрес
		ld bc,#0x8000
		sbc hl,bc
		
		jr z,addrifl
		jp nxtl
addrifl:
		ld hl,#0xa000
		ld(_gl_addr),hl
		jp beg2l
nxtl:
		ld hl,#0x8000
		ld(_gl_addr),hl
		
		ld a,(_gl_page)
		ld b,#0x1
		sub b
		jr z, frst_chngl
		jp next_page_ifl
frst_chngl:
		ld a,#0x5
		ld (_gl_page),a
		jp begl
next_page_ifl:
		ld a,(_gl_page)
		ld b,#0x3
		sub b
		jr z, sec_chngl
		jp endl
sec_chngl:
		ld a,#0x7
		ld (_gl_page),a
		jp begl

		//call _CONVERT_SCREEN
endl:	ld bc,#0xbff7
		ld a,#0x71
		out (c),a
		pop ix
		ret
	__endasm;
}

void do_scrollup(u8 shift) __naked
{
		__asm
		push	ix
		ld	ix,#0
		add	ix,sp
		ld bc,#0x7ffd
		ld a,(_SCREENACTIVE)//ищем нужную страницу
		bit 1,a
		jr z,secpage 
frstpage:
		ld a,#0x1
		jp dopage
secpage:
		ld a,#0x3
dopage:
		ld (_gl_page),a
beg:		
		
		//page
		ld a,(_gl_page)
		xor #0x7f
		ld bc,#0xbff7
		ld (_MEMSLOT2),a
		out (c),a
beg2:		
//---------------------------		
//read 	addr
		ld c,#0x0
		ld b, 4 (ix)
		dec b
		ld hl,#0x28
		ld de,#0x28
		jr z,zer
mul:
		add hl,de
		djnz mul
zer:		
		ld de,(_gl_addr)
		ld b,h
		ld c,l
		
		add hl,de
		push hl
//-----------------------------		
// write addr
		ld de,(_gl_addr)

//---------------------------
//чтение и запись
		//pop bc
		ld hl,#0x1f40
		sbc hl,bc
		ld b,h
		ld c,l
		//ld bc,#0x1f40//блок на 8000 байт
		pop hl
		ldir
//----------------------------
				
		ld hl,(_gl_addr)//проверим адрес
		ld bc,#0x8000
		sbc hl,bc
		
		jr z,addrif
		jp nxt
addrif:
		ld hl,#0xa000
		ld(_gl_addr),hl
		jp beg2
nxt:
		ld hl,#0x8000
		ld(_gl_addr),hl
		
		ld a,(_gl_page)
		ld b,#0x1
		sub b
		jr z, frst_chng
		jp next_page_if
frst_chng:
		ld a,#0x5
		ld (_gl_page),a
		jp beg
next_page_if:
		ld a,(_gl_page)
		ld b,#0x3
		sub b
		jr z, sec_chng
		jp end
sec_chng:
		ld a,#0x7
		ld (_gl_page),a
		jp beg

end:	ld bc,#0xbff7
		ld a,#0x71
		out (c),a
		pop ix
		ret
	__endasm;
}

void setTileUpdateMap(u8 x,u8 y) __naked
{
	__asm
		push	ix
		ld	ix,#0
		add	ix,sp
		ld a,#0x1
		
		ld c,4 (ix)
		ld b,5 (ix)
		call (#0xe644)
		inc b
		call (#0xe644)
		inc b
		call (#0xe644)
		inc c
		call (#0xe644)
		inc c
		call (#0xe644)
		dec b
		call (#0xe644)
		dec b
		call (#0xe644)
		dec c
		call (#0xe644)
		inc b
		call (#0xe644)
		pop ix
		ret
	__endasm;
}
void main(void)
{
	u8 a,col,c,x,y,step,bb,xx,yy,x2,y2;
	i8 dx,dy,dx2,dy2;
	u16 addr,addr2,b;

	gl_addr=32768;
	

	
	select_image(IMG_BG);
	draw_tile(1,1,0);
	sprites_start();
	pal_select(PAL_BG);
	draw_image(0,0,IMG_BG);
	
	do_scrolldown_sector(2,10,15);
	do_scrolldown_sector(2,17,18);
	do_scrolldown_sector(2,26,30);
	
	swap_screen();
	draw_image(0,0,IMG_BG);

	
	

	step=0;
	x2=128;
	y2=24;
	x=64;
	y=80;
	dx=2;
	dy=4;
	dx2=-2;
	dy2=-4;
	

	
	while(1)
	{	
		
		
		
		x+=dx;
		y+=dy;
		x2+=dx2;
		y2+=dy2;
		if(x>=140)dx=-dx;
		if(x<2)dx=-dx;
		if(y>182)dy=-dy;
		if(y<2)dy=-dy;
		
		if(x2>=140)dx2=-dx2;
		if(x2<2)dx2=-dx2;
		if(y2>182)dy2=-dy2;
		if(y2<2)dy2=-dy2;
		set_sprite(0,x,y,0);
		set_sprite(1,x2,y2,0);

		if(step==0)//нужно для того, чтобы спрайты не портили скролирующийся фон под собой
		{
			xx=x>>2;
			yy=y>>3;
			setTileUpdateMap(xx,yy);
			xx=x2>>2;
			yy=y2>>3;
			setTileUpdateMap(xx,yy);

		}
		step++;
		if(step==2)step=0;

		//do_scrolldown_sector(4,10,15);
		//do_scrolldown_sector(4,17,18);
		//do_scrolldown_sector(4,26,30);
		do_scrolldown_looped(4);
			
		
		swap_screen();
	}
}
