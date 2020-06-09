uvscroll_scrbase=0x4000
uvscroll_pushbase=0x8000
uvscroll_callbase=0xc000

;uvscroll_buf256=bgpush_bmpbuf

UVSCROLL_WID=1024
UVSCROLL_HGT=512
UVSCROLL_SCRWID=320
UVSCROLL_SCRHGT=200
UVSCROLL_NPUSHES=UVSCROLL_WID/2/4/2 
UVSCROLL_SCRNPUSHES=UVSCROLL_SCRWID/2/4/2 

UVSCROLL_SCRSTART=uvscroll_scrbase+((UVSCROLL_SCRHGT-1)*40)
UVSCROLL_LINESTEP=-40

UVSCROLL_NCALLPGS=4

UVSCROLL_TEMPSP=tempsp

uvscroll_prepare
;de=filename
        call openstream_file

        ld ix,tpushpgs
        call uvscroll_genpush

        ld ix,tpushpgs+1
        call uvscroll_genpush

        ld ix,tpushpgs+2
        call uvscroll_genpush

        ld ix,tpushpgs+3
        call uvscroll_genpush

;зациклим страницы (UVSCROLL_HGT/64 страниц в каждом слое)
        ld hl,tpushpgs
        ld de,tpushpgs+(UVSCROLL_HGT/64*4)
        ld bc,UVSCROLL_HGT/64*4 ;4*4 ;на высоту экрана
        ldir

        call uvscroll_gencall

        if 1==1
        ;jr $
        call readbmphead_pal

;загрузить графику bmp в ld-push
        ld ix,tpushpgs
        ld hl,uvscroll_pushbase
        ld bc,UVSCROLL_HGT;pushhgt
uvscroll_ldbmp0
        ;ld a,UVSCROLL_WID/8/2
        ld a,512/8/2
        call bgpush_ldbmp_line
        ;ld de,PUSHLINESZ
        ;add hl,de
        inc h
        ld a,h
        cp uvscroll_pushbase/256+64;63
        jr nz,uvscroll_ldbmp0_nonextpg
        ld h,uvscroll_pushbase/256
        ld de,4
        add ix,de
uvscroll_ldbmp0_nonextpg
        dec bc
        ld a,b
        or c
        jr nz,uvscroll_ldbmp0

        endif

        call closestream_file

        ld de,pal;SUMMERPAL
        OS_SETPAL

uvscrollloop0
        ld bc,(xscroll) ;0..511 for 0..1022 pixels
        ld hl,(yscroll) ;0..511
         ld a,h
         and UVSCROLL_HGT/256-1
         ld h,a
        rr b
        adc hl,hl
        ld (allscroll),hl
        ld a,c
        ld (allscroll_lsb),a

        call uvscroll_draw
        call changescrpg ;с этого момента можем видеть, что нарисовали
        
        GET_KEY ;OS_GETKEYNOLANG
        ld a,c ;keynolang
        ;ld (key),a
         jr nz,control_nofocus
control_imer_oldmousecoords=$+1
        ld bc,0
        ld (control_imer_oldmousecoords),de
        ld a,d;b
        sub b;d
        ld d,a
        ld a,e
        sub c
        ld e,a
control_nofocus
        ;ld (control_imer_mousecoordsdelta),de
        ld a,l ;hl=(sysmousebuttons)
        rra
         ret nc ;LMB

        ld c,e
        ld a,e
        rla
        sbc a,a
        ld b,a
        ld hl,(xscroll)
        add hl,bc
        bit 7,h
        jr z,$+5
        ld hl,0
        ld bc,+(UVSCROLL_WID-UVSCROLL_SCRWID)/2
        or a
        sbc hl,bc
        add hl,bc
        jr c,$+4
        ld h,b
        ld l,c
        ld (xscroll),hl
        
        ld c,d
        ld a,d
        rla
        sbc a,a
        ld b,a
        ld hl,(yscroll)
        add hl,bc
        ;bit 7,h
        ;jr z,$+5
        ;ld hl,0
        ;ld de,UVSCROLL_HGT-UVSCROLL_SCRHGT
        ;or a
        ;sbc hl,de
        ;add hl,de
        ;jr c,$+3
        ;ex de,hl
        ld (yscroll),hl
        jr uvscrollloop0



uvscroll_nextgfxpg       
;sp=scr
        exx
        ;ld sp,UVSCROLL_TEMPSP
        inc hl
        inc hl
        inc hl
        inc hl
        ld a,(hl) ;gfx pages
        SETPG32KLOW
        exx
        ld hx,uvscroll_pushbase/256
        jp (ix)

;делаем push для одного слоя
;в каждых 256 байтах такой код:
;ld bc:push bc *UVSCROLL_NPUSHES ;de=0!!!
uvscroll_genpush
        call genpush_newpage ;заказывает страницу, заносит в tpushpgs, a=pg
        SETPG32KLOW
        ld hl,uvscroll_pushbase
        ld bc,UVSCROLL_HGT;pushhgt
uvscroll_genpush0
        push bc
        ld a,h
        cp uvscroll_pushbase/256+64
        call z,uvscroll_genpush_nextpg
        ld b,UVSCROLL_NPUSHES
uvscroll_genpush1
        ld (hl),1 ;ld bc
        inc hl
        ld a,r
        ld (hl),a
        inc hl
        ld a,r
        ld (hl),a
        inc hl
        ld (hl),0xc5 ;push bc
        inc hl
        djnz uvscroll_genpush1
        pop bc
        dec bc
        ld a,b
        or c
        jr nz,uvscroll_genpush0
        ret
uvscroll_genpush_nextpg
        call genpush_newpage ;заказывает страницу, заносит в tpushpgs, a=pg
        push bc
        SETPGPUSHBASE
        pop bc        
        ld hl,uvscroll_pushbase
        ret

;делаем вызывалки (общие для всех слоёв) - надо 3 или 4 страницы

;0xc103/43/83/c3:
;ld sp, ;надо две копии для рисования 0..39 или 1..40 столбцов (sp+1) *2 копии для +0/0x2000
;jp (ix)
;...
;ld-push ;всего их UVSCROLL_NPUSHES
;jp (hl) ;наш патч вместо ld de
;...
;nnnext_i
 ;push bc
;inc hx ;адрес следующего ldpush
;inc h ;адрес следующего nnnext_i
;56t/line * 4 layers

;в последней строке страницы вызывалки (0xffxx) вместо этого:
uvscroll_nnnext_last
         push bc
uvscroll_nnnext_last_sp=$+1
        ld sp,0 ;надо две копии для рисования 0..39 или 1..40 столбцов (sp+1) *2 копии для +0/0x2000 - копии можно разместить в тех же страницах, но с другими L адресами
uvscroll_nnnext_last_pg=$+1
        ld a,0 ;следующая страница вызывалки
        SETPG32KHIGH ;сама себя заменяет!!!
        inc hx ;адрес следующего ldpush
        ld h,uvscroll_callbase/256+1 ;адрес следующего nnnext_i
        jp (ix)
uvscroll_nnnext_last_sz=$-uvscroll_nnnext_last

;в последней строке экрана вместо всего этого:
;jp uvscroll_endofscreen

;после последней строки графики (0xc0xx) вместо ld-push (в любой странице вызывалки!):
;dup UVSCROLL_NPUSHES
;jp uvscroll_nextgfxpg
;nop
;edup

uvscroll_gencall
        ld ix,tcallpgs
        call uvscroll_gencall_newpage ;заказывает страницу, заносит в tpushpgs, a=pg
        SETPG32KHIGH
        ;ld l,0x00
        call uvscroll_gencall_startpage
        ld de,UVSCROLL_SCRSTART+(UVSCROLL_SCRWID/8)        
        ld b,UVSCROLL_SCRHGT;-1
uvscroll_gencall0
        push bc
        ld a,h
        cp uvscroll_callbase/256+0x3f
        jr nz,uvscroll_gencall_nonewpg

        call uvscroll_gencall_newpage ;заказывает страницу, заносит в tpushpgs, a=pg
        push af
        ld (uvscroll_nnnext_last_pg),a
        
        push de
        call uvscroll_gencall_pgend
        inc de
        ld l,0x40
        call uvscroll_gencall_pgend
        dec de
        set 5,d
        ld l,0x80
        call uvscroll_gencall_pgend
        inc de
        ld l,0xc0
        call uvscroll_gencall_pgend
        pop de

        pop af
        SETPG32KHIGH
        call uvscroll_gencall_startpage
        jr uvscroll_gencall_nonewpgq
uvscroll_gencall_nonewpg
        push de
        push hl
        call uvscroll_gencall_nnnext_i
        inc de
        ld l,0x40
        call uvscroll_gencall_nnnext_i
        dec de
        set 5,d
        ld l,0x80
        call uvscroll_gencall_nnnext_i
        inc de
        ld l,0xc0
        call uvscroll_gencall_nnnext_i
        pop hl
        pop de
        inc h
uvscroll_gencall_nonewpgq
        push hl
        ld hl,UVSCROLL_LINESTEP
        add hl,de
        ex de,hl
        pop hl
        pop bc        
        djnz uvscroll_gencall0
        ;ld l,0
uvscroll_gencall_end0
        ld (hl),0xc3 ;jp
        inc l
        ld (hl),uvscroll_endofscreen&0xff
        inc l
        ld (hl),uvscroll_endofscreen/256
        ld a,l
        add a,0x40-2
        ld l,a
        jr nz,uvscroll_gencall_end0
        
;в последней странице (ix-1) не хватает блока pgend
;скопируем его из предыдущей страницы
        ld a,(ix-2)
        SETPG32KHIGH
        ld hl,uvscroll_callbase+0x3f00
        ld de,bgpush_bmpbuf;uvscroll_buf256
        ld bc,256
        push bc
        push de
        push hl
        ldir
        ld a,(ix-1)
        SETPG32KHIGH
        pop de
        pop hl
        pop bc
        ldir
        ret

uvscroll_gencall_pgend
        push de
        push hl
        ex de,hl
        ld (uvscroll_nnnext_last_sp),hl
        ld hl,uvscroll_nnnext_last
        ld bc,uvscroll_nnnext_last_sz
        ldir
        pop hl
        pop de
        ret

uvscroll_gencall_startpage
        ld hl,0xc000
uvscroll_gencall_nextgfxpg0
        ld (hl),0xc3 ;jp
        inc l
        ld (hl),uvscroll_nextgfxpg&0xff
        inc l
        ld (hl),uvscroll_nextgfxpg/256
        inc l
        inc l
        jr nz,uvscroll_gencall_nextgfxpg0
        inc h
        ret

uvscroll_gencall_nnnext_i
         ld (hl),0xc5 ;push bc
         inc hl
        ld (hl),0xdd
        inc hl
        ld (hl),0x24 ;inc hx
        inc hl
        ld (hl),0x24 ;inc h
        inc hl
        ld (hl),0x31 ;ld sp
        inc hl
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        ld (hl),0xdd
        inc hl
        ld (hl),0xe9 ;jp (ix)
        ret

uvscroll_gencall_newpage
;заказывает страницу, заносит в tcallpgs, a=pg
        push bc
        push de
        push hl
        push ix
        OS_NEWPAGE
        pop ix
        ld a,e
        ld (ix),a
        inc ix
        pop hl
        pop de
        pop bc
        ret


uvscroll_draw
        ld hy,0xc1
        call setpgscrlow4000
        ld a,4 ;layer 0..3 + 4
        call uvscroll_drawlayer
        call setpgscrhigh4000
        ld a,5 ;layer 0..3 + 4
        call uvscroll_drawlayer
        call setpgscrlow4000
        ld a,6 ;layer 0..3 + 4
        call uvscroll_drawlayer
        call setpgscrhigh4000
        ld a,7 ;layer 0..3 + 4
uvscroll_drawlayer
        push af
        call uvscroll_patch
        pop af
        push af
        call uvscroll_callpp
        pop af
        ;jp uvscroll_unpatch
uvscroll_unpatch
        ;ld d,0x01 ;d=unpatch byte ld bc
        ld d,0xc5 ;d=unpatch byte push bc
        jr uvscroll_patch_d

uvscroll_patch
;a=layer 0..3 + 4
        ld d,0xe9 ;d=patch byte jp (hl)
uvscroll_patch_d
        ;ld bc,(xscroll) ;0..511 for 0..1022 pixels
        ;ld hl,(yscroll) ;0..511
        ;rr b
        ;adc hl,hl
allscroll=$+1
        ld hl,0
allscroll_lsb=$+1
        add a,0 ;ld c,0
;hlc = allscroll = yscroll*512+xscroll
        ;add a,c
        ld c,a
          jr nc,$+3
          inc hl
         ld e,l ;yscroll*2
        add hl,hl
         rr e ;yscroll (corrected для зацикливания)
         rra
         and 0xfc
         cpl
         ld l,a ;a=0xff-(((xscroll+layer+4)/2)&0xfc)
         ld a,h
         rla
         rla ;a=(xscroll+layer)&3 + ((yscroll/64)*4)
         xor c
         and 0xfc
         xor c
        exx
        ld hl,tpushpgs
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        SETPG32KHIGH
        exx ;hl'=список страниц графики =f((xscroll+layer)&3 + ((yscroll/64)*4))
         ld a,e ;yscroll (corrected для зацикливания)
        or 0xc0
        ld h,a
        add a,UVSCROLL_SCRHGT
        ld e,a
;конец (крайнее правое положение L при вызове, т.е. xscroll=0) = 256-(UVSCROLL_SCRNPUSHES*4)
;адрес входа графики: конец - ((xscroll+layer+4)/2&0xfc)
;d=patch byte
;e=число оставшихся строк патча
;h=0xc0+(yscroll&63)
;l=f(xscroll+layer) ;L = адрес патча выхода = адрес входа графики + (UVSCROLL_SCRNPUSHES*4)-1
;hl'=список страниц графики =f((xscroll+layer)&3 + ((yscroll/64)*4))
        ;ld e,UVSCROLL_SCRHGT
        ;ld a,h
        sub 0xff&(0xc0+UVSCROLL_SCRHGT)
        add a,a ;a=0..64*2
        ld (uvscroll_patcher_patch0),a
uvscroll_patcher_patch0=$+1
        call uvscroll_patcher
uvscroll_patcher0
        exx
        inc hl
        inc hl
        inc hl
        inc hl
        ld a,(hl)
        SETPG32KHIGH
        exx
        ld h,0xc0
        ld a,e
        add a,h
        jr nc,uvscroll_patcher0q ;a=-64..-1 = Npatchinlastpg-0x40
        ld e,a
        call uvscroll_patcher
        jp uvscroll_patcher0
uvscroll_patcher0q
        cpl ;a=0..63 for Npatchinlastpg=64..1
        add a,a
        ld (uvscroll_patcher_patch1),a
uvscroll_patcher_patch1=$+1
        jp uvscroll_patcher




uvscroll_callpp
;a=layer 0..3 + 4
         push af ;a=layer 0..3 + 4

        ;ld hl,(allscroll)
        ld hl,allscroll_lsb
        ;ld c,(hl)
         add a,+(UVSCROLL_SCRNPUSHES-1)*8
;hlc = allscroll = yscroll*512+xscroll
        add a,(hl);c
        ld c,a
          ld hl,(allscroll)
          jr nc,$+3
          inc hl
         ld e,l ;yscroll*2
        add hl,hl
         rr e ;yscroll (corrected для зацикливания)
         rra
         cpl
          ld b,a
         and 0xfc
         ld lx,a ;a=0xfc-(((xscroll+layer+4+((UVSCROLL_SCRNPUSHES-1)*8))/2)&0xfc)
         ld a,h
         rla
         rla ;a=(xscroll+layer)&3 + ((yscroll/64)*4)
         xor c
         and 0xfc
         xor c
        exx
        ld hl,tpushpgs
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl) ;gfx pages
        SETPG32KLOW
      ld a,(tcallpgs)
      SETPG32KHIGH
        exx
        ld a,e ;yscroll (corrected для зацикливания)
        and 63
        add a,0x80
        ld hx,a
         pop af ;a=layer 0..3 + 4
         push af
         rrca
         rrca
         and 0x80;0xc0
         ld l,a ;L=(layer&2)*0x80
         ld a,b ;a=~((xscroll+layer+4)/2)
         and 4/2 ;если не 0, то на выходе подрисовка левого столбца
         rrca
         rrca
         rrca
         add a,l
         ld l,a ;L=(layer&2)*0x80 + ((xscroll+layer)&4)/4*0x40
;конец (крайнее правое положение L при вызове, т.е. xscroll=0) = 256-(UVSCROLL_SCRNPUSHES*4)
;адрес входа графики: конец - ((xscroll+layer+4)/2&0xfc)
         add a,4
         ld ly,a
        ld de,0 ;for interrupt
        ld h,0xc2
        ld (uvscroll_endofscreen_sp),sp
        jp (iy);0xc104 + (N*0x40)
uvscroll_endofscreen
         push bc
uvscroll_endofscreen_sp=$+1
        ld sp,0
         pop af ;layer+4
         ld c,ly
         bit 6,c
        ret z
;TODO подрисовка левого столбца (а если UVSCROLL_SCRWID<320, то и затирание правого)
        if 1==0
        ld hl,UVSCROLL_SCRSTART
         bit 7,c
         jr z,$+4
         set 5,h
        ld de,UVSCROLL_LINESTEP
        xor a
        dup UVSCROLL_SCRHGT-1
        ld (hl),a
        add hl,de
        edup
        ld (hl),a
        ret
        
        else
;uvscroll_drawcolumn
;a=layer 0..3 + 4
       if 1==0
        ld hl,(xscroll) ;0..511 for 0..1022 pixels
        add a,l
        ld l,a
        adc a,h
        sub l
        rra        
        ld a,l
        rr l ;l=(xscroll+layer+4)/2
        exx
        ld hl,(yscroll) ;0..511
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;h=yscroll/16
        xor h
        and 3
        xor h ;a=(xscroll+layer)&3 + ((yscroll/64)*4)
        ld hl,tpushpgs
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        exx ;hl'=список страниц графики =f((xscroll+layer)&3 + ((yscroll/64)*4))
        ld a,(yscroll) ;0..511
        and 63
        add a,0xc0
        ld h,a
        ld a,l
        and 0xfc       
        cpl
         add a,3 ;add a,+(UVSCROLL_SCRNPUSHES*4)-1 ;адрес байта графики H
        ld l,a
       else 
        ;ld hl,(allscroll)
        ld hl,allscroll_lsb
        ;ld c,(hl)
         sub 8
;hlc = allscroll = yscroll*512+xscroll
        add a,(hl);c
        ld c,a
          ld hl,(allscroll)
          jr c,$+3
          inc hl
         ld e,l ;yscroll*2
        add hl,hl
         rr e ;yscroll (corrected для зацикливания)
         rra
         and 0xfc
         cpl
          dec a ;адрес байта графики H
         ld l,a ;a=0xff-(((xscroll+layer+4)/2)&0xfc)
         ld a,h
         rla
         rla ;a=(xscroll+layer)&3 + ((yscroll/64)*4)
         xor c
         and 0xfc
         xor c
        exx
        ld hl,tpushpgs
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        SETPG32KHIGH
        exx ;hl'=список страниц графики =f((xscroll+layer)&3 + ((yscroll/64)*4))
         ld a,e ;yscroll (corrected для зацикливания)
        or 0xc0
        ld h,a
       endif        
;конец (крайнее правое положение L при вызове, т.е. xscroll=0) = 256-(UVSCROLL_SCRNPUSHES*4)
;адрес входа графики: конец - ((xscroll+layer+4)/2&0xfc)
;d=patch byte
;h=0x80+(yscroll&63)
;l=f(xscroll+layer) ;L = адрес патча выхода = адрес входа графики + (UVSCROLL_SCRNPUSHES*4)-1
;hl'=список страниц графики =f((xscroll+layer)&3 + ((yscroll/64)*4))
        add a,UVSCROLL_SCRHGT
        ld lx,a
         ex de,hl
         ld hl,UVSCROLL_SCRSTART
         ld a,ly
         bit 7,a
         jr z,$+4
         set 5,h
        ld a,d;h
        ;sub 0xc0
        add a,a ;a=0..64*2
        add a,a
        ld (uvscroll_columndrawer_patch0),a
        ld bc,UVSCROLL_LINESTEP
uvscroll_columndrawer_patch0=$+1
        call uvscroll_columndrawer
        add hl,bc
uvscroll_columndrawer0
        exx
        inc hl
        inc hl
        inc hl
        inc hl
        ld a,(hl)
        SETPG32KHIGH
        exx
        ld d,0xc0;h,0xc0
        ld a,lx
        add a,d;h
        jr nc,uvscroll_columndrawer0q ;a=-64..-1 = Nlinesinlastpg-0x40
        ld lx,a
        ;ld bc,UVSCROLL_LINESTEP
        call uvscroll_columndrawer
        add hl,bc
        jp uvscroll_columndrawer0
uvscroll_columndrawer0q
        cpl ;a=0..63 for Nlinesinlastpg=64..1
        add a,a
        add a,a
        ld (uvscroll_columndrawer_patch1),a
        ;ld bc,UVSCROLL_LINESTEP
uvscroll_columndrawer_patch1=$+1
        jp uvscroll_columndrawer
        endif


tcallpgs
        ds UVSCROLL_NCALLPGS

        display "xscroll=",xscroll
xscroll
        dw +(UVSCROLL_WID-UVSCROLL_SCRWID)/2;0
yscroll
        dw 0

        align 256
uvscroll_patcher
        dup 63
        ld (hl),d
        inc h
        edup
        ld (hl),d
        ret

        align 256
uvscroll_columndrawer
        dup 63
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
        edup
        ld a,(de)
        ld (hl),a
        ret


