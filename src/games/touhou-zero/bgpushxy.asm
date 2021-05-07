uvscroll_prepare

        ld ix,tpushpgs
        call uvscroll_genpush
        ;ld ix,tpushpgs+1
        call uvscroll_genpush
        ;ld ix,tpushpgs+2
        call uvscroll_genpush
        ;ld ix,tpushpgs+3
        call uvscroll_genpush

;зациклим страницы (UVSCROLL_HGT/64 страниц в каждом слое)
        ld hl,tpushpgs
        ld de,tpushpgs+(UVSCROLL_HGT/64*4)
        ld bc,UVSCROLL_HGT/64*4 ;4*4 ;на высоту экрана
        ldir

        jp uvscroll_gencall

       if 0
uvscroll_preparetiles
;tile gfx
        OS_NEWPAGE
        ld a,e
        ld (pgtilegfx),a
        SETPG32KLOW
        OS_NEWPAGE
        ld a,e
        ld (pgtilegfx2),a
        SETPG32KHIGH

        ld de,tilebmpfilename
        call openstream_file
        call readbmphead_pal
        call closestream_file
        
        ld de,tilefilename
        call openstream_file

        ld l,0
uvscroll_preparetiles0
        push hl
        ld de,bgpush_bmpbuf
        ld hl,128 ;one metatile
;de=buf
;hl=size
        push de
        call readstream_file
        pop de
        pop hl
        ld h,0x80+15+16
        call uvscroll_preparetiles_copy4columns
        ld h,0x80+15
        call uvscroll_preparetiles_copy4columns
        inc l
        jr nz,uvscroll_preparetiles0

        jp closestream_file

uvscroll_preparetiles_copy4columns
        call uvscroll_preparetiles_copy2columns
uvscroll_preparetiles_copy2columns
        call uvscroll_preparetiles_copycolumn
uvscroll_preparetiles_copycolumn
        ld b,16
uvscroll_preparetiles_copycolumn0
        ld a,(de)
        ld (hl),a
        inc de
        dec h
        djnz uvscroll_preparetiles_copycolumn0
        ld a,h
        add a,32+16
        ld h,a
        ret

uvscroll_preparetilemap
;tilemap
        OS_NEWPAGE
        ld a,e
        ld (pgmetatilemap),a
        SETPG32KHIGH

        ld de,tilemapfilename
        call openstream_file
        ld de,0xc000;0xe000
        ld hl,0x4000;0x2000
;de=buf
;hl=size
        call readstream_file        
        call closestream_file

        if 1==0
;перекодируем метатайлы из 2-байтового представления в 1-байтовое
;и переворачиваем, чтобы было снизу вверх, справа налево (в соответствии с ldpush)
        ld hl,0xc000
        ld de,0xffff&(0xe000+0x2000)
        ld bc,0x2000/2
uvscroll_preparetilemap_remetatiles0
        dec de
        ld a,(de)
        ld hx,a
        dec de
        ld a,(de)
        ld lx,a
        add ix,ix
        add ix,ix
        add ix,ix
        ld a,hx
        ld (hl),a
        cpi
        jp pe,uvscroll_preparetilemap_remetatiles0
        endif

        call uvscroll_filltilemap
        jp uvscroll_showtilemap
        
uvscroll_showtilemap_counthlde
        ld hl,(allscroll)
;округлить до целого метатайла в зависимости от yscroll&15 (в самом allscroll нет этой информации)
;т.е. hl-=(yscroll&15)*(UVSCROLL_WID/512)
        ld a,(yscroll)
        and 15
        cpl
        ld c,a
        ld b,-1
        inc bc ;bc<=0
        dup UVSCROLL_WID/512
        add hl,bc
        edup
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a
        ld a,(allscroll_lsb)
        ld c,a
        rra
        rra
        cpl
        and 3*2
;de=TILEMAP-(((x2scroll/8)&3)*2) в зависимости от x2scroll:
        ld de,TILEMAP-6
        add a,e
        ld e,a
        jr nc,$+3
        inc d
        ret

uvscroll_showtilemap
;выводим текущий tilemap в ldpush
        call uvscroll_showtilemap_counthlde
;как выводим относительно TILEMAP: (сначала показаны правые знакоместа)
;x2scroll=0:
;[......][......][......][......][......][......][......][......]
;sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
;x2scroll=8 (go left):
;.....][......][......][......][......][......][......][......]
;sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
;x2scroll=16 (go left):
;...][......][......][......][......][......][......][......]
;sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
;x2scroll=24 (go left):
;.][......][......][......][......][......][......][......]
;sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
        ld b,TILEMAPHGT/2
uvscroll_showtilemap_b
;hl=allscroll-(yscroll&15)*(UVSCROLL_WID/512)
;de=TILEMAP-(((x2scroll/8)&3)*2) в зависимости от x2scroll
;b=hgt
;c=allscroll_lsb
        ld a,c;(allscroll_lsb)
        and 0xe0 ;округлить до x/64 = x2/32
uvscroll_showtilemap0
        push af
        push bc
        push de
        push hl

        ld b,48/8 ;b=число блоков по 8 тайлов
        push af
        push bc
        push de
        push hl
        ex af,af'
        ld a,TILEGFX/256
        ld (drawtiles_hor_block_tilegfx),a
        ex af,af'
;de=tilemap+
;hla=allscroll
        call drawtiles_hor_hla_de
        pop hl
        ld bc,8*(UVSCROLL_WID/512)
        add hl,bc ;y*2
        pop de
        pop bc
        ld a,TILEGFX/256+8
        ld (drawtiles_hor_block_tilegfx),a
        pop af
;de=tilemap+
;hla=allscroll
        call drawtiles_hor_hla_de
        
        pop hl
        ld bc,16*(UVSCROLL_WID/512)
        add hl,bc ;y*(UVSCROLL_WID/512)
        pop de ;tilemap
        ex de,hl
        ld bc,TILEMAPWID*2
        add hl,bc
        ex de,hl
        pop bc
        pop af
        djnz uvscroll_showtilemap0
	ret
       endif
        
        if 1==0
;выводим tilemap 64x32 в ldpush (для сверхбыстрых маленьких уровней? там отключить обновление через tilemap и подрисовку столбцов)
uvscroll_showmetatilemap
        ld hl,0 ;y*(UVSCROLL_WID/512)
        ld de,0xc000;+0x0800 ;metatilemap
        ld b,UVSCROLL_HGT/16
uvscroll_showmetatilemap0
        push bc
        push de
        push hl

        push hl
        ld a,(pgmetatilemap)
        SETPG32KHIGH
        ld hl,bgpush_bmpbuf;TILEMAP
        push hl
        ld b,UVSCROLL_WID/16
uvscroll_gettilemapline0
        ld a,(de)
        inc de
        ld (hl),a
        inc hl
        ld (hl),a
        inc hl
        djnz uvscroll_gettilemapline0
        pop de ;TILEMAP
        pop hl

        ld b,128/8 ;b=число блоков по 8 тайлов
        push bc
        push de
        push hl
        ld a,TILEGFX/256
        ld (drawtiles_hor_block_tilegfx),a
        xor a
;de=tilemap+
;hla=allscroll
        call drawtiles_hor_hla_de
        pop hl
        ld bc,8*(UVSCROLL_WID/512)
        add hl,bc ;y*2
        pop de
        pop bc
        ld a,TILEGFX/256+8
        ld (drawtiles_hor_block_tilegfx),a
        xor a ;x=0
;de=tilemap+
;hla=allscroll
        call drawtiles_hor_hla_de
        
        pop hl
        ld bc,16*(UVSCROLL_WID/512)
        add hl,bc ;y*(UVSCROLL_WID/512)
        pop de ;metatilemap
        ex de,hl
        ld bc,METATILEMAPWID
        add hl,bc
        ex de,hl
        pop bc
        djnz uvscroll_showmetatilemap0
	ret
        endif

uvscroll_preparebmp
;de=filename
        call openstream_file

        call readbmphead_pal

;загрузить графику bmp в ld-push
        ld ix,tpushpgs
        ld hl,uvscroll_pushbase
        ld bc,UVSCROLL_HGT
uvscroll_ldbmp0
        ;ld a,UVSCROLL_WID/8/2
        ;ld a,512/8/2
       ;ld a,320/8/2
       ld a,(bmpwid)
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
        call closestream_file
uvscroll_restorememmap
        call RestoreMemMap3
        jp setpgsmain40008000

uvscroll_setscroll
;hl=y
;de=x
        srl d
        rr e
       ld bc,200-1
       add hl,bc
        ld a,h
        cpl
        and 1
        ld h,a
        ld a,l
        cpl
        ld l,a
       if UVSCROLL_WID==1024
        add hl,hl
       endif
        ld a,d
        add a,l
        ld l,a
        ld a,e
        ld (allscroll_lsb),a
        ld (allscroll),hl
        ret

uvscroll_scroll
;de=delta (d>0: go up) (e>0: go left)
        push de
        ld a,e
        call uvscroll_scroll_x
        pop af
        jp uvscroll_scroll_y

       if 0
uvscroll_scrolltiles
;scroll by metatile
;hx=delta y (>0: go up)
;lx=delta x (>0: go left)
        call uvscroll_scrolltilemap ;делаем этот ldir/lddr только один раз для двух координат
;подкачать появившиеся строки:
        ld a,hx ;delta y (>0: go up)
        or a
        jr z,uvscrollloop_ynupd
        jp m,uvscrollloop_yupddown
         cp TILEMAPHGT /2
         jr c,uvscrollloop_yupdup_nallscr
         ld hx,TILEMAPHGT /2 ;весь экран будет подкачан
uvscrollloop_yupdup_nallscr
        call countmetatilemap ;hl=metatilemap + (yscroll/16*METATILEMAPWID) + (x2scroll/8)
        ld bc,+(TILEMAPHGT/2-1)*METATILEMAPWID
        add hl,bc
        ld de,TILEMAP+((TILEMAPHGT-2)*TILEMAPWID)
uvscrollloop_yupdup0
;de=tilemap+
;hl=metatilemap+
        push de
        push hl
        call uvscroll_filltilemap_line ;заполнение одной двойной строки TILEMAP из карты
        pop hl
        pop de
        ld bc,-METATILEMAPWID
        add hl,bc
        ex de,hl
        ld bc,-TILEMAPWID*2
        add hl,bc
        ex de,hl
        dec hx
        jr nz,uvscrollloop_yupdup0        
        jr uvscrollloop_ynupd
uvscrollloop_yupddown
         cp -(TILEMAPHGT /2)
         jr nc,uvscrollloop_yupddown_nallscr
         ld hx,-(TILEMAPHGT /2) ;весь экран будет подкачан
uvscrollloop_yupddown_nallscr
        call countmetatilemap ;hl=metatilemap + (yscroll/16*METATILEMAPWID) + (x2scroll/8)
        ld de,TILEMAP
uvscrollloop_yupddown0
;de=tilemap+
;hl=metatilemap+
        push de
        push hl
        call uvscroll_filltilemap_line ;заполнение одной двойной строки TILEMAP из карты
        pop hl
        pop de
        ld bc,METATILEMAPWID
        add hl,bc
        ex de,hl
        ld bc,TILEMAPWID*2
        add hl,bc
        ex de,hl
        inc hx
        jr nz,uvscrollloop_yupddown0
uvscrollloop_ynupd

;подкачать появившиеся столбцы:
        ld a,lx ;delta x (>0: go left)
        or a
        jr z,uvscrollloop_xnupd
        jp m,uvscrollloop_xupdright
         cp TILEMAPWID /2
         jr c,uvscrollloop_xupdleft_nallscr
         ld lx,TILEMAPWID /2 ;весь экран будет подкачан
uvscrollloop_xupdleft_nallscr
        call countmetatilemap ;hl=metatilemap + (yscroll/16*METATILEMAPWID) + (x2scroll/8)
        ld bc,TILEMAPWID/2-1
        add hl,bc
        ld de,TILEMAP+TILEMAPWID-2
uvscrollloop_xupdleft0
;de=tilemap+
;hl=metatilemap+
        push de
        push hl
        call uvscroll_filltilemap_column ;заполнение одного двойного столбца TILEMAP из карты
        pop hl
        pop de
        dec hl
        dec de
        dec de
        dec lx
        jr nz,uvscrollloop_xupdleft0        
        jr uvscrollloop_xnupd
uvscrollloop_xupdright
         cp -(TILEMAPWID /2)
         jr nc,uvscrollloop_xupdright_nallscr
         ld lx,-(TILEMAPWID /2) ;весь экран будет подкачан
uvscrollloop_xupdright_nallscr
        call countmetatilemap ;hl=metatilemap + (yscroll/16*METATILEMAPWID) + (x2scroll/8)
        ld de,TILEMAP
uvscrollloop_xupdright0
;de=tilemap+
;hl=metatilemap+
        push de
        push hl
        call uvscroll_filltilemap_column ;заполнение одного двойного столбца TILEMAP из карты
        pop hl
        pop de
        inc hl
        inc de
        inc de
        inc lx
        jr nz,uvscrollloop_xupdright0
uvscrollloop_xnupd

;draw by tile
;hy=delta y (>0: go up) надо отрисовать все появившиеся строки
        ld hl,(allscroll)
;округлить до целого тайла в зависимости от yscroll&7 (в самом allscroll нет этой информации)
;т.е. hl-=(yscroll&7)*(UVSCROLL_WID/512)
        ld a,(yscroll)
        and 7
        cpl
        ld c,a
        ld b,-1
        inc bc ;bc<=0
        dup UVSCROLL_WID/512
        add hl,bc
        edup

;как выводим относительно TILEMAP: (сначала показаны правые знакоместа)
;x2scroll=0:
;[......][......][......][......][......][......][......][......]
;sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
;x2scroll=8 (go left):
;.....][......][......][......][......][......][......][......]
;sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
;x2scroll=16 (go left):
;...][......][......][......][......][......][......][......]
;sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
;x2scroll=24 (go left):
;.][......][......][......][......][......][......][......]
;sSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSs
;de+=TILEMAPWID при yscroll&8 ;TODO перетащить до ветвления, если это верно и одинаково для обеих веток
        ld de,TILEMAP-6
        ld a,(yscroll)
        and 8
        jr z,uvscrollloop_ydrawup_nodd
        ld de,TILEMAP-6 +TILEMAPWID
uvscrollloop_ydrawup_nodd
        or TILEGFX/256
        ld (drawtiles_hor_block_tilegfx),a

        ld a,(allscroll_lsb)
        rra
        rra
        cpl
        and 3*2
;de=TILEMAP-(((x2scroll/8)&3)*2) в зависимости от x2scroll:
        add a,e
        ld e,a
        jr nc,$+3
        inc d

        ld a,hy ;delta y (>0: go up)
        or a
        jp z,uvscrollloop_yndraw
        jp m,uvscrollloop_ydrawdown
;строки из конца TILEMAP или +TILEMAPWID (если yscroll&8)
;рисуем их в ldpush на UVSCROLL_SCRHGT выше текущей округлённой базы
          ld bc,+(UVSCROLL_SCRHGT)*(UVSCROLL_WID/512)
          add hl,bc
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a

        ex de,hl
        ld bc,+(TILEMAPHGT-2)*TILEMAPWID
        add hl,bc
        ex de,hl

        ld a,(allscroll_lsb)
        and 0xe0 ;округлить до x/64 = x2/32
        
uvscrollloop_ydrawup0
;de=tilemap+
;hla=allscroll+
        push af
        push de
        push hl
        ld b,6 ;число блоков по 8 тайлов
        call drawtiles_hor_hla_de ;заполнение одной строки тайлов ldpush из TILEMAP
        ld hl,drawtiles_hor_block_tilegfx
        ld a,(hl)
        xor 8
        ld (hl),a ;верхняя/нижняя половинка метатайла
        pop hl
        pop de
        ld bc,-8*(UVSCROLL_WID/512)
        add hl,bc ;следующая тайловая строка в ldpush
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a
        pop af
        ex de,hl
        ld bc,-TILEMAPWID
        add hl,bc ;следующая тайловая строка в tilemap
        ex de,hl
        dec hy
        jr nz,uvscrollloop_ydrawup0        
        jr uvscrollloop_yndraw
uvscrollloop_ydrawdown
;строки из начала TILEMAP или +TILEMAPWID (если yscroll&8)
;рисуем их в ldpush на уровне текущей округлённой базы
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a

        ld a,(allscroll_lsb)
        and 0xe0 ;округлить до x/64 = x2/32

uvscrollloop_ydrawdown0
;de=tilemap+
;hla=allscroll+
        push af
        push de
        push hl
        ld b,6 ;число блоков по 8 тайлов
        call drawtiles_hor_hla_de ;заполнение одной строки тайлов ldpush из TILEMAP
        ld hl,drawtiles_hor_block_tilegfx
        ld a,(hl)
        xor 8
        ld (hl),a ;верхняя/нижняя половинка метатайла
        pop hl
        pop de
        ld bc,8*(UVSCROLL_WID/512)
        add hl,bc ;следующая тайловая строка в ldpush
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a
        pop af
        ex de,hl
        ld bc,TILEMAPWID
        add hl,bc ;следующая тайловая строка в tilemap
        ex de,hl
        inc hy
        jr nz,uvscrollloop_ydrawdown0
uvscrollloop_yndraw

;ly=delta x (>0: go left) надо отрисовать все появившиеся столбцы
        ld hl,(allscroll)
;округлить до целого метатайла в зависимости от yscroll&15 (в самом allscroll нет этой информации)
;т.е. hl-=(yscroll&15)*(UVSCROLL_WID/512)
        ld a,(yscroll)
        and 15
        cpl
        ld c,a
        ld b,-1
        inc bc ;bc<=0
        dup UVSCROLL_WID/512
        add hl,bc
        edup
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a

        ld de,TILEMAP
;de++ при x2scroll&4
        ld a,(x2scroll)
        and 4
        ld a,TILEGFX/256
        jr z,uvscrollloop_xdraw_nodd
        inc de
        add a,16
uvscrollloop_xdraw_nodd
        ld (drawtiles_ver_block_tilegfx),a

        ld a,ly ;delta x (>0: go left)
        or a
        jp z,uvscrollloop_xndraw
        jp m,uvscrollloop_xdrawright
;столбцы из TILEMAP+TILEMAPWID-2 или +1 (если x2scroll&4)
;рисуем их в ldpush на уровне текущей округлённой базы +((TILEMAPWID-2)*4)
        ex de,hl
        ld bc,TILEMAPWID-2
        add hl,bc
        ex de,hl        
        ld a,(allscroll_lsb)
        and 0xfc ;округлить до x/8 = x2/4
        add a,+((TILEMAPWID-2)*4)
        jr nc,uvscrollloop_xdrawleft_nincallscroll
        inc hl
        ex af,af'
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a
        ex af,af'
uvscrollloop_xdrawleft_nincallscroll
        ld b,ly
uvscrollloop_xdrawleft0
;de=tilemap+
;hla=allscroll+
        push bc
        push af
        push de
        push hl
        ld b,3 ;число блоков по 8 тайлов
        call drawtiles_ver_hla_de
        ld hl,drawtiles_ver_block_tilegfx
        ld a,(hl)
        xor 16
        ld (hl),a ;левая/правая половинка метатайла
        pop hl
        pop de
        dec de
        pop af
        sub 4
        jr nc,uvscrollloop_xdrawleft0_ndecallscroll
        dec hl
        ex af,af'
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a
        ex af,af'
uvscrollloop_xdrawleft0_ndecallscroll
        pop bc
        djnz uvscrollloop_xdrawleft0
        jr uvscrollloop_xndraw
uvscrollloop_xdrawright
;столбцы из начала TILEMAP или +1 (если x2scroll&4)
;рисуем их в ldpush на уровне текущей округлённой базы
        ld a,(allscroll_lsb)
        and 0xfc ;округлить до x/8 = x2/4
        ld b,ly
uvscrollloop_xdrawright0
;de=tilemap+
;hla=allscroll+
        push bc
        push af
        push de
        push hl
        ld b,3 ;число блоков по 8 тайлов
        call drawtiles_ver_hla_de
        ld hl,drawtiles_ver_block_tilegfx
        ld a,(hl)
        xor 16
        ld (hl),a ;левая/правая половинка метатайла
        pop hl
        pop de
        inc de
        pop af
        add a,4
        jr nc,uvscrollloop_xdrawright0_nincallscroll
        inc hl
        ex af,af'
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a
        ex af,af'
uvscrollloop_xdrawright0_nincallscroll
        pop bc
        inc b
        jr nz,uvscrollloop_xdrawright0
uvscrollloop_xndraw
        ret;jp uvscrollloop0

drawtile_toldpush
;de=tilemap+
;hla=allscroll+
        ld b,1 ;число блоков по 8 тайлов
        jp drawtiles_ver_hla_de
       endif

uvscroll_scroll_x
;a>0 = go left
        ld hl,(x2scroll)
        ld c,a
         ld a,l
         and 0xfc
         ld d,a
         and 0xf8
         ld e,a
        ld a,(allscroll_lsb)
        bit 7,c
        jr nz,uvscroll_scroll_x_minus
;uvscroll_scroll_x_plus
        ld b,0
        add hl,bc
        ;ld bc,+(UVSCROLL_WID-UVSCROLL_SCRWID)/2
        ;or a
        ;sbc hl,bc
        ;add hl,bc
        ;jr c,$+4
        ;ld h,b
        ;ld l,c
        add a,c
        ld bc,(allscroll)
        jr nc,$+3
        inc bc
uvscroll_scroll_x_q
        ld (allscroll_lsb),a
         ld a,b
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld b,a
        ld (allscroll),bc
        ld (x2scroll),hl ;чем больше, тем более левая часть карты
         ld a,l
         and 0xf8
         sub e
        sra a
        sra a
        sra a ;a=число левых (с минусом - правых) столбцов, которые надо подкачать (изменился x2scroll/8)
        ld lx,a
         ld a,l
         and 0xfc
         sub d
        sra a
        sra a ;a=число левых (с минусом - правых) столбцов, которые надо подрисовать (изменился x2scroll/4)
        ld ly,a
        ret
        
uvscroll_scroll_x_minus
        ld b,-1
        add hl,bc
         ;bit 7,h
         ;jr z,$+5
         ;ld hl,0 ;сбивает фазу относительно allscroll!
        add a,c
        ld bc,(allscroll)
        jr c,uvscroll_scroll_x_q;$+3
        dec bc
        jr uvscroll_scroll_x_q
        
uvscroll_scroll_y
;a>0 = go up
        ld hl,(yscroll)
        ld c,a
         ld a,l
         and 0xf8
         ld d,a
         and 0xf0
         ld e,a
        bit 7,c
        jr nz,uvscroll_scroll_y_minus
;uvscroll_scroll_y_plus
        ld b,0
        add hl,bc
        ;ld de,UVSCROLL_HGT-UVSCROLL_SCRHGT
        ;or a
        ;sbc hl,de
        ;add hl,de
        ;jr c,$+3
        ;ex de,hl
uvscroll_scroll_y_q
        push hl
        ld hl,(allscroll)
        dup UVSCROLL_WID/512
        add hl,bc
        edup
         ld a,h
         and +(UVSCROLL_HGT/256)*(UVSCROLL_WID/512)-1
         ld h,a
        ld (allscroll),hl
        pop hl
        ld (yscroll),hl ;чем больше, тем более верхняя часть карты
         ld a,l
         and 0xf0
         sub e
        sra a
        sra a
        sra a
        sra a ;a=число верхних (с минусом - нижних) строк, которые надо подкачать (изменился yscroll/16)
        ld hx,a
         ld a,l
         and 0xf8
         sub d
        sra a
        sra a
        sra a ;a=число верхних (с минусом - нижних) строк, которые надо подрисовать (изменился yscroll/8)
        ld hy,a
        ret
        
uvscroll_scroll_y_minus
        ld b,-1
        add hl,bc
         ;bit 7,h
         ;jr z,$+5
         ;ld hl,0 ;сбивает фазу относительно allscroll!
        jr uvscroll_scroll_y_q

       if 0
;процедура скроллинга буфера tilemap (содержит номера тайлов в видимой части карты, снизу вверх, справа налево)
uvscroll_scrolltilemap
;hx=delta y (>0: go up)
;lx=delta x (>0: go left)
;скроллим ровно вдвое больше!!!
        ld a,hx
        or lx
        ret z
        ld hl,TILEMAP ;from
        ld d,h
        ld e,l        ;to
        ld bc,TILEMAPWID *2 ;b=0!!!
        exx
        ld hl,TILEMAPHGT*TILEMAPWID ;size
        ld bc,-TILEMAPWID *2
        exx
        ld a,hx
        or a
        jr z,uvscroll_scrolltilemap_dyq
        jp m,uvscroll_scrolltilemap_dyneg
         cp TILEMAPHGT /2
         ret nc ;скроллить весь экран или даже больше бессмысленно - весь экран будет подкачан
;dy>0: go up (удалить начальную часть tilemap): hl+=dy*TILEMAPWID *2, hl'-=dy*TILEMAPWID *2
uvscroll_scrolltilemap_dypos0
        add hl,bc ;from
        exx
        add hl,bc ;size
        exx
        dec a
        jr nz,uvscroll_scrolltilemap_dypos0
        jr uvscroll_scrolltilemap_dyq
uvscroll_scrolltilemap_dyneg
         cp -(TILEMAPHGT /2 +1)
         ret c ;скроллить весь экран или даже больше бессмысленно - весь экран будет подкачан
;dy<0: go down (удалить конечную часть tilemap): de+=dy*-TILEMAPHGT *2, hl'-=dy*-TILEMAPHGT *2
        ex de,hl
uvscroll_scrolltilemap_dyneg0
        add hl,bc ;to
        exx
        add hl,bc ;size
        exx
        inc a
        jr nz,uvscroll_scrolltilemap_dyneg0
        ex de,hl
uvscroll_scrolltilemap_dyq
        ld a,lx
        ;or a
         add a,a
        jr z,uvscroll_scrolltilemap_dxq
        jp m,uvscroll_scrolltilemap_dxneg
         cp TILEMAPWID
         ret nc ;скроллить весь экран или даже больше бессмысленно - весь экран будет подкачан
;dx>0: go left (удалить начальную часть tilemap): hl+=dx, hl'-=dx
        ld c,a
        ;ld b,0
        add hl,bc ;NC
        jr uvscroll_scrolltilemap_dxok
uvscroll_scrolltilemap_dxneg
         cp -(TILEMAPWID+1)
         ret c ;скроллить весь экран или даже больше бессмысленно - весь экран будет подкачан
;dx<0: go right (удалить конечную часть tilemap): de-=dx, hl'+=dx
        neg
        ex de,hl
        ld c,a
        ;ld b,0
        add hl,bc
        ex de,hl
uvscroll_scrolltilemap_dxok
        exx
        ld c,a
        ld b,0
        ;or a
        sbc hl,bc
        exx
uvscroll_scrolltilemap_dxq
        exx
        push hl ;size
        exx
        pop bc ;size
;hl=from
;de=to
;bc=size
        or a
        sbc hl,de
        add hl,de
        jr nc,uvscroll_scrolltilemap_ldir
        add hl,bc
        dec hl
        ex de,hl
        add hl,bc
        dec hl
        ex de,hl
        lddr ;TODO ldd in a loop
        ret
uvscroll_scrolltilemap_ldir
        ldir ;TODO ldi in a loop
        ret


countmetatilemap
;out: hl=metatilemap + (yscroll/16*METATILEMAPWID) + (x2scroll/8)
        ld hl,(yscroll)
        sra h
        rr l
        sra h
        rr l
        sra h
        rr l
        sra h
        rr l ;hl=yscroll/16
        if METATILEMAPWID==256
        ld h,l
        ld l,0
        else ;METATILEMAPWID==64
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;*64
        endif
        ld bc,(x2scroll)
        sra b
        rr c
        sra b
        rr c
        sra b
        rr c ;bc=x2scroll/8
        add hl,bc
         ;ld hl,0
        ld bc,0xc000;+0x0800 ;metatilemap
        add hl,bc
        ret

uvscroll_filltilemap
;заполнение TILEMAP из карты метатайлов
        call countmetatilemap ;hl=metatilemap + (yscroll/16*METATILEMAPWID) + (x2scroll/8)        
        ld de,TILEMAP
        ld b,TILEMAPHGT/2
uvscroll_filltilemap0
        push bc
        push de
        push hl
        call uvscroll_filltilemap_line
        pop hl
        ld bc,METATILEMAPWID
        add hl,bc
        pop de
        ex de,hl
        ld bc,TILEMAPWID*2
        add hl,bc
        ex de,hl
        pop bc
        djnz uvscroll_filltilemap0
	ret

uvscroll_filltilemap_line
;заполнение одной двойной строки TILEMAP из карты
;de=tilemap+
;hl=metatilemap+
pgmetatilemap=$+1
        ld a,0
        SETPG32KHIGH
        push de
        ld bc,TILEMAPWID/2
uvscroll_filltilemap_line0
        ld a,(hl)
        ld (de),a
        inc de
        ldi
        jp pe,uvscroll_filltilemap_line0
        pop hl
        ld bc,TILEMAPWID
        ldir ;вторая строка тайлов такая же
	ret

uvscroll_filltilemap_column
;заполнение одного двойного столбца TILEMAP из карты
;de=tilemap+
;hl=metatilemap+
        ld a,(pgmetatilemap)
        SETPG32KHIGH
        push de ;tilemap+
        ld de,METATILEMAPWID
        exx
        pop hl ;tilemap+
        ld de,TILEMAPWID-1
        ld b,TILEMAPHGT/2
uvscroll_filltilemap_column0
        exx
        ld a,(hl)
        add hl,de
        exx
        ld (hl),a
        inc hl
        ld (hl),a
        add hl,de
        ld (hl),a
        inc hl
        ld (hl),a ;копируем номер метатайла в 4 тайла
        add hl,de
        djnz uvscroll_filltilemap_column0
	ret
       endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
       push ix
        call genpush_newpage ;заказывает страницу, заносит в tpushpgs, a=pg
        SETPG32KLOW
        ld hl,uvscroll_pushbase
        ld bc,UVSCROLL_HGT
uvscroll_genpush0
        push bc
        ld a,h
        cp uvscroll_pushbase/256+64
        call z,uvscroll_genpush_nextpg
        ld b,UVSCROLL_NPUSHES
uvscroll_genpush1
        ld (hl),1 ;ld bc
        inc hl
        ;ld a,r
        ;ld (hl),a
        inc hl
        ;ld a,r
        ;ld (hl),a
        inc hl
        ld (hl),0xc5 ;push bc
        inc hl
        djnz uvscroll_genpush1
        pop bc
        dec bc
        ld a,b
        or c
        jr nz,uvscroll_genpush0
       pop ix
       inc ix
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
;inc hx ;адрес следующего ldpush (поэтому UVSCROLL_WID=1024)
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
        ld de,bgpush_bmpbuf
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
        ld (hl),0xfd
        inc l
        ld (hl),0xe9 ;jp (iy)
        inc l
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
        ld a,3 ;layer 0..3 [+ 4]
        call uvscroll_drawlayer
        call setpgscrhigh4000
        ld a,2 ;layer 0..3 [+ 4]
        call uvscroll_drawlayer
        call setpgscrlow4000
        ld a,1 ;layer 0..3 [+ 4]
        call uvscroll_drawlayer
        call setpgscrhigh4000
        xor a ;layer 0..3 [+ 4]
uvscroll_drawlayer
        push af
        call uvscroll_patch
        pop af
        push af
        call uvscroll_callpp
         xor a
         ld (uvscroll_scrbase+(40*UVSCROLL_SCRHGT)),a
         ld (uvscroll_scrbase+(40*UVSCROLL_SCRHGT)+0x2000),a
        pop af
        ;jp uvscroll_unpatch
uvscroll_unpatch
        ;ld d,0x01 ;d=unpatch byte ld bc
        ld d,0xc5 ;d=unpatch byte push bc
        call uvscroll_patch_d
        jp uvscroll_restorememmap

uvscroll_patch
;a=layer 0..3 [+ 4]
        ld d,0xe9 ;d=patch byte jp (hl)
uvscroll_patch_d
allscroll=$+1
        ld hl,0
         add a,+(UVSCROLL_SCRNPUSHES-1)*8
allscroll_lsb=$+1
        add a,0 ;ld c,0
;hlc = allscroll = yscroll*512+x2scroll
        ld c,a
          jr nc,$+3
          inc hl
         ld e,l ;yscroll*2
        add hl,hl
         rr e ;yscroll (corrected для зацикливания)
         rra
         or 3 ;and 0xfc
         ld l,a ;a=0xff-(((x2scroll+layer[+4])/2)&0xfc)
         ld a,h
         rla
         rla ;a=(x2scroll+layer)&3 + ((yscroll/64)*4)
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
        exx ;hl'=список страниц графики =f((x2scroll+layer)&3 + ((yscroll/64)*4))
         ld a,e ;yscroll (corrected для зацикливания)
        or 0xc0
        ld h,a
        add a,UVSCROLL_SCRHGT
        ld e,a
;конец (крайнее правое положение L при вызове, т.е. x2scroll=0) = 256-(UVSCROLL_SCRNPUSHES*4)
;адрес входа графики: конец - ((x2scroll+layer[+4])/2&0xfc)
;d=patch byte
;e=число оставшихся строк патча
;h=0xc0+(yscroll&63)
;l=f(x2scroll+layer) ;L = адрес патча выхода = адрес входа графики + (UVSCROLL_SCRNPUSHES*4)-1
;hl'=список страниц графики =f((x2scroll+layer)&3 + ((yscroll/64)*4))
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
;a=layer 0..3 [+ 4]
         push af ;a=layer 0..3 [+ 4]

        ld hl,allscroll_lsb
        add a,(hl)
        ld c,a
          ld hl,(allscroll)
          jr nc,$+3
          inc hl ;hlc = allscroll = yscroll*512+x2scroll
         ld e,l ;yscroll*2
        add hl,hl
         rr e ;yscroll (corrected для зацикливания)
         rra
          ld b,a
         and 0xfc
         ld lx,a ;a=0xfc-(((x2scroll+layer[+4]+((UVSCROLL_SCRNPUSHES-1)*8))/2)&0xfc)
         
        cp 0x100-(UVSCROLL_SCRNPUSHES*4-1)
        ld iy,uvscroll_nextgfxpg
        jr c,uvscroll_callpp_noxcycled
        ld iy,uvscroll_suddennextgfxpg
uvscroll_callpp_noxcycled
         
         ld a,h
         rla
         rla ;a=(x2scroll+layer)&3 + ((yscroll/64)*4)
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
         pop af ;a=layer 0..3 [+ 4]
         push af
          cpl
         rrca
         rrca
         and 0x80;0xc0
         ld l,a ;L=(layer&2)*0x80
         ld a,b ;a=~((x2scroll+layer+4)/2)
         and 4/2 ;если не 0, то на выходе подрисовка левого столбца
         rrca
         rrca
         rrca
         add a,l
         ld l,a ;L=(layer&2)*0x80 + ((x2scroll+layer)&4)/4*0x40
;конец (крайнее правое положение L при вызове, т.е. x2scroll=0) = 256-(UVSCROLL_SCRNPUSHES*4)
;адрес входа графики: конец - ((x2scroll+layer[+4])/2&0xfc)
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
;a=layer 0..3 [+ 4]
        ;ld hl,(allscroll)
        ld hl,allscroll_lsb
        ;ld c,(hl)
         add a,+(UVSCROLL_SCRNPUSHES-0)*8
         ;sub 8
;hlc = allscroll = yscroll*512+x2scroll
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
         ld l,a ;a=0xff-(((x2scroll+layer[+4])/2)&0xfc)
         ld a,h
         rla
         rla ;a=(x2scroll+layer)&3 + ((yscroll/64)*4)
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
        exx ;hl'=список страниц графики =f((x2scroll+layer)&3 + ((yscroll/64)*4))
         ld a,e ;yscroll (corrected для зацикливания)
        or 0xc0
        ld h,a
;конец (крайнее правое положение L при вызове, т.е. x2scroll=0) = 256-(UVSCROLL_SCRNPUSHES*4)
;адрес входа графики: конец - ((x2scroll+layer[+4])/2&0xfc)
;d=patch byte
;h=0x80+(yscroll&63)
;l=f(x2scroll+layer) ;L = адрес патча выхода = адрес входа графики + (UVSCROLL_SCRNPUSHES*4)-1
;hl'=список страниц графики =f((x2scroll+layer)&3 + ((yscroll/64)*4))
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

       if 0
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

;8x8
;рисуем всегда с ровного x/8 (x2/4), а Y может пересекать страницу
;может понадобиться отрисовать 41 тайл по горизонтали
;большая карта может состоять из нескольких зон с разной tilegfx
;одна отрисовка должна быть в рамках одной tilegfx
;так что выводим блоками по 8 тайлов всегда - тогда можно и X всегда привязанный к целому push (ровный x/16 (x2/8)), и весь блок из 8 тайлов не вылетит за сегмент (ровный x/64 (x2/32))
;при экране 38x22 знакомест (надо целое число метатайлов) выводим 40 тайлов по горизонтали и 24 по вертикали (выгода 20%)
drawtiles_hor_hla_de
;de=tilemap+
;hla=allscroll+
;b=число блоков по 8 тайлов
        push bc
        push de

         ld d,l ;y*2
        add hl,hl
         srl d ;y (corrected для зацикливания)
         rra
          and 0xf0;0xfc ;a=0xff-(((x2+layer[+4])/2)&0xfc)
          add a,2 ;адрес байта графики H
         ld e,a
         ld a,h
         add a,a
         add a,a ;a=((y/64)*4)
        ld c,a
        ld b,0
        ld ix,tpushpgs
        add ix,bc ;ix=список страниц графики =f((x2+layer)&3 + ((y/64)*4))
         set 6,d ;y+0x40 (corrected для зацикливания)
;ix=tpushpgs+(Y/64*4)+layer

        pop hl ;tilemap+
        pop bc ;b=число блоков по 8 тайлов
        
;отрисовывать тайлы справа налево (по возрастанию адресов ld-push)
drawtiles_hor_blocks0
        push bc
        push de
        call drawtiles_hor_block
        inc hl
        pop de
        ld a,e
        add a,8*2
        ld e,a
        jr nc,$+3
        inc d
        pop bc
        djnz drawtiles_hor_blocks0
        ret
        
drawtiles_hor_block
;ix=tpushpgs+
;hl=tilemap+
;de=ldpush+ (4000,8000)
;^^^делать SETPG один раз для горизонтальной линии тайлов и 1 раз за 8 тайлов для вертикальной линии тайлов (8 тайлов не может вылететь за вторую страницу, т.к. мы рисуем всегда с ровного X/8=x/64)
;выводить линию тайлов: сначала весь первый слой, потом весь второй и т.д.
        ld a,(pgtilegfx) ;TODO по зоне
        SETPG32KHIGH
        ld a,(ix)
        SETPG16K
        ld a,(ix+4)
        SETPG32KLOW
drawtiles_hor_block_tilegfx=$+1
        ld b,TILEGFX/256 ;+0x08, если Y=y/8 нечётное
         push bc
        push de
        push hl
        call drawtiles_hor_layer
        pop hl
        pop de
        ld a,(ix+1)
        SETPG16K
        ld a,(ix+5)
        SETPG32KLOW
         pop bc
         push bc
         set 5,b
        push de
        push hl
        call drawtiles_hor_layer
        pop hl
        pop de
        ld a,(pgtilegfx2) ;TODO по зоне
        SETPG32KHIGH
        ld a,(ix+2)
        SETPG16K
        ld a,(ix+6)
        SETPG32KLOW
         pop bc
         push bc
        push de
        push hl
        call drawtiles_hor_layer
        pop hl
        pop de
        ld a,(ix+3)
        SETPG16K
        ld a,(ix+7)
        SETPG32KLOW
         pop bc
         set 5,b
drawtiles_hor_layer
;8 tiles = 1489 (не считая call-ret)
;*4 слоя*(6+4, считая вертикальные) блоков по 8 = 59560 > 10% от отрисовки при скролле на 8 пикс за фрейм
;
;c000: metatile gfx
;iy<3f00: tilemap (содержит номера метатайлов! то есть важна чётность X тайлов, мы всегда должны рисовать с целого метатайла)
;4000,8000: ld:push
;чтобы выводить тайлы 8x8 прямо из графики метатайлов, надо расположить их в памяти вертикально (каждый метатайл = 128 inc h)
;слои отстоят друг от друга на +0x2000
;левый и правый полуметатайл отстоят друг от друга на +0x1000
;реально в tilemap могут быть независимые номера тайлов, так что используется 4 набора тайлов - для каждой комбинации чётностей X,Y - важно для надписей
;поэтому не пропускаем ld c
        ld c,(hl) ;tile left ;7
        DRAWTILELAYERDOWN ;+168
        inc hl
        dec e
         set 4,b
        ld c,(hl) ;tile right ;+15
        DRAWTILELAYERUP ;+168
        inc hl
        ld a,e
        add a,5
        ld e,a ;+19 = 377
         res 4,b
        ld c,(hl) ;tile left
        DRAWTILELAYERDOWN
        inc hl
        dec e
         set 4,b
        ld c,(hl) ;tile right
        DRAWTILELAYERUP
        inc hl
        ld a,e
        add a,5
        ld e,a
         res 4,b
        ld c,(hl) ;tile left
        DRAWTILELAYERDOWN
        inc hl
        dec e
         set 4,b
        ld c,(hl) ;tile right
        DRAWTILELAYERUP
        inc hl
        ld a,e
        add a,5
        ld e,a
         res 4,b
        ld c,(hl) ;tile left
        DRAWTILELAYERDOWN
        inc hl
        dec e
         set 4,b
        ld c,(hl) ;tile right
        DRAWTILELAYERUP
        ret

;8x8
;рисуем всегда с ровного x/8 (x2/4), а Y может пересекать страницу
;при высоте 200 может понадобиться отрисовать 14 метатайлов по вертикали
;при высоте 192-16 может понадобиться отрисовать 12 метатайлов по вертикали
drawtiles_ver_hla_de
;de=tilemap+
;hla=allscroll+
;b=число блоков по 8 тайлов
        push bc
        ld hy,d
        ld ly,e ;tilemap+
        
         ld d,l ;y*2
        add hl,hl
         srl d ;y (corrected для зацикливания)
         rra
          rra
          rrca ;CY=A7=x2&4
          rlca ;A0=CY=x2&4
          rla  ;A1=A0=x2&4
          xor 2 ;3->1, 0->2
         ld e,a
         ld a,h
         add a,a
         add a,a ;a=((y/64)*4)
        ld c,a
        ld b,0
        ld ix,tpushpgs
        add ix,bc ;ix=список страниц графики =f((x2+layer)&3 + ((y/64)*4))
         set 6,d ;y+0x40 (corrected для зацикливания)
;ix=tpushpgs+(Y/64*4)+layer
        pop bc ;b=число блоков по 8 тайлов
        
drawtiles_ver_blocks0
        push bc
        call drawtiles_ver_block
        ld bc,+(TILEMAPWID*8)-256 ;компенсация inc hy
        add iy,bc
        inc d
        jp p,drawtiles_ver_nonextpg
        ld a,d ;0x80..0xbf
        sub 64
        ld d,a
        ld bc,4
        add ix,bc
drawtiles_ver_nonextpg
        pop bc
        djnz drawtiles_ver_blocks0
        ret
drawtiles_ver_block
;ix=tpushpgs+
;iy=tilemap+
;de=ldpush+ (4000,8000)
;^^^делать SETPG один раз для горизонтальной линии тайлов и 1 раз за 8 тайлов для вертикальной линии тайлов (8 тайлов не может вылететь за вторую страницу, т.к. мы рисуем всегда с ровного X/8=x/64)
;выводить линию тайлов: сначала весь первый слой, потом весь второй и т.д.
        ld a,(pgtilegfx) ;TODO по зоне
        SETPG32KHIGH
        ld a,(ix)
        SETPG16K
        ld a,(ix+4)
        SETPG32KLOW
drawtiles_ver_block_tilegfx=$+1
        ld h,TILEGFX/256 ;+0x10, если X=x/8 нечётное
        ld l,d
        call drawtiles_ver_layer
        dec hy
        ld a,(ix+1)
        SETPG16K
        ld a,(ix+5)
        SETPG32KLOW
         set 5,h
        ld d,l
        call drawtiles_ver_layer
        dec hy
        ld a,(pgtilegfx2) ;TODO по зоне
        SETPG32KHIGH
        ld a,(ix+2)
        SETPG16K
        ld a,(ix+6)
        SETPG32KLOW
         res 5,h
        ld d,l
        call drawtiles_ver_layer
        dec hy
        ld a,(ix+3)
        SETPG16K
        ld a,(ix+7)
        SETPG32KLOW
         set 5,h
        ld d,l
drawtiles_ver_layer
;
;c000: metatile gfx
;iy<3f00: tilemap (содержит номера метатайлов! то есть важна чётность строки тайлов, мы всегда должны рисовать с целого метатайла)
;4000,8000: ld:push
;чтобы выводить тайлы 8x8 прямо из графики метатайлов, надо расположить их в памяти вертикально (каждый метатайл = 128 inc h)
;слои отстоят друг от друга на +0x2000
;реально в tilemap могут быть независимые номера тайлов, так что используется 4 набора тайлов - для каждой комбинации чётностей X,Y - важно для надписей
;поэтому не пропускаем ld c
        ld b,h
        ld c,(iy) ;tile top
        DRAWTILELAYERDOWN ;+168
        inc d
        inc b;ld b,h
        ld c,(iy+TILEMAPWID) ;tile bottom
        DRAWTILELAYERDOWN
        inc d
        ld b,h
        ld c,(iy+(TILEMAPWID*2)) ;tile top
        DRAWTILELAYERDOWN
        inc d
        inc b;ld b,h
        ld c,(iy+(TILEMAPWID*3)) ;tile bottom
        DRAWTILELAYERDOWN
        inc hy
        inc d
        ld b,h
        ld c,(iy+(TILEMAPWID*4-256)) ;tile top
        DRAWTILELAYERDOWN
        inc d
        inc b;ld b,h
        ld c,(iy+(TILEMAPWID*5-256)) ;tile bottom
        DRAWTILELAYERDOWN
        inc d
        ld b,h
        ld c,(iy+(TILEMAPWID*6-256)) ;tile top
        DRAWTILELAYERDOWN
        inc d
        inc b;ld b,h
        ld c,(iy+(TILEMAPWID*7-256)) ;tile bottom
        DRAWTILELAYERDOWN
        ret
       endif


tcallpgs
        ds UVSCROLL_NCALLPGS

        display "x2scroll=",x2scroll
x2scroll
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


pgtilegfx
        db 0 ;TODO по зонам
pgtilegfx2
        db 0 ;TODO по зонам
