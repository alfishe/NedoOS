;процедуры для рисования в карту, нижнего уровня (зависят от типа экрана)

Pr2CharsInMap
;a'=char1
;a=char2
;hl'=map+
         EXX 
         PUSH HL
         ld de,MAPWID
         EXX 
        push bc
        PUSH HL
        LD D,FONT/2/256
        LD H,D
        SUB 32
        RLA 
        RLA 
        LD L,A
        ADD HL,HL
        ex af,af' ;'
        SUB 32
        RLA 
        RLA 
        RLA 
        LD E,A
        RL D
        LD B,7
SPRINT0 LD A,(DE)
        INC E
        RLCA 
        RLCA 
        RLCA 
        RLCA 
        OR (HL)
        INC L
        EXX 

;TODO

        ;XOR (HL)
        ;LD (HL),A

        ADD HL,DE
        EXX 
        DJNZ SPRINT0
        POP HL
        POP bc
         EXX 
         pop HL
         inc hl
         EXX 
        RET 

SetXYInMap
;b=y
;c=x
         push bc
         exx
         pop bc
        ;LD H,TMAPLN/256
        ;LD L,B
        ;LD A,(HL)
        ;INC H
        ;LD H,(HL)

;TODO

        ; srl c
        ;ADD A,C
        ;LD L,A
        ;JR NC,$+3
        ;INC H

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
        ;call MapGoRight
DrawWormInMappp2
        call DrawWormInMappp
        ;call MapGoRight        
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
;MapGoRight
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
      push ix
       ;neg
       ld b,a ;true y
       cpl
       ;ld b,a
        rlca
        rlca
        and 3 ;y/64
        add a,a
        add a,a
        ;ld l,a
        srl e
        rr c
        ld lx,0x47
       jr nc,XorPixInMap_right
        ld lx,0xb8
XorPixInMap_right
        ;ld a,c
        ;and 3 ;x layer
        ;add a,l
        xor c
        and 0xfc ;3 x layer
        xor c
       if SKIPPGS
       add a,SKIPPGS
       endif
        ld l,a;0
        ld h,tpushpgs/256 ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        srl e
        rr c
        srl e
        rr c
        ld a,(hl)
        push bc
        SETPGC000
        pop bc
        ;jr $
        ;ld hl,0xc001
        ld a,b ;y
        and 0x3f
        ;add a,0xc0
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
       ;inc a;add a,1;l
       rr c
       adc a,1
       ld l,a
       ;ld a,c
       ;and 1
       ;add a,l
       ;ld l,a
        ;jr $
        ld a,(hl)
        xor lx;0xb8
        ld (hl),a

      pop ix
      pop de
       POP HL
       POP BC
        RET 

PrepareUnSetPixInMap
        ret

UnSetPixInMap ;and in mask
;b=y
;ec=x
       ; LD A,B
       ;add a,MAPHGT-TERRAINHGT
       ; SUB TERRAINHGT;MAPHGT
       ; RET NC ;TODO чтобы не вырезало потолок, если взорван пол! или проверять в самом круге
       PUSH BC
       PUSH HL
      push de
      push ix
       ;neg
       ;ld b,a
        ld a,b ;y
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
        ;jr $
        ld hl,0xc001
        ld a,b ;y
        and 0x3f
        add a,h
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
       add a,l
       ld l,a
       ld a,c
       and 1
       add a,l
       ld l,a
        ld a,(hl)
        and lx;0xb8
        ld (hl),a

      pop ix
      pop de
       POP HL
       POP BC
        RET 
