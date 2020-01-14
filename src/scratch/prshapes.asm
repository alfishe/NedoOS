;вывод на экран

        SHAPESPROC shapes_cls
        ld e,a
        OS_CLS
        ret

        SHAPESPROC shapes_copybox
;hl=экранный адрес левого верхнего угла окна
;de=экранный адрес, куда копировать окно
;c=wid8
;b=hgt
        or a
        sbc hl,de
        add hl,de
        jr c,copyboxrightdown_topleft ;hl < de
copyboxleftup
;hl=экранный адрес левого верхнего угла окна
;de=экранный адрес, куда копировать окно (выше или левее hl)
;c=wid8
;b=hgt
        ld a,c
copyboxleftup0
        push bc
        ld b,0
        call ldir_a
        set 5,h
        set 5,d
        call ldir_a
        set 6,h
        set 6,d
        call ldir_a
        res 5,h
        res 5,d
        call ldir_a
        res 6,h
        res 6,d
        ld  c,40 ;b=0
        ex de,hl
        add hl,bc
        ex de,hl
        add hl,bc
        pop bc
        djnz copyboxleftup0
        ret
copyboxrightdown_topleft
;hl=экранный адрес левого верхнего угла окна
;de=экранный адрес, куда копировать окно (выше или левее hl)
;c=wid8
;b=hgt
        push bc
        push hl
        ld a,c ;wid8
        ld c,b ;hgt
        ld b,0
        ld h,b
        ld l,c ;hgt
        add hl,hl
        add hl,hl
        add hl,bc ;*5
        add hl,hl
        add hl,hl
        add hl,hl ;*40
        add a,l
        ld c,a
        adc a,h
        sub c
        ld b,a        
        pop hl
        dec bc
;bc=hgt*40 + wid8 - 1
        ex de,hl
        add hl,bc
        ex de,hl
        add hl,bc
        pop bc
;hl=экранный адрес правого нижнего угла окна + 40
;de=экранный адрес, куда копировать окно + 40 (ниже или правее hl)
;c=wid8
;b=hgt
        ld a,c
copyboxrightdown0
        push bc
        ld bc,-40
        ex de,hl
        add hl,bc
        ex de,hl
        add hl,bc
        ld b,0
        call lddr_a
        set 5,h
        set 5,d
        call lddr_a
        set 6,h
        set 6,d
        call lddr_a
        res 5,h
        res 5,d
        call lddr_a
        res 6,h
        res 6,d
        pop bc
        djnz copyboxrightdown0
        ret
        
ldir_a
        ld c,a
        push hl
        push de
        ldir
        pop de
        pop hl  
        ret
        
lddr_a
        ld c,a
        push hl
        push de
        lddr
        pop de
        pop hl  
        ret
        
prpixel
;de=x (не портится)
;c=y (bc не портится)
;lx=color = %33210210
       ld a,b
        ld l,c
        ld h,0
        ld b,scrbase/256/8 ;h
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40 + scrbase
       ld b,a
prpixel_cury
;de=x (не портится)
;hl=addr(y)
;lx=color = %33210210
        ld a,d
        rra
        ld a,e
        rra
        jr c,prpixel_r
        rra
        jr nc,$+4
        set 6,h
        rra
        jr nc,$+4
        set 5,h
        and 0x3f;%00111111
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,lx
        xor (hl)
        and 0x47;%01000111 ;keep left pixel 
        xor (hl) ;right pixel from screen
        ld (hl),a
        ret
prpixel_r
        rra
        jr nc,$+4
        set 6,h
        rra
        jr nc,$+4
        set 5,h
        and 0x3f;%00111111
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,lx
        xor (hl)
        and 0xb8;%10111000 ;keep right pixel 
        xor (hl) ;left pixel from screen
        ld (hl),a
        ret

line_invpixel
;bc=x (в плоскости экрана относительно рабочей зоны, но может быть отрицательным)
;de=y (в плоскости экрана относительно рабочей зоны, но может быть отрицательным)
        ld a,c
        sub 255&(workzonewid8*8)
        ld a,b
        sbc a,+(workzonewid8*8)/256
        ret p
        xor b
        ret p ;x было отрицательное
        ld a,e
        sub 255&workzonehgt
        ld a,d
        sbc a,workzonehgt/256
        ret p
        xor d
        ret p ;y было отрицательное
        push bc
        push de
        ld a,e ;y
        ld hl,workzonex8*8
        add hl,bc
        ex de,hl ;de=x
        add a,workzoney
        ld c,a ;c=y
        call invpixel
        pop de
        pop bc
        ret
        
invpixel
;de=x (не портится)
;c=y (bc не портится)
       ld a,b
        ld l,c
        ld h,0
       ld b,scrbase/256/8 ;h
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40 + scrbase
       ld b,a
invpixel_cury
;de=x (не портится)
;hl=addr(y)
        ld a,d
        rra
        ld a,e
        rra
        jr c,invpixel_r
        rra
        jr nc,$+4
        set 6,h
        rra
        jr nc,$+4
        set 5,h
        and 0x3f;%00111111
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        xor 0x47;%01000111 ;left pixel from screen
        ld (hl),a
        ret
invpixel_r
        rra
        jr nc,$+4
        set 6,h
        rra
        jr nc,$+4
        set 5,h
        and 0x3f;%00111111
        add a,l
        ld l,a
        adc a,h
        sub l
        ld h,a
        ld a,(hl)
        xor 0xb8;%10111000 ;right pixel from screen
        ld (hl),a
        ret

        SHAPESPROC shapes_prpixelbox
;c=y
;de=x
;b=hgt (последний пиксель = y+hgt-1)
;hl=wid (последний пиксель = x+wid-1)
;lx=color %rlrrrlll
prpixelbox0
        push bc
        push de
        push hl ;wid
        call prpixelhorline
        pop hl ;wid
        pop de
        pop bc
        inc c
        djnz prpixelbox0
        ret

        SHAPESPROC shapes_invpixelframe
;bc=x
;de=y
;hl=hgt (последний пиксель = y+hgt)
;ix=wid (последний пиксель = x+wid)
        push bc
        push de
        push hl ;wid
        inc bc ;x
        call invpixelhorline
        pop hl ;wid
        pop de
        pop bc
        push bc
        push de
        push hl ;wid
        push ix
        add ix,de
        ld d,hx
        ld e,lx ;de=y+hgt
        pop ix
        call invpixelhorline
        pop hl ;wid
        pop de
        pop bc
        push bc
        push de
        add hl,bc ;x
        ld b,h
        ld c,l ;bc=x+wid
        push ix
        pop hl ;hgt
        inc de ;y
        push hl
        call invpixelverline
        pop hl ;hgt
        pop de
        pop bc
invpixelverline
;bc=x
;de=y
;hl=hgt
        ld a,h
        or l
        ret z
invpixelverline0
        push hl
        bit 0,l
        call nz,line_invpixel
        pop hl
        inc de ;y
        dec hl
        ld a,h
        or l
        jr nz,invpixelverline0
        ret
        
invpixelhorline
;bc=x
;de=y
;hl=wid
        ld a,h
        or l
        ret z
invpixelhorline0
        push hl
        bit 0,l
        call nz,line_invpixel
        pop hl
        inc bc ;x
        dec hl
        ld a,h
        or l
        jr nz,invpixelhorline0
        ret

        SHAPESPROC shapes_prpixelframe
;c=y
;de=x
;b=hgt (последний пиксель = y+hgt)
;hl=wid (последний пиксель = x+wid)
;lx=color %rlrrrlll
        push bc
        push de
        push hl ;wid
        inc de ;x
        call prpixelhorline
        pop hl ;wid
        pop de
        pop bc
        push bc
        push de
        push hl ;wid
        ld a,c ;y
        add a,b ;hgt
        ld c,a ;c=y+hgt
        call prpixelhorline
        pop hl ;wid
        pop de
        pop bc
        push bc
        push de
        add hl,de ;x
        ex de,hl ;de=x+wid
        inc c ;y
        call prpixelverline
        pop de
        pop bc
prpixelverline
;c=y
;de=x
;b=hgt
;lx=color
        inc b
        dec b
        ret z
prpixelverline0
prpixelverline_patch=$+1
        call prpixel
        inc c
        djnz prpixelverline0
        ret
        
prpixelhorline
;c=y
;de=x
;hl=wid
;lx=color
        ld a,h
        or l
        ret z
        push hl
        ld l,c
        ld h,0
        ld b,scrbase/256/8 ;h
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*40 + scrbase
        pop bc
        ld a,c
        dec bc
        ld c,b
        inc c ;c=(bc-1)/256+1
        ld b,a ;b=bc&0xff
prpixelhorline0
        push hl ;addr(cury)
prpixelhorline_patch=$+1
        call prpixel_cury
        pop hl ;addr(cury)
        inc de ;x
        djnz prpixelhorline0
        dec c
        jr nz,prpixelhorline0
        ret
        
        SHAPESPROC shapes_invbox
;b=y
;c=x/8
;d=hgt
;e=wid
invbox0
        push de ;d = hgt, e = wid(chr)
        call invhorline               
        pop de ;d = hgt, e = wid(chr)
        inc b ;y
        dec d
        jr nz,invbox0 
        ret

invhorline
;b=y
;c=x/8
;e=wid(chr)
        push bc
        call calcscr_from_xchr_y
        ld b,e
invhorline0
        ld a,(hl)
        cpl
        ld (hl),a
        set 5,h
        ld a,(hl)
        cpl
        ld (hl),a
        set 6,h
        ld a,(hl)
        cpl
        ld (hl),a
        res 5,h
        ld a,(hl)
        cpl
        ld (hl),a
        res 6,h
        inc hl
        djnz invhorline0
        pop bc
        ret
        
        SHAPESPROC shapes_colortocolormask
;a=color = %....3210
        push bc
        ld c,a
        ld b,c
        srl b
        rra
        srl b
        rra
        srl b
        rra
;a=%210...
        srl c
        rra
        srl c
        rra
        srl c
        rra
;a=%210210...
        rrc c
        rra
        rlc c
        rra
        pop bc
        ret

        SHAPESPROC shapes_fillbox
;b=y
;c=x/8
;d=hgt
;e=wid8
;a=%33210210
fillbox0
        push de ;d = hgt, e = wid(chr)
        call prhorline
        pop de ;d = hgt, e = wid(chr)
        inc b ;y
        dec d
        jr nz,fillbox0
        ret
        
        SHAPESPROC shapes_prbox
;b=y
;c=x/8
;d=hgt
;e=wid8
;a=%33210210 (рамка чёрная)
        push bc ;b = y, c = x 
        push de ;d = hgt, e = wid(chr)
        call shapes_fillbox
        pop de ;d = hgt, e = wid(chr)
        pop bc ;b = y, c = x 
        jp shapes_prboxframe
        
        SHAPESPROC shapes_prboxframe
;b=y
;c=x/8
;d=hgt
;e=wid8
;(рамка чёрная)
        push de ;d = hgt, e = wid(chr)
        call prverline_l
        pop de ;d = hgt, e = wid(chr)
        push bc
        ld a,c ;x/8
        add a,e ;wid(chr)
        dec a
        ld c,a ;x/8+wid(chr)-1
        push de ;d = hgt, e = wid(chr)
        call prverline_r
        pop de ;d = hgt, e = wid(chr)
        pop bc

        xor a ;black
        call prhorline                  
        ld a,b ;y
        add a,d ;hgt
        dec a
        ld b,a ;y+hgt-1
        xor a ;black
        ;call prhorline          
        ;ret       
prhorline
;b=y
;c=x/8
;e=wid(chr)
;a=%rlrrrlll
        push bc
        push af
        call calcscr_from_xchr_y
        pop af
        ld b,e
prhorline0
        ld (hl),a
        set 5,h
        ld (hl),a
        set 6,h
        ld (hl),a
        res 5,h
        ld (hl),a
        res 6,h
        inc hl
        djnz prhorline0
        pop bc
        ret
        
prverline_l
;b=y
;c=x/8
;d=hgt
        push bc
        call calcscr_from_xchr_y
        ld a,0xb8;%10111000
        and (hl)
        ld b,d
        ld de,40
prverline_l0
        ld (hl),a
        add hl,de
        djnz prverline_l0
        pop bc
        ret
        
prverline_r
;b=y
;c=x/8
;d=hgt
        push bc
        call calcscr_from_xchr_y
        ld a,h
        add a,0x60
        ld h,a
        ld a,0x47;%01000111
        and (hl)
        ld b,d
        ld de,40
prverline_r0
        ld (hl),a
        add hl,de
        djnz prverline_r0
        pop bc
        ret
        
        SHAPESPROC shapes_line
;bc=x (в плоскости экрана, но может быть отрицательным)
;de=y (в плоскости экрана, но может быть отрицательным)
;ix=x2
;hl=y2
        or a
        sbc hl,de
        add hl,de
        jp p,shapes_line_noswap
        ex de,hl ;y <-> y2
        push ix
        push bc
        pop ix
        pop bc ;x <-> x2
        ;ld a,lx
        ;ld lx,c
        ;ld c,a
        ;ld a,hx
        ;ld hx,b
        ;ld b,a ;x <-> x2
shapes_line_noswap
        or a
        sbc hl,de ;dy >= 0
        push hl ;dy
        ;ld a,lx
        ;sub c
        ;ld l,a
        ;ld a,hx
        ;sbc a,b
        ;ld h,a
        push ix
        pop hl
        sbc hl,bc
        push hl ;dx
        exx
        pop bc ;dx
        ld a,0x03 ;inc bc
        jp p,shapes_line_nodec
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a ;dx >= 0
        ld a,0x0b ;dec bc
shapes_line_nodec
        pop de ;dy
;a=код inc/dec bc
;bc'=x (в плоскости экрана, но может быть отрицательным)
;de'=y (в плоскости экрана, но может быть отрицательным)
;bc=dx
;de=dy
        ex de,hl
        or a
        sbc hl,bc
        add hl,bc
        ex de,hl
        jr nc,shapes_linever ;dy>=dx
        ld hy,b
        ld ly,c ;counter=dx
        inc iy ;inc hy ;рисуем, включая последний пиксель (учтено в цикле)
        ld h,b
        ld l,c
        sra h
        rr l ;ym=dx div 2
         ;xor a
         ;sub l
         ;ld l,a
         ;sbc a,h
         ;sub l
         ;ld h,a ;mym=256-(dx div 2)
        exx
        ld (shapes_lineincx),a
;bc=x
;de=y
;hl'=xm
;bc'=dx
;de'=dy
shapes_linehor0
        call line_invpixel
shapes_lineincx=$
        inc bc ;x+1        
        exx
        ;add hl,de ;mym+dy
        or a
        sbc hl,de ;ym-dy
        exx
        jr nc,shapes_linehor1
        inc de ;y+1
        exx
        ;or a
        ;sbc hl,bc ;mym-dx
        add hl,bc ;ym+dx
        exx
shapes_linehor1
        dec iy
        ld a,hy
        rla
        jp nc,shapes_linehor0
        ret
shapes_linever
        ld hy,d
        ld ly,e ;counter=dy
        ;inc iy ;inc hy ;рисуем, включая последний пиксель (учтено в цикле)
        ld h,d
        ld l,e
        sra h
        rr l
         ;xor a
         ;sub l
         ;ld l,a
         ;sbc a,h
         ;sub l
         ;ld h,a ;mxm=256-(dy div 2)
        exx
        ld (shapes_lineincx2),a
;bc=x
;de=y
;hl'=xm
;bc'=dx
;de'=dy
shapes_linever0
        call line_invpixel
        inc de ;y+1
        exx
        ;add hl,bc ;mxm+dx
        or a
        sbc hl,bc ;xm-dx
        exx
        jr nc,shapes_linever1
shapes_lineincx2=$
        inc bc ;x+1
        exx
        ;or a
        ;sbc hl,de ;mxm-dy
        add hl,de ;xm+dy
        exx
shapes_linever1
        dec iy
        ld a,hy
        rla
        jp nc,shapes_linever0
        ret
