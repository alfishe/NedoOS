DrawMASK
       LD A,PGMASK
       call OUTME
        ld hl,(MOUSEX)
        ld a,l
        srl h
        rra
        srl h
        rra
        srl h
        rra
        srl h
        rra
        ld de,SCRTOP
        ld hl,MASK
       cp MASKWID-SCRWID
       jr c,$+4
       ld a,MASKWID-SCRWID
        ld c,a
        ld b,0
        add hl,bc
        ld b,MASKHGT;SCRHGT
DrawMASK0
        push bc
        push de
        ld bc,SCRWID
        ldir
        ld bc,MASKWID-SCRWID
        add hl,bc
        pop de
        call DDE
        pop bc
        djnz DrawMASK0
        ret

DrawMapGfx
        ld a,0xfe
        in a,(0xfe)
        rra
        jp nc,DrawMASK

        ld iy,0
        add iy,sp

       LD A,PGMAP;16
       call OUTME
        LD DE,MAPWID
        LD hl,(MOUSEY-1) ;h ;8bit
        ld L,0
        LD B,8
mULH00E ADD HL,HL
        JR NC,$+3
        ADD HL,DE
        DJNZ mULH00E
        LD BC,MAPDO
        ADD HL,BC
        LD BC,(MOUSEX)
        DUP 3
        SRL B
        RR C
        EDUP 
        ADD HL,BC
;HL=mapadr=MAP+MOUSEY*MAPWID+(MOUSEX>3)
          ;^^^^^^^^^^^^^^^^или по табл

;visiblehgt = SCRHGT
        ld de,SCRTOP
        ld b,SCRHGT
;skyhgt = DOMAP-MOUSEY
;if skyhgt>=0 then visiblehgt = visiblehgt-skyhgt; y=skyhgt
        ld a,(MOUSEY)
        sub SKYHGT
        jp nc,DrawMap_nosky
        push af
        push bc
        neg
        ld b,a ;skyhgt
         ;ld a,e
         ;add a,SCRWID-1
         ;ld e,a
         
         push bc
         push de
         push hl
         
         ld hl,skysprlist
         ld de,skysprlist+1
         ld bc,SKYHGT*6-1
         ld (hl),0
         ldir

        ld ix,WORMXY
prskyworms0
        ld a,(ix+5)
        cp SPRLIST_END
        jp z,prskyworms0q
         ld a,(MOUSEY)
         sub (ix+3) ;y
         cpl
         ;add a,7+1 ;c-MOUSEY+7 = 0..SKYHGT+6
         ;cp SKYHGT+7
         add a,4+1 ;с запасом сверху на 4 (не хватило на высоту червя)
         cp SKYHGT+4
        jp nc,prskyworms_skip
        ld l,a
        ld h,0
        ld b,h
        ld c,l
        add hl,hl ;*2
        add hl,bc ;*3
        add hl,hl ;*6
        ld bc,skysprlist-(6*4) ;с запасом сверху на 4 (не хватило на высоту червя)
        add hl,bc
        ex de,hl
        
         ;ld hl,(4+(SCRWID*8))*64 ;x ;XXXXXXXX XXx????? (TODO >>2)
         ld a,(ix+0) ;x
         ld l,(ix+2) ;X ;XXXXXXXX XXx????? (TODO >>2)
         ld h,0
         rla
         adc hl,hl
         rla
         adc hl,hl ;000000XX XXXXXXXX
         ld bc,(MOUSEX)
         or a
         sbc hl,bc
         ld bc,8
         add hl,bc
         ld  c,8*(SCRWID+1)
         or a
         sbc hl,bc
         add hl,bc
         jr nc,prskyworms_skip

         ld a,l ;l = x относительно экрана!!! 0=на знакоместо левее экрана
         rra
         rra
         rra
         and 31
         sub SCRWID+1
         ld (prskywormx),a ;(X/8)-(SCRWID+1) !=0
         
         ld a,l
         and 7
         ld (prskywormrlpatch),a

         ld b,(ix+1) ;sprite HSB
         ld a,(ix) ;sprite LSB
         add a,a
         add a,a
         add a,a
         ld c,a
prskyworm0
         ld a,(bc) ;gfx
         ld l,a
         ld h,0
prskywormrlpatch=$+1
         jr $+2
         dup 7
         add hl,hl
         edup
         ld a,(de) ;X/8-(SCRWID+1) == 0 значит свободно, иначе занято
         or a
prskywormx=$+1
         ld a,0
         jr nz,prskyworm0tryspr2
         ld (de),a
         inc e
         ld a,h
         ld (de),a
         inc e
         ld a,l
         ld (de),a
         inc e
         inc e
         jr z,prskyworms_skip ;выход за пределы skysprlist
         inc e
         jp prskyworm0tryspr2q
prskyworm0tryspr2
         inc e
         inc e
         inc e
         ld (de),a
         inc e
         jr z,prskyworms_skip ;выход за пределы skysprlist
         ld a,h
         ld (de),a
         inc e
         ld a,l
         ld (de),a
prskyworm0tryspr2q
         inc de
         inc c
         ld a,c
         and 7
         jr nz,prskyworm0
         
prskyworms_skip
        ld bc,6
        add ix,bc
         jp prskyworms0
prskyworms0q
         
         pop hl
         pop de
         pop bc
         
         
         ld hl,skysprlist ;80 строк по 6 байт
         
DrawMap_sky0
        push bc
        push de
       push hl
        ld h,d
        ld l,e
        inc de
        ld bc,SCRWID-1
        ld (hl),b;0
        ldir
;TODO надпечатать спрайты (для MEM128=0)
;допустим, уже составлен список, в каких строках что печатать
;система y,x,data16,pnext (без pnext проблема с сортировкой) займёт слишком много места (20*6*8=960)
;поэтому на каждый "y" неба (всего 80) 2 спрайта по 3 байта: (X/8)-(SCRWID+1),data16 (итого 480, плюс запасы сверху и снизу на высоту червя)
       pop hl
       if 1
       ;первый спрайт
        ld a,e ;lineaddr+SCRWID
        add a,(hl) ;(X/8)-(SCRWID+1)
        ld e,a
        inc l
        ld a,(de)
        xor (hl)
        ld (de),a
        inc l
        inc e
        ld a,(de)
        xor (hl)
        ld (de),a
        inc l
       ;второй спрайт
        ld a,e
        or 0x1f ;FIXME - работает только при SCRWID=30!
        add a,(hl) ;(X/8)-(SCRWID+1)
        ld e,a
        inc l
        ld a,(de)
        xor (hl)
        ld (de),a
        inc l
        inc e
        ld a,(de)
        xor (hl)
        ld (de),a
        inc hl
       endif
        
        pop de
        pop bc
        call DDE
        djnz DrawMap_sky0
         ;ld a,e
         ;sub SCRWID-1
         ;ld e,a
        ld hl,MAP
        LD BC,(MOUSEX)
        DUP 3
        SRL B
        RR C
        EDUP 
        ADD HL,BC
        pop bc
        pop af
        add a,b
        ld b,a
DrawMap_nosky

;waterhgt = MOUSEY-waterYwin
;if waterhgt>=0 then visiblehgt = visiblehgt-waterhgt
        ld a,(MOUSEY)
        sub waterYwin
        jr c,DrawMap_nowater
        neg
        add a,b
        ld b,a
DrawMap_nowater

        LD A,(MOUSEX)
        rra
        jp nc,DrawMap_x0246
        rra
        jp nc,DrawMap_x15
        rra
        jp c,DrawMap_x7
        ld a,Tshift/256 ;x=3
DrawMap_x35_a
        inc hl
        inc hl
        push hl
        pop ix
        ld h,a ;shift table
        ld a,b ;hgt
        ld b,d
        ld c,e;LD bc,SCRTOP;SHADOW
MAPOUT0
;ix=mapadr
;sp=mapadr
;hl=tab
;bc=screen
;a=hgt
        ex af,af' ;'
        ld e,(ix-2)
        ld d,(ix-1)
       ld sp,ix
         ld l,e    ;%abcdefgh
       DUP SCRWID/2
        ld a,(hl) ;%defgh000
        ld l,d    ;%ijklmnop
        inc h
        or (hl)   ;%defghijk
        dec h
        ld (bc),a
        inc c
        ld a,(hl) ;%lmnop000
        pop de
        ld l,e    ;%qrstuvwx
        inc h
        or (hl)   ;%lmnopqrs
        dec h
        ld (bc),a
        inc c
       EDUP 
        org $-1
        ld a,c
        sub SCRWID-1
        ld c,a
        inc b
        ld a,b
        and 7
        jr z,MAPOUT0_chr
MAPOUT0_chrq
       ld sp,iy;SPOILSTACK
        LD de,MAPWID
        ADD ix,de
        ex af,af' ;'
        dec a
        jp nz,MAPOUT0
        ;ld sp,iy
        ret
MAPOUT0_chr
        ld a,c
        sub -32
        ld c,a
        sbc a,a
        and -8
        add a,b
        ld b,a
        jp MAPOUT0_chrq

DrawMap_x0
        ;LD de,SCRTOP;SHADOW
DrawMap_x0line
       PUSH bc
       PUSH de
;HL=mapadr
        ld bc,SCRWID-1
        ldir
        ld a,(hl)
        ld (de),a
       POP de
        CALL DDE
        LD bc,MAPWID-SCRWID+1
        ADD HL,bc
       POP bc
        djnz DrawMap_x0line
        ret

DrawMap_x15
        rra
        ld a,Tshift/256+2 ;x=5
        jp c,DrawMap_x35_a
DrawMap_x1
;hl=mapadr
        ld a,b
        ld bc,SCRWID
        add hl,bc
       push de;SCRTOP
        exx
        LD b,a;SCRHGT
       pop de
       ld hl,SCRWID
       add hl,de ;LD hl,SCRTOP+SCRWID;SHADOW
DrawMap_x1line
;hl'=mapadr (end)
;hl=scr (end)
        ld sp,hl
        exx
        ld a,(hl)
        rla
        dec hl
       dup SCRWID/4
        ld b,(hl)
        dec hl
        ld c,(hl)
        dec hl
        ld d,(hl)
        dec hl
        ld e,(hl)
        rl b
        rl c
        rl d
        rl e
        push bc
        push de
        dec hl
       edup
       if (SCRWID/2)&1
        ld b,(hl)
        dec hl
        ld c,(hl)
        rl b
        rl c
        push bc
        dec hl
       endif
        org $-1
        ld bc,MAPWID+SCRWID
        add hl,bc
        exx
        inc h
        ld a,h
        and 7
        jr z,DrawMap_x1line_chr
;DrawMap_x1line_chrq
        dec b
        jp nz,DrawMap_x1line
        ld sp,iy
        ret
DrawMap_x1line_chr
        ld a,l
        sub -32
        ld l,a
        sbc a,a
        and -8
        add a,h
        ld h,a
        dec b
        jp nz,DrawMap_x1line
        ld sp,iy
        ret

DrawMap_x2
;hl=mapadr
        ld a,b
        ld bc,SCRWID
        add hl,bc
       push de;SCRTOP
        exx
        LD b,a;SCRHGT
       pop de
       ld hl,SCRWID
       add hl,de ;LD hl,SCRTOP+SCRWID;SHADOW
DrawMap_x2line
;hl'=mapadr (end)
;hl=scr (end)
        ld sp,hl
        exx
        ld a,(hl)
        rla ;6??????? CY="d7"
        dec hl
       dup SCRWID/4
        ld b,(hl)
        dec hl
        ld c,(hl)
        dec hl
        ld d,(hl)
        dec hl
        ld e,(hl)
        rl b
        rl c
        rl d
        rl e
        rla;ex af,af' ;'
        rl b
        rl c
        rl d
        rl e
        push bc
        push de
        rra;ex af,af' ;'
        dec hl
       edup
        org $-2
       if (SCRWID/2)&1
        rra;ex af,af' ;'
        dec hl
        ld b,(hl)
        dec hl
        ld c,(hl)
        rl b
        rl c
        rla;ex af,af' ;'
        rl b
        rl c
        push bc
       endif
        ld bc,MAPWID+SCRWID
        add hl,bc
        exx
        inc h
        ld a,h
        and 7
        jr z,DrawMap_x2line_chr
;DrawMap_x2line_chrq
        dec b
        jp nz,DrawMap_x2line
        ld sp,iy
        ret
DrawMap_x2line_chr
        ld a,l
        sub -32
        ld l,a
        sbc a,a
        and -8
        add a,h
        ld h,a
        dec b
        jp nz,DrawMap_x2line
        ld sp,iy
        ret

DrawMap_x04
        rra
        jp nc,DrawMap_x0
DrawMap_x4
;если более 5 фреймов отпущены кнопки и мышь, то переходим на DrawMap_x5 (чтобы не мерцало) (TODO по направлению движения на 3 или 5, а при вертикальном движении переприсвоить X?)
       ld a,(nokeytimer) ;счётчик фреймов, где не использовалось управление
       cp 5
       ld a,Tshift/256+2 ;x=5
       jp nc,DrawMap_x35_a
        ex de,hl;LD hl,SCRTOP;SHADOW
        ld ix,3
        add ix,de
DrawMap_x4line
;ix=mapadr
        ld a,(ix-3)
        ld e,(ix-2)
        ld d,(ix-1)
       ld sp,ix ;mapadr+3, de is ready
        ld c,l
       dup SCRWID/2
        ld (hl),e
        rrd ;18t
        inc l
        ld (hl),d
        rrd ;18t
        inc l
        pop de
       edup
        org $-2
       ld sp,iy;SPOILSTACK
       LD de,MAPWID
       add ix,de
        inc h
        ld a,h
        and 7
        jr z,DrawMap_x4line_chr
        ld l,c
;DrawMap_x4line_chrq
        dec b
        jp nz,DrawMap_x4line
        ;ld sp,iy
        ret
DrawMap_x4line_chr
        ld a,c
        sub -32
        ld l,a
        sbc a,a
        and -8
        add a,h
        ld h,a
        dec b
        jp nz,DrawMap_x4line
        ;ld sp,iy
        ret

DrawMap_x0246
        rra
        jp nc,DrawMap_x04
        rra
        jp nc,DrawMap_x2
DrawMap_x6
        ex de,hl;LD hl,SCRTOP;SHADOW
        ld ix,3
        add ix,de
        ld a,b
DrawMap_x6line
;ix=mapadr
        ex af,af' ;'
        ld a,(ix-3)
        ld e,(ix-2)
        ld d,(ix-1)
       ld sp,ix ;mapadr+3, de is ready
        rra ;???????1 CY="d0"
x6line_startcritical=$+1
       dup SCRWID/4
        pop bc
        rr e ;restore: -
        rr d ;restore: -
        rr c ;restore: rl c
        rr b ;restore: rl b:rl c
        rra ;restore: rla:rl b:rl c
        rr e ;restore: rl e:rla:rl b:rl c
        rr d ;restore: rl d:rl e:rla:rl b:rl c
        rr c ;restore: rl c:rl d:rl e:rla:rl b:rl c
        rr b ;restore: rl b:rl c:rl d:rl e:rla:rl b:rl c
        ld (hl),e
        inc l
        ld (hl),d
        inc l
        ld (hl),c
        inc l
        ld (hl),b
        rla ;restore: rra:rl b:rl c:rl d:rl e:rla:rl b:rl c
        inc l ;20+88+28 = 136/4 = 34
        pop de ;restore: -
       edup
        org $-3
       if (SCRWID/2)&1
        rla
        inc l
        pop de ;restore: -
        rr e ;restore: rl e
        rr d ;restore: rl d:rl e
        rra ;restore: rla:rl d:rl e
        rr e ;restore: rl e:rla:rl d:rl e
        rr d ;restore: rl d:rl e:rla:rl d:rl e
        ld (hl),e
        inc l
        ld (hl),d
       endif
       ld sp,iy;SPOILSTACK
x6line_endcritical
       LD de,MAPWID
       add ix,de
        ld a,l
        sub SCRWID-1
        ld l,a
        inc h
        ld a,h
        and 7
        jr z,DrawMap_x6line_chr
;DrawMap_x6line_chrq
        ex af,af' ;'
        dec a
        jp nz,DrawMap_x6line
        ;ld sp,iy
        ret
DrawMap_x6line_chr
        ld a,l
        sub -32
        ld l,a
        sbc a,a
        and -8
        add a,h
        ld h,a
        ex af,af' ;'
        dec a
        jp nz,DrawMap_x6line
        ;ld sp,iy
        ret

       if (SCRWID/2)&1
;after ld (hl)
        nop
        nop
        nop
;after rr d
        rl d
        rl e
        rla
;after rr d
        rl d
        rl e
       endif
       dup SCRWID/4
;after pop de
        jp (hl) ;restore de
;after inc l
        nop
;after rla
        rra
;after ld (hl)
        nop
        nop
        nop
        nop
        nop
        nop
        nop
;after rr b
        rl b
        rl c
        rl d
        rl e
        rla
;after rr b
        rl b
        rl c
        rl d
        rl e
;after pop bc
;for x6line_startcritical
        ret ;restore bc
       edup
x6line_restorede_startcritical=$-1

DrawMap_x7
        ex de,hl;LD hl,SCRTOP;SHADOW
        ld ix,3
        add ix,de
DrawMap_x7line
;ix=mapadr
        ld a,(ix-3)
        ld e,(ix-2)
        ld d,(ix-1)
       ld sp,ix ;mapadr+3, de is ready
        ld c,l
        rra
       dup SCRWID/2
        ld a,e
        rra
        ld (hl),a
        inc l
        ld a,d
        rra
        ld (hl),a
        inc l
        pop de
       edup
        org $-2
       ld sp,iy;SPOILSTACK
       LD de,MAPWID
       add ix,de
        inc h
        ld a,h
        and 7
        jr z,DrawMap_x7line_chr
        ld l,c
;DrawMap_x7line_chrq
        dec b
        jp nz,DrawMap_x7line
        ;ld sp,iy
        ret
DrawMap_x7line_chr
        ld a,c
        sub -32
        ld l,a
        sbc a,a
        and -8
        add a,h
        ld h,a
        dec b
        jp nz,DrawMap_x7line
        ;ld sp,iy
        ret

DrawWater_Amhgt_DEgfx
        ld (DrawWaterSP),sp
       ld c,a ;-32..-1
        and 7
        add a,0x50
        LD H,A
       ld a,c
       and 0x18
       add a,a
       add a,a
       add a,0x1f
       ld l,a
        ;LD L,#7F
PRWAT0  LD A,(DE)
        INC E
        LD C,A
        LD A,(DE)
        LD B,A
       ld a,e
        inc e
       xor e
       and 0xf0
       jr z,$+2+4
         ld a,e
         add a,32
         ld e,a
        
        LD SP,HL
        DUP 15
        PUSH BC
        EDUP 
        ;ld l,0x7e
        ;dup 15
        ;ld (hl),b
        ;dec l
        ;ld (hl),c
        ;dec l
        ;edup
        ;org $-1
       ;ld a,l
       ;sub 30
       ;ld l,a
       ;ld (hl),c
       ;inc l
       ;ld (hl),b ;иначе запарывает 56ff и т.п.
       ;add a,30
       ;ld l,a
       
        INC H
        BIT 3,H
        JR Z,PRWAT0
        res 3,h
        ld a,l
        sub -32
        ld l,a
        jp p,PRWAT0
DrawWaterSP=$+1
        LD SP,0
        RET  

       if 1
DDE
        INC D
        LD A,D
        AND 7
        RET NZ
        LD A,E
        ADD A,32
        LD E,A
        RET C
        LD A,D
        ADD A,-8
        LD D,A
        RET
       endif
       if 0
DBC
        INC B
        LD A,B
        AND 7
        RET NZ
        LD A,C
        ADD A,32
        LD C,A
        RET C
        LD A,B
        ADD A,-8
        LD B,A
        RET 
       endif

        display "drawmapsize=",$-DrawMap,"+0x400 shifts"
