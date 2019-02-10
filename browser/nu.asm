        
;взять b=R/G/Bmin, hl установить на начало буфера R/G/B:
        ;pop bc ;ld bc,(maxdistaxis) ;b=maxaxis
        ;ld l,0xff&chrbuf
        ;ld a,(Rminmax) ;Rmin
        ;djnz $+2+2+3
        ;ld l,0xff&(chrbuf+8)
        ;ld a,(Gminmax) ;Gmin
        ;djnz $+2+2+3
        ;ld l,0xff&(chrbuf+16)
        ;ld a,(Bminmax) ;Bmin
        ;ld b,a ;b=R/G/Bmin
        ;ld a,c ;c=maxdist
        ;rra
        ;rra
        ; and 0x3f
        ; add a,tmaxdistdiv/256
        ;ld d,a ;d=maxdistdiv

;потом выбираем лучшую ось:
        ;ld de,(Bminmax)
        ld a,d ;Bmax
        sub e ;Bmin
        ld c,a ;maxdist
        ld b,2 ;maxaxis
        pop de ;ld de,(Gminmax)
        ld a,d ;Gmax
        sub e ;Gmin
        cp c ;>=maxdist?
        ld hl,(Bminmaxcolor)
        jr c,$+2+1+1
         ld c,a ;maxdist
         ;dec b ;maxaxis=1
         ld hl,(Gminmaxcolor)
        pop de ;ld de,(Rminmax)
        ld a,d ;Rmax
        sub e ;Rmin
        cp c ;>=maxdist?
        jr c,$+2+4;2
         ;ld b,0 ;maxaxis
         ld hl,(Rminmaxcolor)
        ex de,hl

;потом берём положение рекордных цветов:
        ;pop de ;ld de,(Rminmaxcolor)
        ;djnz $+2+4
        ;ld de,(Gminmaxcolor)
        ;djnz $+2+4
        ;ld de,(Bminmaxcolor)

