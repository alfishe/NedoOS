       if 0
DrawMASK
        ld e,3+128 ;+128=keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        call getuser_scr_high_cur
        SETPG4000
        ld hl,0x5800
        ld de,0x5801
        ld bc,767
        ld (hl),7
        ldir
        
       call SetPgMask
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
        ld de,0x4000;SCRTOP
        ld hl,MASK
       cp MASKWID-30;SCRWID
       jr c,$+4
       ld a,MASKWID-30;SCRWID
        ld c,a
        ld b,0
        add hl,bc
        ld b,MASKHGT;SCRHGT
DrawMASK0
        push bc
        push de
        ld bc,30;SCRWID
        ldir
        ld bc,MASKWID-30;SCRWID
        add hl,bc
        pop de
        call DDE
        pop bc
        djnz DrawMASK0
        jr $;ret
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

DrawMapGfx
       if 0
        ld a,0xfe
        in a,(0xfe)
        rra
        jp nc,DrawMASK
       endif

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