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
        XOR (HL)
        LD (HL),A
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
;c=x/4
;hl=NAMES+ (по нему /(4*12) можно вычислить номер команды и найти цвет)
         push bc
         exx
         pop bc
        LD H,TMAPLN/256
        LD L,B
        LD A,(HL)
        INC H
        LD H,(HL)
         srl c
        ADD A,C
        LD L,A
        JR NC,$+3
        INC H
         exx
        ret

DrawWormInMap ;TODO и в маску?
;de=x in pixels
;l=y
;bc=gfx
        ld a,e ;x
        and 7
        ld (DrawWormInMap_jr),a
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
DrawWormInMap0
        ld a,(bc)
        ld l,a
        ld h,0
DrawWormInMap_jr=$+1
        jr $
        dup 7
        add hl,hl
        edup
        ld a,(de)
        xor h
        ld (de),a
        inc de
        ld a,(de)
        xor l
        ld (de),a
        ld a,e
        add a,MAPWID-1
        ld e,a
        jr nc,$+3
        inc d
        inc c
        ld a,c
        and 7
        jr nz,DrawWormInMap0
        ret

PrepareXorPixInMap
        push bc
        LD A,PGMAP;16
        CALL OUTME
        pop bc
        ret

XorPixInMap
;e=y (от верхнего края TERRAIN)
;bc=x
        LD A,e
       add a,MAPHGT-TERRAINHGT
        SUB TERRAINHGT;MAPHGT
        RET NC
       PUSH BC
       PUSH HL
        LD H,TMAPLN/256
        LD L,A
        LD A,C ;xlow
        AND 0xf8
        ADD A,b ;xhigh
        RRCA 
        RRCA 
        RRCA 
        CP MAPWID
        JR NC,XorPixInMapq
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
        LD A,1
        RRCA 
        DJNZ $-1
        XOR (HL)
        LD (HL),A
XorPixInMapq
       POP HL
       POP BC
        RET 

PrepareUnSetPixInMap
        push bc
        LD A,PGMAP;16
        CALL OUTME
        pop bc
        ret

UnSetPixInMap
;e=truey ;e=y (от верхнего края TERRAIN)
;bc=x
;        LD A,e
;       add a,MAPHGT-TERRAINHGT
;        SUB TERRAINHGT;MAPHGT
;        RET NC
       ;PUSH HL
       ;PUSH BC
        LD H,TMAPLN/256
         LD L,e;A
        LD A,C ;xlow
        AND 0xf8
        ADD A,b ;xhigh
        RRCA 
        RRCA 
        RRCA 
        CP MAPWID
       ret nc;JR NC,UnSetPixInMapq
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
;UnSetPixInMapq
       ;POP BC
       ;POP HL
        RET 
