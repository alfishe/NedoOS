;процедуры для генерации карты, нижнего уровня (зависят от типа экрана)

ClearMap
       ld a,PGMAP
       call OUTME
        LD HL,MAP
        LD DE,MAP+1
        LD BC,0xffff-MAP
        LD (HL),0
        LDIR
        ret

FindPlacesForGrass ;записывает в grassbuf
       ld a,PGMAP
       call OUTME
;по чётным столбцам сверху вниз ищем переходы 0->1
        ld ix,grassbuf
        ld hl,MAP
        ld de,MAPWID
        ld c,128 ;1 bit >>2 every time
        ld b,MAPWID
        xor a ;RLE counter
        ex af,af' ;'
findgrass_columns0
       push bc
       push hl
        ld b,MAPHGT-1
findgrass1
        ld a,(hl)
        cpl
        and c
        add hl,de
        and (hl)
        ex af,af' ;'
        inc a
         jr nz,findgrass_nooverflow
         ld (ix),a;0 ;0=просто пропуск 255 пикс
         inc ix
        ld a,hx
        cp (grassbuf+grassbufsz)/256
        jp z,nowhere ;buffer overflow
         ld a,1
findgrass_nooverflow
        ex af,af' ;'
        jr z,findgrass_empty
        ex af,af' ;'
        ld (ix),a
        inc ix
        ld a,hx
        cp (grassbuf+grassbufsz)/256
        jp z,nowhere ;buffer overflow
        xor a
        ex af,af' ;'
findgrass_empty
        djnz findgrass1
       pop hl
       pop bc
        rrc c
        rrc c
        jr nc,findgrass_columns0
        inc hl
        djnz findgrass_columns0
        ld (ix),b;0 ;иначе в последнем столбце может появиться лажа
        ret

MakeMaskFromMap
;FIXME в случае неполной маски (нужна защита от влетания в стену на краю карты - надо полную маску или при любой порче ландшафта крайний левый пикс маски формировать из 5 левых пикс, справа аналогично?)
;x в маске считается для центра червя, x=0 соответствует x=4 в карте
;то есть берём байт маски из карты так: ----M-M- M-M-m-m- m-m-----
        LD HL,MAP;+1
        LD DE,MASK;MASKBUF
        LD B,MASKHGT;88
MKMAP41 PUSH BC
       ld a,PGMAP
       call OUTME
       push de
       ld de,MKMASKBUF
        LD B,MASKWID
MKMAP42 LD A,(HL)
         RLA 
         RLA 
         RLA 
         RLA 
        DUP 2
        RLA 
        RLA 
        RL C
        EDUP 
        INC HL
        LD A,(HL)
        DUP 4
        RLA 
        RLA 
        RL C
        EDUP 
        INC HL
        LD A,(HL)
        DUP 2
        RLA 
        RLA 
        RL C
        EDUP 
        LD A,C
        LD (DE),A
        INC DE
        DJNZ MKMAP42       
       call SetPgMask
       pop de
       push hl
       ld hl,MKMASKBUF
       ld bc,MASKWID
       ldir
       pop hl        
        LD bc,(MAPWID-MASKWID)*2
        ADD HL,BC
        POP BC
        DJNZ MKMAP41
;extra bottom line of mask is always filled (for element placement)
        LD HL,MASKSZ+MASK;MASKBUF
        LD BC,MASKWID*256+255
        LD (HL),C
        INC HL
        DJNZ $-2
        ret

TexturizeGroundInMap
       ld a,PGMAP
       call OUTME
        LD HL,MAP
        LD DE,MAPWID
        ld bc,texture
        ld lx,MAPWID
MkMapTex0 PUSH BC
        PUSH HL
MkMapTex1 LD A,(BC)
        AND (HL)
        LD (HL),A
        LD A,C
        inc a
        xor c
        and 0x7f
        xor c
        LD C,A
        ADD HL,DE
        JR NC,MkMapTex1
        POP HL
        INC L
        POP BC
        ld a,c
        add a,128
        ld c,a
        jr nc,MkMapTex0ok
        inc b
        ld a,b
        cp texture/256+8
        jr c,MkMapTex0ok
        ld b,texture/256
MkMapTex0ok
        dec lx
        jr NZ,MkMapTex0
        ret

AddGrassInMap
       LD A,PGMAP;16
       CALL OUTME
        ld ix,grassbuf
        ld de,MAPWID
        ld hl,MAP
        ld c,0xc0 ;2 bits >>2 every time
        ld b,MAPWID
        xor a ;RLE counter
        ex af,af' ;'
addgrass_columns0
        ld a,c
        ld (addgrassmask),a
       push bc
       push hl
        ld b,MAPHGT-1
addgrass0
        add hl,de
        ex af,af' ;'
addgrass_noadd1
        inc a
        cp (ix)
        jr nz,addgrass_noadd
        inc ix
         or a
         jr z,addgrass_noadd1 ;0=просто пропуск 255 пикс
     push bc
     push hl
        LD bc,sprgrass
addgrass1
        ld a,(bc)
        or a
        jr z,addgrass1q
addgrassmask=$+1
        and 0
        or (hl)
        ld (hl),a
        add hl,de
        jr c,addgrass1q ;end of column
        inc bc
        jr addgrass1
addgrass1q
     pop hl
     pop bc
        xor a
addgrass_noadd
        ex af,af' ;'
        djnz addgrass0
       pop hl
       pop bc
        rrc c
        rrc c
        jr nc,addgrass_columns0
        inc hl
        djnz addgrass_columns0
        ret

sprgrass
        DB #29,-1,#DB,#7E,#D5,#AA,0
      ;DB #52,-1,#BF,-4,#AB,#55,0

PRLMNerror
        INC C ;don't fit, next x
       POP DE
        LD A,C
        CP MASKWID-5 ;ширина элемента не более 10 знакомест
        jp C,PRLMN00
;       pop de
       pop af
;        scf
        ret

PRLMN
;draw element in map and mask
;c=X (in chr)
;hl=gfx
        LD D,(HL) ;width
        INC HL
        LD E,(HL) ;hgt
        INC HL

       call SetPgMask
        
       PUSH HL ;gfx
PRLMN00
        LD HL,MASK+(MASKWID*(MAPHGT-TERRAINHGT));MASKBUF+(MASKWID*(MAPHGT-TERRAINHGT))
        XOR A
        LD B,A
        ADD HL,BC ;+x
        LD B,E ;hgt
       PUSH DE
        LD DE,MASKWID
;есть ли достаточная высота неба под элемент?
        OR (HL)
        ADD HL,DE
        DJNZ $-2
        jr NZ,PRLMNerror ;don't fit, next x
;ищем грунт (он точно есть, мы в маске сделали лишнюю залитую строку)
         INC B
         OR (HL)
         ADD HL,DE
        JR Z,$-3
       POP DE
        LD A,D ;wid
        DEC A
        RRA 
        NEG 
        ADD A,C
        LD C,A ;x
       ld a,b
       add a,MAPHGT-TERRAINHGT
       ld b,a ;y
;PGMASK уже включено
;b=y
;c=x
;d=width
;e=hgt
       POP HL ;gfx

     PUSH BC ;c=x
        XOR A
        OR B ;y
        PUSH HL ;gfx
        PUSH DE ;width,hgt
        LD HL,MASK;MASKBUF
        LD DE,MASKWID
        JR Z,$+5
        ADD HL,DE
        DJNZ $-1 ;hl=MASK+(y*MASKWID)
        ADD HL,BC ;hl=MASK+(y*MASKWID)+x
        POP BC ;width,hgt
        POP DE ;gfx
;hl=MASK+
;de=gfx
;b=width
;c=hgt
PRLMNmask1
        PUSH BC
        PUSH HL
         xor a
         ld c,a
PRLMNmask2
        LD A,(DE)
         rra
         rl c
         rra
         rr c
         push af
        OR (HL)
        LD (HL),A
        INC HL
        INC DE
         pop af
        DJNZ PRLMNmask2
         ld a,0
         rra
         rl c
         rra
         OR (HL)
         LD (HL),A         
        POP HL
        LD C,MASKWID
        ADD HL,BC
        POP BC
        DEC C
        JR NZ,PRLMNmask1       
        ex de,hl
      LD D,(HL) ;width
      INC HL
      LD E,(HL) ;hgt
      INC HL
    POP BC ;yx
    PUSH BC ;yx
        XOR A
        OR B ;y
        PUSH HL ;gfx
        PUSH DE ;width,hgt
        LD HL,MAP;+(MAPWID*(MAPHGT-TERRAINHGT));#C000
        LD DE,MAPWID*2
        JR Z,$+5
        ADD HL,DE
        DJNZ $-1
        ADD HL,BC
        ADD HL,BC ;hl=MAP+(y*MAPWID*2)+(x*2)
       LD A,PGMAP;16
       CALL OUTME
        POP BC ;width,hgt
        POP DE ;gfx
PRLMN2  PUSH BC
        PUSH HL
        LD A,(DE)
        INC HL
        OR (HL)
        LD (HL),A
        INC DE
        DJNZ $-5
        POP HL
        LD C,MAPWID
        ADD HL,BC
        POP BC
        DEC C
        JR NZ,PRLMN2
;de=end of gfx
        ex de,hl ;hl=end of gfx
        LD A,B ;width
     POP BC ;c=x
        ADD A,C
        LD C,A ;update x (чтобы не лепить объекты совсем рядом)
       ;or a ;NC
        RET 

CopyLMNGfx ;копируем графику выбранных элементов в LMNGFX (не более LMNGFXSZ)
;нужно только для 48/128, а на АТМ будет выводиться непосредственно из LMNS
;TODO с распаковкой? или добавить распаковку при использовании?
       ld a,PGLMN
       call OUTME
     ld a,(LMNS)
LMNSfirstbyte=$+1
     cp 0x81
     ret nz;jr nz,MKMAP_copyLMNbug ;48K повтор карты - используем элементы, которые успели спасти в экране (при послеигровой генерации в экране лежит 0)
        ld hl,LMNlist ;впритык к концу параграфа
        ld de,LMNGFX
copyLMN0
      ld (copyLMN_lastgood),de
        ld a,(hl)
       push hl
        scf
        rla ;a=N*2+1
        LD HL,LMNS
copyLMNfind0
        LD c,(HL)
        INC HL
        LD b,(HL) ;size in bytes
        INC HL
        DEC A
        JR Z,copyLMNfindq
        ADD HL,bc
        JR copyLMNfind0
copyLMNfindq
       push hl
       ld h,d
       ld l,e
       add hl,bc
       ld a,h
       cp (LMNGFX+LMNGFXSZ)/256
       pop hl
       jr nc,copyLMNfail
        ldir
        dec de ;skip 0
        LD c,(HL)
        INC HL
        LD b,(HL) ;size in bytes
        INC HL
       push hl
       ld h,d
       ld l,e
       add hl,bc
       ld a,h
       cp (LMNGFX+LMNGFXSZ)/256
       pop hl
       jr nc,copyLMNfail
        ldir        
        dec de ;skip 0
       pop hl
        inc l
        jr nz,copyLMN0
       jr copyLMNok
copyLMNfail
       pop hl
copyLMN_lastgood=$+1
        ld de,0
copyLMNok
        xor a
        ld (de),a ;end of gfx
;MKMAP_copyLMNbug ;при послеигровой генерации на 48K {0x4000}=0
        ret

       if 0
CheckGroundExist ;проверяем, есть ли земля на ниж. линии (CY=error)
       ld a,PGMAP
       call OUTME ;технически не нужно, т.к. вызывается после MKMAPPP
        LD HL,MAP+((MAPHGT-1)*MAPWID);#FFEF
        LD B,MAPWID
        XOR A
        OR (HL)    ;проверяем, есть ли земля на ниж. линии
        inc HL     ;
        DJNZ $-2   ;
        ret nz
        scf
        ret ;error ;нет земли на ниж. линии
       endif

EorFillInMap
        LD A,PGMAP;16
        CALL OUTME

        LD HL,MAP;#C000
        LD DE,MAPWID
        LD C,E
MKMAPF  PUSH HL
        LD B,MAPHGT
        XOR A
MKMAPF0 XOR (HL)
        LD (HL),A
        ADD HL,DE
        DJNZ MKMAPF0
        POP HL
        INC L
        DEC C
        JR NZ,MKMAPF
        ret
