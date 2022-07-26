DrawMapGfx
        ld hl,1024-(SCRWID*8)-4;-8;maxXwin
        ld de,(MOUSEX)
        xor a
        sbc hl,de
        ex de,hl
        ld bc,SCRHGT-1;maxYwin
        ld hl,(MOUSEY)
        ld h,a;0
        add hl,bc
         ;ld a,h
         ;and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ;ld h,a ;hl=y ;de=x
        call uvscroll_setscroll

        call uvscroll_draw
        call setpgsscr40008000
        xor a
        ld (uvscroll_scrbase-40),a
        ld (uvscroll_scrbase+0x2000-40),a
        ld (uvscroll_scrbase+0x4000-40),a
        ld (uvscroll_scrbase+0x6000-40),a
        jp setpgsmain40008000
        
DrawWater_Amhgt_DEgfx


;TODO

        ret