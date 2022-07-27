;процедуры для рисования в карту, верхнего уровня (не зависят от типа экрана)

AnimMines
        ld hl,drawminesphase
        ld a,(hl)
        xor drawminesphase_xor
        ld (hl),a
        ret

UnDrawWormsInMap ;FIXME
DrawWormsInMap
       if !ATM
        LD A,PGMAP;16
        CALL OUTME
       endif
        ld hl,WORMXY
DrawWormsInMap0
        ;POP BC ;SPRITE (lsb=xlow*64;32)
        ;POP HL ;COORDS
        ;POP DE ;SPEED
        ld c,(hl)
        inc l
        ld a,(hl) ;spritehsb
        inc l
        cp 1
        ret z ;jr z,DrawWormsInMap0q
       ld b,a
       cp sprmine_0/256
drawminesphase=$
drawminesphase0=24 ;jr
drawminesphase1=32 ;jr nz
drawminesphase_xor=drawminesphase0^drawminesphase1
       jr nz,DrawWormsInMap_nomine
       ld a,c
       xor 8;1
       ld c,a
DrawWormsInMap_nomine
        ld e,(hl) ;xhigh
        inc l
       ld a,e
       cp XWID
       jr nc,DrawWormsInMap_skip
        ld d,0
       dup 2
        sla c
        rl e
        rl d
       edup
        sla c
       push hl
        ld l,(hl)
;de=x in pixels
;l=y
;bc=gfx
        call DrawWormInMap
       pop hl
DrawWormsInMap_skip
        inc l
        inc l
        inc l
        jr DrawWormsInMap0

UnDrawWormsDataInMap ;FIXME
DrawWormsDataInMap
       if !ATM
        LD A,PGMAP;16
        CALL OUTME
       endif
        ld hl,WORMXY
DrawWormsDataInMap0
        ;POP BC ;SPRITE (lsb=xlow*32)
        ;POP HL ;COORDS
        ;POP DE ;SPEED
        ;ld e,(hl)
        inc l
        ld a,(hl) ;spritehsb
        inc l
        cp 1
        ret z ;jr z,DrawWormsInMap0q
        ld c,(hl) ;xhigh
        inc l
        ld b,(hl) ;y
        inc l
        inc l
       cp sprmine_0/256
       jr z,DrawWormsDataInMap_skip
       ld a,c ;xhigh
       cp XWID
       jr nc,DrawWormsDataInMap_skip ;dead
       ld a,(hl) ;dy
       cp SPRLIST_STAYING
       jr nz,DrawWormsDataInMap_skip ;not staying
       push hl
        ld a,b ;y
        SUB 13
        LD B,A ;y
       ld de,+(CUWORMS+2)-(WORMXY+5)
       add hl,de
       ld a,(hl) ;health
        add hl,hl
        LD de,NAMES-(2*(CUWORMS+2))
        ADD HL,de ;name+12
;a=health
;b=y
;c=xhigh (XXXXXXXX XXx?????)
;hl=name
       PUSH af ;health
       push bc ;yx
       ld a,XWID-(6*XWIDCHR) ;TODO по ширине имени
       cp c ;x
       jr nc,$+3
       ld c,a ;чтобы не заезжало за правый край карты
        call SetXYInMap
        LD B,6
SPRINTnam
        LD a,(HL)
        ex af,af' ;'
        INC HL
        LD A,(HL)
        CALL Pr2CharsInMap
        INC HL
        DJNZ SPRINTnam
        dec hl ;чтобы можно было использовать hl для указания на команду (т.е. на цвет)
       pop bc ;yx
       ld a,b
       add a,6
       ld b,a ;y
       ld a,XWID-(2*XWIDCHR)
       cp c ;x
       jr nc,$+3
       ld c,a ;чтобы не заезжало за правый край карты
        call SetXYInMap
       POP AF ;health
        LD BC,+('0'-1)*256+100
        INC B
        SUB C
        JR NC,$-2
        ADD A,C
       ld c,a;PUSH AF ;health mod 100
        LD a,' '
        ex af,af' ;'
        LD A,B
        CALL Pr2CharsInMap
       ld a,c;POP AF ;health mod 100
        LD BC,+('0'-1)*256+10
        INC B
        SUB C
        JR NC,$-2
        ex af,af' ;'
        LD A,B
        ex af,af' ;'
        add a,'0'+10
        call Pr2CharsInMap
       pop hl
DrawWormsDataInMap_skip
        inc l
        jr DrawWormsDataInMap0

UnDrawCircleInMap
;d,lxe=y0,x0
;b=R
       push bc
       push de
       push ix
        call PrepareUnSetPixInMap
        ld hl,UnSetPixInMap
        call UnDrawCircle
        call SetPgMask
       pop ix
       pop de
       pop bc
        ld hl,UnSetPixInMask
UnDrawCircle
        ld (hline_unsetpixpatch),hl
        LD L,B,H,#00 ;hl=R
        ADD HL,HL ;hl=curwidth=R*2
       PUSH DE
        LD DE,#0003 ;???
        EX DE,HL
        OR A:SBC HL,DE ;hl=3-(r*2)
        LD e,B,d,#00 ;e=curx=R, d=cury=0
       POP bc ;xy0

fCIR0    PUSH bc ;xy0
       push hl
       push de
       push bc
;e=curx
;d=cury
;b,lxc=y0,x0
        ld a,c
        sub e
        ld c,a ;x=x0-curx
        ld a,e ;len=curx
        ld e,lx ;x0high
        jr nc,$+3
         dec e
        add a,a ;len=2*len
        ld hx,a ;len
       push bc
       push de
        ld a,b ;y0
        add a,d ;cury
        ld b,a ;y=y0+cury
        push ix
        call hline_hx ;b,ec=y,x ;hx=len=2*curx
        pop ix
       pop de
       pop bc
        ld a,b ;y0
        sub d ;cury
        ld b,a ;y=y0-cury
        call hline_hx ;b,ec=y,x ;hx=len=2*curx
       pop bc
       pop de
       pop HL
      PUSH HL ;curwidth
        BIT 7,H:JR Z,fCIR2
;curwidth<0
        INC d ;cury
        LD L,d
        ld H,#00
        LD bc,#0006 ;???
        JR fCIR3 ;hl=cury
fCIR2
;конец ступеньки
       push bc
       push de
        ld a,c
        sub d
        ld c,a ;x=x0-cury
        ld a,d ;len=cury
        ld d,e ;curx
        ld e,lx ;x0high
        jr nc,$+3
         dec e
        add a,a ;len=2*len
        ld hx,a ;len
       push bc
       push de
        ld a,b ;y0
        add a,d ;curx
        ld b,a ;y
        push ix
        call hline_hx ;b,ec=y,x ;hx=len=2*cury
        pop ix
       pop de
       pop bc
        ld a,b ;y0
        sub d ;curx
        ld b,a ;y
        call hline_hx ;b,ec=y,x ;hx=len=2*cury
       pop de
       pop bc
        INC d ;cury
        DEC e ;curx
        LD L,d
        ld H,#00
        LD c,e,b,#00
        OR A:SBC HL,bc ;hl=cury-curx
        LD bc,#000A ;???
fCIR3    ADD HL,HL
        add HL,HL ;hl=(cury-curx)*4
        add HL,bc ;hl=(cury-curx)*4 + const
      POP bc:ADD HL,bc ;hl=(cury-curx)*4 + const + curwidth

        POP bc ;xy0
        LD A,e
        cp d
        JP NC,fCIR0
        ret
       
hline_hx
;b=y
;ec=x
;hx=len
hline0
hline_unsetpixpatch=$+1
        call UnSetPixInMap ;/UnSetPixInMask
        inc c
        jr nz,$+3
         inc e
        dec hx ;--
        jr nz,hline0
        ret

UnSetPixInMask
;b=y (TODO /2)
;ec=x (TODO /2)
        LD A,B
       add a,MAPHGT-TERRAINHGT
        SUB TERRAINHGT;MAPHGT
        RET NC
      PUSH HL
      push bc
        sub 8 ;таблица строк маски использует координату "y" для ног, т.е. на 8 пикс ниже
        ld l,a
        ld b,e
        srl b ;xhigh
        rr c ;xlow
        dec bc
        dec bc ;маска рассчитана под "x" центра червя, т.е. сдвинута на 4 больших (2 масочных) пикс
        LD H,TMASKLN/256
        LD A,C
        AND 0xf8
        ADD A,b ;0/1 = xhigh/2
        RRCA 
        RRCA 
        RRCA 
        CP MASKWID
        JR NC,UnSetPixInMaskq
        ADD A,(HL)
        INC H
        LD H,(HL)
        LD L,A
        JR NC,$+3
        INC H
        LD A,C
        AND 7
        INC A
        LD B,A
        LD A,0xfe
        RRCA 
        DJNZ $-1
        and (HL)
        LD (HL),A
UnSetPixInMaskq
      POP BC
      POP HL
        RET 
