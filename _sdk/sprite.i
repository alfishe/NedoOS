;todo возможность сдвигать по вертикали весь активный экран (или лучше его независимые фрагменты, с ограничением на наложение спрайтов на границе)
;испортится цикл тайл->scrbuf: 24t loop, fit for contention
;	ld a,(de)
;	inc de
;	ld (bc),a
;	inc b
;или линейный экранный буфер? (на нём удобнее линии и полигоны) 0x6000: startup, ISR, music, data(?), scrbuf, gfx engine, logic engine, gfx/logic/data (pageable) + INT vector
;todo отрисовка элементов панельки и диалогов
;todo возможность выводить спрайты поверх панельки??? фреймово прямо на экране, как стрелка в ЧВ?
;todo клипировать спрайты внутри активного экрана?? только с переброской?? (128К экран вряд ли будет эффективным - мало места под графику в нижней памяти)

;можно на ATM рисовать в экране, а на 48K в экранном буфере
;на АТМ сдвиг экрана можно делать сдвигом (если запоминать картинку под спрайтами), а на 48К перерисовкой (т.к. спрайты нельзя снять)
;или везде перерисовка?

;PROC prspr(BYTE x, BYTE y, PBYTE data);
;wid8xhgt sprite (wid8, hgt, (antimask, antipixels, ...))
;клипирования нет!
prspr
prspr.A.=$+1 ;x
prspr.B.=$+2 ;y
	ld bc,0
	ld a,b
	rra
	rra
	rra
	xor b
	and 0xf8
	xor b
	and 0x1f
	add a,scrbuf/256
	ld d,a
	ld a,c
	rlca
	rlca
	rlca
	xor b
	and 0xc7
	xor b
	rlca
	rlca
	ld e,a
;de=screen addr
	ld a,c
	and 7
	;a=shift right 0..7
	exx
prspr.C.=$+1 ;data
	ld hl,0
	ld c,(hl) ;wid8
	inc hl
	ld b,(hl) ;hgt
	inc hl
	dec c
	jp z,prspr8.
	dec c
	jp z,prspr16.
	dec c
	jp z,prspr24.
	dec c
	jp z,prspr32.
	ret

;8xhgt sprite (antimask, antipixels)
;hgt=16:
;x=0:  5411 =12.1/byteshift
;x=1:  5043
;x=2:  4675
;x=3:  4307
;x=4:  3939
;x=5:  3571
;x=6:  3203 =50.0/byteshift
;x=7:  2835 =44.3/byte (no shift) (159 before loop)
prspr8.
	;a=shift right 0..7
	add a,a
	add a,a
	ld (prspr8jr.),a
         exx
	 ld a,e
	 and 0x1f
	 cp 0x1f
	 ret nc
         exx
;b = counter
;hl = data (2 accesses)
;hl' = pixels
;de' = screen (4 accesses)
;ac' = mask
prspr8line.
	ld a,(hl) ;mask1
	inc hl
	exx
	ld c,a ;mask1
	exx
	ld a,(hl) ;pixels1
	inc hl
	exx
	ld l,a ;pixels1

	xor a
	ld h,a
prspr8jr.=$+1 ;shift mask
	jr $ ;+0 = shift left 7 (right 1), +28 = shift left 0 (right 8)
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla
	add hl,hl
	sla c
	rla

	ex de,hl
	or (hl) ;scr0
	ex de,hl
	xor h ;pixels0
	ld (de),a ;scr0
	inc e
	ld a,(de) ;scr1
	or c ;mask1
	xor l ;pixels1
	ld (de),a ;scr1
	dec e
	inc d
	ld a,d
	and 7
	jr z,prspr8down.
	exx
	djnz prspr8line.
	ret
prspr8down.
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	exx
	djnz prspr8line.
	ret

;16xhgt sprite (antimask, antipixels)
;hgt=16:
;x=0:  7932 =11.8/byteshift
;x=1:  7452
;x=2:  6972
;x=3:  6492
;x=4:  6012
;x=5:  5532
;x=6:  5052 =52.6/byteshift
;x=7:  4572 =47.6/byte (no shift)
prspr16.
	;a=shift right 0..7
	add a,a
	ld (prspr16jr1.),a
	ld (prspr16jr2.),a
         exx
	 ld a,e
	 and 0x1f
	 cp 0x1e
	 ret nc
         exx
;b = counter
;ade = pixels
;hl = data (4 accesses)
;de' = screen (6 accesses)
;chl' = mask, masked
prspr16line.
	ld a,(hl) ;mask1
	inc hl
	exx
	ld h,a ;mask1
	exx
	ld d,(hl) ;pixels1
	inc hl
	ld a,(hl) ;mask2
	inc hl
	exx
	ld l,a ;mask2

	xor a
prspr16jr1.=$+1 ;shift mask
	jr $ ;+0 = shift left 7 (right 1), +14 = shift left 0 (right 8)
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla

	ex de,hl
	or (hl) ;scr0
	ex de,hl
	ld c,a ;masked0
	inc e
	inc e
	ld a,(de) ;scr2
	or l ;mask2
	ex af,af' ;keep masked2
	exx
	ld e,(hl) ;pixels2
	inc hl

	ex de,hl
	xor a
prspr16jr2.=$+1 ;shift pixels
	jr $ ;+0 = shift left 7 (right 1), +14 = shift left 0 (right 8)
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	add hl,hl
	rla
	ex de,hl

	ex af,af' ;masked2, keep pixels0
	xor e ;pixels2
	exx
	ld (de),a ;scr2
	dec e
	ld a,(de) ;scr1
	or h ;mask1
	exx
	xor d ;pixels1
	exx
	ld (de),a ;scr1
	dec e
	ex af,af' ;pixels0
	xor c ;masked0
	ld (de),a ;scr0
	inc d
	ld a,d
	and 7
	jr z,prspr16down.
	exx
	djnz prspr16line.
	ret
prspr16down.
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	exx
	djnz prspr16line.
	ret

;PROC prspr24(BYTE x, BYTE y, PBYTE data);
;24xhgt sprite (antimask, antipixels)
;hgt=16:
;x=0: 10951 =12.2/byteshift
;x=1: 10210
;x=2:  9474
;x=3:  8738
;x=4:  8002
;x=5:  7266
;x=6:  6530 =51.0/byteshift
;x=7:  5794 =45.3/byte (no shift)
prspr24.
	;a=shift right 0..7
	add a,a
	add a,a
	ld (prspr24jr1.),a
	ld (prspr24jr2.),a
         exx
	 ld a,e
	 and 0x1f
	 cp 0x1d
	 ret nc
         exx
;b = counter
;hl = data (6 accesses)
;acde = pixels
;de' = screen (8 accesses)
;bchl' = mask, masked
prspr24line.
	ld a,(hl) ;mask1
	inc hl
	exx
	ld c,a ;mask1
	exx
	ld c,(hl) ;pixels1
	inc hl
	ld a,(hl) ;mask2
	inc hl
	exx
	ld h,a ;mask2
	exx
	ld d,(hl) ;pixels2
	inc hl
	ld a,(hl) ;mask3
	inc hl
	exx
	ld l,a ;mask3

	xor a
prspr24jr1.=$+1 ;shift mask
	jr $ ;+0 = shift left 7 (right 1), +28 = shift left 0 (right 8)
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla

	ex de,hl
	or (hl) ;scr0
	ex de,hl
	ld b,a ;masked0
	inc e
	inc e
	inc e
	ld a,(de) ;scr3
	or l ;mask3
	ex af,af' ;keep masked3
	exx
	ld e,(hl) ;pixels3
	inc hl

	ex de,hl
	xor a
prspr24jr2.=$+1 ;shift pixels
	jr $ ;+0 = shift left 7 (right 1), +28 = shift left 0 (right 8)
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	add hl,hl
	rl c
	rla
	ex de,hl

	ex af,af' ;masked3, keep pixels0
	xor e ;pixels3
	exx
	ld (de),a ;scr3
	dec e
	ld a,(de) ;scr2
	or h ;mask2
	exx
	xor d ;pixels2
	exx
	ld (de),a ;scr2
	dec e
	ld a,(de) ;scr1
	or c ;mask1
	exx
	xor c ;pixels1
	exx
	ld (de),a ;scr1
	dec e
	ex af,af' ;pixels0
	xor b ;masked0
	ld (de),a ;scr0

	inc d
	ld a,d
	and 7
	jr z,prspr24down.
	exx
	djnz prspr24line.
	ret
prspr24down.
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	exx
	dec b
	jp nz,prspr24line.
	ret

;PROC prspr32(BYTE x, BYTE y, PBYTE data);
;32xhgt sprite (antimask, antipixels)
;hgt=16:
;x=0: 14101 =12.6/byteshift
;x=1: 13109
;x=2: 12117
;x=3: 11125
;x=4: 10133
;x=5:  9141
;x=6:  8149 =50.9/byteshift
;x=7:  7157 =44.7/byte (no shift)
prspr32.
	;a=shift right 0..7
	ld c,a
	add a,a
	add a,c
	add a,a
	ld (prspr32jr1.),a
	ld (prspr32jr2.),a
         exx
	 ld a,e
	 and 0x1f
	 cp 0x1c
	 ret nc
         exx
	ld hx,b
;hx = counter
;hl = data (6 accesses)
;abcde = pixels
;de' = screen (8 accesses)
;abchl'/lbcha' = mask, masked
prspr32line.
	ld a,(hl) ;mask1
	inc hl
	exx
	ld b,a ;mask1
	exx
	ld b,(hl) ;pixels1
	inc hl
	ld a,(hl) ;mask2
	inc hl
	exx
	ld c,a ;mask2
	exx
	ld c,(hl) ;pixels2
	inc hl
	ld a,(hl) ;mask3
	inc hl
	exx
	ld h,a ;mask3
	exx
	ld d,(hl) ;pixels3
	inc hl
	ld a,(hl) ;mask4
	inc hl
	exx
	ld l,a ;mask4

	xor a
prspr32jr1.=$+1 ;shift pixels
	jr $ ;+0 = shift left 7 (right 1), +7*6 = shift left 0 (right 8)
;max 217 (43.4/byte)
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla

	ex de,hl
	or (hl) ;scr0
	ex de,hl
	ex af,af' ;masked0
	ld a,e
	add a,4
	ld e,a
	ld a,(de) ;scr4
	or l ;mask3
	ex af,af' ;masked0, keep masked4
	ld l,a ;masked0
	exx
	ld e,(hl) ;pixels4
	inc hl

	ex de,hl
	xor a
prspr32jr2.=$+1 ;shift pixels
	jr $ ;+0 = shift left 7 (right 1), +7*6 = shift left 0 (right 8)
;max 217 (43.4/byte)
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	add hl,hl
	rl c
	rl b
	rla
	ex de,hl

	ex af,af' ;masked4, keep pixels0
	xor e ;pixels4
	exx
	ld (de),a ;scr3
	dec e
	ld a,(de) ;scr3
	or h ;mask2
	exx
	xor d ;pixels3
	exx
	ld (de),a ;scr3
	dec e
	ld a,(de) ;scr2
	or c ;mask2
	exx
	xor c ;pixels2
	exx
	ld (de),a ;scr2
	dec e
	ld a,(de) ;scr1
	or b ;mask1
	exx
	xor b ;pixels1
	exx
	ld (de),a ;scr1
	dec e
	ex af,af' ;pixels0
	xor l ;masked0
	ld (de),a ;scr0

	inc d
	ld a,d
	and 7
	jr z,prspr32down.
	exx
	dec hx
	jp nz,prspr32line.
	ret
prspr32down.
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	exx
	dec hx
	jp nz,prspr32line.
	ret

;восстанавливаем фон из карты тайлов текущего экрана (там только адреса тайлов)
;для этого надо знать, какие тайлы изменились - проще всего по координатам спрайтов
;(проверка старых/новых адресов тайлов 8x8 слишком медленная для всего экрана)
;PROC respr(BYTE x, BYTE y, PBYTE data);
;data: wid8, hgt, linegfx, linegfx...
;клипирование слева (по scrx): сделано (коррекция ширины и x + ранний выход при полном несоответствии)
;клипирование справа (по scrx+scrwid): сделано (коррекция ширины + ранний выход при полном несоответствии)
;клипирование сверху (по scry): сделано (коррекция высоты и y + ранний выход при полном несоответствии)
;клипирование снизу (по scry+scrhgt): сделано (коррекция высоты + ранний выход при полном несоответствии)
respr
respr.A.=$+1 ;x
respr.B.=$+2 ;y
	ld de,0
respr.C.=$+1
	ld hl,0 ;data
	ld a,(hl) ;wid8
	inc hl
	inc a ;for shifted sprite position
	ld ly,a ;wid8
	srl e
	srl e
	srl e ;e=x8
	add a,e
	sub scrx+scrwid ;a=wid8+x8-scrright
	jr c,resprnwide.
	sub ly ;a=x8-scrright
	ret p ;x8>=scrright (x8 overflow)
	neg
	ld ly,a ;wid8 = scrright-x8
resprnwide.
	ld a,e ;x8
	sub scrx ;a=x8-scrx
	jp nc,resprnleft.
	add a,ly
	ret z
	ret m
	ld ly,a ;wid8 = wid8 - (scrx-x8)
	ld e,scrx
resprnleft.
	ld a,(hl) ;hgt
	add a,d ;y
	add a,7 ;for full chr
	rra
	rra
	rra
	and 0x1f ;bottom y8
	srl d
	srl d
	srl d ;d=y8
	sub d
	;cp 1
	;jp nz,$+3+3
	;jp $
	ld b,a ;hgt8
	add a,d
	sub scry+scrhgt ;a=hgt8+y8-scrbottom
	jp c,resprnhigh.
	sub b ;a=y8-scrbottom
	ret p ;y8>=scrbottom (y8 overflow)
	neg
	ld b,a ;hgt8 = scrbottom-y8
resprnhigh.
	ld a,d ;y8
	sub scry ;a=y8-scry
	jp nc,resprntop.
	add a,b
	ret z
	ret m
	ld b,a ;hgt8 = hgt8 - (scry-y8)
	ld d,scry
resprntop.
	jp prtileboxgo.

;печать фона из карты тайлов текущего экрана (там только адреса тайлов)
;PROC prtilebox(BYTE x8, BYTE y8, BYTE wid8, BYTE hgt8);
;клипирования нет!
prtilebox
prtilebox.C.=$+2
	ld ly,0 ;wid8
prtilebox.D.=$+1
	ld b,0 ;hgt8
prtilebox.A.=$+1 ;x8
prtilebox.B.=$+2 ;y8
	ld de,0

prtileboxgo.
	xor a
	ld h,d  ;0b000yyyyy
	srl h   ;0b0000yyyy = h
	rra     ;0by0000000
	add a,e ;0b000xxxxx
	add a,e ;0b000xxxxx
	ld l,a  ;0by0xxxxx0 = l
	ld a,d  ;0b000yyyyy
	rrca
	rrca
	rrca
	and 0b11100000
	or e    ;0b000xxxxx
	ld c,a  ;0byyyxxxxx = c
	ld a,d  ;0b000yyyyy
	and 0b00011000
	add a,scrbuf/256
	ld hx,a ;0b010yy000 = hx
	rrca
	rrca
	rrca
	add a,0x18+(scrbuf/256)-(scrbuf/0x800)
	ld lx,a ;0byyyxxxxx = lx
	ld de,tilemap
	add hl,de

;hl= tilemap + 0b0000yyyy y0xxxxx0
;hx(lx)c=scr = 0b010yy000 yyyxxxxx
;b=hgt8
prtileboxline.
	push bc ;scr
	push hl ;tilemap
	ld hy,ly ;wid8
prtileboxchr.
	ld e,(hl)
	inc l
	ld d,(hl)
	inc l

	ld b,hx
;24t loop, fit for contention
	ld a,(de)
	inc de
	ld (bc),a
	inc b
	ld a,(de)
	inc de
	ld (bc),a
	inc b
	ld a,(de)
	inc de
	ld (bc),a
	inc b
	ld a,(de)
	inc de
	ld (bc),a
	inc b
	ld a,(de)
	inc de
	ld (bc),a
	inc b
	ld a,(de)
	inc de
	ld (bc),a
	inc b
	ld a,(de)
	inc de
	ld (bc),a
	inc b
	ld a,(de)
	inc de
	ld (bc),a

	ld b,lx
	ld a,(de)
	ld (bc),a ;attr

	inc c
	dec hy
	jp nz,prtileboxchr.
	pop hl ;tilemap
	ld bc,128 ;tilemapwid*2
	add hl,bc
	pop bc ;scr
	ld a,c
	add a,32
	ld c,a
	jp nc,prtileboxndown.
	ld a,hx
	add a,8
	ld hx,a
	rrca
	rrca
	rrca
	add a,0x18+(scrbuf/256)-(scrbuf/0x800)
	ld lx,a ;0byyyxxxxx = lx
prtileboxndown.
	djnz prtileboxline.
	ret

;вывод элемента фона в тайловый буфер
;PROC pretile(BYTE x8, BYTE y8, BYTE wid8, BYTE hgt8, PBYTE data);
;data: [wid8, hgt8,] chrgfx, chrgfx...
;x8,y8 здесь может быть отрицательным
;клипирование по левому краю автоматическое
;клипирование по правому краю автоматическое
;клипирование по нижнему краю сделано (коррекция высоты + ранний выход при полном несоответствии)
;клипирование по верхнему краю сделано (пропуск строк)
pretile
pretile.A.=$+1 ;x8
pretile.B.=$+2 ;y8
	ld bc,0
	xor a
	ld h,b  ;0b000yyyyy
	srl h   ;0b0000yyyy = h
	rra     ;0by0000000
	add a,c ;0b000xxxxx
	add a,c ;0b000xxxxx
	ld l,a  ;0by0xxxxx0 = l
	ld de,tilemap
	add hl,de
;hl= tilemap + 0b0000yyyy y0xxxxx0
pretile.E.=$+1
	ld de,0 ;data
	;ld a,(de) ;wid8
	;inc de
	;ld lx,a ;wid8
	;ld a,(de) ;hgt8
	;inc de
	;ld hx,a ;hgt8
pretile.C.=$+2 ;wid8
pretile.D.=$+3 ;hgt8
	ld ix,0
	add a,b ;y8
	sub scry+scrhgt ;a=hgt8+y8-scrbottom
	jp c,pretilenhigh.
	sub hx ;a=y8-scrbottom
	;ret p ;y8>=scrbottom (y8 overflow) ;TODO fix
	neg
	;ld hx,a ;hgt8 = scrbottom-y8 ;TODO fix
pretilenhigh.
pretileline.
	 ;для фона 28xN
	 push de
	ld a,h
	cp tilemap/256
	ld a,e
	jr c,pretilenline.
	push hl
	ld b,lx ;wid8
pretilechr.
	ld (hl),a
	inc l
	ld (hl),d
	inc l
	add a,9 ;chr gfx size
	jp nc,$+4
	inc d
	djnz pretilechr.
	pop hl
pretilenlineq.
	ld e,a
	 ;для фона 28xN
	 pop de
	 inc d
	ld bc,128 ;tilemapwid*2
	add hl,bc
	dec hx
	jp nz,pretileline.
	ret
pretilenline.
	ld b,lx ;wid8
pretilenchr.
	add a,9 ;chr gfx size
	jp nc,$+4
	inc d
	djnz pretilenchr.
	jp pretilenlineq.

;PROC showscr();
;попадает под луч!
showscr
	ld de,scrtop
	ld hl,scrbuf-scraddr ;0x4000 ;screen5
	add hl,de
	ld b,scrhgt
showscrtileline.
	push bc
	ld a,8
showscrline.
	push de
	push hl
	ld bc,scrwid
	ldir
	pop hl
	pop de
	inc h
	inc d
	dec a
	jp nz,showscrline.
	push de
	push hl
	;ld a,h
	;rrca
	;rrca
	;rrca
	;add a,0x18+(scrbuf/256)-(scrbuf/0x800)-1
	;ld h,a
	ld a,d
	rrca
	rrca
	rrca
	add a,0x18+(scraddr/256)-(scraddr/0x800)-1 ;0x58-(0x40/8)-1 ;screen5
	ld d,a
        add a,+(scrbuf-scraddr)/256
        ld h,a
	ld bc,scrwid
	ldir
	pop hl
	pop de
	pop bc
	ld a,e
	sub -32
	ld e,a
	sbc a,a
	and -8
	add a,d
	ld d,a
	ld a,l
	sub -32
	ld l,a
	sbc a,a
	and -8
	add a,h
	ld h,a
	djnz showscrtileline.
	ret

;PROC clearscrbuf(BYTE attr);
clearscrbuf
	ld de,scrbuf+1
	ld bc,0x1800
	ld h,d
	ld l,c
	ld (hl),l
	ldir
clearscrbuf.A.=$+1
	ld (hl),7 ;attr
	ld bc,0x2ff
	ldir
	ret

;PROC cleartilemap(PCHAR tileaddr);
cleartilemap
	ld hl,tilemap+1
	ld de,tilemap+2
cleartilemap.A.=$+1
	ld bc,0;emptytile
	ld (hl),b
	dec l
	ld (hl),c
	ld bc,0xbfe
	ldir
	ret

;FUNC BOOL readpix(BYTE x, BYTE y);
;0x00 - pixel off
;0xff - pixel on
readpix
readpix.A.=$+1 ;x
readpix.B.=$+2 ;y
	ld bc,0
        call scrbufaddr.
;hl=screen addr
;a = 128..1
        and (hl)
        ret z ;0x00 - pixel off
        ld a,0xff ;0xff - pixel on
        ret

;PROC setpixscrbuf(BYTE x, BYTE y, BYTE color);
setpixscrbuf
setpixscrbuf.A.=$+1 ;x
setpixscrbuf.B.=$+2 ;y
	ld bc,0
        call scrbufaddr.
;hl=screen addr
;a = 128..1
        ld c,a ;bit
setpixscrbuf.C.=$+1 ;color
        ld a,0
        xor (hl)
        and c ;bit
        xor (hl)
        ;or (hl)
        ld (hl),a
        ret

;PROC setpix(BYTE x, BYTE y, BYTE color);
setpix
setpix.A.=$+1 ;x
setpix.B.=$+2 ;y
	ld bc,0
        call scraddr.
;hl=screen addr
;a = 128..1
        ld c,a ;bit
setpix.C.=$+1 ;color
        ld a,0
        xor (hl)
        and c ;bit
        xor (hl)
        ;or (hl)
        ld (hl),a
        ret

;PROC invpixscrbuf(BYTE x, BYTE y);
invpixscrbuf
invpixscrbuf.A.=$+1 ;x
invpixscrbuf.B.=$+2 ;y
	ld bc,0
        call scrbufaddr.
;hl=screen addr
;a = 128..1
        xor (hl)
        ld (hl),a
        ret

;PROC onpixscrbuf(BYTE x, BYTE y);
onpixscrbuf
onpixscrbuf.A.=$+1 ;x
onpixscrbuf.B.=$+2 ;y
	ld bc,0
        call scrbufaddr.
;hl=screen addr
;a = 128..1
        or (hl)
        ld (hl),a
        ret

;PROC offpixscrbuf(BYTE x, BYTE y);
offpixscrbuf
offpixscrbuf.A.=$+1 ;x
offpixscrbuf.B.=$+2 ;y
	ld bc,0
        call scrbufaddr.
;hl=screen addr
;a = 128..1
        cpl
        and (hl)
        ld (hl),a
        ret

;PROC invpix(BYTE x, BYTE y);
invpix
invpix.A.=$+1 ;x
invpix.B.=$+2 ;y
	ld bc,0
        call scraddr.
;hl=screen addr
;a = 128..1
        xor (hl)
        ld (hl),a
        ret

;PROC onpix(BYTE x, BYTE y);
onpix
onpix.A.=$+1 ;x
onpix.B.=$+2 ;y
	ld bc,0
        call scraddr.
;hl=screen addr
;a = 128..1
        or (hl)
        ld (hl),a
        ret

;PROC offpix(BYTE x, BYTE y);
offpix
offpix.A.=$+1 ;x
offpix.B.=$+2 ;y
	ld bc,0
        call scraddr.
;hl=screen addr
;a = 128..1
        cpl
        and (hl)
        ld (hl),a
        ret

scraddr.
	ld a,b
	rra
	rra
	rra
	xor b
	and 0xf8
	xor b
	and 0x1f
	add a,scraddr/256
	ld h,a
	ld a,c
	rlca
	rlca
	rlca
	xor b
	and 0xc7
	xor b
	rlca
	rlca
	ld l,a
;hl=screen addr
	ld a,c
	and 7
;a=shift right 0..7
        inc a
        ld b,a ;b=1..8
        ld a,1
        rrca
        djnz $-1
;a = 128..1
        ret

scrbufaddr.
	ld a,b
	rra
	rra
	rra
	xor b
	and 0xf8
	xor b
	and 0x1f
	add a,scrbuf/256
	ld h,a
	ld a,c
	rlca
	rlca
	rlca
	xor b
	and 0xc7
	xor b
	rlca
	rlca
	ld l,a
;hl=screen addr
	ld a,c
	and 7
;a=shift right 0..7
        inc a
        ld b,a ;b=1..8
        ld a,1
        rrca
        djnz $-1
;a = 128..1
        ret
