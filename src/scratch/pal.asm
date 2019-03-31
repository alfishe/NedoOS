
editpal_HSx8=0
editpal_HSwid8=16
editpal_Vx8=20
editpal_Vwid8=4

editpal_colorx8=26
editpal_colorwid8=4
editpal_colory=0
editpal_colorhgt=32

editpal_curcolorx8=32
editpal_curcolorwid8=4
editpal_curcolory=0
editpal_curcolorhgt=32

editpal_oldcolorx8=editpal_curcolorx8
editpal_oldcolorwid8=editpal_curcolorwid8
editpal_oldcolory=56
editpal_oldcolorhgt=16
editpal_oldcolorystep=24

minC=64
maxC=96
;#define kC 8

calcRGBtoHSV
;  si = r/2-b/2;
;  c = r/2+b/2-g;
;  float rad = sqrt(si*si + c*c);
;  //TODO if (rad==0) ...

;  //float a=atan2(si,c);
;  float a = asin(si/rad);
;  if (c<0) a = PI - a;
;  Memo1->Lines->Add("a="+FloatToStr(a));
;  h=a/(2*PI);
;  if (h<0) {h=h+1;}

;  v = g/2 + r/4 + b/4;

;  float scoeff = (1 - fabs((v-.5)*2) );
;  s = rad/scoeff/1.7;

;d=r
;e=g
;b=b
        call setpgpal
        call setpgtemp
        
        srl d
        srl b
        srl e
        
        push bc
        push de
        
        ld a,d ;r/2
        sub b ;b/2
        ld h,a ;h=si = +-0..127
        ld l,0 ;isi=32768*si = +-0..32767
        ld a,d ;r/2
        add a,b ;b/2
        rra;srl a
        sub e ;a = (r/2+b/2-g)/2 = c/2
        ld e,a ;c/2 = +-0..127 (соответствует -1..+1)
         push af ;cy=S=знак c
        ld d,tsqr/256
        ld a,(de)
        ld b,a ;c*c
        ld e,h
        sra e ;si/2 = +-0..63 (соответствует -.5..+.5)
        ld a,(de) ;s*s
        add a,b ;+c*c
        ld e,a
        inc d ;tsqrt/256
;аргумент 0..255 (соответствует 0..2)
;результат 0..127 (соответствует 0..1) и выше
        ld a,(de) ;rad = sqrt(si*si + c*c)
        ld e,a
        ld d,0
;hl=isi=32768*si = +-0..32767
;de=irad=128*rad = 0..127
        call divhldesigned ;hl / de результат в hl
;hl=256*(si/rad) = +-0..255
        ;ld bc,256
        ;add hl,bc
        inc h ;hl = 0..511
        sra h
        rr l ;hl = 0..255 (если меньше или больше, то подгоняем)
        ld a,h
        or a
        jp p,$+3+2
        xor a
        ld l,a ;если меньше
        jr z,$+2+2
        ld l,255 ;если больше
        ;ld bc,tarcsin ;0..128 соответствуют -1..0; 128..255 соответствуют 0..+1
        ;add hl,bc
        ld h,tarcsin/256
         pop af ;cy=S=знак c
        ld a,(hl) ;-50..50 соответствуют -pi/2..+pi/2
        jr nc,calcRGBtoHSV_nonegcos
        cpl
        add a,100+1
calcRGBtoHSV_nonegcos
;a=-50..150 соответствуют -pi/2..+3*pi/2
        cp -50
        jr c,calcRGBtoHSV_nonegarcsin
        add a,200
calcRGBtoHSV_nonegarcsin
;a=H=0..199 соответствуют 0..+2*pi
        ld (curH),a
        
        pop de ;d=r/2, e=g/2
        pop af ;b/2
        ld b,3
        srl a
        srl d
        srl e
        djnz $-6
        ;ld b,a
;dea = r,g,b = 0..15
        ;ld a,b
        ld (calcRGBtoHSV_findB),a
        ld a,d
        ld (calcRGBtoHSV_findR),a
        ld a,e
        ld (calcRGBtoHSV_findG),a
;подбираем s,v, пишем их в curS, curV
        ld hx,255 ;min
;l=iv=0..32 ;h=is=#e0+0..31
        ld h,editpal_e0 ;S
calcRGBtoHSV_findS0
        ld l,32 ;V
calcRGBtoHSV_findV0
        ld a,(curH) ;a=h
;h=s
;l=v
        push hl
        call calcHSVtoRGB
;d'e'b' = r,g,b [h,s,v] = 0..15
        exx
        ld a,d
calcRGBtoHSV_findR=$+1        
        sub 0
        jr nc,$+4
        neg
        ld c,a ;разница R
        ld a,e
calcRGBtoHSV_findG=$+1
        sub 0
        jr nc,$+4
        neg
        add a,c
        ld c,a ;разница R+разница G
        ld a,b
calcRGBtoHSV_findB=$+1
        sub 0
        jr nc,$+4
        neg
        add a,c ;общая разница
        exx
        pop hl
        cp hx ;min
        jr nc,calcRGBtoHSV_findnomin
        ld hx,a
        ld a,l
        ld (curV),a
        ld a,h
        ld (curS),a
calcRGBtoHSV_findnomin
;l=iv=0..32 ;h=is=#e0+0..31
        dec l
        jp p,calcRGBtoHSV_findV0
        inc h
         ld a,h
         cp editpal_e0+32
        jr nz,calcRGBtoHSV_findS0
        
        jp setpgs_scr

        macro calcHSVtogfx_1
;  int isi = 4*s*tsin[ih]/kC;
;  int ic = 2*s*tsin[(64-ih)&0xff]/kC;
;  ir = iv + isi + ic + minC;
;  ig = iv +     - ic + minC;
;  ib = iv - isi + ic + minC;
;h=is=#c0+0..31 (уже пересчитано для заданного iv)
;a=ih=0..199
;b=iv=0..32
;d=tabclippal/256 + (y&3)*2
        ld l,a
        ld e,(hl) ;isi = +-0..32 ;sin
        sla e
        add a,50 ;четверть периода
        ld l,a
        ld c,(hl) ;ic = +-0..32 ;cos
        endm
        
        macro calcHSVtogfx_2
        ld a,b ;iv
        sub c ;ic
        ld d,a ;iv - ic

        ld a,b ;iv
        add a,e ;isi = +-0..32
        add a,c ;ic
        ld l,a ;iv + isi + ic
        ld b,(hl) ;h=tabclippal[y]/256
        inc h
        ld c,(hl)                            ;bc=%0000B00A %0000D00C [r]
        sub e ;isi = +-0..32
        sub e ;isi = +-0..32
        ld l,a ;iv - isi + ic
        ld e,(hl)
        dec h
        ld a,(hl) ;h=tabclippal[y]/256       ;ae=%0000B00A %0000D00C [b]

        ld l,d ;iv - ic
        rlca
        or (hl) ;h=tabclippal[y]/256       ;a=%0000B00A [g]
        rlca
        or b
        ex af,af'
        inc h
        ld a,e ;h=tabclippal[y]/256 + 1   ;a=%0000D00C [g]
        rlca
        or (hl)
        rlca
        or c ;a'a = возвращаем 2 байта (4 пикселя по горизонтали) 
        endm
        
;в палитре редактора палитры первые 8 цветов: BGR

copytemp_setpal
        call setpgtemp
        ld de,#ffe0
        push de
        ld bc,32
        ldir
        pop de
        OS_SETPAL
        ret
paleditorpal
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
;high B, high b, low B, low b
paleditorpal_color=$+(8*2) ;видимый цвет
paleditorpal_curcolor=$+(9*2) ;текущий цвет
paleditorpal_oldcolors=$+(10*2) ;старые цвета
        dw #f3f3,#b1b1,#6363,#2121,#d2d2,#9090,#4242,#0000
        dw #f3f3,#d2d2,#b1b1,#9090,#6363,#4242,#2121,#0000 ;8=видимый цвет, 9=текущий цвет, остальные старые
paleditorpalend=$-1
RSTPAL
        ;dw #f3f3,#f2f2,#f1f1,#f0f0,#e3e3,#e2e2,#e1e1,#e0e0
        ;dw #f3f3,#d2d2,#b1b1,#9090,#6363,#4242,#2121,#0000
        STANDARDPAL
RSTPALend=$-1

drawpal
        call cls
        
        ld hl,paleditorpal
        call copytemp_setpal

        call drawpalHS
        call drawpalV

        call drawpalcolor ;видимый цвет
        call drawpalcurcolor ;текущий цвет
;старые цвета
        call setpgshapes

        ld bc,editpal_oldcolory*256 + editpal_oldcolorx8 ;b=y ;c=x/8
        ld hl,paleditorpal_oldcolors
        ld a,%11010010 ;a=%33210210
drawpaloldcolors0
        push af
        push bc
        push hl
        push bc
        ld de,editpal_oldcolorhgt*256+editpal_oldcolorwid8 ;d=hgt ;e=wid8
        call shapes_fillbox
        pop bc
        pop hl
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
         ld a,c
         add a,4*40 - 4
         call calcscr_from_xchr_ya
         set 5,h ;на 4 пикселя правее
        call prhexcolor
        pop hl
        pop bc
        ld a,b
        add a,editpal_oldcolorystep
        ld b,a
        pop af
        add a,%1001
        cp #ff&(%11111111+%1001)
        jr nz,drawpaloldcolors0
       
drawpal_cursors
        call setpgshapes

        ld a,(curS) ;x
        sub editpal_e0
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        ld a,(curH) ;y
        call shapes_prarr_ring8c ;HS
        ld hl,+(editpal_Vx8*8)+(editpal_Vwid8*4)
        ld a,(curV) ;y
        ld c,a
        add a,a
        add a,c
        add a,a ;*6
        add a,3
        cpl
        add a,200
        jp shapes_prarr_ring8c
        
;текущий цвет        
drawpalcurcolor
        call setpgshapes

        ld de,(paleditorpal_curcolor)
        ld hl,#2000+(editpal_curcolory+editpal_curcolorhgt)*40+editpal_curcolorx8 + scrbase
        call prhexcolor
        ld bc,editpal_curcolory*256 + editpal_curcolorx8 ;b=y ;c=x/8
        ld de,editpal_curcolorhgt*256+editpal_curcolorwid8 ;d=hgt ;e=wid8
        ld a,%11001001 ;a=%33210210
        jp shapes_fillbox

calchexcolor
;hl=color (DDp palette)
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
;high B, high b, low B, low b
        ld b,#ff
        ld de,#ffff
        ld a,h
        rra
        rl b ;B high
        rra
        rl d ;R high
        rra
        rra
        rra
        rl e ;G high
        rra
        rl b ;b high
        rra
        rl d ;r high
        rra
        rl e ;g high
        ld a,l
        rra
        rl b ;B low
        rra
        rl d ;R low
        rra
        rra
        rra
        rl e ;G low
        rra
        rl b ;b low
        rra
        rl d ;r low
        rra
        rl e ;g low
;b=B
;d=R
;e=G
        ld a,d ;R
        cpl ;%0000rrrr
        ld d,a
        rlca
        rlca
        rlca
        rlca
        or d
        ld d,a
        ld a,e ;G
        cpl ;%0000gggg
        ld e,a
        rlca
        rlca
        rlca
        rlca
        or e
        ld e,a
        ld a,b ;B
        cpl ;%0000bbbb
        ld b,a
        rlca
        rlca
        rlca
        rlca
        or b
        ld b,a
;b=#BB
;d=#RR
;e=#GG
        ret
        
prhexcolor
;pgshapes!
;de=color (DDp palette)
;hl=screen        
        ld lx,0
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
;high B, high b, low B, low b
        push hl
        ex de,hl
        call calchexcolor
        pop hl
        ld a,d ;R
        call shapes_prhexbyte
        ld a,e ;G
        call shapes_prhexbyte
        ld a,b ;B
        jp shapes_prhexbyte
        
        
drawpalHS
        ld hl,editpal_HSx8 + scrbase
        ld c,32 ;S
drawpalcolumns0
        xor a
        sub c
         add a,editpal_e0-#e0
        ld (drawpalHS_S),a
        push hl
        ld de,40-#4000
        ld b,200 ;H
drawpalcolumn0
        call setpgpal
        call setpgtemp
        
        ld a,200
        sub b ;a=ih=0..199
        exx
;drawpalHS_V=$+1
;curV=$+1
drawpalHS_S=$+2
        ld hl,16 ;l=iv=0..32 ;h=is=#e0+0..31
        ld h,(hl) ;h=is=#c0+0..31 (уже пересчитано для заданного iv)
        ld b,l ;b=iv=0..32
        calcHSVtogfx_1
        ;a=ih (немного искажённое), соответствует y
        and 3
        add a,a
        add a,tabclippal/256
        ld h,a ;d=tabclippal/256 + (y&3)*2
        calcHSVtogfx_2

        push af
        call setpgs_scr
        pop af
        
        exx
        ld (hl),a
        set 6,h
        ex af,af'
        ld (hl),a
        add hl,de
        djnz drawpalcolumn0
        pop hl
        ld a,h
        xor #20
        ld h,a
         and #20
        jr nz,$+3
        inc l
        dec c
        jr nz,drawpalcolumns0
        ret
        
drawpalV
        ld hl,editpal_Vx8+40 + scrbase
        ld de,40-#4000
        ld c,200/6-1 ;V
drawpalVcolumn0
        ld b,6
drawpalVcolumn00
        call setpgpal
        call setpgtemp
        
        ld a,c
        exx
        ld l,a ;l=iv=0..32
curS=$+1
        ld h,editpal_e0+16 ;h=is=#e0+0..31
        ld h,(hl) ;h=is=#c0+0..31 (уже пересчитано для заданного iv)
        ld b,l ;b=iv=0..32
curH=$+1
        ld a,0
        calcHSVtogfx_1
        exx
        ld a,c
        add a,a
        add a,b
        exx ;a=y
        and 3
        add a,a
        add a,tabclippal/256
        ld h,a ;d=tabclippal/256 + (y&3)*2
        calcHSVtogfx_2

        push af
        call setpgs_scr
        pop af
        
        exx
        dup editpal_Vwid8-1
        ld (hl),a
        inc hl
        edup
        ld (hl),a
        set 5,h
        dup editpal_Vwid8-1
        ld (hl),a
        dec hl
        edup
        ld (hl),a
        set 6,h
        ex af,af'
        dup editpal_Vwid8-1
        ld (hl),a
        inc hl
        edup
        ld (hl),a
        res 5,h
        dup editpal_Vwid8-1
        ld (hl),a
        dec hl
        edup
        ld (hl),a
        add hl,de
        djnz drawpalVcolumn00
        dec c
        jp p,drawpalVcolumn0
        ret
        
drawpal_countpixels
        push bc
        push de
        calcHSVtogfx_2
;d'=r, e'=g
;b'=b
;a'a=два цвета = %00bgrbgr
        exx
        rra
        jr nc,$+3
        inc d ;r
        rra
        jr nc,$+3
        inc e ;g
        rra
        jr nc,$+3
        inc b ;b
        rra
        jr nc,$+3
        inc d ;r
        rra
        jr nc,$+3
        inc e ;g
        rra
        jr nc,$+3
        inc b ;b
        ex af,af'
        rra
        jr nc,$+3
        inc d ;r
        rra
        jr nc,$+3
        inc e ;g
        rra
        jr nc,$+3
        inc b ;b
        rra
        jr nc,$+3
        inc d ;r
        rra
        jr nc,$+3
        inc e ;g
        rra
        jr nc,$+3
        inc b ;b
        exx
        pop de
        pop bc
        ret
        
calcHSVtoRGB
;a=h
;h=s
;l=v
        exx
        ld b,0 ;b=b
        ld d,b
        ld e,b ;d=r, e=g
        exx
        ld h,(hl) ;h=is=#c0+0..31 (уже пересчитано для заданного iv)
        ld b,l ;b=iv=0..32
        calcHSVtogfx_1
        ld h,tabclippal/256 ;d=tabclippal/256 + (y&3)*2
        call drawpal_countpixels
        ld h,tabclippal/256+2 ;d=tabclippal/256 + (y&3)*2
        call drawpal_countpixels
        ld h,tabclippal/256+4 ;d=tabclippal/256 + (y&3)*2
        call drawpal_countpixels
        ld h,tabclippal/256+6 ;d=tabclippal/256 + (y&3)*2
        call drawpal_countpixels
        exx
        bit 4,b
        jr z,$+3
        dec b
        bit 4,d
        jr z,$+3
        dec d
        bit 4,e
        jr z,$+3
        dec e
        exx
;d'=r, e'=g
;b'=b
;0..15
        ret
        
drawpal_HSVtocolor
        call setpgpal
        call setpgtemp
        
        ld hl,(curS-1) ;h=is=#e0+0..31
curV=$+1
        ld l,0 ;l=iv=0..32
        ld a,(curH)
;a=h ;h=s ;l=v
        call calcHSVtoRGB
        exx
;d=r, e=g, b=b = 0..15
        ld a,d
        rla
        rla
        rla
        rla
        ld l,a ;R
        ld a,e
        rla
        rla
        rla
        rla
        ld d,a ;G
        ld a,b
        rla
        rla
        rla
        rla
        ld e,a ;B
;e=B, d=G, l=R
        call calcRGBtopal_pp
        ld b,a
        call calcRGBtopal_pp
        ld c,a
;b,c=%grbG11RB
        ld (paleditorpal_color),bc
        jp setpgs_scr

calcRGBtopal_pp
;e=B, d=G, l=R
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
        xor a
        rl e  ;B
        rra
        rl l  ;R
        rra
        rrca
        rrca
        rl d  ;G
        rra
        rl e  ;b
        rra
        rl l  ;r
        rra
        rl d  ;g
        rra
        cpl
        ret

drawpalcolor
        ld hl,paleditorpal
        call copytemp_setpal
        call setpgs_scr

        call setpgshapes

        ld de,(paleditorpal_color)
        ld hl,#2000+(editpal_colory+editpal_colorhgt)*40+editpal_colorx8 + scrbase
        call prhexcolor

        ;ld hl,paleditorpalend
        ;call setpalhl

        ld bc,editpal_colory*256 + editpal_colorx8 ;b=y ;c=x/8
        ld de,editpal_colorhgt*256+editpal_colorwid8 ;d=hgt ;e=wid8
        ld a,%11000000 ;a=%33210210
        jp shapes_fillbox
        
       
editpal
;hl=редактируемый цвет
        ld (editpal_quitsp),sp
        push hl

        call initpal ;составление таблиц
        
        ld hl,paleditorpalend-2 ;paleditorpal_curcolor+...
        ld de,paleditorpalend ;paleditorpal_oldcolors+...
        ld bc,paleditorpalend+1-paleditorpal_oldcolors
        lddr
        pop hl
        ld (paleditorpal_curcolor),hl
        push hl
        call calchexcolor
        call calcRGBtoHSV ;назначает curH,curS,curV
        pop hl
        ld (paleditorpal_color),hl ;потом, чтобы точнее оставить цвет
        
        call drawpal
        
        ld a,ZONE_NO
        ld (prarr_zone),a
        
editpalloop
;1. всё выводим
;2. ждём событие
;3. всё стираем
;4. обрабатываем событие
        call setpgshapes

        ;call ahl_coords
        ;call invarrzone
        call ahl_coords
        call shapes_memorizearr
        call ahl_coords
        call shapes_prarr8c
        
        call waitsomething ;в это время стрелка видна
;что-то изменилось
        
        call ahl_oldcoords
        call shapes_rearr
        ;call ahl_oldcoords
        ;call invarrzone ;инвертировать пункт под стрелкой
	
        ld a,(key)
        cp key_redraw
        call z,drawpal
        ld a,(mousebuttons)
        cpl
        and 7
        call nz,editpal_fire
        jr editpalloop

editpal_fire
;editpal_rmb
        ld hl,(arrx)
        ld a,l
        srl h
        rra
        srl h
        rra
;editpal_HSx8=0
;editpal_HSwid8=16
;editpal_Vx8=20
;editpal_Vwid8=4
        sub editpal_HSx8*2
        ret c ;jr c,editpal_fire_or_rmbq
        cp editpal_HSwid8*2
        jr c,editpal_fire_or_rmbHS
        sub +(editpal_Vx8*2)-(editpal_HSx8*2)
        ret c ;jr c,editpal_fire_or_rmbq
        cp editpal_Vwid8*2
        jr c,editpal_fire_or_rmbV
        sub +(editpal_colorx8*2)-(editpal_Vx8*2)
        ret c ;jr c,editpal_fire_or_rmbq
        cp editpal_colorwid8*2
        jr c,editpal_fire_or_rmbsetcolor
        sub +(editpal_curcolorx8*2)-(editpal_colorx8*2)
        ret c ;jr c,editpal_fire_or_rmbq
        cp editpal_curcolorwid8*2
        jr c,editpal_fire_or_rmbsetcurcolor
;editpal_fire_or_rmbq

        ret

editpal_fire_or_rmbHS
;a=x/4=0..31
        push af
        call drawpal_cursors
        pop af
        add a,editpal_e0
        ld (curS),a
        ld a,(arry)
        ld (curH),a
        call drawpal_HSVtocolor
editpal_fire_redrawpals
        call drawpalV
        call drawpalcolor
        jp drawpal_cursors
        
editpal_fire_or_rmbV
        call drawpal_cursors
        ld a,(arry) ;0..199
        cpl
        add a,200
        jr z,$+3
        dec a ;0..198
        ld c,-1
        sub 6
        inc c
        jr nc,$-3 ;c=a/6
        ld a,32
        cp c
        jr c,$+3 ;c>32
        ld a,c ;c<=32
        ld (curV),a ;0..32
        ;call drawpalHS
        ;call drawpalV
        call drawpal_HSVtocolor
        call drawpalcolor
        jp drawpal_cursors
        
editpal_fire_or_rmbsetcolor
;установить цвет и выйти
        ld a,(arry) ;0..199
        sub editpal_colory
        cp editpal_colorhgt
        ret nc
        ld hl,(paleditorpal_color)
        ld (paleditorpal_curcolor),hl ;чтобы видеть на следующем входе
        ;jp editpal_quit ;hl=цвет-результат
editpal_quit
        ld hl,(paleditorpal_curcolor) ;как было
;hl=цвет-результат
editpal_quitsp=$+1
        ld sp,0
        ret

editpal_fire_or_rmbsetcurcolor
        ld a,(arry)
        sub editpal_curcolory
        cp editpal_curcolorhgt
        jr c,editpal_quit ;hl=цвет-результат
        sub editpal_oldcolory-editpal_curcolory
        ld hl,paleditorpal_oldcolors
        ld b,6
editpal_fire_or_rmbsetoldcolor0
        cp editpal_oldcolorhgt
        jr c,editpal_fire_or_rmbsetoldcolorok
        sub editpal_oldcolorystep
        inc hl
        inc hl
        djnz editpal_fire_or_rmbsetoldcolor0
        ret

editpal_fire_or_rmbsetoldcolorok
        push hl
        call drawpal_cursors
        pop hl
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ld (paleditorpal_color),hl
        push hl
        call calchexcolor
        call calcRGBtoHSV ;назначает curH,curS,curV
        pop hl
        ld (paleditorpal_color),hl ;потом, чтобы точнее оставить цвет
        jp editpal_fire_redrawpals ;там drawpal_cursors

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Инициализация ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;        

initpal
        call setpgpal
        call setpgtemp
        
        ld hl,tsin
initpalmuls0        
        push hl
        ld a,(hl)
        ld c,a
        rla
        sbc a,a
        ld b,a ;bc=-127..+127
        ld e,l
        ld d,editpal_c0
        ld hl,0
initpalmul0
        ld a,h
        ld (de),a
        add hl,bc
        add hl,bc
        inc d
        bit 5,d
        jr z,initpalmul0
        pop hl
        inc l
        jr nz,initpalmuls0 ;важны 0..200

;mktabfixsaturation
;  int scoeff = (1 - ((v-.5)*2)*((v-.5)*2) )*256;
;h=is=#e0+0..31
;l=iv=0..32
;(hl) = is*scoeff/256 + #c0

        ld h,l ;hl=0
initpalfixsat_volumes0
        push hl
;scoeff = (1 - ((v-.5)*2)*((v-.5)*2) )*256*8;
        ld e,l
        ld d,editpal_e0
        ;ld h,tscoeff/256
        ld bc,tscoeff
        add hl,bc
        ld c,(hl) ;0..255
        ld b,0
        ld hl,editpal_c0*256
initpalfixsat0
        ld a,h
        ld (de),a
        add hl,bc ;максимум умножили на 31
        inc d
         ld a,d
         cp editpal_e0+32
        jr nz,initpalfixsat0
        pop hl
        inc l
        jr nz,initpalfixsat_volumes0
        
;mktabclippal
;(hl) = %0000B00A [L]
;(hl+256) = %0000D00C [L]

;  if (ir<minC) ir=minC; if (ir>=maxC) ir=maxC-1;
;  if (ig<minC) ig=minC; if (ig>=maxC) ig=maxC-1;
;  if (ib<minC) ib=minC; if (ib>=maxC) ib=maxC-1;

;  ir = (ir-minC)*kC;
;  ig = (ig-minC)*kC;
;  ib = (ib-minC)*kC;

        ld hl,tchunkpixelnumber
        ld de,tabclippal
mktabclippals0

mktabclippal0
        ld a,e
        cp -minC
        jr c,$+3
        xor a
        add a,a
        jr c,calcHSVtoRGB_maxR
        add a,a
        jr c,calcHSVtoRGB_maxR
        add a,a
        jr nc,calcHSVtoRGB_nomaxR
calcHSVtoRGB_maxR
        sbc a,a
calcHSVtoRGB_nomaxR
         push hl
        ld bc,0
        cp (hl)
        inc hl
        jr c,$+3;4
        inc c ;set 0,c
        cp (hl)
        inc hl
        jr c,$+4
        set 3,c
        cp (hl)
        inc hl
        jr c,$+3;4
        inc b ;set 0,b
        cp (hl)
        jr c,$+4
        set 3,b
         pop hl
        ld a,c
        ld (de),a
        inc d
        ld a,b
        ld (de),a
        dec d
        inc e
        jr nz,mktabclippal0
        ld bc,4
        add hl,bc
        inc d
        inc d
        ld a,d
        cp tabclippal/256+8
        jr nz,mktabclippals0
        
        jp setpgs_scr
        
tchunkpixelnumber
        db 0x01, 0xc1, 0x61, 0xa1
        db 0x91, 0x41, 0x11, 0xd1
        db 0xe1, 0x71, 0xb1, 0x31
        db 0x51, 0x21, 0x81, 0xf1

tscoeff
;iv = 0..32
;scoeff = (1 - ((v-.5)*2)*((v-.5)*2) )*256*8
;        dup 256
;_=($&#ff-16)*2
;        db #ff&((1024-(_*_))/32)
;        edup
_=0
        dup 8
        db _
_=_+18
        edup
        dup 8
        db _
_=_+10
        edup
        db #ff
        dup 8
_=_-10
        db _
        edup
        dup 8
_=_-18
        db _
        edup
