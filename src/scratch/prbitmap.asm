;вывод битмэпа на экран

        MACRO SHOWBITMAPLINELAYER02_25 ;вывод пикселей ab..ef..
        ld b,lx
_=$
        exx
        ld c,(iy)
        ld a,(bc)
        ld l,(iy+4)
        or (hl)
        ld (de),a
        set 5,d
        ld c,(iy+16)
        ld a,(bc)
        ld l,(iy+20)
        or (hl)
        ld (de),a
        res 5,d
        inc de
        exx
        add iy,de ;32
        djnz _
        ENDM

        MACRO SHOWBITMAPLINELAYER02_50 ;вывод пикселей ab..ef..
        ld b,lx
_=$
        exx
        ld c,(iy)
        ld a,(bc)
        ld l,(iy+2)
        or (hl)
        ld (de),a
        set 5,d
        ld c,(iy+8)
        ld a,(bc)
        ld l,(iy+10)
        or (hl)
        ld (de),a
        res 5,d
        inc de
        exx
        add iy,de ;16
        djnz _
        ENDM

        MACRO SHOWBITMAPLINELAYER02_100 ;вывод пикселей ab..ef..
;180t/4pix (было 202)
        ld b,lx
_=$
        exx
        ld c,(iy)
        ld a,(bc) ;0L000LLL
        ld l,(iy+1)
        or (hl) ;(hl)=R0RRR000
        ld (de),a
        set 5,d
        ld c,(iy+4)
        ld a,(bc) ;0L000LLL
        ld l,(iy+5)
        or (hl) ;(hl)=R0RRR000
        ld (de),a
        res 5,d
        inc de
        exx
        add iy,de ;8
        djnz _
        ENDM

        MACRO SHOWBITMAPLINELAYER02_200 ;вывод пикселей ab..ef..
;106t/ (через стек можно 86)
        ld hx,lx
_=$
        ld e,(hl)
        inc hl
        inc hl
        ld a,(de)
        ld (bc),a
        set 5,b
        ld e,(hl)
        inc hl
        inc hl
        ld a,(de)
        ld (bc),a
        res 5,b
        inc bc
        dec hx
        jp nz,_
        ENDM

        MACRO SHOWBITMAPLINELAYER02_400 ;вывод пикселей ab..ef..
        ld hx,lx
_=$
        ld e,(hl)
        inc hl
        ld a,(de)
        ld (bc),a
        set 5,b
        ld e,(hl)
        inc hl
        ld a,(de)
        ld (bc),a
        res 5,b
        inc bc
        dec hx
        jp nz,_
        ENDM

prbitmapbox
;hl=x в bitmap
;de=y в bitmap
;c=x/8 на экране
;b=y на экране
;hy=hgt
;lx=wid(chr)
        push bc ;xy на экране
        push hl ;x в bitmap
        call calcscr_from_xchr_y
        pop bc ;x в bitmap
        ld a,h
        add a,+((scrbase16k-scrbase)/256)&0xff ;or scrbase16k/256 ;0xc0
        ld h,a
        push hl ;scr (0xc000+)
        call calcbitmap_from_xy ;out: a=pg, hl=addr
        pop de ;scr (0xc000+)
        ld bc,(curbitmapscale) ;1=25%, 2=50%, 3=100%, 4=200%, 5=400%
        dec c
        jp z,showbitmapbox_25_lines
        dec c
        jp z,showbitmapbox_50_lines
        dec c
        jp z,showbitmapbox_100_lines
        dec c
        jr z,showbitmapbox_200_lines
        ;dec c
        ;jp z,showbitmapbox_400_lines
        ;pop bc
        ;ret ;никогда
showbitmapbox_400_lines
        ld c,hy
        inc c
        srl c
        inc c
        srl c
        ld hy,c ;/4 с округлением вверх
        push iy
showbitmapbox_400_lines0
        ld ly,4
showbitmapbox_400_lines1
        push de ;scr (0xc000+)
        push af ;pg
        call setpg32k
        push hl ;bitmap addr
         push de ;scr (0xc000+)
         push hl ;bitmap addr
        ;ld a,(setpgs_scr_low)
        ld a,(user_scr0_low)
        SETPG4000
        ld b,d
        ld c,e
        ld d,tpixelrecode/256
        SHOWBITMAPLINELAYER02_400 ;lx=wid(chr)
         pop hl ;bitmap addr
        ;ld a,(setpgs_scr_high)
        ld a,(user_scr0_high)
        SETPG4000
         pop bc ;scr (0xc000+)
        SHOWBITMAPLINELAYER02_400 ;lx=wid(chr)
        pop hl ;bitmap addr
        pop af ;pg
        pop de ;scr (0xc000+)
        call showbitmapbox_scrlinedown
        dec ly
        jp nz,showbitmapbox_400_lines1
        call showbitmapbox_linedown
        dec hy
        jp nz,showbitmapbox_400_lines0
        pop iy
        ld a,hy
        add a,a
        jr addaa_hya_popbc_showbitmaprightbox
        ;add a,a
        ;ld hy,a ;hy=hgt на экране
        ;pop bc ;xy на экране
;c=x/8 на экране
;b=y на экране
;hy=hgt
;lx=wid(chr)
        ;jp showbitmaprightbox ;делает setpgs_scr

showbitmapbox_200_lines
        ld c,hy
        inc c
        srl c
        ld hy,c ;/2 с округлением вверх
        push iy
showbitmapbox_200_lines0
        ld ly,2
showbitmapbox_200_lines1
        push de ;scr (0xc000+)
        push af ;pg
        call setpg32k
        push hl ;bitmap addr
         push de ;scr (0xc000+)
         push hl ;bitmap addr
        ;ld a,(setpgs_scr_low)
        ld a,(user_scr0_low)
        SETPG4000
        ld b,d
        ld c,e
        ld d,tpixelrecode/256
        SHOWBITMAPLINELAYER02_200 ;lx=wid(chr)
         pop hl ;bitmap addr
        ;ld a,(setpgs_scr_high)
        ld a,(user_scr0_high)
        SETPG4000
         pop bc ;scr (0xc000+)
        inc hl
        SHOWBITMAPLINELAYER02_200 ;lx=wid(chr)
        pop hl ;bitmap addr
        pop af ;pg
        pop de ;scr (0xc000+)
        call showbitmapbox_scrlinedown
        dec ly
        jp nz,showbitmapbox_200_lines1
        call showbitmapbox_linedown
        dec hy
        jp nz,showbitmapbox_200_lines0
        pop iy
        ld a,hy
addaa_hya_popbc_showbitmaprightbox
        add a,a
        ld hy,a ;hy=hgt на экране
        pop bc ;xy на экране
;c=x/8 на экране
;b=y на экране
;hy=hgt
;lx=wid(chr)
        jp showbitmaprightbox ;делает setpgs_scr

showbitmapbox_25_lines
        push iy
         exx
         ld de,32
         ld b,hy
         ld l,b
showbitmapbox_25_lines0
        exx
        push de ;scr (0xc000+)
        push af ;pg
        call setpg32k
        push hl ;bitmap addr
         push de ;scr (0xc000+)
          push hl ;bitmap addr
          pop iy
         ld bc,8
         add hl,bc
         push hl ;bitmap addr+2
        ld b,tpixelrecodeLEFT/256
        ld h,tpixelrecodeRIGHT/256
        exx
        ;ld a,(setpgs_scr_low)
        ld a,(user_scr0_low)
        SETPG4000
        SHOWBITMAPLINELAYER02_25 ;lx=wid(chr)
         pop iy ;bitmap addr+2
        exx
         pop de ;scr (0xc000+)
        exx
        ;ld a,(setpgs_scr_high)
        ld a,(user_scr0_high)
        SETPG4000
        SHOWBITMAPLINELAYER02_25 ;lx=wid(chr)
        exx
        pop hl ;bitmap addr
        pop af ;pg
        pop de ;scr (0xc000+)
        call showbitmapbox_scrlinedown
        call showbitmapbox_linedown2
        call showbitmapbox_linedown2
        exx
        dec l
        jp nz,showbitmapbox_25_lines0
        jp popiy_popbc_showbitmaprightbox
        ;pop iy ;hy=hgt на экране
        ;pop bc ;xy на экране
;c=x/8 на экране
;b=y на экране
;hy=hgt
;lx=wid(chr)
        ;jp showbitmaprightbox ;делает setpgs_scr

showbitmapbox_50_lines
        push iy
         exx
         ld de,16
         ld b,hy
         ld l,b
showbitmapbox_50_lines0
        exx
        push de ;scr (0xc000+)
        push af ;pg
        call setpg32k
        push hl ;bitmap addr
         push de ;scr (0xc000+)
          push hl ;bitmap addr
          pop iy
         ld bc,4
         add hl,bc
         push hl ;bitmap addr+2
        ld b,tpixelrecodeLEFT/256
        ld h,tpixelrecodeRIGHT/256
        exx
        ;ld a,(setpgs_scr_low)
        ld a,(user_scr0_low)
        SETPG4000
        SHOWBITMAPLINELAYER02_50 ;lx=wid(chr)
         pop iy ;bitmap addr+2
        exx
         pop de ;scr (0xc000+)
        exx
        ;ld a,(setpgs_scr_high)
        ld a,(user_scr0_high)
        SETPG4000
        SHOWBITMAPLINELAYER02_50 ;lx=wid(chr)
        exx
        pop hl ;bitmap addr
        pop af ;pg
        pop de ;scr (0xc000+)
        call showbitmapbox_scrlinedown
        call showbitmapbox_linedown2
        exx
        dec l
        jp nz,showbitmapbox_50_lines0
        jp popiy_popbc_showbitmaprightbox
        ;pop iy ;hy=hgt на экране
        ;pop bc ;xy на экране
;c=x/8 на экране
;b=y на экране
;hy=hgt
;lx=wid(chr)
        ;jp showbitmaprightbox ;делает setpgs_scr

showbitmapbox_100_lines
;hy=hgt
;lx=wid(chr)
;hl=gfxaddr
;a=pg
        push iy
         exx
         ld de,8
         ld b,hy
         ld l,b
showbitmapbox_100_lines0
         exx
        push de ;scr (0xc000+)
        push af ;pg
        call setpg32k
        push hl ;bitmap addr
         push de ;scr (0xc000+)
          push hl ;bitmap addr
          pop iy
         inc hl
         inc hl
         push hl ;bitmap addr+2
        ld b,tpixelrecodeLEFT/256
        ld h,tpixelrecodeRIGHT/256
        exx
        ;ld a,(setpgs_scr_low)
        ld a,(user_scr0_low)
        SETPG4000
        SHOWBITMAPLINELAYER02_100 ;lx=wid(chr)
         pop iy ;bitmap addr+2
        exx
         pop de ;scr (0xc000+)
        exx
        ;ld a,(setpgs_scr_high)
        ld a,(user_scr0_high)
        SETPG4000
        SHOWBITMAPLINELAYER02_100 ;lx=wid(chr)
        exx
        pop hl ;bitmap addr
        pop af ;pg
        pop de ;scr (0xc000+)
        call showbitmapbox_scrlinedown
        call showbitmapbox_linedown
         exx
        dec l
        jp nz,showbitmapbox_100_lines0
popiy_popbc_showbitmaprightbox
        pop iy ;hy=hgt на экране
        pop bc ;xy на экране
;c=x/8 на экране
;b=y на экране
;hy=hgt
;lx=wid(chr)
        ;jp showbitmaprightbox ;делает setpgs_scr

showbitmaprightbox
;c=x/8 на экране
;b=y на экране
;hy=hgt
;lx=wid(chr)
        push bc ;xy
        call setpgs_scr

        ld hl,(curbitmapwid_edit)
        ld de,(curbitmapxscroll)
        or a
        sbc hl,de
        call scalebitmapcoords
        pop bc ;xy
        
        ld de,workzonewid8*8
        or a
        sbc hl,de ;вычли ширину рабочей зоны
        ret nc ;вне экрана
        ;hl=минус максимальная ширина бокса по этой x-координате (!=0)
        
        push hl
        add hl,de
        ld de,workzonex8*8
        add hl,de ;hl=x на экране правой границы битмэпа
        ex de,hl ;de=x на экране правой границы битмэпа
        pop hl ;hl=минус максимальная ширина бокса по этой x-координате
        ;xor a
        ;sub l
        ;ld l,a
        ;sbc a,h
        ;sub l
        ;ld h,a
        call neghl ;hl=максимальная ширина бокса по этой x-координате (!=0)
        push de ;x
        ld de,7 ;максимум столько пикселей добавляется для округления
        or a
        sbc hl,de
        add hl,de
        jr c,$+3
        ex de,hl ;взяли наименьшее из 7 и максимальной ширины бокса по этой x-координате
        ;hl=wid (последний пиксель = x+wid-1)
        pop de ;x
        
        ld a,c ;x/8
        add a,lx ;wid(chr)
        dec a
        ld c,a ;x/8 самого правого отрисованного байта
        push de
        ld a,e
        srl d
        rra
        srl d
        rra
        srl d
        rra
        pop de
        cp c
        ret nz ;не рисуем на правой границе
        
        call setpgshapes
        
        ld c,b;30 ;c=y
        ;ld de,50 ;de=x
        ld b,hy;10 ;b=hgt (последний пиксель = y+hgt-1)
        ;ld lx,backcolor ;lx=color
        call getgreycolor
        ld lx,a
        jp shapes_prpixelbox

showbitmapbox_scrlinedown
        ex de,hl
        ld bc,40
        add hl,bc
        ex de,hl ;scr (0xc000+)
        ret

showbitmapbox_linedown2
        call showbitmapbox_linedown
showbitmapbox_linedown
        ld bc,(curbitmapwid_view)
        add hl,bc
        bit 6,h
        res 6,h
        ret z
        inc a ;pg
        ret
