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
       jr c,DrawWormInMap_right
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
        jp MapGoRight_de

DrawWormInMap_right
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
;DrawWormInMappp_leftcolumn
_left=0x47
_right=0xb8
        push de
        push hl
        push iy
        ld a,(iy)
        SETPGC000
        ld b,8
DrawWormInMap_leftcolumn0
        ld a,(de)
        rlc (hl)
        jr nc,$+4
        xor _right
        ld (de),a
        inc hl
        dec d
        bit 6,d
        call z,MapNextPg_de
        djnz DrawWormInMap_leftcolumn0
        pop iy
        pop hl
        pop de
        call MapGoRight_de
        call DrawWormInMappp2
        call DrawWormInMappp
;DrawWormInMappp_rightcolumn
_left=0x47
_right=0xb8
        push de
        push hl
        push iy
        ld a,(iy)
        SETPGC000
        ld b,8
DrawWormInMap_rightcolumn0
        ld a,(de)
        rlc (hl)
        jr nc,$+4
        xor _left
        ld (de),a
        inc hl
        dec d
        bit 6,d
        call z,MapNextPg_de
        djnz DrawWormInMap_rightcolumn0
        pop iy
        pop hl
        pop de
        ;jp MapGoRight_de
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
;e=y (от верхнего края TERRAIN)
;bc=x
       LD A,e
       add a,MAPHGT-TERRAINHGT
        SUB TERRAINHGT;MAPHGT
       RET NC
;a=-TERRAINHGT..-1
       PUSH BC
       PUSH HL
       cpl
       ld h,a ;~truey
        rrca
        rrca
        rrca
        xor c
        and 3*8 ;6(7)=xlayer ;3*8=(y/64)*8
        xor c
        rrca
        and 15 ;4 layers with 4 pages each
       if SKIPPGS
       add a,SKIPPGS
       endif
      ld (XorPixInMap_pgnum),a ;окупается только при экономии push..pop de
        srl b
        rr c
      ex af,af' ;'
        srl b
        ld a,c
        rra ;x/4
     if 1
        cpl
;11. -> 100 -> 101
;10. -> 101 -> 110
;01. -> 000 -> 001
;00. -> 001 -> 010
        rrca   ;"b1" -> b0
        rrca   ;"b1" -> b7
        add a,a;"b1" -> CY
        ccf
        rla   ;~"b1" -> b0
        inc a
     else
        rra ;x/8
       cpl
       ld c,a ;x/8
       add a,a
       and 0xfc
       rr c
       sbc a,-2
     endif
       ld l,a ;x8=0: 0x3d ;x8=1: 0x3e ;x8=2: 0x39 ;x8=3: 0x3a
        ld a,h ;~truey
        or 0xc0
        ld h,a
XorPixInMap_pgnum=$+1
        ld a,(tpushpgs) ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        SETPGC000
      ex af,af' ;'
      sbc a,a
      xor 0x47
        xor (hl)
        ld (hl),a
       POP HL
       POP BC
        RET 

PrepareUnSetPixInMap
        ret

UnSetPixInMap
;e=truey ;e=y (от верхнего края TERRAIN)
;bc=x
;        LD A,e
;       add a,MAPHGT-TERRAINHGT
;        SUB TERRAINHGT;MAPHGT
;        RET NC ;TODO чтобы не вырезало потолок, если взорван пол! или проверять в самом круге
       ld a,e
;a=-TERRAINHGT..-1
       ;PUSH BC
       ;PUSH HL
       cpl
       ld h,a ;~truey
        rrca
        rrca
        rrca
        xor c
        and 3*8 ;6(7)=xlayer ;3*8=(y/64)*8
        xor c
        rrca
        and 15 ;4 layers with 4 pages each
       if SKIPPGS
       add a,SKIPPGS
       endif
      ld (UnSetPixInMap_pgnum),a ;окупается только при экономии push..pop de
        srl b
        rr c
      ex af,af' ;'
        srl b
        ld a,c
        rra ;x/4
     if 1
        cpl
;11. -> 100 -> 101
;10. -> 101 -> 110
;01. -> 000 -> 001
;00. -> 001 -> 010
        rrca   ;"b1" -> b0
        rrca   ;"b1" -> b7
        add a,a;"b1" -> CY
        ccf
        rla   ;~"b1" -> b0
        inc a
     else
        rra ;x/8
       cpl
       ld c,a ;x/8
       add a,a
       and 0xfc
       rr c
       sbc a,-2
     endif
       ld l,a ;x8=0: 0x3d ;x8=1: 0x3e ;x8=2: 0x39 ;x8=3: 0x3a
        ld a,h ;~truey
        or 0xc0
        ld h,a
UnSetPixInMap_pgnum=$+1
        ld a,(tpushpgs) ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        SETPGC000
      ex af,af' ;'
      sbc a,a
      xor 0xb8;0x47
        and (hl)
        ld (hl),a
       ;POP HL
       ;POP BC
        RET 
