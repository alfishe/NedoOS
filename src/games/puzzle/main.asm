        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

scrbase=0x4000
prarr_scrbase=0x8000
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrwidpix=scrwid*2
scrhgt=200

STACK=0x3ff0
tempsp=0x3f06 ;6 bytes for prspr
INTSTACK=0x3f00

nofocuskey=0xff

NPIECES=20*12
PIECESZ=8

SAVING=1;0

        org PROGSTART
begin
	jp GO ;patched by prspr
GO
        ld sp,STACK
        OS_HIDEFROMPARENT
        ld e,0+0x80 ;EGA
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode) +8=noturbo, +0x80=keep gfx pages
        ld de,emptypal
        OS_SETPAL ;включаем чёрную палитру, чтобы было незаметно переброску экрана
        ld e,0
        OS_CLS ;очистили текущий экран

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ld a,e
        ld (pgmain4000),a
        ld a,h
        ld (pgmain8000),a
        ld a,l
        ld (pgmainc000),a

	ld a,r
	ld (rndseed1),a
	OS_GETTIMER ;dehl=timer
	ld (rndseed2),hl

        ld de,path
        OS_CHDIR
        
	 if SAVING
	ld de,filename
	OS_OPENHANDLE
	;ld a,-1
	or a
	jr nz,noloadini
	push bc
	ld de,SAVEDATA
	ld hl,SAVEDATAsz
	OS_READHANDLE
	pop bc
	OS_CLOSEHANDLE
	jr loadiniq
noloadini
	xor a
        ld (level),a
        call genxy
loadiniq
	 else
        call genxy
	 endif

        OS_NEWPAGE ;заказали новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pggriddata0),a ;запомнили её номер
        OS_NEWPAGE ;заказали другую новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pggriddata1),a ;запомнили её номер

        OS_NEWPAGE ;заказали новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pgpicdata0),a ;запомнили её номер
        OS_NEWPAGE ;заказали другую новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pgpicdata1),a ;запомнили её номер

        OS_NEWPAGE ;заказали новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pgscrdata0),a ;запомнили её номер
        OS_NEWPAGE ;заказали другую новую страницу, чтобы грузить туда данные
        ld a,e
        ld (pgscrdata1),a ;запомнили её номер

        ld a,(pggriddata0)
        ld de,filenamegrid0 ;имя файла
        ld hl,0xc000 ;куда грузим
        call loadfile_in_ahl ;загрузили один экранный файл в одну страницу
        ld a,(pggriddata1)
        ld de,filenamegrid1 ;имя файла
        ld hl,0xc000 ;куда грузим
        call loadfile_in_ahl ;загрузили другой экранный файл в другую страницу

        ld a,(pgpicdata0)
        ld de,filenamepic0 ;имя файла
        ld hl,0xc000 ;куда грузим
        call loadfile_in_ahl ;загрузили один экранный файл в одну страницу
        ld a,(pgpicdata1)
        ld de,filenamepic1 ;имя файла
        ld hl,0xc000 ;куда грузим
        call loadfile_in_ahl ;загрузили другой экранный файл в другую страницу

;сейчас у нас включены страницы программы, как было

;pic (0x8000) & grid (0xc000) -> scr (0x4000)
	ld a,(pgpicdata0)
	SETPG8000
	ld a,(pggriddata0)
	SETPGC000
	ld a,(pgscrdata0)
	SETPG4000
	call addgridpg
	if 0
        ld hl,0x8000+8000 ;там в картинке палитра (по байту на цвет)
        ld de,pal
        ld b,16
copypal0
        ld a,(hl)
        inc hl
        ld (de),a
        inc de
        ld (de),a
        inc de
        djnz copypal0 ;скопировали палитру в pal (по 2 байта на цвет)
	endif
        
	ld a,(pgpicdata1)
	SETPG8000
	ld a,(pggriddata1)
	SETPGC000
	ld a,(pgscrdata1)
	SETPG4000
	call addgridpg

	ld ix,pieces ;x,y,pg,addr
	
	ld hl,0x4000-1-(8*40)
	push hl
	ld de,mask00-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	ld b,+(20-2)/2
piecelinetop0
	push bc
	ld de,mask10-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	ld de,mask20-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	pop bc
	djnz piecelinetop0
	ld de,mask30-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	pop hl
	ld bc,40*16
	add hl,bc

	 ld b,+(12-2)/2
piecelines0
	 push bc
	
	push hl
	ld de,mask01-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	ld b,+(20-2)/2
piecelineodd0
	push bc
	ld de,mask11-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	ld de,mask21-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	pop bc
	djnz piecelineodd0
	ld de,mask31-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	pop hl
	ld bc,40*16
	add hl,bc

	push hl
	ld de,mask02-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	ld b,+(20-2)/2
piecelineeven0
	push bc
	ld de,mask21-4;mask12-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	ld de,mask11-4;mask22-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	pop bc
	djnz piecelineeven0
	ld de,mask32-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	pop hl
	ld bc,40*16
	add hl,bc
	
	 pop bc
	 djnz piecelines0

	ld de,mask03-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	ld b,+(20-2)/2
piecelinebottom0
	push bc
	ld de,mask13-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	ld de,mask23-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	pop bc
	djnz piecelinebottom0
	ld de,mask33-4
	call reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5

	call swapimer

;теперь надо вывести загруженные данные на экран
        ld a,(pgscrdata0)
        SETPGC000 ;включили страницу с данными в c000
        ld a,(user_scr0_low) ;ok
        SETPG4000 ;включили пол-экрана в 4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран

        ld a,(pgscrdata1)
        SETPGC000 ;включили страницу с данными в c000
        ld a,(user_scr0_high) ;ok
        SETPG4000 ;включили другие пол-экрана в 4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран

        call setpgsscr40008000_current ;включили страницы экрана
	
        ld de,palsneg;pal;sprpal
        OS_SETPAL ;включили палитру спрайтов;картинки
        
        call setpgsmain40008000 ;включили страницу программы в 4000, как было
        call setpgmainc000 ;включили страницу программы в c000, как было

        ;call changescrpg ;с этого момента (точнее, с прерывания) можем видеть, что нарисовали

	if 0
        ld a,(timer)
        ld (uvoldtimer),a
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        
;главный цикл
mainloop

	call prlevel

        ld a,(user_scr0_low) ;ok
        SETPGC000 ;включили страницу с данными в c000
        ld a,(user_scr1_low) ;ok
        SETPG4000 ;включили пол-экрана в 4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран

        ld a,(user_scr0_high) ;ok
        SETPGC000 ;включили страницу с данными в c000
        ld a,(user_scr1_high) ;ok
        SETPG4000 ;включили другие пол-экрана в 4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран

	;ld e,0
	;OS_CLS
	;ld e,1
	;OS_SETSCREEN
	ld a,1
	ld (curscrnum_int),a
	halt;YIELD

;вывод фона или восстановление фона под спрайтами
;... рекомендую взять из sprexamp!
restorer_cursprlist=$+1
        ld hl,sprlist1
        ld de,sprlist1^sprlist2
        ld a,h
        xor d
        ld h,a
        ld a,l
        xor e
        ld l,a
        ld (restorer_cursprlist),hl
       push hl ;curlist

;вывод спрайтов
;...
        call setpgsscr40008000 ;включили страницы экрана
	ld hl,0x4000
	ld de,0x4001
	ld bc,0x7fff
	ld (hl),l;0
	ldir

        ;ld hl,sprlist1
       pop hl
        ld (cursprlistaddr),hl

	call drawpieces

	;ld e,0
	;OS_SETSCREEN
	xor a
	ld (curscrnum_int),a

	ld de,scrwid/4 + (256*scrhgt) ;d=hgt,e=wid (/8)
	ld hl,0x4000 ;hl=scr
	call copyimgega_curtodefault ;копируем картинку на экран-буфер

	;call endkeepspr
	;jr $

;включены страницы экрана

key=$+1
        ld a,0

        jr mouseloop_go
mouseloop
;1. всё выводим
;2. ждём событие
;[3. всё стираем]
;4. обрабатываем событие (без перерисовки)
;5. всё стираем

	if 1
        ld a,(clickstate)
        or a
        jr z,mouseloop_nomove
        call ahl_coords
        cp 200-32-8
        jr c,mouseloop_nomove
         ld a,1
         ld (invalidatetime),a
        
mouseloop_nomove
	endif

        ld a,(key)
        cp nofocuskey
        call nz,prlevelifneeded

mouseloop_go
;сейчас всё выведено, кроме стрелки
        ld a,(key)
        cp nofocuskey
        jr z,mouseloop_noprarr

        ld a,(clickstate)
        or a
        jr z,mouseloop_arr
	ld ix,(curpiece)
	ld a,hx
	or a
	jr z,mouseloop_noprarr
	call setpgsscr40008000
        call ahl_coords
	srl h
	rr l
	sub 8
	ld (ix+1),a ;y активной части кусочка
	ld a,l ;arrx2
	sub 8/2
	ld (ix+0),a ;x2 активной части кусочка
	call drawpiece
	jr mouseloop_noprarr
mouseloop_arr
	call setpgsscr8000c000
        call ahl_coords
        call shapes_memorizearr
        call ahl_coords
        call shapes_prarr8c
mouseloop_noprarr
mainloop_nothing0
        call updatetime
;в это время стрелка видна
        YIELD ;halt
        call control
        jr nz,mainloop_something

         ld a,(invalidatetime)
         or a
        jr z,mainloop_nothing0

mainloop_something
;что-то изменилось
        ld a,(key)
        cp nofocuskey
        jr z,mouseloop_norearr
        ;ld a,(key);(curkey)
        cp key_esc
	jp z,quit
	cp key_enter
	jp z,shuffle
	
        ld a,(clickstate)
        or a
        jr z,mouseloop_rearr
	ld ix,(curpiece)
	ld a,hx
	or a
	jr z,mouseloop_norearr
	call setpgsscr40008000
	ld a,(ix+0) ;x2 активной части кусочка
	add a,8/2 ;>=0
	sub (8/2)+(8/2)
	jr nc,$+3
	xor a
	cp scrwid-(5*4)
	jr c,$+4
	ld a,scrwid-(5*4)
	srl a
	srl a
	ld e,a
;e=x/8 >=0
	ld a,(ix+1) ;y активной части кусочка
	add a,8 ;>=0
	sub 8+8
	jr nc,$+3
	xor a
	cp scrhgt-32
	jr c,$+4
	ld a,scrhgt-32
	ld c,a
;c=y >=0
        ld b,0
        ld l,c
        ld h,b;0
        add hl,hl ;y*2
        add hl,hl ;y*4
        add hl,bc ;y*5
        add hl,hl ;y*10
        add hl,hl ;y*20
        add hl,hl ;y*40
        ld d,b;0
        add hl,de ;+x/8
        ld bc,0x4000
        add hl,bc
	;ld hl,0x4000 ;hl=scr
	;ld de,scrwid/4 + (256*scrhgt) ;d=hgt,e=wid (/8)
	ld de,5 + (256*32) ;d=hgt,e=wid (/8)        
        call copyimgega_defaulttocur

	jr mouseloop_norearr
mouseloop_rearr
	call setpgsscr8000c000
        ld a,(oldarry)
        ld hl,(oldarrx)
        call shapes_rearr
mouseloop_norearr
;сейчас всё выведено, кроме стрелки

        ld a,(mousebuttons)
	and 1
top_oldmousebuttons=$+1
	ld c,1
	ld (top_oldmousebuttons),a
	xor c
	rra
	jp nc,mouseloop ;не нажали и не отжали
	
	ld a,c ;old
        rra
	jp nc,mouse_unfire ;было нажато (теперь отжато)
	
;mouse_fire
	call findpiece ;out: CY=not found, ix=curpiece
	jp c,mouseloop ;findpieceq
	ld a,1
	ld (clickstate),a
	
;вывести все кусочки, кроме текущего:
	
	jp mouse_q ;mouseloop

mouse_unfire
	xor a
	ld (clickstate),a
	ld ix,(curpiece)
	ld hl,0
	ld (curpiece),hl
	ld a,hx
	or a
	jr z,mouse_unfire_nopiece
	ld (ix+7),1 ;moved
;округлим координаты текущего кусочка
	ld a,(ix+0) ;x2
	add a,4/2
	and 0xfc
	ld (ix+0),a
	ld a,(ix+1) ;y
	add a,4
	and 0xf8
	ld (ix+1),a
mouse_unfire_nopiece
;проверка x,y = ideal x,y для всех кусочков
	ld ix,pieces
	ld b,NPIECES
checkwin0
	ld a,(ix+6) ;idealy
	cp (ix+1) ;y
	jr nz,checkwin_no
	ld a,(ix+5) ;idealx2
	cp (ix+0) ;x2
	jr nz,checkwin_no
	ld de,PIECESZ
	add ix,de
	djnz checkwin0
;победа!
	call showwin
	YIELDGETKEYLOOP ;ждём кнопку
	call prlevel;ifneeded
	YIELDGETKEYLOOP ;ждём кнопку
	jp quit
checkwin_no

mouse_q
        call setpgsmain40008000 ;включили страницы программы в 4000,8000, как было
        jp mainloop
shuffle
;ставим случайные координаты всем кусочкам, которые ещё не двигали
	call genxy
	ld b,0
shuffle0
	push bc
	call swappieces
	pop bc
	djnz shuffle0
        jp mainloop
	
quit        
	call unreservepages
	
        ;YIELDGETKEYLOOP ;ждём кнопку
	call swapimer
	 if SAVING
	ld de,filename
	OS_CREATEHANDLE
	push bc
	ld de,SAVEDATA
	ld hl,SAVEDATAsz
	OS_WRITEHANDLE
	pop bc
	OS_CLOSEHANDLE
	 endif
        QUIT

drawpieces
;вывести все кусочки, кроме текущего
	ld ix,pieces
	ld b,NPIECES
drawpieces0
	 push bc
	push ix
	pop de
	ld hl,(curpiece)
	or a
	sbc hl,de
	;jr z,drawpieces0_skip
	 push ix
	call nz,drawpiece
	 pop ix
drawpieces0_skip
	 ld bc,PIECESZ
	 add ix,bc
	 pop bc
	 djnz drawpieces0
	ret

drawpiece
	ld l,(ix+2) ;pg
	ld h,tpg/256
	ld a,(hl)
	SETPGC000
	ld a,(ix+0) ;x
	add a,sprmaxwid-1-(8/2) ;8=размер левого поля кусочка пазла
	ld e,a
	ld a,(ix+1) ;y
	add a,-8 ;8=размер верхнего поля кусочка пазла
	ld c,a
	ld l,(ix+3)
	ld h,(ix+4)
	push hl
	pop iy
	;ld iy,tmp
	;ld e,60 ;e=x = -(sprmaxwid-1)..159 (кодируется как x+(sprmaxwid-1))
	;ld c,60 ;c=y = -(sprmaxhgt-1)..199 (кодируется как есть)
        ;call keepspr
	jp prspr

findpiece
        call ahl_coords
	srl h
	rr l ;l=arrx2
	ld h,a ;h=arry
;ищем кусочек под стрелкой (последний подходящий в списке)
;координаты кусочка указывают на левый верхний угол активной части
;стрелка должна быть +0..15 к ним (по x +0..7)
	ld ix,pieces + (NPIECES*PIECESZ)
	ld b,NPIECES
findpiece0
	ld de,-PIECESZ
	add ix,de
	ld a,h ;arry
	sub (ix+1) ;y
	cp 16
	jr nc,findpiece_no
	ld a,l ;arrx2
	sub (ix+0) ;x2
	cp 8
	jr c,findpiece_ok
findpiece_no
	djnz findpiece0
	scf
	ld ix,0
	ret;jr findpieceq
findpiece_ok
	or a
	ld (curpiece),ix
	ret

ahl_coords
        ld a,(arry)
        ld hl,(arrx)
        ret

	if 0
clspg4000
	ld hl,0x4000
	ld d,h
	ld e,l
	inc e
	ld bc,0x3fff
	ld (hl),l;0
	ldir
	ret
	endif

reservepiece ;hl=scr, de=mask-4, out: hl+=2 ;ix+=5
	 push hl
	 push ix
	push hl ;scr
	ex de,hl ;hl=mask-4
	call getmask
	ld a,(pgscrdata0)
	SETPG4000
	ld a,(pgscrdata1)
	SETPG8000
	pop hl ;scr
	ld de,tmp-2
	call maskpiece
	ld bc,mask10-mask00 ;sprsize
	push bc
	;jr $
	call reserve_mem
	pop bc
	 pop ix
	 ld (ix+2),a ;pg
	 push bc
	 ld c,a
	 ld b,tpg/256
	 ld a,(bc)
	SETPGC000
	 pop bc
	push de
	ld hl,tmp-4
	ldir
	pop de
	 pop hl
	 inc de
	 inc de
	 inc de
	 inc de ;указатели на спрайты на +4
	 ld (ix+3),e
	 ld (ix+4),d
	 ld c,PIECESZ
	 add ix,bc
	 inc hl
	 inc hl
	ret

getmask
	ld a,(pgmain4000)
	SETPG4000
	ld de,tmp-4
	ld bc,mask10-mask00
	ldir
	ret

maskpiece
;0x4000,0x8000 = scrdata
;hl=0x4000+
;de=спрайт маски (без заголовка): 0,mask, в конце стоблца 2-байтный адрес
;туда же кладём результат наложения: and(~mask),or(scrdata&mask)
	ld lx,32/8
maskpiececolumns0
	call maskpiececolumn
	ld bc,0x4000
	add hl,bc
	call maskpiececolumn
	ld bc,0x2000-0x4000
	add hl,bc
	call maskpiececolumn
	ld bc,0x4000
	add hl,bc
	call maskpiececolumn
	ld bc,-0x2000-0x4000+1
	add hl,bc
	dec lx
	jr nz,maskpiececolumns0
	ret

maskpiececolumn
	push hl
	ld bc,40
	ld hx,32
maskpiece1
	inc de
	ld a,(de) ;mask
	dec de
	cpl
	ld (de),a
	cpl
	inc de
	and (hl) ;scrdata
	ld (de),a	
	inc de
	add hl,bc
	dec hx
	jr nz,maskpiece1
	inc de
	inc de
	pop hl
	ret

addgridpg
;pic (0x8000) & grid (0xc000) -> scr (0x4000)
	ld hl,0x8000
	ld bc,0x4000
addgrid0
	ld a,(hl)
	set 6,h
	and (hl)
	res 7,h
	ld (hl),a
	res 6,h
	set 7,h
	cpi
	jp pe,addgrid0
	ret
        
keepspr
cursprlistaddr=$+1
        ld hl,0
        ld (hl),e ;x
        inc hl
        ld (hl),c ;y
        inc hl
        ld a,(iy-1)
        ld (hl),a ;hgt
        inc hl
        ld (cursprlistaddr),hl
        ret
        
endkeepspr
        ld hl,(cursprlistaddr)
        ld (hl),200
        ret

showwin
        ld a,(pgpicdata0)
        SETPGC000 ;включили страницу с данными в c000
        ld a,(user_scr0_low) ;ok
        SETPG4000 ;включили пол-экрана в 4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран

        ld a,(pgpicdata1)
        SETPGC000 ;включили страницу с данными в c000
        ld a,(user_scr0_high) ;ok
        SETPG4000 ;включили другие пол-экрана в 4000
        ld hl,0xc000
        ld de,0x4000
        ld bc,0x4000
        ldir ;перебросили на экран
	ret

sprlist1
        ds 3*128,200
sprlist2
        ds 3*128,200

pal
        ds 32 ;тут будет палитра картинки
emptypal
        ds 32,0xff ;палитра, где все цвета чёрные
	include "pal.ast"

loadfile_in_ahl
;de=имя файла
;hl=куда грузим (0xc000)
;a=в какой странице
        SETPGC000 ;включили страницу A в 0xc000
        push hl ;куда грузим
        OS_OPENHANDLE
        pop de ;куда грузим
        push bc ;b=handle
        ld hl,0x4000 ;столько грузим (если столько есть в файле)
        OS_READHANDLE
        pop bc ;b=handle
        OS_CLOSEHANDLE
	jp setpgmainc000 ;включили страницу программы в c000, как было

primgega_onescreen
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
primgega0
        push bc
        ld hx,b
        push hl
        ld bc,40
primgegacolumn0
        ld a,(de)
        inc de
        ld (hl),a
        add hl,bc
        dec hx
        jr nz,primgegacolumn0
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,primgegacolumn0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
primgegacolumn0q
        pop bc
        dec c
        jr nz,primgega0
        ret


copyimgega_curtodefault
;d=hgt,e=wid (/8)
;hl=scr
        call getuser_scr_low_cur
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_low
        SETPGC000 ;set "to" page in c000
        call copyimgegalayer
        call getuser_scr_high_cur
        SETPG16K ;set "from" page in 4000
        call getuser_scr_high
copyimgegaq
        SETPGC000 ;set "to" page in c000
        call copyimgegalayer
        call setpgmainc000
        jp setpgsmain40008000

copyimgega_defaulttocur
;d=hgt,e=wid (/8)
;hl=scr
        call getuser_scr_low
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_low_cur
        SETPGC000 ;set "to" page in c000
        call copyimgegalayer
        call getuser_scr_high
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_high_cur
        jr copyimgegaq ;set "to" page in c000, copy

	if 0
copyimgega_defaulttoshadow
;d=hgt,e=wid (/8)
;hl=scr
        ld a,(pgscrdata0)
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_low
        SETPGC000 ;set "to" page in c000
        call copyimgegalayer
        ld a,(pgscrdata1)
        SETPG4000 ;set "from" page in 4000
        call getuser_scr_high
        jr copyimgegaq ;set "to" page in c000, copy
        endif

copyimgegalayer
        push hl
        ld hx,e ;wid/8
copyimgega0
        push de
        push hl
        ld b,d ;hgt
        ld de,40-0x8000
copyimgegacolumn0
        ld a,(hl)
        set 5,h
        ld c,(hl)
         set 7,h
        ld (hl),c
        res 5,h
        ld (hl),a
        add hl,de
        djnz copyimgegacolumn0
        pop hl
        pop de
        inc hl
        dec hx
        jr nz,copyimgega0
        pop hl
        ret 
	
genxy
;случайные координаты (если не двигали кусочек)
	ld ix,pieces ;x,y,pg,addr
	ld b,NPIECES
genxy0
	ld a,(ix+7)
	or a
	jr nz,genxy_moved
	 ld c,+(320-16-32)/4
	 call rnd
	 add a,a
	 add a,16/2
	;ld a,(ix+5) ;ideal x2
	 ld (ix+0),a ;x2
	 ld c,+(192-16-32)/4
	 call rnd
	 add a,a
	 add a,a
	 add a,16
	;ld a,(ix+6) ;ideal y
	 ld (ix+1),a ;y
genxy_moved
	ld de,PIECESZ
	add ix,de
	djnz genxy0
	ret
	
swappieces
;случайный обмен порядка (если не двигали кусочек)
	ld c,NPIECES
	call rnd
	call getpiece_a
	ld bc,7
	add hl,bc
	bit 0,(hl)
	ret nz
	sbc hl,bc
	ex de,hl
	ld c,NPIECES
	call rnd
	call getpiece_a
	ld bc,7
	add hl,bc
	bit 0,(hl)
	ret nz
	sbc hl,bc
	ld b,PIECESZ
swappieces0
	ld c,(hl)
	ld a,(de)
	ld (hl),a
	ld a,c
	ld (de),a
	inc hl
	inc de
	djnz swappieces0
	ret
getpiece_a
	ld c,a
	ld b,0
	ld hl,pieces
	dup PIECESZ
	add hl,bc
	edup
	ret

rnd
;0..c-1
        ;ld a,r
        push de
        push hl
        call func_rnd
        pop hl
        pop de
rnd0
        sub c
        jr nc,rnd0
        add a,c
        ret

func_rnd
;Patrik Rak
rndseed1=$+1
        ld  hl,0xA280   ; xz -> yw
rndseed2=$+1
        ld  de,0xC0DE   ; yw -> zt
        ld  (rndseed1),de  ; x = y, z = w
        ld  a,e         ; w = w ^ ( w << 3 )
        add a,a
        add a,a
        add a,a
        xor e
        ld  e,a
        ld  a,h         ; t = x ^ (x << 1)
        add a,a
        xor h
        ld  d,a
        rra             ; t = t ^ (t >> 1) ^ w
        xor d
        xor e
        ld  h,l         ; y = z
        ld  l,a         ; w = t
        ld  (rndseed2),hl
        ;ex de,hl
        ;ld hl,0
        ;res 7,c ;int
        ret

pgscrdata0
        db 0
pgscrdata1
        db 0
pgpicdata0
        db 0
pgpicdata1
        db 0
pggriddata0
        db 0
pggriddata1
        db 0

clickstate
	db 0

curpiece
	dw 0

curkey
        db 0
joystate
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8) 
        db 0

SAVEDATA
level
        db 0
;curx
;	db 0
;cury
;	db 0

cur_h
        db 0
cur_m
        db 0
cur_s
        db 0
cur_f
        db 0

tlevel
ttime
        ;db "TIME "
	db "00:00:00"
ttimeh1=$-8
ttimeh2=$-7
ttimem1=$-5
ttimem2=$-4
ttimes1=$-2
ttimes2=$-1
;nextlevelon=$ ;этот флаг надо сохранять
        db 0

;у нас 20x12 = 240 кусочков
pieces
_y=0
	dup 12
_x=0
	dup 20
	db 0,0 ;x,y
	db 0 ;pg (виртуальная в tpg)
	dw 0 ;addr
	db _x,_y ;ideal x,y
	db 0 ;0=not moved
_x=_x+8
	edup
_y=_y+16
	edup

SAVEDATAsz=$-SAVEDATA

path
        db "puzzle",0
filenamepic0
        db "0pic0.bmpx",0
filenamepic1
        db "1pic0.bmpx",0
filenamegrid0
        db "0grid.bmpx",0
filenamegrid1
        db "1grid.bmpx",0

filename
	db "puzzle.ini",0

	include "mem.asm"
	include "dynmem.asm"
	include "int.asm"

	include "prspr.asm"

div4signedup
        or a
        jp m,$+5
        add a,3
        sra a
        sra a
        ret

prtext
;bc=координаты
;hl=text
        ld a,(hl)
        or a
        ret z
        call prcharxy
        inc hl
        inc c
        jr prtext

prnum
        ld bc,1000
        call prdig
        ld bc,100
        call prdig
        ld bc,10
        call prdig
        ld bc,1
prdig
        ld a,'0'-1
prdig0
        inc a
        or a
        sbc hl,bc
        jr nc,prdig0
        add hl,bc
        ;push hl
        ;call prchar
        ;pop hl
        ;ret
prchar
;a=code
;de=screen
        push de
        push hl
        call prcharin
        pop hl
        pop de
        inc e
        ret
        
calcscraddr
;bc=yx
;можно портить bc
        ex de,hl
        ld a,c ;x
        ld l,b ;y
        ld h,0
        ld b,h
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc ;*5
         add hl,hl
         add hl,hl
         add hl,hl ;*40
         add hl,hl
         add hl,hl
         add hl,hl
        add a,l
        ld l,a
        ld a,h
        adc a,0x80
        ld h,a
        ex de,hl
        ret

prcharxy
;a=code
;bc=yx
        push de
        push hl
        push bc
        push af
        call calcscraddr
        pop af
        call prcharin
        pop bc
        pop hl
        pop de
        ret
        
prcharin
        sub 32
        ld l,a
        ld h,0
         add hl,hl
         add hl,hl
         add hl,hl
         add hl,hl
         add hl,hl
        ;ld bc,font-(32*32)
        ;add hl,bc
        ld a,h
        add a,font/256
        ld h,a
prcharin_go
        ex de,hl
        
        ld bc,40
        push hl
        push hl
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        set 6,h
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        set 5,h
        push hl
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup
        pop hl
        set 6,h
        ;ld d,font/256
        dup 8
        ld a,(de) ;font
        ld (hl),a ;scr
        inc de
        add hl,bc
        edup        
        ret

        macro SHAPESPROC name
name
        endm

	include "prarrow.asm"

	include "control.asm"

prlevelifneeded
        xor a
invalidatetime=$+1
        cp 0
        ret z
prlevel
	call setpgsscr8000c000
        ;ld a,(level)
        ;inc a
        ;ld hl,tleveldig1
        ;call dectotxt12
        ;ld (tleveldig2),a
        ;ld a,b
        ;ld (tleveldig1),a
        ld a,(cur_h)
        ld hl,ttimeh1
        call dectotxt12
        ld a,(cur_m)
        ld hl,ttimem1
        call dectotxt12
        ld a,(cur_s)
        ld hl,ttimes1
        call dectotxt12
        
         xor a
         ld (invalidatetime),a
        
        ld bc,24*256+20-4
        ld hl,tlevel
        jp prtext

dectotxt12
        ld b,'0'-1
        inc b
        sub 10
        jr nc,$-3
        add a,'0'+10
         ld (hl),b
         inc hl
         ld (hl),a
        ret

updatetime
        OS_GETTIMER ;dehl=timer
        ld de,(oldupdtimer)
        ld (oldupdtimer),hl
        or a
        sbc hl,de ;hl=frames
        ret z
        ld b,h
        ld c,l
updatetime0
        call inctime
        ;dec bc
        ;ld a,b
        ;or c
        ;jr nz,updatetime0
        cpi
        jp pe,updatetime0
        ret
inctime
        ld hl,cur_f
        inc (hl)
        ld a,(hl)
        sub 50
        ret c
        ld (hl),a
         ld a,1
         ld (invalidatetime),a
        ld hl,cur_s
        inc (hl)
        ld a,(hl)
        sub 60
        ret c
        ld (hl),a
        ld hl,cur_m
        inc (hl)
        ld a,(hl)
        sub 60
        ret c
        ld (hl),a
        ld hl,cur_h
        inc (hl)
        ret

oldupdtimer
        dw 0

	align 256
font
	display "font=",font
        incbin "fontgfx"
	align 256
tpg
	ds 256

	ds 4
tmp

	ds 0x3f00-(mask10-mask00)-$

	ds 0x4000-$
	include "spr.ast"

end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "puzzle.com",begin,end-begin
	
	LABELSLIST "../../../us/user.l",1
