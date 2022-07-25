;процедуры для генерации карты, нижнего уровня (зависят от типа экрана)

ClearMap
        ld hl,tpushpgs +SKIPPGS ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        ld b,16
ClearMap0
        push bc
        push hl
        ld a,(hl)
        SETPGC000
        ld hl,0xc000
        xor a
ClearMap1
        inc l
        ld (hl),a
        inc l
        ld (hl),a
        inc l
        inc l ;skip push
        jr nz,ClearMap1
        inc h
        jr nz,ClearMap1
        pop hl
        pop bc
        inc hl
        djnz ClearMap0
        ret

MapNextColumn

;TODO

        ret

MapNextPg

;TODO

        ld h,0xc0
        ret

FindPlacesForGrass ;записывает в grassbuf
;TODO

        ret
       ld a,PGMAP
       call OUTME
;по чётным столбцам сверху вниз ищем переходы 0->1
        ld ix,grassbuf
        ld hl,MAP
        ld bc,MAPWID*4
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
        inc h
        call z,MapNextPg
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
        call MapNextColumn
        dec bc
        ld a,b
        or c
        jr nz,findgrass_columns0
        ld (ix),b;0 ;иначе в последнем столбце может появиться лажа
        ret

MakeMaskFromMap
;FIXME в случае неполной маски (нужна защита от влетания в стену на краю карты - надо полную маску или при любой порче ландшафта крайний левый пикс маски формировать из 5 левых пикс, справа аналогично?)
;x в маске считается для центра червя, x=0 соответствует x=4 в карте
;то есть берём байт маски из карты так: ----M-M- M-M-m-m- m-m-----

;TODO

       ld a,PGMAP
       call OUTME

       call SetPgMask
        ld hl,MASK
        ld de,MASK+1
        ld bc,MASKSZ-1
        ld (hl),0
        ldir

        LD HL,MASKSZ+MASK-(MASKWID*2) ;fill last lines (костыль, пока карты нет)
        LD BC,+(MASKWID*2)*256+255
        LD (HL),C
        INC HL
        DJNZ $-2
       
;extra bottom line of mask is always filled (for element placement)
        LD HL,MASKSZ+MASK
        LD BC,MASKWID*256+255
        LD (HL),C
        INC HL
        DJNZ $-2
        ret

TexturizeGroundInMap
        call SetPgTexture8000
        ld de,0x8000
        ld c,0xfd
TexturizeGroundInMap0
        call TexturizeGroundInMappp4
        inc c
        call TexturizeGroundInMappp4
        ld a,c
        sub 5
        ld c,a
        jr nc,TexturizeGroundInMap0
        call setpgsmain40008000
        ret

TexturizeGroundInMappp4        
        ld hl,tpushpgs +SKIPPGS+12 ;первая страница 0 слоя, первая страница 1 слоя, первая страница 2 слоя, первая страница 3 слоя, вторая страница 0 слоя...
        call TexturizeGroundInMappp
        inc l
        call TexturizeGroundInMappp
        inc l
        call TexturizeGroundInMappp
        inc l
        ;call TexturizeGroundInMappp
TexturizeGroundInMappp
;hl=tpushpgs+
;c="l"
;de=gfx
        push hl
        ld b,4
TexturizeGround0
        push bc
        push hl
        ld a,(hl)
        ld h,0xff
        ld l,c
        SETPGC000
       push de
        ld b,64
TexturizeGround1
        ld a,(de)
        inc e
        and (hl)
        ld (hl),a
        dec h
        djnz TexturizeGround1
        ld a,e
       pop de
        xor e
        and 0x7f
        xor e
        ld e,a
        pop hl
        pop bc
        dec l
        dec l
        dec l
        dec l
        djnz TexturizeGround0
        ld hl,128
        add hl,de
        ex de,hl
        pop hl
        res 5,d
        ret

AddGrassInMap

;TODO

        ret

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
;b=N
       push bc
       ld a,PGLMN
       call OUTME
       pop bc

        ld a,b
        SCF 
        rla ;a=N*2+1
        LD HL,LMNS
PRLMN0  LD E,(HL)
        INC HL
        LD D,(HL) ;size in bytes
        INC HL
        DEC A
        JR Z,PRLMNO
        ADD HL,DE
        JR PRLMN0
PRLMNO
        LD D,(HL) ;width
        INC HL
        LD E,(HL) ;hgt
        INC HL

       call SetPgMask
        

;TODO

        ret ;FIXME
        
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
       POP BC
       PUSH BC
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
        
;TODO
        
       LD A,PGMAP;16
       CALL OUTME
        POP BC ;width,hgt
        POP DE ;gfx
        
;TODO
              
        
        
        LD A,B ;width
     POP BC ;c=x
        ADD A,C
        LD C,A ;update x (чтобы не лепить объекты совсем рядом)
       ;or a ;NC
        RET 

CheckGroundExist ;проверяем, есть ли земля на ниж. линии (CY=error)

;TODO
        xor a
        inc a

        ret nz
        scf
        ret ;error ;нет земли на ниж. линии
