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

       ;call drawtiles_hor

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
        ld a,c;e
        sub e;c
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
        ;bit 7,h
        ;jr z,$+5
        ;ld hl,0
        ;ld bc,+(UVSCROLL_WID-UVSCROLL_SCRWID)/2
        ;or a
        ;sbc hl,bc
        ;add hl,bc
        ;jr c,$+4
        ;ld h,b
        ;ld l,c
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



uvscroll_suddennextgfxpg
;если вошли в ловушку в середине строки
;sp=scr(line end)-... (но точно не line start)
        exx
        ;ld sp,UVSCROLL_TEMPSP ;для поля уже экрана? но SETPG и IMER займут только два слова стека - вылет на одно слово, всё равно что штатно
        inc hl
        inc hl
        inc hl
        inc hl
        ld a,(hl) ;gfx pages
        SETPG32KLOW
        exx
        ld hx,uvscroll_pushbase/256-1
        jp uvscroll_pushbase;(ix)

uvscroll_nextgfxpg
;если вошли в ловушку вместо начала строки
;sp=scr(line end)
        exx
        ;ld sp,UVSCROLL_TEMPSP ;обязательно для поля уже экрана!
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
        ld (hl),0xfd;0xc3 ;jp (iy)
        inc l
        ld (hl),0xe9;uvscroll_nextgfxpg&0xff
        inc l
        ;ld (hl),uvscroll_nextgfxpg/256
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
        ld a,7;4 ;layer 0..3 + 4
        call uvscroll_drawlayer
        call setpgscrhigh4000
        ld a,6;5 ;layer 0..3 + 4
        call uvscroll_drawlayer
        call setpgscrlow4000
        ld a,5;6 ;layer 0..3 + 4
        call uvscroll_drawlayer
        call setpgscrhigh4000
        ld a,4;7 ;layer 0..3 + 4
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
         ;jr $
        ;ld bc,(xscroll) ;0..511 for 0..1022 pixels
        ;ld hl,(yscroll) ;0..511
        ;rr b
        ;adc hl,hl
allscroll=$+1
        ld hl,0
         add a,+(UVSCROLL_SCRNPUSHES-1)*8
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
         or 3 ;and 0xfc
         ;cpl
         ld l,a ;a=0xff-(((xscroll+layer+4)/2)&0xfc)
         ld a,h
         rla
         rla ;a=(xscroll+layer)&3 + ((yscroll/64)*4)
         xor c
         and 0xfc
         xor c
          xor 3
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
         ;add a,+(UVSCROLL_SCRNPUSHES-1)*8
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
         ;cpl
          ld b,a
         and 0xfc
         ld lx,a ;a=0xfc-(((xscroll+layer+4+((UVSCROLL_SCRNPUSHES-1)*8))/2)&0xfc)
         
        if 1==1
        ;ld hl,(xscroll)
        ;ld bc,+(UVSCROLL_WID-UVSCROLL_SCRWID)/2+1
        ;or a
        ;sbc hl,bc
        cp 0x100-(UVSCROLL_SCRNPUSHES*4-1)
        ld iy,uvscroll_nextgfxpg
        jr c,uvscroll_callpp_noxcycled
        ld iy,uvscroll_suddennextgfxpg
uvscroll_callpp_noxcycled
        endif
         
         ld a,h
         rla
         rla ;a=(xscroll+layer)&3 + ((yscroll/64)*4)
         xor c
         and 0xfc
         xor c
          xor 3
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
          cpl
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
         push af
         ld (uvscroll_callpp_jp),a

        ld de,0 ;for interrupt
        ld h,0xc2
        ld (uvscroll_endofscreen_sp),sp
        ;jp (iy);0xc104 + (N*0x40)
         ;jr $
uvscroll_callpp_jp=$+1
        jp 0xc104 ;ld sp:jp (ix)
uvscroll_endofscreen
         push bc
uvscroll_endofscreen_sp=$+1
        ld sp,0
         pop bc;ld b,ly
         pop af ;layer+4
         bit 6,b
        ret z
;TODO подрисовка левого столбца (а если UVSCROLL_SCRWID<320, то и затирание правого)
        if 1==0
        ld hl,UVSCROLL_SCRSTART
         bit 7,b
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
        ;ld hl,(allscroll)
        ld hl,allscroll_lsb
        ;ld c,(hl)
         add a,+(UVSCROLL_SCRNPUSHES-0)*8
         ;sub 8
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
         or 3 ;and 0xfc
         ;cpl
          dec a ;адрес байта графики H
         ld l,a ;a=0xff-(((xscroll+layer+4)/2)&0xfc)
         ld a,h
         rla
         rla ;a=(xscroll+layer)&3 + ((yscroll/64)*4)
         xor c
         and 0xfc
         xor c
          xor 3
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
         ;ld b,ly
         bit 7,b
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

;256x64 tiles = 2048x512 pixels = мало!!! сразу пересчитывать из метатайлов?
;нужна текущая карта метатайлов (также для коллизий) 21x14
;её можно двигать прямо ldir, время пренебрежимо малое (для сравнения, карта тайлов 41x26 = 17056 тактов ldi, т.е. 5% от отрисовки)
;или пока обойдёмся тайлами?

        macro DRAWTILELAYERDOWN
        dup 7
        ld a,(bc)
        ld (de),a
        inc b
        inc d
        edup
        ld a,(bc)
        ld (de),a
        endm

        macro DRAWTILELAYERUP
        dup 7
        ld a,(bc)
        ld (de),a
        dec b
        dec d
        edup
        ld a,(bc)
        ld (de),a
        endm

drawtiles_ver
;8x8
;рисуем всегда с ровного X/8, а Y может пересекать страницу
;может понадобиться отрисовать 26 тайлов по вертикали
;TODO
        ret
drawtiles_hor
;8x8
;рисуем всегда с ровного X/8, а Y может пересекать страницу
;может понадобиться отрисовать 41 тайл по горизонтали
;большая карта может состоять из нескольких зон с разной tilegfx
;одна отрисовка должна быть в рамках одной tilegfx
;так что выводим 48 тайлов по горизонтали всегда? тогда можно и X всегда привязанный к целому push (ровный X/16), и весь блок из 8 тайлов не вылетит за сегмент (ровный X/64)
;при экране 39x23 знакомест выводим 40 тайлов по горизонтали и 24 по вертикали (выгода 20%)
        ld a,(pgtilegfx) ;TODO по зоне
        SETPG32KHIGH

;сейчас выводит в правом нижнем углу, за границей экрана (может попасть на 6 пикс в экран по X, но по Y за экраном)
        ld hl,(allscroll)
        ld bc,(allscroll_lsb)
        
        ;ld a,4
;a=layer 0..3 + 4
         ;add a,+(UVSCROLL_SCRNPUSHES-0)*8
;hlc = allyx = y*512+x
        ;add a,c
        ;ld c,a
       ld a,c
       and 0xe0
       ld c,a
          ;jr nc,$+3
          ;inc hl
         ld e,l ;y*2
        add hl,hl
         rr e ;y (corrected для зацикливания)
         rra
         or 3 ;and 0xfc ;a=0xff-(((x+layer+4)/2)&0xfc)
          sub 2 ;адрес байта графики L
         ld l,a
         ld a,h
         add a,a
         add a,a ;a=((y/64)*4)
         ;xor c
         ;and 0xfc
         ;xor c
         ;xor 3
        ld c,a
        ld b,0
        ld ix,tpushpgs
        add ix,bc ;ix=список страниц графики =f((x+layer)&3 + ((y/64)*4))
         ld a,e ;y (corrected для зацикливания)
        and 0x3f
        add a,0x40
        ld h,a
        ex de,hl

;ix=tpushpgs+(Y/64*4)+layer
;TODO hl=tilemap+ (c000)
        ld hl,TILEMAP

;de=ldpush+ (4000,8000)
;^^^делать SETPG один раз для горизонтальной линии тайлов и 1 раз за 8 тайлов для вертикальной линии тайлов (8 тайлов не может вылететь за вторую страницу, т.к. мы рисуем всегда с ровного X/8)
;выводить линию тайлов: сначала весь первый слой, потом весь второй и т.д.
        ld a,(ix)
        SETPG16K
        ld a,(ix+4)
        SETPG32KLOW
        ld b,TILEGFX/256
        push de
        push hl
        call drawtiles_hor_layer
        pop hl
        pop de
        ld a,(ix+1)
        SETPG16K
        ld a,(ix+5)
        SETPG32KLOW
        ld b,TILEGFX/256+8
        push de
        push hl
        call drawtiles_hor_layer
        pop hl
        pop de
        ld a,(ix+2)
        SETPG16K
        ld a,(ix+6)
        SETPG32KLOW
        ld b,TILEGFX/256+16
        push de
        push hl
        call drawtiles_hor_layer
        pop hl
        pop de
        ld a,(ix+3)
        SETPG16K
        ld a,(ix+7)
        SETPG32KLOW
        ld b,TILEGFX/256+24
drawtiles_hor_layer
;8 tiles = 1489 (не считая call-ret)
;*4 слоя*(6+4, считая вертикальные) блоков по 8 = 59560 > 10% от отрисовки при скролле на 8 пикс за фрейм
;
;c000: tile gfx (len = 0x2000)
;<3f00: tilemap
;4000,8000: ld:push
        ;ld b,TILEGFX/256 ;зависит от слоя
        ld c,(hl) ;tile ;7
        DRAWTILELAYERDOWN ;+168
        inc l
        inc e
        ld c,(hl) ;tile ;+15
        DRAWTILELAYERUP ;+168
        inc l
        ld a,e
        sub 5
        ld e,a ;+19 = 377
        ld c,(hl) ;tile
        DRAWTILELAYERDOWN
        inc l
        inc e
        ld c,(hl) ;tile
        DRAWTILELAYERUP
        inc l
        ld a,e
        sub 5
        ld e,a
        ld c,(hl) ;tile
        DRAWTILELAYERDOWN
        inc l
        inc e
        ld c,(hl) ;tile
        DRAWTILELAYERUP
        inc l
        ld a,e
        sub 5
        ld e,a
        ld c,(hl) ;tile
        DRAWTILELAYERDOWN
        inc l
        inc e
        ld c,(hl) ;tile
        DRAWTILELAYERUP
        ret

;TODO для игр с большими тайлами сгенерить в процедуры тайлов 16x8 (каждый слой - страничка, вывод по вертикали в другой страничке), вход такой:
	;ld a,(bc) ;в конце нужен терминатор - невозможный номер тайла
	;inc c
	;ld l,a
	;or 0xc0
	;ld h,a
	;jp (hl) ;30
        ;ex de,hl
        ;dup 7
        ;ld (hl),n
        ;inc h
        ;edup
        ;ld (hl),n
        ;inc l
        ;dup 7
        ;ld (hl),n
        ;dec h
        ;edup
        ;ld (hl),n
        ;ld a,l
        ;sub 5
        ;ld l,a ;поэтому нельзя 8x8
        ;ex de,hl ;+195
	;ld a,(bc)
	;inc c
	;ld l,a
	;or 0xc0
	;ld h,a
	;jp (hl) ;+30, итого тайл 16x8 = 225*4(layers) = 900, *8(tiles)*(3+4)(блоков по 8, считая и горизонтальные) = 50400, при горизонтальном скролле вдвое реже, чем без генерации процедур

tcallpgs
        ds UVSCROLL_NCALLPGS

        display "xscroll=",xscroll
xscroll
        dw 0;+(UVSCROLL_WID-UVSCROLL_SCRWID)/2
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


