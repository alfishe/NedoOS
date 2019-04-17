;tilemask содержит адреса процедур для каждой клетки:
;copychr или skipchr
;cl=screen addr
;bl=attr addr
;в стеке лежат значения VALID0,VALID1, из которых образуются адреса процедур
;в конце строки лежит validnext (2 байта)
valid00
        ;inc l
        ;inc l
        ret
valid00_size=$-valid00
valid10
        ld l,-2
        add hl,sp
        ld h,b
        ld e,l
        ld d,hx
        dup 7
        ld a,(hl)
        ld (de),a
        inc h
        inc d
        edup
        ld a,(hl)
        ld (de),a
        ld h,c
        ld d,lx
        ld a,(hl)
        ld (de),a
        inc l
        inc l
        ret
valid10_size=$-valid10
valid01
        ld l,-1
        add hl,sp
        ;inc l
        ld h,b
        ld e,l
        ld d,hx
        dup 7
        ld a,(hl)
        ld (de),a
        inc h
        inc d
        edup
        ld a,(hl)
        ld (de),a
        ld h,c
        ld d,lx
        ld a,(hl)
        ld (de),a
        inc l
        ret
valid01_size=$-valid10
valid11
        ld l,-2
        add hl,sp
       if 1==1 ;381t, 62b
        ld e,l
        ld d,lx
        ld h,c
        ;ld a,d
        ;add a,+(#40-(scrbuf/256))&#ff
        ;ld h,a
        ldi       ;attr(left)
        ld a,(hl)
        ld (de),a ;attr(right)
        ld h,b
        ld d,hx
        dup 3
        ldd
        ld a,(hl)
        ld (de),a
        inc h
        inc d
        ldi
        ld a,(hl)
        ld (de),a
        inc h
        inc d
        edup
        ldd
        ld a,(hl)
        ld (de),a
        inc h
        inc d
        ldi
        ldi
        ld a,c
        add a,10
        ld c,a
        ret
       else ;426t, 78b
        ld e,l
        ld d,hx
        ld h,b
        dup 7
        ld a,(hl)
        ld (de),a
        inc h
        inc d
        edup
        ld a,(hl)
        ld (de),a ;scr(left)
        ld h,c
        ld d,lx
        ld a,(hl)
        ld (de),a ;attr(left)
        inc l
        inc e
        ld a,(hl)
        ld (de),a ;attr(right)
        ld h,b
        ld d,hx
        dup 7
        ld a,(hl)
        ld (de),a
        inc h
        inc d
        edup
        ld a,(hl)
        ld (de),a ;scr(right)
        inc l
        ret
       endif
valid11_size=$-valid11

prvalid
        ld (prvalidsp),sp
        ld sp,validmap
        ;ld l,0 ;начало экрана
        ld bc,scrbuf/256*256+(scrbuf/256+#18)
        ld ix,#4058 ;scr,attr
        ret
clearvalid
        ld (prvalidsp),sp
        ld sp,validmap+(validmaplinesize*tilemaphgt)
validq
        ld hl,validq
        ld de,VALID00
        ld b,tilemaphgt
clearvalid0
        push hl ;validq или validnext
        dup validmaplinesize/2-1
        push de
        edup
        ld hl,validnext
        djnz clearvalid0
prvalidsp=$+1
        ld sp,0
        ret

validnext
        ld l,-1
        add hl,sp
        ;inc l
        inc l
        ret nz
        ld a,b
        add a,8
        ld b,a
        add a,+(#40-(scrbuf/256))&#ff
        ld hx,a
        inc c
        ld a,c
        add a,+(#40-(scrbuf/256))&#ff
        ld lx,a
        ret

prlives
;печатаем lives сердечек и далее один пробел
        ld de,#401f;scrbuf+#1f
        ld a,(lives)
        inc a
        ld c,a
prlives0
        push de
        ld a,c
        dec a
        ld hl,sprlife
        jr nz,$+5
        ld hl,sprnolife
        ld b,8
prlives1
        ld a,(hl)
        ld (de),a
        inc hl
        inc d
        djnz prlives1
        pop de
        call nextlinede
        dec c
        jr nz,prlives0
        ret
        
sprnolife
        ds 8
sprlife
        db %00000000
        db %00110110
        db %01111111
        db %01111111
        db %00111110
        db %00011100
        db %00001000
        db %00000000

nextlinede
        ld a,e
        add a,32
        ld e,a
        ret nc
        ld a,d
        add a,8
        ld d,a
        ret

prmap
        ld hl,tilemap
        ld de,scrbuf
        ld hx,d
        ld lx,scrbuf/256+#18
        exx
        ld c,tilemaphgt
prmaplines
        exx
        push de
        exx
        ld b,tilemapwid
prmapline
        exx
        ld c,(hl)
        inc hl
        ld b,tilepic/256
        ld d,hx
        dup 7
        ld a,(bc)
        ld (de),a
        inc c
        inc d
        edup
        ld a,(bc)
        ld (de),a
        inc c
        ld d,lx
        ld a,(bc)
        ld (de),a
        inc e
        exx
        djnz prmapline
        exx
        ld de,tilemaplinesize-tilemapwid
        add hl,de
        pop de
        ld a,e
        add a,32
        ld e,a
        jr nc,prmapnewlineq
        ld a,hx
        add a,8
        ld hx,a
        inc lx
prmapnewlineq
        exx
        dec c
        jr nz,prmaplines
;сделать невалидными выведенные ячейки
        ld hl,validmap
        ld a,tilemaphgt
prmap_invalidatelines
        ld bc,tilemapwid-1
        ld d,h
        ld e,l
        inc de
        ld (hl),VALID1
        ldir
        ld bc,validmaplinesize-(tilemapwid-1)
        add hl,bc
        dec a
        jr nz,prmap_invalidatelines
        ret

probjlist
        ld ix,objlist
        ld b,0
probjlist0
        ld a,(ix+(obj_x+1))
        cp TERMINATOR
        ret z
        ld l,(ix+obj_objaddr)
        ld h,(ix+(obj_objaddr+1))
        ;hl=адрес описателя объекта (в начале лежит указатель на список анимаций)
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ;hl=указатель на список анимаций
        ld c,(ix+obj_anim) ;номер анимации
        ;ld b,0
        add hl,bc
        add hl,bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ;hl=указатель на анимацию
        ld c,(ix+obj_animphase) ;номер фазы анимации
        ;ld b,0
        add hl,bc
        add hl,bc
        add hl,bc
         inc hl ;пропустили время фазы
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ;hl=адрес views для данной фазы анимации
        ld c,(ix+obj_dir) ;номер направления 0..3
        ;ld b,0
        add hl,bc
        add hl,bc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ;hl=адрес спрайта
        exx
        ld c,(ix+obj_x)
        ld a,(ix+(obj_x+1))
        if coordsfactor !=4
        display "coordsfactor!=4"
        endif
        rra
        rr c
        rra
        rr c
        ld b,(ix+obj_y)
        ld a,(ix+(obj_y+1))
        if coordsfactor !=4
        display "coordsfactor!=4"
        endif
        rra
        rr b
        rra
        rr b
writereobjaddr=$+1
        ld hl,reobjlist
        ld (hl),c
        inc hl
        ld (hl),b
        inc hl
        ld (writereobjaddr),hl
;сделать невалидными выведенные ячейки
        ;ld (validxy),bc
        CALCvalidmapaddr_bcyx_tohl
        ld a,VALID1
        ld de,validmaplinesize-2
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        add hl,de
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        add hl,de
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        call prspr ;на выходе b=0
        if 1==0
;сделать невалидными выведенные ячейки
validxy=$+1
        ld hl,0
        CALCvalidmapaddr_hlyx_tohl
        ld a,VALID1
        ld c,validmaplinesize-2
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        add hl,bc
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        add hl,bc
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        endif
        ld c,objsize
        add ix,bc
        jp probjlist0

prbulletlist
        ld ix,bulletlist
        ld de,objsize
prbulletlist0
        ld a,(ix+(obj_x+1))
        cp TERMINATOR
        ret z
        ld c,(ix+obj_x)
        ld a,(ix+(obj_x+1))
        if coordsfactor !=4
        display "coordsfactor!=4"
        endif
        rra
        rr c
        rra
        rr c
        ld b,(ix+obj_y)
        ld a,(ix+(obj_y+1))
        if coordsfactor !=4
        display "coordsfactor!=4"
        endif
        rra
        rr b
        rra
        rr b
writerebulletaddr=$+1
        ld hl,rebulletlist
        ld (hl),c
        inc hl
        ld (hl),b
        inc hl
        ld (writerebulletaddr),hl
        CALCvalidmapaddr_bcyx_tohl
        ld (hl),VALID1
        COORDSBC_TOSCRHL 
;hl=screen addr
	ld a,c
	and 7 ;a=shift right 0..7
        inc a
        ld b,a ;b=shift right 1..8
        ld a,#01
        rrca
        djnz $-1
        or (hl)
        ld (hl),a
        ;ld de,objsize
        add ix,de
        jp prbulletlist0

cls
	ld hl,#4000
        call clshl
        ;красим жизни
        ld de,#581f;scrbuf+#1800+#1f
        ld b,maxlives
clscrbuf0
        ld a,#42 ;bright red
        ld (de),a
        ld a,e
        add a,32
        ld e,a
        djnz clscrbuf0
        ret
clshl
	ld d,h
        ld e,l
        inc de
        ld bc,#1800
        ld (hl),0;#ff
        ldir
	ld (hl),emptyattr
	ld bc,767
	ldir
        ret
clscrbuf
	ld hl,scrbuf
        call clshl
        ret

displaycollisionmap
        ld hl,collisionmap
        ld de,#5800
        ld b,collisionmaphgt
displaycollisionmap0
        push bc
        ld b,collisionmapwid
displaycollisionmap1
        ld a,(hl)
        inc hl
        add a,7
        or 7
        ld (de),a
        inc de
        djnz displaycollisionmap1
        ld bc,collisionmaplinesize-collisionmapwid
        add hl,bc
        ex de,hl
        ld bc,32-collisionmapwid
        add hl,bc
        ex de,hl
        pop bc
        djnz displaycollisionmap0
        ret

restoreobjects
        ld hl,(writereobjaddr)
        ld de,reobjlist
        or a
        sbc hl,de
        jp z,restoreobjects_clear
        ex de,hl
        srl d
        rr e
        ld hx,e
restoreobjects0
        ld c,(hl) ;x
        inc hl
        ld a,(hl) ;y
        and #f8
        ld b,a ;округлить!
        inc hl
        push hl
        COORDSBC_TOSCRDE ;de=scrbuf+
        ld a,b
        rra
        rra
        rra
        and #1f
        ld l,a ;y (в знакоместах)
        ld a,c
        rra
        rra
        rra
        and #1f ;x (в знакоместах)
        call calctilemapaddr_a_l ;hl=tilemapaddr
        
        call restoretile
        inc l ;tilemap
        inc e ;scrbuf
        call restoretile
        inc l ;tilemap
        inc e ;scrbuf
        call restoretile
        ld bc,tilemaplinesize-2
        add hl,bc
        ld a,e
        add a,32-2
        ld e,a
        jr nc,$+6
        ld a,d
        add a,8
        ld d,a
        call restoretile
        inc l ;tilemap
        inc e ;scrbuf
        call restoretile
        inc l ;tilemap
        inc e ;scrbuf
        call restoretile
        ld bc,tilemaplinesize-2
        add hl,bc
        ld a,e
        add a,32-2
        ld e,a
        jr nc,$+6
        ld a,d
        add a,8
        ld d,a
        call restoretile
        inc l ;tilemap
        inc e ;scrbuf
        call restoretile
        inc l ;tilemap
        inc e ;scrbuf
        call restoretile
        
        pop hl
        dec hx
        jp nz,restoreobjects0
restoreobjects_clear
        ld hl,reobjlist
        ld (writereobjaddr),hl
        ret
        
restorebullets
        ld hl,(writerebulletaddr)
        ld de,rebulletlist
        or a
        sbc hl,de
        jp z,restorebullets_clear
        ex de,hl
        srl d
        rr e
        ld hx,e
restorebullets0
        ld c,(hl) ;x
        inc hl
        ld a,(hl) ;y
        and #f8
        ld b,a ;округлить!
        inc hl
        push hl
        COORDSBC_TOSCRDE ;de=scrbuf+
        ld a,b
        rra
        rra
        rra
        and #1f
        ld l,a ;y (в знакоместах)
        ld a,c
        rra
        rra
        rra
        and #1f ;x (в знакоместах)
        call calctilemapaddr_a_l ;hl=tilemapaddr
        call restoretile
        pop hl
        dec hx
        jp nz,restorebullets0
restorebullets_clear
        ld hl,rebulletlist
        ld (writerebulletaddr),hl
        ret

restoretile
;hl=tilemap+
;de=scrbuf+
        push de ;scrbuf+
        push hl ;tilemap+
        ld l,(hl)
        ld h,tilepic/256 ;hl=tile gfx
        dup 7
        ld a,(hl)
        ld (de),a ;restore scr (y=+0..6)
        inc l
        inc d
        edup
        ld a,(hl)
        ld (de),a ;restore scr (y=+7)
        inc l
        ld a,d ;'scrbuf+7, 'scrbuf+#f, 'scrbuf+#17
        ;sub scrbuf/256
        rrca ;#80+'scrbuf/2+3, #80+'scrbuf/2+7, #80+'scrbuf/2+#b
        rrca ;#c0+'scrbuf/4+1, #c0+'scrbuf/4+3, #c0+'scrbuf/4+5
        rrca ;#e0+'scrbuf/8+0, #e0+'scrbuf/8+1, #e0+'scrbuf/8+2
        ;and 3
        add a,scrbuf/256+#18 - (#e0+scrbuf/#800)
        ld d,a ;de=attraddr
        ld a,(hl)
        ld (de),a ;restore attr
        pop hl ;tilemap+
        ld a,h
        add a,+(validmap-tilemap)/256
        ld d,a
        ld e,l
        ld a,VALID1 ;невалиден, надо перерисовать
        ld (de),a
        pop de ;scrbuf+
        ret

prnum
        ld bc,10000
        call prdig
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
        call prchar
        ;pop hl
        ret
        
prcharin
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font-256;#3c00
        add hl,bc
        ld b,8
prchar0
        ld a,(hl) ;font
        ld (de),a ;scr
        inc hl
        inc d ;+256
        djnz prchar0
        ret

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
        
prtext
;bc=координаты
;hl=text
prtext0
        ld a,(hl)
        or a
        ret z
        call prcharxy
        inc hl
        inc c
        jr prtext0
        
calcscrbufaddr
;de=scrbuf + (y&#18)+((y*32)&#ff+x)
        ld a,b ;y
        and #18
        add a,scrbuf/256
        ld d,a
        ld a,b ;y
        add a,a ;*2
        add a,a ;*4
        add a,a ;*8
        add a,a ;*16
        add a,a ;*32
        add a,c ;x
        ld e,a
        ret
        
calcscraddr
;de=#4000 + (y&#18)+((y*32)&#ff+x)
        ld a,b ;y
        and #18
        add a,#40
        ld d,a
        ld a,b ;y
        add a,a ;*2
        add a,a ;*4
        add a,a ;*8
        add a,a ;*16
        add a,a ;*32
        add a,c ;x
        ld e,a
        ret
        
calcattraddr
        call calcscraddr
        ;call calcattraddr_fromscr
calcattraddr_fromscr
;de=#5800 + (y&#18)/8+((y*32)&#ff+x)
        ld a,d
        ;sub #40
        rra
        rra
        rra
        and 3
        add a,#58
        ld d,a ;de=attraddr
        ret

prcharxy
;a=code
;bc=yx
        push bc
        push de
        push hl
        push af
        call calcscraddr
        pop af
        push de
        call prcharin
        pop de
        call calcattraddr_fromscr
curattr=$+1
        ld a,0
        ld (de),a
        pop hl
        pop de
        pop bc
        ret
        
        include "sprite.asm"
        include "sprset.ast"
        align 256
        include "tileset.ast"
