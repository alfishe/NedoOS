DrawMapGfx

;TODO
        ld hl,maxXwin
        ld de,(MOUSEX)
        or a
        sbc hl,de
        ex de,hl
        ld hl,maxYwin
        ld a,(MOUSEY)
        ld c,a
        ld b,0
        or a
        add hl,bc
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a
;hl=y
;de=x
        call uvscroll_setscroll

        ;jr $
        ;di
        call uvscroll_draw
        ;ei
        ;halt
        ;halt

        ret
        
DrawWater_Amhgt_DEgfx


;TODO

        ret