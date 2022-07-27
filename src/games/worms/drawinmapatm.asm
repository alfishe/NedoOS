;процедуры для рисования в карту, нижнего уровня (зависят от типа экрана)

Pr2CharsInMap
;a'=char1
;a=char2
;de'=map+
        ;push bc
        ;PUSH HL
        exx
        ex af,af' ;'
        SUB 32
        add a,a
        add a,a
        add a,a
        LD h,FONT/256
        LD L,A
        jr nc,$+3
        inc h
        call PrCharInMappp2

        ex af,af' ;'
        SUB 32
        add a,a
        add a,a
        add a,a
        LD h,FONT/256
        LD L,A
        jr nc,$+3
        inc h
        call PrCharInMappp2
        exx
        ;POP HL
        ;POP bc
        RET 

PrCharInMappp2
        call PrCharInMappp
        ;call MapGoRight_de
PrCharInMappp
;hl=gfx
;de=map+
_left=0x47
_right=0xb8
        push de
        push hl
        push iy
        ld a,(iy)
        SETPGC000
        ld b,7;8
PrCharInMappp0
        ld a,(de)
        rlc (hl)
        jr nc,$+4
PrCharInMap_leftcolor=$+1
        xor _left
        rlc (hl)
        jr nc,$+4
PrCharInMap_rightcolor=$+1
        xor _right     
        ld (de),a
        inc l
        dec d
        bit 6,d
        call z,MapNextPg_de
        djnz PrCharInMappp0
        pop iy
        pop hl
        pop de
        jp MapGoRight_de

SetXYInMap
;b=y
;c=x/4
;hl=NAMES+ (по нему /(4*12) можно вычислить номер команды и найти цвет)
        ld a,l
         push bc
         exx
        sub NAMES&0xff
        ld c,9*3      ;color3 (red)
        sub 48
        jr c,SetXYInMap_colorok
        ld c,9*1+0xc0 ;color9 (yellow)
        sub 48
        jr c,SetXYInMap_colorok
        ld c,9*2+0xc0 ;color10 (green)
        sub 48
        jr c,SetXYInMap_colorok
        ld c,9*6+0xc0 ;color14 (cyan)
SetXYInMap_colorok
        ld a,c
        and 0x47
        ld (PrCharInMap_leftcolor),a
        xor c
        ld (PrCharInMap_rightcolor),a
         pop bc
       ld a,b ;y
       cpl
        rlca
        rlca
        and 3 ;y/64
        srl c ;x0=x phase (0/2)
        adc a,a
        add a,a
       if SKIPPGS
       add a,SKIPPGS
       endif
        ld ly,a;0
        ld hy,tpushpgs/256 ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        ld a,b ;y
        and 0x3f
       cpl
        ld d,a
;c=0: l=0x3d
;c=1: l=0x3e
;c=2: l=0x39
;c=3: l=0x3a
;...
       ld a,c ;x/8
       cpl
       add a,a
       and 0xfc
       rr c
       adc a,1
       ld e,a
       ld a,(iy)
       SETPGC000
         exx
        ret

DrawWormInMap ;TODO и в маску?
;de=x in pixels
;l=y
;bc=gfx
    push bc ;gfx
       ld a,l ;y
       cpl
        rlca
        rlca
        and 3 ;y/64
        add a,a
        add a,a
        srl d
        rr e
;        ld lx,0x47
;       jr nc,DrawWormInMap_right
;        ld lx,0xb8
;DrawWormInMap_right
        xor e
        and 0xfc ;0..3 x layer
        xor e
       if SKIPPGS
       add a,SKIPPGS
       endif
        ld ly,a;0
        ld hy,tpushpgs/256 ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        srl d
        rr e
        srl d
        rr e
        ld a,l ;y
        and 0x3f
       cpl
        ;add a,0xc0
        ld d,a
;e=0: l=0x3d
;e=1: l=0x3e
;e=2: l=0x39
;e=3: l=0x3a
;...
       ld a,e ;x/8
       cpl
       add a,a
       and 0xfc
       ;inc a ;add a,1;l
       rr e
       adc a,1
       ld e,a
     pop hl ;gfx
        call DrawWormInMappp2
        ;call MapGoRight_de
DrawWormInMappp2
        call DrawWormInMappp
        ;call MapGoRight_de
;TODO 16c sprites
DrawWormInMappp
_left=0x47
_right=0xb8
        push de
        push hl
        push iy
        ld a,(iy)
        SETPGC000
        ld b,8
DrawWormInMap0
        ld a,(de)
        rlc (hl)
        jr nc,$+4
        xor _left
        rlc (hl)
        jr nc,$+4
        xor _right     
        ld (de),a
        inc hl
        dec d
        bit 6,d
        call z,MapNextPg_de
        djnz DrawWormInMap0
        pop iy
        pop hl
        pop de
        ;ret
MapGoRight_de
;de=map
;iy=tpushpgs+
        inc ly
        ld a,ly
        and 3
        ret nz
        ld a,ly
        sub 4
        ld ly,a
        inc e
        bit 0,e
        ret z ;0xfd -> 0xfe
        ld a,e
        sub 6
        ld e,a
        ret

PrepareXorPixInMap
        ret

XorPixInMap
;b=y (от верхнего края TERRAIN)
;ec=x
       LD A,B
       add a,MAPHGT-TERRAINHGT
        SUB TERRAINHGT;MAPHGT
       RET NC
;a=-TERRAINHGT..-1
       PUSH BC
       PUSH HL
      push de
       ld l,a ;true y
       cpl
        rlca
        rlca
        and 3 ;y/64
        add a,a
        add a,a
        srl e
        rr c
        ld d,0x47
       jr nc,XorPixInMap_right
        ld d,0xb8
XorPixInMap_right
        xor c
        and 0xfc ;3 x layer
        xor c
       if SKIPPGS
       add a,SKIPPGS
       endif
        srl e
        rr c
        srl e
        rr c ;x/8
      ld e,a
        ld a,l ;y
        and 0x3f
       cpl
        ld h,a
       ld a,c ;x/8
       cpl
       add a,a
       and 0xfc
       rr c
       adc a,1
       ld l,a ;c=0: l=0x3d ;c=1: l=0x3e ;c=2: l=0x39 ;c=3: l=0x3a
      ld c,e
        ld b,tpushpgs/256 ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        ld a,(bc)
        SETPGC000
        ld a,(hl)
        xor d;0xb8
        ld (hl),a
      pop de
       POP HL
       POP BC
        RET 

PrepareUnSetPixInMap
        ret

UnSetPixInMap
;b=y
;ec=x
        LD A,B
       add a,MAPHGT-TERRAINHGT
        SUB TERRAINHGT;MAPHGT
        RET NC ;TODO чтобы не вырезало потолок, если взорван пол! или проверять в самом круге
;a=-TERRAINHGT..-1
       PUSH BC
       PUSH HL
      push de
      push ix
       ld b,a ;true y
       cpl
        rlca
        rlca
        and 3 ;y/64
        add a,a
        add a,a
        ld l,a
        srl e
        rr c
        ld lx,0xb8;0x47
       jr nc,UnSetPixInMap_right
        ld lx,0x47;0xb8
UnSetPixInMap_right
        srl e
        rr c
        rra
        srl e
        rr c
        rra
        rlca
        rlca
        ;cpl
        and 3 ;x layer
        add a,l
       if SKIPPGS
       add a,SKIPPGS
       endif
        ld l,a;0
        ld h,tpushpgs/256 ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        ld a,(hl)
        push bc
        SETPGC000
        pop bc
        ld a,b ;y
        and 0x3f
       cpl
        ld h,a
;c=0: l=0x3d
;c=1: l=0x3e
;c=2: l=0x39
;c=3: l=0x3a
;...
       ld a,c
       cpl
       add a,a
       and 0xfc
       rr c
       adc a,1
       ld l,a
        ld a,(hl)
        and lx;0xb8
        ld (hl),a
      pop ix
      pop de
       POP HL
       POP BC
        RET 
