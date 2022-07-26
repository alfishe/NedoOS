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
        LD H,TMAPLN/256
        LD L,B
        LD A,(HL)
        INC H
        LD H,(HL)

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
        ;ld a,e ;x
        ;and 7
        ;ld (DrawWormInMap_jr),a
        LD H,TMAPLN/256
        ld a,e ;x
        srl d
        rra
        srl d
        rra
        srl d
        rra
        add a,(hl)
        ld e,a
        inc h
        adc a,(hl)
        sub e
        ld d,a
        
;TODO
        
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
       ;ld b,a
        ;ld a,b ;y
       cpl
       ld b,a
        rlca
        rlca
        and 3 ;y/64
        add a,a
        add a,a
        ld l,a
        srl e
        rr c
        ld lx,0x47
       jr nc,XorPixInMap_right
        ld lx,0xb8
XorPixInMap_right
        ld a,c
        and 3 ;x layer
        add a,l
       add a,SKIPPGS
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
       add a,SKIPPGS
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
        ;jr $
        ld a,(hl)
        and lx;0xb8
        ld (hl),a

      pop ix
      pop de
       POP HL
       POP BC
        RET 
